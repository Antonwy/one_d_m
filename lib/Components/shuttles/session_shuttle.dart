import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:one_d_m/components/info_feed.dart';
import 'package:one_d_m/components/margin.dart';
import 'package:one_d_m/helper/color_theme.dart';
import 'package:one_d_m/helper/constants.dart';
import 'package:one_d_m/models/session_models/base_session.dart';
import 'package:one_d_m/provider/sessions_manager.dart';
import 'package:one_d_m/provider/theme_manager.dart';
import 'package:provider/provider.dart';

Widget sessionShuttle(
    Animation<double> animation,
    HeroFlightDirection flightDirection,
    BuildContext fromHeroContext,
    BuildContext toHeroContext,
    ThemeManager _theme,
    Widget bottomWidget) {
  fromHeroContext.visitChildElements((element) {
    print(element);
  });
  BaseSessionManager cm = (flightDirection == HeroFlightDirection.push
          ? toHeroContext
          : fromHeroContext)
      .read<BaseSessionManager>();

  BaseSession? session = cm.baseSession;

  return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        CurvedAnimation lateAnim =
            CurvedAnimation(parent: animation, curve: Interval(.8, 1.0));

        double borderRadius =
            Tween<double>(begin: Constants.radius, end: 0).evaluate(animation);

        Color backgroundColor = ColorTween(
                begin: session?.secondaryColor ?? _theme.colors.dark,
                end: ColorTheme.appBg)
            .evaluate(lateAnim)!;

        Color textColor = ColorTween(
                begin: _theme.correctColorFor(
                    session?.secondaryColor ?? _theme.colors.dark),
                end: _theme.colors.dark)
            .evaluate(lateAnim)!;

        double calculatedAmount = session!.amount! / session.donationUnit.value;

        return ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: Material(
            color: backgroundColor,
            child: Column(
              children: [
                Expanded(
                  flex: 10,
                  child: LayoutBuilder(builder: (context, constraints) {
                    print(constraints.maxHeight);
                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(
                          imageUrl: session.imgUrl ?? "",
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => session.blurHash != null
                              ? BlurHash(hash: session.blurHash!)
                              : Center(
                                  child: CircularProgressIndicator(
                                    valueColor:
                                        AlwaysStoppedAnimation(textColor),
                                  ),
                                ),
                        ),
                        if (session.reachedGoal)
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
                    );
                  }),
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
                                session.name ?? "",
                                style: _theme.textTheme
                                    .withColor(textColor)
                                    .bodyText1,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (session.isCertified) XMargin(4),
                            if (session.isCertified)
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
                          children: session.amount == null ||
                                  session.donationGoal == null
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
                                    "${((calculatedAmount / session.donationGoal!) * 100).round()}%",
                                    style: _theme.textTheme
                                        .withColor(textColor)
                                        .bodyText2,
                                  ),
                                  XMargin(12),
                                  Expanded(
                                    child: PercentLine(
                                      percent: (calculatedAmount /
                                              session.donationGoal!)
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
        );
      });
}
