import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/Session.dart';

abstract class BaseSessionManager {
  final BaseSession baseSession;
  Stream<List<SessionMember>> membersStream;
  Stream<Session> sessionStream;

  void initStreams();

  BaseSessionManager(this.baseSession) {
    initStreams();
  }
}

class SessionManager extends BaseSessionManager {
  Stream<List<SessionMember>> invitedMembersStream;

  SessionManager(BaseSession baseSession) : super(baseSession);

  @override
  void initStreams() {
    sessionStream = DatabaseService.getSession(baseSession.id);
    membersStream = DatabaseService.getSessionMembers(baseSession.id);
    invitedMembersStream =
        DatabaseService.getInvitedSessionMembers(baseSession.id);
  }
}

class CertifiedSessionManager extends BaseSessionManager {
  final String uid;
  Stream<bool> isInSession;

  CertifiedSessionManager({BaseSession baseSession, this.uid})
      : super(baseSession);

  @override
  void initStreams() {
    isInSession = DatabaseService.userIsInSession(uid, baseSession.id);
    membersStream = DatabaseService.getSessionMembers(baseSession.id, 10);
  }
}
