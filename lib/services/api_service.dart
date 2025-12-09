import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/group.dart';
import 'token_manager.dart';

class ApiService {
  // TODO: Replace with your actual backend URL
  static const String baseUrl =
      'http://ec2-18-222-144-126.us-east-2.compute.amazonaws.com:8080';

  static String? _authToken;

  static void setAuthToken(String? token) {
    _authToken = token;
  }

  /// Obtiene headers con token válido (verifica y renueva si es necesario)
  static Future<Map<String, String>> _getHeaders() async {
    final headers = {'Content-Type': 'application/json'};

    // Intentar obtener token válido
    final token = await TokenManager.getValidToken();

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
      _authToken = token; // Mantener sincronizado
    } else if (_authToken != null) {
      // Fallback al token en memoria si TokenManager falla
      headers['Authorization'] = 'Bearer $_authToken';
      print('⚠️ Using cached token (TokenManager returned null)');
    } else {
      print('⚠️ No valid token available');
    }

    return headers;
  }

  /// Maneja reintentos automáticos en caso de error 401
  static Future<http.Response> _makeAuthenticatedRequest(
    Future<http.Response> Function(Map<String, String> headers) requestFn, {
    int maxRetries = 1,
  }) async {
    final headers = await _getHeaders();
    var response = await requestFn(headers);

    // Si recibimos 401, intentar refresh y reintentar
    if (response.statusCode == 401 && maxRetries > 0) {
      print('🔐 Received 401 - attempting token refresh...');

      final refreshed = await TokenManager.refreshToken();
      if (refreshed) {
        print('✅ Token refreshed, retrying request...');
        final newHeaders = await _getHeaders();
        response = await requestFn(newHeaders);
      } else {
        print('❌ Token refresh failed - authentication expired');
        throw Exception('Authentication expired. Please sign in again.');
      }
    }

    return response;
  }

  // Get user profile from backend
  static Future<User> getUserProfile() async {
    try {
      final response = await _makeAuthenticatedRequest(
        (headers) =>
            http.get(Uri.parse('$baseUrl/api/user/profile'), headers: headers),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return User.fromJson(data);
      } else {
        throw Exception('Failed to load user profile: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting user profile: $e');
    }
  }

  // Get user profile by provider ID (Google ID)
  static Future<User> getUserProfileByProviderId(String providerUserId) async {
    try {
      final response = await _makeAuthenticatedRequest(
        (headers) => http.get(
          Uri.parse('$baseUrl/api/users/me?providerUserId=$providerUserId'),
          headers: headers,
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return User.fromJson(data);
      } else {
        throw Exception('Failed to load user profile: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting user profile: $e');
    }
  }

  // Check authentication status
  static Future<bool> checkAuthStatus() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/auth/status'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['authenticated'] as bool? ?? false;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Get user by ID
  static Future<User> getUserById(String userId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/users/$userId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return User.fromJson(data);
      } else {
        throw Exception('Failed to load user: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting user: $e');
    }
  }

  // Add user to group
  static Future<User> addUserToGroup(String userId, String groupId) async {
    try {
      final response = await _makeAuthenticatedRequest(
        (headers) => http.post(
          Uri.parse('$baseUrl/api/users/$userId/groups/$groupId'),
          headers: headers,
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return User.fromJson(data);
      } else {
        throw Exception('Failed to add user to group: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error adding user to group: $e');
    }
  }

  // Remove user from group
  static Future<User> removeUserFromGroup(String userId, String groupId) async {
    try {
      final response = await _makeAuthenticatedRequest(
        (headers) => http.delete(
          Uri.parse('$baseUrl/api/users/$userId/groups/$groupId'),
          headers: headers,
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return User.fromJson(data);
      } else {
        throw Exception(
          'Failed to remove user from group: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error removing user from group: $e');
    }
  }

  // ============================================
  // GROUP ENDPOINTS
  // ============================================

  // Create a new group
  static Future<Group> createGroup({
    required String name,
    String? description,
    required String creatorId,
    String? eventId,
    int maxMembers = 50,
  }) async {
    try {
      final response = await _makeAuthenticatedRequest(
        (headers) => http.post(
          Uri.parse('$baseUrl/api/groups'),
          headers: headers,
          body: json.encode({
            'name': name,
            'description': description,
            'creatorId': creatorId,
            'eventId': eventId,
            'maxMembers': maxMembers,
          }),
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Group.fromJson(data);
      } else {
        throw Exception('Failed to create group: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating group: $e');
    }
  }

  // Get group by ID
  static Future<Group> getGroupById(String groupId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/groups/$groupId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Group.fromJson(data);
      } else {
        throw Exception('Failed to load group: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting group: $e');
    }
  }

  // Get group by invite code
  static Future<Group> getGroupByInviteCode(String inviteCode) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/groups/invite/$inviteCode'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Group.fromJson(data);
      } else {
        throw Exception('Failed to find group: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting group by invite code: $e');
    }
  }

  // Join group with invite code
  static Future<Group> joinGroupWithInviteCode(
    String inviteCode,
    String userId,
  ) async {
    try {
      final response = await _makeAuthenticatedRequest(
        (headers) => http.post(
          Uri.parse('$baseUrl/api/groups/join/$inviteCode'),
          headers: headers,
          body: json.encode({'userId': userId}),
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Group.fromJson(data);
      } else {
        throw Exception('Failed to join group: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error joining group: $e');
    }
  }

  // Get groups by creator
  static Future<List<Group>> getGroupsByCreator(String creatorId) async {
    try {
      final response = await _makeAuthenticatedRequest(
        (headers) => http.get(
          Uri.parse('$baseUrl/api/groups/creator/$creatorId'),
          headers: headers,
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Group.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load groups: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting groups by creator: $e');
    }
  }

  // Get groups by event
  static Future<List<Group>> getGroupsByEvent(String eventId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/groups/event/$eventId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Group.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load groups: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting groups by event: $e');
    }
  }

  // Get groups by member
  static Future<List<Group>> getGroupsByMember(String userId) async {
    try {
      print('🔍 Fetching groups for user: $userId');
      final url = '$baseUrl/api/groups/member/$userId';
      print('📍 URL: $url');

      final response = await _makeAuthenticatedRequest((headers) {
        print('🔑 Auth Token present: ${headers.containsKey("Authorization")}');
        return http.get(Uri.parse(url), headers: headers);
      });

      print('📡 Response status: ${response.statusCode}');
      print('📦 Response Content-Type: ${response.headers['content-type']}');

      // Solo mostrar preview si no es muy largo
      final bodyPreview = response.body.length > 500
          ? response.body.substring(0, 500)
          : response.body;
      print('📦 Response body preview: $bodyPreview');

      // Verificar si la respuesta es JSON
      if (!response.headers['content-type']!.contains('application/json')) {
        print(
          '❌ Response is not JSON! Content-Type: ${response.headers['content-type']}',
        );
        throw Exception(
          'Backend returned HTML instead of JSON. Check authentication or endpoint configuration.',
        );
      }

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('✅ Found ${data.length} groups');
        return data.map((json) => Group.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load groups: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error getting groups by member: $e');
      throw Exception('Error getting groups by member: $e');
    }
  }

  // Get all groups
  static Future<List<Group>> getAllGroups() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/groups'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Group.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load groups: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting all groups: $e');
    }
  }

  // Add member to group
  static Future<Group> addMemberToGroup(String groupId, String userId) async {
    try {
      final response = await _makeAuthenticatedRequest(
        (headers) => http.post(
          Uri.parse('$baseUrl/api/groups/$groupId/members/$userId'),
          headers: headers,
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Group.fromJson(data);
      } else {
        throw Exception('Failed to add member: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error adding member to group: $e');
    }
  }

  // Remove member from group
  static Future<Group> removeMemberFromGroup(
    String groupId,
    String userId,
  ) async {
    try {
      final response = await _makeAuthenticatedRequest(
        (headers) => http.delete(
          Uri.parse('$baseUrl/api/groups/$groupId/members/$userId'),
          headers: headers,
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Group.fromJson(data);
      } else {
        throw Exception('Failed to remove member: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error removing member from group: $e');
    }
  }

  // Update group
  static Future<Group> updateGroup({
    required String groupId,
    String? name,
    String? description,
    int? maxMembers,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (description != null) body['description'] = description;
      if (maxMembers != null) body['maxMembers'] = maxMembers;

      final response = await _makeAuthenticatedRequest(
        (headers) => http.put(
          Uri.parse('$baseUrl/api/groups/$groupId'),
          headers: headers,
          body: json.encode(body),
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Group.fromJson(data);
      } else {
        throw Exception('Failed to update group: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating group: $e');
    }
  }

  // Generate new invite code
  static Future<String> generateNewInviteCode(String groupId) async {
    try {
      final response = await _makeAuthenticatedRequest(
        (headers) => http.post(
          Uri.parse('$baseUrl/api/groups/$groupId/regenerate-invite'),
          headers: headers,
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['inviteCode'] as String;
      } else {
        throw Exception(
          'Failed to generate invite code: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error generating invite code: $e');
    }
  }

  // Delete group
  static Future<void> deleteGroup(String groupId) async {
    try {
      final response = await _makeAuthenticatedRequest(
        (headers) => http.delete(
          Uri.parse('$baseUrl/api/groups/$groupId'),
          headers: headers,
        ),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete group: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting group: $e');
    }
  }
}
