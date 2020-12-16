import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_xlider/flutter_xlider.dart';
import 'package:one_d_m/Components/Avatar.dart';
import 'package:one_d_m/Helper/Campaign.dart';
import 'package:one_d_m/Helper/ColorTheme.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/Donation.dart';
import 'package:one_d_m/Helper/DonationDialogManager.dart';
import 'package:one_d_m/Helper/Helper.dart';
import 'package:one_d_m/Helper/ThemeManager.dart';
import 'package:one_d_m/Helper/User.dart';
import 'package:one_d_m/Helper/UserManager.dart';
import 'package:one_d_m/Pages/PaymentInfosPage.dart';
import 'package:provider/provider.dart';

class DonationDialogWidget extends StatefulWidget {
  final Function close;
  final Campaign campaign;
  final User user;
  final BuildContext context;
  int defaultSelectedAmount;
  final String sessionId;

  DonationDialogWidget(
      {this.close,
      this.campaign,
      this.user,
      this.context,
      this.sessionId,
      this.defaultSelectedAmount = 0});

  @override
  _DonationDialogWidgetState createState() => _DonationDialogWidgetState();
}

class _DonationDialogWidgetState extends State<DonationDialogWidget>
    with SingleTickerProviderStateMixin {
  ThemeData _theme;
  BaseTheme _bTheme;
  FocusScopeNode _keyboardFocus = FocusScopeNode();
  double _selectedValue = 0;

  @override
  void initState() {
    _selectedValue = widget.defaultSelectedAmount.toDouble();
    DatabaseService.getAdBalance(widget.user.id).listen((event) {
      if (event.dcBalance < _selectedValue) {
        _selectedValue = 0;
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _theme = Theme.of(context);
    _bTheme = ThemeManager.of(context).colors;

    return ChangeNotifierProvider<DonationDialogManager>(
        create: (context) => DonationDialogManager(
            adBalanceStream: DatabaseService.getAdBalance(widget.user.id),
            defaultSelectedAmount: widget.defaultSelectedAmount,
            sessionId: widget.sessionId,
            campaign: widget.campaign),
        child: Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: Colors.transparent,
            body: Container(
                color: Colors.transparent,
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Consumer2<DonationDialogManager, UserManager>(
                    builder: (context, ddm, um, child) {
                  if (um.user.ghost) ddm.setAnonymWithoutRebuild(true);
                  return Stack(
                    children: <Widget>[
                      Positioned.fill(
                          child: GestureDetector(
                        onTap: widget.close,
                      )),
                      AnimatedPositioned(
                        duration: Duration(milliseconds: 250),
                        curve: Curves.easeOut,
                        bottom: MediaQuery.of(context).viewInsets.bottom,
                        left: 0,
                        right: 0,
                        child: Stack(
                          children: <Widget>[
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Material(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(20),
                                    topRight: Radius.circular(20)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Align(
                                        alignment: Alignment.center,
                                        child: AutoSizeText(
                                          "Donate",
                                          style: _theme.textTheme.headline4
                                              .copyWith(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold),
                                        )),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        InfoCardWidget(
                                          isDark: true,
                                          childWidget: _buildWWFContent(),
                                        ),
                                        InfoCardWidget(
                                          isDark: true,
                                          childWidget: _buildDVBalanceCard(ddm
                                              .adBalance.dcBalance
                                              .toString()),
                                        )
                                      ],
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Align(
                                        alignment: Alignment.center,
                                        child: Text(
                                          _selectedValue.toInt().toString(),
                                          style: _theme.textTheme.headline4
                                              .copyWith(
                                                  fontWeight: FontWeight.bold),
                                        )),
                                    Align(
                                        alignment: Alignment.center,
                                        child: Text(
                                          'DV selected',
                                          style: _theme.textTheme.headline4
                                              .copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16),
                                        )),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    //dv slider
                                    Flexible(
                                      child: FlutterSlider(
                                        min: 0,
                                        max: ddm.adBalance.dcBalance.toDouble(),
                                        values: [_selectedValue],
                                        onDragging: (handlerIndex, lowerValue,
                                            upperValue) {
                                          _selectedValue = lowerValue;
                                          setState(() {
                                            ddm.amount = _selectedValue.toInt();
                                          });
                                        },
                                        tooltip: FlutterSliderTooltip(
                                          disabled: true
                                        ),
                                        handler: FlutterSliderHandler(
                                          decoration: BoxDecoration(),
                                          child: Material(
                                            type: MaterialType.circle,
                                            color: _bTheme.dark,
                                            elevation: 3,
                                            child: Container(
                                                padding: EdgeInsets.all(5),
                                                child: Icon(Icons.adjust_sharp, size: 25,color: _bTheme.contrast,)),
                                          ),
                                        ),
                                        trackBar: FlutterSliderTrackBar(
                                          activeTrackBarHeight: 16,
                                          inactiveTrackBarHeight: 16,
                                          inactiveTrackBar: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            color: _bTheme.contrast,
                                          ),
                                          activeTrackBar: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              color: _bTheme.dark),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Align(
                                      alignment: Alignment.center,
                                      child: DonationButton(
                                        keyboardFocus: _keyboardFocus,
                                        campaign: widget.campaign,
                                        user: widget.user,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10 +
                                          MediaQuery.of(context).padding.bottom,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            ThankYouWidget(),
                            Positioned(
                                top: 20,
                                right: 20,
                                child: AnimatedOpacity(
                                    duration: Duration(milliseconds: 250),
                                    opacity: ddm.showThankYou ? 1 : 0,
                                    child: _closeButton()))
                          ],
                        ),
                      ),
                    ],
                  );
                }))));
  }

  Widget _buildWWFContent() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.white,
            child: Image.asset(
              "assets/icons/ic_wwf.png",
              width: 37,
              height: 38,
            ),
          ),
          SizedBox(
            width: 5,
          ),
          Text(
            "WWF",
            style: _theme.textTheme.headline5
                .copyWith(color: Colors.white, fontWeight: FontWeight.bold),
          )
        ],
      );

  Widget _buildDVBalanceCard(String dv) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "DV balance",
            style: _theme.textTheme.bodyText1
                .copyWith(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          Text(
            "$dv DV",
            style: _theme.textTheme.headline6
                .copyWith(color: Colors.white, fontWeight: FontWeight.bold),
          )
        ],
      );

  Widget _closeButton() {
    return Container(
      height: 35,
      width: 35,
      child: Material(
        color: Colors.grey[300],
        shape: CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: widget.close,
          child: Center(
            child: Icon(
              Icons.close,
              color: Colors.grey[700],
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}

class InfoCardWidget extends StatelessWidget {
  final Widget childWidget;
  final bool isDark;

  const InfoCardWidget({Key key, this.childWidget, this.isDark})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    BaseTheme _bTheme = ThemeManager.of(context).colors;
    return Container(
      height: 70,
      width: 158,
      margin: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 0,
        color: isDark ? _bTheme.dark : _bTheme.contrast,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: childWidget,
        ),
      ),
    );
  }
}

class DonationButton extends StatelessWidget {
  ThemeData _theme;
  BaseTheme _bTheme;
  DonationDialogManager ddm;
  BuildContext context;

  Campaign campaign;
  FocusScopeNode keyboardFocus;
  User user;

  DonationButton({this.campaign, this.keyboardFocus, this.user});

  @override
  Widget build(BuildContext context) {
    _theme = Theme.of(context);
    _bTheme = ThemeManager.of(context).colors;
    ddm = Provider.of<DonationDialogManager>(context);
    this.context = context;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.0),
      child: OfflineBuilder(
          child: Container(),
          connectivityBuilder: (c, connection, child) {
            bool connected = connection != ConnectivityResult.none;
            return MaterialButton(
              minWidth: 170,
              height: 50,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              elevation: 0,
              color: const Color(0xFF8CB369),
              disabledColor: Colors.grey,
              onPressed: ddm.amount != null &&
                      ddm.amount != 0 &&
                      ddm.amount <= ddm.adBalance.dcBalance
                  ? connected
                      ? _donate
                      : () {
                          Helper.showConnectionSnackBar(context);
                        }
                  : null,
              child: ddm.loading
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Support!",
                          style: _theme.accentTextTheme.button.copyWith(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Image.asset(
                          "assets/icons/ic_support.png",
                          width: 27,
                          height: 27,
                        )
                      ],
                    ),
            );
          }),
    );
  }

  _donate() async {
    if (!ddm.hasPaymentMethod && ddm.amount > ddm.adBalance.dcBalance) {
      return showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Zu wenig DVs"),
          content: Text(
              "Du hast zu wenig DVs um diese Spende durchzuführen! Füge eine Zahlungsmethode hinzu."),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          actions: <Widget>[
            FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                textColor: _bTheme.dark,
                child: Text("OK")),
          ],
        ),
      );
    }

    Donation donation = Donation(ddm.amount,
        campaignId: campaign.id,
        alternativeCampaignId: campaign.id,
        campaignImgUrl: campaign.imgUrl,
        userId: user.id,
        campaignName: campaign.name,
        anonym: ddm.anonym,
        useDCs: ddm.useDCs,
        sessionId: ddm.sessionId);

    if (ddm.amount >= 100) {
      bool res = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
                title: Text("Bist du dir sicher?"),
                content: Text(
                    "Willst du wirklich ${ddm.amount} DV zum unterstützen ausgeben?"),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                actions: <Widget>[
                  FlatButton(
                      onPressed: () {
                        Navigator.pop(context, false);
                      },
                      textColor: _bTheme.contrast,
                      child: Text("ABBRECHEN")),
                  FlatButton(
                      onPressed: () {
                        Navigator.pop(context, true);
                      },
                      textColor: _bTheme.dark,
                      child: Text("UNTERSTÜTZEN")),
                ],
              ));
      if (!res) return;
    }

    ddm.loading = true;

    await DatabaseService.donate(donation);

    ddm.setLoadingWithoutRebuild(false);
    ddm.showThankYou = true;

    if (keyboardFocus.hasPrimaryFocus) keyboardFocus.unfocus();
  }
}

class ThankYouWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ThemeData _theme = Theme.of(context);
    return Consumer<DonationDialogManager>(builder: (context, ddm, child) {
      return Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          top: 0,
          child: IgnorePointer(
            ignoring: !ddm.showThankYou,
            child: AnimatedOpacity(
              opacity: ddm.showThankYou ? 1 : 0,
              duration: Duration(milliseconds: 250),
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SvgPicture.asset(
                      "assets/images/thank-you.svg",
                      width: 300,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      "Wir werden \"${ddm.campaign.name}\" unterstützen!",
                      style: _theme.textTheme.headline6,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).padding.bottom,
                    )
                  ],
                ),
              ),
            ),
          ));
    });
  }
}

class AnonymDCCheckboxWidget extends StatelessWidget {
  ThemeManager _theme;

  @override
  Widget build(BuildContext context) {
    _theme = ThemeManager.of(context);
    return Consumer2<UserManager, DonationDialogManager>(
      builder: (context, um, ddm, child) {
        if (um.user.ghost) return Container();
        return Theme(
          data: ThemeData(accentColor: _theme.colors.contrast),
          child: CheckboxListTile(
            checkColor: _theme.colors.textOnContrast,
            value: ddm.anonym,
            onChanged: (val) => ddm.anonym = val,
            title: Text("Anonym?"),
            subtitle: Text(
                "Wenn aktiviert, wird diese Unterstützung nicht in deinem Profil angezeigt."),
          ),
        );
      },
    );
    // return Consumer2<UserManager, DonationDialogManager>(
    //     builder: (context, um, ddm, child) {
    //   return Container(
    //     height: 130,
    //     child: Row(
    //       crossAxisAlignment: CrossAxisAlignment.stretch,
    //       children: [
    //         !um.user.ghost
    //             ? Expanded(
    //                 child: _checkBox(
    //                     selected: ddm.anonym,
    //                     onChange: (value) {
    //                       ddm.anonym = value;
    //                     },
    //                     title: Text(
    //                       "Anonym spenden?",
    //                       style:
    //                           _theme.textTheme.bodyText1.copyWith(fontSize: 16),
    //                     ),
    //                     subtitle:
    //                         "Wenn aktiviert, wird diese Spende nicht in deinem Profil angezeigt",
    //                     margin: EdgeInsets.only(left: 20)),
    //               )
    //             : Container(),
    //         ddm.adBalance.dcBalance == 0
    //             ? SizedBox(
    //                 width: 20,
    //               )
    //             : Expanded(
    //                 child: _checkBox(
    //                     selected: ddm.useDCs,
    //                     onChange: (value) {
    //                       ddm.useDCs = value;
    //                     },
    //                     title: RichText(
    //                         text: TextSpan(
    //                             style: _theme.textTheme.bodyText2
    //                                 .copyWith(fontSize: 16),
    //                             children: [
    //                           TextSpan(
    //                               text:
    //                                   "${min(ddm.adBalance.dcBalance, ddm.amount)} DC ",
    //                               style: _theme.textTheme.headline6),
    //                           TextSpan(
    //                               text:
    //                                   ddm.hasPaymentMethod ? "verwenden?" : ""),
    //                         ])),
    //                     subtitle: ddm.hasPaymentMethod
    //                         ? "Sollen wir ${min(ddm.adBalance.dcBalance, ddm.amount)} DC von den von ihnen angesammelten ${ddm.adBalance.dcBalance} DC für diese Spende nutzen?"
    //                         : "Du zahlst mit deinen gesammelten DCs.",
    //                     margin: EdgeInsets.only(
    //                         right: 20, left: um.user.ghost ? 20 : 10)),
    //               )
    //       ],
    //     ),
    //   );
    // });
  }

