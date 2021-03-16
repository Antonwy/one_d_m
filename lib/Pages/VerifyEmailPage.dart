import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:one_d_m/Helper/API/ApiResult.dart';
import 'package:one_d_m/Helper/ColorTheme.dart';
import 'package:one_d_m/Helper/UserManager.dart';
import 'package:one_d_m/Pages/ChooseLoginMethodPage.dart';
import 'package:one_d_m/Pages/FindFriendsPage.dart';
import 'package:provider/provider.dart';

class VerifyEmailPage extends StatefulWidget {
  @override
  _VerifyEmailPageState createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  TextTheme _textTheme;

  UserManager _um;

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  bool _loading = false;

  Widget _openWidget = FindFriendsPage(
    afterRegister: true,
  );

  @override
  Widget build(BuildContext context) {
    _textTheme = Theme.of(context).textTheme;
    _um = Provider.of<UserManager>(context);
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: ColorTheme.orange,
      appBar: AppBar(
        backgroundColor: ColorTheme.orange,
        elevation: 0,
        leading: BackButton(
            color: ColorTheme.blue,
            onPressed: () async {
              await _um.delete();
              Navigator.push(context,
                  MaterialPageRoute(builder: (c) => ChooseLoginMethodPage()));
            }),
      ),
      floatingActionButton: OpenContainer(
        openBuilder: (context, close) => _openWidget,
        closedShape: CircleBorder(),
        closedColor: ColorTheme.blue,
        closedBuilder: (context, open) => Container(
          width: 56,
          height: 56,
          child: InkWell(
            onTap: _loading
                ? null
                : () async {
                    setState(() {
                      _loading = true;
                    });
                    await _um.fireUser.reload();
                    _um.fireUser = _um.auth.currentUser;
                    if (_um.fireUser.emailVerified) {
                      _openWidget = FindFriendsPage(afterRegister: true);
                      open();
                    } else
                      _showSnackBar("Email noch nicht verifiziert.");
                    setState(() {
                      _loading = false;
                    });
                  },
            child: _loading
                ? Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                : Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                  ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Center(
              child: SvgPicture.asset(
                "assets/images/verify.svg",
                height: MediaQuery.of(context).size.height * .25,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              "Um fortzufahren musst du deine Email verifizieren!",
              style: _textTheme.headline6.copyWith(color: ColorTheme.blue),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              "Dies läuft wie folgt ab: \nWenn du auf \"Email senden\" klickst, schicken wir dir eine Email mit einem Link an ${_um.fireUser.email}. Bitte klicke auf den Link um dich zu verifizieren. Danach kannst du wieder in die App zurückkehren und auf weiter klicken!",
              style: _textTheme.bodyText1
                  .copyWith(color: ColorTheme.blue.withOpacity(.75)),
            ),
            SizedBox(
              height: 20,
            ),
            FloatingActionButton.extended(
              heroTag: "w",
              onPressed: () async {
                ApiResult res = await _um.sendEmailVerification();
                _showSnackBar(
                    res.hasError() ? res.message : "Email versendet!");
              },
              elevation: 2,
              label: Text("Email senden"),
              icon: Icon(Icons.email),
              backgroundColor: ColorTheme.blue,
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(message)));
  }
}
