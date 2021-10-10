import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:one_d_m/components/info_feed.dart';
import 'package:one_d_m/components/margin.dart';
import 'package:one_d_m/components/shuttles/session_shuttle.dart';
import 'package:one_d_m/helper/constants.dart';
import 'package:one_d_m/models/session_models/base_session.dart';
import 'package:one_d_m/provider/theme_manager.dart';
import 'package:one_d_m/views/sessions/session_page.dart';

import '../custom_hero.dart';

class SessionView extends StatelessWidget {
  final BaseSession? session;
  final bool withHero;

  SessionView(this.session, {this.withHero = true});

  @override
  Widget build(BuildContext context) {
    ThemeManager _theme = ThemeManager.of(context);
    Color? textColor =
        _theme.correctColorFor(session?.secondaryColor ?? _theme.colors.dark);

    double calculatedAmount = session!.amount! / session!.donationUnit.value!;

    return Padding(
        padding: const EdgeInsets.all(2.0),
        child: CustomHero(
          tag: "${session!.id}-container",
          disabled: true,
          flightShuttleBuilder: (flightContext, anim, direction, fromContext,
                  toContext) =>
              sessionShuttle(
                  anim, direction, fromContext, toContext, _theme, Container()),
          child: Material(
            elevation: 1,
            color: session?.secondaryColor ?? _theme.colors.dark,
            borderRadius: BorderRadius.circular(Constants.radius),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SessionPage(session)));
                // PageRouteBuilder(
                //     barrierColor: Colors.black26,
                //     pageBuilder: (context, anim1, anim2) =>
                //         SessionPage(session),
                //     transitionDuration: Duration(milliseconds: 500),
                //     reverseTransitionDuration: Duration(milliseconds: 500),
                //     transitionsBuilder: (context, anim1, anim2, child) =>
                //         child));
              },
              child: SizedBox(
                width: 230,
                child: Column(
                  children: [
                    Expanded(
                      flex: 10,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CachedNetworkImage(
                            imageUrl:
                                session?.thumbnailUrl ?? session?.imgUrl ?? "",
                            width: double.infinity,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => session?.blurHash != null
                                ? BlurHash(hash: session!.blurHash!)
                                : Center(
                                    child: CircularProgressIndicator(
                                      valueColor:
                                          AlwaysStoppedAnimation(textColor),
                                    ),
                                  ),
                          ),
                          if (session?.reachedGoal ?? false)
                            Material(
                                color: Colors.black45,
                                child: Center(
                                  child: Material(
                                      color: _theme.colors.contrast,
                                      shape: CircleBorder(),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Icon(
                                          Icons.done,
                                          color: _theme.colors.textOnContrast,
                                        ),
                                      )),
                                ))
                        ],
                      ),
                    ),
                    Flexible(
                      flex: 4,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                            child: Row(
                              children: [
                                Flexible(
                                  flex: 6,
                                  child: AutoSizeText(
                                    session?.name ?? "",
                                    style: _theme.textTheme
                                        .withColor(textColor)
                                        .bodyText1,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (session!.isCertified) XMargin(4),
                                if (session!.isCertified)
                                  Icon(
                                    Icons.verified,
                                    color: Colors.greenAccent[400],
                                    size: 16,
                                  )
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(8, 0, 14, 0),
                            child: Row(
                              children: session?.donationUnit == null ||
                                      session?.amount == null ||
                                      session?.donationGoal == null
                                  ? [
                                      Text(
                                        "0%",
                                        style: _theme.textTheme
                                            .withColor(textColor)
                                            .bodyText2,
                                      ),
                                      XMargin(12),
                                      Expanded(
                                        child: PercentLine(
                                          percent: 0,
                                          height: 8.0,
                                          color: textColor,
                                        ),
                                      ),
                                    ]
                                  : [
                                      Text(
                                        "${((calculatedAmount / session!.donationGoal!) * 100).round()}%",
                                        style: _theme.textTheme
                                            .withColor(textColor)
                                            .bodyText2,
                                      ),
                                      XMargin(12),
                                      Expanded(
                                        child: PercentLine(
                                          percent: (calculatedAmount /
                                                  session!.donationGoal!)
                                              .clamp(0.0, 1.0),
                                          height: 8.0,
                                          color: textColor,
                                        ),
                                      ),
                                    ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
