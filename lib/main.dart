import 'dart:io';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:one_d_m/helper/color_theme.dart';
import 'package:one_d_m/provider/api_manager.dart';
import 'package:one_d_m/provider/statistics_manager.dart';
import 'package:one_d_m/provider/theme_manager.dart';
import 'package:one_d_m/provider/user_manager.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:stripe_payment/stripe_payment.dart';
import 'Helper/Constants.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'api/api.dart';
import 'components/page_manager_widget.dart';
import 'helper/native_ads.dart';
import 'provider/remote_config_manager.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Hive.initFlutter();
  await Api().init();

  MobileAds.instance.initialize();

  timeago.setLocaleMessages('de', timeago.DeMessages());

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (context) => UserManager.instance()),
    ChangeNotifierProvider(create: (context) => ThemeManager(context)),
    ChangeNotifierProvider(create: (context) => StatisticsManager()),
    ChangeNotifierProvider(create: (context) => ApiManager()),
    Provider(
      create: (context) => RemoteConfigManager(),
    ),
    Provider(
      create: (context) => FirebaseAnalytics(),
    )
  ], child: ODMApp()));
}

class ODMApp extends StatefulWidget {
  @override
  _ODMAppState createState() => _ODMAppState();
}

class _ODMAppState extends State<ODMApp> {
  @override
  void initState() {
    // StripePayment.setOptions(
    //     StripeOptions(publishableKey: Constants.STRIPE_LIVE_KEY));
    getThemeIndex().then((value) {
      ThemeManager _tm = ThemeManager.of(context, listen: false);

      _tm.setThemeMode(ThemeMode.values[value], withSave: false);
    });
    // Platform.isAndroid ? NativeAds.initialize() : null;q

    Api.manager = context.read<ApiManager>();
    _precacheImages();
    super.initState();
  }

  Future<void> _precacheImages() async {
    print("STARTING PRECACHING IMAGES");
    final res = await Future.wait([
      precachePicture(
          ExactAssetPicture(
              SvgPicture.svgStringDecoder, 'assets/images/img_odm_logo.svg'),
          context),
      precachePicture(
          ExactAssetPicture(
              SvgPicture.svgStringDecoder, 'assets/images/img_session.svg'),
          context),
      precachePicture(
          ExactAssetPicture(
              SvgPicture.svgStringDecoder, 'assets/images/img_project.svg'),
          context),
      precachePicture(
          ExactAssetPicture(
              SvgPicture.svgStringDecoder, 'assets/images/img_push.svg'),
          context),
      precachePicture(
          ExactAssetPicture(
              SvgPicture.svgStringDecoder, 'assets/images/img_contact.svg'),
          context),
      precachePicture(
          ExactAssetPicture(
              SvgPicture.svgStringDecoder, 'assets/images/img_login.svg'),
          context),
      precachePicture(
          ExactAssetPicture(
              SvgPicture.svgStringDecoder, 'assets/images/verify.svg'),
          context),
      precachePicture(
          ExactAssetPicture(SvgPicture.svgStringDecoder,
              'assets/images/img_login_register.svg'),
          context),
      precachePicture(
          ExactAssetPicture(
              SvgPicture.svgStringDecoder, 'assets/images/no-news.svg'),
          context),
      precachePicture(
          ExactAssetPicture(
            SvgPicture.svgStringDecoder,
            "assets/images/welcome-gift.svg",
          ),
          context),
      precachePicture(
          ExactAssetPicture(
            SvgPicture.svgStringDecoder,
            "assets/images/no-internet.svg",
          ),
          context),
    ]);
    print("PRECACHED IMAGES");
  }

  Future<int> getThemeIndex() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(Constants.THEME_KEY) ?? Constants.DEFAULT_THEME_INDEX;
  }

  @override
  Widget build(BuildContext context) {
    return FeatureDiscovery(
      child: MaterialApp(
          title: 'One Dollar Movement',
          debugShowCheckedModeBanner: false,
          navigatorObservers: [
            FirebaseAnalyticsObserver(
                analytics: context.read<FirebaseAnalytics>()),
          ],
          themeMode: context.watch<ThemeManager>().themeMode,
          theme: ThemeData(
              primaryColor: Color.fromARGB(255, 52, 199, 89),
              primaryColorLight: Colors.grey[200],
              colorScheme: ColorScheme.light(
                  primary: Color.fromARGB(255, 52, 199, 89),
                  onPrimary: Colors.white,
                  secondary: Color.fromARGB(255, 0, 122, 255),
                  onSecondary: Colors.white,
                  onError: Colors.white,
                  onBackground: Colors.blueGrey[900]!),
              appBarTheme: AppBarTheme(
                  systemOverlayStyle: SystemUiOverlayStyle.dark,
                  backgroundColor: Colors.white,
                  titleTextStyle: TextStyle(
                      color: Colors.blueGrey[900]!,
                      fontSize: 18,
                      fontWeight: FontWeight.w500),
                  iconTheme: IconThemeData(color: Colors.blueGrey[900]!)),
              cardColor: Colors.white,
              cardTheme: CardTheme(
                  margin: EdgeInsets.zero,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      side: BorderSide(color: Colors.grey[200]!),
                      borderRadius: BorderRadius.circular(Constants.radius)),
                  clipBehavior: Clip.antiAlias),
              canvasColor: Colors.grey[200],
              brightness: Brightness.light,
              backgroundColor: Colors.white,
              scaffoldBackgroundColor: Colors.white,
              errorColor: Color.fromARGB(255, 255, 69, 58),
              buttonTheme: ButtonThemeData(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6))),
              snackBarTheme: SnackBarThemeData(
                backgroundColor: Color.fromARGB(255, 255, 59, 48),
                contentTextStyle: TextStyle(color: Colors.white),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                        top: Radius.circular(Constants.radius))),
              ),
              popupMenuTheme: PopupMenuThemeData(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6)))),
          darkTheme: ThemeData(
              primaryColor: Color.fromARGB(255, 48, 209, 88),
              primaryColorLight: Colors.grey[850],
              colorScheme: ColorScheme.dark(
                  primary: Color.fromARGB(255, 48, 209, 88),
                  onPrimary: Colors.white,
                  secondary: Color.fromARGB(255, 10, 132, 255),
                  onSecondary: Colors.white,
                  onError: Colors.white,
                  background: Colors.blueGrey[900]!),
              cardColor: Colors.grey[900],
              canvasColor: Color.fromARGB(255, 44, 44, 46),
              cardTheme: CardTheme(
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(Constants.radius)),
                  clipBehavior: Clip.antiAlias),
              brightness: Brightness.dark,
              scaffoldBackgroundColor: Colors.black,
              backgroundColor: Colors.black,
              errorColor: Color.fromARGB(255, 255, 69, 58),
              buttonTheme: ButtonThemeData(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6))),
              snackBarTheme: SnackBarThemeData(
                backgroundColor: Color.fromARGB(255, 255, 69, 58),
                contentTextStyle: TextStyle(color: Colors.white),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                        top: Radius.circular(Constants.radius))),
              ),
              popupMenuTheme: PopupMenuThemeData(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6)))),
          home: PageManagerWidget()),
    );
  }
}
