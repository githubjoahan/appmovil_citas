import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:medappoint/views/login_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mi Aplicación',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF7F8FA),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: InitialCheck(),
    );
  }
}

class InitialCheck extends StatefulWidget {
  @override
  _InitialCheckState createState() => _InitialCheckState();
}

class _InitialCheckState extends State<InitialCheck> {
  late User? currentUser;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: googleSignIn.isSignedIn(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          // Si hay un usuario conectado con FirebaseAuth o GoogleSignIn
          if (currentUser != null || snapshot.data == true) {
            return LoginPage(); // redidirige al login
          } else {
            return LoginPage();
          }
        } else {
          return CircularProgressIndicator(); // Muestra un indicador de carga mientras se espera
        }
      },
    );
  }
}
