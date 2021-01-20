import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/Helper.dart';
import 'package:one_d_m/Helper/News.dart';
import 'package:one_d_m/Helper/Session.dart';
import 'package:one_d_m/Helper/StorageService.dart';
import 'package:one_d_m/Helper/ThemeManager.dart';
import 'package:one_d_m/Helper/UserManager.dart';
import 'package:one_d_m/Helper/Validate.dart';
import 'package:one_d_m/Helper/margin.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class CreatePostScreen extends StatefulWidget {
  final Session session;

  const CreatePostScreen({Key key, this.session}) : super(key: key);

  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
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
  void didChangeDependencies() {
    _displaySize = MediaQuery.of(context).size;
    _theme = Theme.of(context);
    _accentTextTheme = _theme.accentTextTheme;
    um = Provider.of<UserManager>(context);
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.chevron_left_outlined,
            color: Colors.black,
            size: 42,
          ),
        ),
        title: Text(
          'Post erstellen',
          style: _theme.textTheme.headline6
              .copyWith(fontWeight: FontWeight.w700, fontSize: 24),
        ),
        centerTitle: true,
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
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _showImage(),
                const YMargin(20),
                _textField(
                    hint: "Beschreibung",
                    multiline: true,
                    onSaved: (text) {
                      _postText = text;
                    }),
                const YMargin(20),
                Align(
                    alignment: Alignment.center,
                    child: _buildCreatePostButton(context))
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
    service.uploadNewsImage(StorageService.newsImageName(_newsId)).then((path) {
      News news = News(
          id: _newsId,
          sessionId: widget.session.id,
          campaignId: widget.session.campaignId,
          campaignName: widget.session.campaignName,
          campaignImgUrl: widget.session.campaignImgUrl,
          createdAt: DateTime.now(),
          userId: um.uid,
          title: '',
          text: _postText,
          shortText: _postShortText,
          imageUrl: path);

      DatabaseService.createNews(news).then((value) {
        setState(() {
          _isLoading = false;
        });
        Navigator.pop(context);
      }).catchError((e) {
        setState(() {
          _isLoading = false;
        });

        Helper.showAlert(
            context, "Etwas ist schief gelaufen! Versuche es später erneut!");
      });
    }).catchError((e) {
      _createNews();
    });
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
        width: double.infinity,
        height: 200,
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              border: Border.all(width: 1, color: Colors.grey)),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: _getImage,
            child: Center(
              child: _image == null
                  ? _buildPlaceholder()
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
      textAlignVertical: TextAlignVertical.top,
      onSaved: onSaved,
      maxLines: 5,
      cursorColor: Colors.grey,
      style: TextStyle(color: Colors.grey),
      keyboardType: multiline ? TextInputType.multiline : TextInputType.text,
      maxLength: maxLength,
      decoration: InputDecoration(
          alignLabelWithHint: true,
          counterText: "",
          labelStyle: TextStyle(color: Colors.grey, fontSize: 24),
          labelText: hint,
          hintText: "",
          hintStyle: TextStyle(color: Colors.red),
          border: OutlineInputBorder(),
          errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              borderSide: BorderSide(color: Colors.red)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              borderSide: BorderSide(color: Colors.grey)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              borderSide: BorderSide(color: Colors.grey))),
    );
  }

  Widget _buildPlaceholder() => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            "assets/images/ic_image_pick.png",
            height: 98,
            width: 100,
          ),
          Text(
            'Wähle durch Tippen ein Bild aus',
            textAlign: TextAlign.center,
            style: _theme.textTheme.subtitle1
                .copyWith(color: Colors.grey, fontSize: 24),
          )
        ],
      );

  Widget _buildCreatePostButton(BuildContext context) => RaisedButton(
      color: ThemeManager.of(context).colors.dark,
      textColor: ThemeManager.of(context).colors.light,
      child: Container(
        width: 220,
        height: 48,
        child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: !_isLoading
                ? Center(
                    child: Text(
                      'Post erstellen',
                      style: Theme.of(context).textTheme.button.copyWith(
                          color: ThemeManager.of(context).colors.light,
                          fontSize: 20),
                    ),
                  )
                : Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(
                          ThemeManager.of(context).colors.light),
                    ),
                  )),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onPressed: _isLoading
          ? null
          : () {
              _createNews();
            });
}
