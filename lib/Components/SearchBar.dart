import 'package:flutter/material.dart';
import 'package:one_d_m/Components/SearchPage.dart';

class SearchBar extends StatelessWidget {
  SearchBar({Key key}) : super();

  BuildContext _context;

  GlobalKey _key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    _context = context;
    return Container(
      key: _key,
      width: double.infinity,
      height: 60,
      child: Card(
        margin: EdgeInsets.all(0),
        child: InkWell(
          child: Align(
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Text(
                "Suchen",
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
            ),
            alignment: Alignment.centerLeft,
          ),
          onTap: openSearchPage,
        ),
      ),
    );
  }

  openSearchPage() {
    RenderBox box = _key.currentContext.findRenderObject();
    Offset offset = box.localToGlobal(Offset.zero);
    Navigator.push(
        _context,
        PageRouteBuilder(
            opaque: false,
            pageBuilder: (c, a1, a2) => SearchPage(
                  size: box.size,
                  offset: offset,
                ),
            transitionDuration: Duration.zero));
  }
}
