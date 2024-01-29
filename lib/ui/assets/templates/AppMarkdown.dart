
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
    this.flipBlocksColors = false,
    super.key
  });

  final String data;
  final bool flipBlocksColors;

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
              fontSize: 24,
              color: Theme.of(context).extension<AppCustomColors>()!.accent,
              fontWeight: FontWeight.bold
          ),
          h2: TextStyle(
              fontSize: 20,
              color: Theme.of(context).extension<AppCustomColors>()!.accent
          ),
          h3: TextStyle(
              fontSize: 18,
              color: Theme.of(context).extension<AppCustomColors>()!.accent
          ),
          h4: TextStyle(
              fontSize: 16,
              color: Theme.of(context).extension<AppCustomColors>()!.accent
          ),
          h5: TextStyle(
              fontSize: 15,
              color: Theme.of(context).extension<AppCustomColors>()!.accent
          ),
          h6: TextStyle(
              fontSize: 14,
              color: Theme.of(context).extension<AppCustomColors>()!.accent
          ),
          horizontalRuleDecoration: BoxDecoration(
            border: Border.symmetric(horizontal: BorderSide(
              color: Colors.grey.shade700,
              width: 2
            ),),
          ),
          blockquote: const TextStyle(
              color: Colors.red
          ),
          blockquoteDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: flipBlocksColors ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.secondary,
          ),
          code: TextStyle(
              fontSize: 14,
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
  void visitElementBefore(md.Element element) {
    // TODO: implement visitElementBefore
    super.visitElementBefore(element);
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