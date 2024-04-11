
import 'package:oes/src/objects/Organization.dart';
import 'package:oes/src/restApi/api/ApiOrganizationGateway.dart';

abstract class OrganizationGateway {

  static final OrganizationGateway instance = ApiOrganizationGateway();

  Future<Organization?> get(String name);
  Future<List<Organization>> getAll(String filter);

}