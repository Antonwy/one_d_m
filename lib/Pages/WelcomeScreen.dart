import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ink_page_indicator/ink_page_indicator.dart';
import 'package:one_d_m/Helper/ColorTheme.dart';
import 'package:permission_handler/permission_handler.dart';

import 'ChooseLoginMethodPage.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  PageIndicatorController _pageController = PageIndicatorController();
  double _page = 0.0;

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _page = _pageController.page;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorTheme.whiteBlue,
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
                  svgName: "welcome-2",
                  title: "Wir sind\n One Dollar Movement!",
                  titleText: AutoSizeText.rich(
                    TextSpan(children: [
                      TextSpan(
                          text: "Wir sind\n",
                          style: TextStyle(fontWeight: FontWeight.w200)),
                      TextSpan(
                          text: "One Dollar Movement",
                          style: TextStyle(fontWeight: FontWeight.w500)),
                    ]),
                    style: Theme.of(context)
                        .textTheme
                        .headline4
                        .copyWith(color: ColorTheme.blue),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                  ),
                  description:
                      "Wir wollen das Unterstützen von wohltätigen Organisationen einfach, schnell und kostenlos machen. Vernetze dich mit deinen Freunden, verteile Donation Votes an Projekte und mache die Welt zu einem besseren Ort!",
                  animatedValue: _getAnimatedValue(0, _page),
                  onPressed: () => _animateToPage(1),
                ),
                _WelcomePage(
                    svgName: "donation-credits",
                    title: "Donation Votes",
                    description:
                        "Ein Donation Credit entspricht 10 Cent. Wir verteilen Donation Votes je nach Aktivität an Dich und deine Freunde!",
                    darkText: true,
                    animatedValue: _getAnimatedValue(1, _page),
                    onPressed: () => _animateToPage(2)),
                _WelcomePage(
                    svgName: "landing-page",
                    title: "Sessions",
                    description:
                        "Du kannst öffentlichen Sessions beitreten oder Deine eigene Session erstellen! Zusammen mit deinen Freunden und weiteren Nutzern könnt ihr Donation Votes an Organisationen/Projekte verteilen!",
                    animatedValue: _getAnimatedValue(2, _page),
                    onPressed: () => _animateToPage(3)),
                _WelcomePage(
                    svgName: "projects",
                    title: "Projekte",
                    description:
                        "Die Projekte die auf unserer Plattform vertreten sind, wurden sorgfältig ausgewählt. Neben der Sicherheit zielt unser Auswahlprozess auch darauf ab, ein möglichst vielfältiges Projektangebot anbieten zu können.",
                    darkText: true,
                    animatedValue: _getAnimatedValue(3, _page),
                    onPressed: () => _animateToPage(4)),
                _WelcomePage(
                    svgName: "explore",
                    title: "Entdecken",
                    description:
                        "Um neue Projekte entdecken zu können haben wir eine „Entdecken“ Seite eingebaut. Dort werden die neusten Projekte und Nutzer angezeigt.",
                    animatedValue: _getAnimatedValue(4, _page),
                    onPressed: () => _animateToPage(5)),
                _WelcomePage(
                  svgName: "donation",
                  title: "Ablauf",
                  description:
                      "Durch jede Ad-Impression erhalten wir Geld von unseren Werbenetzwerken. Das eingenommene Geld wird prozentual, je nach Aktivität, auf die Nutzer verteilt und am Ende des Monats an die von den Nutzern ausgewählten Projekte/Organisationen überwiesen. Dabei befindet sich das Geld zu keinem Zeitpunkt auf dem Konto der Nutzer. Dadurch werden unnötigen Transaktionen zwischen den Nutzern und One Dollar Movement vermieden.",
                  animatedValue: _getAnimatedValue(5, _page),
                  onPressed: () => _animateToPage(6),
                ),
                _WelcomePage(
                  svgName: "contacts",
                  title: "Berechtigungen",
                  description:
                      "Damit wir dir eine angenehme User-Experience geben können, brauchen wir einige Berechtigungen von dir.",
                  animatedValue: _getAnimatedValue(6, _page),
                  onPressed: _loading
                      ? null
                      : () async {
                          setState(() {
                            _loading = true;
                          });

                          await _getPermission();

                          await FirebaseMessaging()
                              .requestNotificationPermissions(
                                  IosNotificationSettings());

                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      ChooseLoginMethodPage()));
                        },
                  isLastPage: true,
                  loading: _loading,
                ),
              ],
            ),
          ),
          _page != 6
              ? Positioned(
                  top: 0,
                  right: 10,
                  child: SafeArea(
                      child: FlatButton(
                          onPressed: () {
                            _animateToPage(6);
                          },
                          child: Text(
                            "Überspringen",
                            style: TextStyle(color: ColorTheme.blue),
                          ))))
              : Container(),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              minimum: EdgeInsets.only(bottom: 15),
              child: InkPageIndicator(
                gap: 18,
                padding: 0,
                shape: IndicatorShape.circle(6),
                inactiveColor: ColorTheme.blue.withOpacity(.2),
                activeColor: ColorTheme.blue,
                inkColor: ColorTheme.blue,
                controller: _pageController,
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
      return permissionStatus[Permission.contacts] ??
          PermissionStatus.undetermined;
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
        duration: Duration(milliseconds: 400),);
  }
}

