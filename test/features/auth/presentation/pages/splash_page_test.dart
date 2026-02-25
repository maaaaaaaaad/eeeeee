import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_owner/core/error/failure.dart';
import 'package:mobile_owner/core/storage/secure_token_storage.dart';
import 'package:mobile_owner/features/auth/domain/entities/owner.dart';
import 'package:mobile_owner/features/auth/domain/repositories/auth_repository.dart';
import 'package:mobile_owner/features/auth/presentation/pages/splash_page.dart';
import 'package:mobile_owner/features/auth/presentation/providers/auth_provider.dart';

class MockSecureTokenStorage extends Mock implements SecureTokenStorage {}

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockSecureTokenStorage mockTokenStorage;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockTokenStorage = MockSecureTokenStorage();
    mockAuthRepository = MockAuthRepository();
  });

  const testOwner = Owner(
    id: 'owner-1',
    businessNumber: '123-45-67890',
    phoneNumber: '010-1234-5678',
    nickname: 'TestOwner',
    email: 'owner@test.com',
  );

  Widget createWidget() {
    return ProviderScope(
      overrides: [
        tokenStorageProvider.overrideWithValue(mockTokenStorage),
        authRepositoryProvider.overrideWithValue(mockAuthRepository),
      ],
      child: MaterialApp(
        home: const SplashPage(),
        routes: {
          '/home': (_) => const Scaffold(body: Text('HomePage')),
          '/login': (_) => const Scaffold(body: Text('LoginPage')),
        },
      ),
    );
  }

  group('SplashPage', () {
    testWidgets('should display splash UI', (tester) async {
      when(() => mockTokenStorage.hasToken()).thenAnswer((_) async => false);

      await tester.pumpWidget(createWidget());

      expect(find.text('젤로마크 사장님'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();
    });

    testWidgets('should navigate to login when no token exists',
        (tester) async {
      when(() => mockTokenStorage.hasToken()).thenAnswer((_) async => false);

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('LoginPage'), findsOneWidget);
      verifyNever(() => mockAuthRepository.getCurrentOwner());
    });

    testWidgets('should navigate to home when token is valid',
        (tester) async {
      when(() => mockTokenStorage.hasToken()).thenAnswer((_) async => true);
      when(() => mockAuthRepository.getCurrentOwner())
          .thenAnswer((_) async => const Right(testOwner));

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('HomePage'), findsOneWidget);
    });

    testWidgets(
        'should clear tokens and navigate to login when token is invalid',
        (tester) async {
      when(() => mockTokenStorage.hasToken()).thenAnswer((_) async => true);
      when(() => mockAuthRepository.getCurrentOwner())
          .thenAnswer((_) async => const Left(AuthFailure('인증이 필요합니다')));
      when(() => mockTokenStorage.clearTokens()).thenAnswer((_) async {});

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('LoginPage'), findsOneWidget);
      verify(() => mockTokenStorage.clearTokens()).called(1);
    });

    testWidgets(
        'should clear tokens and navigate to login when validation throws',
        (tester) async {
      when(() => mockTokenStorage.hasToken()).thenAnswer((_) async => true);
      when(() => mockAuthRepository.getCurrentOwner())
          .thenThrow(Exception('network error'));
      when(() => mockTokenStorage.clearTokens()).thenAnswer((_) async {});

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('LoginPage'), findsOneWidget);
      verify(() => mockTokenStorage.clearTokens()).called(1);
    });

    testWidgets('should navigate to login when hasToken throws',
        (tester) async {
      when(() => mockTokenStorage.hasToken()).thenThrow(Exception('storage error'));
      when(() => mockTokenStorage.clearTokens()).thenAnswer((_) async {});

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('LoginPage'), findsOneWidget);
    });
  });
}
