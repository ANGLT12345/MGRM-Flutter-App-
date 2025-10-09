import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';

class CustomerDataProvider extends StatelessWidget {
  const CustomerDataProvider({super.key});

  Future<int> _getCustomerPoints() async {
    final customerDoc = await FirebaseFirestore.instance
        .collection('customers')
        .doc('CUST-12345') // Replace with dynamic customer ID if needed
        .get();

    if (customerDoc.exists) {
      return customerDoc.data()?['points'] ?? 0;
    } else {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
      future: _getCustomerPoints(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return const Text('Error retrieving points');
        } else {
          final points = snapshot.data ?? 0;
          return Text(
            'Points: $points',
            style: Theme.of(context).textTheme.headlineSmall,
          );
        }
      },
    );
  }
}

// Page 1: QR Code (your existing screen)
class QrCodePage extends StatelessWidget {
  const QrCodePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          SizedBox(
            width: 250,
            height: 250,
            child: Image.asset(
              'assets/customer-12345-qr.png',
              width: 250,
              height: 250,
              fit: BoxFit.contain,
              alignment: Alignment.center,
            ),
          ),
          Center(
            child: Text(
              'Please scan QR Code on Recycling Bin\n',
              style:
                  Theme.of(
                    context,
                  ).textTheme.displaySmall?.copyWith(fontSize: 18) ??
                  const TextStyle(fontSize: 18),

              textAlign: TextAlign.center,
            ),
          ),
          const SignOutButton(),
        ],
      ),
    );
  }
}

// Page 2: Games & Progress
class GamesProgressPage extends StatelessWidget {
  const GamesProgressPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Games & Progress Page'));
  }
}

// Page 3: Rewards
class RewardsPage extends StatelessWidget {
  const RewardsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 20),
          ElevatedButton(
            child: Column(
              children: [
                Image.asset(
                  '/iphone.png', // Replace with your image path
                  width: 100,
                  height: 70,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 10),
                Text("Redeem IPhone 17 Pro Max"),
              ],
            ),
            style: ButtonStyle(
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6.7),
                ),
              ),
              foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
              backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Insufficient Points"),
                  content: const Text(
                    "You do not have enough points to redeem this reward.",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text("Close"),
                    ),
                  ],
                ),
              );
            },
          ),
          SizedBox(height: 20),
          ElevatedButton(
            child: Column(
              children: [
                Image.asset(
                  '/5dollarntuc.png', // Replace with your image path
                  width: 100,
                  height: 70,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 5),
                Text("Redeem \$5 Fairprice Voucher"),
              ],
            ),
            style: ButtonStyle(
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6.7),
                ),
              ),
              foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
              backgroundColor: WidgetStateProperty.all<Color>(Colors.green),
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Are you sure?"),
                  content: const Text(
                    "Do you really want to redeem this reward for 500 points?",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text("Yes"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text("No"),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// Main home screen with bottom navigation
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        CustomerDataProvider(), // Added CustomerDataProvider here
        QrCodePage(),
      ],
    ),
    const GamesProgressPage(),
    Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        CustomerDataProvider(), // Added CustomerDataProvider here
        RewardsPage(),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(
                    appBar: AppBar(title: const Text('User Profile')),
                    actions: [
                      SignedOutAction((context) {
                        Navigator.of(context).pop();
                      }),
                    ],
                    children: [
                      const Divider(height: 3),
                      Padding(
                        padding: const EdgeInsets.all(1),
                        child: AspectRatio(
                          aspectRatio: 3,
                          child: Image.asset('magorium_landscape.png'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
        automaticallyImplyLeading: false,
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.qr_code), label: 'QR Code'),
          BottomNavigationBarItem(
            icon: Icon(Icons.videogame_asset),
            label: 'Games',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.card_giftcard),
            label: 'Rewards',
          ),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
