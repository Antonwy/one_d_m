import 'package:flutter/material.dart';
import 'package:one_d_m/components/join_button.dart';
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
    return Consumer<UserPageManager>(builder: (context, upm, child) {
      if (upm.isOwnAccount!)
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          ),
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => EditProfile()));
          },
          child: Text(
            'Edit',
          ),
        );

      bool subscribed = upm.subscribed!;

      return JoinButton(
        subscribed: subscribed,
        subscribedString: "Entfolgen",
        notSubscribedString: "Folgen",
        joinOrLeave: _loading || upm.loadingMoreInfo
            ? null
            : (val) async {
                await upm.followOrUnfollowUser(val, context);
              },
      );
    });
  }
}
