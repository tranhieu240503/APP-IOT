import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ControlLightPage extends StatefulWidget {
  @override
  _ControlLightPageState createState() => _ControlLightPageState();
}

class _ControlLightPageState extends State<ControlLightPage> {
  bool _isLightOn = false;

  void _toggleLight(bool turnOn) async {
    String status = turnOn ? "on" : "off";
    String apiUrl = "https://60b4e7d4fe923b0017c830cb.mockapi.io/api/v1/do-an-iot-smart-home/2";

    try {
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{'light': status}),
      );

      if (response.statusCode == 200) {
        setState(() {
          _isLightOn = turnOn;
        });
      } else {
        throw Exception('Failed to update light status');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Light Control'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            _isLightOn
                ? Image.asset(
                    'assets/light_on.png',
                    width: 100,
                    height: 100,
                  )
                : Image.asset(
                    'assets/light_offf.jpg', 
                    width: 100,
                    height: 100,
                  ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _toggleLight(!_isLightOn),
              child: Text(_isLightOn ? 'Turn Off Light' : 'Turn On Light'),
              style: ElevatedButton.styleFrom(
                primary: _isLightOn ? Colors.red : Colors.green,
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                textStyle: TextStyle(fontSize: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
