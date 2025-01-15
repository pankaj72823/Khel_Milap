import 'package:flutter/material.dart';
import 'package:khel_milap/presentation/Screens/signin.dart';
import 'package:khel_milap/presentation/Screens/signup.dart';
import 'package:khel_milap/presentation/theme/styles.dart';

class WelcomeScreen extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body:  Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/logo_khel_milap.png'),
                ElevatedButton(
                    style: AppStyles.primaryButtonStyle,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Signup(),
                        ),
                      );
                    },
                    child: Text('Sign up'),
                ),
                const SizedBox(height: 16,),
                ElevatedButton(
                  style: AppStyles.primaryButtonStyle,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>Signin(),
                      ),
                    );
                  },
                  child: Text('Login'),
                ),
                ],
            ),
    );
  }

}
