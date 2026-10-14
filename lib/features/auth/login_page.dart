import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_routes.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/app_top_bar.dart';
import 'widgets/auth_form_widgets.dart';

/// Layar masuk dengan No. HP atau Gmail (`screen-login`).
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _identifier = TextEditingController();

  @override
  void dispose() {
    _identifier.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    // TODO(backend): kirim kode verifikasi ke No. HP / Gmail.
    context.push(AppRoutes.otp);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AppTopBar(fallbackRoute: AppRoutes.authgate),
              Padding(
                padding: const EdgeInsets.fromLTRB(AppDimens.gutter, 24, AppDimens.gutter, 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const AuthFormHead(
                        eyebrow: 'Masuk Akun',
                        title: 'Halo, wisatawan!',
                        description: 'Masukkan No. HP atau Gmail yang kamu daftarkan sebelumnya.',
                      ),
                      AppTextField(
                        label: 'No. HP atau Gmail',
                        hint: '08xxxxxxxxxx / nama@gmail.com',
                        controller: _identifier,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.username],
                        validator: (value) => (value == null || value.trim().isEmpty)
                            ? 'Isi No. HP atau Gmail terlebih dahulu.'
                            : null,
                        onFieldSubmitted: (_) => _submit(),
                      ),
                      AppButton(
                        label: 'Kirim Kode Verifikasi',
                        verticalPadding: 14,
                        onPressed: _submit,
                      ),
                      AuthSwitchLink(
                        prefix: 'Belum punya akun? ',
                        linkText: 'Daftar di sini',
                        onTap: () => context.pushReplacement(AppRoutes.register),
                      ),
                    ],
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
