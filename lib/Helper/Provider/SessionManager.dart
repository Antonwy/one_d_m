import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/Session.dart';

class SessionManager {
  final BaseSession baseSession;
  Stream<Session> sessionStream;
  Stream<List<SessionMember>> membersStream;
  Stream<List<SessionMember>> invitedMembersStream;

  SessionManager(this.baseSession) {
    sessionStream = DatabaseService.getSession(baseSession.id);
    membersStream = DatabaseService.getSessionMembers(baseSession.id);
    invitedMembersStream =
        DatabaseService.getInvitedSessionMembers(baseSession.id);
  }
}
