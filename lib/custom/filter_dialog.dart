import 'package:cook_mate/resources/strings.dart';
import 'package:flutter/material.dart';

class FilterDialog extends StatelessWidget {
  final List<String> entries;
  final ValueChanged<String> onSelection;

  const FilterDialog({super.key, required this.entries, required this.onSelection});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(AppStrings.titleDialogFilter),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: entries.length,
          itemBuilder: (context, index) {
            final entry = entries[index];
            return ListTile(
              title: Text(entry),
              onTap: () {
                onSelection(entry);
                Navigator.of(context).pop(); // Close the dialog
              },
            );
          },
        ),
      ),
    );
  }
}