
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

const Color brandYellow = Color(0xFFFFC400);
const Color brandBlack = Color(0xFF151515);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  runApp(const QuickNathamApp());
}

class QuickNathamApp extends StatelessWidget {
  const QuickNathamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'QUICK NATHAM',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: brandYellow,
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F7F7),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: brandBlack,
          foregroundColor: Colors.white,
          title: const Text(
            'QUICK NATHAM',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          bottom: const TabBar(
            indicatorColor: brandYellow,
            labelColor: brandYellow,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: 'Customer'),
              Tab(text: 'Driver'),
              Tab(text: 'Admin'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            CustomerPage(),
            DriverPage(),
            AdminPage(),
          ],
        ),
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.local_shipping,
              size: 90,
              color: brandYellow,
            ),
            const SizedBox(height: 20),
            const Text(
              'Welcome to QUICK NATHAM',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
                color: brandBlack,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Fast and Easy Local Delivery',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: brandYellow,
                  foregroundColor: brandBlack,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PhoneLoginPage(),
                    ),
                  );
                },
                child: const Text(
                  'Customer Login',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.delivery_dining,
            size: 80,
            color: brandYellow,
          ),
          SizedBox(height: 15),
          Text(
            'Driver Section',
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text('Driver registration coming soon'),
        ],
      ),
    );
  }
}

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.admin_panel_settings,
            size: 80,
            color: brandYellow,
          ),
          SizedBox(height: 15),
          Text(
            'Admin Section',
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text('Admin panel coming soon'),
        ],
      ),
    );
  }
}

class PhoneLoginPage extends StatefulWidget {
  const PhoneLoginPage({super.key});

  @override
  State<PhoneLoginPage> createState() => _PhoneLoginPageState();
}

class _PhoneLoginPageState extends State<PhoneLoginPage> {
  final phoneController = TextEditingController();
  final otpController = TextEditingController();

  String verificationId = '';
  bool otpSent = false;
  bool loading = false;

  final FirebaseAuth auth = FirebaseAuth.instance;

  Future<void> sendOTP() async {
    final phone = phoneController.text.trim();

    if (!RegExp(r'^\+91[0-9]{10}$').hasMatch(phone)) {
      showMessage('Enter number in +91XXXXXXXXXX format');
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      // TESTING ONLY:
      // Use the phone number and OTP saved in Firebase Console.
      await auth.setSettings(
        appVerificationDisabledForTesting: true,
      );

      await auth.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: const Duration(seconds: 60),

        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            await auth.signInWithCredential(credential);
            if (!mounted) return;
            showMessage('Phone verified successfully');
          } catch (e) {
            if (!mounted) return;
            showMessage('Login error: $e');
          }
        },

        verificationFailed: (FirebaseAuthException e) {
          if (!mounted) return;
          setState(() {
            loading = false;
          });
          showMessage('${e.code}: ${e.message ?? "Verification failed"}');
        },

        codeSent: (String id, int? resendToken) {
          if (!mounted) return;
          setState(() {
            verificationId = id;
            otpSent = true;
            loading = false;
          });
          showMessage('OTP ready. Enter your Firebase test code.');
        },

        codeAutoRetrievalTimeout: (String id) {
          verificationId = id;
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        loading = false;
      });
      showMessage('Error: $e');
    }
  }

  Future<void> verifyOTP() async {
    final smsCode = otpController.text.trim();

    if (verificationId.isEmpty) {
      showMessage('Please send OTP first');
      return;
    }

    if (smsCode.length != 6) {
      showMessage('Enter the 6 digit OTP');
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      await auth.signInWithCredential(credential);

      if (!mounted) return;

      setState(() {
        loading = false;
      });

      showMessage('Login successful!');

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        loading = false;
      });
      showMessage('${e.code}: ${e.message ?? "Invalid OTP"}');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        loading = false;
      });
      showMessage('Error: $e');
    }
  }

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: brandBlack,
      ),
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
      appBar: AppBar(
        title: const Text('Customer Login'),
        backgroundColor: brandBlack,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 30),
            const Icon(
              Icons.phone_android,
              size: 85,
              color: brandYellow,
            ),
            const SizedBox(height: 20),
            const Text(
              'Mobile Number Verification',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),

            const Text(
              'Mobile Number (+91)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                hintText: '+919876543210',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
            ),

            const SizedBox(height: 20),

            if (!otpSent)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: brandYellow,
                  foregroundColor: brandBlack,
                  minimumSize: const Size(double.infinity, 52),
                ),
                onPressed: loading ? null : sendOTP,
                child: loading
                    ? const CircularProgressIndicator()
                    : const Text(
                        'Send OTP',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
              ),

            if (otpSent) ...[
              const Text(
                'Enter Test OTP',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              TextField(
                controller: otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: const InputDecoration(
                  hintText: 'Enter 6 digit OTP',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
              ),

              const SizedBox(height: 12),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: brandYellow,
                  foregroundColor: brandBlack,
                  minimumSize: const Size(double.infinity, 52),
                ),
                onPressed: loading ? null : verifyOTP,
                child: loading
                    ? const CircularProgressIndicator()
                    : const Text(
                        'Verify OTP',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
              ),
            ],

            const SizedBox(height: 20),

            const Text(
              'Testing mode: Use the test phone number and OTP configured in Firebase Console.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
