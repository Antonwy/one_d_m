import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:one_d_m/Components/PlaceSearch.dart';
import 'package:one_d_m/Helper/API/Api.dart';
import 'package:one_d_m/Helper/Campaign.dart';
import 'package:one_d_m/Helper/Helper.dart';
import 'package:one_d_m/Helper/Place.dart';

class CreateCampaignPage extends StatefulWidget {
  @override
  _CreateCampaignState createState() => _CreateCampaignState();
}

class _CreateCampaignState extends State<CreateCampaignPage> {
  ThemeData theme;

  PostPage _currentPage = PostPage.NAME;

  DateTime _selectedDate = DateTime.now();
  String _name = "", _description = "";
  Place _place;

  File _image;

  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text("Post Erstellen"),
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
      case PostPage.ENDDATE:
        return _endDateWidget();
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
            if (_name.isEmpty) return Helper.showAlert(context, "Gib einen Namen ein!");
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
            ? Container(
                padding: EdgeInsets.symmetric(vertical: 10),
                height: 400,
                child: Image.file(
                  _image,
                  fit: BoxFit.cover,
                ))
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
                if (_image == null) return Helper.showAlert(context, "Wähle ein Bild aus!");
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
            "Geben sie die Projektbeschreibung ein.",
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
                  if (_description.isEmpty)
                    return Helper.showAlert(context, "Gib eine Beschreibung ein!");
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
      _changePage(PostPage.ENDDATE);
    });
  }

  Widget _endDateWidget() {
    return Column(
      key: Key("EndDate"),
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          "Wähle das Enddatum deines Projektes aus.",
          style: theme.accentTextTheme.title,
        ),
        SizedBox(
          height: 5,
        ),
        Text(
          "Bis zu diesem Datum soll für dein Projekt spenden gesammelt werden.",
          style: theme.accentTextTheme.body1,
        ),
        SizedBox(
          height: 25,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              _convertDate(_selectedDate),
              style: theme.accentTextTheme.title,
            ),
            FlatButton(
              child: Text("Datum auswählen"),
              onPressed: () async {
                DateTime myDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2018),
                      lastDate: DateTime(2030),
                    ) ??
                    _selectedDate;
                setState(() {
                  _selectedDate = myDate;
                });
              },
            ),
          ],
        ),
        SizedBox(
          height: 10,
        ),
        Row(
          children: <Widget>[
            OutlineButton(
              child: Text("Zurück"),
              onPressed: () {
                setState(() {
                  _currentPage = PostPage.POSITION;
                });
              },
            ),
            SizedBox(
              width: 10,
            ),
            OutlineButton(
              child: Text("Weiter"),
              onPressed: () {
                if (_selectedDate.isBefore(DateTime.now()))
                  return Helper.showAlert(context, "Datum muss in der Zukunft liegen!");
                setState(() {
                  _currentPage = PostPage.RESULT;
                });
              },
            ),
          ],
        )
      ],
    );
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
                child: Image.file(_image, fit: BoxFit.cover,),
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
          _resultRow("Enddatum", _convertDate(_selectedDate)),
          Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              OutlineButton(
                child: Text("Zurück"),
                onPressed: () {
                  setState(() {
                    _currentPage = PostPage.ENDDATE;
                  });
                },
              ),
              OutlineButton(
                child: Text("Erstellen"),
                onPressed: () async {
                  Campaign campaign = Campaign(
                      amount: 0,
                      name: _name,
                      description: _description,
                      city: _place.name,
                      endDate: _selectedDate,
                      imgUrl: null,
                      finalAmount: 10000, img: null);

                  if (await Api.createCampaign(campaign)) {
                    Navigator.pop(context);
                  } else {
                    Helper.showAlert(context, "Etwas ist schief gelaufen! Versuche es später erneut!");
                  }
                },
              ),
            ],
          )
        ],
      ),
    );
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

enum PostPage { NAME, IMAGE, DESCRIPTION, POSITION, ENDDATE, RESULT }