  Widget _checkBox(
      {Widget title,
      String subtitle,
      EdgeInsetsGeometry margin,
      bool selected,
      Function(bool) onChange}) {
    return Card(
      color: selected ? _theme.colors.contrast : Colors.white,
      elevation: selected ? 2 : 0,
      margin: margin,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: () {
          onChange(!selected);
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              title,
              SizedBox(
                height: 12,
              ),
              Expanded(child: AutoSizeText(subtitle))
            ],
          ),
        ),
      ),
    );
  }
}

class AlternativeCampaignWidget extends StatelessWidget {
  ThemeData _theme;
  BaseTheme _bTheme;
  Campaign campaign;

  AlternativeCampaignWidget(this.campaign);

  @override
  Widget build(BuildContext context) {
    _theme = Theme.of(context);
    _bTheme = ThemeManager.of(context).colors;

    return Consumer<DonationDialogManager>(builder: (context, ddm, child) {
      return FutureBuilder<List<Campaign>>(
          future: _getPossibleCampaigns(context),
          builder: (context, snapshot) {
            List<Campaign> campaigns = [];
            if (snapshot.hasData) {
              campaigns = snapshot.data;
              campaigns.removeWhere((c) => c.id == campaign.id);
              if (ddm.alternativCampaign == null)
                ddm.setAlternativCampaignWithoutRebuild(campaigns[0]);
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "Alternatives Projekt: ",
                              style: _theme.textTheme.headline6,
                            ),
                            AutoSizeText(
                              "Wähle ein Projekt an das wir alternativ unterstützen können.",
                              maxLines: 1,
                              style: _theme.textTheme.caption,
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          _showAlternativeProjectDialog(context);
                        },
                        child: Icon(
                          Icons.info,
                          size: 18,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        bool selected =
                            ddm.alternativCampaign?.id == campaigns[index].id;
                        return Center(
                          child: Container(
                            height: 80,
                            margin: index == 0
                                ? EdgeInsets.only(left: 12)
                                : index == campaigns.length - 1
                                    ? EdgeInsets.only(right: 12)
                                    : null,
                            child: Card(
                              margin: EdgeInsets.fromLTRB(0, 2, 12, 2),
                              elevation: selected ? 2 : 0,
                              color: selected ? _bTheme.contrast : Colors.white,
                              clipBehavior: Clip.antiAlias,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              child: InkWell(
                                onTap: () {
                                  ddm.alternativCampaign = campaigns[index];
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15.0, vertical: 8),
                                  child: Row(
                                    children: <Widget>[
                                      Avatar(campaigns[index].thumbnailUrl ??
                                          campaigns[index].imgUrl),
                                      SizedBox(width: 10),
                                      Text(
                                        "${campaigns[index].name}",
                                        style: _theme.textTheme.headline6
                                            .copyWith(
                                                color: selected
                                                    ? _bTheme.textOnContrast
                                                    : _bTheme.dark),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      itemCount: campaigns.length,
                    )),
              ],
            );
          });
    });
  }

  _showAlternativeProjectDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("Alternatives Projekt"),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              content: Text(
                  "Wir unterstützen deine alternative Auswahl, sollte es eine Problem bei der Organisation oder bei der Überweisung geben.\nWir geben unser bestes in Allen Fällen deine erste Wahl zu erfüllen!"),
              actions: [
                FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Schließen"),
                  textColor: _bTheme.dark,
                )
              ],
            ));
  }

