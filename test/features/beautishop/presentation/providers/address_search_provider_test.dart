import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_owner/features/beautishop/data/datasources/geocode_remote_datasource.dart';
import 'package:mobile_owner/features/beautishop/data/models/geocode_result_model.dart';
import 'package:mobile_owner/features/beautishop/presentation/providers/address_search_provider.dart';

class MockGeocodeRemoteDataSource extends Mock
    implements GeocodeRemoteDataSource {}

void main() {
  late MockGeocodeRemoteDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockGeocodeRemoteDataSource();
  });

  ProviderContainer createContainer() {
    return ProviderContainer(
      overrides: [
        geocodeRemoteDataSourceProvider.overrideWithValue(mockDataSource),
      ],
    );
  }

  const testResults = [
    GeocodeResultModel(
      roadAddress: '서울특별시 강남구 테헤란로 123',
      jibunAddress: '서울특별시 강남구 역삼동 456',
      latitude: 37.5665,
      longitude: 126.978,
    ),
  ];

  group('AddressSearchNotifier', () {
    test('initial state should be initial status', () {
      final container = createContainer();
      addTearDown(container.dispose);

      final state = container.read(addressSearchNotifierProvider);
      expect(state.status, AddressSearchStatus.initial);
      expect(state.results, isEmpty);
    });

    test('should set success state with results on successful search',
        () async {
      when(() => mockDataSource.searchAddress(any()))
          .thenAnswer((_) async => testResults);

      final container = createContainer();
      addTearDown(container.dispose);

      final notifier =
          container.read(addressSearchNotifierProvider.notifier);
      await notifier.searchImmediate('강남구');

      final state = container.read(addressSearchNotifierProvider);
      expect(state.status, AddressSearchStatus.success);
      expect(state.results.length, 1);
      expect(state.results[0].roadAddress, '서울특별시 강남구 테헤란로 123');
    });

    test('should set error state on failure', () async {
      when(() => mockDataSource.searchAddress(any())).thenThrow(
        DioException(
          type: DioExceptionType.connectionTimeout,
          requestOptions: RequestOptions(),
        ),
      );

      final container = createContainer();
      addTearDown(container.dispose);

      final notifier =
          container.read(addressSearchNotifierProvider.notifier);
      await notifier.searchImmediate('강남구');

      final state = container.read(addressSearchNotifierProvider);
      expect(state.status, AddressSearchStatus.error);
      expect(state.errorMessage, isNotNull);
    });

    test('should set success with empty results when no matches', () async {
      when(() => mockDataSource.searchAddress(any()))
          .thenAnswer((_) async => []);

      final container = createContainer();
      addTearDown(container.dispose);

      final notifier =
          container.read(addressSearchNotifierProvider.notifier);
      await notifier.searchImmediate('존재하지않는주소');

      final state = container.read(addressSearchNotifierProvider);
      expect(state.status, AddressSearchStatus.success);
      expect(state.results, isEmpty);
    });

    test('should reset state to initial on clear', () async {
      when(() => mockDataSource.searchAddress(any()))
          .thenAnswer((_) async => testResults);

      final container = createContainer();
      addTearDown(container.dispose);

      final notifier =
          container.read(addressSearchNotifierProvider.notifier);
      await notifier.searchImmediate('강남구');
      notifier.clear();

      final state = container.read(addressSearchNotifierProvider);
      expect(state.status, AddressSearchStatus.initial);
      expect(state.results, isEmpty);
    });

    test('should not search when query is empty', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      final notifier =
          container.read(addressSearchNotifierProvider.notifier);
      await notifier.searchImmediate('');

      final state = container.read(addressSearchNotifierProvider);
      expect(state.status, AddressSearchStatus.initial);
      verifyNever(() => mockDataSource.searchAddress(any()));
    });

    test('should not search when query is only whitespace', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      final notifier =
          container.read(addressSearchNotifierProvider.notifier);
      await notifier.searchImmediate('   ');

      final state = container.read(addressSearchNotifierProvider);
      expect(state.status, AddressSearchStatus.initial);
      verifyNever(() => mockDataSource.searchAddress(any()));
    });
  });
}
