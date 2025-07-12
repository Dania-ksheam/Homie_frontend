import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:flag/flag.dart';
import 'package:path/path.dart' as path;
import 'package:geolocator/geolocator.dart' as geo;
import 'package:location/location.dart' as loc;

import '../theme.dart';
import 'login_screen.dart';
import '../config.dart';

// Define the GenderType enum
enum GenderType { male, female }

class SignUpScreen extends StatefulWidget {
  final int userType; // 0 for Customer, 1 for Vendor
  const SignUpScreen({Key? key, required this.userType}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _ageController = TextEditingController();

  // For Vendor-specific fields
  final _bioController = TextEditingController();
  final _experienceController = TextEditingController();
  List<Map<String, dynamic>> _categories = []; // Categories fetched from API
  Map<String, dynamic>? _selectedCategory; // To store the selected category

  File? _avatarImage;
  String? _avatarFileName;
  String? _base64Image; // To store the Base64 encoded image string
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  int? _selectedAge;
  GenderType? _selectedGender;
  final List<String> _tripoliStreets = [
    "Martyrs' Square",
    "Al-Mansoura",
    "Gargaresh",
    "Hai Al-Andalus",
    "Ben Ashur",
    "Garden City",
    "Abu Salim",
    "Souk Al-Juma",
    "Janzour",
    "Al-Dahra Street",
    "Omar Al-Mukhtar Street",
    "Al-Jumhouria Street",
    "Al-Saraya Street",
    "Al-Naser Street",
    "Al-Sekka Street",
    "Al-Zawiya Street",
    "Al-Hani Street",
    "Al-Shat Road (Corniche Road)",
    "First of September Street",
    "Gurji Area",
    "Al-Hadba Area",
    "Al-Andalus Neighborhood",
    "Fashloom Area",
    "Sidi Khalifa Street",
    "Al-Mansoura Street",
    "Al-Sreem Street",
    "Al-Madina Al-Kadima (Old City)",
    "Souq Al-Jumaa Area",
    "Tajoura Area",
  ];

  // Location Service
  Location _location = Location();

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    geo.LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled, handle accordingly
      return;
    }

    // Check for location permissions
    permission = await geo.Geolocator.checkPermission();
    if (permission == geo.LocationPermission.denied) {
      permission = await geo.Geolocator.requestPermission();
      if (permission == geo.LocationPermission.denied) {
        // Permissions are denied, handle accordingly
        return;
      }
    }

    if (permission == geo.LocationPermission.deniedForever) {
      // Permissions are denied forever, handle accordingly
      return;
    }

    // Get the current location
    geo.Position position = await geo.Geolocator.getCurrentPosition(
      desiredAccuracy: geo.LocationAccuracy.high,
    );

