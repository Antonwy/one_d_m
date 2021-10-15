import 'package:flutter/material.dart';
import 'package:one_d_m/api/api.dart';
import 'package:one_d_m/components/loading_indicator.dart';
import 'package:one_d_m/components/sessions/session_view.dart';
import 'package:one_d_m/models/session_models/base_session.dart';

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
    return FutureBuilder<List<BaseSession?>>(
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
                              index == snapshot.data!.length - 1 ? 12.0 : 0.0),
                      child: SessionView(snapshot.data![index]),
                    ),
                itemCount: snapshot.data!.length),
          );
        });
  }
}
