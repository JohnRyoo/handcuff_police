import 'package:json_annotation/json_annotation.dart';
import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';

part 'RestClient.g.dart';

@RestApi(baseUrl: "https://a4536928-1969-4082-9ecd-815cec5e875b.mock.pstmn.io/smartHandcuff")
abstract class RestClient {
  factory RestClient(Dio dio, {String baseUrl}) = _RestClient;

  @POST("/regUser") // 해당 api 경로
  Future<NormalResponse> registerUser(
      @Body() RegisterUserRequest registerUserRequest);
}

@JsonSerializable()
class RegisterUserRequest {
  String? userId;
  String? userPw;

  RegisterUserRequest({required this.userId, required this.userPw});

  factory RegisterUserRequest.fromJson(Map<String, dynamic> json) =>
      _$RegisterUserRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RegisterUserRequestToJson(this);
}

@JsonSerializable()
class NormalResponse {
  String? success;
  String? message;

  NormalResponse({required this.success, required this.message});

  factory NormalResponse.fromJson(Map<String, dynamic> json) =>
      _$NormalResponseFromJson(json);

  Map<String, dynamic> toJson() => _$NormalResponseToJson(this);
}
