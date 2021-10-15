import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/helper/color_theme.dart';
import 'package:one_d_m/helper/database_service.dart';
import 'package:one_d_m/models/session_models/base_session.dart';
import 'package:one_d_m/views/sessions/session_page.dart';

import '../animated_future_builder.dart';
import '../donation_widget.dart';

class SessionButton extends StatelessWidget {
  final String id;
  final BaseSession? session;
  final Color? color;
  final TextStyle textStyle;
  final double elevation;
  final Function(BaseSession?)? onPressed;
  final double borderRadius;

  SessionButton(this.id,
      {this.session,
      this.color,
      this.textStyle = const TextStyle(color: Colors.black),
      this.onPressed,
      this.elevation = 1,
      this.borderRadius = 5});

  @override
  Widget build(BuildContext context) {
    return AnimatedFutureBuilder<BaseSession>(
        future: session == null
            ? DatabaseService.getSessionFuture(id)
            : Future.value(session),
        builder: (context, snapshot) {
          if (snapshot.hasData)
            return InkWell(
              onTap: () {
                if (onPressed != null) {
                  onPressed!(snapshot.data);
                  return;
                }
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SessionPage(session)));
              },
              child: Material(
                color: color ?? ColorTheme.appBg,
                elevation: elevation,
                borderRadius: BorderRadius.circular(borderRadius),
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
