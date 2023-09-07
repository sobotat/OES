
import 'package:flutter/material.dart';
import 'package:oes/src/restApi/api/TestApi.dart';
import 'package:oes/ui/assets/templates/AppAppBar.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});
  
  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {

  List<String> users = [];
  bool loadingUser = false;
  int page = 1;

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    setState(() { loadingUser = true; });
    users = await TestApi.users(page, 2);

    if (users.isNotEmpty) {
      page += 1;
    } else {
      page = 1;
    }

    setState(() { loadingUser = false; });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppAppBar(),
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => loadUser(),
                child: Ink(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.teal[300],
                  ),
                  width: 300,
                  height: 100,
                  child: Align(
                    alignment: Alignment.center,
                    child: !loadingUser ? ListView.builder(
                      itemCount: users.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return Center(child: Text(users[index]));
                      },
                    ) : const CircularProgressIndicator(),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
