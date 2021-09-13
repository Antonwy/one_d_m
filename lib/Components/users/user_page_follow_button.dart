import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:one_d_m/components/loading_indicator.dart';
import 'package:one_d_m/helper/color_theme.dart';
import 'package:one_d_m/helper/helper.dart';
import 'package:one_d_m/provider/theme_manager.dart';
import 'package:one_d_m/provider/user_page_manager.dart';
import 'package:one_d_m/views/users/edit_profile_page.dart';
import 'package:provider/provider.dart';

class UserPageFollowButton extends StatefulWidget {
  @override
  _UserPageFollowButtonState createState() => _UserPageFollowButtonState();
}

class _UserPageFollowButtonState extends State<UserPageFollowButton> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    ThemeManager _theme = ThemeManager.of(context);
    return Consumer<UserPageManager>(builder: (context, upm, child) {
      if (upm.user?.name == null) return Container();
      if (upm.isOwnAccount)
        return OfflineBuilder(
            child: Container(),
            connectivityBuilder: (context, connection, child) {
              if (connection == ConnectivityResult.none)
                return FloatingActionButton(
                  onPressed: () {
                    Helper.showConnectionSnackBar(context);
                  },
                  child: Icon(
                    Icons.signal_wifi_off,
                    color: ColorTheme.orange,
                  ),
                  backgroundColor: ColorTheme.whiteBlue,
                );
              return RaisedButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6)),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => EditProfile()));
                },
                child: Center(
                  child: Text(
                    'Edit',
                    style: TextStyle(color: _theme.colors.dark),
                  ),
                ),
              );
            });

      bool subscribed = upm.subscribed;
      Color textColor =
          subscribed ? _theme.colors.textOnDark : _theme.colors.textOnContrast;

      return Container(
        width: 100,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6)),
              primary: subscribed ? _theme.colors.dark : _theme.colors.contrast,
              elevation: subscribed ? 12 : 0),
          onPressed: _loading || upm.loadingMoreInfo
              ? null
              : () async {
                  setState(() {
                    _loading = true;
                  });
                  await upm.followOrUnfollowUser(!subscribed, context);
                  setState(() {
                    _loading = false;
                  });
                },
          child: Center(
            child: _loading
                ? Container(
                    width: 15,
                    height: 15,
                    child: LoadingIndicator(strokeWidth: 2, color: textColor))
                : Text(
                    subscribed ? 'Entfolgen' : 'Folgen',
                    style: TextStyle(color: textColor),
                  ),
          ),
        ),
      );
    });
  }
}
