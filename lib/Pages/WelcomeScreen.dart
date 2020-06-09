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
  List<Color> _pageColors = [
    ColorTheme.blue,
    ColorTheme.whiteBlue,
    ColorTheme.orange,
    ColorTheme.white,
    ColorTheme.orange,
    ColorTheme.blue,
    ColorTheme.black,
  ];

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

  Color _getBackgroundColor() {
    return TweenSequence([
      TweenSequenceItem(
          tween: ColorTween(begin: _pageColors[0], end: _pageColors[1]),
          weight: 1),
      TweenSequenceItem(
          tween: ColorTween(begin: _pageColors[1], end: _pageColors[2]),
          weight: 1),
      TweenSequenceItem(
          tween: ColorTween(begin: _pageColors[2], end: _pageColors[3]),
          weight: 1),
      TweenSequenceItem(
          tween: ColorTween(begin: _pageColors[3], end: _pageColors[4]),
          weight: 1),
      TweenSequenceItem(
          tween: ColorTween(begin: _pageColors[4], end: _pageColors[5]),
          weight: 1),
      TweenSequenceItem(
          tween: ColorTween(begin: _pageColors[5], end: _pageColors[6]),
          weight: 1),
      TweenSequenceItem(
          tween: ColorTween(begin: _pageColors[6], end: _pageColors[6]),
          weight: 1),
    ]).transform(_page / 7.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _getBackgroundColor(),
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
                  svgName: "welcome",
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
                        .copyWith(color: ColorTheme.whiteBlue),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                  ),
                  description:
                      "One Dollar Movement ist eine Plattform, auf der kleine Geldbeträge gespendet werden können. Durch uns wird spenden einfach, schnell und unterhaltsam.",
                  animatedValue: _getAnimatedValue(0, _page),
                  onPressed: () => _animateToPage(1),
                ),
                _WelcomePage(
                    svgName: "donation-credits",
                    title: "Donation Credits",
                    description:
                        "Ein Donation Credit entspricht 10 Cent. Wir nutzen das als App interne „Währung“ um ein schnelles und reibungsloses Spenden zu ermöglichen.",
                    darkText: true,
                    animatedValue: _getAnimatedValue(1, _page),
                    onPressed: () => _animateToPage(2)),
                _WelcomePage(
                    svgName: "landing-page",
                    title: "Startseite",
                    description:
                        "Auf der Startseite werden die Spenden deiner Freunde und die jeweiligen Tagesziele angezeigt. So hast Du immer im Blick, wer an was gespendet hat und wie viele Donation Credits noch bis zum Ende des Tages gesammelt werden sollten, um das Tagesziel zu erreichen.",
                    animatedValue: _getAnimatedValue(2, _page),
                    onPressed: () => _animateToPage(3)),
                _WelcomePage(
                    svgName: "projects",
                    title: "Projekte",
                    description:
                        "Die Projekte, an die gespendet werden kann, sind primär Wohltätigkeitsorganisationen, die ohne finanzielle Unterstützung ihrer Arbeit nicht mehr nachgehen könnten.",
                    darkText: true,
                    animatedValue: _getAnimatedValue(3, _page),
                    onPressed: () => _animateToPage(4)),
                _WelcomePage(
                    svgName: "explore",
                    title: "Entdecken",
                    description:
                        "Um neue Projekte entdecken zu können haben wir eine „Entdecken“ Seite eingebaut. Dort werden die neusten Projekte und Nutzer präsentiert.",
                    animatedValue: _getAnimatedValue(4, _page),
                    onPressed: () => _animateToPage(5)),
                _WelcomePage(
                  svgName: "donation",
                  title: "Spendenablauf",
                  description:
                      "Alle Donation Credits, die du spendest, werden bis zum Ende des Monats auf deinem Account gesammelt und in einer Sammelüberweisung auf unser Konto überwiesen. Von dort aus wird das Geld an die Projekte verteilt.",
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
                            style: TextStyle(color: Colors.white),
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
                inactiveColor: _page.round() >= 1 && _page.round() <= 4
                    ? ColorTheme.blue.withOpacity(.5)
                    : ColorTheme.whiteBlue.withOpacity(.5),
                activeColor: _page.round() >= 1 && _page.round() <= 4
                    ? ColorTheme.blue
                    : ColorTheme.whiteBlue,
                inkColor: _page.round() >= 1 && _page.round() <= 4
                    ? ColorTheme.blue
                    : ColorTheme.whiteBlue,
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
        duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
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
      this.darkText = false,
      this.loading = false,
      this.isLastPage = false});

  TextTheme _textTheme;
  MediaQueryData _mq;

  @override
  Widget build(BuildContext context) {
    _textTheme = Theme.of(context).textTheme;
    _mq = MediaQuery.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Opacity(
              opacity: 1 - animatedValue,
              child: Transform.scale(
                scale: 1 - animatedValue * .5,
                child: Transform.translate(
                  offset: Offset(_mq.size.width * animatedValue * .4, 0),
                  child: svgName == null
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
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Opacity(
              opacity: 1 - animatedValue,
              child: Transform.translate(
                offset: Offset(_mq.size.width * animatedValue * .3, 0),
                child: titleText ??
                    AutoSizeText(
                      title,
                      maxLines: 1,
                      style: _textTheme.headline3.copyWith(
                        color:
                            darkText ? ColorTheme.blue : ColorTheme.whiteBlue,
                      ),
                      textAlign: TextAlign.center,
                    ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Opacity(
              opacity: 1 - animatedValue,
              child: Transform.translate(
                offset: Offset(_mq.size.width * animatedValue * .2, 0),
                child: Text(
                  description,
                  style: _textTheme.subtitle2.copyWith(
                      color: darkText
                          ? ColorTheme.blue.withOpacity(.8)
                          : ColorTheme.whiteBlue.withOpacity(.8)),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Opacity(
              opacity: 1 - animatedValue,
              child: Transform.scale(
                scale: 1 - animatedValue * .5,
                child: Transform.translate(
                  offset: Offset(_mq.size.width * animatedValue * .1, 0),
                  child: isLastPage
                      ? Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 10,
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
                                            Colors.white),
                                      ),
                                    )
                                  : Icon(Icons.done),
                              elevation: 0,
                              backgroundColor: Colors.white12,
                            ),
                            FloatingActionButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (c) =>
                                            ChooseLoginMethodPage()));
                              },
                              child: loading
                                  ? Container(
                                      width: 30,
                                      height: 30,
                                      child: CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation(
                                            Colors.white),
                                      ),
                                    )
                                  : Icon(Icons.arrow_forward),
                              elevation: 0,
                              backgroundColor: Colors.white12,
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
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
