import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/components/info_feed.dart';
import 'package:one_d_m/components/margin.dart';
import 'package:one_d_m/models/session_models/base_session.dart';
import 'package:one_d_m/models/session_models/session.dart';
import 'package:one_d_m/models/user.dart';
import 'package:one_d_m/provider/theme_manager.dart';
import 'package:one_d_m/provider/sessions_manager.dart';
import 'package:one_d_m/provider/user_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:styled_text/styled_text.dart';
import 'constants.dart';
import 'numeral.dart';

class InstagramImages {
  final File? foreground, background;

  InstagramImages({this.foreground, this.background});
}

class ShareImage {
  final BuildContext? context;

  ShareImage.of(this.context);

  Future<File> _createBackgroundImage(Color? color, String path) async {
    Widget widget = Container(
      width: 200,
      height: 400,
      color: color,
    );

    Uint8List pngBytes = await ScreenshotController().captureFromWidget(widget);

    File file = File(path);
    return file.writeAsBytes(pngBytes);
  }

  Future<InstagramImages?> createSessionImageFromManager(
      BaseSessionManager sessionManager) async {
    Session? session = sessionManager.session;
    if (session == null) return null;

    print("Session image url: ${session.imgUrl}");
    print("Campaign image url: ${session.campaignImageUrl}");

    User? user = context!.read<UserManager>().user;
    final List<ImageProvider> images = [
      CachedNetworkImageProvider(session.imgUrl!),
      CachedNetworkImageProvider(session.campaignImageUrl!),
    ];

    if (user?.imgUrl != null)
      images.add(CachedNetworkImageProvider(user!.imgUrl!));

    for (ImageProvider imgProv in images) {
      final c = Completer();
      imgProv
          .resolve(ImageConfiguration())
          .addListener(ImageStreamListener((info, val) {
        if (!c.isCompleted) c.complete();
      }));

      await c.future;
    }

    Widget sessionImage = SessionImage(
      session: sessionManager.session,
      user: user,
      theme: ThemeManager.of(context!, listen: false),
      mq: MediaQuery.of(context!),
      images: images,
    );

    Uint8List screenshot = await ScreenshotController()
        .captureFromWidget(sessionImage, delay: Duration(milliseconds: 500));

    imageCache!.clear();
    final directory = (await getApplicationDocumentsDirectory()).path;

    String filePath =
        "$directory/${sessionManager.baseSession!.name!.replaceAll(" ", "_")}_share.png";

    String backgroundFilePath =
        "$directory/${sessionManager.baseSession!.name!.replaceAll(" ", "_")}_share_background.png";

    File backgroundFile = await _createBackgroundImage(
        sessionManager.baseSession!.primaryColor, backgroundFilePath);
    File imgFile = new File(filePath);

    return InstagramImages(
        foreground: await imgFile.writeAsBytes(screenshot),
        background: backgroundFile);
  }
}

class SessionImage extends StatelessWidget {
  final Session? session;
  final User? user;
  final ThemeManager? theme;
  final MediaQueryData? mq;
  final List<ImageProvider>? images;

  const SessionImage(
      {this.session, this.user, this.theme, this.mq, this.images});

