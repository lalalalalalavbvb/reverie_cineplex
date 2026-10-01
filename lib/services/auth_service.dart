import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    await syncDisplayNameFromFirestore();

    return credential;
  }

  Future<UserCredential> register({
    required String displayName,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final user = credential.user;

    if (user != null) {
      await user.updateDisplayName(displayName.trim());

      await user.reload();

      await _firestore.collection('users').doc(user.uid).set({
        'displayName': displayName.trim(),
        'email': email.trim(),
        'role': 'user',
      }, SetOptions(merge: true));
    }

    return credential;
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<bool> isAdmin() async {
    final user = _auth.currentUser;

    if (user == null) {
      return false;
    }

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();

      if (!doc.exists) {
        return false;
      }

      return doc.data()?['role'] == 'admin';
    } catch (_) {
      return false;
    }
  }

  Future<void> syncDisplayNameFromFirestore() async {
    final user = _auth.currentUser;

    if (user == null) {
      return;
    }

    final currentName = user.displayName?.trim() ?? '';

    if (currentName.isNotEmpty) {
      return;
    }

    try {
      final name = await _readFirestoreName(user.uid);

      if (name == null) {
        return;
      }

      await user.updateDisplayName(name);

      await user.reload();
    } catch (_) {
    }
  }

  Future<String?> _readFirestoreName(String uid) async {
    final doc = await _firestore
        .collection('users')
        .doc(uid)
        .get()
        .timeout(const Duration(seconds: 8));

    final data = doc.data();

    for (final key in const ['displayName', 'name']) {
      final value = data?[key];

      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }

    return null;
  }

  Future<String?> getDisplayName() async {
    final user = _auth.currentUser;

    if (user == null) {
      return null;
    }

    final authName = user.displayName?.trim() ?? '';

    if (authName.isNotEmpty) {
      return authName;
    }

    try {
      return await _readFirestoreName(user.uid);
    } catch (_) {
      return null;
    }
  }
}