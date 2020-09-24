import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:flutter_svg/svg.dart';
import 'package:one_d_m/Components/Avatar.dart';
import 'package:one_d_m/Helper/Campaign.dart';
import 'package:one_d_m/Helper/ColorTheme.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/Donation.dart';
import 'package:one_d_m/Helper/Helper.dart';
import 'package:one_d_m/Helper/ThemeManager.dart';
import 'package:one_d_m/Helper/User.dart';
import 'package:one_d_m/Helper/UserManager.dart';
import 'package:one_d_m/Pages/PaymentInfosPage.dart';
import 'package:provider/provider.dart';

class DonationDialogWidget extends StatefulWidget {
  Function close;
  Campaign campaign;
  User user;
  BuildContext context;
  int defaultSelectedAmount;

  DonationDialogWidget(
      {this.close,
      this.campaign,
      this.user,
      this.context,
      this.defaultSelectedAmount = 5});

  @override
  _DonationDialogWidgetState createState() => _DonationDialogWidgetState();
}

class _DonationDialogWidgetState extends State<DonationDialogWidget>
    with SingleTickerProviderStateMixin {
  ThemeData _theme;
  static final List<int> defaultDonationAmounts = [
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

  bool _showThankYou = false,
      _loading = false,
      _customAmount = false,
      _anonym = false;
  int _amount;
  Campaign _alternativCampaign;
  FocusScopeNode _keyboardFocus = FocusScopeNode();

  @override
  void initState() {
    super.initState();
    _amount = widget.defaultSelectedAmount;
  }

  @override
  Widget build(BuildContext context) {
    _theme = Theme.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.transparent,
      body: Container(
        color: Colors.transparent,
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Consumer<UserManager>(builder: (context, um, child) {
          if (um.user.ghost) _anonym = true;
          return StreamBuilder<bool>(
              initialData: true,
              stream: DatabaseService.hasPaymentMethod(um.uid),
              builder: (context, snapshot) {
                if (!snapshot.data) {
                  return Stack(
                    children: <Widget>[
                      Positioned.fill(
                          child: GestureDetector(
                        onTap: widget.close,
                      )),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Material(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10)),
                          child: Padding(
                            padding: const EdgeInsets.all(18.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text(
                                  "Bitte füge eine Bezalmethode hinzu!",
                                  style: _theme.textTheme.headline6,
                                ),
                                Text(
                                  "Bevor du etwas spenden kannst, brauchen wir deine Zahlungsdaten!",
                                  style: _theme.textTheme.bodyText1,
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                OutlineButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (c) =>
                                                PaymentInfosPage()));
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
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 20.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              AutoSizeText(
                                                "Wieviele Donation Credits?",
                                                maxLines: 1,
                                                style:
                                                    _theme.textTheme.headline6,
                                              ),
                                              SizedBox(
                                                height: 4,
                                              ),
                                              Text(
                                                "Wähle einen Betrag:",
                                                style: _theme
                                                    .textTheme.bodyText1
                                                    .copyWith(
                                                        color: Colors.black54),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        _closeButton()
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 120,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemBuilder: (context, index) {
                                        return Center(
                                          child: Container(
                                            width: 120,
                                            height: 100,
                                            margin: index == 0
                                                ? EdgeInsets.only(left: 20)
                                                : index ==
                                                        defaultDonationAmounts
                                                            .length
                                                    ? EdgeInsets.only(right: 20)
                                                    : null,
                                            child: Card(
                                              clipBehavior: Clip.antiAlias,
                                              elevation: index !=
                                                          defaultDonationAmounts
                                                              .length &&
                                                      _amount ==
                                                          defaultDonationAmounts[
                                                              index]
                                                  ? 2
                                                  : 0,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              child: InkWell(
                                                onTap: () {
                                                  if (_customAmount) {
                                                    setState(() {
                                                      _customAmount = false;
                                                    });
                                                  }
                                                  if (index !=
                                                      defaultDonationAmounts
                                                          .length)
                                                    setState(() {
                                                      _amount =
                                                          defaultDonationAmounts[
                                                              index];
                                                    });
                                                  else
                                                    setState(() {
                                                      _customAmount = true;
                                                    });
                                                },
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 15.0,
                                                      vertical: 8),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: <Widget>[
                                                      index !=
                                                              defaultDonationAmounts
                                                                  .length
                                                          ? Material(
                                                              color: ColorTheme
                                                                  .blue
                                                                  .withOpacity(
                                                                      .1),
                                                              shape:
                                                                  CircleBorder(),
                                                              child: Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(
                                                                            8.0),
                                                                child: Text(
                                                                  "DC",
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          12,
                                                                      color: ColorTheme
                                                                          .blue),
                                                                ),
                                                              ),
                                                            )
                                                          : Container(),
                                                      Text(
                                                        index !=
                                                                defaultDonationAmounts
                                                                    .length
                                                            ? "${defaultDonationAmounts[index]}.00"
                                                            : "Anderer Betrag",
                                                        style: _theme.textTheme
                                                            .headline6,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                      itemCount:
                                          defaultDonationAmounts.length + 1,
                                    ),
                                  ),
                                  AnimatedContainer(
                                    duration: Duration(milliseconds: 250),
                                    curve: Curves.easeOut,
                                    height: _customAmount ? 80 : 0.0,
                                    width: double.infinity,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 18.0),
                                      child: _customAmount
                                          ? Theme(
                                              data: ThemeData(
                                                  primaryColor:
                                                      ColorTheme.blue),
                                              child: TextField(
                                                focusNode: _keyboardFocus,
                                                keyboardType:
                                                    TextInputType.number,
                                                maxLength: 6,
                                                inputFormatters: [
                                                  WhitelistingTextInputFormatter
                                                      .digitsOnly,
                                                  LengthLimitingTextInputFormatter(
                                                      500000),
                                                ],
                                                onChanged: (text) {
                                                  setState(() {
                                                    _amount = int.parse(text);
                                                  });
                                                },
                                                decoration: InputDecoration(
                                                  hintText: "Anzahl an DC's",
                                                  labelText: "DC's",
                                                ),
                                              ),
                                            )
                                          : Container(),
                                    ),
                                  ),
                                  FutureBuilder<List<Campaign>>(
                                      future: _getPossibleCampaigns(),
                                      builder: (context, snapshot) {
                                        List<Campaign> campaigns = [];
                                        if (snapshot.hasData) {
                                          campaigns = snapshot.data;
                                          campaigns.removeWhere((c) =>
                                              c.id == widget.campaign.id);
                                        }

                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  left: 20.0, right: 20),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Text(
                                                    "Alternatives Projekt: ",
                                                    style: _theme
                                                        .textTheme.headline6,
                                                  ),
                                                  AutoSizeText(
                                                    "Wähle ein Projekt an das wir alternativ spenden können.",
                                                    maxLines: 1,
                                                    style: _theme
                                                        .textTheme.caption,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                                height: 100,
                                                child: ListView.builder(
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  itemBuilder:
                                                      (context, index) {
                                                    return Center(
                                                      child: Container(
                                                        height: 80,
                                                        margin: index == 0
                                                            ? EdgeInsets.only(
                                                                left: 20)
                                                            : index ==
                                                                    campaigns
                                                                            .length -
                                                                        1
                                                                ? EdgeInsets
                                                                    .only(
                                                                        right:
                                                                            20)
                                                                : null,
                                                        child: Card(
                                                          elevation:
                                                              _alternativCampaign
                                                                          ?.id ==
                                                                      campaigns[
                                                                              index]
                                                                          .id
                                                                  ? 2
                                                                  : 0,
                                                          clipBehavior:
                                                              Clip.antiAlias,
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10)),
                                                          child: InkWell(
                                                            onTap: () {
                                                              setState(() {
                                                                _alternativCampaign =
                                                                    campaigns[
                                                                        index];
                                                              });
                                                            },
                                                            child: Padding(
                                                              padding: const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      15.0,
                                                                  vertical: 8),
                                                              child: Row(
                                                                children: <
                                                                    Widget>[
                                                                  Avatar(campaigns[
                                                                              index]
                                                                          .thumbnailUrl ??
                                                                      campaigns[
                                                                              index]
                                                                          .imgUrl),
                                                                  SizedBox(
                                                                      width:
                                                                          10),
                                                                  Text(
                                                                    "${campaigns[index].name}",
                                                                    style: _theme
                                                                        .textTheme
                                                                        .headline6,
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
                                      }),
                                  um.user.ghost
                                      ? Container()
                                      : Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 4.0),
                                          child: CheckboxListTile(
                                            value: _anonym,
                                            onChanged: (checked) {
                                              setState(() {
                                                _anonym = checked;
                                              });
                                            },
                                            title: Text("Anonym spenden"),
                                            subtitle: Text(
                                                "Wenn aktiviert, wird diese Spende nicht in deinem Profil angezeigt"),
                                          ),
                                        ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 20.0),
                                    child: OfflineBuilder(
                                        child: Container(),
                                        connectivityBuilder:
                                            (c, connection, child) {
                                          bool connected = connection !=
                                              ConnectivityResult.none;
                                          return MaterialButton(
                                            minWidth: double.infinity,
                                            height: 50,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            elevation: 0,
                                            color: ThemeManager.of(context)
                                                .theme
                                                .dark,
                                            disabledColor: Colors.grey,
                                            onPressed: _amount != null &&
                                                    _alternativCampaign !=
                                                        null &&
                                                    _amount != 0
                                                ? connected
                                                    ? _donate
                                                    : () {
                                                        Helper
                                                            .showConnectionSnackBar(
                                                                context);
                                                      }
                                                : null,
                                            child: _loading
                                                ? Center(
                                                    child:
                                                        CircularProgressIndicator(
                                                      valueColor:
                                                          AlwaysStoppedAnimation(
                                                              Colors.white),
                                                    ),
                                                  )
                                                : Text(
                                                    "Spenden",
                                                    style: _theme
                                                        .accentTextTheme.button,
                                                  ),
                                          );
                                        }),
                                  ),
                                  SizedBox(
                                    height: 10 +
                                        MediaQuery.of(context).padding.bottom,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                              left: 0,
                              right: 0,
                              bottom: 0,
                              top: 0,
                              child: IgnorePointer(
                                ignoring: !_showThankYou,
                                child: AnimatedOpacity(
                                  opacity: _showThankYou ? 1 : 0,
                                  duration: Duration(milliseconds: 250),
                                  child: Material(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        SvgPicture.asset(
                                          "assets/images/thank-you.svg",
                                          width: 300,
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        Text(
                                          "Vielen dank für deine Spende!",
                                          style: _theme.textTheme.headline6,
                                        ),
                                        SizedBox(
                                          height: MediaQuery.of(context)
                                              .padding
                                              .bottom,
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              )),
                          Positioned(
                              top: 20,
                              right: 20,
                              child: AnimatedOpacity(
                                  duration: Duration(milliseconds: 250),
                                  opacity: _showThankYou ? 1 : 0,
                                  child: _closeButton()))
                        ],
                      ),
                    ),
                  ],
                );
              });
        }),
      ),
    );
  }

  Future<List<Campaign>> _getPossibleCampaigns() async {
    UserManager um = Provider.of<UserManager>(context, listen: false);
    List<Campaign> possibleCampaigns =
        await DatabaseService.getSubscribedCampaigns(um.uid);
    possibleCampaigns.removeWhere((c) => c.id == widget.campaign.id);
    if (possibleCampaigns.isEmpty)
      possibleCampaigns = await DatabaseService.getTopCampaigns();

    return possibleCampaigns;
  }

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

  _donate() async {
    Donation donation = Donation(_amount,
        campaignId: widget.campaign.id,
        alternativeCampaignId: widget.campaign.id,
        campaignImgUrl: widget.campaign.imgUrl,
        userId: widget.user.id,
        campaignName: widget.campaign.name,
        anonym: _anonym);

    if (_amount >= 100) {
      bool res = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
                title: Text("Bist du dir sicher?"),
                content: Text("Willst du wirklich $_amount DC Spenden?"),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                actions: <Widget>[
                  FlatButton(
                      onPressed: () {
                        Navigator.pop(context, false);
                      },
                      textColor: ColorTheme.orange,
                      child: Text("ABBRECHEN")),
                  FlatButton(
                      onPressed: () {
                        Navigator.pop(context, true);
                      },
                      textColor: ColorTheme.blue,
                      child: Text("SPENDEN")),
                ],
              ));
      if (!res) return;
    }

    setState(() {
      _loading = true;
    });

    await DatabaseService.donate(donation);

    setState(() {
      _loading = false;
      _showThankYou = true;
    });

    if (_keyboardFocus.hasPrimaryFocus) _keyboardFocus.unfocus();

    // widget.close();
  }
}
