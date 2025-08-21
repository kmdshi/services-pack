import 'package:flutter/material.dart';

class FormatSelector extends StatelessWidget {
  final List<String> formats;
  final String fromSelect;
  final String toSelect;
  final void Function(String from, String to)? onChange;

  const FormatSelector({
    super.key,
    required this.formats,
    required this.fromSelect,
    required this.toSelect,
    this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        DropdownButton<String>(
          value: fromSelect,
          items: formats
              .map((f) => DropdownMenuItem(value: f, child: Text(f)))
              .toList(),
          onChanged: (value) {
            if (value != null) onChange?.call(value, toSelect);
          },
        ),
        IconButton(
          icon: const Icon(Icons.swap_horiz, size: 32),
          onPressed: () => onChange?.call(toSelect, fromSelect),
        ),
        DropdownButton<String>(
          value: toSelect,
          items: formats
              .map((f) => DropdownMenuItem(value: f, child: Text(f)))
              .toList(),
          onChanged: (value) {
            if (value != null) onChange?.call(fromSelect, value);
          },
        ),
      ],
    );
  }
}
