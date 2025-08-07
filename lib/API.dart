import 'dart:async';
//import 'package:flutter/material.dart';
import 'package:flutter_samples/models/Sample.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
//import  'package:path/path.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import '../Functions/Server.dart';

//AWS
//http://10.208.110.28/sampletracking_test/
//WEBSTER
//const SERVER_IP = 'https://www.ncnr.nist.gov'
//const SERVER_IP = 'https://ncnr.nist.gov/flutter';

const baseUrl = "$SERVER_IP/sampletracking_test/index.php/samples";
// for a specific ample ID add /id/latest
const baseUrlForms = "$SERVER_IP/sampletracking_test/index.php/forms";
const baseUrlUnits = "$SERVER_IP/sampletracking_test/index.php/units";
const baseUrlHazards = "$SERVER_IP/sampletracking_test/index.php/hazards";

const baseUrl_cans = "$SERVER_IP/sampletracking_test/index.php/cells/";
const baserUrlUpdateSampleCell =
    '$SERVER_IP/sampletracking_test/index.php/cells/';
const baserUrlAddSampleCell = "$SERVER_IP/sampletracking_test/index.php/cells";

const baseUrlSingleCellId = "$SERVER_IP/sampletracking_test/index.php/cells/";
const baseUrl_usersamp =
    "$SERVER_IP/sampletracking_test/index.php/samples/username";
// "https://www.ncnr.nist.gov/sampletracking_test/index.php/samples/username";

const baseUrlUser = "$SERVER_IP/sampletracking_test/index.php/users";
const baseUrlUserPass = "$SERVER_IP/sampletracking_test/index.php/password";
const baseUrlUpdateUser = "$SERVER_IP/sampletracking_test/index.php/users";
// append the ID
const baseUrlAddUser = "$SERVER_IP/sampletracking_test/index.php/users";
// Has no ID associated
const baseUrlUpdateSample = "$SERVER_IP/sampletracking_test/index.php/samples";
const baseUpdateImage = "$SERVER_IP/sampletracking_test/index.php/image";

class API {
  static Future<String> attemptLogIn(String user, String pass) async {
    Map data = {'email': user, 'password': pass};
    String body = json.encode(data);

    var result = await http.post(
      Uri.parse("$SERVER_IP/sampletracking_test/login.php"),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        "origin": "http://localhost"
      },
      body: body,
    );
    //print(result.statusCode.toString());
    //print(result.body);
    //print(result.headers);
    //print(result.reasonPhrase);
    if (result.statusCode == 200) return result.body;
    return "";
  }

  static Future getHazards(String jwt) async {
    var result = await http.get(Uri.parse(baseUrlHazards),
        headers: {"Authorization": "Bearer $jwt"});
    return result;
  }

  static Future getSamples(String jwt) async {
    var result = await http.get(Uri.parse("$baseUrl/latest"),
        headers: {"Authorization": "Bearer $jwt"});
    return result;
  }

  static Future getSampleID(String id, String jwt) async {
    final uri = Uri.parse("$baseUrl/$id"); //+"/latest";
    var result =
        await http.get(uri, headers: {"Authorization": "Bearer $jwt"});

    return result;
  }

  static Future getForms(String jwt) async {
    var result = await http.get(Uri.parse(baseUrlForms),
        headers: {"Authorization": "Bearer $jwt"});
    return result;
  }

  static Future getUnits(String jwt) async {
    var result = await http.get(Uri.parse(baseUrlUnits),
        headers: {"Authorization": "Bearer $jwt"});
    return result;
  }

  static Future getUserSamples(String user, String jwt) async {
    var url = Uri.parse("$baseUrl_usersamp/$user/latest");
    return http.get(url, headers: {"Authorization": "Bearer $jwt"});
  }

  static Future getUsers(String jwt) async {
    var result = await http.get(Uri.parse(baseUrlUser),
        headers: {"Authorization": "Bearer $jwt"});
    return result;
  }

  static Future getCans(String jwt) async {
    var url = Uri.parse(baseUrl_cans);
    var response =
        await http.get(url, headers: {"Authorization": "Bearer $jwt"});
    return response;
  }

  static Future getFullCans(String jwt) async {
    var url = Uri.parse("${baseUrl_cans}full");
    var response =
        await http.get(url, headers: {"Authorization": "Bearer $jwt"});
    return response;
  }

  static Future getEmptyCans(String jwt) async {
    var url = Uri.parse("${baseUrl_cans}empty");
    var response =
        await http.get(url, headers: {"Authorization": "Bearer $jwt"});
    return response;
  }

  static Future getThisCan(String id, String jwt) async {
    var url = Uri.parse(baseUrlSingleCellId + id.toString());
    var response =
        await http.get(url, headers: {"Authorization": "Bearer $jwt"});
    return response;
  }

  //update a user
  static Future updateUser(jwt, {id, data}) async {
    // ignore: prefer_is_empty
    if (id.toString().length >= 0) {
      // ignore: prefer_interpolation_to_compose_strings
      final result = await http.put(Uri.parse("$baseUrlUpdateUser/" + id),
          body: jsonEncode(data),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer " + jwt
          });
      // print(result.body);
      return result.statusCode.toString();
    } else {
      return 0;
    }
  }

  //add a user
  static Future addNewUser(jwt, {data}) async {
    final result = await http.post(Uri.parse(baseUrlAddUser),
        body: jsonEncode(data),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer " + jwt
        });

    if (result.body.toString().contains("Duplicate entry")) {
      return "Error in adding new user: email already in database";
    } else if (result.statusCode.toString() == "200") {
      String ttt = (jsonDecode(result.body)['password'].toString());
      // print(result.body);
      return ttt;
    } else {
      return "Error in adding new user: unknown error";
    }

