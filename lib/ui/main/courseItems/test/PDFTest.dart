import 'package:flutter/services.dart';
import 'package:oes/src/objects/courseItems/Test.dart';
import 'package:oes/src/objects/questions/OpenQuestion.dart';
import 'package:oes/src/objects/questions/PickManyQuestion.dart';
import 'package:oes/src/objects/questions/PickOneQuestion.dart';
import 'package:oes/src/objects/questions/Question.dart';
import 'package:oes/src/objects/questions/QuestionOption.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';

Future<List<int>> exportTestToPDF(Test test) async {
  List<Widget> widgets = [];
  final fontData = await rootBundle.load("google_fonts/Outfit/Outfit-Regular.ttf");
  final fontDataBold = await rootBundle.load("google_fonts/Outfit/Outfit-Bold.ttf");
  final ttf = Font.ttf(fontData.buffer.asByteData());
  final ttfBold = Font.ttf(fontDataBold.buffer.asByteData());

  Widget header = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Row(
          children: [
            Flexible(
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text("Name: ${test.name}", textAlign: TextAlign.left, style: TextStyle(font: ttfBold)),
                    Text("Duration: ${test.duration}", textAlign: TextAlign.left, style: TextStyle(font: ttfBold)),
                    Text("Max Attempts: ${test.maxAttempts}", textAlign: TextAlign.left, style: TextStyle(font: ttfBold)),
                  ]
              ),
            ),
            Flexible(
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text("Firstname Lastname", textAlign: TextAlign.right, style: TextStyle(font: ttf)),
                      _Divider(
                          top: 25,
                          bottom: 2
                      )
                    ]
                )
            ),
          ]
      ),
      _Divider(),
    ]
  );
  widgets.add(header);

  for (Question question in test.questions) {
    widgets.add(Wrap(children: [
      Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text("${question.name} (${question.type.replaceAll("-", " ")})",
              textAlign: TextAlign.left,
              style: TextStyle(fontWeight: FontWeight.bold, font: ttfBold)),
            Text(
              "Max ${question.points} points",
              textAlign: TextAlign.right,
              style: TextStyle(font: ttf)
            ),
          ]),
          Text(question.description, textAlign: TextAlign.left, style: TextStyle(font: ttf)),
          Builder(
            builder: (context) {
              if (question is OpenQuestion) {
                return _OpenQuestion(question);
              } else if (question is PickOneQuestion ||
                  question is PickManyQuestion) {
                return _PickQuestion(question, ttf);
              }
              return Placeholder(fallbackHeight: 50);
            },
          ),
          _Divider(),
        ])
    ]));
  }

  final doc = Document();
  doc.addPage(MultiPage(
    pageFormat: PdfPageFormat.a4,
    build: (context) {
      return widgets;
    },
  )); // Page

  return List<int>.from(await doc.save());
}

Widget _Divider({
  double top = 15,
  double bottom = 15
}) => Container(
  color: PdfColors.grey,
  height: 2,
  margin: EdgeInsets.only(
    top: top,
    bottom: bottom
  )
);

Widget _OpenQuestion(OpenQuestion question) => Builder(
  builder: (context) {
    return Container(
      margin: const EdgeInsets.only(
        top: 15
      ),
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: PdfColors.black,
          width: 2
        ),
      )
    );
  },
);

Widget _Option(QuestionOption option, Font ttf) => Container(
    margin: const EdgeInsets.all(3),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(5),
      border: Border.all(color: PdfColors.black, width: 2),
    ),
    child: Row(children: [
      Container(
        width: 20,
        height: 20,
        margin: const EdgeInsets.all(5),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: PdfColors.black, width: 1),
        ),
      ),
      Text(option.text, maxLines: 5000, style: TextStyle(font: ttf))
    ]));

Widget _PickQuestion(Question question, Font ttf) => Builder(
  builder: (context) {
    return ListView.builder(
      itemCount: question.options.length,
      itemBuilder: (context, index) {
        QuestionOption option = question.options[index];
        return _Option(option, ttf);
      },
    );
  },
);