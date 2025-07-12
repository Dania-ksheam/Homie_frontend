
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';


// class VendorOffersScreen extends StatelessWidget {
//   final String missionId;

//   const VendorOffersScreen({required this.missionId, Key? key}) : super(key: key);

//   Future<List<VendorOffer>> fetchVendorOffers() async {
//     final response = await http.get(Uri.parse('${AppConfig.baseUrl}:7127/api/VendorOffer?missionId=$missionId'));

//     if (response.statusCode == 200) {
//       final List<dynamic> data = json.decode(response.body);
//       return data.map((json) => VendorOffer.fromJson(json)).toList();
//     } else {
//       throw Exception('Failed to load offers');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Vendor Offers')),
//       body: FutureBuilder<List<VendorOffer>>(
//         future: fetchVendorOffers(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return const Center(child: Text('No offers available'));
//           }

//           return ListView.builder(
//             itemCount: snapshot.data!.length,
//             itemBuilder: (context, index) {
//               final offer = snapshot.data![index];
//               return ListTile(title: Text(offer.note), subtitle: Text('\$${offer.price}'));
//             },
//           );
//         },
//       ),
//     );
//   }
// }
// class VendorOffer {
//   final String id;
//   final String venderProfileId;
//   final String missionId;
//   final String note;
//   final double price;
//   final bool state;

//   VendorOffer({
//     required this.id,
//     required this.venderProfileId,
//     required this.missionId,
//     required this.note,
//     required this.price,
//     required this.state,
//   });

//   factory VendorOffer.fromJson(Map<String, dynamic> json) {
//     return VendorOffer(
//       id: json['id']?.toString() ?? '',
//       venderProfileId: json['venderProfileId']?.toString() ?? '',
//       missionId: json['missionId']?.toString() ?? '',
//       note: json['note'] ?? '',
//       price: (json['price'] is int) ? (json['price'] as int).toDouble() : (json['price'] as double? ?? 0.0),
//       state: json['state'] ?? false,
//     );
//   }
// }