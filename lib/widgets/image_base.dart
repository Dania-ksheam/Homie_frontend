import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

class ImageFromBase64 extends StatelessWidget {
  final String base64String;

  ImageFromBase64({required this.base64String});

  @override
  Widget build(BuildContext context) {
    Uint8List bytes = base64Decode(base64String);
    return Image.memory(bytes);
  }
}