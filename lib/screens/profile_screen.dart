import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flag/flag.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'dart:io';

import '../theme.dart';
import '../widgets/image_base.dart';
import 'login_screen.dart';
import '../config.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;

  const ProfileScreen({required this.userId, super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _ageController;
  late final TextEditingController _addressController;
  late final TextEditingController _locationController;
  late final TextEditingController _passwordController;

  // State variables
  String selectedCountryCode = '+218'; // Default country code
  String selectedCountry = 'LY'; // Default country
  String selectedGender = 'Male'; // Default gender
  bool isLoading = true;
  File? _selectedImage;
  String? _base64Image; // To store the Base64 encoded image string
  Location _location = Location();

  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _ageController = TextEditingController();
    _addressController = TextEditingController();
    _locationController = TextEditingController();
    _passwordController = TextEditingController();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final url = '${AppConfig.baseUrl}:7127/api/User/${widget.userId}';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final fetchedData = json.decode(response.body);
        setState(() {
          userData = fetchedData;
          _nameController.text = userData!['userName'] ?? '';
          _emailController.text = userData!['email'] ?? '';
          _phoneController.text =
              userData!['phone']?.replaceFirst(selectedCountryCode, '') ?? '';
          _ageController.text = userData!['age']?.toString() ?? '';
          _addressController.text = userData!['userAddress'] ?? '';
          _locationController.text = userData!['location'] ?? '';
          selectedGender = userData!['gender'] == 1 ? 'Male' : 'Female';
          _base64Image = userData!['image'];
          isLoading = false;
        });
        print('User data fetched successfully: $userData');
      } else {
        throw Exception('Failed to fetch user data');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching user data: $error');
    }
  }

  Future<void> _getCurrentLocation() async {
    final LocationData locationData = await _location.getLocation();
    _locationController.text =
        "${locationData.latitude},${locationData.longitude}";
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Location updated!"),
      ),
    );
    print('Current location: ${_locationController.text}');
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
        _base64Image = base64Encode(_selectedImage!.readAsBytesSync());
      });
      print('Image selected: $_selectedImage');
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
      _base64Image = null;
    });
    print('Image removed');
  }

  void _showImageOptions() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Profile Picture'),
          content: const Text('Choose an option:'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _pickImage();
              },
              child: const Text('Change'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _removeImage();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _showChangePasswordDialog() {
    final _newPasswordController = TextEditingController();
    final _confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible:
          false, // Prevents dismissing the dialog by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Change Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'New Password'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration:
                    const InputDecoration(labelText: 'Confirm Password'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_newPasswordController.text ==
                    _confirmPasswordController.text) {
                  _passwordController.text = _newPasswordController.text;
                  Navigator.of(context).pop();
                  print('Password changed successfully');
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Passwords do not match')),
                  );
                  print('Passwords do not match');
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate() && userData != null) {
      final updatedData = Map<String, dynamic>.from(userData!);
      updatedData['userName'] = _nameController.text;
      updatedData['email'] = _emailController.text;
      updatedData['phone'] = '$selectedCountryCode${_phoneController.text}';
      updatedData['age'] = int.tryParse(_ageController.text) ?? 0;
      updatedData['userAddress'] = _addressController.text;
      updatedData['location'] = _locationController.text;
      updatedData['gender'] = selectedGender == 'Male' ? 1 : 0;
      updatedData['type'] = 0;

      if (_passwordController.text.isNotEmpty) {
        updatedData['password'] = _passwordController.text;
      } else {
        updatedData['password'] = userData!['password'];
      }

      if (_selectedImage != null) {
        final bytes = await _selectedImage!.readAsBytes();
        updatedData['image'] = base64Encode(bytes);
      } else {
        updatedData['image'] = userData!['image'];
      }

      print('Updated user data: $updatedData');
      await _updateUserProfile(updatedData);
    }
  }

  Future<void> _updateUserProfile(Map<String, dynamic> data) async {
    final url = '${AppConfig.baseUrl}:7127/api/User/${widget.userId}';
    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
        print('Profile updated successfully');
      } else {
        print('Failed to update profile: ${response.body}');
        throw Exception('Failed to update profile');
      }
    } catch (error) {
      print('Error updating profile: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update profile')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
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
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.primaryColor),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => LogInScreen(),
                ),
              );
            },
            tooltip: "Log Out",
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: Container(
            color: Colors.grey[300],
            height: 1.5,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_selectedImage != null)
                  Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: FileImage(_selectedImage!),
                    ),
                  )
                else if (_base64Image != null)
                  Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: _base64Image != null
                          ? MemoryImage(base64Decode(_base64Image!))
                          : null,
                      child: _base64Image == null
                          ? Icon(Icons.person, size: 50)
                          : null,
                    ),
                  )
                else if (userData != null && userData!['image'] != null)
                  Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: NetworkImage(userData!['image']),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  )
                else
                  const Center(
                    child: CircleAvatar(
                      radius: 50,
                      child: Icon(Icons.person),
                    ),
                  ),
                const SizedBox(height: 8),
                Center(
                  child: ElevatedButton(
                    onPressed: _showImageOptions,
                    child: const Text('Edit Profile Picture'),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    _nameController.text,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email cannot be empty';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Flag.fromString(
                      selectedCountry,
                      height: 32,
                      width: 48,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      selectedCountryCode,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(labelText: 'Phone'),
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Phone cannot be empty';
                          }
                          if (value.length != 9) {
                            return 'Phone number must be 9 digits';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _ageController,
                  decoration: const InputDecoration(labelText: 'Age'),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Age cannot be empty';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedGender,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedGender = newValue!;
                    });
                  },
                  items: <String>['Male', 'Female']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  decoration: const InputDecoration(labelText: 'Gender'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(labelText: 'Address'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Address cannot be empty';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _locationController,
                        decoration: InputDecoration(
                          labelText: 'Location',
                        ),
                        readOnly: true,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.my_location),
                      onPressed: _getCurrentLocation,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _saveProfile,
                    child: const Text('Save Changes'),
                  ),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: GestureDetector(
                    onTap: _showChangePasswordDialog,
                    child: const Text(
                      'Change Password',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    _addressController.dispose();
    _locationController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
