import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/museum_hours.dart';
import '../../../core/network/api_client.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/tanggal_format.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/app_top_bar.dart';
import '../viewmodel/booking_view_model.dart';

/// Layar "Booking Rombongan" (rute /booking): formulir pengajuan kunjungan
/// untuk sekolah, kampus, atau komunitas.
///
/// Setelah lolos validasi, pengajuan disimpan ke [BookingViewModel] lalu
/// pengguna dibawa ke layar Status Booking.
/// Dengan API aktif, pengajuan dikirim ke Web Admin dulu; layar baru pindah setelah berhasil.
class BookingPage extends StatefulWidget {
  const BookingPage({super.key});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final _formKey = GlobalKey<FormState>();
  final _institution = TextEditingController();
  final _contactName = TextEditingController();
  final _date = TextEditingController();
  final _participants = TextEditingController();
  final _phone = TextEditingController();
  final _notes = TextEditingController();

  DateTime? _visitDate;

  @override
  void dispose() {
    for (final c in [_institution, _contactName, _date, _participants, _phone, _notes]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDate() async {
    final vm = context.read<BookingViewModel>();
    final picked = await showDatePicker(
      context: context,
      initialDate: vm.initialPickerDate(current: _visitDate),
      firstDate: vm.firstVisitDate(),
      lastDate: vm.lastVisitDate(),
      selectableDayPredicate: vm.isSelectableDay,
      helpText: 'Pilih tanggal kunjungan',
      cancelText: 'Batal',
      confirmText: 'Pilih',
    );
    if (picked == null || !mounted) return;
    setState(() {
      _visitDate = picked;
      _date.text = formatTanggalLengkap(picked);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    try {
      await context.read<BookingViewModel>().submitForm(
        institution: _institution.text,
        contactName: _contactName.text,
        visitDate: _visitDate!,
        participants: _participants.text,
        phone: _phone.text,
        notes: _notes.text,
      );
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Pengajuan belum terkirim. ${e.message}')));
      return;
    } on Object {
      messenger.showSnackBar(const SnackBar(content: Text('Pengajuan belum terkirim. Coba lagi.')));
      return;
    }
    messenger.showSnackBar(
      const SnackBar(content: Text('Pengajuan dicatat. Status: Menunggu Konfirmasi.')),
    );
    router.go(AppRoutes.statusBooking);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.read<BookingViewModel>();
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AppTopBar(title: 'Booking Rombongan', titleSize: 18, showBack: false),
              Padding(
                padding: const EdgeInsets.fromLTRB(AppDimens.gutter, 4, AppDimens.gutter, 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('KUNJUNGAN RAMBONGAN', style: AppTextStyles.eyebrow),
                      const SizedBox(height: 6),
                      Text('Ajukan kunjungan grup', style: AppTextStyles.authTitle),
                      const SizedBox(height: 8),
                      Text(
                        'Isi data berikut untuk mengajukan kunjungan sekolah, kampus, atau '
                        'komunitas. Pihak museum akan mengonfirmasi pengajuanmu.',
                        style: AppTextStyles.bodySoft,
                      ),
                      const SizedBox(height: 16),
                      InfoBar(
                        icon: Icons.access_time_outlined,
                        margin: EdgeInsets.zero,
                        message: TextSpan(
                          children: [
                            // Jam ditaruh di baris sendiri supaya "08.00–16.00" tidak
                            // terpotong di tanda "–" saat teks membungkus.
                            TextSpan(text: 'Jam buka museum\n', style: InfoBar.boldStyle),
                            TextSpan(
                              text:
                                  '${MuseumHours.openDaysTextCompact}, pukul '
                                  '${MuseumHours.rangeTextCompact}. Pilih tanggal kunjungan di hari buka.',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      AppTextField(
                        label: 'Nama Instansi',
                        hint: 'mis. SMA Negeri 1 Malang',
                        controller: _institution,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.organizationName],
                        inputFormatters: [LengthLimitingTextInputFormatter(100)],
                        validator: (v) => vm.validateRequired(v, 'Nama instansi'),
                      ),
                      AppTextField(
                        label: 'Nama Penanggung Jawab',
                        hint: 'Nama lengkap penanggung jawab',
                        controller: _contactName,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.name],
                        inputFormatters: [LengthLimitingTextInputFormatter(100)],
                        validator: (v) => vm.validateRequired(v, 'Nama penanggung jawab'),
                      ),
                      _DateField(
                        controller: _date,
                        onTap: _pickDate,
                        validator: (_) =>
                            _visitDate == null ? 'Tanggal kunjungan wajib dipilih.' : null,
                      ),
                      AppTextField(
                        label: 'Jumlah Peserta',
                        hint: 'mis. 30',
                        controller: _participants,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(3),
                        ],
                        validator: vm.validateParticipants,
                      ),
                      AppTextField(
                        label: 'Nomor HP',
                        hint: '08xx-xxxx-xxxx',
                        controller: _phone,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.telephoneNumber],
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9+\- ]')),
                          LengthLimitingTextInputFormatter(18),
                        ],
                        validator: vm.validatePhone,
                      ),
                      AppTextField(
                        label: 'Catatan Tambahan (opsional)',
                        hint: 'mis. ada peserta berkebutuhan khusus, atau minta pemandu',
                        controller: _notes,
                        maxLines: 3,
                        textCapitalization: TextCapitalization.sentences,
                        inputFormatters: [LengthLimitingTextInputFormatter(300)],
                        bottomSpacing: 20,
                      ),
                      AppButton(
                        label: 'Kirim Pengajuan',
                        icon: Icons.send_outlined,
                        onPressed: _submit,
                      ),
                      const SizedBox(height: 10),
                      AppButton.secondary(
                        label: 'Lihat Status Pengajuan',
                        icon: Icons.history,
                        onPressed: () => context.go(AppRoutes.statusBooking),
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

/// Field tanggal: tampilannya sama dengan [AppTextField], tetapi tidak bisa
/// diketik. Mengetuknya membuka date picker lewat [onTap].
class _DateField extends StatelessWidget {
  const _DateField({required this.controller, required this.onTap, required this.validator});

  final TextEditingController controller;
  final VoidCallback onTap;
  final FormFieldValidator<String> validator;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tanggal Kunjungan', style: AppTextStyles.formLabel),
          const SizedBox(height: 7),
          TextFormField(
            controller: controller,
            readOnly: true,
            onTap: onTap,
            style: AppTextStyles.formInput,
            validator: validator,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: const InputDecoration(
              hintText: 'Pilih tanggal',
              suffixIcon: Icon(Icons.calendar_today_outlined, size: 18, color: AppColors.amber),
            ),
          ),
        ],
      ),
    );
  }
}
