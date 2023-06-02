import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';

class DetailOrder extends StatefulWidget {
  final String idOrder;

  const DetailOrder({required this.idOrder, Key? key}) : super(key: key);

  @override
  State<DetailOrder> createState() => _DetailOrderState();
}

class _DetailOrderState extends State<DetailOrder> {
  String? _logo;

  String? recipient;
  String? phone;
  List<dynamic> products = [];
  String? address;
  int totalPrice = 0;
  int totalWeight = 0;
  String? dateOrder;

  void getDetailORder() async {
    await FirebaseFirestore.instance
        .collection('orders')
        .doc(widget.idOrder)
        .get()
        .then((value) {
      if (mounted) {
        setState(() {
          recipient = value.data()!['recipient'];
          phone = value.data()!['phone'];
          products = value.data()!['productItem'];
          address = value.data()!['shippingAddress'];
          totalPrice = value.data()!['totalPrice'];
          totalWeight = value.data()!['totalWeight'];
          dateOrder = DateFormat('EEEE dd MMMM yyyy')
              .format((value.data()!['dateOrder']).toDate());
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getDetailORder();
  }

  void _createInvoice() async {
    final pdf = pw.Document();

    _logo = await rootBundle.loadString('assets/images/logo.svg');

    pdf.addPage(
      pw.MultiPage(
        header: _buildHeader,
        footer: _builtFooter,
        build: (context) => [
          _contentHeader(context),
          pw.SizedBox(height: 40),
          _contentTable(context),
          pw.SizedBox(height: 20),
          _contentFooter(context),
        ],
      ),
    ); // Page

    Uint8List bytes = await pdf.save();

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/invoice_${widget.idOrder}.pdf');

    await file.writeAsBytes(bytes);

    final status = await Permission.manageExternalStorage.status;

    if (!status.isGranted) {
      Permission.manageExternalStorage.request();
      await OpenFile.open(file.path);
    } else {
      await OpenFile.open(file.path);
    }
  }

  pw.Widget _buildHeader(pw.Context context) {
    return pw.Column(
      children: [
        pw.Container(
          //height: 50,
          decoration: pw.BoxDecoration(
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2)),
            color: PdfColor.fromHex('0B607E'),
          ),
          padding: const pw.EdgeInsets.all(20),
          alignment: pw.Alignment.centerLeft,
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _logo == null
                  ? pw.PdfLogo()
                  : pw.SvgImage(svg: _logo!, height: 30),
              pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  children: [
                    pw.Text(
                      dateOrder ?? '',
                      style: const pw.TextStyle(
                        fontSize: 12,
                        color: PdfColors.white,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Order ID : ${widget.idOrder}',
                      style: const pw.TextStyle(
                        fontSize: 12,
                        color: PdfColors.white,
                      ),
                    ),
                  ])
            ],
          ),
        ),
        if (context.pageNumber > 1) pw.SizedBox(height: 20)
      ],
    );
  }

  pw.Widget _contentHeader(pw.Context context) {
    return pw.Padding(
      padding: pw.EdgeInsets.only(top: 20),
      child: pw.Column(children: [
        pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Text('Invoice To : '),
          pw.SizedBox(width: 8),
          pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            pw.Text(
              recipient ?? '',
            ),
            pw.SizedBox(width: 4),
            pw.Text(address ?? ''),
            pw.SizedBox(width: 4),
            pw.Text(phone ?? '')
          ]),
        ]),
      ]),
    );
  }

  pw.Widget _contentTable(pw.Context context) {
    final productItem = products
        .map<Product>((e) => Product(e['productId'], e['productName'],
            e['price'], e['subPrice'], e['qty'], e['weight'], e['subWeight']))
        .toList();

    const tableHeaders = [
      'ProductId',
      'Product Name',
      'Price',
      'Weight',
      'Qty',
      'SubPrice',
      'SubWeight',
    ];

    return pw.TableHelper.fromTextArray(
      border: null,
      cellAlignment: pw.Alignment.centerLeft,
      headerDecoration: pw.BoxDecoration(
        color: PdfColors.grey200,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2)),
        //color: baseColor,
      ),
      headerHeight: 25,
      cellHeight: 40,
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.center,
        3: pw.Alignment.center,
        4: pw.Alignment.center,
        5: pw.Alignment.centerRight,
        6: pw.Alignment.centerRight,
      },
      columnWidths: {
        0: pw.FlexColumnWidth(3),
        1: pw.FlexColumnWidth(3),
        2: pw.FlexColumnWidth(2),
        3: pw.FlexColumnWidth(2),
        4: pw.FlexColumnWidth(1),
        5: pw.FlexColumnWidth(2),
        6: pw.FlexColumnWidth(2),

      },
      headerStyle: pw.TextStyle(
        //color: _baseTextColor,
        fontSize: 10,
        fontWeight: pw.FontWeight.bold,
      ),
      cellStyle: const pw.TextStyle(
        //color: _darkColor,
        fontSize: 10,
      ),
      rowDecoration: pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(
            //color: accentColor,
            width: .5,
          ),
        ),
      ),
      headers: List<String>.generate(
        tableHeaders.length,
        (col) => tableHeaders[col],
      ),
      data: List<List<String>>.generate(
        productItem.length,
        (row) => List<String>.generate(
          tableHeaders.length,
          (col) => productItem[row].getIndex(col),
        ),
      ),
    );
  }

  pw.Widget _contentFooter(pw.Context context) {
    return pw.Row(mainAxisAlignment: pw.MainAxisAlignment.end, children: [
      pw.Expanded(flex: 2, child: pw.Container()),
      pw.Expanded(
        flex: 2,
        child: pw.Column(children: [
          pw.Container(
            child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Total Price', style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold
                  ),),
                  pw.Text('Rp ${totalPrice.toString()}',style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold
                  ),),
                ]),
          ),
          pw.SizedBox(height: 4),
          pw.Container(
            child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Total Weight', style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold
                  ),),
                  pw.Text('${totalWeight.toString()} gr/ml',style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold
                  ),),
                ]),
          ),
        ]),
      ),
    ]);
  }

  pw.Widget _builtFooter(pw.Context context) {
    return pw.Center(
        child: pw.Text('@Suryamart Universitas Muhammadiyah Sidoarjo'));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.black),
          elevation: 0,
          title: Text(
            'Detail Order',
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500, color: Colors.black, fontSize: 16),
          ),
        ),
        body: SingleChildScrollView(
          child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('orders')
                .doc(widget.idOrder)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.connectionState == ConnectionState.active) {
                var x = snapshot.data;

                List z = x?['productItem'];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                          border: Border(
                            top: BorderSide(width: 5, color: Color(0xff0B607E)),
                          ),
                          color: Colors.white),
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 20, right: 20, bottom: 20, top: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.location_on_outlined),
                                Text(
                                  'Shipping Address',
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              x?['shippingAddress'],
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w300),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${x?['phone']}',
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w300),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: z.length,
                              itemBuilder: (context, index) {
                                var y = z[index];
                                return Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 60,
                                          height: 60,
                                          decoration: BoxDecoration(
                                              //color: Colors.grey.shade200,
                                              border: Border.all(
                                                  width: 0.5,
                                                  color: Colors.grey),
                                              borderRadius:
                                                  BorderRadius.circular(8)),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: y['picture'] == null
                                                ? const Icon(Icons
                                                    .image_not_supported_outlined)
                                                : Image.network(y['picture']),
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 8,
                                        ),
                                        Expanded(
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '${y['productName']}',
                                                  maxLines: 1,
                                                  overflow: TextOverflow.clip,
                                                  style: GoogleFonts.poppins(
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                                Text(
                                                  'Rp ${y['price']} x${y['qty']}',
                                                  style: GoogleFonts.poppins(
                                                      fontWeight:
                                                          FontWeight.w300),
                                                ),
                                              ]),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                            const Divider(),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 16, right: 16, bottom: 12),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Total Belanja',
                                    style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w300),
                                  ),
                                  Text(
                                    'Rp ${x?['totalPrice'].toString()}',
                                    style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w300),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Container(
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.credit_card_rounded),
                                const SizedBox(
                                  width: 4,
                                ),
                                Text(
                                  'Payment Method',
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            Expanded(
                                child: Text(
                              x?['paymentMethod'],
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w300,
                              ),
                              textAlign: TextAlign.end,
                            )),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    x!['statusOrder'] == 'SHIPPED'
                        ? Container(
                            color: Colors.white,
                            child: TextButton(

                              onPressed: () {
                                _createInvoice();
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Download Invoice',
                                      style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w500),
                                    ),
                                    const Icon(
                                      Icons.file_download,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        : Container(),
                    x['isReviewed']
                        ? Container(
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Theme(
                                data: ThemeData()
                                    .copyWith(dividerColor: Colors.transparent),
                                child: ExpansionTile(
                                  iconColor: Colors.black,
                                  expandedAlignment: Alignment.topLeft,
                                  title: Text(
                                    'Review',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                    ),
                                  ),
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 16, right: 16, bottom: 16),
                                      child: StreamBuilder(
                                        stream: FirebaseFirestore.instance
                                            .collection('reviews')
                                            .where('idOrder', isEqualTo: x.id)
                                            .snapshots(),
                                        builder: (context, snapshot) {
                                          var x = snapshot.data?.docs.first;
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return const Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            );
                                          } else if (snapshot.connectionState ==
                                              ConnectionState.active) {
                                            if (snapshot
                                                .data!.docs.isNotEmpty) {
                                              return Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  RatingBar.builder(
                                                    ignoreGestures: true,
                                                    initialRating: x!['rate'],
                                                    direction: Axis.horizontal,
                                                    allowHalfRating: true,
                                                    itemCount: 5,
                                                    itemSize: 25,
                                                    itemBuilder: (context, _) =>
                                                        const Icon(
                                                      Icons.star,
                                                      color: Colors.amber,
                                                    ),
                                                    onRatingUpdate:
                                                        (double value) {
                                                      null;
                                                    },
                                                  ),
                                                  const SizedBox(
                                                    height: 4,
                                                  ),
                                                  Text(
                                                    x.data()['review'],
                                                    style: GoogleFonts.poppins(
                                                        fontWeight:
                                                            FontWeight.w300),
                                                    textAlign:
                                                        TextAlign.justify,
                                                  ),
                                                ],
                                              );
                                            } else {
                                              return const Text(
                                                  'review kosong');
                                            }
                                          } else {
                                            return const Text(
                                                'eror ');
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        : Container(),
                  ],
                );
              } else {
                return const Text('eror');
              }
            },
          ),
        ),
        bottomNavigationBar: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('orders')
              .doc(widget.idOrder)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.connectionState == ConnectionState.active) {
              if (snapshot.data!['statusOrder'] == 'SUCCEED') {
                if (snapshot.data!['isReviewed'] == true) {
                  return const BottomAppBar(child: null);
                } else {
                  return BottomAppBar(
                      color: Colors.orangeAccent,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          'No Review',
                          style: GoogleFonts.poppins(
                              color: Colors.grey.shade800,
                              fontSize: 15,
                              fontWeight: FontWeight.w500),
                          textAlign: TextAlign.center,
                        ),
                      ));
                }
              } else {
                return const BottomAppBar(
                  child: null,
                );
              }
            } else {
              return const Text('eror');
            }
          },
        ),
      ),
    );
  }
}

class Product {
  const Product(
    this.productId,
    this.productName,
    this.price,
    this.subTotal,
    this.qty,
    this.weight,
    this.subWeight,
  );

  final String productId;
  final String productName;
  final int price;
  final int subTotal;
  final int qty;
  final int weight;
  final int subWeight;

  String getIndex(int index) {
    switch (index) {
      case 0:
        return productId;
      case 1:
        return productName;
      case 2:
        return price.toString();
      case 3:
        return weight.toString();
      case 4:
        return qty.toString();
      case 5:
        return subTotal.toString();
      case 6:
        return subWeight.toString();
    }
    return '';
  }
}
