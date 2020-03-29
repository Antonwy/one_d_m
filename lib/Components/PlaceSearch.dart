import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:one_d_m/Helper/Place.dart';

List<String> standartSuggestions = ["New York", "Berlin", "Paris", "Madrid"];

class PlaceSearch extends StatefulWidget {
  Function onPrev;
  Function(Place) onNext;

  PlaceSearch({this.onNext, this.onPrev});

  @override
  _PlaceSearchState createState() => _PlaceSearchState();
}

class _PlaceSearchState extends State<PlaceSearch> {
  List<Place> suggestions = [];
  bool _showStandart = true, _loading = false;

  TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onChange);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: double.infinity,
          height: 50,
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
            elevation: 7,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: TextField(
                  controller: _controller,
                  cursorColor: Colors.grey[800],
                  style: TextStyle(color: Colors.grey[800], fontSize: 18),
                  decoration: InputDecoration.collapsed(
                      hintText: "Stadt",
                      hintStyle: TextStyle(color: Colors.grey[400])),
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Expanded(
          child: Container(
            width: double.infinity,
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
              elevation: 7,
              child: _loading
                  ? Center(
                      child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Colors.indigo),
                    ))
                  : ListView(
                      children: _getSuggestions(),
                    ),
            ),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        OutlineButton(
          onPressed: widget.onPrev,
          child: Text("Zurück"),
        )
      ],
    );
  }

  void _onChange() async {
    String reqUrl =
        "https://nominatim.openstreetmap.org/search/${_controller.text}?format=json&limit=10";

    setState(() {
      _loading = true;
    });

    http.Response res = await http.get(reqUrl);

    List<dynamic> body = json.decode(res.body);

    print(body);

    List<Place> placesList = [];

    if (body.isNotEmpty) {
      for (dynamic place in body) {
        if (place["type"] == "city") {
          Place p = Place.fromJson(place);
          placesList.add(p);
        }
      }

      suggestions = placesList;
    }

    if (suggestions.isEmpty || _controller.text.isEmpty) {
      _showStandart = true;
    } else if (suggestions.isNotEmpty) {
      _showStandart = false;
    }

    setState(() {
      _loading = false;
    });
  }

  List<Widget> _getSuggestions() {
    List<Widget> list = [];

    if (_showStandart) {
      list.add(Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 16, 0, 10),
        child: Text("Suggestions:", style: TextStyle(color: Colors.grey[800])),
      ));

      for (String sugg in standartSuggestions) {
        list.add(ListTile(
          leading: Icon(Icons.location_city, color: Colors.grey[800]),
          title: Text(
            sugg,
            style: TextStyle(color: Colors.black),
          ),
          onTap: () {
            _controller.text = sugg;
          },
        ));
      }
    } else {
      list.add(SizedBox(
        height: 10,
      ));
      for (Place sugg in suggestions) {
        list.add(ListTile(
          leading: Icon(Icons.location_city, color: Colors.grey[800]),
          title: Text(
            sugg.name,
            style: TextStyle(color: Colors.black),
          ),
          onTap: () {
            widget.onNext(sugg);
          },
        ));
      }
    }

    return list;
  }
}
