import 'package:aplicacion_clima/screens/forecast_screen.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PrincipalScreen extends StatefulWidget {
  @override
  _PrincipalScreenState createState() => _PrincipalScreenState();
}

class _PrincipalScreenState extends State<PrincipalScreen> {
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

    return jsonDecode(response.body);
  }

  void _refreshWeatherData() {
    setState(() {
      _weatherDataFuture = _getLocationAndWeather();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Clima actual"),
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
            final weather = weatherData['weather'][0];
            final main = weatherData['main'];
            final coord = weatherData['coord'];

            final iconCode = weather['icon'];
            final temperature = main['temp'];
            final description = weather['description'];
            final latitude = coord['lat'];
            final longitude = coord['lon'];

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.network(
                      'http://openweathermap.org/img/wn/$iconCode.png',
                      width: 50,
                      height: 50,
                    ),
                    SizedBox(width: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Clima actual: ${temperature}°C, ${description}',
                      style: TextStyle(fontSize: 20),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _refreshWeatherData,
                  child: const Text("Actualizar"),
                ),
                SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ForecastScreen(
                            weatherData: weatherData,
                          ),
                        ),
                      );
                    },
                    child: const Text("Pronóstico en 3 días"),
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
