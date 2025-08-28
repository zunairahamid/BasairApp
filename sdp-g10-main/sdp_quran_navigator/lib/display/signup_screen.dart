import 'package:flutter/material.dart';
import 'package:sdp_quran_navigator/models/user.dart' as app_user;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sdp_quran_navigator/display/quran_navigator_screen.dart';

final supabase = Supabase.instance.client;

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final formkey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  List<String> userType = ["Admin", "User", "Author", "Reviewer"];
  List<String> userPay = ["Free", "Premium"];
  
  String? selectedUserType;
  String? selectedUserPay;
  
  bool isPasswordVisible = false;
  bool isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Sign Up",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Form(
                key: formkey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(labelText: 'Email'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(labelText: 'Password'),
                      obscureText: !isPasswordVisible,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _confirmPasswordController,
                      decoration: InputDecoration(labelText: 'Confirm Password'),
                      obscureText: !isPasswordVisible,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        } else if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: selectedUserType,
                      items: userType.map((userType) {
                        return DropdownMenuItem<String>(
                          value: userType,
                          child: Text(userType),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedUserType = newValue;
                        });
                      },
                      decoration: InputDecoration(labelText: 'User Type'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a user type';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: selectedUserPay,
                      items: userPay.map((userPay) {
                        return DropdownMenuItem<String>(
                          value: userPay,
                          child: Text(userPay),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedUserPay = newValue;
                        });
                      },
                      decoration: InputDecoration(labelText: 'Payment Type'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a payment type';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        if (formkey.currentState!.validate()) {
                          setState(() {
                            isLoading = true;
                          });
                          try {
                            final response = await supabase.auth.signUp(
                              email: _emailController.text,
                              password: _passwordController.text,
                            );

                            if (response.user != null) {
                              final user = app_user.User(
                                email: response.user!.email!,
                                password: _passwordController.text,
                                uid: response.user!.id,
                                userType: selectedUserType ?? 'User',
                                userPay: selectedUserPay ?? 'Free',
                              );

                              await supabase
                                  .from('users')
                                  .upsert(user.toMap());

                              // Navigate to the Quran Navigator screen
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => QuranNavigator(),
                                ),
                              );
                            } else {
                              throw Exception('User creation failed');
                            }
                          } catch (e) {
                            // Handle error (e.g., show a snackbar)
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                          } finally {
                            setState(() {
                              isLoading = false;
                            });
                          }
                        }
                      },
                      child: isLoading
                          ? CircularProgressIndicator()
                          : Text("Sign Up"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}