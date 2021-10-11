import 'dart:async';

import 'package:one_d_m/api/api_call.dart';
import 'package:one_d_m/api/endpoints/api_endpoint.dart';
import 'package:one_d_m/models/user.dart';

class UsersEndpoint extends ApiEndpoint<User> with SubscribableEndpoint {
  UsersEndpoint([String route = "users"])
      : super(route,
            formatter: (map) => User.fromJson(map),
            listFormatter: User.listFromJson);

  Future<bool> checkIfUsernameIsAvailable(String username) async {
    final res = await ApiCall<Json>(
            this.addRoute('checkUsername').addRoute(username),
            autoFormat: false,
            useCache: false,
            withAuthHeader: false)
        .getOne();

    return res['available'] ?? false;
  }

  @override
  UsersEndpoint addRoute(String? routeToAdd) {
    String finalRoute = route + '/' + routeToAdd!;
    return UsersEndpoint(finalRoute);
  }
}
