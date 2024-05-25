
import 'package:flutter/material.dart';
import 'package:flutter_markdown_selectionarea/flutter_markdown_selectionarea.dart';
import 'package:oes/config/AppTheme.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:oes/ui/assets/dialogs/Toast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AppMarkdown extends StatelessWidget {
  const AppMarkdown({
    required this.data,
    this.flipBlocksColors = true,
    this.textAlign = WrapAlignment.start,
    this.testSize = 14,
    super.key
  });

  final String data;
  final bool flipBlocksColors;
  final WrapAlignment textAlign;
  final double testSize;

  @override
  Widget build(BuildContext context) {
    return SelectionArea(
      child: Markdown(
        data: data,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        onTapLink: (text, href, title) async {
          Uri uri = Uri.parse(href.toString());
          Toast.makeToast(text: "Opening url in Browser", icon: Icons.info);
          if (await canLaunchUrl(uri) ) {
            await launchUrl(
              uri,
              mode: kIsWeb ? LaunchMode.platformDefault : LaunchMode.externalApplication,
            );
          } else {
            Toast.makeErrorToast(text: 'Could not launch $uri', duration: ToastDuration.large);
          }
        },
        builders: {
          'code': _CodeElementBuilder(),
        },
        styleSheet: MarkdownStyleSheet(
          h1: TextStyle(
              fontSize: testSize + 12,
              color: Theme.of(context).extension<AppCustomColors>()!.accent,
              fontWeight: FontWeight.bold
          ),
          h2: TextStyle(
              fontSize: testSize + 10,
              color: Theme.of(context).extension<AppCustomColors>()!.accent
          ),
          h3: TextStyle(
              fontSize: testSize + 6,
              color: Theme.of(context).extension<AppCustomColors>()!.accent
          ),
          h4: TextStyle(
              fontSize: testSize + 4,
              color: Theme.of(context).extension<AppCustomColors>()!.accent
          ),
          h5: TextStyle(
              fontSize: testSize + 2,
              color: Theme.of(context).extension<AppCustomColors>()!.accent
          ),
          h6: TextStyle(
              fontSize: testSize + 1,
              color: Theme.of(context).extension<AppCustomColors>()!.accent
          ),
          textAlign: textAlign,
          a: TextStyle(
            fontSize: testSize,
          ),
          p: TextStyle(
            fontSize: testSize
          ),
          listBullet: TextStyle(
            fontSize: testSize
          ),
          tableBody: TextStyle(
            fontSize: testSize
          ),
          horizontalRuleDecoration: BoxDecoration(
            border: Border.symmetric(horizontal: BorderSide(
              color: Colors.grey.shade700,
              width: 2
            ),),
          ),
          blockquote: TextStyle(
            fontSize: testSize,
            color: Colors.red
          ),
          blockquoteDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: flipBlocksColors ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.secondary,
          ),
          code: TextStyle(
              fontSize: testSize,
              color: Theme.of(context).textTheme.bodyMedium!.color
          ),
          codeblockPadding: const EdgeInsets.all(8),
          codeblockDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: flipBlocksColors ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.secondary,
          ),
        ),
        extensionSet: md.ExtensionSet(
          md.ExtensionSet.gitHubFlavored.blockSyntaxes,
          <md.InlineSyntax>[
            md.EmojiSyntax(),
            ...md.ExtensionSet.gitHubFlavored.inlineSyntaxes
          ],
        ),
      ),
    );
  }
}


class _CodeElementBuilder extends MarkdownElementBuilder {

  bool isCodeBlock(md.Element element) {
    if (element.attributes['class'] != null) {
      return true;
    } else if (element.textContent.contains("\n")) {
      return true;
    }
    return false;
  }

  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    if (!isCodeBlock(element)) {
      return Container(
        padding: const EdgeInsets.all(2),
        child: Text(
          element.textContent.trim(),
          style: TextStyle(
            fontSize: preferredStyle!.fontSize,
            fontStyle: FontStyle.italic,
            color: preferredStyle.color
          ),
        ),
      );
    } else {
      return Container(
        margin: const EdgeInsets.all(10),
        child: Text(
          element.textContent.trim(),
          style: TextStyle(
            fontSize: preferredStyle!.fontSize,
            color: preferredStyle.color
          ),
        ),
      );
    }
  }
}