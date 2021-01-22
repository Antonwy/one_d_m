import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/Helper/Campaign.dart';
import '../DatabaseService.dart';
import '../Session.dart';
import '../User.dart';

class CreateSessionManager extends ChangeNotifier {
  Campaign _selectedCampaign;
  List<User> _selectedUsers = [];
  String sessionName, sessionDescription = "";
  int amountPerUser = 3;
  bool _loading = false;

  bool get loading => _loading;

  set selectedCampaign(Campaign campaign) {
    _selectedCampaign = campaign;
    notifyListeners();
  }

  Campaign get selectedCampaign => _selectedCampaign;

  List<User> get selectedUsers => _selectedUsers;

  void addUser(User user) {
    _selectedUsers.add(user);
    notifyListeners();
  }

  void removeUser(User user) {
    _selectedUsers.remove(user);
    notifyListeners();
  }

  void setLoading(bool l) {
    _loading = l;
    notifyListeners();
  }

  Future<String> createSession() async {
    setLoading(true);

    if (_selectedUsers.isEmpty) {
      setLoading(false);
      return "Du musst mindestens 1 Mitglied wählen.";
    }

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

    UploadableSession session = UploadableSession(
        sessionName: sessionName,
        amountPerUser: amountPerUser,
        campaign: selectedCampaign,
        members: selectedUsers,
        sessionDescription: sessionDescription);

    try {
      await DatabaseService.createSession(session);
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
}
