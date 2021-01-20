import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:one_d_m/Helper/API/ApiResult.dart';
import 'package:one_d_m/Helper/Campaign.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/Helper.dart';
import 'package:one_d_m/Helper/News.dart';
import 'package:one_d_m/Helper/StorageService.dart';
import 'package:one_d_m/Helper/UserManager.dart';
import 'package:one_d_m/Helper/Validate.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class CreateNewsPage extends StatefulWidget {
  Campaign campaign;

  CreateNewsPage(this.campaign);

  @override
  _CreateNewsPageState createState() => _CreateNewsPageState();
}

class _CreateNewsPageState extends State<CreateNewsPage> {
  Size _displaySize;

  ThemeData _theme;

  UserManager um;

  TextTheme _accentTextTheme;

  File _image;

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String _postTitle, _postText, _postShortText;

  final _newsId = Uuid().v4();

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    _displaySize = MediaQuery.of(context).size;
    _theme = Theme.of(context);
    _accentTextTheme = _theme.accentTextTheme;
    um = Provider.of<UserManager>(context);

    return Scaffold(
      backgroundColor: Colors.indigo,
      appBar: AppBar(
        elevation: 0,
        actions: <Widget>[
          _isLoading
              ? Center(
                  child: Container(
                    width: 30,
                    height: 30,
                    margin: EdgeInsets.only(right: 20),
                    child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Colors.white)),
                  ),
                )
              : Container()
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isLoading ? null : _createNews,
        label: Text("Post erstellen"),
        icon: Icon(Icons.create),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _showImage(),
                SizedBox(
                  height: 20,
                ),
                ..._text(
                    title: "Titel",
                    subtitle: "Gebe den Titel deines Posts ein!"),
                _textField(
                    hint: "z.B. Projekt Update!",
                    validator: Validate.postTitle,
                    onSaved: (text) {
                      _postTitle = text;
                    }),
                SizedBox(height: 20),
                ..._text(
                    title: "Kurze Beschreibung",
                    subtitle: "Gebe eine kurze Beschreibung deines Posts ein!"),
                _textField(
                    hint: "z.B. Projekt Update!",
                    maxLength: 50,
                    onSaved: (text) {
                      _postShortText = text;
                    }),
                SizedBox(height: 20),
                ..._text(
                    title: "Text", subtitle: "Gebe den Text deines Posts ein!"),
                _textField(
                    hint: "z.B. Projekt Update Beschreibung!",
                    multiline: true,
                    maxLength: 200,
                    onSaved: (text) {
                      _postText = text;
                    }),
                SizedBox(height: 100)
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _createNews() async {
    if (!_formKey.currentState.validate() || _image == null) return;

    _formKey.currentState.save();

    setState(() {
      _isLoading = true;
    });

    StorageService service = StorageService(file: _image);

    News news = News(
        id: _newsId,
        campaignId: widget.campaign.id,
        campaignName: widget.campaign.name,
        campaignImgUrl: widget.campaign.thumbnailUrl ?? widget.campaign.imgUrl,
        title: _postTitle,
        text: _postText,
        shortText: _postShortText,
        imageUrl:
            await service.uploadImage(StorageService.newsImageName(_newsId)));

    ApiResult res = await DatabaseService.createNews(news);

    if (res.hasError())
      return Helper.showAlert(
          context, "Etwas ist schief gelaufen! Versuche es später erneut!");

    Navigator.pop(context);
  }

  Future<void> _getImage() async {
    File _file = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (_file == null) return;
    setState(() {
      _image = _file;
    });
  }

  Widget _showImage() {
    return Center(
      child: Container(
        width: _displaySize.width * .85,
        height: 200,
        child: Material(
          color: Colors.grey.withOpacity(.4),
          borderRadius: BorderRadius.circular(10),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: _getImage,
            child: Center(
              child: _image == null
                  ? Icon(
                      Icons.photo,
                      size: 50,
                      color: Colors.grey,
                    )
                  : Image.file(
                      _image,
                      width: _displaySize.width * 85,
                      fit: BoxFit.cover,
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _textField(
      {String hint,
      bool multiline = false,
      Function validator,
      int maxLength = null,
      Function onSaved}) {
    return TextFormField(
      validator: validator,
      onSaved: onSaved,
      cursorColor: Colors.white,
      style: TextStyle(color: _accentTextTheme.body1.color),
      maxLines: multiline ? 10 : 1,
      keyboardType: multiline ? TextInputType.multiline : TextInputType.text,
      maxLength: maxLength,
      decoration: InputDecoration(
          counterStyle: TextStyle(color: _accentTextTheme.body1.color),
          hintText: hint,
          hintStyle:
              TextStyle(color: _accentTextTheme.body1.color.withOpacity(.5)),
          border: OutlineInputBorder(),
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white.withOpacity(.5))),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(width: 2, color: Colors.white))),
    );
  }

  List<Widget> _text({String title, String subtitle}) {
    return [
      Text(
        title,
        style: _accentTextTheme.title,
      ),
      SizedBox(height: 2),
      Text(
        subtitle,
        style: _accentTextTheme.body2.copyWith(
            color: _accentTextTheme.body2.color.withOpacity(.8),
            fontWeight: FontWeight.w400),
      ),
      SizedBox(
        height: 5,
      ),
    ];
  }
}
