
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const Color brandYellow = Color(0xFFFFC400);
const Color brandBlack = Color(0xFF151515);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
    runApp(const QuickNathamApp());
  } catch (e) {
    runApp(FirebaseErrorApp(error: e.toString()));
  }
}

class FirebaseErrorApp extends StatelessWidget {
  final String error;

  const FirebaseErrorApp({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: brandBlack,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline,
                    color: brandYellow, size: 60),
                const SizedBox(height: 15),
                const Text(
                  'Firebase Connection Failed',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                const SizedBox(height: 10),
                Text(error,
                    style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class QuickNathamApp extends StatelessWidget {
  const QuickNathamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'QUICK NATHAM',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: brandYellow,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFFFFDF5),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int tab = 0;

  final pages = const [
    CustomerPage(),
    DriverPage(),
    AdminPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: brandYellow,
        foregroundColor: brandBlack,
        title: const Text(
          'QUICK NATHAM',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: pages[tab],
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.white,
        indicatorColor: brandYellow,
        selectedIndex: tab,
        onDestinationSelected: (value) {
          setState(() => tab = value);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.person),
            label: 'Customer',
          ),
          NavigationDestination(
            icon: Icon(Icons.two_wheeler),
            label: 'Driver',
          ),
          NavigationDestination(
            icon: Icon(Icons.admin_panel_settings),
            label: 'Admin',
          ),
        ],
      ),
    );
  }
}

class CustomerPage extends StatelessWidget {
  const CustomerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.local_taxi,
              size: 75,
              color: brandBlack,
            ),
            const SizedBox(height: 15),
            const Text(
              'Your Local Ride Partner',
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Bike Taxi + Auto',
              style: TextStyle(fontSize: 17),
            ),
            const Text('Natham + 20 KM'),
            const SizedBox(height: 25),
            const Text(
              'நம்ம ஊர்… நம்ம பயணம்…\nநம்ம QUICK NATHAM!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 25),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: brandYellow,
                foregroundColor: brandBlack,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LoginPage(),
                  ),
                );
              },
              icon: const Icon(Icons.phone_android),
              label: const Text('Mobile Login'),
            ),
          ],
        ),
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final phoneController = TextEditingController();
  final otpController = TextEditingController();

  String verificationId = '';
  bool otpSent = false;
  bool loading = false;

  Future<void> sendOTP() async {
    final phone = phoneController.text.trim();

    if (!RegExp(r'^[6-9][0-9]{9}$').hasMatch(phone)) {
      showMessage('Enter a valid 10-digit mobile number');
      return;
    }

    setState(() => loading = true);

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: '+91$phone',
        verificationCompleted: (credential) async {
          await FirebaseAuth.instance.signInWithCredential(credential);
          if (mounted) Navigator.pop(context);
        },
        verificationFailed: (error) {
          showMessage(error.message ?? 'OTP failed');
        },
        codeSent: (id, token) {
          if (!mounted) return;
          setState(() {
            verificationId = id;
            otpSent = true;
          });
          showMessage('OTP sent successfully');
        },
        codeAutoRetrievalTimeout: (id) {
          verificationId = id;
        },
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      showMessage('Error: $e');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> verifyOTP() async {
    if (otpController.text.trim().length != 6) {
      showMessage('Enter 6 digit OTP');
      return;
    }

    setState(() => loading = true);

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otpController.text.trim(),
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      if (mounted) {
        showMessage('Login successful');
        Navigator.pop(context);
      }
    } catch (e) {
      showMessage('OTP verification failed: $e');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    phoneController.dispose();
    otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Customer Login')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.phone_android, size: 60),
            const SizedBox(height: 20),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              decoration: const InputDecoration(
                labelText: 'Mobile Number',
                prefixText: '+91 ',
                border: OutlineInputBorder(),
              ),
            ),
            if (otpSent)
              TextField(
                controller: otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: const InputDecoration(
                  labelText: 'Enter OTP',
                  border: OutlineInputBorder(),
                ),
              ),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: loading
                    ? null
                    : otpSent
                        ? verifyOTP
                        : sendOTP,
                style: FilledButton.styleFrom(
                  backgroundColor: brandYellow,
                  foregroundColor: brandBlack,
                  padding: const EdgeInsets.all(16),
                ),
                child: loading
                    ? const CircularProgressIndicator()
                    : Text(otpSent ? 'Verify OTP' : 'Send OTP'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DriverPage extends StatelessWidget {
  const DriverPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.two_wheeler, size: 70),
            const SizedBox(height: 15),
            const Text(
              'QUICK NATHAM DRIVER',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Driver registration and ride acceptance '
              'will be enabled after secure backend setup.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const Chip(label: Text('Driver Portal Preview')),
          ],
        ),
      ),
    );
  }
}

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.admin_panel_settings, size: 70),
            SizedBox(height: 15),
            Text(
              'QUICK NATHAM ADMIN',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Secure admin access and booking '
              'management require trusted server setup.',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 15),
            Chip(label: Text('Admin Preview')),
          ],
        ),
      ),
    );
  }
}
