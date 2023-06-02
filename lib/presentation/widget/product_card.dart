import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    Key? key,
    required this.ds,
  }) : super(key: key);

  final QueryDocumentSnapshot<Object?>? ds;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(width: 0.5, color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              width: 80,
              height: 80,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(14), bottom: Radius.circular(14)),
                child: (ds!.data() as Map<String, dynamic>)["image"] == null
                    ? const Icon(Icons.image_not_supported_outlined)
                    : Image.network(
                        (ds?.data() as Map<String, dynamic>)["image"] ?? '',
                        fit: BoxFit.scaleDown,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Text('No Internet',style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w300,
                          fontSize: 8),),
                    );
                  },
                      ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${(ds?.data() as Map<String, dynamic>)["name"]}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                    ),
                    (ds?.data() as Map<String, dynamic>)["category"] == ''
                        ? const Text('Kategori : -')
                        : Text(
                            'Kategori : ${(ds?.data() as Map<String, dynamic>)["category"]}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w300),
                          ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Rp ${(ds?.data() as Map<String, dynamic>)["price"]}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              GoogleFonts.poppins(fontWeight: FontWeight.w300),
                        ),
                        Text(
                          'stok : ${(ds?.data() as Map<String, dynamic>)["stock"]}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              GoogleFonts.poppins(fontWeight: FontWeight.w300),
                        ),
                      ],
                    )
                  ]),
            ),
          ],
        ),
      ),
    );
  }
}
