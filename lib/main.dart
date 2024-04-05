import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: Colors.lightBlue[100],
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> countries = ['London', 'Paris', 'New York', 'Tokyo', 'Berlin', 'Moscow', 'Rome', 'Sydney'];
  late List<String> filteredCountries;
  List<String> secrets = [];

  @override
  void initState() {
    super.initState();
    filteredCountries = countries;
  }

  void _filterCountries(String query) {
    setState(() {
      if (query == 'admin') {
        // Navigate to the secret text page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SecretTextPage(
              onAddSecret: (secret) {
                setState(() {
                  secrets.add(secret);
                });
              },
            ),
          ),
        );
      } else {
        // Filter countries normally
        filteredCountries = countries.where((country) => country.toLowerCase().contains(query.toLowerCase())).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather App'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search country...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: _filterCountries,
            ),
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: filteredCountries.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailedWeatherScreen(city: filteredCountries[index]),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 5,
                    child: Center(
                      child: Text(
                        filteredCountries[index],
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 20),
          // Secret button appears only if 'admin' is entered in the search box
          if (secrets.isNotEmpty && filteredCountries.isEmpty)
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SecretListPage(secrets: secrets),
                  ),
                );
              },
              child: Text('View Secrets'),
            ),
        ],
      ),
    );
  }
}

class DetailedWeatherScreen extends StatefulWidget {
  final String city;

  DetailedWeatherScreen({required this.city});

  @override
  _DetailedWeatherScreenState createState() => _DetailedWeatherScreenState();
}

class _DetailedWeatherScreenState extends State<DetailedWeatherScreen> {
  late Future<WeatherData> futureWeatherData;

  @override
  void initState() {
    super.initState();
    futureWeatherData = fetchWeatherData(widget.city);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather Details - ${widget.city}'),
      ),
      body: FutureBuilder<WeatherData>(
        future: futureWeatherData,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return WeatherDetails(weatherData: snapshot.data!);
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}

class WeatherDetails extends StatelessWidget {
  final WeatherData weatherData;

  WeatherDetails({required this.weatherData});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      margin: EdgeInsets.all(20),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('City: ${weatherData.city}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text('Temperature: ${weatherData.temperature}°C'),
            SizedBox(height: 10),
            Text('Description: ${weatherData.description}'),
            SizedBox(height: 10),
            Text('Humidity: ${weatherData.humidity}%'),
            SizedBox(height: 10),
            Text('Wind Speed: ${weatherData.windSpeed} m/s'),
            SizedBox(height: 10),
            Text('Min Temperature: ${weatherData.minTemperature}°C'),
            SizedBox(height: 10),
            Text('Max Temperature: ${weatherData.maxTemperature}°C'),
            SizedBox(height: 10),
            Text('Pressure: ${weatherData.pressure} hPa'),
            SizedBox(height: 10),
            Text('Visibility: ${weatherData.visibility} meters'),
            SizedBox(height: 10),
            Text('Sunrise: ${DateTime.fromMillisecondsSinceEpoch(weatherData.sunrise * 1000)}'),
            SizedBox(height: 10),
            Text('Sunset: ${DateTime.fromMillisecondsSinceEpoch(weatherData.sunset * 1000)}'),
          ],
        ),
      ),
    );
  }
}

class WeatherData {
  final String city;
  final double temperature;
  final String description;
  final int humidity;
  final double windSpeed;
  final double minTemperature;
  final double maxTemperature;
  final int pressure;
  final int visibility;
  final int sunrise;
  final int sunset;

  WeatherData({
    required this.city,
    required this.temperature,
    required this.description,
    required this.humidity,
    required this.windSpeed,
    required this.minTemperature,
    required this.maxTemperature,
    required this.pressure,
    required this.visibility,
    required this.sunrise,
    required this.sunset,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      city: json['name'],
      temperature: json['main']['temp'].toDouble(),
      description: json['weather'][0]['description'],
      humidity: json['main']['humidity'],
      windSpeed: json['wind']['speed'].toDouble(),
      minTemperature: json['main']['temp_min'].toDouble(),
      maxTemperature: json['main']['temp_max'].toDouble(),
      pressure: json['main']['pressure'],
      visibility: json['visibility'],
      sunrise: json['sys']['sunrise'],
      sunset: json['sys']['sunset'],
    );
  }
}

Future<WeatherData> fetchWeatherData(String city) async {
  final apiKey = 'b5fe7bf360c7cce65110619bf0bdbba0';
  final url = 'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric';

  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    return WeatherData.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to load weather data');
  }
}

class SecretTextPage extends StatefulWidget {
  final Function(String) onAddSecret;

  SecretTextPage({required this.onAddSecret});

  @override
  _SecretTextPageState createState() => _SecretTextPageState();
}

class _SecretTextPageState extends State<SecretTextPage> {
  String secretText = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Secret Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              onChanged: (text) {
                setState(() {
                  secretText = text;
                });
              },
              decoration: InputDecoration(
                hintText: 'Enter secret text...',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                widget.onAddSecret(secretText);
                Navigator.pop(context);
              },
              child: Text('Save Secret Text'),
            ),
          ],
        ),
      ),
    );
  }
}

class SecretListPage extends StatelessWidget {
  final List<String> secrets;

  SecretListPage({required this.secrets});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Secrets'),
      ),
      body: ListView.builder(
        itemCount: secrets.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(secrets[index]),
          );
        },
      ),
    );
  }
}
