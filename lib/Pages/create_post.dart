import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:one_d_m/Helper/Campaign.dart';
import 'package:one_d_m/Helper/ColorTheme.dart';
import 'package:one_d_m/Helper/Constants.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/Helper.dart';
import 'package:one_d_m/Helper/News.dart';
import 'package:one_d_m/Helper/Session.dart';
import 'package:one_d_m/Helper/StorageService.dart';
import 'package:one_d_m/Helper/ThemeManager.dart';
import 'package:one_d_m/Helper/UserManager.dart';
import 'package:one_d_m/Helper/margin.dart';
import 'package:one_d_m/utils/video/video_info.dart';
import 'package:one_d_m/utils/video/video_widget.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class CreatePostScreen extends StatefulWidget {
  final Campaign campaign;
  final bool isSession;
  final BaseSession session;
  final ScrollController controller;

  const CreatePostScreen(
      {Key key, this.session, this.controller, this.campaign, this.isSession})
      : super(key: key);

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

  final thumbWidth = 100;
  final thumbHeight = 150;
  bool _imagePickerActive = false;
  bool _processing = false;
  bool _canceled = false, _showInMainfeed = true;
  double _progress = 0.0;
  int _videoDuration = 0;
  String _processPhase = '';
  VideoInfo videoInfo;
  bool _isVideo = true;

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
            Icons.keyboard_arrow_down,
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
      ),
      body: SingleChildScrollView(
        controller: widget.controller,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _showImage(),
                const YMargin(40),
                _textField(
                    hint: "Beschreibung",
                    multiline: true,
                    onSaved: (text) {
                      _postText = text;
                    }),
                YMargin(12),
                _buildCheckBox(),
                const YMargin(20),
                _buildCreatePostButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _createNews() async {
    if (!_formKey.currentState.validate() || _isVideo
        ? videoInfo == null
        : _image == null) return;

    _formKey.currentState.save();
    String imgUrl;

    setState(() {
      _isLoading = true;
    });

    if (!_isVideo) {
      StorageService service = StorageService(file: _image);
      imgUrl =
          await service.uploadNewsImage(StorageService.newsImageName(_newsId));
    }

    News news = News(
        id: _newsId,
        sessionId: widget.isSession ? widget.session?.id : '',
        campaignId:
            widget.isSession ? widget.session?.campaignId : widget.campaign?.id,
        campaignName: widget.isSession
            ? widget.session?.campaignName
            : widget.campaign?.name,
        campaignImgUrl: widget.isSession
            ? widget.session?.campaignImgUrl
            : widget.campaign?.imgUrl,
        createdAt: DateTime.now(),
        userId: um.uid,
        title: '',
        text: _postText,
        shortText: _postShortText,
        videoUrl: _isVideo ? videoInfo.videoUrl : null,
        imageUrl: _isVideo ? videoInfo.coverUrl : imgUrl,
        showInMainfeed: _showInMainfeed);

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
  }

  Future<void> _getImage() async {
    PickedFile _file =
        await ImagePicker().getImage(source: ImageSource.gallery);
    if (_file == null) return;
    _cropImage(File(_file.path));
  }

  Widget _showImage() {
    return Center(
      child: Container(
        width: double.infinity,
        height: 200,
        child: Material(
          borderRadius: BorderRadius.circular(Constants.radius),
          color: Colors.white,
          elevation: 1,
          clipBehavior: Clip.antiAlias,
          child: Center(
            child: _isVideo
                ? _processing
                    ? _getProgressBar()
                    : videoInfo == null
                        ? _buildPlaceholder()
                        : VideoWidget(url: videoInfo.videoUrl, play: true)
                : _image == null
                    ? _buildPlaceholder()
                    : Image.file(
                        _image,
                        width: _displaySize.width * 85,
                        fit: BoxFit.cover,
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
      maxLines: 7,
      cursorColor: Colors.grey,
      style: TextStyle(color: ThemeManager.of(context).colors.textOnContrast),
      keyboardType: multiline ? TextInputType.multiline : TextInputType.text,
      maxLength: maxLength,
      decoration: InputDecoration(
          alignLabelWithHint: true,
          counterText: "",
          labelStyle: TextStyle(
              color: ThemeManager.of(context).colors.textOnContrast,
              fontSize: 20,
              fontWeight: FontWeight.w700),
          labelText: hint,
          hintText: "",
          hintStyle: TextStyle(color: Colors.red),
          border: OutlineInputBorder(),
          errorBorder: OutlineInputBorder()),
    );
  }

  Widget _buildCheckBox() {
    return CheckboxListTile(
      value: _showInMainfeed,
      onChanged: (val) {
        setState(() {
          _showInMainfeed = !_showInMainfeed;
        });
      },
      title: Text("Im Mainfeed anzeigen"),
    );
  }

  Widget _buildPlaceholder() => Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildMediaButton(true),
          _buildMediaButton(false),
        ],
      );

  Widget _buildMediaButton(bool isPhoto) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          MaterialButton(
            clipBehavior: Clip.antiAlias,
            color: ThemeManager.of(context).colors.contrast,
            shape: CircleBorder(),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                isPhoto
                    ? Icons.photo_library_rounded
                    : Icons.video_collection_rounded,
                size: 40,
                color: ThemeManager.of(context).colors.textOnContrast,
              ),
            ),
            onPressed: () => isPhoto ? _getImage() : _takeVideo(),
          ),
          const YMargin(10),
          AutoSizeText(
            isPhoto ? 'Füge ein \nFoto hinzu' : 'Füge ein \nVideo hinzu',
            maxLines: 2,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyText1,
          )
        ],
      );

  Widget _buildCreatePostButton(BuildContext context) => Container(
        width: 220,
        height: 48,
        child: MaterialButton(
            color: ThemeManager.of(context).colors.dark,
            disabledColor: Colors.grey,
            child: !_isLoading
                ? Center(
                    child: Text(
                      'Post erstellen',
                      style: Theme.of(context)
                          .accentTextTheme
                          .button
                          .copyWith(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    ],
                  ),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            onPressed: _isLoading
                ? null
                : () {
                    _createNews();
                  }),
      );

  ///video uploading content

  void _onUploadProgress(TaskSnapshot event) {
    if (event.state == TaskState.running) {
      final double progress = event.bytesTransferred / event.totalBytes;
      setState(() {
        _progress = progress;
      });
    }
  }

  Future<String> _uploadFile(filePath, folderName, isVideo) async {
    final file = new File(filePath);
    final basename = p.basename(filePath);
    final dir = isVideo ? 'news/news_$_newsId' : 'news/news_$_newsId';

    final Reference ref = FirebaseStorage.instance
        .ref()
        .child(dir)
        .child(folderName)
        .child(basename);
    UploadTask uploadTask = ref.putFile(file);
    uploadTask.snapshotEvents.listen(_onUploadProgress);
    String videoUrl = '';
    await uploadTask
        .then((ts) async => videoUrl = await ts.ref.getDownloadURL());
    return videoUrl;
  }

  Future<void> _processVideo(File rawVideoFile) async {
    final videoName = 'video_$_newsId';
    final rawVideoPath = rawVideoFile.path;

    setState(() {
      _processPhase = 'Processing video...';
      _progress = 0.0;
    });

    setState(() {
      _processPhase = 'Processing video...';
      _progress = 0.0;
    });

    setState(() {
      _processPhase = 'Processing video...';
      _progress = 0.0;
    });
    final videoUrl = await _uploadFile(rawVideoPath, 'video_$_newsId', true);

    videoInfo = VideoInfo(
      videoUrl: videoUrl,
      uploadedAt: DateTime.now().millisecondsSinceEpoch,
      videoName: videoName,
    );

    setState(() {
      _processPhase = 'Uploading video';
      _progress = 0.0;
    });

    ///todo save video in firebase

    setState(() {
      _processPhase = '';
      _progress = 0.0;
      _processing = false;
    });
  }

  void _takeVideo() async {
    PickedFile videoFile;
    if (_imagePickerActive) return;

    _imagePickerActive = true;
    videoFile = await ImagePicker().getVideo(source: ImageSource.gallery);
    _imagePickerActive = false;
    if (videoFile == null) return;
    setState(() {
      _isVideo = true;
      _processing = true;
    });

    try {
      await _processVideo(File(videoFile.path));
    } catch (e) {
      print('${e.toString()}');
    } finally {
      setState(() {
        _processing = false;
      });
    }
  }

  Future<Null> _cropImage(File image) async {
    File croppedFile = await ImageCropper.cropImage(
        sourcePath: image.path,
        aspectRatioPresets: Platform.isAndroid
            ? [
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio16x9
              ]
            : [
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio5x3,
                CropAspectRatioPreset.ratio5x4,
                CropAspectRatioPreset.ratio7x5,
                CropAspectRatioPreset.ratio16x9
              ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          title: 'Cropper',
        ));
    if (croppedFile != null) {
      setState(() {
        _isVideo = false;
        _image = croppedFile;
      });
    }
  }

  _getProgressBar() {
    return Container(
      padding: EdgeInsets.all(30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(bottom: 30.0),
            child: Text(_processPhase),
          ),
          LinearProgressIndicator(
            value: _progress,
          ),
        ],
      ),
    );
  }
}
