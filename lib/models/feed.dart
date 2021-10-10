import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/components/custom_text_field.dart';
import 'package:one_d_m/components/donation_widget.dart';
import 'package:one_d_m/components/margin.dart';
import 'package:one_d_m/components/user_follow_button.dart';
import 'package:one_d_m/helper/constants.dart';
import 'package:one_d_m/helper/database_service.dart';
import 'package:one_d_m/models/user.dart';
import 'package:one_d_m/provider/theme_manager.dart';
import 'package:one_d_m/provider/user_manager.dart';
import 'package:one_d_m/views/users/user_page.dart';
import 'package:provider/provider.dart';
import 'package:styled_text/styled_text.dart';
import 'package:timeago/timeago.dart' as timeago;

class FeedDoc {
  final List<String> unseenObjects;

  FeedDoc(this.unseenObjects);

  factory FeedDoc.fromDoc(DocumentSnapshot doc) => FeedDoc(
      List.from((doc.data() as Map<String, dynamic>)[UNSEEN_OBJECTS] ?? []));

  factory FeedDoc.zero() => FeedDoc([]);

  int get unseen => unseenObjects.length;

  static const String UNSEEN_OBJECTS = "unseen_objects";
}

abstract class FeedObject {
  final DateTime? createdAt;
  final String? id;

  const FeedObject({this.id, this.createdAt});

  Widget buildWidget(BuildContext context, {bool highlighted = false});

  factory FeedObject.fromDoc(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    final feedType = data[FEED_TYPE];

    if (feedType == FOLLOW)
      return FollowNotification.fromDoc(doc);
    else if (feedType == SURVEY) return SurveyNotification.fromDoc(doc);

    return FollowNotification.fromDoc(doc);
  }

  static DateTime dateFromDoc(DocumentSnapshot doc) =>
      ((doc.data() as Map<String, dynamic>)[FeedObject.CREATED_AT] as Timestamp)
          .toDate();

  static List<FeedObject> fromQuerySnapshot(QuerySnapshot qs) =>
      qs.docs.map((doc) => FeedObject.fromDoc(doc)).toList();

  static const String FEED_TYPE = "feed_type",
      FOLLOW = "follow",
      SURVEY = "survey",
      CREATED_AT = "created_at";
}

class FollowNotification extends FeedObject {
  @override
  Widget buildWidget(BuildContext context, {bool highlighted = false}) {
    return _FollowNotificationWidget(this, highlighted);
  }

  FollowNotification({DateTime? createdAt, String? id})
      : super(createdAt: createdAt, id: id);

  factory FollowNotification.fromDoc(DocumentSnapshot doc) =>
      FollowNotification(
        id: doc.id,
        createdAt: FeedObject.dateFromDoc(doc),
      );

  @override
  String toString() => 'FollowNotification(createdAt: $createdAt, id: $id)';
}

class SurveyNotification extends FeedObject {
  const SurveyNotification({String? id, DateTime? createdAt})
      : super(createdAt: createdAt, id: id);

  factory SurveyNotification.fromDoc(DocumentSnapshot doc) =>
      SurveyNotification(
        id: doc.id,
        createdAt: FeedObject.dateFromDoc(doc),
      );

  @override
  Widget buildWidget(BuildContext context, {bool highlighted = false}) {
    return FutureBuilder<Survey?>(
        future: DatabaseService.getSurveyDeleteFromFeedIfNotExists(
            id, context.read<UserManager>().uid),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data != null)
              return snapshot.data!
                  .buildWidget(context, highlighted: highlighted);
          }
          return Container();
        });
  }
}

abstract class Survey<T extends SurveyResult> extends FeedObject {
  final String? question, surveyType;
  final bool? rollout, onlyAdmin;
  final int? resultCount;
  final T? result;

  Survey(
      {String? id,
      DateTime? createdAt,
      this.question,
      this.surveyType,
      this.rollout,
      this.onlyAdmin,
      this.result,
      this.resultCount = 0})
      : super(createdAt: createdAt, id: id);

