import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/router/app_routes.dart';
import '../../core/state/auth_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_top_bar.dart';
import 'widgets/auth_form_widgets.dart';

/// Layar kode verifikasi 4 digit (`screen-otp`).
class OtpPage extends StatefulWidget {
  const OtpPage({super.key});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  static const int _codeLength = 4;
  static const int _resendSeconds = 28;

  final _codeController = TextEditingController();
  final _focusNode = FocusNode();

  Timer? _timer;
  int _secondsLeft = _resendSeconds;
  String? _error;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
    _codeController.addListener(_onCodeChanged);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _codeController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onCodeChanged() {
    setState(() {
      if (_codeController.text.length == _codeLength) _error = null;
    });
  }

  /// Memulai hitung mundur kirim ulang dari [_resendSeconds]. Pemanggil
  /// bertanggung jawab memanggil `setState` kalau perlu.
  void _startCountdown() {
    _timer?.cancel();
    _secondsLeft = _resendSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() => _secondsLeft--);
      if (_secondsLeft <= 0) timer.cancel();
    });
  }

  void _resend() {
    // TODO(backend): minta kode verifikasi baru ke server.
    _codeController.clear();
    setState(() {
      _error = null;
      _startCountdown();
    });
    _focusNode.requestFocus();
  }

  Future<void> _verify() async {
    if (_submitting) return;
    if (_codeController.text.length < _codeLength) {
      setState(() => _error = 'Masukkan $_codeLength digit kode verifikasi.');
      _focusNode.requestFocus();
      return;
    }
    setState(() => _submitting = true);
    // TODO(backend): mode demo, kode 4 digit apa pun diterima. Ganti dengan
    // verifikasi OTP ke server setelah endpoint untuk aplikasi mobile ada.
    await context.read<AuthController>().login();
    // Router otomatis memindahkan ke Beranda begitu status login berubah.
    if (mounted) {
      setState(() => _submitting = false);
      context.go(AppRoutes.beranda);
    }
  }

  String get _countdownText => '00:${_secondsLeft.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
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
                      length: _codeLength,
                    ),
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.formError,
                        ),
                      ),
                    _ResendHint(
                      secondsLeft: _secondsLeft,
                      countdownText: _countdownText,
                      onResend: _resend,
                    ),
                    AppButton(
                      label: 'Verifikasi & Masuk',
                      verticalPadding: 14,
                      onPressed: _submitting ? null : _verify,
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