//    print("going back");
  }

  //updates user passsword
  static Future updateUserPassword(jwt, email) async {
    var data = {"email": email, "password": ""};
    final result = await http.put(Uri.parse(baseUrlUserPass),
        body: jsonEncode(data),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer " + jwt
        });
    String ttt = (jsonDecode(result.body)['password'].toString());

//    print("going back");
    if (result.statusCode.toString() == "200") {
      return ttt;
    } else {
      return "error in password change";
    }
  }

//delete a cell
  static Future deleteCell(jwt, id) async {
    //var data = {"id": id};
    final url = Uri.parse(baseUrl_cans + id);
    // ignore: unused_local_variable
    final result = await http.delete(url,
        //body: jsonEncode(data),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer " + jwt
        });
    // print('Deleting cell ' + id);
    // print(result.body);
    return 200;
  }

  //add a cell
  static Future addNewCell(jwt, {barcode, description}) async {
    var data = {"barcode": barcode, "description": description};
    final result = await http.post(Uri.parse(baserUrlAddSampleCell),
        body: jsonEncode(data),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer " + jwt
        });
    // print(result.statusCode.toString());
    // print(jsonEncode(data).toString());
    // print(baseUrlAddUser);
    // print('Adding new cell' + barcode);
    // print(result.body);
    return result.statusCode.toString();
  }

  // add an image from file:
  static Future updateImage(jwt, {sampleID, file}) async {
    final mimeTypeData =
        lookupMimeType(file.path, headerBytes: [0xFF, 0xD8])!.split('/');
// Intilize the multipart request
    final imageUploadRequest =
        http.MultipartRequest('POST', Uri.parse(baseUpdateImage));
// Attach the file in the request
    final fileAttached = await http.MultipartFile.fromPath('image', file.path,
        contentType: MediaType(mimeTypeData[0], mimeTypeData[1]));
// add the id:
    imageUploadRequest.headers['sample_id'] = sampleID.toString();
    imageUploadRequest.headers["Authorization"] = "Bearer " + jwt;
    imageUploadRequest.fields['sample_id'] = sampleID.toString();
    imageUploadRequest.files.add(fileAttached);
    print(imageUploadRequest.fields.toString());
    try {
      final streamedResponse = await imageUploadRequest.send();
      final response = await http.Response.fromStream(streamedResponse);
      print(response.statusCode);
      if (response.statusCode != 200) {
        print('server response is not OK');
        final responseData = json.decode(response.body);
        print(responseData);
        return "";
      }
      final responseData = json.decode(response.body);
      print(
          "Uppdated image: warning might need a delay to next sampless refresh!");
      return responseData;
    } catch (e) {
      print('There was an error uploading the image');
      // print(e);
      return "";
    }
  }

  //update a cell
  static Future updateCell(jwt, {id, barcode, description}) async {
    var data = {"barcode": barcode, "description": description};
    final result = await http.put(
        Uri.parse(baserUrlUpdateSampleCell + id.toString()),
        body: jsonEncode(data),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer " + jwt
        });
    return result.statusCode.toString();
  }

  //update a sample
  static Future updateSample(jwt, {required Sample sample}) async {
    print('updating sample');
    print(jsonEncode(sample));
    final response = await http.post(Uri.parse(baseUrlUpdateSample),
        body: jsonEncode(sample),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer " + jwt
        });
    if (response.statusCode != 200) {
      // print("sample addition error!");
      // print(json.decode(response.body).toString());
      return null;
    } else {
      if (!json.decode(response.body).toString().contains('result: False')) {
        // print('code: ' + response.statusCode.toString());
        final responseData = json.decode(response.body);
        // print('output: ' + json.decode(response.body).toString());
        return responseData;
      } else {
        // print(response.statusCode.toString());
        // print(json.decode(response.body).toString());
        return null;
      }
    }
  }

  static Future newSampleWithImage(jwt, {required Sample sample, image}) async {
    // print('updating sample');
    final response = await http.post(Uri.parse(baseUrlUpdateSample),
        body: jsonEncode(sample),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer " + jwt
        });
    if (response.statusCode != 200) {
      return null;
    }
    final responseData = json.decode(response.body);
    var id = responseData['sample_id'];
    var val = updateImage(jwt, sampleID: id, file: image);
    if (val.toString().isNotEmpty) {
      // print(val);
    }
  }
}
