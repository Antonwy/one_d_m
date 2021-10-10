import 'dart:ui';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/helper/color_theme.dart';
import 'package:one_d_m/helper/database_service.dart';
import 'package:one_d_m/models/organization.dart';
import 'package:one_d_m/views/organizations/organization_page.dart';
import 'animated_future_builder.dart';
import 'custom_open_container.dart';
import 'donation_widget.dart';

class OrganizationButton extends StatelessWidget {
  String id;
  Organization? organization;
  Color? color;
  TextStyle textStyle;
  double elevation;
  Function(Organization?)? onPressed;
  double borderRadius;

  OrganizationButton(this.id,
      {this.organization,
      this.color,
      this.textStyle = const TextStyle(color: Colors.black),
      this.onPressed,
      this.elevation = 1,
      this.borderRadius = 5});

  @override
  Widget build(BuildContext context) {
    return AnimatedFutureBuilder<Organization>(
        future: organization == null
            ? DatabaseService.getOrganization(id)
            : Future.value(organization),
        builder: (context, snapshot) {
          if (snapshot.hasData)
            return CustomOpenContainer(
              openBuilder: (context, open, scrollController) =>
                  OrganizationPage(
                snapshot.data!.description == null
                    ? Organization(
                        id: organization!.id,
                        imgUrl: organization!.imgUrl,
                        name: organization!.name)
                    : snapshot.data,
                scrollController: scrollController,
              ),
              closedColor: color ?? ColorTheme.appBg,
              closedElevation: elevation,
              closedShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius)),
              closedBuilder: (context, open) => InkWell(
                onTap: () {
                  if (onPressed != null) {
                    onPressed!(snapshot.data);
                    return;
                  }
                  open();
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: <Widget>[
                      RoundedAvatar(
                        snapshot.data!.imgUrl,
                        color: color ?? ColorTheme.appBg,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: AutoSizeText(
                          "${snapshot.data!.name}",
                          maxLines: 1,
                          style: Theme.of(context)
                              .textTheme
                              .bodyText1!
                              .copyWith(color: textStyle.color),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          return Container(height: 20);
        });
  }
}
