import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:url_launcher/url_launcher.dart';

import '../theme.dart';
import '../config.dart';

class VendorDetailsScreen extends StatefulWidget {
  final String userId;
  final String vendorId;
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

  const VendorDetailsScreen({
    required this.userId,
    required this.vendorId,
    required this.vendorName,
    required this.vendorEmail,
    this.vendorImage,
    required this.bio,
    required this.experience,
    required this.age,
    required this.phoneNumber,
    required this.location,
    required this.gender,
    required this.userAddress,
    Key? key,
  }) : super(key: key);

  @override
  _VendorDetailsScreenState createState() => _VendorDetailsScreenState();
}

class _VendorDetailsScreenState extends State<VendorDetailsScreen> {
  late Future<List<Comment>> comments;
  final Map<String, User> _userCache =
      {}; // Store user data to prevent multiple fetches
  final _commentController = TextEditingController();
  int _rating = 0;
  bool _isPostingComment = false; // State to track posting comment

  @override
  void initState() {
    super.initState();
    comments = fetchComments(widget.vendorId);
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  /// Fetch vendor comments from API
  Future<List<Comment>> fetchComments(String vendorId) async {
    print(vendorId);
    try {
      final response = await http.get(
        Uri.parse(
            '${AppConfig.baseUrl}:7127/api/Comments/filter?vendorProfileId=$vendorId'),
      );
      print('dania');
      print(json.decode(response.body));
      if (response.statusCode == 200 || response.statusCode == 201) {
        List jsonResponse = json.decode(response.body);
        List<Comment> commentList =
            jsonResponse.map((comment) => Comment.fromJson(comment)).toList();

        // Fetch user details for all comments in a single request
        await _fetchUsersForComments(commentList);

        return commentList;
      } else {
        throw Exception('Failed to load comments: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching comments: $e');
    }
  }

  /// Fetch user details for all comments (reducing API calls)
  Future<void> _fetchUsersForComments(List<Comment> comments) async {
    Set<String> uniqueUserIds = comments.map((c) => c.userId).toSet();

    for (String userId in uniqueUserIds) {
      if (!_userCache.containsKey(userId)) {
        try {
          final user = await fetchUser(userId);
          _userCache[userId] = user;
        } catch (e) {
          debugPrint("Error fetching user ($userId): $e");
        }
      }
    }
  }

  /// Fetch user details from API (called only once per user)
  Future<User> fetchUser(String userId) async {
    print(userId);
    print('dania');
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}:7127/api/User/$userId'),
      );
      print(json.decode(response.body));
      if (response.statusCode == 200 || response.statusCode == 201) {
        return User.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load user: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching user: $e');
    }
  }

