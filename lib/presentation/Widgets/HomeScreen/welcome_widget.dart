import 'package:flutter/material.dart';

class WelcomeWidget extends StatelessWidget {
  const WelcomeWidget({super.key,  required this.child});
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.lightBlueAccent[100],
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          automaticallyImplyLeading: false,
        ),
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            Image.asset(
              'assets/Home_Screen/sign.jpg',
              fit: BoxFit.contain,
              width: double.infinity,
              height: double.infinity,
            ),
            SafeArea(
              child: child!,
            )
          ],
        ),
      ),
    );
  }
}