  @override
  Widget build(BuildContext c) {
    ThemeManager _theme = theme!;
    return Container(
      height: 650,
      color: session!.primaryColor,
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Material(
                  elevation: 20,
                  borderRadius: BorderRadius.circular(Constants.radius),
                  clipBehavior: Clip.antiAlias,
                  color: session!.secondaryColor,
                  child: Builder(builder: (context) {
                    double size = (mq!.size.width - 64) / 2;
                    return Column(
                      children: [
                        Row(
                          children: [
                            Image(
                              image: images![0],
                              width: size,
                              height: size,
                              fit: BoxFit.cover,
                            ),
                            Image(
                              image: images![1],
                              width: size,
                              height: size,
                              fit: BoxFit.cover,
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            user?.imgUrl == null && images!.length < 2
                                ? Container(
                                    width: size,
                                    height: size,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.person,
                                          size: 40,
                                          color: _theme.correctColorFor(
                                              session!.secondaryColor!),
                                        ),
                                        YMargin(6),
                                        Text(
                                          user!.name,
                                          style: _theme.textTheme
                                              .correctColorFor(
                                                  session!.secondaryColor!)
                                              .bodyText1
                                              .copyWith(
                                                  fontWeight: FontWeight.bold),
                                        )
                                      ],
                                    ),
                                  )
                                : Image(
                                    image: images![2],
                                    width: size,
                                    height: size,
                                    fit: BoxFit.cover,
                                  ),
                            Container(
                              width: size,
                              height: size,
                              child: Stack(
                                children: [
                                  Align(
                                    alignment: Alignment.topRight,
                                    child: Image.asset(
                                      'assets/images/ic_onedm.png',
                                      width: 110,
                                      height: 110,
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 20,
                                    left: 20,
                                    child: Text(
                                      "One\nDollar\nMovement",
                                      style: _theme.textTheme
                                          .correctColorFor(
                                              session!.secondaryColor!)
                                          .bodyText1
                                          .copyWith(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  })),
            ),
            YMargin(24),
            Text(
              session!.name!,
              style: _theme.textTheme
                  .correctColorFor(session!.primaryColor!)
                  .headline6,
            ),
            StyledText(
              text:
                  "<b>${session!.name}</b> unterstützt <b>${session!.campaignTitle}</b>",
              tags: {
                'b':
                    StyledTextTag(style: TextStyle(fontWeight: FontWeight.bold))
              },
              style: _theme.textTheme
                  .correctColorFor(session!.primaryColor!)
                  .caption,
            ),
            YMargin(12),
            Builder(builder: (context) {
              Color? textColor =
                  _theme.correctColorFor(session!.secondaryColor!);
              BaseTextTheme textTheme =
                  _theme.textTheme.correctColorFor(session!.secondaryColor!);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Material(
                    color: session!.secondaryColor,
                    borderRadius: BorderRadius.circular(Constants.radius),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                              child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              children: [
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                          text:
                                              "${Numeral(session!.amount!).value()} "),
                                      if (session!.donationUnit.smiley !=
                                              null &&
                                          session!
                                              .donationUnit.smiley!.isNotEmpty)
                                        TextSpan(
                                            text:
                                                "${session!.donationUnit.smiley}",
                                            style: TextStyle(
                                                fontSize: 38,
                                                fontWeight: FontWeight.w300))
                                      else
                                        TextSpan(
                                            text:
                                                "${session!.donationUnit.name}",
                                            style: TextStyle(
                                                fontSize: 22,
                                                fontWeight: FontWeight.w300))
                                    ],
                                    style: textTheme.headline5.copyWith(
                                        fontSize: 38,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          )),
                          YMargin(6),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 6.0),
                            child: Builder(builder: (context) {
                              double width = mq!.size.width - 48 - 24;
                              return Container(
                                width: width,
                                child: PercentLine(
                                  percent: (session!.amount! /
                                          session!.donationGoal!)
                                      .clamp(0.0, 1.0),
                                  height: 10.0,
                                  color: textColor,
                                ),
                              );
                            }),
                          ),
                          YMargin(6.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "${_formatPercent(session!)}% erreicht",
                                style: textTheme.bodyText1,
                              ),
                              RichText(
                                  text: TextSpan(
                                      style: textTheme.bodyText1.copyWith(
                                          fontWeight: FontWeight.w400),
                                      children: [
                                    TextSpan(
                                      text: "Ziel: ",
                                    ),
                                    TextSpan(
                                        text: "${session!.donationGoal} ",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    TextSpan(
                                        text:
                                            "${session!.donationUnit.smiley ?? session!.donationUnit.name}"),
                                  ])),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              );
            })
          ],
        ),
      ),
    );
  }

  String _formatPercent(BaseSession session) {
    double percentValue = (session.amount! / session.donationGoal!) * 100;

    if (percentValue < 1) return percentValue.toStringAsFixed(2);
    if ((percentValue % 1) == 0) return percentValue.toInt().toString();

    return percentValue.toStringAsFixed(1);
  }
}
