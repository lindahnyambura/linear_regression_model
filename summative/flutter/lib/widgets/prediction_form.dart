import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/prediction_request.dart';
import '../providers/prediction_provider.dart';

class PredictionForm extends ConsumerStatefulWidget {
  const PredictionForm({super.key});

  @override
  ConsumerState<PredictionForm> createState() => _PredictionFormState();
}

class _PredictionFormState extends ConsumerState<PredictionForm> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  
  // Form fields
  double? latitude;
  double? longitude;
  String? locationCluster;
  String priceType = 'Retail';
  String currency = 'USD';
  double? priceToUsdRatio;
  double? rollingAvgPrice;
  double? priceVolatility;
  
  // Encoded values
  int admin1Encoded = 0;
  int admin2Encoded = 0;
  int marketEncoded = 0;
  int categoryEncoded = 0;
  int commodityEncoded = 0;
  int unitEncoded = 0;
  int priceflagEncoded = 0;
  int priceCategoryEncoded = 0;

  final List<String> locationClusters = ['urban', 'suburban', 'rural'];
  final List<String> priceTypes = ['Retail', 'Wholesale'];
  final List<String> currencies = ['USD', 'KES'];

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      final request = PredictionRequest(
        latitude: latitude!,
        longitude: longitude!,
        date: _dateController.text,
        pricetype: priceType,
        currency: currency,
        locationCluster: locationCluster ?? 'urban',
        priceToUsdRatio: priceToUsdRatio!,
        rollingAvgPrice: rollingAvgPrice!,
        priceVolatility: priceVolatility!,
        admin1Encoded: admin1Encoded,
        admin2Encoded: admin2Encoded,
        marketEncoded: marketEncoded,
        categoryEncoded: categoryEncoded,
        commodityEncoded: commodityEncoded,
        unitEncoded: unitEncoded,
        priceflagEncoded: priceflagEncoded,
        priceCategoryEncoded: priceCategoryEncoded,
      );

      ref.read(predictionProvider.notifier).getPrediction(request);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            decoration: const InputDecoration(labelText: 'Latitude'),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Required';
              final lat = double.tryParse(value);
              if (lat == null || lat < -90 || lat > 90) {
                return 'Invalid latitude';
              }
              latitude = lat;
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Longitude'),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Required';
              final lon = double.tryParse(value);
              if (lon == null || lon < -180 || lon > 180) {
                return 'Invalid longitude';
              }
              longitude = lon;
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _dateController,
            decoration: const InputDecoration(
              labelText: 'Date',
              hintText: 'YYYY-MM-DD',
              suffixIcon: Icon(Icons.calendar_today),
            ),
            readOnly: true,
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime(2025),
              );
              if (date != null) {
                _dateController.text = DateFormat('yyyy-MM-dd').format(date);
              }
            },
            validator: (value) =>
                value?.isEmpty ?? true ? 'Please select a date' : null,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: locationCluster ?? locationClusters.first,
            decoration: const InputDecoration(labelText: 'Location Cluster'),
            items: locationClusters
                .map((cluster) => DropdownMenuItem(
                      value: cluster,
                      child: Text(cluster),
                    ))
                .toList(),
            onChanged: (value) => setState(() => locationCluster = value),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: priceType,
            decoration: const InputDecoration(labelText: 'Price Type'),
            items: priceTypes
                .map((type) => DropdownMenuItem(
                      value: type,
                      child: Text(type),
                    ))
                .toList(),
            onChanged: (value) => setState(() => priceType = value!),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: currency,
            decoration: const InputDecoration(labelText: 'Currency'),
            items: currencies
                .map((curr) => DropdownMenuItem(
                      value: curr,
                      child: Text(curr),
                    ))
                .toList(),
            onChanged: (value) => setState(() => currency = value!),
          ),
          const SizedBox(height: 16),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Price to USD Ratio'),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Required';
              final ratio = double.tryParse(value);
              if (ratio == null || ratio <= 0) {
                return 'Invalid ratio';
              }
              priceToUsdRatio = ratio;
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Rolling Average Price'),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Required';
              final avg = double.tryParse(value);
              if (avg == null || avg < 0) {
                return 'Invalid average price';
              }
              rollingAvgPrice = avg;
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Price Volatility'),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Required';
              final vol = double.tryParse(value);
              if (vol == null || vol < 0) {
                return 'Invalid volatility';
              }
              priceVolatility = vol;
              return null;
            },
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _submitForm,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Get Prediction'),
          ),
        ],
      ),
    );
  }
}