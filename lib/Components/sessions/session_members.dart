import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/components/custom_open_container.dart';
import 'package:one_d_m/components/donation_widget.dart';
import 'package:one_d_m/components/margin.dart';
import 'package:one_d_m/components/user_follow_button.dart';
import 'package:one_d_m/helper/color_theme.dart';
import 'package:one_d_m/helper/constants.dart';
import 'package:one_d_m/helper/numeral.dart';
import 'package:one_d_m/models/session_models/session.dart';
import 'package:one_d_m/models/session_models/session_member.dart';
import 'package:one_d_m/models/user.dart';
import 'package:one_d_m/provider/sessions_manager.dart';
import 'package:one_d_m/provider/theme_manager.dart';
import 'package:one_d_m/views/users/user_page.dart';
import 'package:provider/provider.dart';

class SessionMembers extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ThemeManager _theme = ThemeManager.of(context);
    return SliverToBoxAdapter(
      child: Consumer<BaseSessionManager>(
        builder: (context, sm, child) => Builder(builder: (context) {
          Session session = sm.session;
          List<SessionMember> members =
              !sm.loadingMoreInfo ? session.members : [];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              members.isEmpty
                  ? SizedBox.shrink()
                  : Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 6),
                      child: Text(
                        "Unterstützer",
                        style: _theme.textTheme.dark.bodyText1,
                      ),
                    ),
              SizedBox(
                  height: 155,
                  child: Builder(builder: (context) {
                    if (members.isNotEmpty) {
                      return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: members.length,
                          itemBuilder: (context, index) => Padding(
                                padding: EdgeInsets.only(
                                    left: index == 0 ? 6.0 : 0.0,
                                    right: index == members.length - 1
                                        ? 6.0
                                        : 0.0),
                                child: SessionMemberView(
                                    member: members[index],
                                    showTargetAmount: true,
                                    color: sm.baseSession?.primaryColor ??
                                        _theme.colors.dark,
                                    avatarColor: Colors.white,
                                    avatarBackColor:
                                        sm.baseSession.secondaryColor,
                                    donationUnit:
                                        session.donationUnit.name ?? "DV",
                                    dvController:
                                        session.donationUnit.value ?? 1),
                              ));
                    } else {
                      return SizedBox.shrink();
                    }
                  })),
            ],
          );
        }),
      ),
    );
  }
}

class SessionMemberView extends StatelessWidget {
  final SessionMember member;
  final bool invited, showTargetAmount, showFollowButton, clickable;
  final Color color, avatarColor, avatarBackColor;
  final String donationUnit;
  final int dvController;
  ThemeManager _theme;

  SessionMemberView(
      {Key key,
      this.member,
      this.color = ColorTheme.wildGreen,
      this.avatarColor,
      this.avatarBackColor,
      this.invited = false,
      this.showTargetAmount = true,
      this.showFollowButton = true,
      this.donationUnit = "DV",
      this.dvController = 1,
      this.clickable = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    _theme = ThemeManager.of(context);
    return Consumer<BaseSessionManager>(
      builder: (context, sm, child) => Opacity(
          opacity: invited ? .3 : 1.0,
          child: Container(
            width: showFollowButton ? 108 : 90,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: CustomOpenContainer(
                openBuilder: (context, close, scrollController) => UserPage(
                  User(
                    name: member.name,
                    imgUrl: member.imageUrl,
                    thumbnailUrl: member.thumbnailUrl,
                    blurHash: member.blurHash,
                  ),
                  scrollController: scrollController,
                ),
                tappable: clickable,
                closedElevation: 0,
                closedColor: color.withOpacity(.45),
                closedShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(Constants.radius)),
                closedBuilder: (context, open) => Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      RoundedAvatar(
                        member?.imageUrl,
                        blurHash: member?.blurHash,
                        color: _theme.colors.dark,
                        iconColor: _theme.colors.contrast,
                        height: 30,
                        name: member?.name,
                      ),
                      YMargin(6),
                      Container(
                        width: 76,
                        height: 25,
                        child: Center(
                          child: AutoSizeText(
                              "${member?.name ?? 'Laden...'}\n${Numeral(((member?.donatedAmount ?? 0) / dvController).round()).value()} $donationUnit",
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              style: TextStyle(
                                  color: _theme.correctColorFor(color),
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                      if (showFollowButton) YMargin(6),
                      if (showFollowButton)
                        UserFollowButton(
                            followerId: member?.id,
                            color: color,
                            textColor: _theme.correctColorFor(color),
                            backOpacity: .5),
                    ],
                  ),
                ),
              ),
            ),
          )),
    );
  }
}
