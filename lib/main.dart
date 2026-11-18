
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
        colorScheme: ColorScheme.fromSeed(seedColor: brandYellow),
        scaffoldBackgroundColor: const Color(0xFFF7F7F7),
      ),
      home: const AuthGate(),
    );
  }
}

// CHECK LOGIN STATUS

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          return const CustomerDashboard();
        }

        return const HomePage();
      },
    );
  }
}

// HOME PAGE

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
            style: TextStyle(fontWeight: FontWeight.bold),
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

// CUSTOMER PAGE

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
              'WELCOME TO QUICK NATHAM',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text('Fast and Easy Local Delivery'),
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
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// DRIVER PAGE

class DriverPage extends StatelessWidget {
  const DriverPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.delivery_dining, size: 80, color: brandYellow),
          SizedBox(height: 15),
          Text(
            'Driver Section',
            style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
          ),
          Text('Driver registration coming soon'),
        ],
      ),
    );
  }
}

// ADMIN PAGE

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.admin_panel_settings, size: 80, color: brandYellow),
          SizedBox(height: 15),
          Text(
            'Admin Section',
            style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
          ),
          Text('Admin panel coming soon'),
        ],
      ),
    );
  }
}

// PHONE LOGIN PAGE

class PhoneLoginPage extends StatefulWidget {
  const PhoneLoginPage({super.key});

  @override
  State<PhoneLoginPage> createState() => _PhoneLoginPageState();
}

class _PhoneLoginPageState extends State<PhoneLoginPage> {
  final phoneController = TextEditingController();
  final otpController = TextEditingController();

  final FirebaseAuth auth = FirebaseAuth.instance;

  String verificationId = '';
  bool otpSent = false;
  bool loading = false;

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: brandBlack,
      ),
    );
  }

  Future<void> completeLogin(PhoneAuthCredential credential) async {
    try {
      await auth.signInWithCredential(credential);

      if (!mounted) return;

      setState(() {
        loading = false;
      });

      showMessage('Login successful!');

      // AuthGate now detects the signed-in user.
      // Pop login page to reveal Customer Dashboard.
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() => loading = false);
      showMessage('${e.code}: ${e.message}');
    } catch (e) {
      if (!mounted) return;
      setState(() => loading = false);
      showMessage('Login error: $e');
    }
  }

  Future<void> sendOTP() async {
    final phone = phoneController.text.trim();

    if (!RegExp(r'^\+91[0-9]{10}$').hasMatch(phone)) {
      showMessage('Enter number in +91XXXXXXXXXX format');
      return;
    }

    setState(() => loading = true);

    try {
      // TESTING ONLY. Use Firebase Console test phone number.
      await auth.setSettings(
        appVerificationDisabledForTesting: true,
      );

      await auth.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: const Duration(seconds: 60),

        verificationCompleted: (PhoneAuthCredential credential) {
          completeLogin(credential);
        },

        verificationFailed: (FirebaseAuthException e) {
          if (!mounted) return;
          setState(() => loading = false);
          showMessage('${e.code}: ${e.message}');
        },

        codeSent: (String id, int? resendToken) {
          if (!mounted) return;

          setState(() {
            verificationId = id;
            otpSent = true;
            loading = false;
          });

          showMessage('Test OTP ready. Enter your test code.');
        },

        codeAutoRetrievalTimeout: (String id) {
          verificationId = id;
        },
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() => loading = false);
      showMessage('${e.code}: ${e.message}');
    } catch (e) {
      if (!mounted) return;
      setState(() => loading = false);
      showMessage('Error: $e');
    }
  }

  Future<void> verifyOTP() async {
    final code = otpController.text.trim();

    if (verificationId.isEmpty) {
      showMessage('Please send OTP first');
      return;
    }

    if (code.length != 6) {
      showMessage('Enter 6 digit OTP');
      return;
    }

    setState(() => loading = true);

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: code,
      );

      await completeLogin(credential);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() => loading = false);
      showMessage('${e.code}: ${e.message}');
    } catch (e) {
      if (!mounted) return;
      setState(() => loading = false);
      showMessage('Error: $e');
    }
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
                    : const Text('Send OTP'),
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
                    : const Text('Verify OTP'),
              ),
            ],
            const SizedBox(height: 20),
            const Text(
              'Testing mode: Use the phone number and code configured in Firebase Console.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

// CUSTOMER DASHBOARD

class CustomerDashboard extends StatelessWidget {
  const CustomerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final phone = user?.phoneNumber ?? 'Customer';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: brandBlack,
        foregroundColor: Colors.white,
        title: const Text(
          'QUICK NATHAM',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              phone,
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 25),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: brandBlack,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.local_shipping,
                    color: brandYellow,
                    size: 48,
                  ),
                  SizedBox(height: 15),
                  Text(
                    'QUICK NATHAM DELIVERY',
                    style: TextStyle(
                      color: brandYellow,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Fast and Easy Local Delivery',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),
            const Text(
              'Services',
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),

            DashboardButton(
              icon: Icons.add_box,
              title: 'Book Delivery',
              subtitle: 'Create a new delivery booking',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const BookDeliveryPage(),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            DashboardButton(
              icon: Icons.receipt_long,
              title: 'My Bookings',
              subtitle: 'View your delivery bookings',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MyBookingsPage(),
                  ),
                );
              },
            ),

            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                },
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// DASHBOARD BUTTON

class DashboardButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const DashboardButton({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(14),
        leading: CircleAvatar(
          backgroundColor: brandYellow,
          child: Icon(icon, color: brandBlack),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 17),
        onTap: onTap,
      ),
    );
  }
}

// BOOK DELIVERY PAGE

class BookDeliveryPage extends StatefulWidget {
  const BookDeliveryPage({super.key});

  @override
  State<BookDeliveryPage> createState() => _BookDeliveryPageState();
}

class _BookDeliveryPageState extends State<BookDeliveryPage> {
  final pickupController = TextEditingController();
  final deliveryController = TextEditingController();
  final detailsController = TextEditingController();

  @override
  void dispose() {
    pickupController.dispose();
    deliveryController.dispose();
    detailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Delivery'),
        backgroundColor: brandBlack,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Delivery Details',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: pickupController,
              decoration: const InputDecoration(
                labelText: 'Pickup Location',
                prefixIcon: Icon(Icons.location_on),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: deliveryController,
              decoration: const InputDecoration(
                labelText: 'Delivery Location',
                prefixIcon: Icon(Icons.flag),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: detailsController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Parcel Details',
                hintText: 'Describe your parcel',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 25),
            const Text(
              'Booking submission will be enabled after Firebase booking setup.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

// MY BOOKINGS PAGE

class MyBookingsPage extends StatelessWidget {
  const MyBookingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
        backgroundColor: brandBlack,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 75, color: brandYellow),
            SizedBox(height: 15),
            Text(
              'No Bookings Yet',
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Your delivery bookings will appear here.'),
          ],
        ),
      ),
    );
  }
}