  Future<List<Campaign>> _getPossibleCampaigns(BuildContext context) async {
    UserManager um = Provider.of<UserManager>(context, listen: false);
    List<Campaign> possibleCampaigns =
        await DatabaseService.getSubscribedCampaigns(um.uid);
    possibleCampaigns.removeWhere((c) => c.id == campaign.id);
    if (possibleCampaigns.isEmpty)
      possibleCampaigns = await DatabaseService.getTopCampaigns();

    return possibleCampaigns;
  }
}

class CustomAmountWidget extends StatelessWidget {
  FocusScopeNode keyboardFocus = FocusScopeNode();

  CustomAmountWidget(this.keyboardFocus);

  @override
  Widget build(BuildContext context) {
    return Consumer<DonationDialogManager>(builder: (context, ddm, child) {
      return AnimatedContainer(
        duration: Duration(milliseconds: 250),
        curve: Curves.easeOut,
        height: ddm.customAmount ? 92 : 0.0,
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: ddm.customAmount
              ? Theme(
                  data: ThemeData(primaryColor: ColorTheme.blue),
                  child: TextFormField(
                    focusNode: keyboardFocus,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(500000),
                    ],
                    onChanged: (text) {
                      ddm.amount = int.parse(text);
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (text) {
                      int amount = int.parse(text);
                      if (amount > ddm.adBalance.dcBalance)
                        return "Du hast nur ${ddm.adBalance.dcBalance} DV's! Wähle einen kleineren Betrag.";
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: "Anzahl an DV's",
                      labelText: "DV's",
                    ),
                  ),
                )
              : Container(),
        ),
      );
    });
  }
}

