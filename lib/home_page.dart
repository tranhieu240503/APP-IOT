import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'dart:convert';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'light_control_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late MqttServerClient client;
  double temperature = 0.0;
  double humidity = 0.0;

  @override
  void initState() {
    super.initState();

   
    client = MqttServerClient('broker.emqx.io', 'flutter_client');
    client.port = 1883;

    client.onDisconnected = _onDisconnected;
    _connectToMqttBroker();
  }

  void _connectToMqttBroker() async {
    try {
      await client.connect();
      print('Connected to MQTT broker');

      client.subscribe('temperature_humidity', MqttQos.atMostOnce);

     
      client.updates?.listen((List<MqttReceivedMessage<MqttMessage>> messages) {
        final MqttPublishMessage message = messages[0].payload as MqttPublishMessage;
        final String payload = MqttPublishPayload.bytesToStringAsString(message.payload.message!);

        print('Received message: $payload');

        try {
          final Map<String, dynamic> data = jsonDecode(payload);
          setState(() {
            temperature = double.parse(data['temperature'].toString());
            humidity = double.parse(data['humidity'].toString());
          });
        } catch (e) {
          print('Error parsing MQTT message: $e');
        }
      });
    } catch (e) {
      print('Failed to connect to MQTT broker: $e');
    }
  }

  void _onDisconnected() {
    print('Disconnected from MQTT broker');
   
    Future.delayed(const Duration(seconds: 5), () {
      _connectToMqttBroker();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Smart Home Control'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                
              },
              child: Text('Refresh Temperature & Humidity'),
            ),
            SizedBox(height: 20),
            Text(
              'Current Temperature: ${temperature.toStringAsFixed(2)} °C',
              style: TextStyle(fontSize: 24),
            ),
            Text(
              'Current Humidity: ${humidity.toStringAsFixed(2)} %',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ControlLightPage()),
                );
              },
              child: Text('Open Light Control'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    client.disconnect();
    super.dispose();
  }
}
