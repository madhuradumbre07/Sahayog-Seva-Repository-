import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sahayogseva/l10n/l10n.dart';
import 'package:sahayogseva/models/registration_data.dart';
import 'package:sahayogseva/models/workspace_role.dart';
import 'package:sahayogseva/providers/auth_provider.dart';
import 'package:sahayogseva/providers/language_provider.dart';
import 'package:sahayogseva/providers/registration_provider.dart';
import 'package:sahayogseva/screens/auth/registration_screen.dart';

Widget createRegistrationTestApp({
  WorkspaceRoleId role = WorkspaceRoleId.worker,
  String languageCode = 'en',
  RegistrationProvider? registrationProvider,
  AuthProvider? authProvider,
}) {
  final langProv = LanguageProvider();
  langProv.setLanguage(languageCode);

  final auth = authProvider ?? AuthProvider();
  final reg = registrationProvider ?? RegistrationProvider();
  reg.setRole(role);

  return MultiProvider(
    providers: [
      ChangeNotifierProvider<LanguageProvider>.value(value: langProv),
      ChangeNotifierProvider<AuthProvider>.value(value: auth),
      ChangeNotifierProvider<RegistrationProvider>.value(value: reg),
    ],
    child: MaterialApp(
      locale: Locale(languageCode),
      home: AppLocaleScope(
        locale: Locale(languageCode),
        child: RegistrationScreen(initialRole: role),
      ),
      routes: {
        '/login': (context) => const Scaffold(body: Text('Login Screen')),
        '/home': (context) => const Scaffold(body: Text('Home Screen')),
      },
    ),
  );
}

