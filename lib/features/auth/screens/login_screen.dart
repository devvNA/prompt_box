import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/base_page.dart';
import '../../../core/widgets/brutal_button.dart';
import '../widgets/custom_text_field.dart';

enum AuthMode { signIn, signUp }

class LoginScreen extends StatefulWidget {
  final AuthMode initialMode;
  final void Function(String email, String password)? onSignIn;
  final void Function(String name, String email, String password)? onSignUp;

  const LoginScreen({
    super.key,
    this.initialMode = AuthMode.signIn,
    this.onSignIn,
    this.onSignUp,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late AuthMode _currentMode;
  bool _obscurePassword = true;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentMode = widget.initialMode;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool get _isSignIn => _currentMode == AuthMode.signIn;

  void _switchTab(AuthMode mode) {
    if (_currentMode != mode) {
      setState(() {
        _currentMode = mode;
      });
    }
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(
          top: 16,
          left: AppSpacing.pagePadding,
          right: AppSpacing.pagePadding,
          bottom: 24,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.ink,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.ink, width: 2),
            boxShadow: const [
              BoxShadow(
                color: Color(0x40000000),
                offset: Offset(3, 3),
                blurRadius: 6,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.info_outline, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (_isSignIn) {
      if (widget.onSignIn != null) {
        widget.onSignIn!(email, password);
      } else {
        _showToast('Berhasil masuk sebagai $email');
      }
    } else {
      final name = _nameController.text.trim();
      if (widget.onSignUp != null) {
        widget.onSignUp!(name, email, password);
      } else {
        _showToast('Pendaftaran akun baru $email diproses!');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF7EE),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.pagePadding,
              vertical: AppSpacing.md,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 390),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 20),
                  _buildTabSwitcher(),
                  const SizedBox(height: 20),
                  _buildForm(),
                  const SizedBox(height: 18),
                  _buildDivider(),
                  const SizedBox(height: 16),
                  _buildSocialButtons(),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Box Logo [P] with cartoon doodle marks
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            // Sketch doodle lines around the logo
            CustomPaint(
              size: const Size(64, 64),
              painter: _LogoDoodlePainter(),
            ),
            // Orange/Red Logo Box
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFFA5838),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.ink, width: 2.8),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.ink,
                    offset: Offset(3.5, 3.5),
                    blurRadius: 0,
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outline text
                  Text(
                    'P',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 38,
                      fontWeight: FontWeight.w900,
                      foreground: Paint()
                        ..style = PaintingStyle.stroke
                        ..strokeWidth = 4
                        ..color = AppColors.ink,
                    ),
                  ),
                  // White text with shadow
                  Text(
                    'P',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 38,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      shadows: const [
                        Shadow(color: AppColors.ink, offset: Offset(2, 2)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Brand Text
        Text(
          'PROMPTBOX',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 31,
            fontWeight: FontWeight.w900,
            color: AppColors.ink,
            letterSpacing: -0.5,
          ),
        ),

        const SizedBox(height: 2),

        // Slogan / Subtitle
        Text(
          'Ideas today. Better tomorrow.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF262626),
          ),
        ),
      ],
    );
  }

  Widget _buildTabSwitcher() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF7EE),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.ink, width: 2),
      ),
      child: Row(
        children: [
          // Sign In Tab
          Expanded(
            child: _buildTabItem(
              title: 'Sign In',
              isActive: _isSignIn,
              onTap: () => _switchTab(AuthMode.signIn),
            ),
          ),
          // Sign Up Tab
          Expanded(
            child: _buildTabItem(
              title: 'Sign Up',
              isActive: !_isSignIn,
              onTap: () => _switchTab(AuthMode.signUp),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem({
    required String title,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFFDE153) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? AppColors.ink : Colors.transparent,
            width: 2,
          ),
          boxShadow: isActive
              ? const [
                  BoxShadow(
                    color: AppColors.ink,
                    offset: Offset(2.5, 2.5),
                    blurRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 14.5,
            fontWeight: FontWeight.w700,
            color: isActive ? AppColors.ink : AppColors.muted,
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Name Field (Sign Up Only)
          if (!_isSignIn) ...[
            CustomTextField(
              label: 'NAME',
              controller: _nameController,
              hintText: 'John Doe',
              keyboardType: TextInputType.name,
              validator: (value) {
                if (!_isSignIn && (value == null || value.trim().isEmpty)) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
          ],

          // Email Field
          CustomTextField(
            label: 'EMAIL',
            controller: _emailController,
            hintText: 'you@example.com',
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your email';
              }
              final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
              if (!emailRegex.hasMatch(value.trim())) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),

          const SizedBox(height: 14),

          // Password Field
          CustomTextField(
            label: 'PASSWORD',
            controller: _passwordController,
            hintText: _isSignIn ? 'Enter your password' : 'Create a password',
            obscureText: _obscurePassword,
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                size: 20,
                color: const Color(0xFF262626),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),

          // Forgot Password Link (Sign In Only)
          if (_isSignIn) ...[
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () => _showToast('Fitur reset kata sandi telah dibuka!'),
                child: Text(
                  'Forgot password?',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2D5682),
                  ),
                ),
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Submit Button
          BrutalButton(
            text: _isSignIn ? 'Sign In' : 'Sign Up',
            icon: Icons.arrow_forward,
            isFullWidth: true,
            onPressed: _handleSubmit,
          ),

          const SizedBox(height: 16),

          // Dev Bypass Button
          BrutalButton(
            text: 'Dev Bypass to Dashboard',
            icon: Icons.developer_mode,
            isFullWidth: true,
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const BasePage()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(
          child: Divider(color: Color(0xFFD4D4D4), thickness: 1.5),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'or continue with',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF525252),
            ),
          ),
        ),
        const Expanded(
          child: Divider(color: Color(0xFFD4D4D4), thickness: 1.5),
        ),
      ],
    );
  }

  Widget _buildSocialButtons() {
    return Column(
      children: [
        // Continue with Google
        _SocialButton(
          text: 'Continue with Google',
          icon: SizedBox(
            width: 20,
            height: 20,
            child: SvgPicture.asset('assets/icons/google.svg'),
          ),
          onTap: () => _showToast('Melanjutkan dengan Akun Google...'),
        ),

        const SizedBox(height: 10),

        // Continue with Apple
        _SocialButton(
          text: 'Continue with Apple',
          icon: const Icon(Icons.apple, size: 22, color: AppColors.ink),
          onTap: () => _showToast('Melanjutkan dengan Akun Apple...'),
        ),
      ],
    );
  }
}

