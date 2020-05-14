import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/Helper/ColorTheme.dart';
import 'package:transparent_image/transparent_image.dart';

class Avatar extends StatelessWidget {
  String imageUrl;
  IconData icon;
  Function onTap;
  double elevation;
  Color color, iconColor;

  Avatar(this.imageUrl,
      {this.icon,
      this.onTap,
      this.elevation = 0.0,
      this.color = ColorTheme.blue,
      this.iconColor = ColorTheme.red});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        backgroundImage:
            imageUrl != null ? CachedNetworkImageProvider(imageUrl) : null,
        backgroundColor: color,
        child: imageUrl == null
            ? Icon(
                icon ?? Icons.person,
                color: iconColor,
              )
            : Container(),
      ),
    );
  }
}
