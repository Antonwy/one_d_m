import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:one_d_m/Helper/API/ApiError.dart';
import 'package:one_d_m/Helper/API/ApiResult.dart';
import 'package:one_d_m/Helper/API/ApiSuccess.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'StorageService.dart';
import 'User.dart';

enum Status { Uninitialized, Authenticated, Authenticating, Unauthenticated }

class UserManager extends ChangeNotifier {
  User _user;
  FirebaseAuth _auth;
  FirebaseUser _fireUser;
  Status _status = Status.Uninitialized;

  Status get status => _status;
  User get user => _user;

  set user(User user) {
    _user = user;
  }

  String get uid => _fireUser.uid;

  UserManager.instance() : _auth = FirebaseAuth.instance {
    _auth.onAuthStateChanged.listen(_onAuthStateChanged);
  }

  Future<User> getUser() async {
    if (user != null) return _user;
    return DatabaseService((await _auth.currentUser()).uid).getUser();
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

  Future<ApiResult<FirebaseUser>> signUp(User user, File image) async {
    try {
      _status = Status.Authenticating;
      notifyListeners();
      AuthResult res = await _auth.createUserWithEmailAndPassword(
          email: user.email, password: user.password);

      if (image != null) {
        StorageService service = StorageService(file: image, id: res.user.uid);
        await service.compressImage(quality: 20);
        user.imgUrl = await service.uploadImage();
      }

      await DatabaseService(res.user.uid).addUser(user);
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
    await DatabaseService(uid).addUser(user);
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
      _fireUser = firebaseUser;
      _status = Status.Authenticated;
    }
    notifyListeners();
  }
}
