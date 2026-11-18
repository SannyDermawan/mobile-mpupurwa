import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_top_bar.dart';
import '../viewmodel/auth_view_model.dart';
import '../viewmodel/otp_view_model.dart';
import 'widgets/auth_form_widgets.dart';

/// Layar kode verifikasi 4 digit (`screen-otp`).
///
/// Hitung mundur, validasi kode, dan proses verifikasi ada di [OtpViewModel].
/// View hanya memegang `TextEditingController` dan `FocusNode`.
class OtpPage extends StatelessWidget {
  const OtpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<OtpViewModel>(
      create: (context) => OtpViewModel(context.read<AuthViewModel>()),
      child: const _OtpView(),
    );
  }
}

class _OtpView extends StatefulWidget {
  const _OtpView();

  @override
  State<_OtpView> createState() => _OtpViewState();
}

class _OtpViewState extends State<_OtpView> {
  final _codeController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _codeController.addListener(_onCodeChanged);
  }

  @override
  void dispose() {
    _codeController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onCodeChanged() => context.read<OtpViewModel>().onCodeChanged(_codeController.text);

  void _resend() {
    context.read<OtpViewModel>().resend();
    _codeController.clear();
    _focusNode.requestFocus();
  }

  Future<void> _verify() async {
    final vm = context.read<OtpViewModel>();
    final ok = await vm.verify(_codeController.text);
    if (!ok) {
      _focusNode.requestFocus();
      return;
    }
    // Router otomatis memindahkan ke Beranda begitu status login berubah.
    if (mounted) context.go(AppRoutes.beranda);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<OtpViewModel>();
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AppTopBar(fallbackRoute: AppRoutes.login),
              Padding(
                padding: const EdgeInsets.fromLTRB(AppDimens.gutter, 20, AppDimens.gutter, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const AuthFormHead(
                      eyebrow: 'Verifikasi',
                      title: 'Masukkan Kode',
                      description: 'Kode verifikasi telah dikirim ke No. HP / Gmail kamu.',
                      centered: true,
                    ),
                    _OtpBoxes(
                      controller: _codeController,
                      focusNode: _focusNode,
                      length: vm.codeLength,
                    ),
                    if (vm.error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          vm.error!,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.formError,
                        ),
                      ),
                    _ResendHint(
                      secondsLeft: vm.secondsLeft,
                      countdownText: vm.countdownText,
                      onResend: _resend,
                    ),
                    AppButton(
                      label: 'Verifikasi & Masuk',
                      verticalPadding: 14,
                      onPressed: vm.submitting ? null : _verify,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Empat kotak kode (`.otp-box`). Di bawahnya ada satu `TextField`
/// transparan seukuran kotak-kotak itu yang menampung ketikan, sehingga
/// fokus otomatis maju, backspace mundur, dan tempel kode (paste) bekerja
/// tanpa mengurus empat `FocusNode`.
class _OtpBoxes extends StatelessWidget {
  const _OtpBoxes({required this.controller, required this.focusNode, required this.length});

  final TextEditingController controller;
  final FocusNode focusNode;
  final int length;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 8),
      child: Center(
        child: SizedBox(
          width: length * 44.0 + (length - 1) * 10,
          height: 52,
          child: Stack(
            children: [
              ListenableBuilder(
                listenable: Listenable.merge([controller, focusNode]),
                builder: (context, _) {
                  final text = controller.text;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      for (var i = 0; i < length; i++)
                        _OtpBox(
                          digit: i < text.length ? text[i] : null,
                          focused: focusNode.hasFocus && i == text.length.clamp(0, length - 1),
                        ),
                    ],
                  );
                },
              ),
              Positioned.fill(
                child: Semantics(
                  label: 'Kode verifikasi $length digit',
                  textField: true,
                  child: Opacity(
                    opacity: 0,
                    alwaysIncludeSemantics: true,
                    child: TextField(
                      controller: controller,
                      focusNode: focusNode,
                      autofocus: true,
                      expands: true,
                      maxLines: null,
                      minLines: null,
                      textAlignVertical: TextAlignVertical.center,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.oneTimeCode],
                      showCursor: false,
                      enableInteractiveSelection: false,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(length),
                      ],
                      decoration: const InputDecoration(
                        filled: false,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OtpBox extends StatelessWidget {
  const _OtpBox({required this.digit, required this.focused});

  final String? digit;
  final bool focused;

  @override
  Widget build(BuildContext context) {
    final filled = digit != null;
    return Container(
      width: 44,
      height: 52,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.offwhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: filled ? AppColors.amber : (focused ? AppColors.stoneMid : AppColors.stoneLine),
          width: 1.5,
        ),
      ),
      child: Text(
        digit ?? '',
        style: AppTextStyles.serif(20, weight: FontWeight.w400, height: 1.2),
      ),
    );
  }
}

/// "Tidak menerima kode? Kirim ulang (00:28)" dengan hitung mundur yang
/// berjalan. Setelah habis, "Kirim ulang" menjadi tombol.
class _ResendHint extends StatelessWidget {
  const _ResendHint({
    required this.secondsLeft,
    required this.countdownText,
    required this.onResend,
  });

  final int secondsLeft;
  final String countdownText;
  final VoidCallback onResend;

  @override
  Widget build(BuildContext context) {
    final base = AppTextStyles.sans(12, color: AppColors.inkSoft);
    final bold = AppTextStyles.sans(12, weight: FontWeight.w700, color: AppColors.stoneDark);

    return Padding(
      padding: EdgeInsets.only(bottom: secondsLeft > 0 ? 26 : 18),
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text('Tidak menerima kode? ', style: base),
          if (secondsLeft > 0)
            Text('Kirim ulang ($countdownText)', style: bold)
          else
            TextButton(
              onPressed: onResend,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                textStyle: AppTextStyles.sans(12, weight: FontWeight.w700),
              ),
              child: const Text('Kirim ulang'),
            ),
        ],
      ),
    );
  }
}
