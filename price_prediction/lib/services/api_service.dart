import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/prediction_request.dart';
import '../models/prediction_response.dart';

class ApiService {
  static const String baseUrl = 'https://linear-regression-model-0kqu.onrender.com';

  Future<PredictionResponse> getPrediction(PredictionRequest request) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/predict'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        return PredictionResponse.fromJson(jsonDecode(response.body));
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail']['message'] ?? 'Failed to get prediction');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server: $e');
    }
  }
}