  static Survey? fromDoc(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    final surveyType = data[SURVEY_TYPE];
    print("SURVEY_TYPE == $surveyType");
    if (surveyType == MULTIPLE_CHOICE) return CheckBoxSurvey.fromDoc(doc);
    if (surveyType == SINGLE_CHOICE)
      return CheckBoxSurvey.fromDoc(doc, isSingleChoice: true);
    if (surveyType == YES_NO) return SingleAnswerSurvey<bool>.fromDoc(doc);
    if (surveyType == TEXT) return SingleAnswerSurvey<String>.fromDoc(doc);

    return null;
  }

  Map<String, dynamic> buildResult() {
    return result!.toMap(this);
  }

  Future<void> sendResult(BuildContext context) async {
    await DatabaseService.sendSurveyResults(this,
        uid: context.read<UserManager>().uid);
  }

  static const String SURVEY_TYPE = "survey_type",
      RESULT_COUNT = "result_count",
      MULTIPLE_CHOICE = "multiple-choice",
      SINGLE_CHOICE = "single-choice",
      YES_NO = "yes-no",
      TEXT = "text",
      SINGLE_ANSWER = "single-answer",
      ROLLOUT = "rollout",
      ONLY_ADMINS = "only_admins",
      QUESTION = "question";
}

class SingleAnswerSurvey<T> extends Survey<SingleAnswerSurveyResult<T>> {
  final Map<String, int>? evaluation;

  SingleAnswerSurvey(
      {String? id,
      DateTime? createdAt,
      String? question,
      bool rollout = false,
      bool onlyAdmin = false,
      int resultCount = 0,
      this.evaluation})
      : super(
            createdAt: createdAt,
            id: id,
            question: question,
            surveyType: Survey.SINGLE_ANSWER,
            rollout: rollout,
            onlyAdmin: onlyAdmin,
            result: SingleAnswerSurveyResult<T>(),
            resultCount: resultCount);

  factory SingleAnswerSurvey.fromDoc(DocumentSnapshot doc) {
    print("SINGLE ANSWER FROM DOC");

    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return SingleAnswerSurvey(
      createdAt: FeedObject.dateFromDoc(doc),
      id: doc.id,
      question: data[Survey.QUESTION],
      rollout: data[Survey.ROLLOUT] ?? false,
      onlyAdmin: data[Survey.ONLY_ADMINS] ?? false,
      resultCount: data[Survey.RESULT_COUNT] ?? 0,
      evaluation: Map.from(
        data[CheckBoxSurvey.EVALUATION] ?? {},
      ),
    );
  }

  @override
  Widget buildWidget(BuildContext context, {bool highlighted = false}) {
    print("BUILDING SINGLE ANSWER...");
    print("TYPE: ${T.toString()}");

    Widget getWidget() {
      if (T.toString() == "bool") {
        print("RETURNING BOOL SURVEY");
        return _YesNoSurveyWidget();
      } else {
        print("RETURNING STRING SURVEY");
        return _TextSurveyWidget();
      }
    }

    return _SurveyWrapper<SingleAnswerSurvey<T>>(
      getWidget(),
      survey: this,
    );
  }
}

class CheckBoxSurvey extends Survey<CheckBoxSurveyResult> {
  final Map<String, int>? evaluation;
  final List<String>? answers;
  final bool isSingleChoice;

  CheckBoxSurvey(
      {String? id,
      DateTime? createdAt,
      String? question,
      this.answers,
      bool rollout = false,
      bool onlyAdmin = false,
      int? resultCount,
      this.evaluation,
      this.isSingleChoice = false})
      : super(
            createdAt: createdAt,
            id: id,
            question: question,
            surveyType: Survey.MULTIPLE_CHOICE,
            rollout: rollout,
            onlyAdmin: onlyAdmin,
            result: CheckBoxSurveyResult(isSingleChoice),
            resultCount: resultCount);