class _SocialButton extends StatefulWidget {
  final String text;
  final Widget icon;
  final VoidCallback onTap;

  const _SocialButton({
    required this.text,
    required this.icon,
    required this.onTap,
  });

  @override
  State<_SocialButton> createState() => _SocialButtonState();
}

class _SocialButtonState extends State<_SocialButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: Transform.translate(
        offset: _isPressed ? const Offset(1.5, 1.5) : Offset.zero,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 10.5, horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFFAF7EE),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.ink, width: 2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              widget.icon,
              const SizedBox(width: 12),
              Text(
                widget.text,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogoDoodlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.ink
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.8;

    // Top-right doodle line 1
    final path1 = Path();
    path1.moveTo(size.width + 12, -4);
    path1.quadraticBezierTo(size.width + 20, -12, size.width + 26, -16);
    canvas.drawPath(path1, paint);

    // Top-right doodle line 2
    final path2 = Path();
    path2.moveTo(size.width + 18, 5);
    path2.quadraticBezierTo(size.width + 24, 2, size.width + 28, 1);
    canvas.drawPath(path2, paint);

    // Left doodle line 1
    final path3 = Path();
    path3.moveTo(-10, size.height * 0.48);
    path3.quadraticBezierTo(-18, size.height * 0.46, -24, size.height * 0.44);
    canvas.drawPath(path3, paint);

    // Left doodle line 2
    final path4 = Path();
    path4.moveTo(-8, size.height * 0.72);
    path4.quadraticBezierTo(-14, size.height * 0.64, -20, size.height * 0.58);
    canvas.drawPath(path4, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
