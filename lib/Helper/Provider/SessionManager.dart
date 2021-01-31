import 'package:one_d_m/Helper/Campaign.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/Donation.dart';
import 'package:one_d_m/Helper/Session.dart';

abstract class BaseSessionManager {
  final BaseSession baseSession;
  Stream<List<SessionMember>> membersStream;
  Stream<List<Donation>> donationStream;
  Stream<Session> sessionStream;
  List<Session> mySessions = [];
  List<String> mySessionIds = [];

  void initStreams();

  BaseSessionManager(this.baseSession) {
    sessionStream = DatabaseService.getSession(baseSession.id);
    initStreams();
  }
}

class SessionManager extends BaseSessionManager {
  Stream<List<SessionMember>> invitedMembersStream;

  SessionManager(BaseSession baseSession) : super(baseSession);

  @override
  void initStreams() {
    membersStream = DatabaseService.getSessionMembers(baseSession.id);
    invitedMembersStream =
        DatabaseService.getInvitedSessionMembers(baseSession.id);
  }
}

class UserSessionManager extends BaseSessionManager {
  final String uid;
  Session session;
  List<Session> mySessions = [];
  List<String> mySessionIds = [];

  UserSessionManager({this.session, this.uid}) : super(session);

  @override
  void initStreams() {
    ///listen events for user followed sessions
    DatabaseService.getCertifiedSessions().listen((event) {
      mySessions.clear();
      event.forEach((element) {
        DatabaseService.userIsInSession(uid, element.id).listen((isExist) {
          if (isExist) {
            mySessions.add(element);
          }
        });
      });
    });

    DatabaseService.getSessionPosts().listen((news) {
      mySessionIds.clear();
      news.sort((a, b) => b.createdAt?.compareTo(a.createdAt));

      List<String> sessionsWithPost = [];

      news.forEach((element) {
        sessionsWithPost.add(element.sessionId);
      });

      ///sort and add sessions with post to the begining of the list
      ///
      List<String> sessionIds = sessionsWithPost.toSet().toList();
      DatabaseService.getCertifiedSessions().listen((sessions) {
        List<String> allSessions = [];

        sessions.forEach((element) {
          allSessions.add(element.id);
        });

        ///add sessions that doesn't have posts

        sessionIds = [...sessionIds, ...allSessions];

        List<String> uniqueIds = sessionIds.toSet().toList();
        uniqueIds.forEach((element) {
          DatabaseService.userIsInSession(uid, element).listen((isExist) {
            if (isExist) {
              mySessionIds.add(element);
            }
          });
        });
      });
    });
  }
}

class CertifiedSessionManager extends BaseSessionManager {
  final String uid;
  Stream<bool> isInSession;
  Session session;
  Stream<Campaign> campaign;

  CertifiedSessionManager({this.session, this.uid}) : super(session);

  @override
  void initStreams() {
    isInSession = DatabaseService.userIsInSession(uid, baseSession.id);
    membersStream = DatabaseService.getSessionMembers(baseSession.id, 100);
    donationStream = DatabaseService.getDonationsFromSession(baseSession.id);
    campaign = DatabaseService.getCampaignStream(session.campaignId);
  }
}
