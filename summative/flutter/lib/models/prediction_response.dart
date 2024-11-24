// lib/models/prediction_response.dart
class PredictionResponse {
  final String status;
  final Predictions predictions;
  final Analysis analysis;
  final Metadata metadata;
  

  PredictionResponse({
    required this.status,
    required this.predictions,
    required this.analysis,
    required this.metadata,
  });

  factory PredictionResponse.fromJson(Map<String, dynamic> json) {
    return PredictionResponse(
      status: json['status'],
      predictions: Predictions.fromJson(json['predictions']),
      analysis: Analysis.fromJson(json['analysis']),
      metadata: Metadata.fromJson(json['metadata']),
    );
  }
}

class Predictions {
  final CurrencyPrediction usd;
  final CurrencyPrediction kes;

  Predictions({required this.usd, required this.kes});

  factory Predictions.fromJson(Map<String, dynamic> json) {
    return Predictions(
      usd: CurrencyPrediction.fromJson(json['usd']),
      kes: CurrencyPrediction.fromJson(json['kes']),
    );
  }
}

class CurrencyPrediction {
  final double price;


  CurrencyPrediction({required this.price});

  factory CurrencyPrediction.fromJson(Map<String, dynamic> json) {
    return CurrencyPrediction(
      price: json['price'].toDouble(),
    );
  }
}

class Analysis {
  final double currentRollingAverage;
  final double priceVolatility;
  final double priceToUsdRatio;
  final String priceTrend;
  final double priceDifferencePercent;

  Analysis({
    required this.currentRollingAverage,
    required this.priceVolatility,
    required this.priceToUsdRatio,
    required this.priceTrend,
    required this.priceDifferencePercent,
  });

  factory Analysis.fromJson(Map<String, dynamic> json) {
    return Analysis(
      currentRollingAverage: json['current_rolling_average'].toDouble(),
      priceVolatility: json['price_volatility'].toDouble(),
      priceToUsdRatio: json['price_to_usd_ratio'].toDouble(),
      priceTrend: json['price_trend'],
      priceDifferencePercent: json['price_difference_percent'].toDouble(),
    );
  }
}

class Metadata {
  final String predictionDate;
  final Location location;
  final String priceType;

  Metadata({
    required this.predictionDate,
    required this.location,
    required this.priceType,
  });

  factory Metadata.fromJson(Map<String, dynamic> json) {
    return Metadata(
      predictionDate: json['prediction_date'],
      location: Location.fromJson(json['location']),
      priceType: json['price_type'],
    );
  }
}

class Location {
  final double latitude;
  final double longitude;
  final String cluster;

  Location({
    required this.latitude,
    required this.longitude,
    required this.cluster,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      cluster: json['cluster'],
    );
  }
}