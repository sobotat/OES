import 'package:download/download.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:oes/src/objects/Device.dart';
import 'package:oes/src/objects/courseItems/Test.dart';
import 'package:oes/src/restApi/interface/courseItems/TestGateway.dart';
import 'package:oes/src/services/DeviceInfo.dart';
import 'package:oes/ui/assets/dialogs/Toast.dart';
import 'package:oes/ui/assets/templates/AppAppBar.dart';
import 'package:oes/ui/assets/templates/WidgetLoading.dart';
import 'package:oes/ui/main/courseItems/test/PDFTest.dart';

class CourseTestPrintScreen extends StatefulWidget {
  const CourseTestPrintScreen({
    required this.courseId,
    required this.testId,
    super.key
  });

  final int courseId;
  final int testId;

  @override
  State<CourseTestPrintScreen> createState() => _CourseTestPrintScreenState();
}

class _CourseTestPrintScreenState extends State<CourseTestPrintScreen> {

  Future<void> prepareAndDownloadPDF(Test test) async {
    String fileName = "${test.name}.pdf";
    Device device = await DeviceInfo.getDevice();
    String? path;
    if (device.isWeb) {
      path = fileName;
    } else {
      path = await FilePicker.platform.getDirectoryPath(dialogTitle: "Download Location");
      if (path == null) {
        return;
      }
      path += "/$fileName";
    }
    debugPrint("Downloading File to $path");

    try {
      List<int> bytes = await exportTestToPDF(test);
      Toast.makeSuccessToast(text: "PDF Generated");

      await download(Stream.fromIterable(bytes), path);

      Toast.makeSuccessToast(text: "PDF Downloaded");
    } catch (e) {
      Toast.makeErrorToast(text: "Failed to Generate PDF");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppAppBar(),
      body: FutureBuilder(
        future: TestGateway.instance.get(widget.testId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: WidgetLoading(),);
          Test test = snapshot.data!;
          prepareAndDownloadPDF(test).then((value) {
            if(mounted) context.pop();
          });

          return const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              WidgetLoading(),
              Text("Preparing PDF", style: TextStyle(fontSize: 30),),
            ],
          );
        },
      ),
    );
  }
}
