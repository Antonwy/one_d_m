import 'package:one_d_m/api/api_call.dart';
import 'package:one_d_m/api/endpoints/api_endpoint.dart';
import 'package:one_d_m/models/session_models/base_session.dart';
import 'package:one_d_m/models/session_models/session.dart';
import 'package:one_d_m/models/session_models/uploadable_session.dart';

class SessionsEndpoint extends ApiEndpoint<BaseSession>
    with SubscribableEndpoint, SessionEndpointQueries {
  SessionsEndpoint([String route = "sessions"])
      : super(route,
            formatter: (map) => Session.fromJson(map),
            listFormatter: BaseSession.listFromJson);

  Future<Session> create(UploadableSession session) {
    return ApiCall<Session>(this).post(session.toMap());
  }

  Future<void> update(UploadableSession session) {
    return ApiCall<Session>(this.addRoute(session.id))
        .put(session.toUpdateMap());
  }

  Future<void> delete(String sid) {
    return ApiCall<Session>(this.addRoute(sid)).delete();
  }

  @override
  SessionsEndpoint addRoute(String routeToAdd) {
    String finalRoute = route + '/' + routeToAdd;
    return SessionsEndpoint(finalRoute);
  }
}

class QueriedSessionEndpoint = QueryableEndpoint<BaseSession>
    with SessionEndpointQueries;

mixin SessionEndpointQueries on ApiEndpoint<BaseSession> {
  QueriedSessionEndpoint name(String name) {
    return QueriedSessionEndpoint(route,
        query: {...(query ?? {}), 'name': name},
        formatter: formatter,
        listFormatter: listFormatter);
  }

  QueriedSessionEndpoint isCertified() {
    return QueriedSessionEndpoint(route,
        query: {...(query ?? {}), 'is_certified': true},
        formatter: formatter,
        listFormatter: listFormatter);
  }

  QueriedSessionEndpoint fromUser(String uid) {
    return QueriedSessionEndpoint(route,
        query: {...(query ?? {}), 'creator_id': uid},
        formatter: formatter,
        listFormatter: listFormatter);
  }

  QueriedSessionEndpoint goalReached() {
    return QueriedSessionEndpoint(route,
        query: {...(query ?? {}), 'goal_reached': true},
        formatter: formatter,
        listFormatter: listFormatter);
  }
}