    _locationController.text = "${position.latitude},${position.longitude}";
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Location updated!"),
      ),
    );
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _avatarImage =
            File(pickedFile.path); // Store the full path for file operations
        _avatarFileName =
            path.basename(pickedFile.path); // Extract and store the file name
        _base64Image = base64Encode(
            _avatarImage!.readAsBytesSync()); // Convert image to Base64 string
      });
    }
  }

  void _fetchCategories() async {
    try {
      final response =
          await http.get(Uri.parse('${AppConfig.baseUrl}:7127/api/Category'));
      print(response.statusCode); // Log the response status code
      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _categories = data.map((item) {
              return {
                'id': item['id'],
                'name': item['name'],
              };
            }).toList();
            if (_categories.isNotEmpty) {
              _selectedCategory =
                  _categories[0]; // Set the first category as the default
            }
          });
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to fetch categories")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error fetching categories: $e")),
        );
      }
    }
  }

  Future<void> submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      final Map<String, dynamic> userData = {
        'userName': _nameController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
        'confirmPassword': _confirmPasswordController.text,
        'userAddress': _addressController.text,
        'phone': _phoneController.text,
        'age':  _ageController,
        'gender': _selectedGender == GenderType.male ? 1 : 0,
        'type': widget.userType == 0 ? 0 : 1,
        'image': _base64Image, // Store the Base64 encoded image string
        'location': _locationController.text,
        'fileName': _avatarFileName, // Store only the file name
      };

      try {
        final response = await http.post(
          Uri.parse('${AppConfig.baseUrl}:7127/api/user'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode(userData),
        );

        if (response.statusCode == 201) {
          final newUser = jsonDecode(response.body);
          print("New user created with ID: ${newUser['id']}");

          if (widget.userType == 1) {
            // Fetch the user by email to get the user ID using the filter endpoint
            final userResponse = await http.get(Uri.parse(
                '${AppConfig.baseUrl}:7127/api/user/filter?email=${_emailController.text}'));

            if (userResponse.statusCode == 200) {
              final filteredUsers = jsonDecode(userResponse.body);
              if (filteredUsers.isNotEmpty) {
                final fetchedUser = filteredUsers[0];
                final userId = fetchedUser['id'];

                final Map<String, dynamic> vendorData = {
                  'userId': userId, // Use fetched user ID
                  'categoryId': _selectedCategory != null
                      ? _selectedCategory!['id']
                      : null,
                  'bio': _bioController.text,
                  'experience': int.tryParse(_experienceController.text),
                };

                final vendorResponse = await http.post(
                  Uri.parse('${AppConfig.baseUrl}:7127/api/VenderProfile'),
                  headers: {
                    'Content-Type': 'application/json',
                  },
                  body: jsonEncode(vendorData),
                );

                if (vendorResponse.statusCode == 201) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Account created successfully!")),
                  );
                  Navigator.pop(context);
                } else {
                  _showErrorDialog("Error",
                      "Vendor profile creation error: ${vendorResponse.body}");
                  print(
                      "Vendor profile creation error: ${vendorResponse.body}");
                }
              } else {
                _showErrorDialog("Error", "User not found by email");
                print("User not found by email: ${userResponse.body}");
              }
            } else {
              _showErrorDialog("Error",
                  "Error fetching user by email: ${userResponse.body}");
              print("Error fetching user by email: ${userResponse.body}");
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Account created successfully!")),
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LogInScreen()),
            );
          }
        } else {
          _showErrorDialog("Error", "User creation error: ${response.body}");
          print("User creation error: ${response.body}");
        }
      } catch (e) {
        _showErrorDialog("Error", "Network error: $e");
        print("Network error: $e");
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 30),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(8.0), // Add border radius
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back,
                              color: AppColors.primaryColor),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.037),
                Text(
                  "Sign up",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                Text(
                  widget.userType == 1
                      ? "As a service provider you can offer your services and get paid for them"
                      : "As a client you can request a service provider to help you",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textPrimaryColor,
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.07),
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 100,
                    backgroundImage:
                        _avatarImage != null ? FileImage(_avatarImage!) : null,
                    child: _avatarImage == null
                        ? Icon(Icons.camera_alt, size: 70)
                        : null,
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                _buildTextFormField(
                  controller: _nameController,
                  labelText: 'Name',
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Enter your name' : null,
                  maxLength: 30,
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                _buildEmailFormField(
                  controller: _emailController,
                  labelText: 'Email',
                  validator: (value) => value == null || !value.contains('@')
                      ? 'Enter a valid email'
                      : null,
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                _buildPasswordFormField(
                  controller: _passwordController,
                  labelText: 'Password',
                  obscureText: _obscurePassword,
                  onToggleVisibility: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                  validator: (value) => value == null ||
                          value.length < 6 ||
                          !RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{6,}$')
                              .hasMatch(value)
                      ? 'Password must be at least 6 characters, and contain both letters and numbers'
                      : null,
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                Text(
                  'Password must contain both letters and numbers.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textPrimaryColor,
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                _buildPasswordFormField(
                  controller: _confirmPasswordController,
                  labelText: 'Confirm Password',
                  obscureText: _obscureConfirmPassword,
                  onToggleVisibility: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                  validator: (value) => value != _passwordController.text
                      ? 'Passwords do not match'
                      : null,
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                _buildTextFormField(
                  controller: _ageController,
                  labelText: 'Age',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter your age';
                    }
                    final age = int.tryParse(value);
                    if (age == null || age < 16) {
                      return 'Age must be above 16';
                    }
                    return null;
                  },
                  maxLength: 3,
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                _buildGenderSelection(),
                SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                _buildPhoneNumberField(),
                SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                _buildDropdownButtonFormField(
                  value: _addressController.text.isEmpty
                      ? null
                      : _addressController.text,
                  labelText: 'Address',
                  items: _tripoliStreets
                      .map<DropdownMenuItem<String>>(
                        (street) => DropdownMenuItem<String>(
                          value: street,
                          child: Text(street),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _addressController.text = value!;
                    });
                  },
                  validator: (value) => value == null || value.isEmpty
                      ? 'Select your address'
                      : null,
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.03),
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
                SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                if (widget.userType == 1) _buildVendorFields(),
                SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                SizedBox(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.08,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : submitForm,
                    child: _isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text('Sign Up',
                            style: TextStyle(
                              fontSize: 18,
                            )),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    required int maxLength,
    TextInputType keyboardType = TextInputType.text,
    required String? Function(String?) validator,
    int? maxLines,
  }) {
    return TextFormField(
      controller: controller,
      maxLength: maxLength,
      decoration: InputDecoration(
        labelText: labelText,
        alignLabelWithHint: true,
      ),
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
    );
  }

  Widget _buildEmailFormField({
    required TextEditingController controller,
    required String labelText,
    TextInputType keyboardType = TextInputType.text,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: labelText),
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  Widget _buildPasswordFormField({
    required TextEditingController controller,
    required String labelText,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLength: 20,
      decoration: InputDecoration(
        labelText: labelText,
        suffixIcon: IconButton(
          icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility),
          onPressed: onToggleVisibility,
        ),
      ),
      obscureText: obscureText,
      validator: validator,
    );
  }

  Widget _buildDropdownButtonFormField({
    required String? value,
    required String labelText,
    required List<DropdownMenuItem<String>> items,
    required void Function(String?) onChanged,
    required String? Function(String?) validator,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(labelText: labelText),
      items: items,
      onChanged: onChanged,
      validator: validator,
    );
  }

  Widget _buildGenderSelection() {
    return Row(
      children: [
        Expanded(
          child: ListTile(
            title: Text('Male'),
            leading: Radio<GenderType>(
              value: GenderType.male,
              groupValue: _selectedGender,
              onChanged: (GenderType? value) {
                setState(() {
                  _selectedGender = value;
                });
              },
            ),
          ),
        ),
        Expanded(
          child: ListTile(
            title: Text('Female'),
            leading: Radio<GenderType>(
              value: GenderType.female,
              groupValue: _selectedGender,
              onChanged: (GenderType? value) {
                setState(() {
                  _selectedGender = value;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneNumberField() {
    return Row(
      children: [
        Flag.fromString('LY', height: 24, width: 32),
        SizedBox(width: MediaQuery.of(context).size.width * 0.02),
        Text('+218', style: TextStyle(fontSize: 16)),
        SizedBox(width: MediaQuery.of(context).size.width * 0.02),
        Expanded(
          child: TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            maxLength: 9,
            decoration: InputDecoration(
              labelText: 'Phone Number',
              counterText: "",
            ),
            validator: (value) {
              if (value == null ||
                  value.isEmpty ||
                  value.length != 9 ||
                  !RegExp(r'^[0-9]+$').hasMatch(value)) {
                return 'Enter a valid 9-digit number';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildVendorFields() {
    return Column(
      children: [
        _buildTextFormField(
            controller: _bioController,
            labelText: 'Bio',
            validator: (value) => null,
            maxLength: 250,
            maxLines: 5),
        SizedBox(height: MediaQuery.of(context).size.height * 0.03),
        _buildTextFormField(
          controller: _experienceController,
          labelText: 'Experience (years)',
          validator: (value) => null,
          maxLength: 2,
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.03),
        DropdownButtonFormField<Map<String, dynamic>>(
          value: _selectedCategory,
          decoration: InputDecoration(labelText: 'Select Category'),
          items: _categories
              .map((category) => DropdownMenuItem<Map<String, dynamic>>(
                    value: category,
                    child: Text(category['name']),
                  ))
              .toList(),
          onChanged: (newValue) {
            setState(() {
              _selectedCategory = newValue;
            });
          },
          validator: (value) => value == null ? 'Select a category' : null,
        ),
      ],
    );
  }
}
