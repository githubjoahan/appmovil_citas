import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:medappoint/views/MyHome_view.dart';
import 'package:medappoint/views/createUser_view.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<LoginPage> {
  late String email, password;
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  String error = '';

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();
      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        return await _auth.signInWithCredential(credential);
      }
    } catch (error) {
      print(error);
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _auth.authStateChanges(),
      builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          if (snapshot.data != null) {
            // Si hay un usuario autenticado, dirige a MyHomePage
            return MyHomePage();
          } else {
            // Si no hay un usuario autenticado, muestra LoginPage
            return buildLoginPage(context);
          }
        }
        // Mientras espera a que el stream informe el estado, muestra un indicador de carga.
        return Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }

  @override
  buildLoginPage(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: Card(
          margin: EdgeInsets.symmetric(horizontal: 20.0),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.person, size: 100, color: Colors.blue),
                  SizedBox(height: 20),
                  Text("Med Appoint",
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  SizedBox(height: 20),
                  formulario(),
                  SizedBox(height: 20),
                  buttonLogin(),
                  SizedBox(height: 20),
                  ElevatedButton(
                    child: Text("Iniciar con Google"),
                    onPressed: () async {
                      UserCredential? user = await signInWithGoogle();
                      if (user != null) {
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => MyHomePage(),
                        ));
                      }
                    },
                  ),
                  SizedBox(height: 20),
                  nuevoAqui(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget nuevoAqui() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("¿Aún no estás registrado?"),
        TextButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => CreateUserPage()));
            },
            child: Text("Regístrate")),
      ],
    );
  }

  Widget formulario() {
    return Form(
        key: _formKey,
        child: Column(
          children: [
            buildEmail(),
            SizedBox(height: 20),
            buildPassword(),
          ],
        ));
  }

  Widget buttonLogin() {
    return FractionallySizedBox(
      widthFactor: 0.6,
      child: ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              UserCredential? credenciales = await login(email, password);
              if (credenciales != null) {
                if (credenciales.user != null) {
                  if (credenciales.user!.emailVerified) {
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => MyHomePage()),
                        (Route<dynamic> route) => false);
                  } else {
                    setState(() {
                      error = "Debes verificar tu correo antes de acceder";
                    });
                  }
                }
              }
            }
          },
          child: Text("Iniciar sesión")),
    );
  }

  Future<UserCredential?> login(String email, String passwd) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: passwd);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        setState(() {
          error = 'No se encontró un usuario con ese email.';
        });
      } else if (e.code == 'wrong-password') {
        setState(() {
          error = 'Contraseña incorrecta.';
        });
      }
      return null;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Widget buildEmail() {
    return TextFormField(
    decoration: InputDecoration(labelText: "Email"),
      validator: (val) => val!.isEmpty ? 'Por favor ingresa un email' : null,
      onSaved: (val) => email = val!,


    );
  }

  Widget buildPassword() {
    return TextFormField(
      decoration: InputDecoration(labelText: "Contraseña"),
      obscureText: true,
      validator: (val) => val!.length < 6
          ? 'Por favor ingresa una contraseña de al menos 6 caracteres'
          : null,
      onSaved: (val) => password = val!,
    );
  }
}
