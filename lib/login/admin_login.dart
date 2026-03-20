import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hotel_booking_admin/dashboard/dashboard.dart';
import 'package:http/http.dart' as http;

class Signinscreen extends StatefulWidget {
  const Signinscreen({super.key});

  @override
  State<Signinscreen> createState() => _SigninscreenState();
}

class _SigninscreenState extends State<Signinscreen> {
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();

  bool isPasswordVisible = false;
  bool isLoading = false;

  void showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  void login() async {
    String userEmail = email.text.trim();
    String userPass = password.text.trim();

    if (userEmail.isEmpty || userPass.isEmpty) {
      showMsg("All fields required");
      return;
    }

    if (!userEmail.endsWith("@gmail.com")) {
      showMsg("Invalid Email");
      return;
    }

    if (userPass.length < 6) {
      showMsg("Password must be at least 6 characters");
      return;
    }

    setState(() => isLoading = true);

    var url = Uri.parse("https://prakrutitech.xyz/jiya/admin_login.php");

    try {
      var resp = await http.post(url, body: {
        "email": userEmail,
        "password": userPass,
      }).timeout(const Duration(seconds: 10));

      if (resp.statusCode == 200) {
        String response = resp.body.trim();

        if (response == "Login Success") {
          String username = userEmail.split("@")[0];

          showMsg("Welcome $username");

          Future.delayed(const Duration(milliseconds: 500), () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomeScreen(
                  email: userEmail,
                  username: username,
                ),
              ),
            );
          });
        } else {
          showMsg("Invalid Email or Password");
        }
      } else {
        showMsg("Server Error");
      }
    } on TimeoutException {
      showMsg("Server Timeout");
    } catch (e) {
      showMsg("Something went wrong");
    }

    setState(() => isLoading = false);
  }

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: Stack(
          children: [

            /// BACKGROUND
            SizedBox.expand(
              child: Image.asset(
                "assets/hotel_bg.png",
                fit: BoxFit.cover,
              ),
            ),

            /// DARK OVERLAY
            Container(color: Colors.black.withOpacity(0.5)),

            /// MAIN UI
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [

                      /// 🔥 GLASS CARD (NO BLUR = NO LINE)
                      Container(
                        margin: const EdgeInsets.only(top: 50),
                        padding: const EdgeInsets.fromLTRB(25, 80, 25, 25),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),

                          /// Fake glass look
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withOpacity(0.15),
                              Colors.white.withOpacity(0.05),
                            ],
                          ),

                          /// Border glow
                          border: Border.all(
                            color: Colors.white.withOpacity(0.25),
                            width: 1,
                          ),

                          /// Soft shadow
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            )
                          ],
                        ),

                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [

                            const Text(
                              "Admin Login!",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),

                            const SizedBox(height: 25),

                            /// EMAIL
                            TextField(
                              controller: email,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: "Enter Gmail",
                                hintStyle: const TextStyle(color: Colors.white60),
                                prefixIcon: const Icon(Icons.email, color: Colors.white),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.08),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),

                            const SizedBox(height: 15),

                            /// PASSWORD
                            TextField(
                              controller: password,
                              obscureText: !isPasswordVisible,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: "Enter Password",
                                hintStyle: const TextStyle(color: Colors.white60),
                                prefixIcon: const Icon(Icons.lock, color: Colors.white),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    isPasswordVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      isPasswordVisible = !isPasswordVisible;
                                    });
                                  },
                                ),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.08),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),

                            const SizedBox(height: 25),

                            /// BUTTON
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 15),
                                  backgroundColor: Colors.orangeAccent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                onPressed: isLoading ? null : login,
                                child: isLoading
                                    ? const CircularProgressIndicator(color: Colors.white)
                                    : const Text(
                                  "LOGIN",
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      /// ICON
                      Positioned(
                        top: 5,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.orange.withOpacity(0.6),
                                blurRadius: 25,
                                spreadRadius: 3,
                              ),
                            ],
                          ),
                          child: const CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.orange,
                            child: Icon(Icons.apartment, size: 40, color: Colors.white),
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
      ),
    );
  }
}