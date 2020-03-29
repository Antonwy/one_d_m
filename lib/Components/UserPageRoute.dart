import 'package:flutter/material.dart';
import 'package:one_d_m/Helper/User.dart';
import 'package:one_d_m/Pages/UserPage.dart';

class UserPageRoute extends PageRouteBuilder {

  UserPageRoute(User user) : super(
    opaque: false,
    pageBuilder: (c, a1, a2) => UserPage(user),
    transitionDuration: Duration.zero
  );

}