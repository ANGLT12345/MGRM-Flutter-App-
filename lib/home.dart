import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';

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
              '/assets/customer-12345-qr.png',
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
          const Text('Rewards Page'),
          ElevatedButton(
            child: Text("Redeem IPhone 17 Pro Max"),
            style: ButtonStyle(
              foregroundColor: WidgetStateProperty.all<Color>(Colors.blue),
              backgroundColor: WidgetStateProperty.all<Color>(Colors.yellow),
            ),
            onPressed: () {},
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
  final List<Widget> _pages = const [
    QrCodePage(),
    GamesProgressPage(),
    RewardsPage(),
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
