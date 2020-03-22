import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:one_d_m/Components/PlaceSearch.dart';
import 'package:one_d_m/Helper/Campaign.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/Helper.dart';
import 'package:one_d_m/Helper/Place.dart';
import 'package:one_d_m/Helper/StorageService.dart';
import 'package:one_d_m/Helper/UserManager.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class CreateCampaignPage extends StatefulWidget {
  @override
  _CreateCampaignState createState() => _CreateCampaignState();
}

class _CreateCampaignState extends State<CreateCampaignPage> {
  ThemeData theme;

  PostPage _currentPage = PostPage.NAME;

  String _name = "", _description = "", _shortDescription = "";
  Place _place;

  File _image;

  UserManager um;

  String _postId = Uuid().v4();

  bool isUploading = false;

  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);
    um = Provider.of<UserManager>(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text("Projekt Erstellen"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Theme(
            data: ThemeData.dark(),
            child: AnimatedSwitcher(
              duration: Duration(milliseconds: 250),
              child: _getChild(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _getChild() {
    switch (_currentPage) {
      case PostPage.NAME:
        return _nameWidget();
      case PostPage.IMAGE:
        return _imageWidget();
      case PostPage.DESCRIPTION:
        return _descriptionWidget();
      case PostPage.POSITION:
        return _positionWidget();
      case PostPage.RESULT:
        return _resultWidget();
      default:
        return _nameWidget();
    }
  }

  Widget _nameWidget() {
    return Column(
      key: Key("Name"),
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          "Geben sie den Projektnamen ein.",
          style: theme.accentTextTheme.title,
        ),
        SizedBox(
          height: 5,
        ),
        _textField(
            hint: "Projekt Name",
            onChanged: (text) {
              _name = text;
            }),
        SizedBox(
          height: 10,
        ),
        OutlineButton(
          onPressed: () {
            if (_name.isEmpty)
              return Helper.showAlert(context, "Gib einen Namen ein!");
            _changePage(PostPage.IMAGE);
          },
          child: Text("Weiter"),
        )
      ],
    );
  }

  Widget _imageWidget() {
    return Column(
      key: Key("Image"),
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          "Wählen sie ein Titelbild aus!",
          style: theme.accentTextTheme.title,
        ),
        _image != null
            ? Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Card(
                    clipBehavior: Clip.antiAlias,
                    child: Image.file(
                      _image,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )),
              )
            : Container(),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(5),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () async {
                var img =
                    await ImagePicker.pickImage(source: ImageSource.gallery);
                setState(() {
                  _image = img;
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      Icons.photo,
                      size: 40,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      "Galerie",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Row(
          children: <Widget>[
            OutlineButton(
              onPressed: () {
                _changePage(PostPage.NAME);
              },
              child: Text("Zurück"),
            ),
            SizedBox(
              width: 10,
            ),
            OutlineButton(
              onPressed: () {
                if (_image == null)
                  return Helper.showAlert(context, "Wähle ein Bild aus!");
                _changePage(PostPage.DESCRIPTION);
              },
              child: Text("Weiter"),
            ),
          ],
        )
      ],
    );
  }

  Widget _descriptionWidget() {
    return SingleChildScrollView(
      child: Column(
        key: Key("Description"),
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "Beschreibe dein Projekt kurz.",
            style: theme.accentTextTheme.title,
          ),
          SizedBox(
            height: 10,
          ),
          _textField(
              hint: "Kurze Beschreibung",
              minLines: 2,
              onChanged: (text) {
                _shortDescription = text;
              }),
          SizedBox(
            height: 20,
          ),
          Text(
            "Beschreibe dein Projekt detailliert.",
            style: theme.accentTextTheme.title,
          ),
          SizedBox(
            height: 10,
          ),
          _textField(
              hint: "Beschreibung",
              minLines: 5,
              onChanged: (text) {
                _description = text;
              }),
          SizedBox(
            height: 10,
          ),
          Row(
            children: <Widget>[
              OutlineButton(
                onPressed: () {
                  _changePage(PostPage.IMAGE);
                },
                child: Text("Zurück"),
              ),
              SizedBox(
                width: 10,
              ),
              OutlineButton(
                onPressed: () {
                  if (_description.isEmpty || _shortDescription.isEmpty) {
                    return Helper.showAlert(
                        context, "Gib eine Beschreibung ein!");
                  }
                  _changePage(PostPage.POSITION);
                },
                child: Text("Weiter"),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _positionWidget() {
    return PlaceSearch(onPrev: () {
      _changePage(PostPage.DESCRIPTION);
    }, onNext: (Place place) {
      _place = place;
      _changePage(PostPage.RESULT);
    });
  }

  Widget _resultWidget() {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            height: 200,
            child: Center(
              child: Material(
                child: Image.file(
                  _image,
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(5),
                elevation: 10,
                clipBehavior: Clip.antiAlias,
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Center(
            child: Text(
              _name,
              style: theme.accentTextTheme.headline,
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            "Kurze Beschreibung: ",
            style: theme.accentTextTheme.title,
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            _shortDescription,
            style: theme.accentTextTheme.body1,
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            "Beschreibung: ",
            style: theme.accentTextTheme.title,
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            _description,
            style: theme.accentTextTheme.body1,
          ),
          SizedBox(
            height: 10,
          ),
          Divider(),
          _resultRow("Ort", _place.name),
          Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              OutlineButton(
                child: Text("Zurück"),
                onPressed: () {
                  setState(() {
                    _currentPage = PostPage.POSITION;
                  });
                },
              ),
              isUploading ? CircularProgressIndicator() : Container(),
              OutlineButton(
                  child: Text("Erstellen"),
                  onPressed: isUploading ? null : _uploadCampaign),
            ],
          )
        ],
      ),
    );
  }

  void _uploadCampaign() async {
    setState(() {
      isUploading = true;
    });

    StorageService service = StorageService(file: _image, id: _postId);

    await service.compressImage();

    Campaign campaign = Campaign(
      amount: 0,
      name: _name,
      description: _description,
      city: _place.name,
      imgUrl: await service.uploadImage(),
      finalAmount: 10000,
      authorId: um.uid,
    );

    await DatabaseService(um.uid).createCampaign(campaign);
    Navigator.pop(context);
  }

  Widget _resultRow(String left, String right) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            left,
            style: theme.accentTextTheme.title,
          ),
          Container(
            width: 200,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                right,
                style: theme.accentTextTheme.body1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _textField(
      {String hint, int minLines = 1, Function(String) onChanged}) {
    return TextField(
      cursorColor: Colors.white,
      style: TextStyle(color: Colors.white),
      minLines: minLines,
      maxLines: 20,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white54),
        enabledBorder:
            OutlineInputBorder(borderSide: BorderSide(color: Colors.white30)),
        focusedBorder:
            OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
      ),
    );
  }

  String _convertDate(DateTime date) {
    return DateFormat("d. MMMM yyyy").format(date);
  }

  void _changePage(PostPage page) {
    setState(() {
      _currentPage = page;
    });
  }
}

enum PostPage { NAME, IMAGE, DESCRIPTION, POSITION, RESULT }
