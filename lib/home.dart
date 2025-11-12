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
class GamesProgressPage extends StatefulWidget {
  const GamesProgressPage({super.key});

  @override
  State<GamesProgressPage> createState() => _GamesProgressPageState();
}

class _GamesProgressPageState extends State<GamesProgressPage> {
  final List<Map<String, Object>> _questions = [
    {
      'questionText': 'Who founded Magorium?',
      'answers': [
        {'text': 'Oh Chu Xian', 'score': 10},
        {'text': 'Elon Musk', 'score': -2},
        {'text': 'Bill Gates', 'score': -2},
        {'text': 'Greta Thunberg', 'score': -2},
      ],
    },
    {
      'questionText': 'What does Magorium recycle?',
      'answers': [
        {'text': 'Electronic Waste', 'score': -2},
        {'text': 'Used Cooking Oil', 'score': -2},
        {'text': 'Plastic Waste', 'score': 10},
        {'text': 'Paper Waste', 'score': -2},
      ],
    },
    {
      'questionText':
          'What product does Magorium create from recycled plastic?',
      'answers': [
        {'text': 'Furniture', 'score': -2},
        {'text': 'Road Construction Material', 'score': 10},
        {'text': 'Bottles', 'score': -2},
        {'text': 'Textiles', 'score': -2},
      ],
    },
    {
      'questionText': 'Where is Magorium based?',
      'answers': [
        {'text': 'Malaysia', 'score': -2},
        {'text': 'Singapore', 'score': 10},
        {'text': 'Indonesia', 'score': -2},
        {'text': 'Thailand', 'score': -2},
      ],
    },
    {
      'questionText':
          'Can all types of plastic be recycled using Magorium’s technology?',
      'answers': [
        {'text': 'Yes', 'score': 10},
        {'text': 'No', 'score': -2},
      ],
    },
  ];

  int _questionIndex = 0;
  int _totalScore = 0;
  bool _pointsGiven = false; // To ensure points are only given once

  // Replace with actual user id
  final String customerId = 'CUST-12345';

  void _answerQuestion(int score) {
    setState(() {
      _totalScore += score;
      _questionIndex += 1;
    });
  }

  void _resetQuiz() {
    setState(() {
      _questionIndex = 0;
      _totalScore = 0;
      _pointsGiven = false;
    });
  }

  String get _resultRemark {
    if (_totalScore >= 41) {
      return 'You are awesome!';
    } else if (_totalScore >= 31) {
      return 'Pretty likeable!';
    } else if (_totalScore >= 21) {
      return 'You need to work more!';
    } else if (_totalScore >= 1) {
      return 'You need to work hard!';
    } else {
      return 'This is a poor score!';
    }
  }

  Future<void> _addPointsToCustomer(int points) async {
    final userRef = FirebaseFirestore.instance
        .collection('customers')
        .doc(customerId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(userRef);
      final currentPoints = snapshot.data()?['points'] ?? 0;
      transaction.update(userRef, {'points': currentPoints + points});
    });
  }

  @override
  Widget build(BuildContext context) {
    final quizEnded = _questionIndex >= _questions.length;

    // Give points only once when the quiz ends
    if (quizEnded && !_pointsGiven) {
      _pointsGiven = true;
      _addPointsToCustomer(_totalScore);
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: !quizEnded
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _questions[_questionIndex]['questionText'] as String,
                    style: const TextStyle(fontSize: 28),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ...(_questions[_questionIndex]['answers']
                          as List<Map<String, Object>>)
                      .map(
                        (ans) => Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () =>
                                _answerQuestion(ans['score'] as int),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                            child: Text(ans['text'] as String),
                          ),
                        ),
                      ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _resultRemark,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'Score $_totalScore',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: _resetQuiz,
                    child: Container(
                      color: Colors.green,
                      padding: const EdgeInsets.all(14),
                      child: const Text(
                        'Restart Quiz',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// Page 3: Rewards
class RewardsPage extends StatelessWidget {
  const RewardsPage({super.key});

  Future<void> redeemReward(
    BuildContext context,
    String customerId,
    int pointsRequired,
    String rewardName,
  ) async {
    final userRef = FirebaseFirestore.instance
        .collection('customers')
        .doc(customerId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(userRef);
      final currentPoints = snapshot.data()?['points'] ?? 0;

      if (currentPoints >= pointsRequired) {
        transaction.update(userRef, {'points': currentPoints - pointsRequired});
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Success"),
            content: Text("You have redeemed $rewardName!"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("Close"),
              ),
            ],
          ),
        );
      } else {
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
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Replace static ElevatedButtons with dynamic rewards list
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('rewards').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();
        final rewardDocs = snapshot.data!.docs;

        return ListView.builder(
          shrinkWrap: true,
          itemCount: rewardDocs.length,
          itemBuilder: (context, index) {
            final reward = rewardDocs[index].data() as Map<String, dynamic>;
            final rewardName = reward['name'] ?? 'Reward';
            final imageAsset = reward['image'] ?? 'default.png';
            final pointsRequired = reward['points_required'] ?? 0;

            return Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 16.0,
                horizontal: 24.0,
              ),
              child: ElevatedButton(
                style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6.7),
                    ),
                  ),
                  foregroundColor: MaterialStateProperty.all<Color>(
                    Colors.white,
                  ),
                  backgroundColor: MaterialStateProperty.all<Color>(
                    Colors.green,
                  ),
                ),
                child: Column(
                  children: [
                    Image.asset(
                      imageAsset,
                      width: 100,
                      height: 70,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 10),
                    Text(rewardName),
                    const SizedBox(height: 8),
                    Text("Redeem for $pointsRequired points"),
                  ],
                ),
                onPressed: () {
                  // Get the actual customer ID (replace CUST-12345 with real ID)
                  redeemReward(
                    context,
                    'CUST-12345',
                    pointsRequired,
                    rewardName,
                  );
                },
              ),
            );
          },
        );
      },
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
