import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';

class GoalPageManager extends ChangeNotifier {
  Goal _goal;
  Goal get goal => _goal;
  set goal(Goal val) {
    _goal = val;
    notifyListeners();
  }

  bool error = false;

  Stream<List<Goal>> goalsStream;
  List<Goal> goals = [];

  GoalPageManager() {
    this.goalsStream = DatabaseService.getGoals()
      ..listen(_addGoalListener, onError: _addGoalErrorListener);
  }

  void _addGoalListener(List<Goal> data) {
    print(data);
    error = false;
    goals.clear();
    goals = data;
    if (goal == null) _goal = goals.first;
    if (goals.contains(goal))
      _goal = goals.where((g) => g.name == goal.name).first;
    notifyListeners();
  }

  void _addGoalErrorListener(dynamic err) {
    error = true;
    notifyListeners();
    print(err);
  }
}

class Goal {
  final int currentValue;
  final String id, name, description, unitSmiley, unit;
  final Stream<List<GoalCheckpoint>> checkpoints;

  Goal(
      {this.currentValue,
      this.description,
      this.id,
      this.name,
      this.checkpoints,
      this.unitSmiley,
      this.unit});

  factory Goal.fromDoc(DocumentSnapshot doc) {
    return Goal(
        id: doc.id,
        name: doc.data()[NAME] ?? doc.id,
        unitSmiley: doc.data()[UNIT_SMILEY],
        unit: doc.data()[UNIT] ?? doc.id,
        currentValue: doc.data()[CURRENT_VALUE] ?? 0,
        description: doc.data()[DESCRIPTION],
        checkpoints: DatabaseService.getCheckpointsOfGoal(doc.id));
  }

  static List<Goal> fromQuerySnapshot(QuerySnapshot qs) {
    return qs.docs.map((doc) => Goal.fromDoc(doc)).toList();
  }

  static const String CURRENT_VALUE = "current_value",
      UNIT_SMILEY = "unit_smiley",
      UNIT = "unit",
      NAME = "name",
      DESCRIPTION = "description";

  bool operator ==(Object o) => o is Goal && o.name == this.name;
  int get hashCode => name.hashCode;
}

class GoalCheckpoint {
  final String pending, done;
  final int value;
  TimelinePosition position = TimelinePosition.middle;

  GoalCheckpoint({this.pending, this.done, this.value});

  factory GoalCheckpoint.fromDoc(DocumentSnapshot doc) {
    return GoalCheckpoint(
        pending: doc.data()[PENDING],
        done: doc.data()[DONE],
        value: doc.data()[VALUE] ?? 0);
  }

  static List<GoalCheckpoint> fromQuerySnapshot(QuerySnapshot qs) {
    return qs.docs.map((doc) => GoalCheckpoint.fromDoc(doc)).toList();
  }

  static const String PENDING = "pending", DONE = "done", VALUE = "value";
}

enum TimelinePosition { first, middle, last }
