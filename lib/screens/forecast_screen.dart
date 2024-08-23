import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ForecastScreen extends StatefulWidget {
  @override
  _ForecastScreenState createState() => _ForecastScreenState();
}

class _ForecastScreenState extends State<ForecastScreen> {
  Location location = Location();
  final String _apiKey = '06968c7563f4ece42f9b92753b3a6809';
  Future<Map<String, dynamic>>? _weatherDataFuture;

  @override
  void initState() {
    super.initState();
    _weatherDataFuture = _getLocationAndWeather();
  }

  Future<Map<String, dynamic>> _getLocationAndWeather() async {
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled)
        throw Exception("El servicio de localización está deshabilitado.");
    }

    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        throw Exception("Permiso de localización denegado.");
      }
    }

    LocationData locationData = await location.getLocation();
    final url = Uri.parse(
      'https://api.openweathermap.org/data/2.5/weather?lat=${locationData.latitude}&lon=${locationData.longitude}&appid=$_apiKey&units=metric',
    );

    final response = await http.get(url);
    if (response.statusCode != 200) {
      throw Exception(
          'Error al obtener los datos del clima: ${response.statusCode}');
    }

    Map<String, dynamic> weatherData = jsonDecode(response.body);

    List<Map<String, dynamic>> forecast = List.generate(3, (index) {
      return {
        'day': 'Día ${index + 1}',
        'temp': weatherData['main']['temp'] + index * 2.0,
        'temp_min':
            weatherData['main']['temp_min'] - index * 1.0, // Ajuste simulado
        'temp_max':
            weatherData['main']['temp_max'] + index * 1.0, // Ajuste simulado
        'description':
            _translateDescription(weatherData['weather'][0]['description']),
        'icon': weatherData['weather'][0]['icon'],
      };
    });

    return {
      'current': weatherData,
      'forecast': forecast,
    };
  }

  String _translateDescription(String description) {
    Map<String, String> translations = {
      "clear sky": "cielo despejado",
      "few clouds": "pocas nubes",
      "scattered clouds": "nubes dispersas",
      "broken clouds": "nubes rotas",
      "shower rain": "lluvia ligera",
      "rain": "lluvia",
      "thunderstorm": "tormenta",
      "snow": "nieve",
      "mist": "niebla",
    };

    return translations[description.toLowerCase()] ?? description;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[100],
      appBar: AppBar(
        title: const Text("Pronostico en 3 dias"),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blue[900],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _weatherDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                strokeWidth: 10,
              ),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('No se encontraron datos.'));
          } else {
            final weatherData = snapshot.data!;
            final forecast = weatherData['forecast'];
            final thirdDay = forecast[2];

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: Container(
                    width: 250,
                    height: 250,
                    child: Image.network(
                      'http://openweathermap.org/img/wn/${thirdDay['icon']}@2x.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Min: ${thirdDay['temp_min']}°C  Max: ${thirdDay['temp_max']}°C',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 10),
                Text(
                  '${thirdDay['description']}',
                  style: TextStyle(fontSize: 18),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Volver al inicio"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[900],
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
