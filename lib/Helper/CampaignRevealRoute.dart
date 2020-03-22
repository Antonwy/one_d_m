import 'package:flutter/material.dart';
import 'package:one_d_m/Helper/Helper.dart';

class CampaignRevealRoute extends PageRouteBuilder {
  GlobalKey widgetKey;
  Widget page;

  CampaignRevealRoute({this.widgetKey, this.page})
      : super(
            opaque: true,
            pageBuilder: (context, firstAnim, secAnim) => page,
            transitionDuration: Duration(milliseconds: 500),
            transitionsBuilder: (context, firstAnim, secondAnim, child) {
              Offset cardPos = Helper.getCenteredPositionFromKey(widgetKey);
              Size cardSize = Helper.getSizeFromKey(widgetKey);

              print(firstAnim.value);

              return LayoutBuilder(builder: (context, constraints) {
                return Container(
                  width: Tween<double>(
                          begin: cardSize.width, end: constraints.maxWidth)
                      .animate(firstAnim)
                      .value,
                  height: Tween<double>(begin: cardSize.height, end: 200)
                      .animate(firstAnim)
                      .value,
                  child: (Card(
                    color: Colors.red,
                    child: child,
                  )),
                );
              });
            });
}
