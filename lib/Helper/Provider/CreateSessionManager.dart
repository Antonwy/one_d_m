import 'dart:io';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/Helper/Campaign.dart';
import 'package:one_d_m/Helper/StorageService.dart';
import 'package:one_d_m/Helper/ThemeManager.dart';
import 'package:one_d_m/Helper/UserManager.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../DatabaseService.dart';
import '../Session.dart';
import '../User.dart';

class CreateSessionManager extends ChangeNotifier {
  Campaign _selectedCampaign;
  String sessionName,
      sessionDescription = "",
      creatorId,
      sessionId = Uuid().v4();
  int donationGoal = 100;
  bool _loading = false, editMode = false;
  File _image;
  Color _primaryColor, _secondaryColor;
  BaseSession baseSession;

  CreateSessionManager(BuildContext context, {this.baseSession}) {
    ThemeManager _theme = ThemeManager.of(context, listen: false);
    _primaryColor = _theme.colors.dark;
    _secondaryColor = _theme.colors.contrast;
    creatorId = context.read<UserManager>().uid;
    if (baseSession != null) {
      editMode = true;
      sessionName = baseSession.name;
      sessionDescription = baseSession.sessionDescription;
      primaryColor = baseSession.primaryColor;
      secondaryColor = baseSession.secondaryColor;
      selectedCampaign = Campaign(
          name: baseSession.campaignName,
          imgUrl: baseSession.campaignImgUrl,
          id: baseSession.campaignId,
          unit: baseSession.donationUnit);
    }
  }

  Color get primaryColor => _primaryColor;

  set primaryColor(Color color) {
    _primaryColor = color;
    notifyListeners();
  }

  Color get secondaryColor => _secondaryColor;

  set secondaryColor(Color color) {
    _secondaryColor = color;
    notifyListeners();
  }

  bool get loading => _loading;

  set selectedCampaign(Campaign campaign) {
    _selectedCampaign = campaign;
    notifyListeners();
  }

  File get image => _image;

  set image(File file) {
    _image = file;
    notifyListeners();
  }

  Campaign get selectedCampaign => _selectedCampaign;

  void setLoading(bool l) {
    _loading = l;
    notifyListeners();
  }

  Future<String> createSession() async {
    setLoading(true);

    if (sessionDescription.length < 5) {
      setLoading(false);
      return "Du musst eine Beschreibung eingeben, der länger als 5 Zeichen ist.";
    }

    if (sessionName.length < 2) {
      setLoading(false);
      return "Du musst einen Sessionnamen eingeben, der länger als 2 Zeichen ist.";
    }

    if (sessionName.length > 20) {
      setLoading(false);
      return "Du musst einen Sessionnamen eingeben, der kürzer als 20 Zeichen ist.";
    }

    if (image == null && !editMode) {
      setLoading(false);
      return "Du musst ein Bild einstellen.";
    }

    UploadableSession session = uploadableSession;

    print("Image: $image");

    if (editMode) session.id = baseSession.id;

    print(session.id);

    if (image != null) {
      StorageService storageService = StorageService(file: session.image);
      session.imgUrl = await storageService
          .uploadSessionImage(StorageService.sessionImageName(session.id));
    }

    try {
      if (!editMode) {
        await DatabaseService.createSession(session);
      } else if (uploadableSession.primaryColor != baseSession.primaryColor ||
          uploadableSession.secondaryColor != baseSession.secondaryColor ||
          uploadableSession.sessionName != baseSession.name ||
          uploadableSession.donationGoal != baseSession.donationGoal ||
          uploadableSession.sessionDescription !=
              baseSession.sessionDescription ||
          image != null) {
        print("UPDATING...");
        await DatabaseService.updateSession(session);
      }
    } on FirebaseFunctionsException catch (e) {
      setLoading(false);
      return e.message;
    } catch (e) {
      print(e);
      setLoading(false);
      return "Etwas ist schief gelaufen, versuche es später erneut!";
    }

    setLoading(false);
    return null;
  }

  PreviewSession get previewSession {
    return PreviewSession(
        id: baseSession?.id,
        campaignId: selectedCampaign.id,
        name: sessionName,
        donationGoal: donationGoal,
        donationGoalCurrent: 0,
        donationUnit: "DV",
        donationUnitEffect: "test",
        sessionDescription: sessionDescription,
        creatorId: creatorId,
        secondaryColor: secondaryColor,
        primaryColor: primaryColor,
        imgUrl: baseSession?.imgUrl,
        uploadableSession: uploadableSession);
  }

  UploadableSession get uploadableSession {
    return UploadableSession(
        id: sessionId,
        sessionName: sessionName,
        donationGoal: donationGoal,
        campaign: selectedCampaign,
        sessionDescription: sessionDescription,
        primaryColor: primaryColor,
        secondaryColor: secondaryColor,
        image: image,
        creatorId: creatorId);
  }
}
