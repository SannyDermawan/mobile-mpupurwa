import 'package:flutter_test/flutter_test.dart';
import 'package:museum_mpupurwa_app/core/services/link_launcher.dart';
import 'package:museum_mpupurwa_app/features/collections/model/koleksi_model.dart';
import 'package:museum_mpupurwa_app/features/collections/viewmodel/koleksi_detail_view_model.dart';

class _Launcher implements LinkLauncher {
  @override
  Future<bool> open(String url) async => true;
}

Koleksi _k({String era = 'SINGOSARI', String periode = '±820 tahun'}) => Koleksi(
  id: 'brahma',
  nama: 'Arca Brahma',
  era: era,
  asal: '',
  periode: periode,
  material: '',
  sejarah: '',
  fotoUrl: '',
);

void main() {
  test('ringkasan disusun dari era dan periode arca, bukan teks tetap', () {
    final vm = KoleksiDetailViewModel(_k(), _Launcher());
    expect(vm.ringkasan, 'Koleksi Museum Mpu Purwa · masa Singosari · ±820 tahun.');
    expect(vm.ringkasan, isNot(contains('tikus')));
  });

  test('ringkasan tetap rapi kalau era dan periode kosong', () {
    final vm = KoleksiDetailViewModel(_k(era: '', periode: ''), _Launcher());
    expect(vm.ringkasan, 'Koleksi Museum Mpu Purwa.');
  });
}
