import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/app_top_bar.dart';
import 'widgets/auth_form_widgets.dart';

/// Layar pendaftaran pengunjung (`screen-register`).
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _domicile = TextEditingController();
  final _institution = TextEditingController();
  final _educationLevel = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();

  // Di HTML kotak persetujuan sudah tercentang sejak awal (`checked`).
  bool _agreed = true;
  bool _consentError = false;

  @override
  void dispose() {
    for (final c in [_name, _domicile, _institution, _educationLevel, _phone, _email]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _required(String? value, String fieldName) =>
      (value == null || value.trim().isEmpty) ? '$fieldName wajib diisi.' : null;

  void _submit() {
    final formValid = _formKey.currentState!.validate();
    setState(() => _consentError = !_agreed);
    if (!formValid || !_agreed) return;
    // TODO(backend): kirim data pendaftaran dan minta kode verifikasi.
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
                padding: const EdgeInsets.fromLTRB(AppDimens.gutter, 8, AppDimens.gutter, 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const AuthFormHead(
                        eyebrow: 'Buat Akun',
                        title: 'Daftar sebagai pengunjung',
                        description: 'Isi sekali saja — data ini dipakai untuk pencatatan kunjungan setiap kamu datang.',
                      ),
                      AppTextField(
                        label: 'Nama Lengkap',
                        hint: 'Nama kamu',
                        controller: _name,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.name],
                        validator: (v) => _required(v, 'Nama lengkap'),
                      ),
                      AppTextField(
                        label: 'Domisili',
                        hint: 'mis. Surabaya',
                        controller: _domicile,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        validator: (v) => _required(v, 'Domisili'),
                      ),
                      AppTextField(
                        label: 'Asal Sekolah / Institusi',
                        hint: 'mis. Universitas Brawijaya',
                        controller: _institution,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        validator: (v) => _required(v, 'Asal sekolah / institusi'),
                      ),
                      AppTextField(
                        label: 'Tingkat Pendidikan',
                        hint: 'mis. Mahasiswa',
                        controller: _educationLevel,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        validator: (v) => _required(v, 'Tingkat pendidikan'),
                      ),
                      AppTextFieldRow(
                        left: AppTextField(
                          label: 'No. HP',
                          hint: '08xx-xxxx-xxxx',
                          controller: _phone,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.telephoneNumber],
                          validator: (v) => _required(v, 'No. HP'),
                        ),
                        right: AppTextField(
                          label: 'Gmail',
                          hint: 'nama@gmail.com',
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.done,
                          autofillHints: const [AutofillHints.email],
                          validator: (v) => _required(v, 'Gmail'),
                          onFieldSubmitted: (_) => _submit(),
                        ),
                      ),
                      _ConsentRow(
                        agreed: _agreed,
                        showError: _consentError,
                        onChanged: (value) => setState(() {
                          _agreed = value;
                          if (value) _consentError = false;
                        }),
                      ),
                      AppButton(
                        label: 'Daftar & Verifikasi',
                        verticalPadding: 14,
                        onPressed: _submit,
                      ),
                      AuthSwitchLink(
                        prefix: 'Sudah punya akun? ',
                        linkText: 'Masuk di sini',
                        onTap: () => context.pushReplacement(AppRoutes.login),
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

/// Kotak persetujuan data (`.consent-row`).
class _ConsentRow extends StatelessWidget {
  const _ConsentRow({required this.agreed, required this.showError, required this.onChanged});

  final bool agreed;
  final bool showError;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 6, 0, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => onChanged(!agreed),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: Checkbox(value: agreed, onChanged: (value) => onChanged(value ?? false)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Saya setuju data ini digunakan untuk keperluan pencatatan kunjungan Museum Mpu Purwa, sesuai kebijakan privasi yang berlaku.',
                    style: AppTextStyles.sans(11.5, color: AppColors.inkSoft, height: 1.5),
                  ),
                ),
              ],
            ),
          ),
          if (showError)
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 28),
              child: Text('Centang persetujuan untuk melanjutkan.', style: AppTextStyles.formError),
            ),
        ],
      ),
    );
  }
}
