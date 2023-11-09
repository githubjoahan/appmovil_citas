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
          title: Text('Registrar Cita Médica'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                title: Text('Fecha de la Cita: ${_selectedDate.toLocal()}'
                    .split(' ')[0]),
                trailing: Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
              ListTile(
                title:
                    Text('Hora de la Cita: ${_selectedTime.format(context)}'),
                trailing: Icon(Icons.access_time),
                onTap: () => _selectTime(context),
              ),
              TextField(
                controller: _razonController,
                decoration: InputDecoration(
                  labelText: 'Razón de la Cita',
                  icon: Icon(Icons.note),
                ),
              ),
            ],
            
          ),
          

actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Agregar'),
              onPressed: () async {
                CollectionReference citas =
                    FirebaseFirestore.instance.collection('citas');
                DateTime finalDateTime = DateTime(
                  _selectedDate.year,
                  _selectedDate.month,
                  _selectedDate.day,
                  _selectedTime.hour,
                  _selectedTime.minute,
                );
                // Agrega el 'uid' al documento de la cita
                await citas.add({
                  'fecha_hora': finalDateTime,
                  'razon': _razonController.text,
                  'uid': FirebaseAuth.instance.currentUser
                      ?.uid, // Asegúrate de que esto se añada
                });
                _razonController.clear();
                Navigator.of(context).pop();
              },
            ),
          ],

        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     
appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        title: Text("AGENDA DE CITAS MEDICAS"),
        centerTitle: true,
      ),
      drawer: _buildDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(height: 50.0),
            Image.network(
              "https://play-lh.googleusercontent.com/A9kmwxo2f7DyIa3c6QCq3-mCQ3MenMPzQ5w8BBmdXs2KJEH1WIchR2ncM9uSACdXinn6", // Insertar el URL del logo aquí
              height: 150.0,
              width: 150.0,
            ),
            SizedBox(height: 40.0),
            _buildOptionCard(
                icon: Icons.calendar_today,
                title: "Agendar Cita",
                subtitle: "Le permite agendar citas medicas",
                onTap: _showAddCitaDialog),
          ],
        ),
      ),
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
