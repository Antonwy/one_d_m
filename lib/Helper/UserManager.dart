import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:one_d_m/Helper/API/ApiError.dart';
import 'package:one_d_m/Helper/API/ApiResult.dart';
import 'package:one_d_m/Helper/API/ApiSuccess.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'StorageService.dart';
import 'User.dart';

enum Status {
  Uninitialized,
  NEEDSMOREINFORMATIONS,
  Authenticated,
  Authenticating,
  Unauthenticated,
  Unverified,
}

class UserManager extends ChangeNotifier {
  User _user;
  FirebaseAuth _auth;
  FirebaseUser _fireUser;
  Status _status = Status.Uninitialized;
  GoogleSignIn _googleSignIn;

  Status get status => _status;
  set status(Status status) {
    _status = status;
    notifyListeners();
  }

  User get user => _user;

  String get uid => _fireUser?.uid;
  FirebaseUser get fireUser => _fireUser;
  set fireUser(FirebaseUser fUser) {
    _fireUser = fUser;
  }

  FirebaseAuth get auth => _auth;

  UserManager.instance() {
    _googleSignIn = GoogleSignIn(scopes: [
      'profile',
      'email',
    ]);
    _auth = FirebaseAuth.instance;
    _auth.onAuthStateChanged.listen(_onAuthStateChanged);
  }

  Future<User> getUser() async {
    if (user != null) return _user;
    return DatabaseService.getUser((await _auth.currentUser()).uid);
  }

  Future<void> delete() {
    return fireUser.delete();
  }

  Future<ApiResult<FirebaseUser>> signInWithGoogle() async {
//    await _googleSignIn.signOut();
    bool isSignedIn = await _googleSignIn.isSignedIn();

    if (isSignedIn) {
      _fireUser = await _auth.currentUser();
      return ApiSuccess(data: _fireUser, message: "Bereits eingeloggt");
    }

    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();

    if (googleUser == null) return ApiError("Etwas ist schief gelaufen!");

    GoogleSignInAuthentication googleAuthentication;

    try {
      googleAuthentication = await googleUser.authentication;
    } on PlatformException catch (exc) {
      return ApiError(exc.message);
    }

    if (googleAuthentication == null)
      return ApiError("Etwas ist schief gelaufen!");
//:A_p6Z&fHR@D
    final AuthCredential credential = GoogleAuthProvider.getCredential(
        idToken: googleAuthentication.idToken,
        accessToken: googleAuthentication.accessToken);

    _fireUser = (await _auth.signInWithCredential(credential)).user;
    return ApiSuccess(data: _fireUser);
  }

  Future<ApiResult<FirebaseUser>> signIn(String email, String password) async {
    try {
      status = Status.Authenticating;
      AuthResult res = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      status = Status.Authenticated;
      return ApiSuccess(data: res.user);
    } on PlatformException catch (e) {
      status = Status.Unauthenticated;
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

  Future<ApiResult> createSocialUserDocument(
      String username, String phonenumber) async {
    User user = User(
        phoneNumber: phonenumber,
        name: username,
        email: fireUser.email,
        imgUrl: fireUser.photoUrl,
        id: fireUser.uid);
    try {
      await DatabaseService.addUser(user);
      _user = user;
      return ApiSuccess();
    } catch (e) {
      return ApiError("Etwas ist schief gelaufen! Versuche es später erneut!");
    }
  }

  Future<ApiResult<FirebaseUser>> signUp(User user, File image) async {
    try {
      status = Status.Authenticating;

      if (!await DatabaseService.checkUsernameAvailable(user.name)) {
        status = Status.Unauthenticated;
        return ApiError(
            "Nutzername gibt es bereits, bitte wähle einen anderen!");
      }

      print(user);

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
      return ApiSuccess(data: res.user);
    } on PlatformException catch (e) {
      _status = Status.Unauthenticated;
      notifyListeners();
      return ApiError(e.message);
    }
  }

  Future<ApiResult> updateUser(User updatedUser) async {
    if (updatedUser.name != user.name &&
        !await DatabaseService.checkUsernameAvailable(updatedUser.name)) {
      return ApiError("Nutzername existiert bereits!");
    }
    user.name = updatedUser.name;
    user.imgUrl = updatedUser.imgUrl;
    user.thumbnailUrl = updatedUser.thumbnailUrl;
    user.phoneNumber = updatedUser.phoneNumber;
    await DatabaseService.updateUser(user);
    return ApiSuccess();
  }

  Future<void> logout() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    status = Status.Unauthenticated;
  }

  Future<void> _onAuthStateChanged(FirebaseUser firebaseUser) async {
    print(firebaseUser);
    if (firebaseUser == null) {
      status = Status.Unauthenticated;
    } else {
      _fireUser = firebaseUser;
      if (!firebaseUser.isEmailVerified) {
        status = Status.Unverified;
      } else {
        _user = await DatabaseService.getUser(firebaseUser.uid);
        if (user?.name == null) {
          status = Status.NEEDSMOREINFORMATIONS;
        } else {
          status = Status.Authenticated;
        }
      }
    }
  }

  Future<void> resetPassword() {
    print(_fireUser.email);
    return _auth.sendPasswordResetEmail(email: _fireUser.email);
  }
}
