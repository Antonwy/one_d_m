import 'dart:io';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/api/api.dart';
import 'package:one_d_m/api/api_error.dart';
import 'package:one_d_m/api/api_result.dart';
import 'package:one_d_m/api/api_success.dart';
import 'package:one_d_m/helper/storage_service.dart';
import 'package:one_d_m/models/campaign_models/base_campaign.dart';
import 'package:one_d_m/models/donation_unit.dart';
import 'package:one_d_m/models/session_models/preview_session.dart';
import 'package:one_d_m/models/session_models/session.dart';
import 'package:one_d_m/models/session_models/uploadable_session.dart';
import 'package:one_d_m/provider/theme_manager.dart';
import 'package:one_d_m/provider/user_manager.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'sessions_manager.dart';

class CreateSessionManager extends ChangeNotifier {
  BaseCampaign? _selectedCampaign;
  String? sessionName,
      sessionDescription = "",
      creatorId,
      sessionId = Uuid().v4();
  int donationGoal = 100;
  bool _loading = false, editMode = false;
  File? _image;
  Color? _primaryColor, _secondaryColor;
  BaseSessionManager? baseSessionManager;
  ThemeData theme;

  CreateSessionManager(BuildContext context,
      {this.baseSessionManager, required this.theme}) {
    _primaryColor = theme.primaryColor;
    _secondaryColor = theme.colorScheme.secondary;
    creatorId = context.read<UserManager>().uid;
    if (baseSessionManager != null) {
      editMode = true;
      sessionName = baseSessionManager!.baseSession!.name;
      sessionDescription = baseSessionManager!.baseSession!.description;
      primaryColor = baseSessionManager!.baseSession!.primaryColor;
      secondaryColor = baseSessionManager!.baseSession!.secondaryColor;
      selectedCampaign = BaseCampaign(
          id: baseSessionManager!.baseSession!.campaignId,
          name: baseSessionManager!.session?.campaignTitle ?? "Not Found",
          unit: DonationUnit());
    }
  }

  Color? get primaryColor => _primaryColor;

  set primaryColor(Color? color) {
    _primaryColor = color;
    notifyListeners();
  }

  Color? get secondaryColor => _secondaryColor;

  set secondaryColor(Color? color) {
    _secondaryColor = color;
    notifyListeners();
  }

  bool get loading => _loading;

  set selectedCampaign(BaseCampaign? campaign) {
    _selectedCampaign = campaign;
    notifyListeners();
  }

  File? get image => _image;

  set image(File? file) {
    _image = file;
    notifyListeners();
  }

  BaseCampaign? get selectedCampaign => _selectedCampaign;

  void setLoading(bool l) {
    _loading = l;
    notifyListeners();
  }

  Future<ApiResult<Session>> createSession(BuildContext context) async {
    setLoading(true);

    if (sessionDescription!.length < 5) {
      setLoading(false);
      return ApiError(
          "Du musst eine Beschreibung eingeben, der länger als 5 Zeichen ist.");
    }

    if (sessionName!.length < 2) {
      setLoading(false);
      return ApiError(
          "Du musst einen Sessionnamen eingeben, der länger als 2 Zeichen ist.");
    }

    if (sessionName!.length > 20) {
      setLoading(false);
      return ApiError(
          "Du musst einen Sessionnamen eingeben, der kürzer als 20 Zeichen ist.");
    }

    if (image == null && !editMode) {
      setLoading(false);
      return ApiError("Du musst ein Bild einstellen.");
    }

    UploadableSession session = uploadableSession;

    print("Image: $image");

    if (editMode) session.id = baseSessionManager!.baseSession!.id;

    print(session.id);

    StorageStreamResult? storageRes;

    if (image != null) {
      StorageService storageService = StorageService(file: session.image!);
      storageRes = await storageService.uploadSessionImageStream(
          StorageService.sessionImageName(session.id),
          context: context);

      session.imgUrl = storageRes.url;
    }

    try {
      if (storageRes != null) {
        storageRes.streamController
            .add(editMode ? "Updating Session..." : "Uploading Session...");
      }

      if (!editMode) {
        Session? s = await Api().sessions().create(session);

        if (storageRes != null) await storageRes.finish();
        setLoading(false);
        return ApiSuccess(data: s);
      } else if (uploadableSession.primaryColor !=
              baseSessionManager!.baseSession!.primaryColor ||
          uploadableSession.secondaryColor !=
              baseSessionManager!.baseSession!.secondaryColor ||
          uploadableSession.name != baseSessionManager!.baseSession!.name ||
          uploadableSession.donationGoal !=
              baseSessionManager!.baseSession!.donationGoal ||
          uploadableSession.description !=
              baseSessionManager!.baseSession!.description ||
          image != null) {
        print("UPDATING...");
        await Api().sessions().update(session);
        if (storageRes != null) await storageRes.finish();
        setLoading(false);
      }
    } catch (e) {
      print(e);
      if (storageRes != null) await storageRes.error();
      setLoading(false);
      return ApiError("Etwas ist schief gelaufen, versuche es später erneut!");
    }

    return ApiSuccess();
  }

  PreviewSession get previewSession {
    return PreviewSession(
        id: baseSessionManager?.baseSession?.id,
        campaignId: selectedCampaign!.id,
        description: sessionDescription,
        name: sessionName,
        donationGoal: donationGoal,
        donationGoalCurrent: 0,
        donationUnit: selectedCampaign?.unit ?? DonationUnit(),
        creatorId: creatorId,
        secondaryColor: secondaryColor,
        primaryColor: primaryColor,
        imgUrl: baseSessionManager?.baseSession?.imgUrl,
        uploadableSession: uploadableSession);
  }

  UploadableSession get uploadableSession {
    return UploadableSession(
        id: editMode ? baseSessionManager?.baseSession?.id : sessionId,
        name: sessionName,
        donationGoal: donationGoal,
        campaign: selectedCampaign,
        description: sessionDescription,
        primaryColor: primaryColor,
        secondaryColor: secondaryColor,
        image: image,
        creatorId: creatorId);
  }
}
