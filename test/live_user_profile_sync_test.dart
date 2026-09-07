import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sahayogseva/models/workspace_role.dart';
import 'package:sahayogseva/providers/auth_provider.dart';
import 'package:sahayogseva/providers/registration_provider.dart';
import 'package:sahayogseva/services/registration_api_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Live Database Profile Sync Tests', () {
    test('AuthProvider.syncUserProfileFromBackend updates names and roles from live DB response', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path.contains('/api/v1/auth/user/7021348455')) {
          return http.Response(
            jsonEncode({
              'found': true,
              'users': [
                {
                  'full_name': 'Saakshi Patil',
                  'mobile': '7021348455',
                  'email': 'saakshi@example.com',
                  'role': 'customer',
                  'location': 'Pune, Maharashtra',
                  'organization_name': 'Saakshi Enterprises',
                  'is_registered': true,
                }
              ]
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response('{"detail":"Not found"}', 404);
      });

      final apiService = RegistrationApiService(client: mockClient);
      final authProvider = AuthProvider(apiService: apiService);

      authProvider.setPhoneDigits('7021348455');
      final synced = await authProvider.syncUserProfileFromBackend(mobile: '7021348455');

      expect(synced, isTrue);
      expect(authProvider.customerName, equals('Saakshi Patil'));
      expect(authProvider.registeredEmail, equals('saakshi@example.com'));
      expect(authProvider.isRoleRegistered(WorkspaceRoleId.customer), isTrue);
      expect(authProvider.activeRole, equals(WorkspaceRoleId.customer));
    });

    test('RegistrationProvider.loadSavedProfile fetches live profile from DB over dummy fallback', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path.contains('/api/v1/auth/profile/7021348455')) {
          return http.Response(
            jsonEncode({
              'full_name': 'Saakshi Patil',
              'mobile': '7021348455',
              'email': 'saakshi@example.com',
              'role': 'customer',
              'location': 'Pune, Maharashtra',
              'organization_name': 'Saakshi Enterprises',
              'is_registered': true,
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response('{"detail":"Not found"}', 404);
      });

      final apiService = RegistrationApiService(client: mockClient);
      final regProvider = RegistrationProvider(apiService: apiService);

      final profileData = await regProvider.loadSavedProfile(WorkspaceRoleId.customer, phone: '7021348455');

      expect(profileData, isNotNull);
      expect(profileData!.fullName, equals('Saakshi Patil'));
      expect(profileData.email, equals('saakshi@example.com'));
      expect(profileData.organizationName, equals('Saakshi Enterprises'));
    });

    test('Switching users: Sanjay (Worker) -> Logout -> Saakshi (Customer) completely clears old session', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path.contains('/api/v1/auth/user/9876543219')) {
          return http.Response(
            jsonEncode({
              'found': true,
              'users': [
                {
                  'full_name': 'Sanjay V. Patil',
                  'mobile': '9876543219',
                  'email': 'sanjay@example.com',
                  'role': 'worker',
                  'location': 'Kothrud, Pune',
                  'work_category': 'Electrician',
                  'is_registered': true,
                }
              ]
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        } else if (request.url.path.contains('/api/v1/auth/user/7021348455')) {
          return http.Response(
            jsonEncode({
              'found': true,
              'users': [
                {
                  'full_name': 'Saakshi',
                  'mobile': '7021348455',
                  'email': 'saa@gmail.com',
                  'role': 'customer',
                  'location': 'Mumbai',
                  'organization_name': 'Saakshi',
                  'is_registered': true,
                }
              ]
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response('{"detail":"Not found"}', 404);
      });

      final apiService = RegistrationApiService(client: mockClient);
      final authProvider = AuthProvider(apiService: apiService);
      final regProvider = RegistrationProvider(apiService: apiService);

      // 1. User 1: Login as Sanjay (Worker)
      authProvider.setPhoneDigits('9876543219');
      await authProvider.syncUserProfileFromBackend(mobile: '9876543219');

      expect(authProvider.workerName, equals('Sanjay V. Patil'));
      expect(authProvider.isRoleRegistered(WorkspaceRoleId.worker), isTrue);
      expect(authProvider.activeRole, equals(WorkspaceRoleId.worker));

      // 2. Sanjay logs out
      regProvider.reset();
      await authProvider.logout();

      expect(authProvider.phoneDigits, isEmpty);
      expect(authProvider.isRoleRegistered(WorkspaceRoleId.worker), isFalse);
      expect(authProvider.isAnyRoleRegistered, isFalse);
      expect(regProvider.fullName, isEmpty);

      // 3. User 2: Login as Saakshi (Customer)
      authProvider.setPhoneDigits('7021348455');
      await authProvider.syncUserProfileFromBackend(mobile: '7021348455');

      expect(authProvider.customerName, equals('Saakshi'));
      expect(authProvider.registeredEmail, equals('saa@gmail.com'));
      expect(authProvider.isRoleRegistered(WorkspaceRoleId.customer), isTrue);
      expect(authProvider.isRoleRegistered(WorkspaceRoleId.worker), isFalse); // Worker role of Sanjay must NOT linger
      expect(authProvider.activeRole, equals(WorkspaceRoleId.customer)); // Active role must switch to Customer
      expect(authProvider.workerName, isNot(equals('Sanjay V. Patil'))); // Sanjay's name must not be present
    });
  });
}
