import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';

class QuillEditorComponent extends StatelessWidget {
  const QuillEditorComponent({
    super.key,
    required this.controller,
  });

  final QuillController controller;

  @override
  Widget build(BuildContext context) {
    return QuillProvider(
      configurations: QuillConfigurations(
        controller: controller,
        sharedConfigurations: const QuillSharedConfigurations(
          locale: Locale("en", "US"),
        ),
      ),
      child: Column(
        children: [
          QuillToolbar(
            configurations: QuillToolbarConfigurations(
                // embedButtons: FlutterQuillEmbeds.toolbarButtons(
                //   videoButtonOptions: null,
                //   imageButtonOptions: QuillToolbarImageButtonOptions(
                //     // linkRegExp: RegExp(
                //     //     r"^https?:\/\/(?:www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b(?:[-a-zA-Z0-9()@:%_\+.~#?&\/=]*)$"),
                //     imageButtonConfigurations: QuillToolbarImageConfigurations(
                //         onImageInsertCallback: (imageUrl, controller) async {
                //       var actualUrl = imageUrl;
                //       print(actualUrl.substring(0, 50));
                //       if (imageUrl.startsWith("blob://")) {
                //         http.Response response =
                //             await http.get(Uri.parse(imageUrl));
                //         final bytes = response.bodyBytes;
                //         actualUrl =
                //             "data:image/png;base64,${base64Encode(bytes)}";
                //       }

                //       controller.skipRequestKeyboard = true;
                //       controller.insertImageBlock(imageSource: actualUrl);
                //     }),
                //   ),
                // ),
                ),
          ),
          Expanded(
            child: QuillEditor.basic(
              configurations: QuillEditorConfigurations(
                readOnly: false,
                embedBuilders: kIsWeb
                    ? FlutterQuillEmbeds.editorWebBuilders()
                    : FlutterQuillEmbeds.editorBuilders(),
              ),
            ),
          )
        ],
      ),
    );
  }
}
