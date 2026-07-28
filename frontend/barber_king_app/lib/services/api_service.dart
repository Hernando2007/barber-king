import 'package:dio/dio.dart';

import '../core/constants.dart';

class ApiService {

  final Dio dio = Dio(

    BaseOptions(

      baseUrl: AppConstants.apiUrl,

      headers: {

        "Content-Type": "application/json"

      },

    ),

  );

}