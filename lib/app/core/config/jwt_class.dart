import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

class JwtSign {
  final mySecret = 'QXBwVW5pb2RvbnRvMjAyNA==';

  String getToken(Map<String, dynamic> body) {
    final jwt = JWT(body);

    final token = jwt.sign(SecretKey(mySecret));
    return token;
  }
}
