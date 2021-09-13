import 'dart:math';
import 'package:flutter/material.dart';
import 'package:one_d_m/api/api.dart';
import 'package:one_d_m/api/stream_result.dart';
import 'package:one_d_m/components/discovery_holder.dart';
import 'package:one_d_m/components/sessions/session_view.dart';
import 'package:one_d_m/components/sessions/sessions_holder.dart';
import 'package:one_d_m/helper/database_service.dart';
import 'package:one_d_m/models/session_models/base_session.dart';
import 'package:one_d_m/provider/theme_manager.dart';

class SessionList extends StatefulWidget {
  @override
  _SessionListState createState() => _SessionListState();
}

class _SessionListState extends State<SessionList> {
  Stream<StreamResult<List<BaseSession>>> _sessionsStream;

  @override
  void initState() {
    super.initState();
    _sessionsStream = Api().sessions().streamGet();
  }

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: StreamBuilder<StreamResult<List<BaseSession>>>(
          initialData: StreamResult(fromCache: true, data: []),
          stream: _sessionsStream,
          builder: (context, snapshot) {
            List<BaseSession> sessions = snapshot.data?.data ?? [];

            int minSessionsToShow = 2;
            int length = min(minSessionsToShow, sessions.length);
            bool showSessionHolder = sessions.length > minSessionsToShow;

            return Container(
                height: 180,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  separatorBuilder: (context, index) => SizedBox(
                    width: 8,
                  ),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(
                          left: index == 0 ? 12.0 : 0.0,
                          right: index == length ? 12.0 : 0.0),
                      child: index == length
                          ? showSessionHolder
                              ? SessionHolder(
                                  sessions,
                                  minSessionsToShow: minSessionsToShow,
                                )
                              : SizedBox.shrink()
                          : index == 0
                              ? DiscoveryHolder.sessions(
                                  child: SessionView(sessions[index]),
                                  tapTarget: Icon(Icons.arrow_forward,
                                      color: ThemeManager.of(context)
                                          .colors
                                          .contrast),
                                )
                              : SessionView(sessions[index]),
                    );
                  },
                  itemCount: length == 0 ? length : length + 1,
                ));
          }),
    );
  }
}
