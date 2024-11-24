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