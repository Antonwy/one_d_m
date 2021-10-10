import 'package:one_d_m/helper/helper.dart';
import 'package:one_d_m/models/user.dart';

typedef Json = Map<String, dynamic>;

class Contacts {
  final List<User> topUsers, usersFromContacts;

  Contacts({required this.topUsers, required this.usersFromContacts});

  Contacts.fromJson(Json json)
      : topUsers = User.listFromJson(Helper.castJson(json['top_users'])),
        usersFromContacts =
            User.listFromJson(Helper.castJson(json['users_from_contacts']));
}
