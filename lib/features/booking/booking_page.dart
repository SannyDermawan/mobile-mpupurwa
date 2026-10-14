import 'package:flutter/material.dart';

/// Layar "Booking Rombongan" (rute /booking).
// TODO(Teman 2): implementasi layar ini
class BookingPage extends StatelessWidget {
  const BookingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Booking Rombongan')),
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [Text('Booking Rombongan'), Text('Placeholder, belum diimplementasi.')],
        ),
      ),
    );
  }
}
