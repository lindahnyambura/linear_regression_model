import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/prediction_provider.dart';
import '../widgets/prediction_form.dart';
import '../widgets/prediction_results.dart';

class PredictionScreen extends ConsumerWidget {
  const PredictionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final predictionState = ref.watch(predictionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Price Prediction'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const PredictionForm(),
              const SizedBox(height: 20),
              if (predictionState.isLoading)
                const Center(child: CircularProgressIndicator()),
              if (predictionState.error != null)
                Card(
                  color: Colors.red.shade100,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      predictionState.error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ),
              if (predictionState.prediction != null)
                PredictionResult(prediction: predictionState.prediction!),
            ],
          ),
        ),
      ),
    );
  }
}

// lib/models/prediction_request.dart
class PredictionRequest {
  final double latitude;
  final double longitude;
  final String date;
  final String pricetype;
  final String currency;
  final String locationCluster;
  final double priceToUsdRatio;
  final double rollingAvgPrice;
  final double priceVolatility;
  final int admin1Encoded;
  final int admin2Encoded;
  final int marketEncoded;
  final int categoryEncoded;
  final int commodityEncoded;
  final int unitEncoded;
  final int priceflagEncoded;
  final int priceCategoryEncoded;

  PredictionRequest({
    required this.latitude,
    required this.longitude,
    required this.date,
    required this.pricetype,
    required this.currency,
    required this.locationCluster,
    required this.priceToUsdRatio,
    required this.rollingAvgPrice,
    required this.priceVolatility,
    required this.admin1Encoded,
    required this.admin2Encoded,
    required this.marketEncoded,
    required this.categoryEncoded,
    required this.commodityEncoded,
    required this.unitEncoded,
    required this.priceflagEncoded,
    required this.priceCategoryEncoded,
  });

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        'date': date,
        'pricetype': pricetype,
        'currency': currency,
        'location_cluster': locationCluster,
        'price_to_usd_ratio': priceToUsdRatio,
        'rolling_avg_price': rollingAvgPrice,
        'price_volatility': priceVolatility,
        'admin1_encoded': admin1Encoded,
        'admin2_encoded': admin2Encoded,
        'market_encoded': marketEncoded,
        'category_encoded': categoryEncoded,
        'commodity_encoded': commodityEncoded,
        'unit_encoded': unitEncoded,
        'priceflag_encoded': priceflagEncoded,
        'price_category_encoded': priceCategoryEncoded,
      };
}