  Future<void> _postComment() async {
    if (_commentController.text.isEmpty || _rating == 0) {
      _showErrorDialog('Please enter a comment and rating.');
      return;
    }

    setState(() {
      _isPostingComment = true; // Show loading indicator
    });

    final comment = {
      'content': _commentController.text,
      'rating': _rating,
      'vendorProfileId': widget.vendorId,
      'userId': widget.userId,
    };

    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}:7127/api/Comments'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(comment),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Comment posted successfully')),
        );
        setState(() {
          comments = fetchComments(widget.vendorId);
        });
        _commentController.clear();
        setState(() {
          _rating = 0;
        });
      } else if (response.statusCode == 400) {
        _showErrorDialog('Bad comment: ${response.body}');
      } else {
        throw Exception('Failed to post comment');
      }
    } catch (e) {
      _showErrorDialog('Error posting comment: $e');
    } finally {
      setState(() {
        _isPostingComment = false; // Hide loading indicator
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _openMap(String location) async {
    final url =
        'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(location)}';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('User ID: ${widget.userId}');
    debugPrint('Vendor ID: ${widget.vendorId}');

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryColor),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: AppColors.backgroundColor,
        title: const Text(
          'Vendor Details',
          style: TextStyle(color: AppColors.primaryColor),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 1,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: widget.vendorImage != null
                      ? NetworkImage(widget.vendorImage!)
                      : null,
                  child: widget.vendorImage == null
                      ? const Icon(Icons.person, size: 50)
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.vendorName,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                widget.vendorEmail,
                style: const TextStyle(fontSize: 18, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              Text('Bio: ${widget.bio}', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              Text('Experience: ${widget.experience} years',
                  style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 16),
              Text('Age: ${widget.age}', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              Text('Phone: ${widget.phoneNumber}',
                  style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              Text('Location: ', style: const TextStyle(fontSize: 16)),
              InkWell(
                onTap: () => _openMap(widget.location),
                child: Text(
                  widget.location,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(height: 8),
            Text(
  'Gender: ${widget.gender == '1' ? 'Male' : 'Female'}',
  style: const TextStyle(fontSize: 16),
),

              const SizedBox(height: 8),
              Text('Address: ${widget.userAddress}',
                  style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 16),

              /// Comment Input Section
              TextField(
                controller: _commentController,
                decoration: const InputDecoration(
                  labelText: 'Enter your comment',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 8),
              DropdownButton<int>(
                value: _rating == 0 ? null : _rating,
                items: List.generate(5, (index) => index + 1)
                    .map((rating) => DropdownMenuItem<int>(
                          value: rating,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('$rating'),
                              const Icon(Icons.star, color: Colors.yellow),
                            ],
                          ),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _rating = value!;
                  });
                },
                hint: const Text('Select a rating'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _isPostingComment ? null : _postComment,
                child: _isPostingComment
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    : const Text('Post Comment'),
              ),
              const SizedBox(height: 16),

              /// Comments Section
              FutureBuilder<List<Comment>>(
                future: comments,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Center(child: Text('Failed to load comments'));
                  } else if (snapshot.hasData && snapshot.data!.isEmpty) {
                    return const Center(child: Text('No comments available'));
                  } else {
                    return ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final comment = snapshot.data![index];
                        final user = _userCache[comment.userId];

                        if (user == null) {
                          return const ListTile(
                            title: Text("Failed to load user"),
                          );
                        }

                        return ListTile(
                          title: Text(
                            user.email,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.name,
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.grey),
                              ),
                              Text(
                                'Rating: ${'★' * comment.rating}${'☆' * (5 - comment.rating)}',
                                style: const TextStyle(fontSize: 16),
                              ),
                              Text(
                                'Content: ${comment.content ?? 'No content'}',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// **Comment Model**
class Comment {
  final String id;
  final String? content;
  final int rating;
  final String vendorProfileId;
  final String userId;

  Comment({
    required this.id,
    this.content,
    required this.rating,
    required this.vendorProfileId,
    required this.userId,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      content: json['content'],
      rating: json['rating'],
      vendorProfileId: json['vendorProfileId'],
      userId: json['userId'],
    );
  }
}

class User {
  final String id;
  final String name;
  final String email;
  final String? location; // Nullable
  final String? gender; // Nullable
  final String? userAddress; // Nullable
  final String? image; // Nullable
  final String? phone; // Nullable
  final int age; // Assuming age is always present

  User({
    required this.id,
    required this.name,
    required this.email,
    this.location,
    this.gender,
    this.userAddress,
    this.image,
    this.phone,
    required this.age, // Keeping age required
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '', // Default empty string if null
      name: json['userName'] ?? 'Unknown', // Provide a fallback
      email: json['email'] ?? 'No email', // Provide a fallback
      location: json['location'], // Nullable field
      gender: json['gender']?.toString(), // Convert to string safely
      userAddress: json['userAddress'], // Nullable field
      image: json['image'], // Nullable field
      phone: json['phone'], // Nullable field
      age: json['age'] ?? 0, // Default age to 0 if null
    );
  }
}
