import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/app_top_bar.dart';
import '../viewmodel/login_view_model.dart';
import 'widgets/auth_form_widgets.dart';

/// Layar masuk dengan No. HP atau Gmail (`screen-login`).
///
/// View hanya menampilkan form dan meneruskan aturan validasi dari
/// [LoginViewModel].
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider<LoginViewModel>(
      create: (_) => const LoginViewModel(),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
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
                        validator: context.read<LoginViewModel>().validateIdentifier,
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
