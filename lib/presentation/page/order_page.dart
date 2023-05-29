import 'package:admin_surya_mart_v1/presentation/page/detail_order.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({Key? key}) : super(key: key);

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  var defaultTab = ['ALL'];

  var listHeaderTab = ['PACKED', 'SHIPPED', 'SUCCEED', 'CANCELLED'];

  @override
  Widget build(BuildContext context) {
    var listTab = defaultTab + listHeaderTab;

    var viewTabDefault = <Widget>[
      StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .orderBy('dateOrder', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.data!.docs.isNotEmpty) {
              return ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  var x = snapshot.data!.docs[index];

                  Timestamp t = x.data()['dateOrder'];
                  DateTime d = t.toDate();

                  List z = x.data()['productItem'];

                  Map first = z.first;

                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          //Text(x.id),
                          InkWell(
                            onTap: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return DetailOrder(
                                    idUser: x.data()['userId'],
                                    listCart: x.data()['productItem'],
                                    status: x.data()['statusOrder'],
                                    idOrder: x.id,
                                    isReviewed: x.data()['isReviewed']);
                              }));
                            },
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      d.toString(),
                                      style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w300),
                                    ),
                                    Text(
                                      x.data()['statusOrder'],
                                      style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w500,
                                          color:  const Color(0xff0B607E),),
                                    ),
                                  ],
                                ),
                                const Divider(),
                                Row(
                                  children: [
                                    Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                              width: 0.5, color: Colors.grey)),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: first['picture'] == null
                                            ? const Icon(Icons
                                                .image_not_supported_outlined)
                                            : Image.network(first['picture']),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${first['productName']}',
                                            style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.w300),
                                            overflow: TextOverflow.clip,
                                            maxLines: 1,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'Rp ${first['price']} ',
                                                style: GoogleFonts.poppins(
                                                    fontWeight: FontWeight.w300),
                                              ),
                                              Text(
                                                'x${first['qty']}',
                                                style: GoogleFonts.poppins(
                                                    fontWeight: FontWeight.w300),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                z.isEmpty
                                    ? Column(children: [
                                        const Divider(),
                                        Center(
                                          child: Text(
                                            'Tampilkan produk lainnya',
                                            style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.w300),
                                          ),
                                        ),
                                      ])
                                    : Container(),
                                const Divider(),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${z.length.toString()} produk',
                                      style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w300),
                                    ),
                                    Row(children: [
                                      Text(
                                        'Total Belanja ',
                                        style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w300),
                                      ),
                                      Text(
                                        'Rp ${x.data()['totalPrice'].toString()}',
                                        style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w300,
                                            color: Colors.redAccent),
                                      )
                                    ]),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          if (x.data()['statusOrder'] == 'SUCCEED')
                            x.data()['isReviewed'] == false
                                ? Column(
                                    children: [
                                      const Divider(),
                                      Text(
                                        'Belum diulas',
                                        style: GoogleFonts.poppins(
                                            color: Colors.grey.shade800,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      const Divider(),
                                      Text(
                                        'Sudah diulas',
                                        style: GoogleFonts.poppins(
                                            color: Colors.yellow.shade800,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  )
                          else if (x.data()['statusOrder'] == 'PACKED')
                            InkWell(
                              onTap: () {
                                FirebaseFirestore.instance
                                    .collection('orders')
                                    .doc(x.id)
                                    .update({'statusOrder': 'SHIPPED'});
                              },
                              child: x.data()['statusOrder'] == 'PACKED'
                                  ? Padding(
                                      padding: const EdgeInsets.only(top: 14),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color:  const Color(0xff0B607E),
                                        ),
                                        height: 50,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Kirimkan Pesanan',
                                              style: GoogleFonts.poppins(
                                                  color: Colors.white,
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : null,
                            )
                        ],
                      ),
                    ),
                  );
                },
              );
            } else {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: Text(
                    'Belum ada riwayat pembelian',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }
          } else {
            return const Text('eror');
          }
        },
      )
    ];

    var viewTabCategory = listHeaderTab.map<Widget>((e) {
      return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('statusOrder', isEqualTo: e)
            .orderBy('dateOrder', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.data!.docs.isNotEmpty) {
              return ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  var x = snapshot.data!.docs[index];

                  Timestamp t = x.data()['dateOrder'];
                  DateTime d = t.toDate();

                  List z = x.data()['productItem'];
                  Map first = z.first;

                  //print('nilai id untuk buka detail order ${x.id}');

                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          //Text(x.id),
                          InkWell(
                            onTap: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return DetailOrder(
                                    idUser: x.data()['userId'],
                                    listCart: x.data()['productItem'],
                                    status: x.data()['statusOrder'],
                                    idOrder: x.id,
                                    isReviewed: x.data()['isReviewed']);
                              }));
                            },
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      d.toString(),
                                      style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w300),
                                    ),
                                    Text(
                                      x.data()['statusOrder'],
                                      style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w500,
                                          color:  const Color(0xff0B607E),),
                                    ),
                                  ],
                                ),
                                const Divider(),
                                Row(
                                  children: [
                                    Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                              width: 0.5, color: Colors.grey)),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: first['picture'] == null
                                            ? const Icon(Icons
                                                .image_not_supported_outlined)
                                            : Image.network(first['picture']),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${first['productName']}',
                                            style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.w300),
                                            maxLines: 1,
                                            overflow: TextOverflow.clip,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'Rp ${first['price']} ',
                                                style: GoogleFonts.poppins(
                                                    fontWeight: FontWeight.w300),
                                              ),
                                              Text(
                                                'x${first['qty']}',
                                                style: GoogleFonts.poppins(
                                                    fontWeight: FontWeight.w300),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                z.isEmpty
                                    ? Column(children: [
                                        const Divider(),
                                        Center(
                                          child: Text(
                                            'Tampilkan produk lainnya',
                                            style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.w300),
                                          ),
                                        ),
                                      ])
                                    : Container(),
                                const Divider(),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${z.length.toString()} produk',
                                      style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w300),
                                    ),
                                    Row(children: [
                                      Text(
                                        'Total Belanja ',
                                        style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w300),
                                      ),
                                      Text(
                                        'Rp ${x.data()['totalPrice'].toString()}',
                                        style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w300,
                                            color: Colors.redAccent),
                                      )
                                    ]),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          if (x.data()['statusOrder'] == 'SUCCEED')
                            x.data()['isReviewed'] == false
                                ? Column(
                                    children: [
                                      const Divider(),
                                      Text(
                                        'Belum diulas',
                                        style: GoogleFonts.poppins(
                                            color: Colors.grey.shade800,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      const Divider(),
                                      Text(
                                        'Sudah diulas',
                                        style: GoogleFonts.poppins(
                                            color: Colors.yellow.shade800,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  )
                          else if (x.data()['statusOrder'] == 'PACKED')
                            InkWell(
                              onTap: () {
                                FirebaseFirestore.instance
                                    .collection('orders')
                                    .doc(x.id)
                                    .update({'statusOrder': 'SHIPPED'});
                              },
                              child: x.data()['statusOrder'] == 'PACKED'
                                  ? Padding(
                                      padding: const EdgeInsets.only(top: 14),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color:  const Color(0xff0B607E),
                                        ),
                                        height: 50,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Kirimkan Pesanan',
                                              style: GoogleFonts.poppins(
                                                  color: Colors.white,
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : null,
                            )
                        ],
                      ),
                    ),
                  );
                },
              );
            } else {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: Text(
                    'Belum ada riwayat pembelian',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }
          } else {
            return const Text('eror');
          }
        },
      );
    }).toList();

    var viewTabAll = viewTabDefault + viewTabCategory;

    return SafeArea(
      child: DefaultTabController(
        length: listTab.length,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            iconTheme: const IconThemeData(color: Colors.black),
            elevation: 0,
            title: Text(
              'Manage Orders',
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                  fontSize: 16),
            ),
            notificationPredicate: (ScrollNotification notification) {
              return notification.depth == 1;
            },
            scrolledUnderElevation: 2.0,
            bottom: TabBar(
              indicatorColor:  const Color(0xff0B607E),
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              isScrollable: true,
              tabs: listTab
                  .map((e) => Tab(
                        text: e,
                      ))
                  .toList(),
            ),
          ),
          body: TabBarView(children: viewTabAll),
        ),
      ),
    );
  }
}
