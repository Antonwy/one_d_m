import 'package:one_d_m/api/api_call.dart';
import 'package:one_d_m/api/endpoints/api_endpoint.dart';
import 'package:one_d_m/api/stream_result.dart';
import 'package:one_d_m/models/user_account.dart';
import 'package:one_d_m/models/user.dart';

class AccountEndpoint extends ApiEndpoint<User> {
  AccountEndpoint([String route = "account"])
      : super(route,
            formatter: (map) => User.fromJson(map),
            listFormatter: User.listFromJson);

  AccountEndpoint useCache(bool val) {
    this.apiUseCache = val;
    return this;
  }

  Future<void> addDvs([int amount = 1]) {
    return ApiCall(this.addRoute('addDv').addRoute(amount.toString())).put();
  }

  Future<UserAccount> getUserAccount(String uid) async {
    final map = await ApiCall<Map<String, dynamic>>(this.addRoute(uid),
            autoFormat: false)
        .getOne();
    return UserAccount.fromJson(map);
  }

  Stream<StreamResult<UserAccount>> getUserAccountStream(String uid) {
    Stream<StreamResult<Map<String, dynamic>>> stream =
        ApiCall<Map<String, dynamic>>(this.addRoute(uid), autoFormat: false)
            .streamGetOne();
    return stream.map((res) => StreamResult(
        fromCache: res.fromCache, data: UserAccount.fromJson(res.data)));
  }

  Future<List<User>> following(String uid) {
    return ApiCall<User>(this.addRoute(uid).addRoute('following')).get();
  }

  Future<List<User>> followed(String uid) {
    return ApiCall<User>(this.addRoute(uid).addRoute('followed')).get();
  }

  Future<User> create(User user) async {
    return await ApiCall<User>(this).post(user.toMap());
  }

  Future<void> saveDeviceToken(String token) {
    return ApiCall(this.addRoute("deviceToken")).put({"device_token": token});
  }

  Future<void> deleteDeviceToken() {
    return ApiCall(this.addRoute('deviceToken')).delete();
  }

  Future<void> update(User user) {
    return ApiCall(this).put(user.toMap());
  }

  Future<void> updateMap(Map<String, dynamic> map) {
    return ApiCall(this).put(map);
  }

  @override
  AccountEndpoint addRoute(String routeToAdd) {
    String finalRoute = route + '/' + routeToAdd;
    return AccountEndpoint(finalRoute);
  }
}
