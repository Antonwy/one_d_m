import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
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
import 'package:one_d_m/Pages/OrganisationPage.dart';
import 'package:one_d_m/chart/circle_painter.dart';
import 'package:provider/provider.dart';
import 'package:rive/rive.dart';

import 'DiscoveryHolder.dart';

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
  MediaQueryData _mq;
  double _selectedValue = 0;

  ///dv animation variables
  bool _isAnim = false;
  double _dv = 0;
  int _currentIndex = 0;
  String _currentAnimation = '+1';
  Artboard _riveArtboard;
  RiveAnimationController _controller;

  Stream<AdBalance> _adbalanceStream;

  Future<Artboard> _futureRiveArtboard;

  @override
  void initState() {
    _selectedValue = widget.defaultSelectedAmount.toDouble();
    _isAnim = widget.campaign.dvAnimation?.isNotEmpty ?? false;
    _adbalanceStream =
        DatabaseService.getAdBalance(widget.user?.id ?? widget.uid);

    _adbalanceStream.listen((event) {
      if (event.dcBalance < _selectedValue) {
        _selectedValue = 0;
      }
      if (_isAnim) {
        if (event.dcBalance >= widget.campaign.dvController) {
          _selectedValue = widget.campaign.dvController.toDouble();
        } else {
          _currentAnimation = '-0';
        }
      }
    });

    if (_isAnim) {
      _futureRiveArtboard = _loadAndCacheRive();
    }

    context
        .read<FirebaseAnalytics>()
        .setCurrentScreen(screenName: "Donation Dialog");

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      FeatureDiscovery.discoverFeatures(
          context, DiscoveryHolder.donationDialogFeatures);
    });

    super.initState();
  }

  Future<Artboard> _loadAndCacheRive() async {
    try {
      final cacheManager = DefaultCacheManager();
      FileInfo fileInfo = await cacheManager.getFileFromCache(
          widget.campaign.dvAnimation); // Get video from cache first

      if (fileInfo?.file == null) {
        fileInfo = await cacheManager.downloadFile(widget.campaign.dvAnimation);
      }

      Uint8List list = await fileInfo.file.readAsBytes();
      ByteData byteData = ByteData.view(list.buffer);

      final file = RiveFile();

      if (file.import(byteData)) {
        final artboard = file.mainArtboard;

        artboard
            .addController(_controller = SimpleAnimation(_currentAnimation));
        _riveArtboard = artboard;
        return artboard;
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    _theme = Theme.of(context);
    _bTheme = ThemeManager.of(context).colors;
    _mq = MediaQuery.of(context);
    return ChangeNotifierProvider<DonationDialogManager>(
        create: (context) => DonationDialogManager(
              adBalanceStream: _adbalanceStream,
              defaultSelectedAmount: _selectedValue.toInt(),
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
                  if (_isAnim && mounted) {
                    if (ddm.adBalance.dcBalance >=
                        widget.campaign.dvController) {
                      ddm.setAmountWithoutRebuild(_selectedValue.toInt());
                    }
                  }
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
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      !_isAnim
                                          ? _buildheading(
                                              widget.campaign?.imgUrl ?? "",
                                              widget.campaign?.blurHash,
                                              widget.campaign?.name ??
                                                  "Not found",
                                              widget.campaign?.authorId ?? "")
                                          : _buildHeadingAnimation(),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      Align(
                                        alignment: Alignment.center,
                                        child: AnimatedSwitcher(
                                          duration:
                                              const Duration(milliseconds: 0),
                                          child: Text(
                                            _buildAmountText(),
                                            style: _theme.accentTextTheme.button
                                                .copyWith(
                                                    fontSize: 21,
                                                    fontWeight: FontWeight.bold,
                                                    color: _bTheme.dark),
                                            key: ValueKey(_selectedValue),
                                          ),
                                        ),
                                      ),
                                      const YMargin(5),
                                      Align(
                                        alignment: Alignment.center,
                                        child: Text(
                                          !_isAnim
                                              ? 'von ${ddm?.adBalance?.dcBalance ?? 0} DV'
                                              : 'mit ${_selectedValue.toInt()} von ${ddm.adBalance?.dcBalance ?? 0} DVs unterstützen',
                                          style: _theme.textTheme.subtitle1
                                              .copyWith(
                                                  fontSize: 12,
                                                  color: Colors.black54),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                              flex: 1,
                                              child:
                                                  DiscoveryHolder.donationSub(
                                                tapTarget: Text(
                                                  "-",
                                                  style: TextStyle(
                                                      color: _bTheme.contrast,
                                                      fontSize: 28,
                                                      fontWeight:
                                                          FontWeight.w300),
                                                ),
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
                                                        icon: Text(
                                                          "-",
                                                          style: TextStyle(
                                                              fontSize: 28,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w300),
                                                        ),
                                                        color: _bTheme.dark,
                                                        onPressed: () {
                                                          if (_selectedValue >
                                                                  0 &&
                                                              _selectedValue >
                                                                  widget
                                                                      .campaign
                                                                      .dvController) {
                                                            HapticFeedback
                                                                .heavyImpact();
                                                            setState(() {
                                                              _selectedValue -=
                                                                  widget
                                                                      .campaign
                                                                      .dvController;
                                                              ddm.amount =
                                                                  _selectedValue
                                                                      .toInt();
                                                              _switchRiveAnimation(
                                                                  _selectedValue);
                                                            });
                                                          }
                                                        }),
                                                  ),
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
                                              child:
                                                  DiscoveryHolder.donationAdd(
                                                tapTarget: Icon(
                                                  Icons.add,
                                                  color: _bTheme.contrast,
                                                ),
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
                                                        icon: Icon(Icons.add),
                                                        color: _bTheme.light,
                                                        onPressed: () {
                                                          if ((ddm?.adBalance
                                                                      ?.dcBalance ??
                                                                  0) >=
                                                              _selectedValue +
                                                                  widget
                                                                      .campaign
                                                                      .dvController) {
                                                            HapticFeedback
                                                                .heavyImpact();
                                                            setState(() {
                                                              _selectedValue +=
                                                                  widget
                                                                      .campaign
                                                                      .dvController;
                                                              ddm.amount =
                                                                  _selectedValue
                                                                      .toInt();
                                                              _switchRiveAnimation(
                                                                  _selectedValue);
                                                            });
                                                          } else {
                                                            Helper.showAlert(
                                                                context,
                                                                "Du musst mehr DVs sammeln um weiter spenden zu können.",
                                                                title:
                                                                    "Zu wenig DVs!");
                                                          }
                                                        }),
                                                  ),
                                                ),
                                              ))
                                        ],
                                      ),
                                      const YMargin(20),
                                      Align(
                                        alignment: Alignment.center,
                                        child: Builder(builder: (context) {
                                          List<String> dEffects = widget
                                                  .campaign?.donationEffects ??
                                              [];
                                          String effect = dEffects.isEmpty
                                              ? ""
                                              : dEffects[new Random(42)
                                                  .nextInt(dEffects.length)];
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 0.0, horizontal: 8.0),
                                            child: Text(
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
                                            ),
                                          );
                                        }),
                                      ),
                                      const YMargin(20),
                                      Align(
                                        alignment: Alignment.center,
                                        child: DonationButton(
                                            campaign: widget.campaign,
                                            user: widget.user,
                                            uid: widget.uid),
                                      ),
                                      AnimatedContainer(
                                        curve: Curves.fastOutSlowIn,
                                        duration: Duration(milliseconds: 350),
                                        height: ddm.showAnimation
                                            ? _mq.size.height *
                                                (_isAnim ? .35 : .45)
                                            : _mq.size.height * .05,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              ddm.showAnimation
                                  ? DonationAnimationWidget(widget.close)
                                  : SizedBox.shrink()
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }))));
  }

  String _buildAmountText() {
    int amount = !_isAnim
        ? _selectedValue.toInt()
        : _selectedValue ~/ widget.campaign.dvController;

    return !_isAnim
        ? '$amount DV'
        : '$amount ${(amount == 1 ? widget.campaign.singularUnit : widget.campaign.unit) ?? 'DV'}';
  }

  void _switchRiveAnimation(double selectedDv) {
    if (_isAnim) {
      int index = _selectedValue ~/ widget.campaign.dvController;
      var direction = _dv < selectedDv ? '+' : '-';
      //prevent playing same animation again
      if (_currentIndex == index || index > widget.campaign.maxAnimCount)
        return;

      _dv = selectedDv;
      _currentIndex = index;
      _currentAnimation = '$direction$index';
      //change animation name
      print('Current animation:$_currentAnimation');
      _riveArtboard.removeController(_controller);
      _riveArtboard
          .addController(_controller = SimpleAnimation(_currentAnimation));
    }
  }

  Widget _buildHeadingAnimation() => FutureBuilder(
      future: _futureRiveArtboard,
      builder: (context, snapshot) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(18.0),
          child: Container(
              width: double.infinity,
              height: 180,
              child: !snapshot.hasData
                  ? SizedBox.shrink()
                  : Rive(
                      fit: BoxFit.fitWidth,
                      artboard: _riveArtboard,
                    )),
        );
      });

  Widget _buildheading(
          String url, String blurHash, String title, String authorId) =>
      Row(
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
                placeholder: (context, url) => blurHash != null
                    ? BlurHash(hash: blurHash)
                    : Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(
                                ThemeManager.of(context).colors.dark,
                              )),
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
                Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: AutoSizeText(
                    title,
                    maxLines: 1,
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.headline5.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _bTheme.dark),
                  ),
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
  final User user;
  final String uid;

  DonationButton({this.campaign, this.user, this.uid});

  @override
  Widget build(BuildContext context) {
    _theme = Theme.of(context);
    _bTheme = ThemeManager.of(context).colors;
    ddm = Provider.of<DonationDialogManager>(context);
    this.context = context;

    return DiscoveryHolder.supportButton(
      tapTarget: Icon(
        Icons.euro,
        color: _bTheme.contrast,
      ),
      child: Padding(
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
                        style: _theme.accentTextTheme.button.copyWith(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
              );
            }),
      ),
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
    try {
      await context
          .read<FirebaseAnalytics>()
          ?.logEvent(name: "Donation", parameters: {
        "amount": donation.amount,
        "campaign": donation.campaignName,
        "session": donation?.sessionId ?? ""
      });
    } catch (e) {
      print(e);
    }

    ddm.setLoadingWithoutRebuild(false);
    ddm.showAnimation = true;
  }
}

