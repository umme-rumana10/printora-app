import 'package:dio/dio.dart';

class ApiService {
  static const String baseUrl = "http://192.168.0.11:5000/api";

  final Dio dio = Dio();

  Future<Response> uploadMultipleFiles(
    FormData formData,
  ) async {
    return await dio.post(
      "$baseUrl/print/upload-multiple",
      data: formData,
    );
  }

  Future<Response> getOrder(
    String orderId,
  ) async {
    return await dio.get(
      "$baseUrl/print/order/$orderId",
    );
  }

  Future<Response> getKioskJobs(
    String kioskId,
  ) async {
    return await dio.get(
      "$baseUrl/kiosk/$kioskId/jobs",
    );
  }

  Future<Response> startPrinting(
    String jobId,
  ) async {
    return await dio.patch(
      "$baseUrl/kiosk/print/$jobId/start",
    );
  }

  Future<Response> completePrinting(
    String jobId,
  ) async {
    return await dio.patch(
      "$baseUrl/kiosk/print/$jobId/complete",
    );
  }
}
