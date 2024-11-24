import 'package:flutter/material.dart';
import '../models/prediction_response.dart';

class PredictionResult extends StatelessWidget {
  final PredictionResponse prediction;

  const PredictionResult({super.key, required this.prediction});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Prediction Results',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const Divider(),
            _buildPriceSection('USD Price', prediction.predictions.usd),
            const SizedBox(height: 16),
            _buildPriceSection('KES Price', prediction.predictions.kes),
            const SizedBox(height: 16),
            const Divider(),
            Text(
              'Analysis',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            _buildAnalysisRow(
              'Price Trend',
              prediction.analysis.priceTrend.toUpperCase(),
              color: _getTrendColor(prediction.analysis.priceTrend),
            ),
            _buildAnalysisRow(
              'Price Change',
              '${prediction.analysis.priceDifferencePercent.toStringAsFixed(2)}%',
              color: _getTrendColor(prediction.analysis.priceTrend),
            ),
            _buildAnalysisRow(
              'Rolling Average',
              prediction.analysis.currentRollingAverage.toStringAsFixed(2),
            ),
            _buildAnalysisRow(
              'Volatility',
              prediction.analysis.priceVolatility.toStringAsFixed(2),
            ),
            _buildAnalysisRow(
              'USD Ratio',
              prediction.analysis.priceToUsdRatio.toStringAsFixed(2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceSection(String title, CurrencyPrediction prediction) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Price: ${prediction.price.toStringAsFixed(2)}',
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildAnalysisRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: color != null ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Color _getTrendColor(String trend) {
    switch (trend.toLowerCase()) {
      case 'increasing':
        return Colors.green;
      case 'decreasing':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }
}