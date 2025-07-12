import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:test/screens/user_home.dart';
import '../theme.dart';
import '../widgets/image_base.dart';
import 'vendor_details_screen.dart';
import '../config.dart';

class OrdersScreen extends StatefulWidget {
  final String userId;

  const OrdersScreen({required this.userId, Key? key}) : super(key: key);

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final Future<List<Mission>> _missionsFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _missionsFuture = _fetchMissions();
  }

  Future<List<Mission>> _fetchMissions() async {
    final response = await http.get(Uri.parse(
      '${AppConfig.baseUrl}:7127/api/Mission/Filter?userId=${widget.userId}',
    ));

    if (response.statusCode == 200) {
      return (json.decode(response.body) as List)
          .map((json) => Mission.fromJson(json))
          .toList();
    }
    if (response.statusCode == 404) return [];
    throw Exception('Failed to load missions: ${response.statusCode}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        title: Text(
          'User Missions',
          style: TextStyle(color: AppColors.primaryColor),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.backgroundColor,
          unselectedLabelColor: AppColors.textPrimaryColor,
          indicator: BoxDecoration(
            color:
            AppColors.primaryColor, // Background color of the selected tab
            borderRadius: BorderRadius.circular(
                2), // Optional: Add rounded corners to the indicator
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          tabs: const [
            Tab(text: 'All Missions'),
            Tab(text: 'Scheduled Missions'),
          ],
        ),
      ),
      body: FutureBuilder<List<Mission>>(
        future: _missionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final missions = snapshot.data ?? [];
          if (missions.isEmpty) {
            return const Center(child: Text('No missions yet'));
          }

          final scheduled =
          missions.where((m) => m.state == MissionState.Scheduled).toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _MissionList(missions: missions, userId: widget.userId),
              _MissionList(missions: scheduled, userId: widget.userId),
            ],
          );
        },
      ),
    );
  }
}

class _MissionList extends StatelessWidget {
  final List<Mission> missions;
  final String userId;

  const _MissionList({required this.missions, required this.userId});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: missions.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) => MissionCard(
        mission: missions[index],
        userId: userId,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VendorOffersScreen(
              missionId: missions[index].id,
              userId: userId,
            ),
          ),
        ),
      ),
    );
  }
}

class MissionCard extends StatelessWidget {
  final Mission mission;
  final String userId;
  final VoidCallback onTap;

