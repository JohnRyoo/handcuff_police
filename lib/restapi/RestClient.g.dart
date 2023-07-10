// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'RestClient.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RegisterUserRequest _$RegisterUserRequestFromJson(Map<String, dynamic> json) =>
    RegisterUserRequest(
      user_id: json['user_id'] as String?,
      user_pw: json['user_pw'] as String?,
    );

Map<String, dynamic> _$RegisterUserRequestToJson(
        RegisterUserRequest instance) =>
    <String, dynamic>{
      'user_id': instance.user_id,
      'user_pw': instance.user_pw,
    };

NormalResponse _$NormalResponseFromJson(Map<String, dynamic> json) =>
    NormalResponse(
      success: json['success'] as bool?,
      message: json['message'] as String?,
    );

Map<String, dynamic> _$NormalResponseToJson(NormalResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
    };

LoginRequest _$LoginRequestFromJson(Map<String, dynamic> json) => LoginRequest(
      user_id: json['user_id'] as String?,
      user_pw: json['user_pw'] as String?,
    );

Map<String, dynamic> _$LoginRequestToJson(LoginRequest instance) =>
    <String, dynamic>{
      'user_id': instance.user_id,
      'user_pw': instance.user_pw,
    };

LoginResponse _$LoginResponseFromJson(Map<String, dynamic> json) =>
    LoginResponse(
      success: json['success'] as bool?,
      handcuff_id_list: (json['handcuff_id_list'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$LoginResponseToJson(LoginResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'handcuff_id_list': instance.handcuff_id_list,
    };

DeleteHandcuffRequest _$DeleteHandcuffRequestFromJson(
        Map<String, dynamic> json) =>
    DeleteHandcuffRequest(
      user_id: json['user_id'] as String?,
      handcuff_id: json['handcuff_id'] as String?,
    );

Map<String, dynamic> _$DeleteHandcuffRequestToJson(
        DeleteHandcuffRequest instance) =>
    <String, dynamic>{
      'user_id': instance.user_id,
      'handcuff_id': instance.handcuff_id,
    };

RegisterHandcuffRequest _$RegisterHandcuffRequestFromJson(
        Map<String, dynamic> json) =>
    RegisterHandcuffRequest(
      user_id: json['user_id'] as String?,
      handcuff_id: json['handcuff_id'] as String?,
    );

Map<String, dynamic> _$RegisterHandcuffRequestToJson(
        RegisterHandcuffRequest instance) =>
    <String, dynamic>{
      'user_id': instance.user_id,
      'handcuff_id': instance.handcuff_id,
    };

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps,no_leading_underscores_for_local_identifiers

class _RestClient implements RestClient {
  _RestClient(
    this._dio, {
    this.baseUrl,
  }) {
    baseUrl ??= 'http://15.165.14.183:8088/smartHandcuff';
  }

  final Dio _dio;

  String? baseUrl;

  @override
  Future<NormalResponse> registerUser(
      RegisterUserRequest registerUserRequest) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(registerUserRequest.toJson());
    final _result = await _dio
        .fetch<Map<String, dynamic>>(_setStreamType<NormalResponse>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/regUser',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = NormalResponse.fromJson(_result.data!);
    return value;
  }

  @override
  Future<LoginResponse> login(LoginRequest loginRequest) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(loginRequest.toJson());
    final _result = await _dio
        .fetch<Map<String, dynamic>>(_setStreamType<LoginResponse>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/login',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = LoginResponse.fromJson(_result.data!);
    return value;
  }

  @override
  Future<NormalResponse> deleteHandcuff(
      DeleteHandcuffRequest deleteHandcuffRequest) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(deleteHandcuffRequest.toJson());
    final _result = await _dio
        .fetch<Map<String, dynamic>>(_setStreamType<NormalResponse>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/delHandcuff',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = NormalResponse.fromJson(_result.data!);
    return value;
  }

  @override
  Future<NormalResponse> registerHandcuff(
      RegisterHandcuffRequest registerHandcuffRequest) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(registerHandcuffRequest.toJson());
    final _result = await _dio
        .fetch<Map<String, dynamic>>(_setStreamType<NormalResponse>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/regHandcuff',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = NormalResponse.fromJson(_result.data!);
    return value;
  }

  RequestOptions _setStreamType<T>(RequestOptions requestOptions) {
    if (T != dynamic &&
        !(requestOptions.responseType == ResponseType.bytes ||
            requestOptions.responseType == ResponseType.stream)) {
      if (T == String) {
        requestOptions.responseType = ResponseType.plain;
      } else {
        requestOptions.responseType = ResponseType.json;
      }
    }
    return requestOptions;
  }
}
