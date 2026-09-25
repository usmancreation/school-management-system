import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _usernameController = TextEditingController(text: 'superadmin');
  final _passwordController = TextEditingController(text: 'Admin@123');
  bool _rememberMe = true;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    final auth = context.read<AuthProvider>();
    final success = await auth.login(
      _usernameController.text.trim(),
      _passwordController.text.trim(),
    );

    if (success && mounted) {
      context.go('/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      body: Row(
        children: [
          // Left Banner (Desktop Ergonomics)
          Expanded(
            flex: 5,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF0F172A), Color(0xFF1E3A8A), Color(0xFF1E293B)],
                ),
              ),
              padding: const EdgeInsets.all(48),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Oakridge International\nAcademy ERP',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Comprehensive institutional enterprise management powered by Flutter Desktop and high-performance PostgreSQL.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withValues(alpha: 0.8),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 48),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _featureChip('11 User Roles'),
                      _featureChip('PostgreSQL 16 Engine'),
                      _featureChip('Offline-Resilient Caching'),
                      _featureChip('Double-Entry Bursary'),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Right Form
          Expanded(
            flex: 4,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 32),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Welcome Back',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Sign in to access your administrative terminal',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                      const SizedBox(height: 32),

                      if (auth.errorMessage != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline, color: Colors.red, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  auth.errorMessage!,
                                  style: const TextStyle(color: Colors.red, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Username Input
                      const Text('Username / Email', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.person_outline, size: 20),
                          hintText: 'Enter username or email',
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Password Input
                      const Text('Password', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock_outline, size: 20),
                          hintText: 'Enter password',
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, size: 20),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Remember Me & Forgot
                      Row(
                        children: [
                          Checkbox(
                            value: _rememberMe,
                            onChanged: (v) => setState(() => _rememberMe = v ?? true),
                          ),
                          const Text('Remember Me', style: TextStyle(fontSize: 13)),
                          const Spacer(),
                          TextButton(
                            onPressed: () {},
                            child: const Text('Forgot Password?', style: TextStyle(fontSize: 13)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: auth.isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: auth.isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                )
                              : const Text('Sign In', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Quick Role Selector for testing
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.secondary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTheme.secondary.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.badge_outlined, size: 18, color: AppTheme.secondary),
                            const SizedBox(width: 8),
                            const Text('Quick Role:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.secondary)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  isExpanded: true,
                                  hint: const Text('Select Role to Autofill', style: TextStyle(fontSize: 12)),
                                  items: const [
                                    DropdownMenuItem(value: 'superadmin', child: Text('1. Super Admin', style: TextStyle(fontSize: 12))),
                                    DropdownMenuItem(value: 'admin', child: Text('2. Admin', style: TextStyle(fontSize: 12))),
                                    DropdownMenuItem(value: 'principal', child: Text('3. Principal', style: TextStyle(fontSize: 12))),
                                    DropdownMenuItem(value: 'viceprincipal', child: Text('4. Vice Principal', style: TextStyle(fontSize: 12))),
                                    DropdownMenuItem(value: 'teacher', child: Text('5. Teacher (Sarah Connor)', style: TextStyle(fontSize: 12))),
                                    DropdownMenuItem(value: 'accountant', child: Text('6. Accountant', style: TextStyle(fontSize: 12))),
                                    DropdownMenuItem(value: 'receptionist', child: Text('7. Receptionist', style: TextStyle(fontSize: 12))),
                                    DropdownMenuItem(value: 'student', child: Text('8. Student (Alexander)', style: TextStyle(fontSize: 12))),
                                    DropdownMenuItem(value: 'parent', child: Text('9. Parent / Guardian', style: TextStyle(fontSize: 12))),
                                    DropdownMenuItem(value: 'librarian', child: Text('10. Library Staff', style: TextStyle(fontSize: 12))),
                                    DropdownMenuItem(value: 'transport', child: Text('11. Transport Manager', style: TextStyle(fontSize: 12))),
                                  ],
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(() {
                                        _usernameController.text = val;
                                        _passwordController.text = 'Admin@123';
                                      });
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _featureChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }
}
