class ServiceResponse {
  final bool isSuccess;
  final dynamic data;
  final String? message;

  ServiceResponse({
    required this.isSuccess,
    this.data,
    this.message,
  });

  factory ServiceResponse.success({dynamic data}) {
    return ServiceResponse(isSuccess: true, data: data);
  }

  factory ServiceResponse.error({String? message}) {
    return ServiceResponse(isSuccess: false, message: message);
  }
}