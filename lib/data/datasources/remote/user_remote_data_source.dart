import 'package:dio/dio.dart';

import '../../../core/config/app_env.dart';
import '../../../core/utils/paginated_response.dart';
import '../../models/app_user_model.dart';

class UserRemoteDataSource {
  UserRemoteDataSource(this._dio);

  final Dio _dio;

  void _ensureReqResKey() {
    if (!AppEnv.hasReqResKey) {
      throw StateError(
        'Missing ReqRes API key in AppEnv.reqResApiKey.',
      );
    }
  }

  Future<PaginatedResponse<AppUserModel>> fetchUsers({required int page}) async {
    _ensureReqResKey();

    final response = await _dio.get<dynamic>(
      '/users',
      queryParameters: <String, dynamic>{'page': page},
    );

    final data = response.data as Map<String, dynamic>;
    final users = (data['data'] as List<dynamic>)
        .map(
          (dynamic item) =>
              AppUserModel.fromReqResJson(item as Map<String, dynamic>),
        )
        .toList();

    return PaginatedResponse<AppUserModel>(
      items: users,
      page: data['page'] as int? ?? page,
      totalPages: data['total_pages'] as int? ?? page,
    );
  }

  Future<AppUserModel> createUser({
    required String localId,
    required String name,
    required String job,
  }) async {
    _ensureReqResKey();

    final response = await _dio.post<dynamic>(
      '/users',
      data: <String, dynamic>{'name': name, 'job': job},
    );

    return AppUserModel.fromCreateResponse(
      response.data as Map<String, dynamic>,
      localId: localId,
      name: name,
      job: job,
      isPendingSync: false,
    );
  }
}