  factory CheckBoxSurvey.fromDoc(DocumentSnapshot doc,
      {bool isSingleChoice = false}) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return CheckBoxSurvey(
        createdAt: FeedObject.dateFromDoc(doc),
        id: doc.id,
        question: data[Survey.QUESTION],
        answers: List.from(data[ANSWERS] ?? []),
        rollout: data[Survey.ROLLOUT] ?? false,
        onlyAdmin: data[Survey.ONLY_ADMINS] ?? false,
        resultCount: data[Survey.RESULT_COUNT] ?? 0,
        evaluation: Map.from(
          data[EVALUATION] ?? {},
        ),
        isSingleChoice: isSingleChoice);
  }

  @override
  Widget buildWidget(BuildContext context, {bool highlighted = false}) {
    if (!rollout! ||
        (onlyAdmin! && !(context.read<UserManager>().user?.admin ?? false)))
      return SizedBox.shrink();

    return _SurveyWrapper<CheckBoxSurvey>(
      _ChoiceWidget(),
      survey: this,
    );
  }

  static const String ANSWERS = "answers", EVALUATION = "evaluation";
}

abstract class SurveyResult<T> {
  T get answers;
  set answers(T a);

  void addAnswer(T answer);
  Map<String, dynamic> toMap(Survey survey);

  static const String RESULT = "result";
}

class SingleAnswerSurveyResult<T> extends SurveyResult<T?> {
  @override
  T? answers;

  @override
  void addAnswer(T? answer) {
    answers = answer;
  }

  @override
  Map<String, dynamic> toMap(Survey<SurveyResult> survey) {
    return {
      Survey.QUESTION: survey.question,
      Survey.SURVEY_TYPE: survey.surveyType,
      SurveyResult.RESULT: answers
    };
  }
}

class CheckBoxSurveyResult extends SurveyResult<Map<String, bool?>?> {
  Map<String, bool?>? _answers;
  final bool isSingleChoice;

  CheckBoxSurveyResult([this.isSingleChoice = false]);

  @override
  Map<String, dynamic> toMap(Survey<SurveyResult> survey) {
    return {
      Survey.QUESTION: survey.question,
      Survey.SURVEY_TYPE: survey.surveyType,
      SurveyResult.RESULT: answers
    };
  }

  @override
  void addAnswer(Map<String, bool?>? answer) {
    if (isSingleChoice) {
      _answers!.updateAll((key, value) => false);
    }
    _answers!.addAll(answer!);
  }

  @override
  Map<String, bool?>? get answers => _answers;

  @override
  set answers(Map<String, bool?>? a) {
    _answers = a;
  }
}

class _SurveyWrapper<T extends Survey> extends StatefulWidget {
  final Widget child;
  final T survey;
  const _SurveyWrapper(this.child, {required this.survey});

  @override
  __SurveyWrapperState<T> createState() => __SurveyWrapperState<T>();
}

class __SurveyWrapperState<T extends Survey> extends State<_SurveyWrapper<T>>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    UserManager um = context.read<UserManager>();
    if (!widget.survey.rollout! ||
        (widget.survey.onlyAdmin! && !(um.user?.admin ?? false)) ||
        (widget.survey.question?.isEmpty ?? true)) return SizedBox.shrink();

    ThemeManager _theme = ThemeManager.of(context);
    return Provider<T>(
      create: (context) => widget.survey,
      builder: (context, child) => FutureBuilder<bool>(
          initialData: true,
          future: DatabaseService.hasContributedToSurvey(
              sid: widget.survey.id, uid: um.uid),
          builder: (context, snapshot) {
            return snapshot.data!
                ? SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 6),
                    child: Material(
                      color: _theme.colors.contrast,
                      borderRadius: BorderRadius.circular(Constants.radius),
                      clipBehavior: Clip.antiAlias,
                      child: Theme(
                        data: ThemeData(
                            unselectedWidgetColor:
                                _theme.colors.textOnContrast.withOpacity(.8),
                            colorScheme: ColorScheme.fromSwatch().copyWith(
                                secondary: _theme.colors!.textOnContrast)),
                        child: ExpansionTile(
                          initiallyExpanded: true,
                          maintainState: true,
                          title: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                            child: Text(
                              widget.survey.question ?? "",
                              style: _theme.textTheme.textOnContrast.headline6
                                  .copyWith(fontSize: 16),
                            ),
                          ),
                          children: [this.widget.child],
                        ),
                      ),
                    ),
                  );
          }),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class _YesNoSurveyWidget extends StatefulWidget {
  @override
  __YesNoSurveyWidgetState createState() => __YesNoSurveyWidgetState();
}

