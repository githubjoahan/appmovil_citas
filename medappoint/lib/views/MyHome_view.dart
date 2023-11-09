import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medappoint/views/login_view.dart';
import 'package:medappoint/views/MisCitasPage.dart';
import 'package:medappoint/views/AppInfoPage.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  TextEditingController _razonController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _showAddCitaDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
         
          content: Column(
            mainAxisSize: MainAxisSize.min,

            //children
            
          ),
          

          //actions:

        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text(currentUser?.displayName ??
                'Nombre no disponible'), // Usamos el nombre del usuario actual
            accountEmail: Text(currentUser?.email ??
                'Email no disponible'), // Usamos el email del usuario actual
          ),
          ListTile(
            leading: Icon(Icons.calendar_today),
            title: Text('Mis Citas'),
            onTap: () {
              Navigator.of(context).pop(); // Para cerrar el drawer
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => MisCitasPage(),
              ));
            },
          ),
          ListTile(
            leading: Icon(Icons.app_registration),
            title: Text('Inf. de la APP'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AppInfoPage(),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Salir'),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) =>
                    LoginPage(), // Supongo que quieres redirigir al usuario a la vista de inicio de sesión después de cerrar sesión
              ));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: ListTile(
        leading: Icon(icon, size: 40.0),
        title: Text(title),
        subtitle: Text(subtitle),
        onTap: onTap,
      ),
    );
  }
}
