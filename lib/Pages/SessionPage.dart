import 'package:flutter/material.dart';
import 'package:one_d_m/Helper/Provider/SessionManager.dart';

class SessionPage extends StatelessWidget {
  final SessionManager sessionManager;
  final ScrollController scrollController;

  const SessionPage({Key key, this.sessionManager, this.scrollController})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(sessionManager.baseSession.name),
      ),
    );
  }
}
