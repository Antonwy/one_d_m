import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:one_d_m/api/api.dart';
import 'package:one_d_m/components/loading_indicator.dart';
import 'package:one_d_m/components/margin.dart';
import 'package:one_d_m/models/donation_request.dart';
import 'package:one_d_m/provider/donation_dialog_manager.dart';
import 'package:one_d_m/provider/theme_manager.dart';
import 'package:one_d_m/views/donations/donation_dialog.dart';
import 'package:provider/provider.dart';

import 'donation_dialog_animation.dart';

class DonationDialogHolder extends StatefulWidget {
  final String campaignId, sessionId;
  final List<String> donationEffects;

  DonationDialogHolder({this.campaignId, this.sessionId, this.donationEffects});

  @override
  _DonationDialogHolderState createState() => _DonationDialogHolderState();
}

class _DonationDialogHolderState extends State<DonationDialogHolder>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    ThemeManager _theme = ThemeManager.of(context);
    return OfflineBuilder(
        child: Container(),
        connectivityBuilder: (context, connectivity, child) {
          bool noConnection = connectivity == ConnectivityResult.none;
          return ChangeNotifierProvider<DonationDialogManager>(
              create: (context) => DonationDialogManager(
                  context: context,
                  campaignId: widget.campaignId,
                  sessionId: widget.sessionId,
                  noConnection: noConnection),
              builder: (context, snapshot) {
                DonationDialogManager ddm =
                    context.watch<DonationDialogManager>();
                return AnimatedSize(
                    vsync: this,
                    duration: Duration(milliseconds: 1000),
                    curve: Curves.fastLinearToSlowEaseIn,
                    alignment: Alignment.topCenter,
                    child: AnimatedOpacity(
                        opacity: ddm.opacity,
                        duration: Duration(milliseconds: 250),
                        child: Builder(builder: (context) {
                          if (ddm.initialLoading || noConnection)
                            return Container(
                              height: (widget.donationEffects?.isEmpty ?? true)
                                  ? 450
                                  : 500,
                              child: Center(
                                  child: noConnection
                                      ? _NoConnection()
                                      : LoadingIndicator(
                                          message:
                                              "Wir bereiten deine Spende vor...🙃😎",
                                        )),
                            );

                          if (ddm.showAnimation)
                            return Container(
                                height:
                                    MediaQuery.of(context).size.height * .95,
                                child: DonationAnimationWidget());

                          return Container(
                              height: (ddm.dr?.donationEffects?.isEmpty ?? true)
                                  ? 450
                                  : 500,
                              child: DonationDialog());
                        })));
              });
        });
  }
}

class _NoConnection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ThemeManager _theme = ThemeManager.of(context);
    return Container(
      height: 250,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Material(
              shape: CircleBorder(),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Icon(Icons.warning, color: Colors.red),
              ),
              color: Colors.red.withOpacity(.1)),
          YMargin(18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
                "Zum Unterstützen brauchst du eine funktionierende Internetverbindung!",
                textAlign: TextAlign.center,
                style: _theme.textTheme.dark.bodyText2),
          ),
          YMargin(12),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                  primary: ThemeManager.of(context).colors.dark),
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("ABBRECHEN"))
        ],
      ),
    );
  }
}
