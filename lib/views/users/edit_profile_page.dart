import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:image_picker/image_picker.dart';
import 'package:one_d_m/api/api_result.dart';
import 'package:one_d_m/components/custom_text_field.dart';
import 'package:one_d_m/components/loading_indicator.dart';
import 'package:one_d_m/extensions/theme_extensions.dart';
import 'package:one_d_m/helper/constants.dart';
import 'package:one_d_m/helper/helper.dart';
import 'package:one_d_m/helper/storage_service.dart';
import 'package:one_d_m/helper/validate.dart';
import 'package:one_d_m/models/user.dart';
import 'package:one_d_m/provider/user_manager.dart';
import 'package:provider/provider.dart';

class EditProfile extends StatefulWidget {
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  late UserManager um;

  File? _image;
  bool _deletedImage = false;
  bool _loading = false;

  late TextEditingController _nameController, _phoneNumberController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    UserManager um = context.read<UserManager>();
    _nameController = TextEditingController(text: um.user?.name);
    _phoneNumberController = TextEditingController(text: um.user?.phoneNumber);
  }

  @override
  Widget build(BuildContext context) {
    um = Provider.of<UserManager>(context);

    ImageProvider? _imgWidget = _showImage();

    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          title: Text(
            "Profil ändern",
          ),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 5.0),
              child: AnimatedSwitcher(
                duration: Duration(milliseconds: 250),
                child: _loading
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 14.0),
                          child: LoadingIndicator(
                            size: 18,
                            strokeWidth: 3,
                          ),
                        ),
                      )
                    : Builder(builder: (bContext) {
                        return OfflineBuilder(
                            child: Container(),
                            connectivityBuilder: (c, connection, child) {
                              return IconButton(
                                  icon: Icon(Icons.done),
                                  onPressed: () async {
                                    if (connection == ConnectivityResult.none) {
                                      Helper.showConnectionSnackBar(context);
                                      return;
                                    }

                                    if (!(_formKey.currentState?.validate() ??
                                        false)) return;

                                    setState(() {
                                      _loading = true;
                                    });

                                    User currUser = User(
                                        id: um.uid!,
                                        name: um.user!.name,
                                        imgUrl: um.user!.imgUrl,
                                        thumbnailUrl: um.user!.thumbnailUrl,
                                        phoneNumber: um.user!.phoneNumber);

                                    StorageStreamResult? streamRes;

                                    if (_deletedImage) currUser.imgUrl = null;
                                    if (_image != null) {
                                      StorageService service =
                                          StorageService(file: _image!);

                                      streamRes = await service.uploadUserImage(
                                          StorageService.userImageName(um.uid),
                                          context: context);

                                      currUser.imgUrl = streamRes.url;
                                    }

                                    String _name = _nameController.text;
                                    String _phoneNumber =
                                        _phoneNumberController.text;

                                    if (Validate.username(_name) == null)
                                      currUser.name = _name;
                                    if (Validate.telephone(_phoneNumber) ==
                                        null)
                                      currUser.phoneNumber = _phoneNumber;

                                    if (streamRes != null &&
                                        streamRes.snackBarController != null) {
                                      streamRes.streamController
                                          .add("Update Nutzerdaten...");
                                    }

                                    ApiResult res =
                                        await um.updateUser(currUser);

                                    if (res.hasError()) {
                                      print(res.message);

                                      if (streamRes != null) {
                                        await streamRes.error();
                                      }

                                      setState(() {
                                        _loading = false;
                                      });

                                      return;
                                    }

                                    if (streamRes != null)
                                      await streamRes.finish();

                                    Navigator.pop(context);
                                  });
                            });
                      }),
              ),
            )
          ],
        ),
        body: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    GestureDetector(
                      onTap: _getImage,
                      child: Container(
                        width: 60,
                        height: 60,
                        child: Material(
                          borderRadius: BorderRadius.circular(Constants.radius),
                          elevation: 1,
                          clipBehavior: Clip.antiAlias,
                          child: _imgWidget == null
                              ? Icon(Icons.person,
                                  color: context.theme.primaryColor)
                              : Image(image: _imgWidget, fit: BoxFit.cover),
                        ),
                      ),
                    ),
                    Row(
                      children: <Widget>[
                        OutlinedButton(
                          onPressed: _getImage,
                          child: Text("Ändern"),
                        ),
                        SizedBox(width: 10),
                        OutlinedButton(
                          onPressed: _deleteImage,
                          child: Text("Löschen"),
                        ),
                      ],
                    )
                  ],
                ),
                SizedBox(height: 20),
                _textView(
                    controller: _nameController,
                    label: "Nutzername",
                    formatters: [
                      FilteringTextInputFormatter.allow(RegExp("[a-z0-9-._]"))
                    ]),
                SizedBox(height: 10),
                _textView(
                    controller: _phoneNumberController,
                    label: "Telefonnummer",
                    validator: Validate.telephone),
                SizedBox(height: 10),
                OfflineBuilder(
                    child: Container(),
                    connectivityBuilder: (context, connection, child) {
                      return Consumer<UserManager>(
                        builder: (context, um, child) => OutlinedButton.icon(
                            onPressed: () async {
                              if (connection == ConnectivityResult.none) {
                                Helper.showConnectionSnackBar(context);
                                return;
                              }

                              if (!(await Helper.showWarningAlert(context,
                                      "Bist du dir sicher, das du dein Passwort zurücksetzen willst?",
                                      title: "Sicher?") ??
                                  false)) return;

                              setState(() {
                                _loading = true;
                              });
                              await um.resetPassword();
                              setState(() {
                                _loading = false;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content: Text(
                                      "Wir haben dir eine Email zum Zurücksetzen deines Passwortes geschickt!")));
                            },
                            icon: Icon(Icons.restore),
                            label: Text("Passwort zurücksetzen")),
                      );
                    })
              ],
            ),
          ),
        ));
  }

  _showImage() {
    if (_deletedImage) return null;
    if ((um.user!.thumbnailUrl ?? um.user!.imgUrl) == null && _image == null)
      return null;
    if (_image != null) return FileImage(_image!);

    return CachedNetworkImageProvider(
        um.user!.thumbnailUrl ?? um.user!.imgUrl!);
  }

  _getImage() async {
    ImagePicker _picker = ImagePicker();
    XFile? file = await _picker.pickImage(source: ImageSource.gallery);

    setState(() {
      _deletedImage = false;
      _image = file != null ? File(file.path) : null;
    });
  }

  _deleteImage() {
    setState(() {
      _deletedImage = true;
      _image = null;
    });
  }

  Widget _textView(
          {required TextEditingController controller,
          String? label,
          String? Function(String?)? validator,
          List<TextInputFormatter>? formatters}) =>
      CustomTextField(
        controller: controller,
        inputFormatter: formatters ?? [],
        validator: validator,
        textColor: context.theme.colorScheme.onBackground,
        focusedColor: context.theme.colorScheme.onBackground,
        activeColor: context.theme.colorScheme.onBackground.withOpacity(.4),
        label: label,
      );
}