void main() {
  group('Role-Based Registration Screen Tests', () {
    testWidgets('Worker Registration Form renders with all role-specific fields', (tester) async {
      await tester.pumpWidget(createRegistrationTestApp(role: WorkspaceRoleId.worker));
      await tester.pumpAndSettle();

      // Top bar & Title
      expect(find.text('Create your account'), findsOneWidget);
      expect(find.text('Join as a Worker and start getting work'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      expect(find.text('Register'), findsOneWidget);

      // Worker specific fields
      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Mobile Number'), findsOneWidget);
      expect(find.text('Email (Optional)'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Work Category'), findsOneWidget);
      expect(find.text('Location'), findsOneWidget);

      // Why Register as Worker Card
      expect(find.text('Why register as Worker?'), findsOneWidget);
      expect(find.textContaining('Get matched with verified jobs'), findsOneWidget);

      // CTA Button & Login link
      expect(find.text('Create Account'), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
    });

    testWidgets('Customer Registration Form renders with all role-specific fields', (tester) async {
      await tester.pumpWidget(createRegistrationTestApp(role: WorkspaceRoleId.customer));
      await tester.pumpAndSettle();

      expect(find.text('Join as a Customer to post and manage jobs'), findsOneWidget);
      expect(find.text('Organization / Name'), findsOneWidget);
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Why register as Customer?'), findsOneWidget);
      expect(find.textContaining('Post jobs, find skilled workers'), findsOneWidget);
    });

    testWidgets('Contractor Registration Form renders with Company & GST fields', (tester) async {
      await tester.pumpWidget(createRegistrationTestApp(role: WorkspaceRoleId.contractor));
      await tester.pumpAndSettle();

      expect(find.text('Join as a Contractor to manage projects'), findsOneWidget);
      expect(find.text('Company / Business Name'), findsOneWidget);
      expect(find.text('GST Number (Optional)'), findsOneWidget);
      expect(find.text('Why register as Contractor?'), findsOneWidget);
      expect(find.textContaining('Create projects, assign work'), findsOneWidget);
    });

    testWidgets('Co-operative Registration Form renders with Society & Registration Number', (tester) async {
      await tester.pumpWidget(createRegistrationTestApp(role: WorkspaceRoleId.cooperative));
      await tester.pumpAndSettle();

      expect(find.text('Join as a Co-operative to empower your community'), findsOneWidget);
      expect(find.text('Co-operative Name'), findsOneWidget);
      expect(find.text('Representative Name'), findsOneWidget);
      expect(find.text('Registration Number'), findsOneWidget);
      expect(find.text('Why register as Co-operative?'), findsOneWidget);
      expect(find.textContaining('Collaborate, share resources'), findsOneWidget);
    });

    testWidgets('Selecting "Other" in Work Category reveals custom text field', (tester) async {
      final reg = RegistrationProvider();
      reg.setRole(WorkspaceRoleId.worker);

      await tester.pumpWidget(createRegistrationTestApp(
        role: WorkspaceRoleId.worker,
        registrationProvider: reg,
      ));
      await tester.pumpAndSettle();

      // Initially other work category field is not visible
      expect(find.text('Other Work Category'), findsNothing);

      // Select 'serviceOther'
      reg.setWorkCategory('serviceOther');
      await tester.pumpAndSettle();

      expect(find.text('Other Work Category'), findsOneWidget);
    });

    testWidgets('Internationalization (i18n) renders correctly in Marathi (mr)', (tester) async {
      await tester.pumpWidget(createRegistrationTestApp(
        role: WorkspaceRoleId.worker,
        languageCode: 'mr',
      ));
      await tester.pumpAndSettle();

      expect(find.text('तुमचे खाते तयार करा'), findsOneWidget);
      expect(find.text('कामगार म्हणून सामील व्हा आणि काम मिळवणे सुरू करा'), findsOneWidget);
      expect(find.text('नोंदणी'), findsOneWidget);
      expect(find.text('पूर्ण नाव'), findsOneWidget);
      expect(find.text('मोबाईल नंबर'), findsOneWidget);
      expect(find.text('पासवर्ड'), findsOneWidget);
      expect(find.text('खाते तयार करा'), findsOneWidget);
      expect(find.text('लॉग इन करा'), findsOneWidget);
    });

    testWidgets('Internationalization (i18n) renders correctly in Hindi (hi)', (tester) async {
      await tester.pumpWidget(createRegistrationTestApp(
        role: WorkspaceRoleId.worker,
        languageCode: 'hi',
      ));
      await tester.pumpAndSettle();

      expect(find.text('अपना खाता बनाएं'), findsOneWidget);
      expect(find.text('एक कारीगर के रूप में जुड़ें और काम पाना शुरू करें'), findsOneWidget);
      expect(find.text('पंजीकरण'), findsOneWidget);
      expect(find.text('पूरा नाम'), findsOneWidget);
      expect(find.text('खाता बनाएं'), findsOneWidget);
    });

    test('RegistrationData serialization to backend and local map', () {
      const data = RegistrationData(
        role: WorkspaceRoleId.contractor,
        fullName: 'Rahul Sharma',
        mobile: '9876543210',
        email: 'rahul@example.com',
        password: 'securePassword123',
        location: 'Kothrud, Pune',
        companyName: 'Sharma Constructions',
        gstNumber: '27AAAAA0000A1Z5',
      );

      final backendJson = data.toBackendJson();
      expect(backendJson['role'], 'contractor');
      expect(backendJson['full_name'], 'Rahul Sharma');
      expect(backendJson['password'], 'securePassword123');
      expect(backendJson['company_name'], 'Sharma Constructions');
      expect(backendJson['gst_number'], '27AAAAA0000A1Z5');

      final localMap = data.toLocalMap();
      // Password must not be saved in local map
      expect(localMap.containsKey('password'), isFalse);
      expect(localMap['companyName'], 'Sharma Constructions');

      final restored = RegistrationData.fromLocalMap(localMap);
      expect(restored.role, WorkspaceRoleId.contractor);
      expect(restored.companyName, 'Sharma Constructions');
    });
  });
}
