import 'package:flutter/material.dart';
import 'package:one_d_m/api/api.dart';
import 'package:one_d_m/api/endpoints/api_endpoint.dart';
import 'package:one_d_m/api/endpoints/sessions_endpoint.dart';
import 'package:one_d_m/components/sessions/long_session_list.dart';
import 'package:one_d_m/helper/database_service.dart';
import 'package:one_d_m/models/session_models/base_session.dart';
import 'package:one_d_m/provider/user_manager.dart';
import 'package:provider/provider.dart';

class LongSessionListManager extends ChangeNotifier {
  final List<BaseSession?>? sessions;
  final TextEditingController textController;
  final BuildContext? context;
  Future<List<BaseSession?>>? sessionsFuture;
  String _lastText = "";
  List<FilterTag> tags = [
    FilterTag(
        tag: "Zertifizierte",
        icon: Icons.verified,
        iconColor: Colors.greenAccent[400],
        type: FilterTagType.certified),
    FilterTag(
        tag: "Von mir", icon: Icons.person, type: FilterTagType.mySession),
    FilterTag(
        tag: "Abgeschloßen", icon: Icons.done, type: FilterTagType.goalReached),
  ];
  bool loading = false;

  LongSessionListManager(
      {this.sessions, this.sessionsFuture, required this.textController, this.context}) {
    textController.addListener(_listenForTextChanges);
  }

  bool get showDeleteAllIcon => textController.text.isNotEmpty;

  void _listenForTextChanges() {
    if (textController.text.isEmpty && _lastText.length == 0) return;
    if (textController.text.isEmpty && _lastText.length > 0) {
      sessionsFuture = Future.value(sessions);
      _lastText = textController.text;
      return;
    }
    _lastText = textController.text;
    callQuery();
  }

  void deleteText() {
    textController.text = "";
    callQuery();
  }

  void toggleTag(FilterTag tag) {
    tag.filtered = !tag.filtered;
    callQuery();
  }

  Future<void> callQuery() async {
    QueriedSessionEndpoint seq = Api().sessions().name(textController.text);

    if (tags[0].filtered ?? false) seq = seq.isCertified();
    if (tags[1].filtered ?? false)
      seq = seq.fromUser(context!.read<UserManager>().uid);
    if (tags[2].filtered ?? false) seq = seq.goalReached();

    loading = true;
    notifyListeners();

    sessionsFuture = seq.get();
    await sessionsFuture;

    loading = false;
    notifyListeners();
  }
}
