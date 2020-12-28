import 'dart:async';
import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:flutter_xlider/flutter_xlider.dart';
import 'package:lottie/lottie.dart';
import 'package:number_slide_animation/number_slide_animation.dart';
import 'package:one_d_m/Helper/Campaign.dart';
import 'package:one_d_m/Helper/ColorTheme.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/Donation.dart';
import 'package:one_d_m/Helper/DonationDialogManager.dart';
import 'package:one_d_m/Helper/Helper.dart';
import 'package:one_d_m/Helper/ThemeManager.dart';
import 'package:one_d_m/Helper/User.dart';
import 'package:one_d_m/Helper/UserManager.dart';
import 'package:one_d_m/Helper/notification_helper.dart';
import 'package:one_d_m/chart/circle_painter.dart';
import 'package:one_d_m/chart/size_const.dart';
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
                  return Container(
                    child: Stack(
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
                                      topLeft: Radius.circular(30),
                                      topRight: Radius.circular(30)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        _buildheading(widget.campaign.imgUrl,
                                            widget.campaign.name),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Gesammelte DV: ',
                                              style: _theme.textTheme.subtitle1
                                                  .copyWith(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.black,
                                                      fontSize: 18),
                                            ),
                                            Text(
                                              ddm.adBalance.dcBalance
                                                  .toString(),
                                              style: _theme.textTheme.subtitle1
                                                  .copyWith(
                                                      fontWeight:
                                                          FontWeight.w900,
                                                      fontSize: 24,
                                                      color: Colors.black),
                                            )
                                          ],
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Ausgewählt: ',
                                              style: _theme.textTheme.subtitle1
                                                  .copyWith(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.black,
                                                      fontSize: 18),
                                            ),
                                            Text(
                                              _selectedValue.toInt().toString(),
                                              style: _theme.textTheme.subtitle1
                                                  .copyWith(
                                                      fontWeight:
                                                          FontWeight.w900,
                                                      fontSize: 24,
                                                      color: Colors.black),
                                            )
                                          ],
                                        ),
                                        //dv slider
                                        Flexible(
                                          child: FlutterSlider(
                                            min: 0,
                                            max: ddm.adBalance.dcBalance
                                                .toDouble(),
                                            values: [_selectedValue],
                                            onDragging: (handlerIndex,
                                                lowerValue, upperValue) {
                                              _selectedValue = lowerValue;
                                              setState(() {
                                                ddm.amount =
                                                    _selectedValue.toInt();
                                              });
                                            },
                                            tooltip: FlutterSliderTooltip(
                                                disabled: true),
                                            handler: FlutterSliderHandler(
                                              decoration: BoxDecoration(),
                                              child: Material(
                                                type: MaterialType.circle,
                                                color: _bTheme.dark,
                                                elevation: 3,
                                                child: Container(
                                                    padding: EdgeInsets.all(5),
                                                    child: Icon(
                                                      Icons.adjust_sharp,
                                                      size: 25,
                                                      color: _bTheme.contrast,
                                                    )),
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
                                          height: 30 +
                                              MediaQuery.of(context)
                                                  .padding
                                                  .bottom,
                                        ),
                                        Visibility(
                                          visible: ddm.showAnimation,
                                          child: SizedBox(
                                            height: 150 +
                                                MediaQuery.of(context)
                                                    .padding
                                                    .bottom,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              ddm.showAnimation
                                  ? DonationAnimationWidget(widget.close)
                                  : SizedBox.shrink(),
                              // Positioned(
                              //     top: 20,
                              //     right: 20,
                              //     child: AnimatedOpacity(
                              //         duration: Duration(milliseconds: 250),
                              //         opacity: ddm.showThankYou ? 1 : 0,
                              //         child: _closeButton()))
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }))));
  }

  Widget _buildheading(String url, String title) => Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.transparent,
            child: CachedNetworkImage(
              imageUrl: url,
              imageBuilder: (context, imageProvider) => Container(
                height: 58.0,
                width: 76.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(25)),
                  image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 5,
          ),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.headline5.copyWith(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                Text(
                  'by WWF',
                  style: Theme.of(context).textTheme.subtitle1.copyWith(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w500),
                )
              ],
            ),
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
              color: _bTheme.dark,
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
                  : Text(
                      "Support!",
                      style: _theme.accentTextTheme.button
                          .copyWith(fontSize: 21, fontWeight: FontWeight.bold),
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
    ddm.showAnimation = true;

    if (keyboardFocus.hasPrimaryFocus) keyboardFocus.unfocus();
    await notificationPlugin.showNotification('Horaaa!', 'You save the world');
  }
}

