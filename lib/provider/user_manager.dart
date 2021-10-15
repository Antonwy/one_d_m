import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart' as firebaseAuth;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:google_sign_in/google_sign_in.dart';
import 'package:one_d_m/models/user.dart';
import 'package:one_d_m/api/api.dart';
import 'package:one_d_m/api/api_error.dart';
import 'package:one_d_m/api/api_result.dart';
import 'package:one_d_m/api/api_success.dart';
import 'package:one_d_m/helper/database_service.dart';
import 'package:one_d_m/helper/storage_service.dart';
import 'package:permission_handler/permission_handler.dart';
// import 'package:sign_in_with_apple/sign_in_with_apple.dart';

enum Status {
  Uninitialized,
  NEEDSMOREINFORMATIONS,
  Authenticated,
  Authenticating,
  Unauthenticated,
  Unverified,
}

class UserManager extends ChangeNotifier {
  User? _user;
  firebaseAuth.FirebaseAuth? _auth;
  firebaseAuth.User? _fireUser;
  Status _status = Status.Uninitialized;
  // GoogleSignIn _googleSignIn;
  bool firstSignIn = false;

  Status get status => _status;

  set status(Status status) {
    _status = status;
    notifyListeners();
  }

  User? get user => _user;

  String? get uid => _fireUser?.uid;

  firebaseAuth.User? get fireUser => _fireUser;

  set fireUser(firebaseAuth.User? fUser) {
    _fireUser = fUser;
  }

  firebaseAuth.FirebaseAuth? get auth => _auth;

  UserManager.instance() {
    // _googleSignIn = GoogleSignIn(scopes: [
    //   'profile',
    //   'email',
    // ]);
    _auth = firebaseAuth.FirebaseAuth.instance;
    _auth!.authStateChanges().listen(_onAuthStateChanged);
  }

  Future<User?> getUser() async {
    _user = await Api().getAccount();
    return _user;
  }

  Future<void> reloadUser() async {
    try {
      print("GETTING NEW USER");
      _user = await Api().getAccount();
      print("NEW USERBALANCE: " + _user!.dvBalance.toString());
      notifyListeners();
    } catch (e) {
      print("RELOAD ERROR");
      print(e);
    }
  }

  Future<void> delete() {
    return fireUser!.delete();
  }

//   Future<ApiResult<firebaseAuth.User>> signInWithApple() async {
//     try {
//       final AuthorizationCredentialAppleID appleResult =
//           await SignInWithApple.getAppleIDCredential(
//         scopes: [
//           AppleIDAuthorizationScopes.email,
//           AppleIDAuthorizationScopes.fullName,
//         ],
//       );

//       final firebaseAuth.AuthCredential credential =
//           firebaseAuth.OAuthProvider('apple.com').credential(
//         accessToken: appleResult.authorizationCode,
//         idToken: appleResult.identityToken,
//       );

//       firebaseAuth.UserCredential firebaseResult =
//           await _auth.signInWithCredential(credential);
//       _fireUser = firebaseResult.user;

//       return ApiSuccess(data: _fireUser);
//     } catch (error) {
//       print(error);
//       return ApiError("Etwas ist schief gelaufen!");
//     }
//   }

//   Future<ApiResult<firebaseAuth.User>> signInWithGoogle() async {
// //    await _googleSignIn.signOut();
//     bool isSignedIn = await _googleSignIn.isSignedIn();

//     if (isSignedIn) {
//       _fireUser = _auth.currentUser;
//       return ApiSuccess(data: _fireUser, message: "Bereits eingeloggt");
//     }

//     final GoogleSignInAccount googleUser = await _googleSignIn.signIn();

//     if (googleUser == null) return ApiError("Etwas ist schief gelaufen!");

//     GoogleSignInAuthentication googleAuthentication;

//     try {
//       googleAuthentication = await googleUser.authentication;
//     } on PlatformException catch (exc) {
//       return ApiError(exc.message);
//     }

//     if (googleAuthentication == null)
//       return ApiError("Etwas ist schief gelaufen!");
//     final firebaseAuth.GoogleAuthCredential credential =
//         firebaseAuth.GoogleAuthProvider.credential(
//             idToken: googleAuthentication.idToken,
//             accessToken: googleAuthentication.accessToken);

//     _fireUser = (await _auth.signInWithCredential(credential)).user;
//     return ApiSuccess(data: _fireUser);
//   }

  Future<ApiResult<firebaseAuth.User>> signIn(
      String email, String password) async {
    try {
      status = Status.Authenticating;
      firebaseAuth.UserCredential res = await _auth!
          .signInWithEmailAndPassword(email: email, password: password);

      await reloadUser();
      status = Status.Authenticated;
      return ApiSuccess(data: res.user);
    } on firebaseAuth.FirebaseAuthException catch (e) {
      status = Status.Unauthenticated;
      return ApiError(e.message);
    }
  }

  Future<ApiResult<User>> uploadAdditionalInformations(
      User user, File? image) async {
    try {
      _status = Status.Authenticating;
      notifyListeners();

      if (image != null) {
        StorageService service = StorageService(file: image);
        user.imgUrl = await service
            .uploadImage(StorageService.userImageName(fireUser!.uid));
      }

      user.id = fireUser!.uid;
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
      var actionCodeSettings = firebaseAuth.ActionCodeSettings(
        url:
            'https://one-dollar-movement.firebaseapp.com/?email=${_fireUser!.email}',
        dynamicLinkDomain: 'odm.page.link',
        androidPackageName: 'com.odm.onedollarmovement',
        androidInstallApp: true,
        androidMinimumVersion: '114',
        iOSBundleId: 'com.odm.onedollarmovement',
        handleCodeInApp: true,
      );

      await _fireUser!.sendEmailVerification(actionCodeSettings);
      return ApiSuccess(data: null, message: "Success");
    } on PlatformException catch (e) {
      return ApiError(e.message);
    } on firebaseAuth.FirebaseAuthException catch (e) {
      print(e);
      return ApiError(e.message);
    } catch (e) {
      print(e);
      return ApiError("Email konnte nicht gesendet werden!");
    }
  }

