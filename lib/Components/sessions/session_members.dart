import 'package:flutter/material.dart';
import 'package:one_d_m/components/margin.dart';
import 'package:one_d_m/components/users/vertical_user_button.dart';
import 'package:one_d_m/helper/color_theme.dart';
import 'package:one_d_m/helper/numeral.dart';
import 'package:one_d_m/models/donation_unit.dart';
import 'package:one_d_m/models/session_models/session.dart';
import 'package:one_d_m/models/session_models/session_member.dart';
import 'package:one_d_m/models/user.dart';
import 'package:one_d_m/provider/sessions_manager.dart';
import 'package:provider/provider.dart';

class SessionMembers extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ThemeData _theme = Theme.of(context);
    return SliverToBoxAdapter(
      child: Consumer<BaseSessionManager>(
        builder: (context, sm, child) => Builder(builder: (context) {
          Session? session = sm.session;
          List<SessionMember> members =
              !sm.loadingMoreInfo! ? session!.members : [];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              members.isEmpty
                  ? SizedBox.shrink()
                  : Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 6),
                      child: Text(
                        "Unterstützer (${Numeral(sm.session?.memberCount ?? 0).value()})",
                        style: _theme.textTheme.bodyText1,
                      ),
                    ),
              SizedBox(
                  height: 140,
                  child: Builder(builder: (context) {
                    if (members.isNotEmpty) {
                      return ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: members.length,
                          separatorBuilder: (context, index) => XMargin(6),
                          itemBuilder: (context, index) => Padding(
                                padding: EdgeInsets.only(
                                    left: index == 0 ? 12.0 : 0.0,
                                    right: index == members.length - 1
                                        ? 12.0
                                        : 0.0,
                                    bottom: 4),
                                child: SessionMemberView(
                                    member: members[index],
                                    showTargetAmount: true,
                                    color: sm.baseSession?.secondaryColor ??
                                        _theme.primaryColor,
                                    donationUnit: session!.donationUnit.name,
                                    dvController: session.donationUnit.value),
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
  final Color? color, avatarColor, avatarBackColor;
  final String donationUnit;
  final int dvController;
  late final ThemeData _theme;

  SessionMemberView(
      {Key? key,
      required this.member,
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
    _theme = Theme.of(context);

    return Consumer<BaseSessionManager>(builder: (context, bsm, child) {
      String unit() {
        DonationUnit unit = bsm.baseSession!.donationUnit;

        if (unit.smiley != null) return unit.smiley!;

        if (member.donatedAmount == 1) return unit.singular;

        return unit.name;
      }

      return VerticalUserButton(
        User(
          id: member.id!,
          name: member.name!,
          imgUrl: member.thumbnailUrl ?? member.imageUrl,
          thumbnailUrl: member.thumbnailUrl,
          blurHash: member.blurHash,
        ),
        additionalText:
            "${Numeral(member.donatedAmount! / (bsm.baseSession?.donationUnit.value ?? 1)).value()} ${unit()}",
        avatarColor: bsm.baseSession!.primaryColor,
        followButtonColor: bsm.baseSession!.secondaryColor,
        backgroundColor: _theme.canvasColor,
      );
    });
  }
}
