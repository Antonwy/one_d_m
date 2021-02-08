import 'dart:async';
import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:line_icons/line_icons.dart';
import 'package:lottie/lottie.dart';
import 'package:number_slide_animation/number_slide_animation.dart';
import 'package:one_d_m/Helper/AdBalance.dart';
import 'package:one_d_m/Helper/Campaign.dart';
import 'package:one_d_m/Helper/ColorTheme.dart';
import 'package:one_d_m/Helper/Constants.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/Donation.dart';
import 'package:one_d_m/Helper/DonationDialogManager.dart';
import 'package:one_d_m/Helper/Helper.dart';
import 'package:one_d_m/Helper/Organisation.dart';
import 'package:one_d_m/Helper/ThemeManager.dart';
import 'package:one_d_m/Helper/User.dart';
import 'package:one_d_m/Helper/UserManager.dart';
import 'package:one_d_m/Helper/currency.dart';
import 'package:one_d_m/Helper/margin.dart';
import 'package:one_d_m/Helper/notification_helper.dart';
import 'package:one_d_m/Pages/OrganisationPage.dart';
import 'package:one_d_m/chart/circle_painter.dart';
import 'package:provider/provider.dart';

class DonationDialogWidget extends StatefulWidget {
  final Function close;
  final Campaign campaign;
  final User user;
  final BuildContext context;
  int defaultSelectedAmount;
  final String sessionId;
  final ScrollController controller;
  final String uid;

  DonationDialogWidget(
      {this.close,
      @required this.uid,
      this.campaign,
      this.user,
      this.context,
      this.sessionId,
      this.defaultSelectedAmount = 0,
      this.controller});

  @override
  _DonationDialogWidgetState createState() => _DonationDialogWidgetState();
}

