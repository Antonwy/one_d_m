import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/Helper/ColorTheme.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/Helper.dart';
import 'package:one_d_m/Helper/User.dart';
import 'package:one_d_m/Helper/UserManager.dart';
import 'package:one_d_m/Pages/UserPage.dart';
import 'package:provider/provider.dart';

import 'AnimatedFutureBuilder.dart';
import 'Avatar.dart';
import 'CustomOpenContainer.dart';

class UserButton extends StatelessWidget {
  String id;
  User user;
  Color color, avatarColor;
  TextStyle textStyle;
  double elevation;
  bool withAddButton;

  UserButton(this.id,
      {this.user,
      this.color = Colors.white,
      this.avatarColor = ColorTheme.blue,
      this.textStyle = const TextStyle(color: Colors.black),
      this.elevation = 1,
      this.withAddButton = false});

  @override
  Widget build(BuildContext context) {
    return AnimatedFutureBuilder<User>(
        future: user == null ? DatabaseService.getUser(id) : Future.value(user),
        builder: (context, snapshot) {
          if (snapshot.hasData)
            return Container(
              key: Key(id),
              height: 60,
              child: CustomOpenContainer(
                openBuilder: (context, close, controller) =>
                    UserPage(snapshot.data, scrollController: controller),
                closedShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                closedElevation: elevation,
                closedColor: color,
                closedBuilder: (context, open) => Material(
                  color: color,
                  child: InkWell(
                    onTap: open,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                            child: Row(
                              children: <Widget>[
                                Avatar(
                                    snapshot.data?.thumbnailUrl ??
                                        snapshot.data.imgUrl,
                                    color: avatarColor),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Container(
                                    height: double.infinity,
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: AutoSizeText(
                                          "${snapshot.data.name ?? "Gelöschter Account"}",
                                          maxLines: 1,
                                          style: TextStyle(
                                              color: textStyle.color,
                                              fontWeight: FontWeight.w500)),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          withAddButton
                              ? Consumer<UserManager>(
                                  builder: (context, um, child) =>
                                      StreamBuilder<bool>(
                                          initialData: false,
                                          stream:
                                              DatabaseService.getFollowStream(
                                                  um.uid, id),
                                          builder: (context, snapshot) {
                                            return IconButton(
                                                icon: TweenAnimationBuilder(
                                                  duration: Duration(
                                                      milliseconds: 250),
                                                  tween: Tween<double>(
                                                      begin: 0,
                                                      end: snapshot.data
                                                          ? 1
                                                          : 0),
                                                  builder:
                                                      (context, tween, child) =>
                                                          Transform.rotate(
                                                    angle: tween *
                                                        Helper.degreesToRads(
                                                            45),
                                                    child: Material(
                                                      shape: CircleBorder(),
                                                      color: ColorTween(
                                                              begin: ColorTheme
                                                                  .orange
                                                                  .withOpacity(
                                                                      .3),
                                                              end: ColorTheme
                                                                  .orange)
                                                          .transform(tween),
                                                      child: Center(
                                                        child: Icon(
                                                          Icons.add,
                                                          color: ColorTween(
                                                                  begin:
                                                                      ColorTheme
                                                                          .orange,
                                                                  end: Colors
                                                                      .white)
                                                              .transform(tween),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                onPressed: () {
                                                  if (snapshot.data)
                                                    DatabaseService
                                                        .deleteFollow(
                                                            um.uid, id);
                                                  else
                                                    DatabaseService
                                                        .createFollow(
                                                            um.uid, id);
                                                });
                                          }),
                                )
                              : Container()
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          return Container(
            key: Key("${id}_loading"),
            height: 60,
            child: Material(
              borderRadius: BorderRadius.circular(5),
              clipBehavior: Clip.antiAlias,
              color: color,
              elevation: elevation,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Avatar(
                          null,
                          color: avatarColor,
                        ),
                        SizedBox(width: 10),
                        AutoSizeText("Laden...",
                            maxLines: 1,
                            style: Theme.of(context)
                                .textTheme
                                .bodyText1
                                .copyWith(color: textStyle.color))
                      ],
                    ),
                    withAddButton
                        ? IconButton(
                            icon: Material(
                                shape: CircleBorder(),
                                color: ColorTheme.whiteBlue,
                                child: Center(
                                    child: Icon(Icons.add,
                                        color: ColorTheme.blue))),
                            onPressed: null)
                        : Container()
                  ],
                ),
              ),
            ),
          );
        });
  }
}
