import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

import 'Functions/Server.dart';
import 'models/Sample.dart' hide Hazards;
import 'models/Cells.dart';
import 'models/Forms.dart';
import 'models/Hazards.dart';
import 'models/Units.dart';
import 'models/User.dart';

// --- Custom Exceptions ---

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() {
    return "ApiException: $message (Status code: ${statusCode ?? 'N/A'})";
  }
}

class NetworkException extends ApiException {
  NetworkException(String message) : super("Network Error: $message");
}

class UnauthorizedException extends ApiException {
  UnauthorizedException([String message = "Unauthorized"]) : super(message, 401);
}

// --- API Client ---

/// A modern and robust API client for the sample tracking service.
///
/// NOTE: This application is configured to bypass SSL certificate validation
/// via a global HttpOverrides setting in main.dart. This is an intentional
/// configuration based on user requirements for an internal network.
class ApiClient {
  final http.Client _client;
  final String _baseUrl = "$SERVER_IP/sampletracking_test/index.php";

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  // --- Helper Methods ---

  Future<T> _get<T>(String endpoint, {required String jwt, required T Function(dynamic json) fromJson}) async {
    final uri = Uri.parse('$_baseUrl/$endpoint');
    try {
      final response = await _client.get(uri, headers: _authHeaders(jwt));
      return _handleResponse(response, fromJson);
    } on SocketException catch (e) {
      throw NetworkException(e.message);
    }
  }

  Future<T> _post<T>(String endpoint, {String? jwt, required Map<String, dynamic> body, required T Function(dynamic json) fromJson}) async {
    final uri = Uri.parse('$_baseUrl/$endpoint');
    try {
      final response = await _client.post(uri, headers: _headers(jwt: jwt), body: json.encode(body));
      return _handleResponse(response, fromJson);
    } on SocketException catch (e) {
      throw NetworkException(e.message);
    }
  }

  Future<T> _put<T>(String endpoint, {required String jwt, required Map<String, dynamic> body, required T Function(dynamic json) fromJson}) async {
    final uri = Uri.parse('$_baseUrl/$endpoint');
    try {
      final response = await _client.put(uri, headers: _authHeaders(jwt), body: json.encode(body));
      return _handleResponse(response, fromJson);
    } on SocketException catch (e) {
      throw NetworkException(e.message);
    }
  }

  Future<void> _delete(String endpoint, {required String jwt}) async {
    final uri = Uri.parse('$_baseUrl/$endpoint');
    try {
      final response = await _client.delete(uri, headers: _authHeaders(jwt));
       _handleResponse(response, (json) => null); // We just care about the status code
    } on SocketException catch (e) {
      throw NetworkException(e.message);
    }
  }

