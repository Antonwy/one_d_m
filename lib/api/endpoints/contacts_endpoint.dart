import 'package:one_d_m/api/api_call.dart';
import 'package:one_d_m/api/endpoints/api_endpoint.dart';
import 'package:one_d_m/models/contacts.dart';

import '../api.dart';

typedef Json = Map<String, dynamic>;

class ContactsEndpoint extends ApiEndpoint<Contacts> {
  ContactsEndpoint([String route = "contacts"])
      : super(route, formatter: (map) => Contacts.fromJson(map));

  Future<Contacts?> uploadContacts(List<String> contacts) async {
    Json? json = await ApiCall<Json>(this, autoFormat: false).post(contacts);

    if (Api.box != null && json != null) await Api.box!.put("contacts", json);

    print(json);
    return Contacts.fromJson(json!);
  }

  @override
  ContactsEndpoint addRoute(String? routeToAdd) {
    String finalRoute = route + '/' + routeToAdd!;
    return ContactsEndpoint(finalRoute);
  }
}
