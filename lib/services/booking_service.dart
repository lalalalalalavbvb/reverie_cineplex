import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/booking_model.dart';
import '../models/movie_model.dart';
import 'api_service.dart';

abstract class BookingService extends ChangeNotifier {
  List<BookingModel> get bookings;
  List<AdminItem> items(String category);
  Future<void> saveItem(String category, AdminItem item);
  Future<void> deleteItem(String category, String id);

  String buyerOf(String bookingId) => '';

  String buyerEmailOf(String bookingId) => '';
}

class CinemaCatalog {
  static const showtimeCategory = 'showtimes';
  static const foodCategory = 'อาหาร';
  static final FirestoreBookingService service = FirestoreBookingService();
  static final ApiService api = ApiService();
  static Future<List<MovieModel>> loadMovies() async {
    final now = await api.getNowPlaying();
    final upcoming = await api.getUpcoming();
    final byId = <int, MovieModel>{
      for (final movie in [...now, ...upcoming]) movie.id: movie,
    };
    return byId.values.toList();
  }
}

class FirestoreBookingService extends BookingService {
  FirestoreBookingService({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance {
    _authSubscription = _auth.authStateChanges().listen(_onAuthChanged);

    for (final entry in _collections.entries) {
      _subscriptions.add(
        _firestore
            .collection(entry.value)
            .snapshots()
            .listen(
              (snapshot) {
                final list = snapshot.docs.map(_fromDoc).toList()
                  ..sort(_compareFor(entry.key));
                _items[entry.key] = list;
                notifyListeners();
              },
              onError: (Object error) {
                debugPrint('โหลด ${entry.value} จาก Firestore ไม่สำเร็จ: $error');
              },
            ),
      );
    }
  }

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  static const Map<String, String> _collections = {
    CinemaCatalog.showtimeCategory: 'showtimes',
    CinemaCatalog.foodCategory: 'foods',
  };

  final Map<String, List<AdminItem>> _items = {};
  final List<StreamSubscription<QuerySnapshot<Map<String, dynamic>>>>
  _subscriptions = [];

  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _ticketsSubscription;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _usersSubscription;
  int _authGeneration = 0;
  List<BookingModel> _bookings = const [];
  final Map<String, String> _buyerUidByBooking = {};
  final Map<String, String> _userNames = {};
  final Map<String, String> _userEmails = {};

  Future<void> _onAuthChanged(User? user) async {
    final generation = ++_authGeneration;
    await _stopWatchingBookings();
    if (user == null) return;

    bool admin = false;
    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      admin = doc.data()?['role'] == 'admin';
    } catch (_) {}

    if (generation != _authGeneration || !admin) return;

    _ticketsSubscription = _firestore
        .collectionGroup('tickets')
        .snapshots()
        .listen(
          (snapshot) {
            final entries = <(DateTime, BookingModel)>[];
            _buyerUidByBooking.clear();
            for (final doc in snapshot.docs) {
              final data = doc.data();
              final booking = BookingModel.fromMap(doc.id, data);
              final createdAt = data['createdAt'];
              entries.add((
                createdAt is Timestamp ? createdAt.toDate() : DateTime.now(),
                booking,
              ));
              final buyerUid = doc.reference.parent.parent?.id;
              if (buyerUid != null) _buyerUidByBooking[doc.id] = buyerUid;
            }
            entries.sort((a, b) => b.$1.compareTo(a.$1));
            _bookings = [for (final e in entries) e.$2];
            notifyListeners();
          },
          onError: (Object error) {
            debugPrint('โหลดรายการจองไม่สำเร็จ: $error');
          },
        );

    _usersSubscription = _firestore
        .collection('users')
        .snapshots()
        .listen(
          (snapshot) {
            _userNames.clear();
            _userEmails.clear();
            for (final doc in snapshot.docs) {
              final data = doc.data();
              final name = (data['displayName'] as String?)?.trim() ?? '';
              final email = (data['email'] as String?)?.trim() ?? '';
              _userNames[doc.id] = name.isNotEmpty ? name : email;
              _userEmails[doc.id] = email;
            }
            notifyListeners();
          },
          onError: (Object error) {
            debugPrint('โหลดรายชื่อผู้ใช้ไม่สำเร็จ: $error');
          },
        );
  }

  Future<void> _stopWatchingBookings() async {
    await _ticketsSubscription?.cancel();
    await _usersSubscription?.cancel();
    _ticketsSubscription = null;
    _usersSubscription = null;
    final hadData = _bookings.isNotEmpty;
    _bookings = const [];
    _buyerUidByBooking.clear();
    _userNames.clear();
    _userEmails.clear();
    if (hadData) notifyListeners();
  }

  @override
  List<BookingModel> get bookings => _bookings;

  @override
  String buyerOf(String bookingId) {
    final uid = _buyerUidByBooking[bookingId];
    if (uid == null) return '';
    return _userNames[uid] ?? '';
  }

  @override
  String buyerEmailOf(String bookingId) {
    final uid = _buyerUidByBooking[bookingId];
    if (uid == null) return '';
    return _userEmails[uid] ?? '';
  }

  CollectionReference<Map<String, dynamic>> _collection(String category) {
    final name = _collections[category];
    if (name == null) {
      throw ArgumentError('ไม่รู้จักหมวด: $category');
    }
    return _firestore.collection(name);
  }

  static AdminItem _fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final price = data['price'];
    return AdminItem(
      id: doc.id,
      name: (data['name'] as String?) ?? '',
      detail: (data['detail'] as String?) ?? '',
      price: price is num ? price.toInt() : 0,
      image: (data['image'] as String?) ?? '',
    );
  }

  static int Function(AdminItem, AdminItem) _compareFor(String category) {
    if (category != CinemaCatalog.showtimeCategory) {
      return (a, b) => a.name.compareTo(b.name);
    }
    String key(AdminItem item) {
      final parts = item.detail.split('|');
      if (parts.length != 3) return item.detail;
      return '${parts[1]} ${parts[2]} ${parts[0]}';
    }

    return (a, b) => key(a).compareTo(key(b));
  }

  @override
  List<AdminItem> items(String category) =>
      List.unmodifiable(_items[category] ?? const <AdminItem>[]);

  @override
  Future<void> saveItem(String category, AdminItem item) async {
    await _collection(category).doc(item.id).set({
      'name': item.name,
      'detail': item.detail,
      'price': item.price,
      'image': item.image,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> deleteItem(String category, String id) async {
    await _collection(category).doc(id).delete();
  }

  @override
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _authSubscription?.cancel();
    _ticketsSubscription?.cancel();
    _usersSubscription?.cancel();
    super.dispose();
  }
}