  T _handleResponse<T>(http.Response response, T Function(dynamic json) fromJson) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        final jsonBody = json.decode(response.body);
        return fromJson(jsonBody);
      } on FormatException {
        // Handle cases where the server returns a 200 OK status but with a
        // plain text error message instead of JSON (which is incorrect behavior).
        if (response.body.contains('Unauthorized')) {
          throw UnauthorizedException(
              'Server returned "Unauthorized" with a success status code.');
        }
        // If it's a different format error, it's unexpected.
        rethrow;
      }
    } else if (response.statusCode == 401) {
      throw UnauthorizedException();
    } else {
      throw ApiException(
          'Request failed with status: ${response.statusCode}.', response.statusCode);
    }
  }

  Map<String, String> _headers({String? jwt}) {
    final headers = {'Content-Type': 'application/json; charset=UTF-8'};
    if (jwt != null) {
      headers['Authorization'] = 'Bearer $jwt';
    }
    return headers;
  }

  Map<String, String> _authHeaders(String jwt) => _headers(jwt: jwt);

  // --- Authentication ---

  Future<String> attemptLogIn(String email, String password) async {
    // This login endpoint is outside the standard /index.php path
    final uri = Uri.parse('$SERVER_IP/sampletracking_test/login.php');
    try {
      final response = await _client.post(
        uri,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          "origin": "http://localhost" // As per original code
        },
        body: json.encode({'email': email, 'password': password}),
      );
      // Login returns the JWT directly in the body, not as JSON
      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw ApiException('Login failed', response.statusCode);
      }
    } on SocketException catch (e) {
      throw NetworkException(e.message);
    }
  }

  // --- Users ---

  Future<List<User>> getUsers(String jwt) async {
    return await _get('users', jwt: jwt, fromJson: (json) {
      final users = (json as List).map((data) => User.fromJson(data)).toList();
      return users;
    });
  }

  // Note: The original code for updateUser, addNewUser, etc. returned strings or status codes.
  // A better implementation returns the updated/created object or void.
  // For now, we will return Future<void> to indicate success/failure via exceptions.

  Future<void> updateUser(String jwt, {required String id, required Map<String, dynamic> data}) async {
    await _put('users/$id', jwt: jwt, body: data, fromJson: (json) => null);
  }

  Future<Map<String, dynamic>> addNewUser(String jwt, {required Map<String, dynamic> data}) async {
    return await _post('users', jwt: jwt, body: data, fromJson: (json) => json as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> updateUserPassword(String jwt, String email) async {
    return await _put('password', jwt: jwt, body: {"email": email, "password": ""}, fromJson: (json) => json as Map<String, dynamic>);
  }

  // --- Samples & Related Data ---

  Future<List<Sample>> getSamples(String jwt) async {
    return await _get('samples/latest', jwt: jwt, fromJson: (json) {
      return (json as List).map((data) => Sample.fromJson(data)).toList();
    });
  }

  Future<Sample> getSampleID(String jwt, {required String id}) async {
    return await _get('samples/$id', jwt: jwt, fromJson: (json) => Sample.fromJson(json));
  }

  Future<List<Sample>> getUserSamples(String jwt, {required String userEmail}) async {
    print(userEmail);
    return await _get('samples/username/$userEmail/latest', jwt: jwt, fromJson: (json) {
      return (json as List).map((data) => Sample.fromJson(data)).toList();
    });
  }

  Future<Map<String, dynamic>?> updateSample(String jwt, {required Sample sample}) async {
    // The original API seems to use POST for updates, which is unconventional.
    return await _post('samples', jwt: jwt, body: sample.toJson(), fromJson: (json) => json as Map<String, dynamic>?);
  }

  // --- Forms, Units, Hazards ---

  Future<List<FormsOfSample>> getForms(String jwt) async {
    return await _get('forms', jwt: jwt, fromJson: (json) {
      return (json as List).map((data) => FormsOfSample.fromJson(data)).toList();
    });
  }

  Future<List<UnitsOfSample>> getUnits(String jwt) async {
    return await _get('units', jwt: jwt, fromJson: (json) {
      return (json as List).map((data) => UnitsOfSample.fromJson(data)).toList();
    });
  }

  Future<List<Hazards>> getHazards(String jwt) async {
    return await _get('hazards', jwt: jwt, fromJson: (json) {
      return (json as List).map((data) => Hazards.fromJson(data)).toList();
    });
  }

  // --- Cells / Cans ---

  Future<List<Cells>> getCans(String jwt, {String? status}) async {
    String endpoint = 'cells';
    if (status != null && (status == 'full' || status == 'empty')) {
      endpoint = 'cells/$status';
    }
    return await _get(endpoint, jwt: jwt, fromJson: (json) {
      return (json as List).map((data) => Cells.fromJson(data)).toList();
    });
  }

  Future<Cells> getThisCan(String jwt, {required String id}) async {
    return await _get('cells/$id', jwt: jwt, fromJson: (json) => Cells.fromJson(json));
  }

  Future<void> addNewCell(String jwt, {required String barcode, required String description}) async {
    await _post('cells', jwt: jwt, body: {'barcode': barcode, 'description': description}, fromJson: (json) => null);
  }

  Future<void> updateCell(String jwt, {required String id, required String barcode, required String description}) async {
    await _put('cells/$id', jwt: jwt, body: {'barcode': barcode, 'description': description}, fromJson: (json) => null);
  }

  Future<void> deleteCell(String jwt, {required String id}) async {
    await _delete('cells/$id', jwt: jwt);
  }

  // --- Image Upload ---

  Future<String?> updateImage(String jwt, {required String sampleID, required File file}) async {
    final uri = Uri.parse('$_baseUrl/image');
    final request = http.MultipartRequest('POST', uri);

    final mimeTypeData = lookupMimeType(file.path)?.split('/');
    final fileStream = http.ByteStream(file.openRead());
    final length = await file.length();

    request.headers['Authorization'] = 'Bearer $jwt';
    request.fields['sample_id'] = sampleID;

    final multipartFile = http.MultipartFile(
      'image',
      fileStream,
      length,
      filename: file.path.split('/').last,
      contentType: mimeTypeData != null ? MediaType(mimeTypeData[0], mimeTypeData[1]) : null,
    );

    request.files.add(multipartFile);

    try {
      final streamedResponse = await _client.send(request);
      final response = await http.Response.fromStream(streamedResponse);
      return _handleResponse(response, (json) {
        // Per user feedback, the key is 'url' and it provides a full, absolute URL.
        return json['url'] as String?;
      });
    } on SocketException catch (e) {
      throw NetworkException(e.message);
    }
  }
}