  Future<ApiResult> createSocialUserDocument(
      String username, String? phonenumber) async {
    if (!await DatabaseService.checkUsernameAvailable(username.trim())) {
      return ApiError("Nutzername nicht verfügbar!");
    }

    User user = User(
        phoneNumber: phonenumber,
        name: username.trim(),
        email: fireUser!.email,
        imgUrl: fireUser!.photoURL,
        id: fireUser!.uid);
    try {
      await DatabaseService.addUser(user);
      _user = user;
      return ApiSuccess();
    } catch (e) {
      return ApiError("Etwas ist schief gelaufen! Versuche es später erneut!");
    }
  }

  Future<ApiResult<firebaseAuth.User>> signUp(
      User user, File? image, BuildContext context) async {
    user.name = user.name.trim();
    StorageStreamResult? streamRes;

    try {
      status = Status.Authenticating;

      if (!await Api().users().checkIfUsernameIsAvailable(user.name)) {
        status = Status.Unauthenticated;
        return ApiError(
            "Nutzername gibt es bereits, bitte wähle einen anderen!");
      }

      print(user);
      firebaseAuth.UserCredential res;

      try {
        res = await _auth!.createUserWithEmailAndPassword(
            email: user.email!, password: user.password!);
      } on firebaseAuth.FirebaseAuthException catch (e) {
        status = Status.Unauthenticated;
        return ApiError(e.message);
      } catch (e) {
        print(e);
        return ApiError("Etwas ist schief gelaufen!");
      }

      if (image != null) {
        try {
          StorageService service = StorageService(file: image);
          streamRes = await service.uploadUserImage(
              StorageService.userImageName(res.user!.uid),
              context: context);

          user.imgUrl = streamRes.url;
        } catch (e) {
          print("COULDN'T Upload image!");
        }
      }

      await res.user!.updateDisplayName(user.name);

      await res.user!.updatePhotoURL(user.imgUrl);

      user.id = res.user!.uid;

      if (streamRes != null)
        streamRes.streamController.add("Erstelle Nutzeraccount...");
      await Api().reInit();
      User? userRes = await Api().account().create(user);

      _user = userRes;
      if (streamRes != null) await streamRes.finish();
      return ApiSuccess(data: res.user);
    } on PlatformException catch (e) {
      _status = Status.Unauthenticated;
      if (streamRes != null) await streamRes.finish();
      notifyListeners();
      return ApiError(e.message);
    } catch (e) {
      if (streamRes != null) await streamRes.finish();
      return ApiError("Etwas ist schief gelaufen beim registrieren...");
    }
  }

  Future<void> afterAuthentication() async {
    print("After Authentication");
    final PermissionStatus permission = await Permission.notification.status;

    if (permission == PermissionStatus.granted) {
      bool hasTurnedOn = user!.deviceToken?.isNotEmpty ?? false;
      print("User $uid has notifications turned on: $hasTurnedOn");
      print(hasTurnedOn);
      if (!hasTurnedOn) {
        print("Calling SaveToken:");
        _saveToken();
      }
    }
  }

  Future<void> _saveToken() async {
    try {
      String? token = await FirebaseMessaging.instance.getToken();
      print("Saving device token: $token");
      await Api().account().saveDeviceToken(token);
    } catch (e) {
      print('Something went wrong saving the token: $e');
    }
  }

  Future<ApiResult> updateUser(User updatedUser) async {
    updatedUser.name = updatedUser.name.trim();
    if (updatedUser.name != user!.name.trim() &&
        !await Api().users().checkIfUsernameIsAvailable(updatedUser.name)) {
      return ApiError("Nutzername gibt es bereits, bitte wähle einen anderen!");
    }
    user!.name = updatedUser.name;
    user!.imgUrl = updatedUser.imgUrl;
    user!.thumbnailUrl = updatedUser.thumbnailUrl;
    user!.phoneNumber = updatedUser.phoneNumber;
    try {
      await Api().account().update(user!);
    } catch (e) {
      return ApiError(e.toString());
    }

    return ApiSuccess();
  }

  Future<void> logout() async {
    await Api().account().deleteDeviceToken().catchError((e) => print(e));
    await _auth!.signOut();
    _user = null;
    Api().disconnect();
    // await _googleSignIn.signOut();
    status = Status.Unauthenticated;
  }

  Future<void> _onAuthStateChanged(firebaseAuth.User? firebaseUser) async {
    print(firebaseUser);
    if (firebaseUser == null) {
      status = Status.Unauthenticated;
    } else {
      _fireUser = firebaseUser;
      if (!firebaseUser.emailVerified) {
        status = Status.Unverified;
      } else {
        await Api().reInit();
        _user = await Api().getAccount();
        if (_user?.name == null) {
          status = Status.NEEDSMOREINFORMATIONS;
        } else {
          status = Status.Authenticated;
        }
      }
    }
  }

  Future<void> resetPassword() {
    print(_fireUser!.email);
    return _auth!.sendPasswordResetEmail(email: _fireUser!.email!);
  }
}
