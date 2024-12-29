import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl;

  ApiService({this.baseUrl = 'http://localhost:8089'});

  Future<Map<String, dynamic>> classifyImage(Uint8List imageBytes) async {
    try {
      // Create multipart request
      final uri = Uri.parse('$baseUrl/predict');
      var request = http.MultipartRequest('POST', uri);

      // Add the image file to the request
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          imageBytes,
          filename: 'image.jpg',
        ),
      );

      // Send the request
      final response = await request.send();
      final responseString = await response.stream.bytesToString();

      if (response.statusCode != 200) {
        throw Exception('Failed to classify image: ${response.statusCode}\n$responseString');
      }

      // Parse the response
      final Map<String, dynamic> result = json.decode(responseString);

      // Convert to match your existing format
      return {
        'topPrediction': {
          'label': result['class'],
          'confidence': _parseConfidence(result['confidence']),
        },
        'top3Predictions': [
          {
            'label': result['class'],
            'confidence': _parseConfidence(result['confidence']),
          }
        ],
      };
    } catch (e) {
      throw Exception('Failed to classify image: $e');
    }
  }

  double _parseConfidence(String confidenceStr) {
    // Convert "95.5%" to 0.955
    return double.parse(confidenceStr.replaceAll('%', '')) / 100;
  }
}