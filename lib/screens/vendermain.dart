import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:test/theme.dart';
import 'VenderProfile.dart'; // Corrected import for VenderProfile
//import 'vendorOrders.dart'; // Corrected import for vendorOrders
import 'VenderComments.dart'; // Corrected import for VenderComments
import 'login_screen.dart'; // Corrected import for SignInScreen
import 'package:http/http.dart'
    as http; // Add HTTP package for network requests
import 'dart:convert'; // Add JSON package for decoding responses
//import 'MissionsScreen.dart'; // Corrected import for MissionsScreen
import 'VendorOrders.dart';
import '../config.dart';

class VendorMainScreen extends StatefulWidget {
  final String userId; // Accept userId as a parameter

  const VendorMainScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _VendorMainScreenState createState() => _VendorMainScreenState();
}

class _VendorMainScreenState extends State<VendorMainScreen> {
  int _selectedIndex = 0;
  String? _vendorId; // Store the vendorId
  String? _categoryId; // Store the categoryId

  // Global Key for managing Scaffold state across different screens
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Initialize the screens list with placeholders
  late List<Widget> _screens = [
    Center(
        child:
            CircularProgressIndicator()), // Placeholder for VenderProfile screen
    Center(
        child:
            CircularProgressIndicator()), // Placeholder for vendorOrders screen
    Center(
        child:
            CircularProgressIndicator()), // Placeholder for VenderComments screen
  ];

  @override
  void initState() {
    super.initState();
    _fetchVendorId();
  }

  Future<void> _fetchVendorId() async {
    final response = await http.get(
      Uri.parse(
          '${AppConfig.baseUrl}:7127/api/VenderProfile/filter?userId=${widget.userId}'),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      if (data.isNotEmpty) {
        setState(() {
          _vendorId = data[0]['id'];
          _fetchVendorProfile(_vendorId!);
        });
      } else {
        // Handle empty response
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No vendor profile found for this user ID')),
        );
      }
    } else {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch vendor ID')),
      );
    }
  }

  Future<void> _fetchVendorProfile(String vendorId) async {
    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}:7127/api/VenderProfile/$vendorId'),
    );
    print(jsonDecode(response.body));
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      setState(() {
        _categoryId = data['categoryId'];
        // Update the screens list with the actual screens
        _screens = [
          VendorProfile(
            userId: widget.userId,
            vendorId: _vendorId!,
          ),
          MissionsScreen(
            categoryId: _categoryId!,
            vendorId: _vendorId!,
          ),
          VendorCommentsScreen(
            vendorId: _vendorId!,
          ),
        ];
      });
    } else {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch vendor profile')),
      );
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _changeLocale() {
    // Implement any logic for changing locale here
  }

  List<String> _getTitles() {
    return [
      'Profile',
      'Orders',
      'Comments',
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // Set the scaffold key here
      appBar: AppBar(
        // title: Text(
        //   _getTitles()[_selectedIndex],
        //   style: const TextStyle(
        //     fontWeight: FontWeight.bold,
        //     color: Colors.white,
        //   ),
        // ),
        backgroundColor: AppColors.backgroundColor,
        flexibleSpace: Padding(
          padding: const EdgeInsets.only(top: 25),
          child: Center(
            child: SvgPicture.asset(
              'images/homie_new_logo.svg',
              height: 80,
            ),
          ),
        ),
        actions: [
          if (_selectedIndex == 0) ...[
            // Show logout only on profile screen
            IconButton(
              icon: const Icon(
                Icons.logout,
                color: AppColors.primaryColor,
              ),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LogInScreen(),
                  ),
                );
              },
              tooltip: 'Log Out', // Use hardcoded string for logout
            ),
            IconButton(
              icon: const Icon(
                Icons.language,
                color: AppColors.primaryColor,
              ),
              onPressed: _changeLocale,
            ),
          ],
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: Container(
            color: Colors.grey[300],
            height: 1.5,
          ),
        ),
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(0),
          topRight: Radius.circular(0),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          backgroundColor: Theme.of(context).primaryColor,
          selectedItemColor: AppColors.accentColor,
          unselectedItemColor: Colors.white,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.list),
              label: 'Orders',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.comment),
              label: 'Comments',
            ),
          ],
        ),
      ),
    );
  }
}
