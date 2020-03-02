import 'package:flutter/material.dart';
import 'package:one_d_m/Helper/Constants.dart';
import 'package:one_d_m/Helper/UserManager.dart';
import 'package:one_d_m/Pages/HomePage/HomePage.dart';
import 'package:one_d_m/Pages/RegisterPage.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.containsKey(Constants.USERNAME);

  runApp(MyApp(isLoggedIn));
}

class MyApp extends StatelessWidget {
  bool isLoggedIn;

  MyApp(this.isLoggedIn);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          builder: (context) => UserManager(),
        ),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            primarySwatch: Colors.indigo),
        // home: RegisterPage(),
        home: isLoggedIn ? HomePage() : RegisterPage(),
      ),
    );
  }
}
