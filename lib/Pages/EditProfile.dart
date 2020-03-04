import 'package:flutter/material.dart';

class EditProfile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Profil ändern"),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 5.0),
              child: IconButton(
                  icon: Icon(Icons.done),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
            )
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: SingleChildScrollView(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 20),
              Text(
                "Account Daten ändern:",
                style: Theme.of(context).textTheme.headline,
              ),
              SizedBox(height: 20),
              _textView(label: "Firstname"),
              SizedBox(height: 10),
              _textView(label: "Lastname"),
              SizedBox(height: 10),
              _textView(label: "Username"),
              SizedBox(height: 10),
              _textView(label: "Passwort"),
              SizedBox(height: 10),
              _textView(label: "Passwort erneut eingeben"),
              SizedBox(height: 10),
            ],
          )),
        ));
  }

  Widget _textView({String label}) => TextField(
        decoration:
            InputDecoration(labelText: label, border: OutlineInputBorder()),
      );
}
