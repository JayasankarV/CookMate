import 'package:cook_mate/resources/strings.dart';
import 'package:flutter/material.dart';

class DialogBuilder extends StatelessWidget {

  final String title;
  final String message;
  final VoidCallback positiveAction;
  final VoidCallback negativeAction;

  const DialogBuilder({super.key,
    required this.title,
    required this.message,
    required this.positiveAction,
    required this.negativeAction,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: negativeAction,
          child: Text(AppStrings.actionCancel.toUpperCase()),
        ),
        TextButton(
          onPressed: positiveAction,
          child: Text(AppStrings.actionConfirm.toUpperCase()),
        )
      ],
    );
  }

}