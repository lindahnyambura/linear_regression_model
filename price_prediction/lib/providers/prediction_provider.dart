import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/prediction_response.dart';
import '../services/api_service.dart';
import '../models/prediction_request.dart';

class PredictionState {
  final bool isLoading;
  final String? error;
  final PredictionResponse? prediction;

  PredictionState({
    this.isLoading = false,
    this.error,
    this.prediction,
  });

  PredictionState copyWith({
    bool? isLoading,
    String? error,
    PredictionResponse? prediction,
  }) {
    return PredictionState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      prediction: prediction ?? this.prediction,
    );
  }
}

class PredictionNotifier extends StateNotifier<PredictionState> {
  final ApiService _apiService;

  PredictionNotifier(this._apiService) : super(PredictionState());

  Future<void> getPrediction(PredictionRequest request) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final prediction = await _apiService.getPrediction(request);
      state = state.copyWith(
        isLoading: false,
        prediction: prediction,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}

final apiServiceProvider = Provider((ref) => ApiService());

final predictionProvider =
    StateNotifierProvider<PredictionNotifier, PredictionState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return PredictionNotifier(apiService);
});
