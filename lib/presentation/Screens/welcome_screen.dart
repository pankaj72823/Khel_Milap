import 'package:flutter/material.dart';
import 'package:khel_milap/presentation/Screens/signin.dart';
import 'package:khel_milap/presentation/Screens/signup.dart';
import 'package:khel_milap/presentation/Screens/home_screen.dart';
import 'package:khel_milap/presentation/theme/styles.dart';
import '../../data/data_source/auth_services.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  WelcomeScreenState createState() => WelcomeScreenState();
}

class WelcomeScreenState extends State<WelcomeScreen> {
  bool _checkingSession = true;

  @override
  void initState() {
    super.initState();
    _checkSessionAndRedirect();
  }

  Future<void> _checkSessionAndRedirect() async {
    final isLoggedIn = await AuthManager.shouldStayLoggedIn();
    if (!mounted) return;

    if (isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen()),
      );
    } else {
      setState(() {
        _checkingSession = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingSession) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/logo_khel_milap.png'),
          ElevatedButton(
            style: AppStyles.primaryButtonStyle,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Signup()),
              );
            },
            child: Text('Sign up'),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            style: AppStyles.primaryButtonStyle,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Signin()),
              );
            },
            child: Text('Login'),
          ),
        ],
      ),
    );
  }
}
