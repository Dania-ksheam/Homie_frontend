import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../theme.dart';
import '../config.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vendor Comments',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: VendorCommentsScreen(vendorId: 'your-vendor-id-here'),
    );
  }
}

class VendorCommentsScreen extends StatefulWidget {
  final String vendorId;

  const VendorCommentsScreen({required this.vendorId, Key? key})
      : super(key: key);

  @override
  _VendorCommentsScreenState createState() => _VendorCommentsScreenState();
}

class _VendorCommentsScreenState extends State<VendorCommentsScreen> {
  late Future<List<Comment>> comments;

  @override
  void initState() {
    super.initState();
    comments = fetchComments(widget.vendorId);
  }

  Future<List<Comment>> fetchComments(String vendorId) async {
    print(vendorId);
    final response = await http.get(Uri.parse(
        '${AppConfig.baseUrl}:7127/api/Comments/filter?vendorProfileId=$vendorId'));
    print(json.decode(response.body));

    if (response.statusCode == 200 || response.statusCode == 201) {
      final List<dynamic> data = json.decode(response.body);
      if (data.any((json) =>
          json['content'] == 'The comment contains inappropriate content.')) {
        _showInappropriateContentPopup();
        return [];
      }
      return data.map((json) => Comment.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load comments');
    }
  }

  Future<User> fetchUserDetails(String userId) async {
    final response =
        await http.get(Uri.parse('${AppConfig.baseUrl}:7127/api/User/$userId'));
    print(json.decode(response.body));

    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> data = json.decode(response.body);
      return User.fromJson(data);
    } else {
      throw Exception('Failed to load user details');
    }
  }

  void _showInappropriateContentPopup() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Inappropriate Content'),
          content: const Text(
              'The comment contains inappropriate content and cannot be displayed.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
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
        title: Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 2),
          child: Text(
            'Vendor Comments',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: FutureBuilder<List<Comment>>(
        future: comments,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No comments available'));
          } else {
            final allComments = snapshot.data!;
            return ListView.builder(
              itemCount: allComments.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final comment = allComments[index];
                return FutureBuilder<User>(
                  future: fetchUserDetails(comment.userId),
                  builder: (context, userSnapshot) {
                    if (userSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (userSnapshot.hasError) {
                      return ListTile(
                        title: Text('Error loading user data'),
                        subtitle: Text(comment.content ?? 'No content'),
                      );
                    } else if (!userSnapshot.hasData) {
                      return ListTile(
                        title: Text('User data not available'),
                        subtitle: Text(comment.content ?? 'No content'),
                      );
                    } else {
                      final user = userSnapshot.data!;
                      return CommentCard(
                        userName: user.userName,
                        email: user.email,
                        content: comment.content,
                        rating: comment.rating,
                        imageUrl: user.image,
                      );
                    }
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}

class CommentCard extends StatelessWidget {
  final String userName;
  final String email;
  final String? content;
  final int? rating;
  final String? imageUrl;

  const CommentCard({
    required this.userName,
    required this.email,
    this.content,
    this.rating,
    this.imageUrl,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
        leading: imageUrl != null
            ? CircleAvatar(
                backgroundImage: NetworkImage(imageUrl!),
              )
            : const CircleAvatar(
                child: Icon(Icons.person),
              ),
        title:
            Text(userName, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.grey[200], // Background color of the bubble
            borderRadius: BorderRadius.circular(12), // Rounded corners
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0), // Padding inside the bubble
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        content ?? 'No content',
                        softWrap: true,
                        overflow: TextOverflow.visible,
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 10),
                if (rating != null)
                  Row(
                    children: [
                      Text('Rating: $rating'),
                      Icon(Icons.star, color: Colors.yellow),
                    ],
                  ),
              ],
            ),
          ),
        ));
  }
}

class Comment {
  final String id;
  final String? content;
  final int? rating;
  final String vendorProfileId;
  final String userId;

  Comment({
    required this.id,
    this.content,
    this.rating,
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
  final String location;
  final int gender;
  final String userAddress;
  final String email;
  final String userName;
  final int type;
  final int age;
  final String? image;
  final String password;
  final String phone;

  User({
    required this.id,
    required this.location,
    required this.gender,
    required this.userAddress,
    required this.email,
    required this.userName,
    required this.type,
    required this.age,
    this.image,
    required this.password,
    required this.phone,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      location: json['location'],
      gender: json['gender'],
      userAddress: json['userAddress'],
      email: json['email'],
      userName: json['userName'],
      type: json['type'],
      age: json['age'],
      image: json['image'],
      password: json['password'],
      phone: json['phone'],
    );
  }
}
