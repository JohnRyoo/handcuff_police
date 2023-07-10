import 'package:json_annotation/json_annotation.dart';
import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';

part 'RestClient.g.dart';

@RestApi(baseUrl: "http://15.165.14.183:8088/smartHandcuff")
abstract class RestClient {
  factory RestClient(Dio dio, {String baseUrl}) = _RestClient;

  @POST("/regUser")
  Future<NormalResponse> registerUser(
      @Body() RegisterUserRequest registerUserRequest);

  @POST("/login")
  Future<LoginResponse> login(
      @Body() LoginRequest loginRequest);

  @POST("/delHandcuff")
  Future<NormalResponse> deleteHandcuff(
      @Body() DeleteHandcuffRequest deleteHandcuffRequest);

  @POST("/regHandcuff")
  Future<NormalResponse> registerHandcuff(
      @Body() RegisterHandcuffRequest registerHandcuffRequest);

}

// ============== REGISTER USER ==============
@JsonSerializable()
class RegisterUserRequest {
  String? user_id;
  String? user_pw;

  RegisterUserRequest({required this.user_id, required this.user_pw});

  factory RegisterUserRequest.fromJson(Map<String, dynamic> json) =>
      _$RegisterUserRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RegisterUserRequestToJson(this);
}

@JsonSerializable()
class NormalResponse {
  bool? success;
  String? message;

  NormalResponse({required this.success, required this.message});

  factory NormalResponse.fromJson(Map<String, dynamic> json) =>
      _$NormalResponseFromJson(json);

  Map<String, dynamic> toJson() => _$NormalResponseToJson(this);
}

// ============== LOGIN ==============
@JsonSerializable()
class LoginRequest {
  String? user_id;
  String? user_pw;

  LoginRequest({required this.user_id, required this.user_pw});

  factory LoginRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestFromJson(json);

  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);
}

@JsonSerializable()
class LoginResponse {
  bool? success;
  List<String>? handcuff_id_list;

  LoginResponse({required this.success, required this.handcuff_id_list});

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);
}

// ============== DELETE ==============
@JsonSerializable()
class DeleteHandcuffRequest {
  String? user_id;
  String? handcuff_id;

  DeleteHandcuffRequest({required this.user_id, required this.handcuff_id});

  factory DeleteHandcuffRequest.fromJson(Map<String, dynamic> json) =>
      _$DeleteHandcuffRequestFromJson(json);

  Map<String, dynamic> toJson() => _$DeleteHandcuffRequestToJson(this);
}

// ============== REGISTER HANDCUFF ==============
@JsonSerializable()
class RegisterHandcuffRequest {
  String? user_id;
  String? handcuff_id;

  RegisterHandcuffRequest({required this.user_id, required this.handcuff_id});

  factory RegisterHandcuffRequest.fromJson(Map<String, dynamic> json) =>
      _$RegisterHandcuffRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RegisterHandcuffRequestToJson(this);
}