class DonationAnimationWidget extends StatelessWidget {
  ThemeManager _bTheme;
  ThemeData _theme;
  final Function close;

  DonationAnimationWidget(this.close);

  @override
  Widget build(BuildContext context) {
    _bTheme = ThemeManager.of(context);
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
                          context, ddm.campaign, ddm.amount, close),
                )),
          ));
    });
  }

  Widget _buildThankYou(BuildContext context, Campaign campaign, int amount,
          Function close) =>
      Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
        child: MediaQuery.removePadding(
          removeTop: true,
          context: context,
          child: StaggeredGridView.count(
            crossAxisCount: 4,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: [
              _buildThankTitle(context, close),
              _buildInfoContent(context, campaign),
              _buildDonatedAmountContent(amount, campaign),
              _buildCampaignImage(campaign.imgUrl),
              _buildChartContent(context),
              _buildReadMore(context, campaign, close),
              _buildThanksContent(context),
              _buildContinueButton(context, close),
            ],
            staggeredTiles: [
              StaggeredTile.fit(4),
              StaggeredTile.fit(2),
              StaggeredTile.fit(2),
              StaggeredTile.fit(2),
              StaggeredTile.fit(2),
              StaggeredTile.fit(2),
              StaggeredTile.fit(2),
              StaggeredTile.fit(2),
            ],
          ),
        ),
      );

  Widget _buildThankTitle(BuildContext context, Function close) => Padding(
        padding: const EdgeInsets.only(bottom: 8.0, top: 24),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Vielen Dank!',
                style: _bTheme.textTheme.dark.headline5,
              ),
            ),
            Material(
              color: _bTheme.colors.dark.withOpacity(.1),
              shape: CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: close,
                child: Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Icon(
                    Icons.close,
                    size: 18,
                    color: _bTheme.colors.dark,
                  ),
                ),
              ),
            )
          ],
        ),
      );

  Widget _buildInfoContent(BuildContext context, Campaign campaign) {
    bool _showCustomEffect =
        campaign.effects.where((el) => el.isNotEmpty).isNotEmpty;
    return Container(
      height: _showCustomEffect ? null : 200,
      child: Material(
        borderRadius: BorderRadius.circular(Constants.radius),
        elevation: 1,
        color: _bTheme.colors.contrast,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: _showCustomEffect
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Was deine Spende bewirkt:",
                      style: _bTheme.textTheme.textOnContrast.headline6
                          .copyWith(fontSize: 16),
                    ),
                    YMargin(6),
                    for (String effect in campaign.effects)
                      Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('•'),
                              XMargin(6),
                              Expanded(
                                child: Text(
                                  '$effect',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText1
                                      .copyWith(
                                          fontSize: 15,
                                          color: _bTheme.colors.dark,
                                          fontWeight: FontWeight.w400),
                                ),
                              ),
                            ],
                          ),
                          YMargin(4),
                        ],
                      ),
                  ],
                )
              : Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      child: Image(
                        image: AssetImage('assets/icons/ic_flower.png'),
                      ),
                    ),
                    Consumer<UserManager>(
                        builder: (context, um, child) => StreamBuilder<User>(
                            initialData: um.user,
                            stream: DatabaseService.getUserStream(um.uid),
                            builder: (context, snapshot) {
                              User user = snapshot.data;
                              return Expanded(
                                child: Center(
                                  child: RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                            text: "${user.name}",
                                            style: _bTheme.textTheme
                                                .textOnContrast.bodyText1),
                                        TextSpan(
                                          text:
                                              ', du hast die Welt ein kleines Stück besser gemacht!',
                                        ),
                                      ],
                                      style: _bTheme
                                          .textTheme.textOnContrast.bodyText2,
                                    ),
                                  ),
                                ),
                              );
                            }))
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildDonatedAmountContent(int amount, Campaign campaign) {
    return Material(
      elevation: 1,
      borderRadius: BorderRadius.all(Radius.circular(Constants.radius)),
      color: _bTheme.colors.dark,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              children: [
                Text('Du hast ', style: _bTheme.textTheme.textOnDark.headline6),
                NumberSlideAnimation(
                  number: "${(amount / campaign.dvController).round()}",
                  duration: const Duration(seconds: 3),
                  curve: Curves.bounceIn,
                  textStyle: _bTheme.textTheme.textOnDark.headline6.copyWith(
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline),
                ),
                Text(' ${campaign.unitSmiley ?? campaign.unit ?? "DV"}',
                    style: _bTheme.textTheme.textOnDark.headline6),
                Text('gespendet!',
                    style: _bTheme.textTheme.textOnDark.headline6),
              ],
            ),
            SizedBox(
              height: 5,
            ),
            Text('Das entspricht ${amount * 5} Cent',
                style: _theme.textTheme.subtitle2
                    .copyWith(color: _bTheme.colors.light.withOpacity(.7))),
          ],
        ),
      ),
    );
  }

  Widget _buildCampaignImage(String imageUrl) => Material(
        borderRadius: BorderRadius.circular(Constants.radius),
        elevation: 1,
        clipBehavior: Clip.antiAlias,
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          imageBuilder: (_, imgProvider) => Container(
            height: 240,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: imgProvider,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      );

  Widget _buildReadMore(
          BuildContext context, Campaign campaign, Function function) =>
      Material(
        color: _bTheme.colors.contrast,
        borderRadius: BorderRadius.circular(Constants.radius),
        elevation: 1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 7),
              child: AutoSizeText(
                campaign.name,
                style: _bTheme.textTheme.textOnContrast.headline6,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: AutoSizeText(
                campaign.shortDescription,
                style: _bTheme.textTheme.textOnContrast.bodyText2,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Divider(),
            Padding(
              padding: const EdgeInsets.only(left: 0.0, bottom: 8),
              child: FlatButton(
                  textColor: _bTheme.colors.textOnContrast,
                  child: Text('MEHR LESEN'),
                  onPressed: function),
            )
          ],
        ),
      );

  Widget _buildChartContent(BuildContext context) {
    return Container(
      height: 240,
      width: MediaQuery.of(context).size.width,
      child: Material(
        borderRadius: BorderRadius.all(Radius.circular(Constants.radius)),
        color: _bTheme.colors.dark,
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Was mit deiner Spende passiert:',
                style: _bTheme.textTheme.textOnDark.bodyText1,
              ),
              YMargin(6),
              Container(
                height: 100,
                child: Center(
                  child: PercentCircle(
                    percent: 14,
                  ),
                ),
              ),
              YMargin(12),
              FieldWidget(
                amount: '70',
                title: 'erhält das Projekt',
                color: ColorTheme.donationRed,
              ),
              YMargin(6),
              FieldWidget(
                amount: '25',
                title: 'Advertising',
                color: ColorTheme.donationLightBlue,
              ),
              YMargin(6),
              FieldWidget(
                  amount: '5',
                  title: 'erhält ODM',
                  color: ColorTheme.donationBlue)
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThanksContent(BuildContext context) => Material(
        borderRadius: BorderRadius.all(Radius.circular(Constants.radius)),
        color: _bTheme.colors.contrast,
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Weiter so!',
                style: _bTheme.textTheme.textOnContrast.headline6,
              ),
              SizedBox(
                height: 6,
              ),
              Text(
                  'Sammle DV, spende sie und löse mit unserer Community globale Probleme!',
                  style: _bTheme.textTheme.textOnContrast.bodyText2),
            ],
          ),
        ),
      );

  Widget _buildContinueButton(BuildContext context, Function function) =>
      Container(
        width: double.infinity,
        height: 55,
        child: Material(
          clipBehavior: Clip.antiAlias,
          elevation: 1,
          borderRadius: BorderRadius.circular(Constants.radius),
          color: _bTheme.colors.dark,
          child: InkWell(
            onTap: function,
            child: Center(
              child: Text(
                'WEITER',
                style: TextStyle(
                    color: _bTheme.colors.textOnDark,
                    fontWeight: FontWeight.w600),
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
    return Row(
      children: [
        Container(
          height: 12,
          width: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        XMargin(6),
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
              Expanded(
                child: AutoSizeText(
                  title,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: Theme.of(context).textTheme.subtitle1.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: ThemeManager.of(context).colors.light),
                ),
              )
            ],
          ),
        )
      ],
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
    return Stack(
      alignment: Alignment.center,
      children: [
        Text(
          '100%',
          style: TextStyle(
            color: _theme.colors.light,
            fontWeight: FontWeight.w700,
            fontSize: 13.0,
          ),
        ),
        Container(
          height: 2 * radius,
          width: 2 * radius,
          child: CustomPaint(
            size: Size(2 * radius, 2 * radius),
            painter: CirclePainter(600, 600, startAngle: 0, colors: [
              ColorTheme.donationRed,
              ColorTheme.donationLightBlue,
              ColorTheme.donationBlue,
            ]),
          ),
        ),
      ],
    );
  }
}
