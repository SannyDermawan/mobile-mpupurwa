import 'package:flutter/material.dart';

/// Layar "Status Booking" (rute /status-booking).
// TODO(Teman 2): implementasi layar ini
class StatusBookingPage extends StatelessWidget {
  const StatusBookingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Status Booking')),
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [Text('Status Booking'), Text('Placeholder, belum diimplementasi.')],
        ),
      ),
    );
  }
}
