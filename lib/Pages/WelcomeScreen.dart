import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ink_page_indicator/ink_page_indicator.dart';
import 'package:one_d_m/Helper/ColorTheme.dart';
import 'package:one_d_m/Helper/Helper.dart';
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
                  svgName: "img_odm_logo",
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
                      "Wir möchten mit One Dollar Movement Spenden kostenlos, einfach und alltäglich machen. Wenn du ODM nutzt, bist du Teil unserer Community um die Welt ein kleines Stück besser zu machen!",
                  animatedValue: _getAnimatedValue(0, _page),
                  onPressed: () => _animateToPage(1),
                ),
                _WelcomePage(
                    svgName: "img_session",
                    title: "Sessions",
                    description:
                        "Sessions sind Bereiche von bekannten Menschen mit großer Reichweite in Sozialen Netwerken. Du kannst dich ihnen anschließen und das ausgewählte Projekt einer Sessions unterstützen!",
                    animatedValue: _getAnimatedValue(1, _page),
                    onPressed: () => _animateToPage(2)),
                _WelcomePage(
                    svgName: "img_project",
                    title: "Projekte",
                    description:
                        "Jedes Projekt widmet sich einem Problem auf dieser Erde. Du kannst dabei Tiere, Menschen oder die Umwelt unterstützen. Miteinem Klick.",
                    darkText: true,
                    animatedValue: _getAnimatedValue(2, _page),
                    onPressed: () => _animateToPage(3)),
                _WelcomePage(
                  svgName: "img_push",
                  title: "Push Nachrichten",
                  description:
                      "Push Nachrichten halten dich über Sessions, Projekte und Freunde auf dem laufenden.",
                  darkText: true,
                  isPermission: true,
                  animatedValue: _getAnimatedValue(3, _page),
                  onPressed: () async {
                    _requestNotificationPermission()
                        .then((value) => _animateToPage(4));
                  },
                ),

                // _WelcomePage(
                //     svgName: "contacts",
                //     title: "Kontaktbuch",
                //     description:
                //         "Um dich direkt zu beginn mit deinen Freunden zu verknüpfen benötigen wir deine Zustimmung!",
                //     animatedValue: _getAnimatedValue(4, _page),
                //     onPressed: () => _animateToPage(5)),
                // _WelcomePage(
                //   svgName: "donation",
                //   title: "Ablauf",
                //   description:
                //       "Durch jede Ad-Impression erhalten wir Geld von unseren Werbenetzwerken. Das eingenommene Geld wird prozentual, je nach Aktivität, auf die Nutzer verteilt und am Ende des Monats an die von den Nutzern ausgewählten Projekte/Organisationen überwiesen. Dabei befindet sich das Geld zu keinem Zeitpunkt auf dem Konto der Nutzer. Dadurch werden unnötigen Transaktionen zwischen den Nutzern und One Dollar Movement vermieden.",
                //   animatedValue: _getAnimatedValue(5, _page),
                //   onPressed: () => _animateToPage(6),
                // ),
                _WelcomePage(
                  svgName: "img_contact",
                  title: "Kontaktbuch",
                  description:
                      "Damit wir dir eine angenehme User-Experience geben können, brauchen wir einige Berechtigungen von dir.",
                  animatedValue: _getAnimatedValue(4, _page),
                  onPressed: () async {
                    await _getPermission();

                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ChooseLoginMethodPage()));
                  },
                  isPermission: true,
                ),
              ],
            ),
          ),
          _page != 4
              ? Visibility(
                  visible: false,
                  child: Positioned(
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
                              )))),
                )
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

  Future<PermissionStatus> _requestNotificationPermission() async {
    final PermissionStatus permission = await Permission.notification.status;
    if (permission != PermissionStatus.granted) {
      final Map<Permission, PermissionStatus> permissionStatus =
          await [Permission.notification].request();
      return permissionStatus[Permission.notification] ??
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
    _pageController.animateToPage(
      page,
      duration: Duration(milliseconds: 400),
    );
  }
}

class _WelcomePage extends StatelessWidget {
  String svgName, imageName, title, description;
  double animatedValue;
  AutoSizeText titleText;
  VoidCallback onPressed;
  bool isPermission, loading, darkText;

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
      this.isPermission = false});

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
                      color: darkText ? ColorTheme.blue : ColorTheme.whiteBlue,
                    ),
                    textAlign: TextAlign.center,
                  ),
              SizedBox(
                height: 10,
              ),
              Text(
                description,
                style: _textTheme.subtitle2.copyWith(
                    color: darkText ? ColorTheme.blue : ColorTheme.whiteBlue),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 20,
              ),
              isPermission
                  ? MaterialButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4)),
                      onPressed: onPressed,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          "Erlauben",
                          style: Theme.of(context)
                              .accentTextTheme
                              .button
                              .copyWith(fontSize: 18),
                        ),
                      ),
                      color: Helper.hexToColor('#3E313F'),
                    )
                  : FloatingActionButton(
                      onPressed: onPressed,
                      child: Icon(
                        Icons.arrow_forward,
                        color:
                            darkText ? ColorTheme.blue : ColorTheme.whiteBlue,
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
