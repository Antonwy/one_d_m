import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class Avatar extends StatelessWidget {
  String imageUrl;
  IconData icon;

  Avatar(this.imageUrl, {this.icon});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: Colors.grey[300],
      child: imageUrl == null ? Icon(icon ?? Icons.person, color: Colors.black87,) : null,
      backgroundImage: imageUrl == null
          ? null
          : CachedNetworkImageProvider(
              imageUrl,
            ),
    );
  }
}
