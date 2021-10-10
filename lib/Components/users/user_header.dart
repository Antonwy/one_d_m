import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:one_d_m/api/api.dart';
import 'package:one_d_m/components/margin.dart';
import 'package:one_d_m/components/users/user_page_follow_button.dart';
import 'package:one_d_m/extensions/theme_extensions.dart';
import 'package:one_d_m/helper/constants.dart';
import 'package:one_d_m/helper/dynamic_link_manager.dart';
import 'package:one_d_m/helper/numeral.dart';
import 'package:one_d_m/models/user.dart';
import 'package:one_d_m/models/user_account.dart';
import 'package:one_d_m/provider/theme_manager.dart';
import 'package:one_d_m/provider/user_page_manager.dart';
import 'package:one_d_m/views/home/profile_page.dart';
import 'package:one_d_m/views/users/followers_list_page.dart';
import 'package:one_d_m/views/users/user_donations_page.dart';
import 'package:provider/provider.dart';
import 'package:social_share/social_share.dart';

class UserHeader extends SliverPersistentHeaderDelegate {
  final int index = 0;
  late ThemeData _theme;
  double _minExtend = 80.0;

  Future<void> _shareUser(BuildContext context) async {
    UserPageManager upm = context.read<UserPageManager>();
    if ((upm.user.name.isEmpty ?? true)) return;
    SocialShare.shareOptions(
        (await DynamicLinkManager.of(context).createUserLink(upm.user))
            .toString());
  }

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    _theme = Theme.of(context);
    _minExtend = MediaQuery.of(context).padding.top + 56.0;
    return LayoutBuilder(builder: (context, constraints) {
      final double percentage =
          (constraints.maxHeight - minExtent) / (maxExtent - minExtent);
      final bool _fullVisible = percentage < 0.5;
      return Container(
        height: constraints.maxHeight,
        child: Material(
          elevation: Tween<double>(begin: 1.0, end: 0.0).transform(percentage),
          child: SafeArea(
            bottom: false,
            child: Stack(
              children: [
                Opacity(
                    opacity: 1 - percentage,
                    child: IgnorePointer(
                      ignoring: !_fullVisible,
                      child: Container(
                          height: constraints.maxHeight,
                          width: constraints.maxWidth,
                          child: SafeArea(
                              bottom: false,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildUserImage(context, size: Size(35, 35)),
                                  XMargin(12),
                                  Consumer<UserPageManager>(
                                      builder: (context, upm, child) {
                                    return Text(
                                      "${upm.user.name}",
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600),
                                    );
                                  }),
                                  XMargin(12),
                                  SizedBox(
                                      height: 35, child: UserPageFollowButton())
                                ],
                              ))),
                    )),
                Wrap(
                  alignment: WrapAlignment.center,
                  children: <Widget>[
                    AppBar(
                      backgroundColor: Colors.transparent,
                      iconTheme: _theme.iconTheme,
                      elevation: 0,
                      actions: [
                        Center(
                          child: AppBarButton(
                            onPressed: () => _shareUser(context),
                            color: _theme.canvasColor,
                            icon: CupertinoIcons.share,
                          ),
                        ),
                        XMargin(12)
                      ],
                    ),
                    IgnorePointer(
                      ignoring: _fullVisible,
                      child: Opacity(
                        opacity: percentage,
                        child: Transform.translate(
                          offset: Tween<Offset>(
                                  begin: Offset(0, _minExtend - maxExtent),
                                  end: Offset.zero)
                              .transform(percentage),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              _buildUserImage(context),
                              const XMargin(15),
                              Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Consumer<UserPageManager>(
                                    builder: (context, upm, child) => Text(
                                      "${upm.user.name ?? "Gelöschter Account"}",
                                      style: TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                  const YMargin(10),
                                  UserPageFollowButton()
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    Opacity(
                      opacity: percentage,
                      child: Transform.translate(
                        offset: Tween<Offset>(
                                begin: Offset(0, _minExtend - maxExtent),
                                end: Offset.zero)
                            .transform(percentage),
                        child: Container(
                          margin: const EdgeInsets.only(top: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              _waitForLoadedColumn(
                                  text: "Abonnenten",
                                  context: context,
                                  clickable: (ua) => ua!.followedCount > 0,
                                  usersFuture: (uid) =>
                                      Api().account().followed(uid!),
                                  callback: (ua) =>
                                      ua!.followedCount.toString()),
                              Material(
                                borderRadius: BorderRadius.circular(5),
                                clipBehavior: Clip.antiAlias,
                                color: Colors.transparent,
                                child: Consumer<UserPageManager>(
                                  builder: (context, upm, child) => InkWell(
                                    onTap: (upm.userAccount?.donatedAmount ==
                                                    null
                                                ? 0
                                                : upm.userAccount!
                                                    .donatedAmount) >
                                            0
                                        ? () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (c) =>
                                                        UsersDonationsPage(
                                                            upm.userAccount)));
                                          }
                                        : null,
                                    child: _textNumberColumn(
                                        text: "Unterstützt",
                                        number:
                                            "${Numeral(upm.userAccount?.donatedAmount ?? 0).value()} DV"),
                                  ),
                                ),
                              ),
                              _waitForLoadedColumn(
                                  text: "Abonniert",
                                  context: context,
                                  clickable: (ua) => ua!.followingCount > 0,
                                  usersFuture: (uid) =>
                                      Api().account().following(uid!),
                                  callback: (ua) =>
                                      ua!.followingCount.toString())
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildUserImage(BuildContext context,
          {Size size = const Size(88, 88)}) =>
      Container(
        height: size.height,
        width: size.width,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Constants.radius),
        ),
        child: Consumer<UserPageManager>(
          builder: (context, upm, child) => CachedNetworkImage(
            imageUrl: upm.user.imgUrl ?? '',
            imageBuilder: (context, imageProvider) => Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: imageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            errorWidget: (_, __, ___) => Container(
              height: size.height,
              width: size.width,
              decoration: BoxDecoration(
                color: context.theme.primaryColor,
              ),
              child: Center(
                  child: Icon(
                Icons.person,
                color: context.theme.colorScheme.onPrimary,
              )),
            ),
            placeholder: (_, __) => Container(
              height: size.height,
              width: size.width,
              child: upm.user.blurHash == null
                  ? Center(
                      child: CircularProgressIndicator(
                        color: context.theme.primaryColor,
                      ),
                    )
                  : BlurHash(hash: upm.user.blurHash!),
            ),
          ),
        ),
      );

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate _) => true;

  @override
  double get maxExtent => 270.0;

  @override
  double get minExtent => _minExtend;

  Widget _waitForLoadedColumn(
      {String? text,
      BuildContext? context,
      Future<List<User?>> Function(String? uid)? usersFuture,
      bool Function(UserAccount? ua)? clickable,
      String Function(UserAccount? ua)? callback}) {
    return Consumer<UserPageManager>(
      builder: (context, upm, child) => Material(
        color: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        borderRadius: BorderRadius.circular(5),
        child: InkWell(
          onTap: !upm.loadingMoreInfo! && clickable!(upm.userAccount)
              ? () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (c) => FollowersListPage(
                                title: text,
                                usersFuture: usersFuture!(upm.user.id),
                              )));
                }
              : null,
          child: _textNumberColumn(
              number: upm.loadingMoreInfo! ? "0" : callback!(upm.userAccount),
              text: text!),
        ),
      ),
    );
  }

  Widget _textNumberColumn(
      {required String text,
      String? number,
      CrossAxisAlignment alignment = CrossAxisAlignment.center}) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          AutoSizeText(
            number.toString(),
            maxLines: 1,
            style: _theme.textTheme.headline6!
                .copyWith(fontWeight: FontWeight.w700, fontSize: 20),
          ),
          const YMargin(4),
          Text(
            text,
            style: _theme.textTheme.bodyText1!
                .copyWith(fontWeight: FontWeight.w400, fontSize: 14),
          )
        ],
      ),
    );
  }
}
