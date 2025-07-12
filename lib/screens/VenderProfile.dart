import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:flag/flag.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

import '../theme.dart';
import '../widgets/image_base.dart';
import '../config.dart';

class VendorProfile extends StatefulWidget {
  final String userId;
  final String vendorId;

  const VendorProfile({
    Key? key,
    required this.userId,
    required this.vendorId,
  }) : super(key: key);

  @override
  _VendorProfileState createState() => _VendorProfileState();
}

class _VendorProfileState extends State<VendorProfile> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _userAddressController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  String? _profileImage;
  String _selectedGender = 'Male'; // Default gender
  final Location _location = Location();
  bool _isLoading = true;
  File? _selectedImage;
  String? _base64Image;
  String? _existingPassword;
  String? _categoryId;
  String? _vendorProfileId;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      print(
          'Fetching data for userId: ${widget.userId} and vendorId: ${widget.vendorId}');

      final userResponse = await http.get(
        Uri.parse('${AppConfig.baseUrl}:7127/api/user/${widget.userId}'),
      );

      final vendorResponse = await http.get(
        Uri.parse(
            '${AppConfig.baseUrl}:7127/api/venderProfile/${widget.vendorId}'),
      );

      print('User Response: ${userResponse.body}');
      print('Vendor Response: ${vendorResponse.body}');

      if (userResponse.statusCode == 200 && vendorResponse.statusCode == 200) {
        final userData = jsonDecode(userResponse.body);
        final vendorData = jsonDecode(vendorResponse.body);

        setState(() {
          _usernameController.text = userData['userName'] ?? '';
          _bioController.text = vendorData['bio'] ?? '';
          _phoneController.text = userData['phone'] ?? '';
          _emailController.text = userData['email'] ?? '';
          _experienceController.text =
              vendorData['experience']?.toString() ?? '';
          _addressController.text = userData['location'] ?? '';
          _userAddressController.text = userData['userAddress'] ?? '';
          _ageController.text = userData['age']?.toString() ?? '';
          _selectedGender = userData['gender'] == 1 ? 'Male' : 'Female';
          _profileImage = userData['image'];
          _existingPassword = userData['password'];
          _categoryId = vendorData['categoryId'];
          _vendorProfileId = vendorData['id'];
          _isLoading = false;
        });
        print('User Data: $userData');
        print('Vendor Data: $vendorData');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch data')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
      print('Error fetching data: $e');
    }
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

  Future<void> _getCurrentLocation() async {
    final LocationData locationData = await _location.getLocation();
    _addressController.text =
        "${locationData.latitude},${locationData.longitude}";
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Location updated!"),
      ),
    );
    print(
        'Current Location: Lat: ${locationData.latitude}, Long: ${locationData.longitude}');
  }

  Future<void> _showChangePasswordDialog() async {
    showDialog(
      context: context,
      barrierDismissible:
          false, // Prevents dismissing the dialog by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Change Password"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _newPasswordController,
                obscureText: true,
                decoration: InputDecoration(labelText: "New Password"),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(labelText: "Confirm Password"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (_newPasswordController.text !=
                    _confirmPasswordController.text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Passwords do not match")),
                  );
                  print('Passwords do not match');
                } else {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Password changed successfully")),
                  );
                  print('Password changed successfully');
                }
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final userData = {
        'id': widget.userId,
        'userName': _usernameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'age': int.tryParse(_ageController.text) ?? 0,
        'gender': _selectedGender == 'Male' ? 1 : 0,
        'location': _addressController.text,
        'userAddress': _userAddressController.text,
        'password': _newPasswordController.text.isNotEmpty
            ? _newPasswordController.text
            : _existingPassword,
        'image': _selectedImage != null
            ? base64Encode(_selectedImage!.readAsBytesSync())
            : _profileImage,
        'type': 1, // Assuming userType is always Vendor for this screen
      };

      final vendorData = {
        'id': _vendorProfileId,
        'bio': _bioController.text,
        'experience': int.tryParse(_experienceController.text) ?? 0,
        'categoryId': _categoryId,
        'userId': widget.userId,
      };

      print('User Data to be sent: $userData');
      print('Vendor Data to be sent: $vendorData');

      try {
        final userResponse = await http.put(
          Uri.parse('${AppConfig.baseUrl}:7127/api/user/${widget.userId}'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(userData),
        );

        final vendorResponse = await http.put(
          Uri.parse(
              '${AppConfig.baseUrl}:7127/api/venderProfile/${widget.vendorId}'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(vendorData),
        );

        print('User Response Status: ${userResponse.statusCode}');
        print('User Response Body: ${userResponse.body}');
        print('Vendor Response Status: ${vendorResponse.statusCode}');
        print('Vendor Response Body: ${vendorResponse.body}');

        if (userResponse.statusCode == 200 &&
            vendorResponse.statusCode == 204) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Profile updated successfully')),
          );
          print('Profile updated successfully');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update profile')),
          );
          print(
              'Failed to update profile: User Response Status: ${userResponse.statusCode}, Vendor Response Status: ${vendorResponse.statusCode}');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: $e')),
        );
        print('Error updating profile: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 2),
          child: Text(
            "Profile",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          if (_selectedImage != null)
                            CircleAvatar(
                              radius: 50,
                              backgroundImage: FileImage(_selectedImage!),
                            )
                          else if (_base64Image != null)
                            CircleAvatar(
                              radius: 50,
                              backgroundImage:
                                  MemoryImage(base64Decode(_base64Image!)),
                            )
                          else if (_profileImage != null)
                            CircleAvatar(
                              radius: 50,
                              backgroundImage: NetworkImage(_profileImage!),
                            )
                          else
                            const CircleAvatar(
                              radius: 50,
                              child: Icon(Icons.person),
                            ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: IconButton(
                              icon: Icon(Icons.add_circle,
                                  color: AppColors.backgroundColor),
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Wrap(
                                      children: [
                                        ListTile(
                                          leading: Icon(Icons.photo_library),
                                          title: Text("Change Picture"),
                                          onTap: () {
                                            Navigator.pop(context);
                                            _pickImage();
                                          },
                                        ),
                                        ListTile(
                                          leading: Icon(Icons.delete),
                                          title: Text("Delete Picture"),
                                          onTap: () {
                                            Navigator.pop(context);
                                            _removeImage();
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _usernameController.text.isEmpty
                                ? "Username"
                                : _usernameController.text,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              setState(() {
                                _usernameController.text = '';
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _bioController,
                        maxLines: 4,
                        decoration: InputDecoration(labelText: "Bio"),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Flag.fromCode(FlagsCode.LY, height: 20, width: 30),
                          const SizedBox(width: 8),
                          Text("+218"),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _phoneController,
                              keyboardType: TextInputType.number,
                              maxLength: 9,
                              decoration: InputDecoration(labelText: "Phone"),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(labelText: "Email"),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _experienceController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: "Experience"),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedGender,
                        items: [
                          DropdownMenuItem(value: 'Male', child: Text("Male")),
                          DropdownMenuItem(
                              value: 'Female', child: Text("Female")),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedGender = value!;
                          });
                        },
                        decoration: InputDecoration(labelText: "Gender"),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _addressController,
                        decoration: InputDecoration(
                          labelText: "Address",
                          suffixIcon: IconButton(
                            icon: Icon(Icons.location_on),
                            onPressed: _getCurrentLocation,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _userAddressController,
                        decoration: InputDecoration(labelText: "User Address"),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _ageController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: "Age"),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _saveProfile,
                          child: Text("Save Changes"),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: TextButton(
                          onPressed: _showChangePasswordDialog,
                          child: Text("Change Password"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
