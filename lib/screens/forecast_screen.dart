import 'package:flutter/material.dart';

class ForecastScreen extends StatefulWidget {
  final Map<String, dynamic> weatherData;

  ForecastScreen({required this.weatherData}); // Constructor que recibe el parámetro

  @override
  _ForecastScreenState createState() => _ForecastScreenState();
}

class _ForecastScreenState extends State<ForecastScreen> {
  @override
  Widget build(BuildContext context) {
    // Verificar que weatherData no sea null y contenga la clave 'daily'
    if (widget.weatherData == null || widget.weatherData['daily'] == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Clima en los próximos 3 días"),
          automaticallyImplyLeading: false,
        ),
        body: Center(
          child: Text('No hay datos disponibles.'),
        ),
      );
    }

    final daily = widget.weatherData['daily'];

    // Verificar que daily tenga al menos 4 elementos
    if (daily.length < 4) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Clima en los próximos 3 días"),
          automaticallyImplyLeading: false,
        ),
        body: Center(
          child: Text('No hay suficiente información para mostrar.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Clima en los próximos 3 días"),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Usando los datos pasados desde la pantalla principal
          Text('Día 1: ${daily[1]['temp']['day']}°C'),
          Text('Día 2: ${daily[2]['temp']['day']}°C'),
          Text('Día 3: ${daily[3]['temp']['day']}°C'),
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Volver al inicio"),
            ),
          ),
        ],
      ),
    );
  }
}
