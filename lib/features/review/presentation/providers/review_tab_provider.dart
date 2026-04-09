import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_owner/features/home/presentation/providers/home_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

final reviewTabNotifierProvider =
    NotifierProvider<ReviewTabNotifier, ReviewTabState>(
  () => ReviewTabNotifier(),
);

class ReviewTabNotifier extends Notifier<ReviewTabState> {
  static const _lastReadPrefix = 'review_last_read_count_';

  @override
  ReviewTabState build() {
    Future.microtask(() => _loadUnreadCounts());
    return const ReviewTabState();
  }

  Future<void> _loadUnreadCounts() async {
    final homeState = ref.read(homeNotifierProvider);
    final shops = homeState.shops;
    if (shops.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final unreadMap = <String, int>{};

    for (final shop in shops) {
      final lastRead = prefs.getInt('$_lastReadPrefix${shop.id}') ?? 0;
      final unread = shop.reviewCount - lastRead;
      if (unread > 0) unreadMap[shop.id] = unread;
    }

    state = state.copyWith(unreadCounts: unreadMap);
  }

  Future<void> markShopAsRead(String shopId, int currentCount) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('$_lastReadPrefix$shopId', currentCount);

    final updated = Map<String, int>.from(state.unreadCounts)..remove(shopId);
    state = state.copyWith(unreadCounts: updated);
  }

  Future<void> refresh() async {
    await _loadUnreadCounts();
  }
}

class ReviewTabState {
  final Map<String, int> unreadCounts;

  const ReviewTabState({this.unreadCounts = const {}});

  int get totalUnreadCount => unreadCounts.values.fold(0, (a, b) => a + b);

  int unreadCountFor(String shopId) => unreadCounts[shopId] ?? 0;

  ReviewTabState copyWith({Map<String, int>? unreadCounts}) {
    return ReviewTabState(
      unreadCounts: unreadCounts ?? this.unreadCounts,
    );
  }
}
