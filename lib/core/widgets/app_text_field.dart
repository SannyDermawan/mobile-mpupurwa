import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_text_styles.dart';

/// Input dengan label di atasnya (`.form-group` + `.form-label` +
/// `.form-input`). Pakai `maxLines: 3` untuk varian textarea (`.form-textarea`,
/// tinggi sekitar 70).
///
/// Dipakai di dalam `Form`; kalau [validator] diisi, pesan error muncul
/// di bawah input.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.autofillHints,
    this.inputFormatters,
    this.maxLines = 1,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.bottomSpacing = 16,
  });

  final String label;
  final String? hint;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final Iterable<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;

  /// 1 untuk input satu baris, 3 untuk textarea.
  final int maxLines;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;

  /// Jarak di bawah field (`margin-bottom: 16px` pada `.form-group`).
  final double bottomSpacing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: bottomSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.formLabel),
          const SizedBox(height: 7),
          TextFormField(
            controller: controller,
            keyboardType: maxLines > 1 ? TextInputType.multiline : keyboardType,
            textInputAction: textInputAction,
            textCapitalization: textCapitalization,
            autofillHints: autofillHints,
            inputFormatters: inputFormatters,
            minLines: maxLines,
            maxLines: maxLines,
            style: AppTextStyles.formInput,
            validator: validator,
            // Pesan error ikut hilang begitu pengguna memperbaiki isinya.
            autovalidateMode: AutovalidateMode.onUserInteraction,
            onChanged: onChanged,
            onFieldSubmitted: onFieldSubmitted,
            decoration: InputDecoration(hintText: hint),
          ),
        ],
      ),
    );
  }
}

/// Dua field berdampingan (`.form-row2`, jarak 12), mis. No. HP dan Gmail.
class AppTextFieldRow extends StatelessWidget {
  const AppTextFieldRow({super.key, required this.left, required this.right});

  final Widget left;
  final Widget right;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: left),
        const SizedBox(width: 12),
        Expanded(child: right),
      ],
    );
  }
}
