import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/Components/DonationWidget.dart';
import 'package:one_d_m/Helper/ColorTheme.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/Organisation.dart';
import 'package:one_d_m/Pages/OrganisationPage.dart';

import 'AnimatedFutureBuilder.dart';
import 'CustomOpenContainer.dart';

class OrganisationButton extends StatelessWidget {
  String id;
  Organisation organisation;
  Color color;
  TextStyle textStyle;
  double elevation;
  Function(Organisation) onPressed;
  double borderRadius;

  OrganisationButton(this.id,
      {this.organisation,
      this.color,
      this.textStyle = const TextStyle(color: Colors.black),
      this.onPressed,
      this.elevation = 1,
      this.borderRadius = 5});

  @override
  Widget build(BuildContext context) {
    return AnimatedFutureBuilder<Organisation>(
        future: organisation == null
            ? DatabaseService.getCampaign(id)
            : Future.value(organisation),
        builder: (context, snapshot) {
          if (snapshot.hasData)
            return CustomOpenContainer(
              openBuilder: (context, open, scrollController) =>
                  OrganisationPage(
                snapshot.data.description == null
                    ? Organisation(
                        id: organisation.id,
                        imgUrl: organisation.imgUrl,
                        name: organisation.name)
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
                    onPressed(snapshot.data);
                    return;
                  }
                  open();
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: <Widget>[
                      RoundedAvatar(
                        snapshot.data.imgUrl,
                        color: color ?? ColorTheme.appBg,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: AutoSizeText(
                          "${snapshot.data.name}",
                          maxLines: 1,
                          style: Theme.of(context)
                              .textTheme
                              .bodyText1
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