  const MissionCard({
    required this.mission,
    required this.userId,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        onTap: onTap,
        leading: _buildMissionImage(),
        title: Text(
          mission.name,
          style: TextStyle(
              color: AppColors.primaryColor, fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Location: ${mission.location}'),
        trailing: Container(
          decoration: BoxDecoration(
            color: Colors.transparent, // Background color of the pill
            borderRadius: BorderRadius.circular(20), // Rounded corners
            border: Border.all(
              color: AppColors.primaryColor, // Outline color
              width: 2.0, // Border width
            ),
          ),
          padding: EdgeInsets.symmetric(
              horizontal: 12, vertical: 6), // Padding inside the pill
          child: Text(
            mission.state.name,
            style: TextStyle(
              color: AppColors.primaryColor, // Text color
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMissionImage() {
    return mission.image != null
        ? Image.network(mission.image!, width: 50, height: 50)
        : const Icon(
      Icons.work,
      color: AppColors.primaryColor,
    );
  }
}

class VendorOffersScreen extends StatefulWidget {
  final String missionId;
  final String userId;

  const VendorOffersScreen({
    required this.missionId,
    required this.userId,
    Key? key,
  }) : super(key: key);

  @override
  State<VendorOffersScreen> createState() => _VendorOffersScreenState();
}

class _VendorOffersScreenState extends State<VendorOffersScreen> {
  late Future<List<VendorOffer>> _offersFuture;
  final Set<String> _processingOffers = {};

  @override
  void initState() {
    super.initState();
    _offersFuture = _fetchOffers();
  }

  Future<List<VendorOffer>> _fetchOffers() async {
    try {
      final response = await http.get(Uri.parse(
        '${AppConfig.baseUrl}:7127/api/VendorOffer/Filter?missionId=${widget.missionId}',
      ));

      if (response.statusCode != 200) return [];

      final offers = await _processOfferData(json.decode(response.body));
      return offers;
    } catch (e) {
      print('Error fetching offers: $e');
      return [];
    }
  }

  Future<List<VendorOffer>> _processOfferData(List<dynamic> data) async {
    final List<VendorOffer> offers = [];

    for (final item in data) {
      try {
        var offer = VendorOffer.fromJson(item);
        offer = await _enhanceOfferWithProfileData(offer);
        offers.add(offer);
      } catch (e) {
        print('Error processing offer: $e');
      }
    }
    return offers;
  }

  Future<VendorOffer> _enhanceOfferWithProfileData(VendorOffer offer) async {
    try {
      final profileResponse = await http.get(Uri.parse(
        '${AppConfig.baseUrl}:7127/api/VenderProfile/${offer.venderProfileId}',
      ));

      if (profileResponse.statusCode != 200) return offer;

      final profile = json.decode(profileResponse.body);
      final userId = profile['userId']?.toString();
      if (userId == null) return offer;

      final userResponse = await http
          .get(Uri.parse('${AppConfig.baseUrl}:7127/api/User/$userId'));

      if (userResponse.statusCode != 200) return offer;

      final user = json.decode(userResponse.body);
      return offer.copyWith(
        vendorName: user['userName']?.toString() ?? 'Unknown Vendor',
        vendorEmail: user['email']?.toString() ?? 'No email',
        vendorImage: user['image']?.toString(),
        bio: profile['bio']?.toString() ?? 'No bio',
        experience: (profile['experience'] as num?)?.toInt() ?? 0,
        age: (user['age'] as num?)?.toInt() ?? 0,
        phoneNumber: user['phone']?.toString() ?? 'No phone',
        location: user['location']?.toString() ?? 'Unknown',
        gender: user['gender']?.toString() ?? 'Not specified',
        userAddress: user['userAddress']?.toString() ?? 'No address',
      );
    } catch (e) {
      print('Error enhancing offer: $e');
      return offer;
    }
  }

  Future<void> _acceptOffer(String offerId) async {
    setState(() => _processingOffers.add(offerId));

    try {
      final response = await http.put(
        Uri.parse(
            '${AppConfig.baseUrl}:7127/api/VendorOffer/ChangeStateToAccepted/$offerId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'state': true}),
      );

      if (response.statusCode == 204) {
        setState(() => _offersFuture = _fetchOffers());
        _showPopup('Success', 'Offer accepted successfully');
        _showDialog('Offer Accepted', 'The offer has been accepted successfully.');
      } else {
        _showSnackBar('Failed to accept offer: ${response.body}');
      }
    } catch (e) {
      _showSnackBar('Error accepting offer: $e');
    } finally {
      setState(() => _processingOffers.remove(offerId));
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
  void _showPopup(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        title: const Text(
          'Vendor Offers',
          style: TextStyle(color: AppColors.primaryColor),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryColor),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: FutureBuilder<List<VendorOffer>>(
        future: _offersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final offers = snapshot.data ?? [];
          if (offers.isEmpty) {
            return const Center(child: Text('No offers available'));
          }

          final hasAcceptedOffer = offers.any((o) => o.state);

          if (hasAcceptedOffer) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showDialog('Offer Already Accepted', 'An offer has already been accepted.');
            });
          }

          return ListView.builder(
            itemCount: offers.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) => OfferCard(
              offer: offers[index],
              userId: widget.userId,
              onAccept: () => _acceptOffer(offers[index].id),
              isProcessing: _processingOffers.contains(offers[index].id),
              hasAcceptedOffer: hasAcceptedOffer,
            ),
          );
        },
      ),
    );
  }
}

class OfferCard extends StatelessWidget {
  final VendorOffer offer;
  final String userId;
  final VoidCallback onAccept;
  final bool isProcessing;
  final bool hasAcceptedOffer;

  const OfferCard({
    required this.offer,
    required this.userId,
    required this.onAccept,
    required this.isProcessing,
    required this.hasAcceptedOffer,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isAccepted = offer.state;
    final isDisabled = isAccepted || hasAcceptedOffer || isProcessing;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: () => _showVendorDetails(context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildVendorHeader(),
              if (offer.note != null) _buildNoteSection(),
              const SizedBox(height: 16),
              _buildAcceptButton(context,isDisabled, isAccepted),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVendorHeader() {
    return Row(
      children: [
        CircleAvatar(
          radius: 25,
          backgroundImage: offer.vendorImage != null &&
              !offer.vendorImage!.startsWith('data:image')
              ? NetworkImage(offer.vendorImage!)
              : null,
          child: offer.vendorImage != null &&
              offer.vendorImage!.startsWith('data:image')
              ? ImageFromBase64(base64String: offer.vendorImage!.split(',')[1])
              : offer.vendorImage == null
              ? const Icon(Icons.person)
              : null,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                offer.vendorName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(offer.vendorEmail),
            ],
          ),
        ),
        Text('LYD ${offer.price.toStringAsFixed(2)}'),
      ],
    );
  }

  Widget _buildNoteSection() {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text('Note: ${offer.note}'),
    );
  }

  Widget _buildAcceptButton(BuildContext context,bool isDisabled, bool isAccepted) {
    return SizedBox(
      width: double.infinity,
      child:ElevatedButton(
        onPressed: isDisabled
            ? null
            : () {
          onAccept();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => UserHomeScreen(userId: userId),
            )
          );
        },
        child: isProcessing
            ? const CircularProgressIndicator()
            : Text(isAccepted ? 'Accepted' : 'Accept Offer'),
      ),
    );
  }

  void _showVendorDetails(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VendorDetailsScreen(
          userId: userId,
          vendorId: offer.venderProfileId,
          vendorName: offer.vendorName,
          vendorEmail: offer.vendorEmail,
          vendorImage: offer.vendorImage,
          bio: offer.bio,
          experience: offer.experience,
          age: offer.age,
          phoneNumber: offer.phoneNumber,
          location: offer.location,
          gender: offer.gender,
          userAddress: offer.userAddress,
        ),
      ),
    );
  }
}

