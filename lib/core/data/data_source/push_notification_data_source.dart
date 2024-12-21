import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart';

Future<String> getAccessToken() async {
  final serviceAccountJson = {
    "type": "service_account",
    "project_id": "fir-social-3f174",
    "private_key_id": "e63dc8ed20a7bb34d71e80e28675c998bf3652af",
    "private_key":
        "-----BEGIN PRIVATE KEY-----\nMIIEvwIBADANBgkqhkiG9w0BAQEFAASCBKkwggSlAgEAAoIBAQDUT8rl53d0KIlX\ntDprDTTftRJAzm+8mELbDjMqAVMqjBpp5xM7fSbYkjV/bC0EXGvA8hbwzh9cFURN\nsiAw0rZ/O9QjDJAMNucP4GM1Gg91QxahZCI8UN4Q8rCzuitXvSBeH+zfv3ALoCnr\nVe9cpQ8p5qSSz7kjrpmhyB6TsuoGs1XXHZOTDrhgDzpkF9RCNnm6m/WWXS1vXsgA\nVDbkhEvykpc6VBvgWqWWVCQwBpYZyWMa+rGe7ITsHp++mJXGYGMuYZqaXXyga+sf\nkd0711sJhCymQeX7vPriOIho08x8GdAT6UJsUAxA3WbTYUPfbeQZ4ns0q9gYNjUG\nCOYPZPE3AgMBAAECggEAZbHotpHWEnIeQz/FYaScSHFjkl4vgE8QavvUvxCOZQlh\n14tDF5IdaswxytymfXnFdVCgc2zP8ZwQMQUazTgJCU2/kaBBWVBtAhpResyGTf06\nGEkt6uUzUTvmLtiETUz+dYdmP1Bj23W2zo5FjoNTjZb4CohsHm7SEP+ZwdaHqXga\nz0wOqagigYJaUF2zlNfAukofYeQPmmqW/m3sCDH1zRVvINWWju+rz1+QR4FaXRRz\njSU+ZRi28RjAafmYY/L8+TNdsO0yFtzLurhFV3fjy9BsSo9CBz/oOFzeM6VIiYEO\nEYxe6lBmDGoh4kOggzpOsUziIqRTH7QrJv9Le1zIXQKBgQDsdLIek9cloPGEpbwe\nnhJfIvdO5+JwYfFikagPZFVv/gVT4+S6bM4nerbh9sxIXAIv2oxrjT/7667YbpJL\nIB/qQGtcD2iVbCLjb2pKbh1u9icjwzurBX0GWk9JbMI+aZfCnuJm2O4dpw3VL+FA\nTBnvSiEBG+4xeS1MHyaLn+vmewKBgQDl3DeEhsryQfHqIDw9UiOX9sswyaHZqzXK\npRA83bWmfozQElakpAyaTLJWm0mQGYYy+T8thgijZJ/MtJB321Fh70z2UKQBMrRB\nmvWkvR7iR5x2ye9SbqGoRUZ5bH2PLMqDjdKiByZAEDmfijLnzfj5kKjKxDSlxM+Q\ngO0CDsBhdQKBgQCWjMpn+5ttguajnV6EZAKwfjPWEoAzK7kkGDdX7XsUfjjoK96S\n7/nmWxScFKYGoEZoL49eXyXRAUNm3CfbG04WuQNiLxFYqewgwOx9DVVCNAnBlGmm\nPy1WYSPATTXzxQlySfU+pHofeSCujvitFocguyL+cMkcyNmVcPP6zEzHhwKBgQC0\n0+KlEnlzzecnXYamYwj3UsKUtfrqx2MA8YvtpilyOppCUjrxONFlTbL6qR1dDIdj\ncGuAP7JqAA4qt13zvIiwd9Ze7B+phZ8DAYn/uHwkXVu8o63vdnMccqs3eN7qFL2Y\ncqjiqKcxvNHoLYtQitw0UNZI9cPJKSR1NMe/V6WGxQKBgQCH1uSIoOuvwRpPdJex\nVGrNuK+HT1cSpLDXqioroEa24IniUtAt9ahkfAIJBlPrGKcrqz7UHpzYtphnUXcq\nat8lAhMc+64ZuD2z420XfHPtL9CtoOHQZ0CeHGTxQ+Qdv9NE43eWk5s1IWQsYGMu\nuwWWW3SHQCGxKrVTj6D9soM2ww==\n-----END PRIVATE KEY-----\n",
    "client_email":
        "firebase-adminsdk-wvz0k@fir-social-3f174.iam.gserviceaccount.com",
    "client_id": "109794639275476251985",
    "auth_uri": "https://accounts.google.com/o/oauth2/auth",
    "token_uri": "https://oauth2.googleapis.com/token",
    "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
    "client_x509_cert_url":
        "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-wvz0k%40fir-social-3f174.iam.gserviceaccount.com",
    "universe_domain": "googleapis.com"
  };
  List<String> scopes = ["https://www.googleapis.com/auth/firebase.messaging"];

  var client = await clientViaServiceAccount(
    ServiceAccountCredentials.fromJson(serviceAccountJson),
    scopes,
  );
  AccessCredentials credentials =
      await obtainAccessCredentialsViaServiceAccount(
          ServiceAccountCredentials.fromJson(serviceAccountJson),
          scopes,
          client);
  client.close();
  return credentials.accessToken.data;
}

Future<void> sendFCMMessage({
  required String fcmToken,
  required String title,
  required String body,
  required String route,
}) async {
  final String serverKey = await getAccessToken(); // Your FCM server key
  const String fcmEndpoint =
      'https://fcm.googleapis.com/v1/projects/fir-social-3f174/messages:send';

  final Map<String, dynamic> message = {
    'message': {
      'token': fcmToken,
      'notification': {'title': title, 'body': body},
      'data': {
        'route': route,
      },
    }
  };

  final response = await post(
    Uri.parse(fcmEndpoint),
    headers: <String, String>{
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $serverKey',
    },
    body: jsonEncode(message),
  );

  if (response.statusCode == 200) {
    if (kDebugMode) {
      print('FCM message sent successfully');
    }
  } else {
    if (kDebugMode) {
      print('Failed to send FCM message: ${response.body}');
    }
  }
}
