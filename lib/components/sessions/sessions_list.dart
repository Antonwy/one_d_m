import 'dart:math';
import 'package:flutter/material.dart';
import 'package:one_d_m/api/api.dart';
import 'package:one_d_m/api/stream_result.dart';
import 'package:one_d_m/components/discovery_holder.dart';
import 'package:one_d_m/components/loading_indicator.dart';
import 'package:one_d_m/components/margin.dart';
import 'package:one_d_m/components/sessions/session_view.dart';
import 'package:one_d_m/components/sessions/sessions_holder.dart';
import 'package:one_d_m/extensions/theme_extensions.dart';
import 'package:one_d_m/helper/constants.dart';
import 'package:one_d_m/models/session_models/base_session.dart';
import 'package:one_d_m/provider/theme_manager.dart';

import '../warning_icon.dart';

class SessionList extends StatefulWidget {
  @override
  _SessionListState createState() => _SessionListState();
}

class _SessionListState extends State<SessionList> {
  Stream<StreamResult<List<BaseSession?>>>? _sessionsStream;

  @override
  void initState() {
    super.initState();
    _sessionsStream = Api().sessions().streamGet();
  }

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: StreamBuilder<StreamResult<List<BaseSession?>>>(
          stream: _sessionsStream,
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.hasError) {
              if (snapshot.hasError) print(snapshot.error);
              return SessionsLoadingOrError(snapshot.hasError);
            }

            List<BaseSession?> sessions = snapshot.data?.data ?? [];

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

class SessionsLoadingOrError extends StatelessWidget {
  final bool hasError;

  const SessionsLoadingOrError([this.hasError = false]);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          XMargin(12),
          Padding(
            padding: const EdgeInsets.all(2.0),
            child: Container(
              height: 180,
              width: 230,
              child: Material(
                color: context.theme.canvasColor,
                borderRadius: BorderRadius.circular(Constants.radius),
                child: Center(
                    child: hasError
                        ? WarningIcon(
                            message: "Konnte Sessions nicht laden...",
                          )
                        : LoadingIndicator(
                            size: 18,
                            strokeWidth: 3,
                            message: "Lade Sessions")),
              ),
            ),
          ),
          XMargin(6),
          Padding(
            padding: const EdgeInsets.all(2.0),
            child: Container(
              height: 180,
              width: 230,
              child: Material(
                color: context.theme.canvasColor,
                borderRadius: BorderRadius.circular(Constants.radius),
              ),
            ),
          ),
          XMargin(12),
        ],
      ),
    );
  }
}
