import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'routes/route.dart';
import 'services/api_service.dart'; // Pastikan import ApiService

void main() {
  // Inisialisasi ApiService
  Get.put(ApiService()); // ApiService akan tersedia di seluruh aplikasi

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: Routes.welcome, // Set halaman pertama ke WelcomePage
      getPages: AppPages.pages, // Atur rute menggunakan GetX
    );
  }
}
