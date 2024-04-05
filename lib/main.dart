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
  final List<String> countries = [
    'London',
    'Paris',
    'New York',
    'Tokyo',
    'Berlin',
    'Moscow',
    'Rome',
    'Sydney',
    'Madrid',
    'Beijing',
    'Cairo',
    'Rio de Janeiro'
  ];
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
        _navigateToSecretListPage();
      } else {
        filteredCountries = countries
            .where((country) =>
                country.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _navigateToSecretListPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SecretListPage(
          secrets: secrets,
          onAddSecret: _addSecret,
          onDeleteSecret: _deleteSecret,
          onEditSecret: _editSecret,
        ),
      ),
    );
  }

  void _addSecret(String title, String message) {
    setState(() {
      secrets.add('$title: $message');
    });
  }

  void _deleteSecret(int index) {
    setState(() {
      secrets.removeAt(index);
    });
  }

  void _editSecret(int index, String title, String message) {
    setState(() {
      secrets[index] = '$title: $message';
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
                        builder: (context) =>
                            DetailedWeatherScreen(city: filteredCountries[index]),
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
            Text('City: ${weatherData.city}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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

class SecretListPage extends StatefulWidget {
  final List<String> secrets;
  final Function(String, String) onAddSecret;
  final Function(int, String, String) onEditSecret;
  final Function(int) onDeleteSecret;

  SecretListPage({
    required this.secrets,
    required this.onAddSecret,
    required this.onEditSecret,
    required this.onDeleteSecret,
  });

  @override
  _SecretListPageState createState() => _SecretListPageState();
}

class _SecretListPageState extends State<SecretListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Secrets'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              _navigateToSecretTextPage(context);
            },
          ),
        ],
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: widget.secrets.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 5,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(widget.secrets[index]),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          _deleteSecret(index);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          _navigateToEditSecretTextPage(context, index);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _navigateToSecretTextPage(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SecretTextPage(),
      ),
    );
    if (result != null && result is Map<String, String>) {
      widget.onAddSecret(result['title']!, result['message']!);
    }
  }

  void _navigateToEditSecretTextPage(BuildContext context, int index) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditSecretTextPage(
          title: widget.secrets[index].split(':')[0],
          message: widget.secrets[index].split(':')[1],
        ),
      ),
    );
    if (result != null && result is Map<String, String>) {
      widget.onEditSecret(index, result['title']!, result['message']!);
    }
  }

  void _deleteSecret(int index) {
    setState(() {
      widget.onDeleteSecret(index);
    });
  }
}

class SecretTextPage extends StatefulWidget {
  @override
  _SecretTextPageState createState() => _SecretTextPageState();
}

class _SecretTextPageState extends State<SecretTextPage> {
  late TextEditingController _titleController;
  late TextEditingController _messageController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _messageController = TextEditingController();
  }

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
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Enter secret title...',
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Enter secret message...',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _saveSecret();
              },
              child: Text('Save Secret'),
            ),
          ],
        ),
      ),
    );
  }

  void _saveSecret() {
    final title = _titleController.text.trim();
    final message = _messageController.text.trim();
    if (title.isNotEmpty && message.isNotEmpty) {
      Navigator.pop(context, {'title': title, 'message': message});
    } else {
      // Show error message or handle invalid input
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }
}

class EditSecretTextPage extends StatefulWidget {
  final String title;
  final String message;

  EditSecretTextPage({required this.title, required this.message});

  @override
  _EditSecretTextPageState createState() => _EditSecretTextPageState();
}

class _EditSecretTextPageState extends State<EditSecretTextPage> {
  late TextEditingController _titleController;
  late TextEditingController _messageController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.title);
    _messageController = TextEditingController(text: widget.message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Secret'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Edit secret title...',
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Edit secret message...',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _saveEditedSecret();
              },
              child: Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  void _saveEditedSecret() {
    final newTitle = _titleController.text.trim();
    final newMessage = _messageController.text.trim();
    if (newTitle.isNotEmpty && newMessage.isNotEmpty) {
      Navigator.pop(context, {'title': newTitle, 'message': newMessage});
    } else {
      // Show error message or handle invalid input
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }
}