class __YesNoSurveyWidgetState extends State<_YesNoSurveyWidget>
    with SingleTickerProviderStateMixin {
  bool _done = false;

  @override
  Widget build(BuildContext context) {
    ThemeManager _theme = ThemeManager.of(context);
    SingleAnswerSurvey<bool?> survey =
        context.read<SingleAnswerSurvey<bool?>>();
    return AnimatedSize(
      vsync: this,
      duration: Duration(milliseconds: 250),
      curve: Curves.fastLinearToSlowEaseIn,
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: 250),
        switchOutCurve: Curves.easeOut,
        switchInCurve: Curves.easeIn,
        child: _done
            ? Column(
                children: [
                  ListTile(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "JA (${survey.evaluation!["true"] ?? 0}/${survey.resultCount})",
                          style: _theme.textTheme.textOnContrast.bodyText1,
                        ),
                        YMargin(6),
                        _progressWidget(
                            theme: _theme, survey: survey, eval: "true"),
                      ],
                    ),
                  ),
                  ListTile(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "NEIN (${survey.evaluation!["false"] ?? 0}/${survey.resultCount})",
                          style: _theme.textTheme.textOnContrast.bodyText1,
                        ),
                        YMargin(6),
                        _progressWidget(
                            theme: _theme, survey: survey, eval: "false"),
                      ],
                    ),
                  ),
                ],
              )
            : Column(
                children: [
                  YMargin(24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          FloatingActionButton(
                            key: ValueKey("yes"),
                            heroTag: "yes",
                            onPressed: () => _clickedValue(
                                context: context, value: true, survey: survey),
                            child: Icon(
                              Icons.done,
                              color: _theme.colors.textOnContrast,
                            ),
                            backgroundColor: _theme.colors.contrast,
                          ),
                          YMargin(12),
                          Text(
                            "JA",
                            style: _theme.textTheme.textOnContrast.bodyText1,
                          )
                        ],
                      ),
                      XMargin(24),
                      Column(
                        children: [
                          FloatingActionButton(
                            key: ValueKey("no"),
                            heroTag: "no",
                            onPressed: () => _clickedValue(
                                context: context, value: false, survey: survey),
                            child: Icon(Icons.close,
                                color: _theme.colors.textOnDark),
                            backgroundColor: _theme.colors.dark,
                          ),
                          YMargin(12),
                          Text(
                            "NEIN",
                            style: _theme.textTheme.textOnContrast.bodyText1,
                          )
                        ],
                      ),
                    ],
                  ),
                  YMargin(24),
                ],
              ),
      ),
    );
  }

  Widget _progressWidget(
      {ThemeManager? theme, SingleAnswerSurvey<bool?>? survey, String? eval}) {
    return Material(
      borderRadius: BorderRadius.circular(10),
      clipBehavior: Clip.antiAlias,
      color: Colors.transparent,
      child: LayoutBuilder(builder: (context, constraints) {
        double value = survey!.resultCount! > 0
            ? ((survey.evaluation![eval!] ?? 0) / survey.resultCount!)
            : 0;
        return LinearProgressIndicator(
            value: value,
            backgroundColor: theme!.colors.textOnContrast.withOpacity(.1),
            valueColor: AlwaysStoppedAnimation(theme.colors.textOnContrast));
      }),
    );
  }

  void _clickedValue(
      {required BuildContext context,
      bool? value,
      required SingleAnswerSurvey<bool?> survey}) {
    survey.result!.addAnswer(value);
    survey.sendResult(context);
    setState(() {
      _done = true;
    });
  }
}

