import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TokenManager {
  static const String _tokenKey = 'google_id_token';
  static const String _tokenExpiryKey = 'token_expiry';
  static const String _lastRefreshKey = 'last_refresh';

  // Renovar token cada 50 minutos (Google tokens duran 1 hora)
  static const Duration _refreshInterval = Duration(minutes: 50);

  // URL del backend
  static const String baseUrl =
      'http://ec2-18-222-144-126.us-east-2.compute.amazonaws.com:8080';

  /// Guarda el token en almacenamiento local
  static Future<void> saveToken(String token, {int? expiresInSeconds}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);

    if (expiresInSeconds != null) {
      final expiryTime = DateTime.now().add(
        Duration(seconds: expiresInSeconds),
      );
      await prefs.setInt(_tokenExpiryKey, expiryTime.millisecondsSinceEpoch);
    }

    await prefs.setInt(_lastRefreshKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// Obtiene el token guardado
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// Verifica si el token necesita renovación
  static Future<bool> needsRefresh() async {
    final prefs = await SharedPreferences.getInstance();
    final lastRefresh = prefs.getInt(_lastRefreshKey);

    if (lastRefresh == null) return true;

    final lastRefreshTime = DateTime.fromMillisecondsSinceEpoch(lastRefresh);
    final timeSinceRefresh = DateTime.now().difference(lastRefreshTime);

    return timeSinceRefresh > _refreshInterval;
  }

  /// Verifica si el token ha expirado
  static Future<bool> isExpired() async {
    final prefs = await SharedPreferences.getInstance();
    final expiryTimestamp = prefs.getInt(_tokenExpiryKey);

    if (expiryTimestamp == null) return true;

    final expiryTime = DateTime.fromMillisecondsSinceEpoch(expiryTimestamp);
    return DateTime.now().isAfter(expiryTime);
  }

  /// Refresca el token con el backend
  static Future<bool> refreshToken() async {
    try {
      final token = await getToken();
      if (token == null) {
        print('❌ No token found to refresh');
        return false;
      }

      print('🔄 Refreshing token...');

      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'idToken': token}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['valid'] == true) {
          print('✅ Token is still valid');

          // Actualizar tiempo de último refresh
          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt(
            _lastRefreshKey,
            DateTime.now().millisecondsSinceEpoch,
          );

          // Si el backend nos da info de expiración, guardarla
          if (data['tokenInfo'] != null &&
              data['tokenInfo']['expiresAt'] != null) {
            final expiresAt = data['tokenInfo']['expiresAt'] as int;
            final expiryTime = DateTime.fromMillisecondsSinceEpoch(
              expiresAt * 1000,
            );
            await prefs.setInt(
              _tokenExpiryKey,
              expiryTime.millisecondsSinceEpoch,
            );
          }

          return true;
        }
      } else if (response.statusCode == 401) {
        print('❌ Token expired, need re-authentication');
        await clearToken();
        return false;
      }

      return false;
    } catch (e) {
      print('❌ Error refreshing token: $e');
      return false;
    }
  }

  /// Intenta renovar token si es necesario
  static Future<bool> ensureValidToken() async {
    // Si el token expiró, necesitamos re-autenticación
    if (await isExpired()) {
      print('⚠️ Token expired, clearing...');
      await clearToken();
      return false;
    }

    // Si necesita refresh (pero no expiró), intentar renovar
    if (await needsRefresh()) {
      return await refreshToken();
    }

    // Token válido y no necesita refresh
    return true;
  }

  /// Limpia el token guardado
  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_tokenExpiryKey);
    await prefs.remove(_lastRefreshKey);
  }

  /// Obtiene el token actual o lo renueva si es necesario
  static Future<String?> getValidToken() async {
    if (!await ensureValidToken()) {
      return null;
    }
    return await getToken();
  }
}