class Mission {
  final String id;
  final String name;
  final MissionState state;
  final DateTime day;
  final String location;
  final String? image;

  Mission({
    required this.id,
    required this.name,
    required this.state,
    required this.day,
    required this.location,
    this.image,
  });

  factory Mission.fromJson(Map<String, dynamic> json) => Mission(
    id: json['id'],
    name: json['name'],
    state: MissionState.values[json['state']],
    day: DateTime.parse(json['day']),
    location: json['location'],
    image: json['image'],
  );
}

enum MissionState { Pending, Scheduled, Completed, Cancelled }

class VendorOffer {
  final String id;
  final String venderProfileId;
  final String missionId;
  final String? note;
  final double price;
  final bool state;
  final String vendorName;
  final String vendorEmail;
  final String? vendorImage;
  final String bio;
  final int experience;
  final int age;
  final String phoneNumber;
  final String location;
  final String gender;
  final String userAddress;

  VendorOffer({
    required this.id,
    required this.venderProfileId,
    required this.missionId,
    this.note,
    required this.price,
    required this.state,
    this.vendorName = 'Loading...',
    this.vendorEmail = 'Loading...',
    this.vendorImage,
    this.bio = '',
    this.experience = 0,
    this.age = 0,
    this.phoneNumber = '',
    this.location = '',
    this.gender = '',
    this.userAddress = '',
  });

  factory VendorOffer.fromJson(Map<String, dynamic> json) => VendorOffer(
    id: json['Id'] ?? '',
    venderProfileId: json['VenderProfileId'] ?? '',
    missionId: json['MissionId'] ?? '',
    note: json['Note'],
    price: (json['Price'] as num?)?.toDouble() ?? 0.0,
    state: json['State'] ?? false,
  );

  VendorOffer copyWith({
    String? vendorName,
    String? vendorEmail,
    String? vendorImage,
    String? bio,
    int? experience,
    int? age,
    String? phoneNumber,
    String? location,
    String? gender,
    String? userAddress,
  }) {
    return VendorOffer(
      id: id,
      venderProfileId: venderProfileId,
      missionId: missionId,
      note: note,
      price: price,
      state: state,
      vendorName: vendorName ?? this.vendorName,
      vendorEmail: vendorEmail ?? this.vendorEmail,
      vendorImage: vendorImage ?? this.vendorImage,
      bio: bio ?? this.bio,
      experience: experience ?? this.experience,
      age: age ?? this.age,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      location: location ?? this.location,
      gender: gender ?? this.gender,
      userAddress: userAddress ?? this.userAddress,
    );
  }
}