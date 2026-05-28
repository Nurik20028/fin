import 'package:dio/dio.dart';

class DioClient{
  static const String baseurl = "https://data.fx.kg";
  static final Dio _dio = _createDio();

  static Dio _createDio() {
    Dio dio = Dio(
        BaseOptions(
            baseUrl: baseurl,
            connectTimeout: Duration(seconds: 3),
            receiveTimeout: Duration(seconds: 3),
            sendTimeout: Duration(seconds: 3),
            responseType: ResponseType.json,
        ),
    );


    dio.interceptors.add(
        InterceptorsWrapper(
            onRequest: (options, handler) {
              print(
                  "--> [DIO] REQUEST[${options.method}] => PATH: ${options.path}",
              );
              return handler.next(options);
            },
            onResponse: (response, handler) {
              print(
                  "<-- [DIO] RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}",
              );
              return handler.next(response);
            },
            onError: (DioException e, handler) {
              print(
                  "<-- [DIO] ERROR[${e.response?.statusCode}] => MESSAGE: ${e.message}",
              );
              return handler.next(e);
            },
        ),
    );
    return dio;
  }

  static Dio get instance => _dio;
  static Dio getDio() => _dio;

}