class DonationAnimationWidget extends HookWidget {
  BaseTheme _bTheme;
  ThemeData _theme;
  final Function close;

  DonationAnimationWidget(this.close);

  @override
  Widget build(BuildContext context) {
    _bTheme = ThemeManager.of(context).colors;
    _theme = Theme.of(context);
    return Consumer<DonationDialogManager>(builder: (context, ddm, child) {
      return Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          top: 0,
          child: IgnorePointer(
            ignoring: !ddm.showAnimation,
            child: AnimatedOpacity(
              opacity: ddm.showAnimation ? 1 : 0,
              duration: Duration(milliseconds: 250),
              child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  child: AnimatedSwitcher(
                    duration: Duration(seconds: 1),
                    child: !ddm.showThankYou
                        ? Lottie.asset('assets/anim/anim_start.json',
                            onLoaded: (composition) {
                            HapticFeedback.heavyImpact();
                            Timer(Duration(seconds: 1), () {
                              ddm.showThankYou = true;
                            });
                          })
                        : _buildThankYou(context, ddm.campaign,
                            ddm.amount.toString(), close),
                  )),
            ),
          ));
    });
  }

  Widget _buildThankYou(BuildContext context, Campaign campaign, String amount,
          Function close) =>
      SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const SizedBox(
              height: 10,
            ),
            _buildInfoContent(),
            _buildDonatedAmountContent(amount),
            _buildCampaignImage(campaign.imgUrl),
            _buildReadMore(context, campaign, close),
            _buildChartContent(context),
            _buildThanksContent(context),
            const SizedBox(
              height: 20,
            ),
            _buildContinueButton(context, close),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      );

  Widget _buildInfoContent() => Row(
        children: [
          Image(
            image: AssetImage('assets/icons/ic_flower.png'),
            width: 120,
            height: 102,
          ),
          const SizedBox(
            width: 5,
          ),
          Consumer<UserManager>(
              builder: (context, um, child) => StreamBuilder<User>(
                  initialData: um.user,
                  stream: DatabaseService.getUserStream(um.uid),
                  builder: (context, snapshot) {
                    User user = snapshot.data;
                    return AutoSizeText(
                      '${user.name},du hast soeben mit\ndeinen DV die Welt\nkleines Stück besser\ngemacht!',
                      maxLines: null,
                      textAlign: TextAlign.left,
                      softWrap: true,
                      style: Theme.of(context)
                          .textTheme
                          .bodyText2
                          .copyWith(fontWeight: FontWeight.bold),
                    );
                  }))
        ],
      );

  Widget _buildDonatedAmountContent(String amount) => Container(
        height: 180,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Stack(
            children: [
              Container(
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(15.0)),
                  color: _bTheme.dark,
                  boxShadow: [
                    BoxShadow(
                      color: _bTheme.dark.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 3,
                      offset: Offset(3, 2), // changes position of shadow
                    ),
                  ],
                ),
                child: Container(
                  margin: const EdgeInsets.only(top: 24.0, left: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('Du hast ',
                              style: _theme.textTheme.headline6.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: _bTheme.light)),
                          NumberSlideAnimation(
                            number: amount,
                            duration: const Duration(seconds: 3),
                            curve: Curves.bounceIn,
                            textStyle: _theme.textTheme.headline6.copyWith(
                                fontWeight: FontWeight.bold,
                                color: _bTheme.light,
                                decoration: TextDecoration.underline),
                          ),
                          Text(' DV gespendet',
                              style: _theme.textTheme.headline6.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: _bTheme.light)),
                        ],
                      ),
                      Text('Das entspricht ${int.parse(amount) * 5} Cent',
                          style: _theme.textTheme.bodyText2
                              .copyWith(color: _bTheme.light)),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Image(
                  image: AssetImage('assets/icons/ic_donation.png'),
                  width: 120,
                  height: 102,
                ),
              )
            ],
          ),
        ),
      );

  Widget _buildCampaignImage(String imageUrl) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          imageBuilder: (_, imgProvider) => Container(
            height: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(20.0)),
              image: DecorationImage(
                image: imgProvider,
                fit: BoxFit.cover,
              ),
              boxShadow: [
                BoxShadow(
                  color: _bTheme.dark.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 3,
                  offset: Offset(3, 2), // changes position of shadow
                ),
              ],
            ),
          ),
        ),
      );

  Widget _buildReadMore(
          BuildContext context, Campaign campaign, Function function) =>
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          height: 170,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(17.0)),
            color: Colors.white,
            border:
                Border.all(width: 0.5, color: _bTheme.dark.withOpacity(0.4)),
            boxShadow: [
              BoxShadow(
                color: _bTheme.dark.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 3,
                offset: Offset(3, 2), // changes position of shadow
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 10,
              ),
              AutoSizeText(
                campaign.name,
                style: _theme.textTheme.headline6
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: AutoSizeText(
                  campaign.shortDescription,
                  style: _theme.textTheme.bodyText2
                      .copyWith(fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              RaisedButton(
                  color: _bTheme.dark,
                  textColor: _bTheme.light,
                  child: Text('Mehr lesen'),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  onPressed: function)
            ],
          ),
        ),
      );

  Widget _buildChartContent(BuildContext context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          height: 170,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(15.0)),
            color: _bTheme.dark,
            boxShadow: [
              BoxShadow(
                color: _bTheme.dark.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 3,
                offset: Offset(3, 2), // changes position of shadow
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 10,
                ),
                AutoSizeText(
                  'Was mit deiner Spende passiert:',
                  style: _theme.textTheme.bodyText2.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _bTheme.light),
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Expanded(
                        flex: 1,
                        child: _PercentCircle(
                          percent: 14,
                        )),
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          FieldWidget(
                            amount: '94',
                            title: 'erhält das Projekt',
                            color: ColorTheme.donationGreen,
                          ),
                          FieldWidget(
                            amount: '4',
                            title: 'erhält ODM',
                            color: ColorTheme.donationOrange,
                          ),
                          FieldWidget(
                            amount: '2',
                            title: 'Transaktionskosten',
                            color: ColorTheme.donationBlack,
                          )
                        ],
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      );

  Widget _buildThanksContent(BuildContext context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          height: 155,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(17.0)),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: _bTheme.dark.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 3,
                offset: Offset(3, 2), // changes position of shadow
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: AutoSizeText(
                    'Weiter so!',
                    style: _theme.textTheme.headline6
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Image(
                    image: AssetImage('assets/icons/ic_baloons.png'),
                    width: 120,
                    height: 100,
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: AutoSizeText(
                      'Sammle DV, spende\nsie und löse mit\nunserer Community\nglobale Probleme!',
                      maxLines: null,
                      softWrap: true,
                      style: Theme.of(context)
                          .textTheme
                          .bodyText2
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _buildContinueButton(BuildContext context, Function function) =>
      RaisedButton(
          color: _bTheme.dark,
          textColor: _bTheme.light,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Weiter',
                style: Theme.of(context).textTheme.button.copyWith(
                    color: ThemeManager.of(context).colors.light, fontSize: 18),
              ),
              Icon(
                Icons.chevron_right,
                color: ThemeManager.of(context).colors.light,
              )
            ],
          ),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          onPressed: function);
}

class FieldWidget extends StatelessWidget {
  final String amount;
  final String title;
  final Color color;

  const FieldWidget({Key key, this.amount, this.title, this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              height: 12,
              width: 12,
              decoration: BoxDecoration(
                  color: color,
                  border: Border.all(
                      width: 1, color: ThemeManager.of(context).colors.light),
                  shape: BoxShape.circle),
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                AutoSizeText(
                  '$amount% ',
                  style: Theme.of(context).textTheme.subtitle1.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: ThemeManager.of(context).colors.light),
                ),
                AutoSizeText(
                  title,
                  style: Theme.of(context).textTheme.subtitle1.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w200,
                      color: ThemeManager.of(context).colors.light),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _PercentCircle extends StatelessWidget {
  const _PercentCircle({
    Key key,
    @required this.percent,
    this.radius = 50,
  }) : super(key: key);

  final double radius;
  final double percent;

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 2 * radius,
        width: 2 * radius,
        child: CustomPaint(
            painter: CirclePainter(MediaQuery.of(context).size.width,
                MediaQuery.of(context).size.height,
                startAngle: 0),
            child: Center(
              child: Text(
                '100%',
                style: TextStyle(
                  color: ColorTheme.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15.0,
                ),
              ),
            )));
  }
}