class _WelcomePage extends StatelessWidget {
  String svgName, imageName, title, description;
  double animatedValue;
  AutoSizeText titleText;
  VoidCallback onPressed;
  bool isLastPage, loading, darkText;

  _WelcomePage(
      {this.svgName,
      this.imageName,
      this.title,
      this.titleText,
      this.description,
      this.animatedValue,
      this.onPressed,
      this.darkText = true,
      this.loading = false,
      this.isLastPage = false});

  TextTheme _textTheme;
  MediaQueryData _mq;

  @override
  Widget build(BuildContext context) {
    _textTheme = Theme.of(context).textTheme;
    _mq = MediaQuery.of(context);
    return AnimatedOpacity(
      duration: const Duration(seconds: 1),
      opacity: 1 - animatedValue,
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
                    title,
                    maxLines: 1,
                    style: _textTheme.headline3.copyWith(
                      color:
                          darkText ? ColorTheme.blue : ColorTheme.whiteBlue,
                    ),
                    textAlign: TextAlign.center,
                  ),
              SizedBox(
                height: 10,
              ),
              Text(
                description,
                style: _textTheme.subtitle2.copyWith(
                    color: darkText
                        ? ColorTheme.blue
                        : ColorTheme.whiteBlue),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 20,
              ),
              isLastPage
                  ? Column(
                      children: <Widget>[
                        FloatingActionButton.extended(
                          heroTag: "",
                          onPressed: onPressed,
                          label: Text("Berechtigen"),
                          icon: loading
                              ? Container(
                                  width: 30,
                                  height: 30,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation(
                                        ColorTheme.blue),
                                  ),
                                )
                              : Icon(Icons.done),
                          elevation: 0,
                          backgroundColor: ColorTheme.blue,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        FloatingActionButton.extended(
                          icon: Icon(Icons.not_interested),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (c) =>
                                        ChooseLoginMethodPage()));
                          },
                          label: Text("Nicht berechtigen"),
                          elevation: 0,
                          backgroundColor: ColorTheme.blue,
                        ),
                      ],
                    )
                  : FloatingActionButton(
                      onPressed: onPressed,
                      child: Icon(
                        Icons.arrow_forward,
                        color: darkText
                            ? ColorTheme.blue
                            : ColorTheme.whiteBlue,
                      ),
                      elevation: 0,
                      backgroundColor:
                          darkText ? Colors.black12 : Colors.white12,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
class AutoSizeTextWidget extends StatelessWidget {
  final String text;

  const AutoSizeTextWidget({Key key, this.text}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}


