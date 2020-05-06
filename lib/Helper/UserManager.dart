import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:one_d_m/Helper/API/ApiError.dart';
import 'package:one_d_m/Helper/API/ApiResult.dart';
import 'package:one_d_m/Helper/API/ApiSuccess.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/ImageUrl.dart';
import 'StorageService.dart';
import 'User.dart';

enum Status {
  Uninitialized,
  Authenticated,
  Authenticating,
  Unauthenticated,
  Unverified,
  NEEDSMOREINFORMATION
}

class UserManager extends ChangeNotifier {
  User _user;
  FirebaseAuth _auth;
  FirebaseUser _fireUser;
  Status _status = Status.Uninitialized;

  Status get status => _status;
  set status(Status status) {
    _status = status;
    notifyListeners();
  }

  User get user => _user;

  String get uid => _fireUser.uid;
  FirebaseUser get fireUser => _fireUser;
  set fireUser(FirebaseUser firebaseUser) => _fireUser = firebaseUser;
  FirebaseAuth get auth => _auth;

  UserManager.instance() : _auth = FirebaseAuth.instance {
    _auth.onAuthStateChanged.listen(_onAuthStateChanged);
  }

  void initListener(DocumentSnapshot qs) {
    _user = User.fromSnapshot(qs);
    notifyListeners();
  }

  Future<User> getUser() async {
    if (user != null) return _user;
    return DatabaseService.getUser((await _auth.currentUser()).uid);
  }

  Future<ApiResult<FirebaseUser>> signIn(String email, String password) async {
    try {
      _status = Status.Authenticating;
      notifyListeners();
      AuthResult res = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      _status = Status.Authenticated;
      notifyListeners();
      return ApiSuccess(data: res.user);
    } on PlatformException catch (e) {
      _status = Status.Unauthenticated;
      return ApiError(e.message);
    }
  }

  Future<ApiResult<FirebaseUser>> signUpAuth(
      {String email, String password}) async {
    try {
      _status = Status.Authenticating;
      notifyListeners();
      AuthResult res = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      _fireUser = res.user;

      return ApiSuccess(data: res.user);
    } on PlatformException catch (e) {
      _status = Status.Unauthenticated;
      return ApiError(e.message);
    }
  }

  Future<ApiResult<User>> uploadAdditionalInformations(
      User user, File image) async {
    try {
      _status = Status.Authenticating;
      notifyListeners();

      if (image != null) {
        StorageService service = StorageService(file: image);
        user.imgUrl = await service
            .uploadImage(StorageService.userImageName(fireUser.uid));
      }

      user.id = fireUser.uid;
      await DatabaseService.addUser(user);
      _user = user;
      _status = Status.Authenticated;
      notifyListeners();
      return ApiSuccess(data: user);
    } on PlatformException catch (e) {
      _status = Status.Unauthenticated;
      return ApiError(e.message);
    }
  }

  Future<ApiResult> sendEmailVerification() async {
    try {
      await _fireUser.sendEmailVerification();
      return ApiSuccess(data: null, message: "Success");
    } on PlatformException catch (e) {
      return ApiError(e.message);
    }
  }

  Future<ApiResult<FirebaseUser>> signUp(User user, File image) async {
    try {
      _status = Status.Authenticating;
      notifyListeners();
      AuthResult res = await _auth.createUserWithEmailAndPassword(
          email: user.email, password: user.password);

      if (image != null) {
        StorageService service = StorageService(file: image);
        user.imgUrl = await service
            .uploadImage(StorageService.userImageName(res.user.uid));
      }

      user.id = res.user.uid;
      await DatabaseService.addUser(user);
      _user = user;
      _status = Status.Authenticated;
      notifyListeners();
      return ApiSuccess(data: res.user);
    } on PlatformException catch (e) {
      _status = Status.Unauthenticated;
      return ApiError(e.message);
    }
  }

  Future<void> updateUser() async {
    await DatabaseService.updateUser(user);
  }

  Future<void> logout() async {
    await _auth.signOut();
    _status = Status.Unauthenticated;
    notifyListeners();
  }

  Future<void> _onAuthStateChanged(FirebaseUser firebaseUser) async {
    if (firebaseUser == null) {
      _status = Status.Unauthenticated;
    } else {
      if (!firebaseUser.isEmailVerified)
        _status = Status.Unverified;
      else {
        DocumentSnapshot userDoc = await Firestore.instance
            .collection('user')
            .document(firebaseUser.uid)
            .get(source: Source.serverAndCache);
        if (!userDoc.exists) {
          _status = Status.NEEDSMOREINFORMATION;
        } else {
          Firestore.instance
              .collection("user")
              .document(firebaseUser.uid)
              .snapshots()
              .listen(initListener);
          _status = Status.Authenticated;
        }
      }
      _fireUser = firebaseUser;
    }
    notifyListeners();
  }
}
