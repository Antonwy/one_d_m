import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:one_d_m/Components/ValueAnimator.dart';
import 'package:one_d_m/Helper/API/ApiResult.dart';
import 'package:one_d_m/Helper/CircularRevealRoute.dart';
import 'package:one_d_m/Helper/Helper.dart';
import 'package:one_d_m/Helper/User.dart';
import 'package:one_d_m/Helper/UserManager.dart';
import 'package:one_d_m/Helper/Validate.dart';
import 'package:one_d_m/Pages/HomePage/HomePage.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  ThemeData theme;

  TextTheme textTheme;

  TextTheme accentTextTheme;

  double percentageDone = 0.0;

  RegisterPages _currentPage = RegisterPages.EMAIL;

  bool _login = false;

  List<String> _images = [
    "assets/images/clip-payment.png",
    "assets/images/clip-sign-up.png",
    "assets/images/clip-virtual-reality.png"
  ];

  GlobalKey _fabKey = GlobalKey();

  final _formKey = GlobalKey<FormState>();

  String email = "",
      password1 = "",
      password2 = "",
      firstName = "",
      lastName = "";

  UserManager um;

  File _file;

  String _userId = Uuid().v4();

  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);
    textTheme = theme.textTheme;
    accentTextTheme = theme.accentTextTheme;

    um = Provider.of<UserManager>(context);

    return Scaffold(
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(left: 35.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              IgnorePointer(
                ignoring: _currentPage.index == 0 || _login,
                child: AnimatedOpacity(
                  duration: Duration(milliseconds: 250),
                  opacity: _currentPage.index == 0 || _login ? 0 : 1,
                  child: FloatingActionButton(
                    child: Icon(Icons.navigate_before),
                    onPressed: _prevPage,
                  ),
                ),
              ),
              FloatingActionButton(
                key: _fabKey,
                heroTag: "null",
                child: _getFabWidget(),
                onPressed: _nextPage,
              ),
            ],
          ),
        ),
        body: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              automaticallyImplyLeading: false,
              expandedHeight: 250,
              floating: false,
              pinned: true,
              flexibleSpace: Column(
                children: <Widget>[
                  Expanded(
                    child: FlexibleSpaceBar(
                      title: Text(
                        "One\$M",
                        style: accentTextTheme.headline.copyWith(fontSize: 25),
                      ),
                      background: AnimatedSwitcher(
                        duration: Duration(milliseconds: 500),
                        child: _getImage(),
                      ),
                    ),
                  ),
                  ValueAnimator(
                      curve: Curves.fastOutSlowIn,
                      value: Helper.mapValue(_currentPage.index, 0,
                          RegisterPages.values.length, 0, 1),
                      builder: (value) {
                        return LinearProgressIndicator(
                          value: value,
                          valueColor: AlwaysStoppedAnimation(
                              Theme.of(context).primaryColorDark),
                        );
                      }),
                ],
              ),
            ),
            SliverFillRemaining(
                child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: AnimatedSwitcher(
                    duration: Duration(milliseconds: 500),
                    child: _getCurrentPage()),
              ),
            )),
          ],
        ));
  }

  Widget _getImage() {
    String img = _images[_currentPage.index];
    return Image.asset(
      img,
      key: Key(img),
    );
  }

  Widget _getCurrentPage() {
    if (_login) {
      return _loginWidget();
    }

    switch (_currentPage) {
      case RegisterPages.EMAIL:
        return _emailWidget();
      case RegisterPages.PASSWORD:
        return _passwordWidget();
      case RegisterPages.INFOS:
        return _infoWidget();
      default:
        return _emailWidget();
    }
  }

  Widget _emailWidget() {
    return Padding(
      key: Key("Email"),
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 40,
          ),
          Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Willkommen!",
                    style: textTheme.title,
                  ),
                  Text(
                    "Bitte registriere dich um die App zu nutzen.",
                    style: textTheme.body1,
                  ),
                ],
              )),
          SizedBox(
            height: 20,
          ),
          _textField(
              label: "Email",
              hint: "z.B. mustermail@gmail.com",
              inputType: TextInputType.emailAddress,
              initText: email,
              onSaved: (text) {
                email = text;
              },
              validator: Validate.email),
          SizedBox(
            height: 10,
          ),
          Material(
            borderRadius: BorderRadius.circular(3),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: _showLogin,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Sie haben bereits ein Account?",
                  style: textTheme.button,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _passwordWidget() {
    return Padding(
      key: Key("Password"),
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 40,
          ),
          Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Passwort",
                    style: textTheme.title,
                  ),
                  Text(
                    "Bitte gib ein sicheres Passwort ein!",
                    style: textTheme.body1,
                  ),
                ],
              )),
          SizedBox(
            height: 20,
          ),
          _textField(
              label: "Passwort",
              hint: "",
              obscureText: true,
              initText: password1,
              onChanged: (text) {
                password1 = text;
              },
              onSaved: (text) {
                password1 = text;
              },
              validator: (text) {
                String error = Validate.password(text);
                if (password1 != password2)
                  error = "Deine Passwörter sind unterschiedlich!";
                return error;
              }),
          SizedBox(
            height: 15,
          ),
          _textField(
              label: "Passwort bestätigen",
              hint: "",
              obscureText: true,
              initText: password1,
              onChanged: (text) {
                password2 = text;
              },
              onSaved: (text) {
                password2 = text;
              },
              validator: (text) {
                String error = Validate.password(text);
                if (password1 != password2)
                  error = "Deine Passwörter sind unterschiedlich!";
                return error;
              }),
          SizedBox(
            height: 10,
          ),
          Material(
            borderRadius: BorderRadius.circular(3),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: _showLogin,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Sie haben bereits ein Account?",
                  style: textTheme.button,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _infoWidget() {
    return Padding(
      key: Key("Info"),
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Profilbild",
                    style: textTheme.title,
                  ),
                  Text(
                    "Suche ein passendes Profilbild aus!",
                    style: textTheme.body1,
                  ),
                ],
              ),
              Container(
                width: 60,
                height: 60,
                child: Material(
                  elevation: 4,
                  shape: CircleBorder(),
                  color: Theme.of(context).primaryColor,
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () async {
                      var file = await ImagePicker.pickImage(
                          source: ImageSource.gallery);
                      setState(() {
                        _file = file;
                      });
                    },
                    child: _file == null
                        ? Padding(
                            padding: EdgeInsets.all(15.0),
                            child: Icon(
                              Icons.add,
                              color: Colors.white,
                            ),
                          )
                        : Image.file(
                            _file,
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            "Vorname",
            style: textTheme.title,
          ),
          SizedBox(
            height: 5,
          ),
          _textField(
              label: "Vorname",
              hint: "z.B. Testname",
              initText: firstName,
              onSaved: (text) {
                firstName = text;
              },
              inputType: TextInputType.text,
              validator: Validate.username),
          SizedBox(
            height: 10,
          ),
          Text(
            "Nachname",
            style: textTheme.title,
          ),
          SizedBox(
            height: 5,
          ),
          _textField(
              label: "Nachname",
              hint: "z.B. Testname",
              initText: lastName,
              onSaved: (text) {
                lastName = text;
              },
              inputType: TextInputType.text,
              validator: Validate.username),
          SizedBox(
            height: 10,
          ),
          Material(
            borderRadius: BorderRadius.circular(3),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: _showLogin,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Sie haben bereits ein Account?",
                  style: textTheme.button,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 50,
          ),
        ],
      ),
    );
  }

  Widget _loginWidget() {
    return Padding(
      key: Key("Login"),
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 40,
          ),
          Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Willkommen zurück!",
                    style: textTheme.title,
                  ),
                  Text(
                    "Bitte logge dich ein, um die App zu nutzen.",
                    style: textTheme.body1,
                  ),
                ],
              )),
          SizedBox(
            height: 20,
          ),
          _textField(
              label: "Email",
              hint: "",
              inputType: TextInputType.emailAddress,
              onSaved: (text) {
                email = text;
              }),
          SizedBox(
            height: 15,
          ),
          _textField(
              label: "Passwort",
              hint: "",
              obscureText: true,
              validator: Validate.password,
              onSaved: (text) {
                password1 = text;
              },
              inputType: TextInputType.text),
          SizedBox(
            height: 10,
          ),
          Material(
            borderRadius: BorderRadius.circular(3),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: _showRegister,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Sie haben noch keinen Account?",
                  style: textTheme.button,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  void _nextPage() async {
    if (!_formKey.currentState.validate()) return;

    _formKey.currentState.save();

    if (_login) {
      _showLoading(true);
      bool res = await _loginUser();
      if (res) _pushNextPage();
      return;
    }

    if (_currentPage.index < RegisterPages.values.length - 1) {
      setState(() {
        _currentPage = RegisterPages.values[_currentPage.index + 1];
      });
    } else {
      _showLoading(true);
      bool res = await _registerUser();
      if (res) _pushNextPage();
    }
  }

  Widget _getFabWidget() {
    if (_loading)
      return Padding(
        padding: const EdgeInsets.all(15.0),
        child: CircularProgressIndicator(
          valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    return _currentPage.index == RegisterPages.values.length - 1 || _login
        ? Icon(Icons.done)
        : Icon(Icons.navigate_next);
  }

  void _showLoading(bool value) {
    setState(() {
      _loading = value;
    });
  }

  void _prevPage() {
    if (_currentPage.index != 0) {
      setState(() {
        _currentPage = RegisterPages.values[_currentPage.index - 1];
      });
    }
  }

  void _showLogin() {
    setState(() {
      _login = true;
    });
  }

  void _showRegister() {
    setState(() {
      _login = false;
    });
  }

  void _pushNextPage() {
    Navigator.push(
        context,
        CircularRevealRoute(
            page: HomePage(),
            color: Theme.of(context).primaryColor,
            startColor: Theme.of(context).primaryColor,
            offset: Helper.getCenteredPositionFromKey(_fabKey),
            duration: Duration(milliseconds: 400)));
  }

  Future _registerUser() async {
    User user = User(
        email: email.toLowerCase(),
        firstname: firstName,
        lastname: lastName,
        password: password1);

    ApiResult result = await um.signUp(user, _file);

    if (result.hasError()) {
      _showError(result.getMessage());
    }

    return !result.hasError();
  }

  Future _loginUser() async {
    ApiResult result = await um.signIn(email.toLowerCase(), password1);

    if (result.hasError()) _showError(result.getMessage());
    return !result.hasError();
  }

  void _showError(String error) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(
                "Something went wrong.",
                style: TextStyle(color: Colors.red),
              ),
              content: Text(error),
            )).then((v) => _showLoading(false));
  }

  Widget _textField(
      {String label,
      String hint,
      TextInputType inputType = TextInputType.text,
      bool obscureText = false,
      String Function(String) validator,
      Function(String) onChanged,
      Function(String) onSaved,
      String initText}) {
    return TextFormField(
      initialValue: initText,
      validator: validator,
      onChanged: onChanged,
      onSaved: onSaved,
      obscureText: obscureText,
      keyboardType: inputType,
      decoration: InputDecoration(
          hintText: hint, labelText: label, border: OutlineInputBorder()),
    );
  }
}

enum RegisterPages { EMAIL, PASSWORD, INFOS }
