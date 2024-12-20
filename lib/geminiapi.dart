import 'package:google_generative_ai/google_generative_ai.dart';

final String _apiKey="AIzaSyC6AbDoQaLVdTyGDXTtO7GeT6FJTFvmwBQ";

Future<String?>  geminiapirequest(String prompt) async{
  final model = GenerativeModel(
    model: 'gemini-1.5-flash',
    apiKey: _apiKey,
  );

  final prompt = 'Write a story about a magic backpack.';
  final response = await model.generateContent([Content.text(prompt)]);

  print(response.text);
  return response.text;
}


