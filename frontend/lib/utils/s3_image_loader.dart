import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';
import 'package:image/image.dart' as img;
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:crypto/crypto.dart';
import 'package:intl/intl.dart';



class S3ImageLoader {

  static const String _baseUrl = 'https://airepur-aws-s3.s3.eu-north-1.amazonaws.com/';

  static Widget loadImage(String fileName, {double? width ,double? height}){
    String fullUrl = '$_baseUrl$fileName';
    return Image.network(
      fullUrl,
      width: width,
      height: height,
      errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
        if (kDebugMode) {
          print(exception);
        }
        return Text('Failed to load the image: $exception in url $fullUrl');
      },
      loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null ?
                   loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                   : null,
          ), 
        );
      },
    );  
  }

  static ImageProvider loadImageAsImageProvider(String fileName) {
    String fullUrl = '$_baseUrl$fileName';
    return NetworkImage(fullUrl);
  }

  static Future<BitmapDescriptor> loadMarkerIcon(String fileName) async {
    String fullUrl = '$_baseUrl$fileName';

    // Carga la imagen como byte array
    final response = await http.get(Uri.parse(fullUrl));

    if (response.statusCode == 200) {
      // Decodifica la imagen a partir de los bytes descargados
      img.Image image = img.decodeImage(response.bodyBytes)!;

      // Redimensiona la imagen a las dimensiones especificadas
      img.Image resized = img.copyResize(image, width: 150, height: 150);

      // Convierte la imagen redimensionada a Uint8List
      Uint8List resizedBytes = Uint8List.fromList(img.encodePng(resized));
      // Crea un BitmapDescriptor desde los bytes
      return BitmapDescriptor.fromBytes(resizedBytes);
    } else {
      throw Exception('Failed to load image');
    }
  }
}


class S3ImageUploader {
final String accessKey = 'YOUR_AWS_ACCESS';
  final String secretKey = 'SECRET_KEY';
   final String bucketName = 'BUCKET_NAME';
  final ImagePicker _picker = ImagePicker();

  Future<String?> uploadProfileImage(String userName) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) {
      if (kDebugMode) {
        print('No file selected');
      }
      return null;
    }

    final fileName = 'profile_images/$userName.png';
    await _uploadFile(pickedFile, fileName);
    return fileName;
  }

  Future<String?> uploadForumImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) {
      if (kDebugMode) {
        print('No file selected');
      }
      return null;
    }

    final uniqueFileName = 'forum_images/${DateTime.now().millisecondsSinceEpoch}.png';
    await _uploadFile(pickedFile, uniqueFileName);
    return uniqueFileName;
  }

  Future<String?> _uploadFile(XFile file, String fileName) async {
  try {
    if (kDebugMode) {
      print('Starting file upload...');
      print('File path: ${file.path}');
    }
    final endpoint = 'https://$bucketName.s3.eu-north-1.amazonaws.com/$fileName';
    if (kDebugMode) {
      print('Endpoint: $endpoint');
    }
    final bytes = await file.readAsBytes();
    if (kDebugMode) {
      print('File read successfully, bytes length: ${bytes.length}');
    }
    
    DateFormat("EEE, dd MMM yyyy HH:mm:ss 'GMT'").format(DateTime.now().toUtc());
    final xAmzDate = DateFormat("yyyyMMdd'T'HHmmss'Z'").format(DateTime.now().toUtc());
    const contentType = 'image/png';
    final payloadHash = sha256.convert(bytes).toString();

    final canonicalHeaders = [
      'content-type:$contentType',
      'host:$bucketName.s3.eu-north-1.amazonaws.com',
      'x-amz-content-sha256:$payloadHash',
      'x-amz-date:$xAmzDate'
    ].join('\n');

    const signedHeaders = 'content-type;host;x-amz-content-sha256;x-amz-date';

    final canonicalRequest = [
      'PUT',
      '/$fileName',
      '',
      canonicalHeaders,
      '',
      signedHeaders,
      payloadHash
    ].join('\n');

    if (kDebugMode) {
      print('Canonical Request: $canonicalRequest');
    }

    final hashedCanonicalRequest = sha256.convert(utf8.encode(canonicalRequest)).toString();

    final credentialScope = [
      DateFormat("yyyyMMdd").format(DateTime.now().toUtc()),
      'eu-north-1',
      's3',
      'aws4_request'
    ].join('/');

    final stringToSign = [
      'AWS4-HMAC-SHA256',
      xAmzDate,
      credentialScope,
      hashedCanonicalRequest
    ].join('\n');

    if (kDebugMode) {
      print('String to Sign: $stringToSign');
    }

    final signingKey = _getSignatureKey(secretKey, DateFormat("yyyyMMdd").format(DateTime.now().toUtc()), 'eu-north-1', 's3');
    final signature = Hmac(sha256, signingKey).convert(utf8.encode(stringToSign)).toString();

    if (kDebugMode) {
      print('Signature: $signature');
    }

    final authorizationHeader = [
      'AWS4-HMAC-SHA256 Credential=$accessKey/$credentialScope',
      'SignedHeaders=$signedHeaders',
      'Signature=$signature'
    ].join(', ');

    final headers = {
      'Content-Type': contentType,
      'x-amz-date': xAmzDate,
      'x-amz-content-sha256': payloadHash,
      'Authorization': authorizationHeader,
    };

    // Devolver la URL antes de que termine la subida
    final imageUrl = endpoint;

    final response = await http.put(
      Uri.parse(endpoint),
      headers: headers,
      body: bytes,
    );

    if (response.statusCode == 200) {
      if (kDebugMode) {
        print('File uploaded successfully');
      }
      return imageUrl;
    } else {
      if (kDebugMode) {
        print('Failed to upload: ${response.body}');
      }
      return null;
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error during file upload: $e');
    }
    return null;
  }
}

  List<int> _getSignatureKey(String key, String dateStamp, String regionName, String serviceName) {
    final kDate = Hmac(sha256, utf8.encode('AWS4$key')).convert(utf8.encode(dateStamp)).bytes;
    final kRegion = Hmac(sha256, kDate).convert(utf8.encode(regionName)).bytes;
    final kService = Hmac(sha256, kRegion).convert(utf8.encode(serviceName)).bytes;
    final kSigning = Hmac(sha256, kService).convert(utf8.encode('aws4_request')).bytes;
    return kSigning;
  }
}