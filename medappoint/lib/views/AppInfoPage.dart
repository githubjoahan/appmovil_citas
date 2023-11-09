import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AppInfoPage extends StatelessWidget {
  AppInfoPage({Key? key}) : super(key: key);

  final String appVersion =
      "1.0.0"; // Asegúrate de actualizar esto con tu versión actual de la aplicación
  final String releaseDate =
      "09 Noviembre 2023"; // Actualiza esto con la fecha de lanzamiento de tu aplicación
  final String supportEmail = "montejo1jwn@gmail.com"; // Correo de soporte

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Información de la APP'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.info),
            title: Text('Versión de la Aplicación'),
            subtitle: Text(appVersion),
          ),
          ListTile(
            leading: Icon(Icons.date_range),
            title: Text('Fechas de lanzamiento'),
            subtitle: Text(releaseDate),
          ),
          ListTile(
            leading: Icon(Icons.email),
            title: Text('Contacto y Soporte'),
            subtitle: Text(supportEmail),
            onTap: () async {
              final Uri emailLaunchUri = Uri(
                scheme: 'mailto',
                path: supportEmail,
                query: encodeQueryParameters(<String, String>{
                  'subject': 'Bienvenido al Soporte de la Aplicación'
                }),
              );

              // Añade esta línea para imprimir la URL en la consola
              print('Launching URL: ${emailLaunchUri.toString()}');

              if (await canLaunchUrl(emailLaunchUri)) {
                await launchUrl(emailLaunchUri);
              } else {
                // Solo intenta lanzar sin comprobar con canLaunchUrl
                try {
                  await launchUrl(emailLaunchUri);
                } catch (e) {
                  print('Could not launch $emailLaunchUri: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('No se pudo abrir el cliente de correo'),
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  String? encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }
}
