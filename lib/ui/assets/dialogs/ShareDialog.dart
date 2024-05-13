
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:oes/src/AppSecurity.dart';
import 'package:oes/src/objects/SharePermission.dart';
import 'package:oes/src/objects/ShareUser.dart';
import 'package:oes/src/objects/User.dart';
import 'package:oes/src/restApi/interface/CourseGateway.dart';
import 'package:oes/src/restApi/interface/ShareGateway.dart';
import 'package:oes/ui/assets/dialogs/Toast.dart';
import 'package:oes/ui/assets/templates/Button.dart';
import 'package:oes/ui/assets/templates/IconItem.dart';
import 'package:oes/ui/assets/templates/PopupDialog.dart';
import 'package:oes/ui/assets/templates/WidgetLoading.dart';

class ShareDialog extends StatefulWidget {

  const ShareDialog({
    required this.courseId,
    required this.itemId,
    required this.gateway,
    super.key
  });

  final int courseId;
  final int itemId;
  final ShareGateway gateway;

  @override
  State<ShareDialog> createState() => _ShareDialogState();
}

class _ShareDialogState extends State<ShareDialog> {

  Future<void> addUser(String username) async {
    List<User> users = await CourseGateway.instance.getUsers(widget.courseId);
    User? user = users.where((element) => element.username == username).firstOrNull;

    if (user == null) {
      Toast.makeErrorToast(text: "User not found in Course");
      return;
    }

    bool success = false;
    try {
      success = await widget.gateway.add(widget.itemId, ShareUser(
          id: user.id,
          firstName: user.firstName,
          lastName: user.lastName,
          username: user.username,
          permission: SharePermission.viewer
      ));
    } catch (e, stackTrace) {
      debugPrint(e.toString());
      debugPrintStack(stackTrace: stackTrace);
    }

    if (success) {
      Toast.makeSuccessToast(text: "User Added");
      setState(() {});
      return;
    }
    Toast.makeErrorToast(text: "Failed to add User");
    setState(() {});
  }

  Future<bool> updateUser(ShareUser user) async {
    bool success = false;
    try {
      success = await widget.gateway.update(widget.itemId, user);
    } catch (e, stackTrace) {
      debugPrint(e.toString());
      debugPrintStack(stackTrace: stackTrace);
    }

    if (success) {
      Toast.makeSuccessToast(text: "User Updated");
      setState(() {});
      return true;
    }
    Toast.makeErrorToast(text: "Failed to update User");
    setState(() {});
    return false;
  }

  Future<bool> removeUser(int userId) async {
    bool success = false;
    try {
      success = await widget.gateway.remove(widget.itemId, userId);
    } catch (e, stackTrace) {
      debugPrint(e.toString());
      debugPrintStack(stackTrace: stackTrace);
    }

    if (success) {
      Toast.makeSuccessToast(text: "User Removed");
      setState(() {});
      return true;
    }
    Toast.makeErrorToast(text: "Failed to remove User");
    setState(() {});
    return false;
  }

