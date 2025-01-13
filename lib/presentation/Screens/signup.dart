import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:khel_milap/presentation/Provider/user_id.dart';
import 'package:khel_milap/presentation/Screens/home_screen.dart';
import 'package:khel_milap/presentation/Screens/signin.dart';
import 'package:khel_milap/presentation/theme/theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Signup extends ConsumerStatefulWidget {
  const Signup({super.key});

  @override
  _Signup createState() => _Signup();
}

class _Signup extends ConsumerState<Signup> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  File? _imageFile;

  bool _isPasswordVisible = false;

  final Map<String, bool> _sports = {
    'Tennis': false,
    'Badminton': false,
    'Cricket': false,
    'Football': false,
    'Basketball': false,
    'Volleyball': false,
    'Hockey': false,
    'Table Tennis': false,
  };

  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> pickImage() async{
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if(pickedFile!=null){
      setState(() {
        _imageFile = File(pickedFile.path);
      });
  }

  }

  Future<void> _signup() async {
    if (_formKey.currentState!.validate() && _imageFile != null) {
      try {
        final response = await _supabase.auth.signUp(
          email: _emailController.text,
          password: _passwordController.text,
        );

        if (response.user != null) {

          final userId = response.user?.id;
          print("Response: $response");

          final fileName = _imageFile!.path.split('/').last;
          final filePath = 'User/$userId/$fileName';
          print("initial file name: $fileName");
          await _supabase.storage.from('Photos').upload(filePath, _imageFile!);
          List<String> listSports = _sports.keys.where((sport){
            final selected = _sports[sport] == true;
            return selected;
          }).toList();

          await _supabase.from('Users').insert({
          'id': userId,
          'username' : _usernameController.text,
          'name': _nameController.text,
          'email': _emailController.text,
          'sports' : listSports ,
          });

          await _supabase.from('Profile').insert({
            'id':userId,
            'name': _nameController.text,
            'username' : _usernameController.text,
            'sports' : listSports,
            'profile_pic' : fileName,
          });
          ref.read(userIdProvider.notifier).state = userId;


            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Signup successful!')),
            );
            Navigator.push(
            context, MaterialPageRoute(
            builder: (context) => HomeScreen(),
              ),
            );
      }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
        print("Error in signup : $e");
      }
      } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Please fill all fields and select an image')),
          );
      }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Opacity(
            opacity: 0.3,
            child: Image.asset(
              'assets/background.jpg',
              fit: BoxFit.contain,
              height: double.infinity,
              width: double.infinity,
            ),
          ),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(48.0),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Let’s create account",
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 20),

                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: "Name",
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),

                      TextFormField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: "Username",
                          hintText: "Can include text, numbers, and symbols",
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your username';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),

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
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                            return 'Please enter a valid email address';
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
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters long';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),

                      Text(
                        "Select Sports",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      ..._sports.keys.map((sport) {
                        return CheckboxListTile(
                          title: Text(sport),
                          value: _sports[sport],
                          onChanged: (bool? value) {
                            setState(() {
                              _sports[sport] = value ?? false;
                            });
                          },
                        );
                      }).toList(),
                      SizedBox(height: 16,),
                      GestureDetector(
                        onTap: pickImage,
                        child:  _imageFile!=null
                        ? Image.file(
                          _imageFile!,
                            height: 150,
                            width: 150,
                            fit: BoxFit.cover,
                        )
                        : Container(
                          height: 150,
                          width: 150,
                          color: Colors.grey[300],
                          child: Icon(Icons.add_a_photo, size: 50,),
                        ),
                      ),
                      SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _signup,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          child: Text("Sign Up"),
                        ),
                      ),
                      SizedBox(height: 16),

                      Center(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context, MaterialPageRoute(
                              builder: (context) => Signin(),
                            ),
                            );
                          },
                          child: Text(
                            "Already have an account? Sign In",
                            style: TextStyle(
                              color: AppTheme.accentColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}