class _TextSurveyWidget extends StatefulWidget {
  @override
  __TextSurveyWidgetState createState() => __TextSurveyWidgetState();
}

class __TextSurveyWidgetState extends State<_TextSurveyWidget>
    with SingleTickerProviderStateMixin {
  bool _done = false;

  @override
  Widget build(BuildContext context) {
    ThemeManager _theme = ThemeManager.of(context);
    SingleAnswerSurvey<String> survey =
        context.read<SingleAnswerSurvey<String>>();

    return AnimatedSize(
      vsync: this,
      duration: Duration(milliseconds: 250),
      curve: Curves.fastLinearToSlowEaseIn,
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: 250),
        switchOutCurve: Curves.easeOut,
        switchInCurve: Curves.easeIn,
        child: _done
            ? Column(
                children: [
                  YMargin(12),
                  Material(
                    shape: CircleBorder(),
                    color: _theme.colors.dark,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Icon(Icons.done, color: _theme.colors.textOnDark),
                    ),
                  ),
                  YMargin(12),
                  Text(
                    "Vielen Dank für deine Teilnahme!",
                    style: _theme.textTheme.textOnContrast.bodyText1,
                  ),
                  YMargin(24),
                ],
              )
            : Column(
                children: [
                  YMargin(6),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: CustomTextField(
                      hint: "Deine Antwort",
                      label: "Deine Antwort",
                      activeColor:
                          _theme.colors.textOnContrast.withOpacity(.75),
                      focusedColor: _theme.colors.textOnContrast,
                      textColor: _theme.colors.textOnContrast,
                      maxLines: 3,
                      onChanged: (text) {
                        survey.result!.addAnswer(text);
                        setState(() {});
                      },
                    ),
                  ),
                  YMargin(6),
                  _SurveyBottomContent<SingleAnswerSurvey<String>>(
                    active: survey.result!.answers?.isNotEmpty ?? false,
                    onSubmitted: () {
                      setState(() {
                        _done = true;
                      });
                    },
                  ),
                  YMargin(6),
                ],
              ),
      ),
    );
  }
}

class _ChoiceWidget extends StatefulWidget {
  @override
  __ChoiceWidgetState createState() => __ChoiceWidgetState();
}

class __ChoiceWidgetState extends State<_ChoiceWidget>
    with SingleTickerProviderStateMixin {
  bool _done = false;

  @override
  Widget build(BuildContext context) {
    ThemeManager _theme = ThemeManager.of(context);
    return Consumer<CheckBoxSurvey>(
      builder: (context, survey, child) {
        if (survey.result!.answers == null) {
          survey.result!.answers = {
            for (String ans in survey.answers!) ans: false
          };
        }

        Duration duration = Duration(milliseconds: 250);

        return AnimatedSize(
          vsync: this,
          duration: duration,
          curve: Curves.fastLinearToSlowEaseIn,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (String answer in survey.result!.answers!.keys)
                AnimatedSwitcher(
                  duration: duration,
                  switchOutCurve: Curves.easeOut,
                  switchInCurve: Curves.easeIn,
                  child: _done
                      ? ListTile(
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "$answer (${survey.evaluation![answer] ?? 0}/${survey.resultCount})",
                                style:
                                    _theme.textTheme.textOnContrast.bodyText1,
                              ),
                              YMargin(6),
                              Material(
                                borderRadius: BorderRadius.circular(10),
                                clipBehavior: Clip.antiAlias,
                                color: Colors.transparent,
                                child: LayoutBuilder(
                                    builder: (context, constraints) {
                                  double value = survey.resultCount! > 0
                                      ? ((survey.evaluation![answer] ?? 0) /
                                          survey.resultCount!)
                                      : 0;
                                  return LinearProgressIndicator(
                                      value: value,
                                      backgroundColor: _theme
                                          .colors.textOnContrast
                                          .withOpacity(.1),
                                      valueColor: AlwaysStoppedAnimation(
                                          _theme.colors.textOnContrast));
                                }),
                              ),
                            ],
                          ),
                        )
                      : CheckboxListTile(
                          value: survey.result!.answers![answer],
                          checkColor: _theme.colors.textOnDark,
                          activeColor: _theme.colors.textOnContrast,
                          onChanged: (val) {
                            print(val);
                            survey.result!.addAnswer({answer: val});
                            setState(() {});
                          },
                          title: Text(
                            answer,
                            style: _theme.textTheme.textOnContrast.bodyText2,
                          ),
                        ),
                ),
              _done
                  ? SizedBox.shrink()
                  : Padding(
                      padding: const EdgeInsets.fromLTRB(16.0, 8, 16, 0),
                      child: Text(
                        survey.isSingleChoice
                            ? "Wähle eine Antwort aus."
                            : "Wähle eine oder mehrere Antworten aus.",
                        style: _theme.textTheme.textOnContrast.caption,
                      ),
                    ),
              YMargin(_done ? 0 : 6),
              _done
                  ? SizedBox.shrink()
                  : _SurveyBottomContent<CheckBoxSurvey>(
                      onSubmitted: () {
                        setState(() {
                          _done = true;
                        });
                      },
                    ),
              YMargin(_done ? 6 : 8),
            ],
          ),
        );
      },
    );
  }
}

