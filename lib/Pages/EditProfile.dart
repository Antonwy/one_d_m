import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:one_d_m/Helper/API/ApiResult.dart';
import 'package:one_d_m/Helper/ColorTheme.dart';
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
        appBar: AppBar(
          backgroundColor: ColorTheme.blue,
          title: Text("Profil ändern"),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 5.0),
              child: _loading
                  ? Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : IconButton(
                      icon: Icon(Icons.done),
                      onPressed: () async {
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
                          StorageService service = StorageService(file: _image);
                          currUser.imgUrl = await service.uploadImage(
                              StorageService.userImageName(um.uid));
                        }

                        if (_name != null && Validate.username(_name) == null)
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  CircleAvatar(
                      child: _imgWidget == null ? Icon(Icons.person) : null,
                      radius: 30,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: _imgWidget),
                  Row(
                    children: <Widget>[
                      OutlineButton(
                        onPressed: _getImage,
                        child: Text("Ändern"),
                      ),
                      SizedBox(width: 10),
                      OutlineButton(
                        onPressed: _deleteImage,
                        child: Text("Löschen"),
                      ),
                    ],
                  )
                ],
              ),
              SizedBox(height: 20),
              _textView(
                  label: "Vorname",
                  initValue: um.user.name,
                  onChanged: (text) {
                    _name = text;
                  }),
              SizedBox(height: 10),
              _textView(
                  label: "Telefonnummer",
                  initValue: um.user.phoneNumber,
                  onChanged: (text) {
                    _phoneNumber = text;
                  }),
              SizedBox(height: 10),
            ],
          )),
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

  Widget _textView({String label, Function onChanged, String initValue}) =>
      TextFormField(
        initialValue: initValue,
        onChanged: onChanged,
        decoration:
            InputDecoration(labelText: label, border: OutlineInputBorder()),
      );
}
