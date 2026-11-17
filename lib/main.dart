import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Add firebase_options.dart using FlutterFire CLI before enabling this initialization.
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const QuickNathamApp());
}

class QuickNathamApp extends StatelessWidget {
  const QuickNathamApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'QUICK NATHAM',
    theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFFC400)), useMaterial3: true),
    home: const HomePage(),
  );
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int tab = 0;
  final pages = const [CustomerPage(), DriverPage(), AdminPage()];
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('QUICK NATHAM', style: TextStyle(fontWeight: FontWeight.bold)), backgroundColor: const Color(0xFFFFC400)),
    body: pages[tab],
    bottomNavigationBar: NavigationBar(selectedIndex: tab, onDestinationSelected: (v) => setState(() => tab = v), destinations: const [
      NavigationDestination(icon: Icon(Icons.person), label: 'Customer'),
      NavigationDestination(icon: Icon(Icons.two_wheeler), label: 'Driver'),
      NavigationDestination(icon: Icon(Icons.admin_panel_settings), label: 'Admin'),
    ]),
  );
}

class CustomerPage extends StatelessWidget {
  const CustomerPage({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Padding(padding: EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.local_taxi, size: 64), SizedBox(height: 12), Text('Your Local Ride Partner', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)), Text('Bike Taxi + Auto • Natham + 20 KM'), SizedBox(height: 16), Text('Booking flow and OTP sign-in need Firebase configuration and backend matching.')])));
}
class DriverPage extends StatelessWidget {
  const DriverPage({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text('Driver Portal\nDriver registration and ride acceptance are not enabled yet.', textAlign: TextAlign.center));
}
class AdminPage extends StatelessWidget {
  const AdminPage({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text('Admin Preview\nSecure admin access must be configured on a trusted server.', textAlign: TextAlign.center));
}
