import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LoadingAlertDialog extends StatelessWidget {
  const LoadingAlertDialog({super.key, this.text});

  final String? text;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 48,
            child: AspectRatio(
              aspectRatio: 1,
              child: CircularProgressIndicator(
                strokeWidth: 4,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(text ?? AppLocalizations.of(context)!.loadingDialogText)
        ],
      ),
    );
  }
}
