import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:medappoint/views/MyHome_view.dart';

class VistaExitosa extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text("Acción realizada con éxito!")),
    );
  }
}

class CreateUserPage extends StatefulWidget {
  @override
  State createState() => _CreateUserState();
}

class _CreateUserState extends State<CreateUserPage> {
  String email = '', password = '';
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Crear usuario",
              style: TextStyle(color: Colors.black, fontSize: 24)),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: formulario(),
          ),
          isLoading ? CircularProgressIndicator() : botonCrearUsuario(),
          botonInicioGoogle(),
          TextButton(
            child: Text("¿Ya estás registrado? Iniciar sesión"),
            onPressed: () {
              // Navega a la página de inicio de sesión aquí
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget formulario() {
    return Form(
        key: _formKey,
        child: Column(
          children: [
            buildEmail(),
            const Padding(padding: EdgeInsets.only(top: 12)),
            buildPassword(),
          ],
        ));
  }

  Widget buildEmail() {
    return TextFormField(
      decoration: InputDecoration(
          labelText: "Ingrese un correo válido",
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.black))),
      keyboardType: TextInputType.emailAddress,
      onSaved: (String? value) {
        email = value!;
      },
      validator: (value) {
        if (value!.isEmpty) {
          return "Este campo es obligatorio";
        }
        return null;
      },
    );
  }

  Widget buildPassword() {
    return TextFormField(
      decoration: InputDecoration(
          labelText: "Ingresa una contraseña",
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.black))),
      obscureText: true,
      validator: (value) {
        if (value!.isEmpty) {
          return "Este campo es obligatorio";
        } else if (value.length < 6) {
          return "La contraseña debe tener al menos 6 caracteres";
        }
        return null;
      },
      onSaved: (String? value) {
        password = value!;
      },
    );
  }

  Widget botonCrearUsuario() {
    return FractionallySizedBox(
      widthFactor: 0.6,
      child: ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              setState(() {
                isLoading = true;
              });
              UserCredential? credenciales =
                  await crearUsuario(email, password);
              setState(() {
                isLoading = false;
              });
              if (credenciales != null) {
                if (credenciales.user != null) {
                  await credenciales.user!.sendEmailVerification();
                  mostrarSnackBar(
                      "Usuario creado. Por favor, verifica tu correo para iniciar sesión.");
                  navegarAVista();
                }
              }
            }
          },
          child: Text("Registrarse")),
    );
  }

  Future<UserCredential?> crearUsuario(String email, String passwd) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: passwd);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        mostrarSnackBar("El correo ya se encuentra en uso");
      } else if (e.code == 'weak-password') {
        mostrarSnackBar("Contraseña débil");
      } else if (e.code == 'invalid-email') {
        mostrarSnackBar("El correo proporcionado no es válido");
      } else {
        mostrarSnackBar("Ocurrió un error desconocido");
      }
      return null;
    }
  }

  Widget botonInicioGoogle() {
    return FractionallySizedBox(
      widthFactor: 0.6,
      child: ElevatedButton(
          onPressed: () async {
            setState(() {
              isLoading = true;
            });
            UserCredential? credenciales = await iniciarConGoogle();
            setState(() {
              isLoading = false;
            });
            if (credenciales != null && credenciales.user != null) {
              mostrarSnackBar("Inicio de sesión exitoso con Google.");
            }
          },
          child: Text("Iniciar con Google")),
    );
  }

  Future<UserCredential?> iniciarConGoogle() async {
    try {
      await googleSignIn.signOut();

      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();
      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );
        UserCredential credenciales =
            await FirebaseAuth.instance.signInWithCredential(credential);

        if (credenciales.user != null) {
          String email = credenciales.user!.email!;
          if (email.endsWith("@gmail.com")) {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => MyHomePage()),
                (route) => false);
            mostrarSnackBar("Inicio de sesión exitoso con Google.");
          } else {
            navegarAVista();
          }
        }
        return credenciales;
      }
    } catch (error) {
      mostrarSnackBar("Error al iniciar sesión con Google.");
      return null;
    }
  }

  void navegarAVista() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => VistaExitosa()));
  }

  void mostrarSnackBar(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        duration: Duration(seconds: 4),
      ),
    );
  }
}
