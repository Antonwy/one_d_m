import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:image_picker/image_picker.dart';
import 'package:one_d_m/Components/CustomTextField.dart';
import 'package:one_d_m/Helper/API/ApiResult.dart';
import 'package:one_d_m/Helper/ColorTheme.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/Helper.dart';
import 'package:one_d_m/Helper/StorageService.dart';
import 'package:one_d_m/Helper/User.dart';
import 'package:one_d_m/Helper/UserManager.dart';
import 'package:one_d_m/Helper/Validate.dart';
import 'package:provider/provider.dart';

class EditProfile extends StatefulWidget {
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  UserManager um;

  File _image;
  bool _deletedImage = false;

  String _name, _phoneNumber;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    um = Provider.of<UserManager>(context);

    ImageProvider _imgWidget = _showImage();

    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: ColorTheme.whiteBlue,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: ColorTheme.whiteBlue,
          iconTheme: IconThemeData(color: ColorTheme.blue),
          brightness: Brightness.dark,
          title: Text(
            "Profil ändern",
            style: TextStyle(color: ColorTheme.blue),
          ),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 5.0),
              child: _loading
                  ? Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(ColorTheme.blue),
                      ),
                    )
                  : OfflineBuilder(
                      child: Container(),
                      connectivityBuilder: (c, connection, child) {
                        return IconButton(
                            icon: Icon(Icons.done),
                            onPressed: () async {
                              if (connection == ConnectivityResult.none) {
                                Helper.showConnectionSnackBar(context);
                                return;
                              }

                              setState(() {
                                _loading = true;
                              });

                              User currUser = User(
                                  name: um.user.name,
                                  imgUrl: um.user.imgUrl,
                                  thumbnailUrl: um.user.thumbnailUrl,
                                  phoneNumber: um.user.phoneNumber);

                              if (_deletedImage) currUser.imgUrl = null;
                              if (_image != null) {
                                StorageService service =
                                    StorageService(file: _image);
                                currUser.imgUrl = await service.uploadImage(
                                    StorageService.userImageName(um.uid));
                              }

                              if (_name != null &&
                                  Validate.username(_name) == null)
                                currUser.name = _name;
                              if (_phoneNumber != null &&
                                  Validate.telephone(_phoneNumber) == null)
                                currUser.phoneNumber = _phoneNumber;

                              ApiResult res = await um.updateUser(currUser);

                              if (res.hasError()) {
                                _scaffoldKey.currentState.showSnackBar(
                                    SnackBar(content: Text(res.message)));
                                setState(() {
                                  _loading = false;
                                });
                                return;
                              }

                              Navigator.pop(context);
                            });
                      }),
            )
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 20),
              Text(
                "Account Daten ändern:",
                style: Theme.of(context)
                    .textTheme
                    .headline6
                    .copyWith(color: ColorTheme.blue),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  GestureDetector(
                    onTap: _getImage,
                    child: CircleAvatar(
                      child: _imgWidget == null ? Icon(Icons.person) : null,
                      radius: 30,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: _imgWidget,
                      onBackgroundImageError:
                          _imgWidget != null ? (e, strc) => print(strc) : null,
                    ),
                  ),
                  Theme(
                    data: ThemeData.light(),
                    child: Row(
                      children: <Widget>[
                        OutlineButton(
                          onPressed: _getImage,
                          textColor: ColorTheme.blue,
                          child: Text("Ändern"),
                          highlightedBorderColor: ColorTheme.blue,
                        ),
                        SizedBox(width: 10),
                        OutlineButton(
                          onPressed: _deleteImage,
                          textColor: ColorTheme.blue,
                          child: Text("Löschen"),
                          highlightedBorderColor: ColorTheme.blue,
                        ),
                      ],
                    ),
                  )
                ],
              ),
              SizedBox(height: 20),
              _textView(
                  label: "Nutzername",
                  formatters: [
                    FilteringTextInputFormatter.allow(RegExp("[a-z0-9-._]"))
                  ],
                  initValue: um.user.name,
                  onChanged: (text) {
                    _name = text;
                  }),
              SizedBox(height: 10),
              StreamBuilder<String>(
                  initialData: um.user.phoneNumber,
                  stream: DatabaseService.getPhoneNumber(um.uid),
                  builder: (context, snapshot) {
                    return _textView(
                        key: Key(snapshot.data),
                        label: "Telefonnummer",
                        initValue: snapshot.data,
                        onChanged: (text) {
                          _phoneNumber = text;
                        });
                  }),
              SizedBox(height: 10),
              OfflineBuilder(
                  child: Container(),
                  connectivityBuilder: (context, connection, child) {
                    return Consumer<UserManager>(
                      builder: (context, um, child) => Theme(
                        data: ThemeData.light(),
                        child: OutlineButton.icon(
                            onPressed: () async {
                              if (connection == ConnectivityResult.none) {
                                Helper.showConnectionSnackBar(context);
                                return;
                              }
                              setState(() {
                                _loading = true;
                              });
                              await um.resetPassword();
                              setState(() {
                                _loading = false;
                              });
                              Scaffold.of(context).showSnackBar(SnackBar(
                                  content: Text(
                                      "Wir haben dir eine Email zum Zurücksetzen deines Passwortes geschickt!")));
                            },
                            highlightedBorderColor: ColorTheme.blue,
                            icon: Icon(Icons.restore),
                            label: Text("Passwort zurücksetzen")),
                      ),
                    );
                  })
            ],
          ),
        ));
  }

  _showImage() {
    if (_deletedImage) return null;
    if ((um.user.thumbnailUrl ?? um.user.imgUrl) == null && _image == null)
      return null;
    if (_image != null) return FileImage(_image);

    return NetworkImage(um.user.thumbnailUrl ?? um.user.imgUrl);
  }

  _getImage() async {
    File file = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      _deletedImage = false;
      _image = file;
    });
  }

  _deleteImage() {
    setState(() {
      _deletedImage = true;
      _image = null;
    });
  }

  Widget _textView(
          {Key key,
          String label,
          Function onChanged,
          String initValue,
          List<TextInputFormatter> formatters}) =>
      Theme(
        key: key,
        data: ThemeData.dark().copyWith(accentColor: ColorTheme.blue),
        child: TextFormField(
          style: TextStyle(color: ColorTheme.blue),
          cursorColor: ColorTheme.blue,
          initialValue: initValue,
          onChanged: onChanged,
          inputFormatters: formatters ?? [],
          decoration: InputDecoration(
              labelText: label,
              labelStyle: TextStyle(color: ColorTheme.blue),
              border: OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: ColorTheme.blue.withOpacity(.5)))),
        ),
      );
}
