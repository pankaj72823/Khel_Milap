
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khel_milap/presentation/Provider/user_id.dart';
import 'package:khel_milap/presentation/Screens/home_screen.dart';
import 'package:khel_milap/presentation/Screens/signup.dart';
import 'package:khel_milap/presentation/theme/theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/data_source/auth_services.dart';

class Signin extends ConsumerStatefulWidget {
  const Signin({super.key});

  @override
  _Signin createState() => _Signin();
}

class _Signin extends ConsumerState<Signin> {
  final SupabaseClient _supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  Future<void> signIn() async {

    final response = await Supabase.instance.client.auth.signInWithPassword(
      email: _emailController.text,
      password: _passwordController.text,
    );
    if (response.session != null) {
      await AuthManager.setLoginTimestamp();
    } else{
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Signin failed')),
      );
    }
    final res = await _supabase
        .from('Users')
        .select('id,name,sports')
        .eq('email', "${_supabase.auth.currentUser?.email}").single();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Signed in successfully'),
        ),
      );
      ref.read(userIdProvider.notifier).state = "${res['id']}";
    ref.read(nameProvider.notifier).state = "${res['name']}";
    ref.read(sportsProvider.notifier).state = res['sports'];

      Navigator.push(
          context, MaterialPageRoute(
          builder: (context) => HomeScreen(fromSignup: false,),
      ),
      );
    }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Opacity(
            opacity: 0.2,
            child: Image.asset(
              'assets/cric.png',
              fit: BoxFit.contain,
              height: double.infinity,
              width: double.infinity,
            ),
          ),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(48.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Welcome back, champ",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: "Email",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      decoration: InputDecoration(
                        labelText: "Password",
                        border: OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            signIn();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        child: Text("Sign in"),
                      ),
                    ),
                    SizedBox(height: 16),
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context, MaterialPageRoute(
                            builder: (context) => Signup(),
                          ),
                          );
                        },
                        child: Text(
                          "New user? Sign up",
                          style: TextStyle(color: AppTheme.accentColor, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
