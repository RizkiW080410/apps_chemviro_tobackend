import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import 'home.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  late final ApiService
      _apiService; // Inisialisasi ApiService sebagai late final
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _apiService = Get.find<
        ApiService>(); // Pastikan ApiService diambil menggunakan Get.find
  }

  void _login() async {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      _showSnackbar(
        title: "Error",
        message: "Email dan Password harus diisi!",
        isSuccess: false,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String token = await _apiService.login(
        _usernameController.text,
        _passwordController.text,
      );

      _apiService.setAuthToken(token); // Set token setelah login berhasil

      // Navigasi ke halaman Home
      Get.offAll(() => const HomePage());
    } catch (e) {
      _showSnackbar(
        title: "Login Gagal",
        message: e.toString(),
        isSuccess: false,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackbar(
      {required String title,
      required String message,
      required bool isSuccess}) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: isSuccess ? Colors.green : Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: 20,
            left: 20,
            child: Container(
              height: screenHeight * 0.08,
              width: screenWidth * 0.2,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/logo_login.png'),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          Positioned(
            top: -screenHeight * 0.05,
            right: -screenWidth * 0.1,
            child: Container(
              height: screenHeight * 0.3,
              width: screenHeight * 0.3,
              decoration: const BoxDecoration(
                color: Color(0xFF00A651),
                shape: BoxShape.circle,
              ),
              child: Align(
                alignment: Alignment.center,
                child: Icon(
                  Icons.water_drop,
                  color: Colors.white,
                  size: screenWidth * 0.2,
                ),
              ),
            ),
          ),
          Positioned(
            top: screenHeight * 0.4,
            left: 0,
            right: 0,
            child: Container(
              height: screenHeight * 0.6,
              decoration: const BoxDecoration(
                color: Color.fromARGB(245, 229, 229, 229),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Login',
                          style: GoogleFonts.poppins(
                            fontSize: screenHeight * 0.035,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF00A651),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.03),
                        TextField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            hintText: 'Email',
                            prefixIcon: const Icon(Icons.email),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        TextField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          decoration: InputDecoration(
                            hintText: 'Password',
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.04),
                        Center(
                          child: _isLoading
                              ? const CircularProgressIndicator()
                              : ElevatedButton(
                                  onPressed: _login,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF00A651),
                                    padding: EdgeInsets.symmetric(
                                      vertical: screenHeight * 0.02,
                                      horizontal: screenWidth * 0.2,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    'Log In',
                                    style: GoogleFonts.poppins(
                                      fontSize: screenHeight * 0.02,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
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
          ),
        ],
      ),
    );
  }
}
