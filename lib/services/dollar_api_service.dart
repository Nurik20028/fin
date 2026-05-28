import 'package:dio/dio.dart';
import 'package:finance/services/dio_client.dart';

class DollarApiService {
  final Dio _dio = DioClient.getDio();
  Future<double> getDollarCourse() async {
    try {
      print('Debug: Starting API call to fx.kg...');
      final response = await _dio.get(
          '/api/v1/average',
          options: Options(
              headers: {'Authorization': 'Bearer 85a0e89254c3c699857e01d36a2b962b'},
          ),
      );
      print('Debug: Response: ${response.data}');
      var rawValue = response.data['buy_usd'] ?? response.data['average_buy'];
      if (rawValue != null) {
        return double.tryParse(rawValue.toString()) ?? 0.0;
      } else {
        throw Exception('USD key not found in response');
      }
    } on DioException catch (e) {
      print('Network Error: ${e.message}');
      print('Status Code: ${e.response?.statusCode}');
      print('Error Data: ${e.response?.data}');
      rethrow;
    } catch (e) {
      print('Parsing Error: $e');
      rethrow;
    }
  }
}