class DCSlider extends StatelessWidget {
  final List<int> defaultDonationAmounts = [
    1,
    2,
    5,
    10,
    15,
    20,
    30,
    40,
    50,
    100
  ];

  @override
  Widget build(BuildContext context) {
    BaseTheme _bTheme = ThemeManager.of(context).colors;
    return Consumer<DonationDialogManager>(builder: (context, ddm, child) {
      defaultDonationAmounts
          .removeWhere((element) => element > ddm.adBalance.dcBalance);
      return SizedBox(
        height: 120,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            bool selected = index != defaultDonationAmounts.length &&
                ddm.amount == defaultDonationAmounts[index];
            return Center(
              child: Container(
                width: 120,
                height: 100,
                margin: index == 0
                    ? EdgeInsets.only(left: 12)
                    : index == defaultDonationAmounts.length
                        ? EdgeInsets.only(right: 12)
                        : null,
                child: Card(
                  margin: EdgeInsets.fromLTRB(0, 2, 12, 2),
                  clipBehavior: Clip.antiAlias,
                  elevation: selected ? 2 : 0,
                  color: selected ? _bTheme.contrast : Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  child: InkWell(
                    onTap: () {
                      if (ddm.customAmount) {
                        ddm.customAmount = false;
                      }
                      if (index != defaultDonationAmounts.length)
                        ddm.amount = defaultDonationAmounts[index];
                      else
                        ddm.customAmount = true;
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15.0, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          index != defaultDonationAmounts.length
                              ? Material(
                                  color: _bTheme.dark.withOpacity(.1),
                                  shape: CircleBorder(),
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      "DV",
                                      style: TextStyle(
                                          fontSize: 12, color: _bTheme.dark),
                                    ),
                                  ),
                                )
                              : Container(),
                          Text(
                            index != defaultDonationAmounts.length
                                ? "${defaultDonationAmounts[index]}.00"
                                : "Anderer Betrag",
                            style: Theme.of(context)
                                .textTheme
                                .headline6
                                .copyWith(
                                    color: selected
                                        ? _bTheme.textOnContrast
                                        : _bTheme.dark),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
          itemCount: defaultDonationAmounts.length + 1,
        ),
      );
    });
  }
}

class AddPaymentMethodDialog extends StatelessWidget {
  ThemeData _theme;

  final Function close;

  AddPaymentMethodDialog(this.close);

  @override
  Widget build(BuildContext context) {
    _theme = Theme.of(context);
    return Stack(
      children: <Widget>[
        Positioned.fill(
            child: GestureDetector(
          onTap: close,
        )),
        Align(
          alignment: Alignment.bottomCenter,
          child: Material(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10), topRight: Radius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    "Bitte füge eine Bezalmethode hinzu oder sammle neue DVs!",
                    style: _theme.textTheme.headline6,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "Bevor du etwas unterstützen kannst, brauchen wir deine Zahlungsdaten oder gesammelte DVs!",
                    style: _theme.textTheme.bodyText2,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  OutlineButton.icon(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (c) => PaymentInfosPage()));
                    },
                    label: Text("Hinzufügen"),
                    icon: Icon(Icons.add),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).padding.bottom,
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
