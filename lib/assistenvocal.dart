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
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const CircleAvatar(
              radius: 60,
              backgroundColor: Colors.blueAccent,
              child: Icon(
                Icons.mic,
                size: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10), // Moins d'espace
            const Text(
              'Tap to Talk',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 15), // Moins d'espace
            // Zone de texte pour les mots reconnus
            TextField(
              controller: TextEditingController(text: _lastWords),
              readOnly: true,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Recognized speech will appear here...',
                filled: true,
                fillColor: Colors.transparent,
                border: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Colors.blueAccent,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 15),
            // Zone de texte pour la réponse de l'API (avec scroll)
            Expanded(
              child: SingleChildScrollView(
                child: TextField(
                  controller: TextEditingController(text: _apiResponse),
                  readOnly: true,
                  maxLines: null, // Permet un contenu extensible
                  decoration: InputDecoration(
                    hintText: 'API response will appear here...',
                    filled: true,
                    fillColor: Colors.transparent,
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.green,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
            // Bouton flottant pour démarrer/arrêter l'enregistrement vocal
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
    );
  }
}
