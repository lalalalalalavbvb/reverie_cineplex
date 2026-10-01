import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
    this.initialEmail,
  });

  final String? initialEmail;

  @override
  State<LoginPage> createState() =>
      _LoginPageState();
}

class _LoginPageState
    extends State<LoginPage> {
  late final TextEditingController
      _emailController;

  final TextEditingController
      _passwordController =
      TextEditingController();

  final AuthService _authService =
      AuthService();

  bool _loading = false;

  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();

    _emailController =
        TextEditingController(
      text: widget.initialEmail ?? '',
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  Future<void> _login() async {
    final email =
        _emailController.text.trim();

    final password =
        _passwordController.text;

    if (email.isEmpty) {
      _showMessage(
        'กรุณากรอก Email',
      );
      return;
    }

    if (password.isEmpty) {
      _showMessage(
        'กรุณากรอก Password',
      );
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      await _authService.login(
        email: email,
        password: password,
      );

      if (!mounted) return;

      Navigator.of(context).pop();
    } on FirebaseAuthException catch (e) {
      String message;

      switch (e.code) {
        case 'invalid-credential':
        case 'wrong-password':
        case 'user-not-found':
          message =
              'Email หรือ Password ไม่ถูกต้อง';
          break;

        case 'invalid-email':
          message =
              'รูปแบบ Email ไม่ถูกต้อง';
          break;

        case 'user-disabled':
          message =
              'บัญชีนี้ถูกปิดการใช้งาน';
          break;

        case 'too-many-requests':
          message =
              'ลองเข้าสู่ระบบบ่อยเกินไป กรุณารอสักครู่';
          break;

        case 'network-request-failed':
          message =
              'ไม่สามารถเชื่อมต่ออินเทอร์เน็ตได้';
          break;

        default:
          message =
              'เข้าสู่ระบบไม่สำเร็จ';
      }

      if (mounted) {
        _showMessage(message);
      }
    } catch (_) {
      if (mounted) {
        _showMessage(
          'เกิดข้อผิดพลาดในการเข้าสู่ระบบ',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  void _showMessage(
    String message,
  ) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  void _openRegister() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            const RegisterPage(),
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final theme =
        Theme.of(context);

    final colors =
        theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'เข้าสู่ระบบ',
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.all(28),
            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(
                maxWidth: 420,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.stretch,
                children: [

                  Icon(
                    Icons
                        .local_movies_rounded,
                    size: 72,
                    color:
                        colors.primary,
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  Text(
                    'Reverie Cineplex',
                    textAlign:
                        TextAlign.center,
                    style: theme
                        .textTheme
                        .headlineMedium
                        ?.copyWith(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  Text(
                    'เข้าสู่ระบบเพื่อใช้งานแอป',
                    textAlign:
                        TextAlign.center,
                    style: TextStyle(
                      color: colors
                          .onSurfaceVariant,
                    ),
                  ),

                  const SizedBox(
                    height: 40,
                  ),

                  TextField(
                    controller:
                        _emailController,
                    enabled:
                        !_loading,
                    keyboardType:
                        TextInputType
                            .emailAddress,
                    textInputAction:
                        TextInputAction.next,
                    decoration:
                        const InputDecoration(
                      labelText: 'Email',
                      hintText:
                          'กรอก Email',
                      prefixIcon:
                          Icon(
                        Icons
                            .email_outlined,
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  TextField(
                    controller:
                        _passwordController,
                    enabled:
                        !_loading,
                    obscureText:
                        _obscurePassword,
                    textInputAction:
                        TextInputAction.done,
                    onSubmitted: (_) {
                      if (!_loading) {
                        _login();
                      }
                    },
                    decoration:
                        InputDecoration(
                      labelText:
                          'Password',
                      hintText:
                          'กรอก Password',
                      prefixIcon:
                          const Icon(
                        Icons
                            .lock_outline,
                      ),
                      suffixIcon:
                          IconButton(
                        onPressed:
                            _loading
                                ? null
                                : () {
                                    setState(() {
                                      _obscurePassword =
                                          !_obscurePassword;
                                    });
                                  },
                        icon: Icon(
                          _obscurePassword
                              ? Icons
                                  .visibility_outlined
                              : Icons
                                  .visibility_off_outlined,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  SizedBox(
                    height: 52,
                    child:
                        FilledButton(
                      onPressed:
                          _loading
                              ? null
                              : _login,
                      child: _loading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth:
                                    2,
                              ),
                            )
                          : const Text(
                              'เข้าสู่ระบบ',
                              style:
                                  TextStyle(
                                fontSize:
                                    16,
                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  OutlinedButton(
                    onPressed:
                        _loading
                            ? null
                            : _openRegister,
                    child:
                        const Text(
                      'สมัครสมาชิก',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}