import 'package:flutter/material.dart';
import 'package:one_d_m/api/api.dart';
import 'package:one_d_m/components/keep_alive_stream.dart';
import 'package:one_d_m/components/loading_indicator.dart';
import 'package:one_d_m/components/margin.dart';
import 'package:one_d_m/components/sessions/session_join_button.dart';
import 'package:one_d_m/components/sessions/session_view.dart';
import 'package:one_d_m/models/news.dart';
import 'package:one_d_m/models/session_models/base_session.dart';
import 'package:one_d_m/models/session_models/certified_session.dart';
import 'package:one_d_m/provider/theme_manager.dart';
import 'package:one_d_m/provider/user_manager.dart';
import 'package:one_d_m/provider/sessions_manager.dart';
import 'package:provider/provider.dart';
import 'database_service.dart';

class RecomendedSessions extends StatefulWidget {
  @override
  _RecomendedSessionsState createState() => _RecomendedSessionsState();
}

class _RecomendedSessionsState extends State<RecomendedSessions> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _buildLatestSessionsWithPost();
  }

  Widget _buildLatestSessionsWithPost() {
    return FutureBuilder<List<BaseSession>>(
        future: Api().sessions().get(),
        builder: (_, snapshot) {
          if (!snapshot.hasData) return LoadingIndicator();

          return Container(
            height: 180,
            child: ListView.separated(
                scrollDirection: Axis.horizontal,
                separatorBuilder: (context, index) => SizedBox(
                      width: 8,
                    ),
                itemBuilder: (context, index) => Padding(
                      padding: EdgeInsets.only(
                          left: index == 0 ? 12 : 0,
                          right:
                              index == snapshot.data.length - 1 ? 12.0 : 0.0),
                      child: SessionView(snapshot.data[index]),
                    ),
                itemCount: snapshot.data.length),
          );
        });
  }
}
