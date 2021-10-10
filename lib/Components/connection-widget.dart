import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:one_d_m/components/margin.dart';
import 'package:one_d_m/extensions/theme_extensions.dart';
import 'package:one_d_m/provider/api_manager.dart';
import 'package:provider/provider.dart';

class ConnectionWidget extends StatelessWidget {
  const ConnectionWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ApiManager>(builder: (context, am, child) {
      return OfflineBuilder(
          child: Container(),
          connectivityBuilder: (context, connectivity, child) {
            bool show = connectivity == ConnectivityResult.none;
            double height = MediaQuery.of(context).padding.top + 60;

            String message = "Keine Verbindung zum Internet!";

            if (!am.apiReachable) {
              print("NOW");
              show = true;
              message = "Der Server reagiert nicht. Versuche es später erneut!";
            }

            return AnimatedPositioned(
              duration: Duration(milliseconds: 500),
              curve: Curves.fastLinearToSlowEaseIn,
              top: show ? 0 : -height,
              left: 0,
              right: 0,
              height: height,
              child: Material(
                color: context.theme.errorColor,
                child: Padding(
                    padding: EdgeInsets.fromLTRB(
                        12, MediaQuery.of(context).padding.top, 12, 0),
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: [
                            Icon(Icons.wifi_off, color: Colors.white),
                            XMargin(12),
                            Expanded(
                              child: AutoSizeText(message,
                                  maxLines: 1,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ))),
              ),
            );
          });
    });
  }
}
