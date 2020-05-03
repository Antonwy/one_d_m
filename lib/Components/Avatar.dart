import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/Helper/ColorTheme.dart';
import 'package:transparent_image/transparent_image.dart';

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
              backgroundColor: ColorTheme.avatar,
              child: Stack(
                children: <Widget>[
                  Positioned.fill(
                    child: imageUrl != null
                        ? FadeInImage(
                            placeholder: MemoryImage(kTransparentImage),
                            image: CachedNetworkImageProvider(imageUrl),
                            fit: BoxFit.cover,
                            fadeInDuration: Duration(milliseconds: 300),
                          )
                        : Container(),
                  ),
                  imageUrl == null
                      ? Icon(
                          icon ?? Icons.person,
                          color: Colors.white,
                        )
                      : Container(),
                ],
              ))),
    );
  }
}
