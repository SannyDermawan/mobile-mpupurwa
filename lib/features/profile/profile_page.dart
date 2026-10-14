import 'package:flutter/material.dart';

/// Layar "Profil Saya" (rute /profil).
// TODO(Teman 1): implementasi layar ini
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil Saya')),
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [Text('Profil Saya'), Text('Placeholder, belum diimplementasi.')],
        ),
      ),
    );
  }
}
