
import 'package:oes/src/objects/SharePermission.dart';
import 'package:oes/src/objects/ShareUser.dart';

abstract class ShareGateway {
  Future<SharePermission> getPermission(int itemId, int userId);
  Future<List<ShareUser>> getAll(int itemId);

  Future<bool> add(int itemId, ShareUser user);
  Future<bool> remove(int itemId, int userId);
  Future<bool> update(int itemId, ShareUser user);
}