class _SurveyBottomContent<T extends Survey> extends StatelessWidget {
  final void Function()? onSubmitted;
  final bool active;

  const _SurveyBottomContent({Key? key, this.onSubmitted, this.active = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeManager _theme = ThemeManager.of(context);
    Survey _survey = context.read<T>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  primary: _theme.colors.textOnContrast),
              onPressed: active ? () => _submitResult(context, _survey) : null,
              icon: Icon(
                Icons.send,
                size: 12,
              ),
              label: Text("Abschicken")),
          Text(timeago.format(_survey.createdAt!, locale: "de"),
              style: _theme.textTheme.textOnContrast.caption),
        ],
      ),
    );
  }

  Future<void> _submitResult(BuildContext context, Survey survey) async {
    await DatabaseService.sendSurveyResults(survey,
        uid: context.read<UserManager>().uid);
    onSubmitted!();
  }
}

class _FollowNotificationWidget extends StatelessWidget {
  final FollowNotification notification;
  final bool highlighted;

  _FollowNotificationWidget(this.notification, this.highlighted);

  late ThemeManager _theme;

  @override
  Widget build(BuildContext context) {
    _theme = ThemeManager.of(context);
    return FutureBuilder<User>(
        future: DatabaseService.getUser(notification.id),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return _buildLoadingTile();

          User? user = snapshot.data;
          return ListTile(
            tileColor: highlighted ? _theme.colors.contrast : null,
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => UserPage(user!)));
            },
            leading: RoundedAvatar(
              user?.thumbnailUrl ?? user?.imgUrl,
              blurHash: user?.blurHash,
            ),
            title: StyledText(
              text: "<bold>${user?.name}</bold> folgt dir jetzt!",
              style: (highlighted
                      ? _theme.textTheme.textOnContrast
                      : _theme.textTheme.dark)
                  .bodyText2,
              overflow: TextOverflow.ellipsis,
              styles: {"bold": TextStyle(fontWeight: FontWeight.bold)},
            ),
            subtitle: Text(
              timeago.format(notification.createdAt!, locale: "de"),
            ),
            trailing: UserFollowButton(
              followerId: user?.id,
            ),
          );
        });
  }

  Widget _buildLoadingTile() => ListTile(
        tileColor: highlighted ? _theme.colors.contrast : null,
        leading: RoundedAvatar(
          null,
          loading: true,
        ),
        title: Text(
          "Lade Nutzer...",
          style: _theme.textTheme.dark.bodyText2,
        ),
      );
}
