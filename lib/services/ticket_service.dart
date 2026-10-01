import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/booking_model.dart';

class TicketService {
  TicketService({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _tickets(String uid) =>
      _firestore.collection('users').doc(uid).collection('tickets');

  Stream<List<BookingModel>> watchMyTickets() =>
      _auth.authStateChanges().asyncExpand((user) {
        if (user == null) return Stream.value(const <BookingModel>[]);
        return _tickets(user.uid)
            .orderBy('createdAt', descending: true)
            .snapshots()
            .map((snapshot) => snapshot.docs
                .map((doc) => BookingModel.fromMap(doc.id, doc.data()))
                .toList(growable: false));
      });

  Future<BookingModel> savePurchase(BookingModel booking) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('Please sign in before completing a purchase.');
    }
    if (!booking.isPaid || booking.referenceCode.isEmpty) {
      throw ArgumentError('A completed simulated purchase is required.');
    }

    final document = _tickets(user.uid).doc();
    final typedEmail = booking.email.trim();
    final saved = BookingModel(
      id: document.id,
      movie: booking.movie,
      cinema: booking.cinema,
      date: booking.date,
      time: booking.time,
      seats: List.unmodifiable(booking.seats),
      total: booking.total,
      status: 'paid',
      food: List.unmodifiable(booking.food),
      referenceCode: booking.referenceCode,
      qrPayload: booking.qrPayload,
      isPaid: true,
      phone: booking.phone.replaceAll(RegExp(r'[\s-]'), ''),
      email: typedEmail.isNotEmpty ? typedEmail : (user.email ?? ''),
    );

    await document.set({
      'movie': saved.movie,
      'cinema': saved.cinema,
      'date': saved.date,
      'time': saved.time,
      'seats': saved.seats,
      'total': saved.total,
      'food': saved.food,
      'status': 'paid',
      'referenceCode': saved.referenceCode,
      'qrPayload': saved.qrPayload,
      'phone': saved.phone,
      'email': saved.email,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return saved;
  }
}