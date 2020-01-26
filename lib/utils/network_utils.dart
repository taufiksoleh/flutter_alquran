import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class NetworkUtils {
  // next three lines makes this class a Singleton
  static NetworkUtils _instance = new NetworkUtils.internal();
  NetworkUtils.internal();
  factory NetworkUtils() => _instance;

  final JsonDecoder _decoder = new JsonDecoder();

  Future<dynamic> get(String url, {headers}) async {
    print("url get: " + url);
    return await http.get(url, headers: headers).then((http.Response response) {

      final String res     = response.body;
      print(res);
      final int statusCode = response.statusCode;
      
      if (statusCode < 200 || statusCode > 400 || res == null) {
        throw new Exception(_decoder.convert(res));
      }
      
      return _decoder.convert(res);
    });
  }

  Future<dynamic> post(String url, {headers, body, encoding}) {
    print("url post: " + url);
    print(body);
    return http
        .post(url, body: body, headers: headers, encoding: encoding)
        .then((http.Response response) {
      final String res     = response.body;
      print(res);
      final int statusCode = response.statusCode;

      if (statusCode < 200 || statusCode > 400 || res == null) {
        throw new Exception(_decoder.convert(res));
      }
      return _decoder.convert(res);
    });
  }
}