class _DonationDialogWidgetState extends State<DonationDialogWidget>
    with SingleTickerProviderStateMixin {
  ThemeData _theme;
  BaseTheme _bTheme;
  FocusScopeNode _keyboardFocus = FocusScopeNode();
  double _selectedValue = 0;
  ScrollController _scrollController;
  bool _shouldScroll = true;

  Stream<AdBalance> _adbalanceStream;

  @override
  void initState() {
    _selectedValue = widget.defaultSelectedAmount.toDouble();
    _adbalanceStream =
        DatabaseService.getAdBalance(widget.user?.id ?? widget.uid);

    _adbalanceStream.listen((event) {
      if (event.dcBalance < _selectedValue) {
        _selectedValue = 0;
      }
    });

    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.position.atEdge) {
        if (_scrollController.position.pixels == 0) {
          setState(() {
            _shouldScroll = false;
          });
        } else {
          setState(() {
            _shouldScroll = true;
          });
        }
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
              adBalanceStream: _adbalanceStream,
              defaultSelectedAmount: widget.defaultSelectedAmount,
              sessionId: widget.sessionId,
              campaign: widget.campaign,
            ),
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
                        Positioned(
                          bottom: MediaQuery.of(context).viewInsets.bottom,
                          left: 0,
                          right: 0,
                          child: Stack(
                            children: <Widget>[
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: Material(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(18),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        _buildheading(
                                            widget.campaign?.imgUrl ?? "",
                                            widget.campaign?.name ??
                                                "Not found",
                                            widget.campaign?.authorId ?? ""),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        Align(
                                          alignment: Alignment.center,
                                          child: MaterialButton(
                                            minWidth: 118,
                                            height: 50,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        Constants.radius)),
                                            elevation: 0,
                                            color: _bTheme.dark,
                                            child: Column(
                                              children: [
                                                Text(
                                                  '${_selectedValue.toInt().toString()} DV',
                                                  style: _theme
                                                      .accentTextTheme.button
                                                      .copyWith(
                                                          fontSize: 21,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                            onPressed: () {},
                                          ),
                                        ),
                                        const YMargin(5),
                                        Align(
                                          alignment: Alignment.center,
                                          child: Text(
                                            'von ${ddm?.adBalance?.dcBalance ?? 0} DV',
                                            style: _theme.textTheme.subtitle1
                                                .copyWith(
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 12,
                                                    color: Colors.black54),
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Expanded(
                                                flex: 1,
                                                child: MaterialButton(
                                                  clipBehavior: Clip.antiAlias,
                                                  shape: CircleBorder(),
                                                  elevation: 0,
                                                  onPressed: () {},
                                                  color: Helper.hexToColor(
                                                      '#e2e2e2'),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            2.0),
                                                    child: IconButton(
                                                        icon: Icon(
                                                            LineIcons.minus),
                                                        color: _bTheme.dark,
                                                        onPressed: () {
                                                          if (_selectedValue >
                                                              0) {
                                                            HapticFeedback
                                                                .heavyImpact();
                                                            setState(() {
                                                              _selectedValue--;
                                                              ddm.amount =
                                                                  _selectedValue
                                                                      .toInt();
                                                            });
                                                          }
                                                        }),
                                                  ),
                                                )),
                                            Expanded(
                                                flex: 2,
                                                child: Column(
                                                  children: [
                                                    Container(
                                                      color: _bTheme.dark
                                                          .withOpacity(.1),
                                                      height: 1,
                                                    ),
                                                  ],
                                                )),
                                            Expanded(
                                                flex: 1,
                                                child: MaterialButton(
                                                  clipBehavior: Clip.antiAlias,
                                                  shape: CircleBorder(),
                                                  color: _bTheme.dark,
                                                  elevation: 0,
                                                  onPressed: () {},
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            2.0),
                                                    child: IconButton(
                                                        icon: Icon(
                                                            LineIcons.plus),
                                                        color: _bTheme.light,
                                                        onPressed: () {
                                                          if ((ddm?.adBalance
                                                                      ?.dcBalance ??
                                                                  0) >
                                                              _selectedValue) {
                                                            HapticFeedback
                                                                .heavyImpact();
                                                            setState(() {
                                                              _selectedValue++;
                                                              ddm.amount =
                                                                  _selectedValue
                                                                      .toInt();
                                                            });
                                                          }
                                                        }),
                                                  ),
                                                ))
                                          ],
                                        ),
                                        const YMargin(20),
                                        Align(
                                          alignment: Alignment.center,
                                          child: Builder(builder: (context) {
                                            List<String> dEffects = widget
                                                    .campaign
                                                    ?.donationEffects ??
                                                [];
                                            String effect = dEffects.isEmpty
                                                ? ""
                                                : dEffects[new Random(42)
                                                    .nextInt(dEffects.length)];
                                            return Text(
                                              effect.replaceFirst(
                                                  '**',
                                                  Currency((_selectedValue
                                                              .toInt() *
                                                          5))
                                                      .value()),
                                              textAlign: TextAlign.center,
                                              style: _theme.textTheme.subtitle1
                                                  .copyWith(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 15,
                                                      color: ThemeManager.of(
                                                              context)
                                                          .colors
                                                          .dark),
                                            );
                                          }),
                                        ),
                                        const YMargin(20),
                                        Align(
                                          alignment: Alignment.center,
                                          child: DonationButton(
                                              keyboardFocus: _keyboardFocus,
                                              campaign: widget.campaign,
                                              user: widget.user,
                                              uid: widget.uid),
                                        ),
                                        AnimatedContainer(
                                          curve: Curves.fastOutSlowIn,
                                          duration: Duration(milliseconds: 350),
                                          height: ddm.showAnimation
                                              ? context.screenHeight(
                                                  percent: 0.45)
                                              : context.screenHeight(
                                                  percent: .05),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              ddm.showAnimation
                                  ? DonationAnimationWidget(widget.close,
                                      _scrollController, _shouldScroll)
                                  : SizedBox.shrink()

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

  Widget _buildheading(String url, String title, String authorId) => Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Material(
              borderRadius: BorderRadius.circular(Constants.radius),
              clipBehavior: Clip.antiAlias,
              child: CachedNetworkImage(
                height: 58.0,
                width: 76,
                imageUrl: url,
                fit: BoxFit.cover,
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
                AutoSizeText(
                  title,
                  maxLines: 1,
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.headline5.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: _bTheme.dark),
                ),
                FutureBuilder<Organisation>(
                    future: DatabaseService.getOrganisation(authorId),
                    builder: (context, snapshot) {
                      Organisation organisation = snapshot.data;
                      return InkWell(
                        onTap: !snapshot.hasData
                            ? null
                            : () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            OrganisationPage(organisation)));
                              },
                        child: Text(
                          'by ${organisation?.name ?? ''}',
                          style: Theme.of(context).textTheme.subtitle1.copyWith(
                                color: Colors.black54,
                                fontSize: 13,
                              ),
                        ),
                      );
                    }),
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
  final User user;
  final String uid;

  DonationButton({this.campaign, this.keyboardFocus, this.user, this.uid});

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
                  borderRadius: BorderRadius.circular(Constants.radius)),
              elevation: 0,
              color: _bTheme.dark,
              disabledColor: Colors.grey,
              onPressed: ddm.amount != null &&
                          ddm.amount != 0 &&
                          ddm.amount <= ddm.adBalance?.dcBalance ??
                      0
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
                          .copyWith(fontSize: 18, fontWeight: FontWeight.bold),
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
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Constants.radius)),
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
        userId: uid,
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
                    borderRadius: BorderRadius.circular(Constants.radius)),
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
  final ScrollController controller;
  bool shouldScroll;

  DonationAnimationWidget(this.close, this.controller, this.shouldScroll);

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
          child: AnimatedOpacity(
            opacity: ddm.showAnimation ? 1 : 0,
            duration: Duration(milliseconds: 250),
            child: Material(
                clipBehavior: Clip.antiAlias,
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                child: AnimatedSwitcher(
                  duration: Duration(seconds: 1),
                  child: !ddm.showThankYou
                      ? Lottie.asset('assets/anim/anim_start.json',
                          repeat: false, onLoaded: (composition) {
                          HapticFeedback.heavyImpact();
                          Timer(Duration(seconds: 1), () {
                            ddm.showThankYou = true;
                          });
                        })
                      : _buildThankYou(
                          context,
                          ddm.campaign,
                          ddm.amount.toString(),
                          close,
                          controller,
                          shouldScroll),
                )),
          ));
    });
  }

  Widget _buildThankYou(BuildContext context, Campaign campaign, String amount,
          Function close, ScrollController controller, bool shouldScroll) =>
      SingleChildScrollView(
        controller: controller,
        physics: shouldScroll
            ? AlwaysScrollableScrollPhysics()
            : NeverScrollableScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const YMargin(20),
            _buildThankTitle(context),
            _buildInfoContent(context),
            _buildDonatedAmountContent(amount),
            _buildReadMore(context, campaign, close),
            _buildChartContent(context),
            _buildThanksContent(context),
            _buildContinueButton(context, close),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      );

  Widget _buildThankTitle(BuildContext context) => Column(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 18.0),
              child: Text(
                'Vielen Dank!',
                style: _theme.textTheme.headline5
                    .copyWith(fontWeight: FontWeight.bold, fontSize: 28),
              ),
            ),
          ),
        ],
      );

  Widget _buildInfoContent(BuildContext context) => Padding(
        padding: const EdgeInsets.all(12.0),
        child: Material(
          borderRadius: BorderRadius.circular(Constants.radius),
          elevation: 1,
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Image(
                  image: AssetImage('assets/icons/ic_flower.png'),
                  width: 120,
                  height: 102,
                ),
                const SizedBox(
                  width: 12,
                ),
                Consumer<UserManager>(
                    builder: (context, um, child) => StreamBuilder<User>(
                        initialData: um.user,
                        stream: DatabaseService.getUserStream(um.uid),
                        builder: (context, snapshot) {
                          User user = snapshot.data;
                          return Expanded(
                            child: AutoSizeText(
                              '${user.name}, du hast die Welt ein kleines Stück besser gemacht!',
                              maxLines: null,
                              textAlign: TextAlign.left,
                              softWrap: true,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText2
                                  .copyWith(fontWeight: FontWeight.w600),
                            ),
                          );
                        }))
              ],
            ),
          ),
        ),
      );

  Widget _buildDonatedAmountContent(String amount) => Container(
        height: 180,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Stack(
            children: [
              Container(
                height: 120,
                child: Material(
                  elevation: 1,
                  borderRadius:
                      BorderRadius.all(Radius.circular(Constants.radius)),
                  color: _bTheme.dark,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
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
                            Text(' DV gespendet!',
                                style: _theme.textTheme.headline6.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: _bTheme.light)),
                          ],
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text('Das entspricht ${int.parse(amount) * 5} Cent',
                            style: _theme.textTheme.subtitle2.copyWith(
                                color: _bTheme.light.withOpacity(.7))),
                      ],
                    ),
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

  Widget _buildCampaignImage(String imageUrl) => CachedNetworkImage(
        imageUrl: imageUrl,
        imageBuilder: (_, imgProvider) => Container(
          height: 200,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: imgProvider,
              fit: BoxFit.cover,
            ),
          ),
        ),
      );

  Widget _buildReadMore(
          BuildContext context, Campaign campaign, Function function) =>
      Padding(
        padding: const EdgeInsets.all(12.0),
        child: Material(
          clipBehavior: Clip.antiAlias,
          color: Colors.white,
          borderRadius: BorderRadius.circular(Constants.radius),
          elevation: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildCampaignImage(campaign.imgUrl),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 7),
                child: AutoSizeText(
                  campaign.name,
                  style: _theme.textTheme.headline6
                      .copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: AutoSizeText(
                  campaign.shortDescription,
                  style: _theme.textTheme.bodyText2
                      .copyWith(fontWeight: FontWeight.w600),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Divider(),
              Padding(
                padding: const EdgeInsets.only(left: 0.0, bottom: 8),
                child: FlatButton(
                    textColor: _bTheme.textOnContrast,
                    child: Text('MEHR LESEN'),
                    onPressed: function),
              )
            ],
          ),
        ),
      );

  Widget _buildChartContent(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Container(
          height: 170,
          width: MediaQuery.of(context).size.width,
          child: Material(
            borderRadius: BorderRadius.all(Radius.circular(Constants.radius)),
            color: _bTheme.dark,
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                          child: PercentCircle(
                            percent: 14,
                          )),
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            FieldWidget(
                              amount: '70',
                              title: 'erhält das Projekt',
                              color: ColorTheme.donationRed,
                            ),
                            FieldWidget(
                              amount: '25',
                              title: 'Advertising',
                              color: ColorTheme.donationLightBlue,
                            ),
                            FieldWidget(
                                amount: '5',
                                title: 'erhält ODM',
                                color: ColorTheme.donationBlue)
                          ],
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      );

  Widget _buildThanksContent(BuildContext context) => Padding(
        padding: const EdgeInsets.all(12.0),
        child: Material(
          borderRadius: BorderRadius.all(Radius.circular(Constants.radius)),
          color: Colors.white,
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AutoSizeText(
                        'Weiter so!',
                        style: _theme.textTheme.headline6
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 12,
                      ),
                      AutoSizeText(
                          'Sammle DV, spende sie und löse mit unserer Community globale Probleme!',
                          maxLines: null,
                          softWrap: true,
                          style: Theme.of(context).textTheme.bodyText2),
                    ],
                  ),
                ),
                Image(
                  image: AssetImage('assets/icons/ic_baloons.png'),
                  width: 120,
                  height: 100,
                ),
              ],
            ),
          ),
        ),
      );

  Widget _buildContinueButton(BuildContext context, Function function) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Container(
          width: double.infinity,
          height: 55,
          child: Material(
            clipBehavior: Clip.antiAlias,
            elevation: 1,
            borderRadius: BorderRadius.circular(Constants.radius),
            color: _bTheme.dark,
            child: InkWell(
              onTap: function,
              child: Center(
                child: Text(
                  'WEITER',
                  style: TextStyle(
                      color: _bTheme.textOnDark, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ),
      );
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
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
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
                      fontWeight: FontWeight.w700,
                      color: ThemeManager.of(context).colors.light),
                ),
                AutoSizeText(
                  title,
                  style: Theme.of(context).textTheme.subtitle1.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
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

class PercentCircle extends StatelessWidget {
  const PercentCircle({
    Key key,
    @required this.percent,
    this.radius = 50,
  }) : super(key: key);

  final double radius;
  final double percent;

  @override
  Widget build(BuildContext context) {
    ThemeManager _theme = ThemeManager.of(context);
    return Container(
        height: 2 * radius,
        width: 2 * radius,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8.0, top: 14.0),
              child: Text(
                '100%',
                style: TextStyle(
                  color: _theme.colors.light,
                  fontWeight: FontWeight.w700,
                  fontSize: 13.0,
                ),
              ),
            ),
            Container(
              height: 2 * radius,
              width: 2 * radius,
              child: CustomPaint(
                painter: CirclePainter(MediaQuery.of(context).size.width,
                    MediaQuery.of(context).size.height,
                    startAngle: 0,
                    colors: [
                      ColorTheme.donationRed,
                      ColorTheme.donationLightBlue,
                      ColorTheme.donationBlue,
                    ]),
              ),
            ),
          ],
        ));
  }
}