  Future<void> leave() async {
    User user = AppSecurity.instance.user!;

    bool success = await removeUser(user.id);
    if (success) {
      if(mounted) context.pop();
      if(mounted) context.pop();
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: widget.gateway.getPermission(widget.itemId, AppSecurity.instance.user!.id),
      builder: (context, snapshot) {
        bool? isEditor = snapshot.hasData ? snapshot.data! == SharePermission.editor : null;

        return FutureBuilder(
          future: widget.gateway.getAll(widget.itemId),
          builder: (context, snapshot) {
            List<ShareUser>? users = snapshot.data;

            return PopupDialog(
              padding: const EdgeInsets.all(30),
              child: Material(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  constraints: const BoxConstraints(
                    maxWidth: 600,
                    maxHeight: 800
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _Heading(),
                      _SharedList(
                        users: users,
                        enableEdit: isEditor ?? false,
                        onUpdated: (user) => updateUser(user),
                        onRemoved: (user) => removeUser(user.id),
                      ),
                      Builder(
                        builder: (context) {
                          if (isEditor == null) {
                            return Container();
                          }
                          return isEditor ? _Input(
                            addUser: (username) => addUser(username),
                          ) : _LeaveButton(
                            leave: () => leave(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              )
            );
          }
        );
      }
    );
  }
}

class _LeaveButton extends StatelessWidget {
  const _LeaveButton({
    required this.leave,
    super.key
  });

  final Function() leave;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Button(
        icon: Icons.remove,
        text: "Leave",
        backgroundColor: Colors.red.shade700,
        shouldPopOnClick: true,
        maxWidth: double.infinity,
        maxHeight: 55,
        onClick: (context) {
          leave();
        },
      ),
    );
  }
}


class _Input extends StatefulWidget {
  const _Input({
    required this.addUser,
    super.key,
  });
  
  final Function(String username) addUser;

  @override
  State<_Input> createState() => _InputState();
}

class _InputState extends State<_Input> {
  
  TextEditingController controller = TextEditingController();
  
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: Row(
        children: [
          Flexible(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: "Username"
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(5),
            child: Button(
              icon: Icons.add,
              toolTip: "Add",
              maxWidth: 40,
              maxHeight: 60,
              backgroundColor: Colors.green.shade700,
              onClick: (context) {
                widget.addUser(controller.text.trim());
              },
            ),
          )
        ],
      ),
    );
  }
}

class _SharedList extends StatelessWidget {
  const _SharedList({
    required this.users,
    required this.enableEdit,
    required this.onUpdated,
    required this.onRemoved,
    super.key,
  });

  final List<ShareUser>? users;
  final bool enableEdit;
  final Function(ShareUser user) onUpdated;
  final Function(ShareUser user) onRemoved;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Theme.of(context).colorScheme.secondary
        ),
        child: users != null ? ListView.builder(
          itemCount: users!.length,
          itemBuilder: (context, index) {
            ShareUser user = users![index];
            return _SharedUser(
              user: user,
              enableEdit: enableEdit,
              onPermissionChanged: (permission) {
                user.permission = permission;
                onUpdated(user);
              },
              onRemoved: () {
                onRemoved(user);
              },
            );
          },
        ) : const Center(
          child: WidgetLoading(),
        ),
      ),
    );
  }
}

class _SharedUser extends StatelessWidget {
  const _SharedUser({
    required this.user,
    required this.enableEdit,
    required this.onPermissionChanged,
    required this.onRemoved,
    super.key
  });

  final bool enableEdit;
  final ShareUser user;
  final Function(SharePermission permission) onPermissionChanged;
  final Function() onRemoved;

  Widget getEditControls(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var overflow = 500;

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: DropdownMenu<SharePermission>(
            expandedInsets: width < overflow ? EdgeInsets.zero : null,
            initialSelection: user.permission,
            dropdownMenuEntries: SharePermission.values
                .map<DropdownMenuEntry<SharePermission>>(
                    (SharePermission permission) {
              return DropdownMenuEntry<SharePermission>(
                value: permission,
                label: permission.name,
              );
            }).toList(),
            onSelected: (value) {
              onPermissionChanged(value ?? SharePermission.viewer);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(5),
          child: Button(
            icon: Icons.remove,
            toolTip: "Remove",
            maxWidth: 40,
            backgroundColor: Colors.red.shade700,
            onClick: (context) {
              onRemoved();
            },
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var overflow = 500;

    return IconItem(
      icon: Icon(user.permission == SharePermission.editor ? Icons.edit : Icons.remove_red_eye),
      height: enableEdit && width < overflow ? 100 : 55,
      bodyFlex: 1,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Text("${user.firstName} ${user.lastName} (${user.username})"),
            ],
          ),
          enableEdit && width < overflow ? getEditControls(context) : Container()
        ],
      ),
      actions: enableEdit && width >= overflow ? [getEditControls(context)] : [],
    );
  }
}


class _Heading extends StatelessWidget {
  const _Heading({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Shared With', style: TextStyle(fontSize: 40)),
      ],
    );
  }
}
