import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ink_page_indicator/ink_page_indicator.dart';
import 'package:one_d_m/components/big_button.dart';
import 'package:one_d_m/extensions/theme_extensions.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import 'choose_login_method.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  PageIndicatorController _pageController = PageIndicatorController();
  double? _page = 0.0;
  late ValueNotifier<double> _pageNotifier;

  @override
  void initState() {
    super.initState();
    context
        .read<FirebaseAnalytics>()
        .setCurrentScreen(screenName: "Welcome Screen");
    _pageNotifier = ValueNotifier(0.0);
    _pageController.addListener(() {
      _pageNotifier.value = _pageController.page ?? 0;
      setState(() {
        _page = _pageController.page;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(context.theme.darkMode
        ? SystemUiOverlayStyle.light
        : SystemUiOverlayStyle.dark);

    return Scaffold(
      body: Stack(
        children: <Widget>[
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            top: 0,
            child: PageView(
              controller: _pageController,
              children: <Widget>[
                _WelcomePage(
                  svgName: "img_odm_logo",
                  title: "Wir sind\n One Dollar Movement!",
                  titleText: AutoSizeText.rich(
                    TextSpan(children: [
                      TextSpan(
                          text: "Wir sind\n",
                          style: TextStyle(fontWeight: FontWeight.w300)),
                      TextSpan(
                          text: "One Dollar Movement",
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: context.theme.colorScheme.primary)),
                    ]),
                    style: Theme.of(context).textTheme.headline4!.copyWith(
                        color: context.theme.colorScheme.onBackground),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                  ),
                  description:
                      "Wir möchten mit One Dollar Movement Spenden kostenlos, einfach und alltäglich machen.",
                  animatedValue: _getAnimatedValue(0, _page!),
                  onPressed: () => _animateToPage(1),
                ),
                _WelcomePage(
                    svgName: "img_session",
                    title: "Sessions",
                    description:
                        "Sessions sind „Profile“ von bekannten Menschen mit großer Reichweite in Sozialen Netzwerken, die sich auf ein ausgewähltes Projekt fokussieren und dieses unterstützen.",
                    animatedValue: _getAnimatedValue(1, _page!),
                    onPressed: () => _animateToPage(2)),
                _WelcomePage(
                    svgName: "img_project",
                    title: "Projekte",
                    description:
                        "Jedes Projekt widmet sich einem Problem auf dieser Erde. Du kannst dabei Tiere, Menschen oder die Umwelt unterstützen. Mit einem Klick.",
                    darkText: true,
                    animatedValue: _getAnimatedValue(2, _page!),
                    onPressed: () => _animateToPage(3)),
                _WelcomePage(
                  svgName: "img_push",
                  title: "Push Nachrichten",
                  description:
                      "Push Nachrichten halten dich über Sessions, Projekte und Freunde auf dem laufenden.",
                  darkText: true,
                  isPermission: true,
                  animatedValue: _getAnimatedValue(3, _page!),
                  onPressed: () async {
                    _requestNotificationPermission()
                        .then((value) => _animateToPage(4));
                  },
                ),
                _WelcomePage(
                  svgName: "img_contact",
                  title: "Finde Deine Freunde",
                  description:
                      "Damit Du deine Freunde findest, benötigen wir deine Erlaubnis um auf das Kontaktbuch zuzugreifen. Deine Kontakte werden an niemanden weitergegeben und sind bei uns sicher.",
                  animatedValue: _getAnimatedValue(4, _page!),
                  onPressed: () async {
                    await _getPermission();

                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ChooseLoginMethodPage()));
                  },
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              minimum: EdgeInsets.only(bottom: 15),
              child: InkPageIndicator(
                gap: 18,
                padding: 0,
                shape: IndicatorShape.circle(6),
                inactiveColor: context.theme.primaryColor.withOpacity(.4),
                activeColor: context.theme.primaryColor,
                inkColor: context.theme.primaryColor,
                page: _pageNotifier,
                pageCount: 5,
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<PermissionStatus> _getPermission() async {
    final PermissionStatus permission = await Permission.contacts.status;
    if (permission != PermissionStatus.granted) {
      final Map<Permission, PermissionStatus> permissionStatus =
          await [Permission.contacts].request();
      return permissionStatus[Permission.contacts] ?? PermissionStatus.denied;
    } else {
      return permission;
    }
  }

  Future<PermissionStatus> _requestNotificationPermission() async {
    final PermissionStatus permission = await Permission.notification.status;
    if (permission != PermissionStatus.granted) {
      final Map<Permission, PermissionStatus> permissionStatus =
          await [Permission.notification].request();

      return permissionStatus[Permission.notification] ??
          PermissionStatus.denied;
    } else {
      return permission;
    }
  }

  double _getAnimatedValue(int index, double position) {
    double value = (index - position).abs();
    if (value <= 1.0 && value >= 0)
      return value;
    else
      return 1;
  }

  void _animateToPage(int page) {
    _pageController.animateToPage(page,
        duration: Duration(milliseconds: 400), curve: Curves.easeInOut);
  }
}

class _WelcomePage extends StatelessWidget {
  final String? svgName, imageName, title, description;
  final double? animatedValue;
  final AutoSizeText? titleText;
  final VoidCallback? onPressed;
  final int index;
  final bool isPermission, loading, darkText;

  _WelcomePage(
      {this.svgName,
      this.imageName,
      this.title,
      this.titleText,
      this.description,
      this.animatedValue,
      this.onPressed,
      this.index = -1,
      this.darkText = true,
      this.loading = false,
      this.isPermission = false});

  late final TextTheme _textTheme;

  @override
  Widget build(BuildContext context) {
    _textTheme = Theme.of(context).textTheme;
    return Transform.scale(
      scale: Tween<double>(begin: 1.0, end: .75).transform(animatedValue!),
      child: Opacity(
        opacity: 1 - animatedValue!,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                svgName == null
                    ? Image.asset(
                        "assets/images/$imageName",
                      )
                    : SvgPicture.asset(
                        "assets/images/$svgName.svg",
                        height: MediaQuery.of(context).size.height * .25,
                        placeholderBuilder: (context) => Container(
                          height: MediaQuery.of(context).size.height * .25,
                        ),
                      ),
                SizedBox(
                  height: 20,
                ),
                titleText ??
                    AutoSizeText(
                      title!,
                      maxLines: 1,
                      style: _textTheme.headline3!.copyWith(
                          color: context.theme.colorScheme.onBackground),
                      textAlign: TextAlign.center,
                    ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  description!,
                  style: _textTheme.subtitle2!
                      .copyWith(fontWeight: FontWeight.normal),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 20,
                ),
                isPermission
                    ? BigButton(
                        onPressed: onPressed,
                        color: context.theme.colorScheme.secondary,
                        label: "Erlauben",
                      )
                    : FloatingActionButton(
                        onPressed: onPressed,
                        child: Icon(
                          Icons.arrow_forward,
                        ),
                        elevation: 0,
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AutoSizeTextWidget extends StatelessWidget {
  final String? text;

  const AutoSizeTextWidget({Key? key, this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
