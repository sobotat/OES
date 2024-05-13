
import 'package:oes/src/restApi/api/courseItems/ApiUserQuizShareGateway.dart';
import 'package:oes/src/restApi/interface/ShareGateway.dart';

abstract class UserQuizShareGateway extends ShareGateway {

  static final UserQuizShareGateway instance = ApiUserQuizShareGateway();

}