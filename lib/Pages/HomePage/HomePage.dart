import 'dart:async';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/Components/DiscoveryHolder.dart';
import 'package:one_d_m/Components/NavBar.dart';
import 'package:one_d_m/Helper/ColorTheme.dart';
import 'package:one_d_m/Helper/Constants.dart';
import 'package:one_d_m/Helper/DialogHolder.dart';
import 'package:one_d_m/Helper/DynamicLinkManager.dart';
import 'package:one_d_m/Helper/GoalPageManager.dart';
import 'package:one_d_m/Helper/NavBarManager.dart';
import 'package:one_d_m/Helper/RemoteConfigManager.dart';
import 'package:one_d_m/Helper/UserManager.dart';
import 'package:one_d_m/Pages/HomePage/GoalPage.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ExplorePage.dart';
import 'ProfilePage.dart';

class HomePage extends StatefulWidget {
  Future initFuture;
  HomePage({Key key, this.initFuture}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final GlobalKey<ProfilePageState> profileGlobalKey =
      new GlobalKey<ProfilePageState>();

  PageController _pageController = PageController(
    initialPage: 1,
    keepPage: false,
  );
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    DynamicLinkManager.of(context).initialize();

    FirebaseAnalytics analytics = context.read<FirebaseAnalytics>();
    analytics.setCurrentScreen(screenName: "HomeScreen");

    Future.wait([
      widget.initFuture ?? Future.value(),
      Future.delayed(Duration(seconds: 1))
    ]).then((v) async {
      await _createDialogQueue();
      FeatureDiscovery.discoverFeatures(context, DiscoveryHolder.features);
      print(DiscoveryHolder.features);
    });
  }

  Future<void> _createDialogQueue() async {
    StartupDialogManager sdm = StartupDialogManager(context,
        isFirstStart: context.read<UserManager>().firstSignIn);
    sdm.addDialogToQueue(
        StartDialogModel(DialogHolder.showWelcomeDialog, onFirstStart: true));
    print("SHOULD UPDATE: ${context.read<RemoteConfigManager>().shouldUpdate}");
    if (await _shouldShowVersionDialog())
      sdm.addDialogToQueue(StartDialogModel(DialogHolder.showUpdateAppDialog));

    return sdm.showDialogs();
  }

  Future<bool> _shouldShowVersionDialog() async {
    RemoteConfigManager _rcm = context.read<RemoteConfigManager>();
    if (!_rcm.shouldUpdate) return false;

    SharedPreferences _prefs = await SharedPreferences.getInstance();
    int _versionNumber =
        _prefs.getInt(Constants.UPDATE_DIALOG_DO_NOT_REMIND_AGAIN) ?? -1;
    print(_versionNumber);

    if (_versionNumber == -1) return true;

    if (_versionNumber == (int.tryParse(_rcm.packageInfo.buildNumber) ?? 1))
      return false;

    return true;
  }

  void _logPageChanges(int page) {
    FirebaseAnalytics analytics = context.read<FirebaseAnalytics>();
    switch (page) {
      case 0:
        analytics.logEvent(name: "Swipe to Roadmap");
        break;
      case 1:
        analytics.logEvent(name: "Swipe to Profile");
        break;
      case 2:
        analytics.logEvent(name: "Swipe to Explore");
        break;
      default:
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: ColorTheme.appBg,
        body: Stack(
          children: <Widget>[
            PageView(
              controller: _pageController,
              onPageChanged: (page) {
                _logPageChanges(page);
                if (page == 0) {
                  setState(() {});
                  profileGlobalKey.currentState.toggleVisible();
                }
                _resetPageScroll();
              },
              children: <Widget>[
                ChangeNotifierProvider(
                    create: (_) => GoalPageManager(),
                    builder: (context, child) => GoalPage()),
                Provider<Future<void> Function(int)>(
                    create: (context) => _changePage,
                    builder: (context, child) {
                      return ProfilePage(
                        key: profileGlobalKey,
                        scrollController: _scrollController,
                      );
                    }),
                // NewsHomePage(() => _changePage(2)),
                ExplorePage(
                  scrollController: _scrollController,
                ),
              ],
            ),
            ChangeNotifierProvider(
              create: (context) => NavBarManager(_pageController),
              child: NavBar(_changePage),
            )
          ],
        ));
  }

  Future<void> _changePage(int page) async {
    await _pageController.animateToPage(page,
        duration: Duration(milliseconds: 200), curve: Curves.fastOutSlowIn);
    _resetPageScroll();
  }

  void _resetPageScroll() {
    _scrollController.animateTo(
      0.0,
      curve: Curves.easeOut,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class StartupDialogManager {
  final BuildContext context;
  final bool isFirstStart;
  List<StartDialogModel> _dialogQueue = [];

  StartupDialogManager(this.context, {this.isFirstStart = false});

  void addDialogToQueue(StartDialogModel dialogModel) {
    _dialogQueue.add(dialogModel);
  }

  Future showDialogs() async {
    print("SHOWING DIALOGS");
    while (_dialogQueue.isNotEmpty) {
      print("SHOW DIALOG");
      await _showDialog(_dialogQueue.removeAt(0));
      await Future.delayed(Duration(milliseconds: 500));
    }
  }

  Future _showDialog(StartDialogModel model) async {
    if (model.onFirstStart && !isFirstStart) return;

    await model.build(context);
  }
}

class StartDialogModel {
  final bool onFirstStart;
  final Future Function(BuildContext) build;

  StartDialogModel(this.build, {this.onFirstStart = false});
}
