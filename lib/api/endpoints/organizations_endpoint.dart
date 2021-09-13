import 'package:one_d_m/api/endpoints/api_endpoint.dart';
import 'package:one_d_m/models/organization.dart';

class OrganizationsEndpoint extends ApiEndpoint<Organization> {
  OrganizationsEndpoint([String route = "organizations"])
      : super(route,
            formatter: (v) => Organization.fromJson(v),
            listFormatter: (l) => Organization.listFromJson(l));
}
