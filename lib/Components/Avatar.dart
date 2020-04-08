import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class Avatar extends StatelessWidget {
  String imageUrl;
  IconData icon;
  Function onTap;
  double elevation;

  Avatar(this.imageUrl, {this.icon, this.onTap, this.elevation = 0.0});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Material(
          elevation: elevation,
          shape: CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: CircleAvatar(
            backgroundColor: Colors.grey[300],
            child: imageUrl == null
                ? Icon(
                    icon ?? Icons.person,
                    color: Colors.black87,
                  )
                : null,
            backgroundImage: imageUrl == null
                ? null
                : CachedNetworkImageProvider(
                    imageUrl,
                  ),
          )),
    );
  }
}
