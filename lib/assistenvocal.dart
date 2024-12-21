import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class Assistenvocal extends StatefulWidget {
  const Assistenvocal({super.key});

  @override
  State<Assistenvocal> createState() => _AssistenvocalState();
}

class _AssistenvocalState extends State<Assistenvocal> {
  SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';
  String _apiResponse = '';
  bool _isListening = false;

  final String _apiKey = "AIzaSyC6AbDoQaLVdTyGDXTtO7GeT6FJTFvmwBQ";

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  void _startListening() async {
    if (!_isListening) {
      await _speechToText.listen(onResult: _onSpeechResult);
      setState(() {
        _isListening = true;
      });
    }
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {
      _isListening = false;
    });

    if (_lastWords.isNotEmpty) {
      await _sendToGemini(_lastWords);
    }
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;
    });
  }

  Future<void> _sendToGemini(String prompt) async {
    try {
      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: _apiKey,
      );

      final response = await model.generateContent([Content.text(prompt)]);

      setState(() {
        _apiResponse = response.text ?? 'No response from the model';
      });
    } catch (e) {
      setState(() {
        _apiResponse = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Assistant'),
        backgroundColor: Colors.blueAccent,
        elevation: 2,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade200, Colors.blueAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              // Logo above the "Tap to Talk" text
              Image.asset(
                'assets/pngegg.png', // Path to your logo
                height: 140, // Adjust size as needed
              ),
              const SizedBox(height: 20),

              const SizedBox(height: 20),
              const Text(
                'Tap to Talk',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              // Recognized Speech Display
              _buildTextField(
                value: _lastWords,
                hintText: 'Recognized speech will appear here...',
                borderColor: Colors.blueAccent,
              ),
              const SizedBox(height: 20),
              // API Response Display
              Expanded(
                child: SingleChildScrollView(
                  child: _buildTextField(
                    value: _apiResponse,
                    hintText: 'API response will appear here...',
                    borderColor: Colors.greenAccent,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Floating Button
              FloatingActionButton(
                onPressed: () {
                  if (_isListening) {
                    _stopListening();
                  } else {
                    _startListening();
                  }
                },
                child: Icon(
                  _isListening ? Icons.stop : Icons.mic,
                  color: Colors.white,
                  size: 30,
                ),
                backgroundColor: Colors.blueAccent,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String value,
    required String hintText,
    required Color borderColor,
  }) {
    return TextField(
      controller: TextEditingController(text: value),
      readOnly: true,
      maxLines: null,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.blue.shade50.withOpacity(0.3),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: borderColor, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      style: const TextStyle(color: Colors.white, fontSize: 16),
    );
  }
}
