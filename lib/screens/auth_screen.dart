import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'dashboard_screen.dart';

// ─── Design Tokens (from Figma) ───────────────────────────────────────────────
const _kGold = Color(0xFFC9A84C);
const _kGoldLight = Color(0xFFA8893A);
const _kCream = Color(0xFFE8D5A3);
const _kDark = Color(0xFF0D0D0D);
const _kFieldBg = Color(0x1AFFFFFF);      // white 10 %
const _kFieldBorder = Color(0x66C9A84C); // gold 40 %
const _kDivider = Color(0x33FFFFFF);      // white 20 %

// Luxury real estate background (Unsplash)
const _kBgImage =
    'https://images.unsplash.com/photo-1600210492486-724fe5c67fb0'
    '?auto=format&fit=crop&q=85&w=900';

// ─── Screen ───────────────────────────────────────────────────────────────────
enum _AuthView { login, signup, forgot }

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  _AuthView _view = _AuthView.login;

  // controllers
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController(text: 'angedemanou0@gmail.com');
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController(text: '••••••••');
  final _confirmCtrl = TextEditingController();

  bool _passVisible = false;
  bool _confirmVisible = false;
  bool _acceptTerms = false;

  void _goToDashboard() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, a, __) => const DashboardScreen(),
        transitionsBuilder: (_, a, __, child) =>
            FadeTransition(opacity: a, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontSize: 13)),
      backgroundColor: const Color(0xFF1C1917),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  // ── build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Image.network(_kBgImage, fit: BoxFit.cover),

          // Dark gradient overlay (bottom → top)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Color(0xCC0D0D0D), Color(0x660D0D0D)],
              ),
            ),
          ),

          // Content
          SafeArea(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              child: _view == _AuthView.login
                  ? _LoginContent(
                      key: const ValueKey('login'),
                      emailCtrl: _emailCtrl,
                      passCtrl: _passCtrl,
                      passVisible: _passVisible,
                      onTogglePass: () =>
                          setState(() => _passVisible = !_passVisible),
                      onLogin: _goToDashboard,
                      onGoSignup: () =>
                          setState(() => _view = _AuthView.signup),
                      onGoForgot: () =>
                          setState(() => _view = _AuthView.forgot),
                      onGoogleTap: () => _showSnack(
                          'Connexion Google — fonctionnalité à venir.'),
                      onAppleTap: () => _showSnack(
                          'Connexion Apple — fonctionnalité à venir.'),
                    )
                  : _view == _AuthView.signup
                      ? _SignupContent(
                          key: const ValueKey('signup'),
                          nameCtrl: _nameCtrl,
                          emailCtrl: _emailCtrl,
                          phoneCtrl: _phoneCtrl,
                          passCtrl: _passCtrl,
                          confirmCtrl: _confirmCtrl,
                          passVisible: _passVisible,
                          confirmVisible: _confirmVisible,
                          acceptTerms: _acceptTerms,
                          onTogglePass: () =>
                              setState(() => _passVisible = !_passVisible),
                          onToggleConfirm: () =>
                              setState(() => _confirmVisible = !_confirmVisible),
                          onToggleTerms: (v) =>
                              setState(() => _acceptTerms = v ?? false),
                          onSignup: _goToDashboard,
                          onGoLogin: () =>
                              setState(() => _view = _AuthView.login),
                          onGoogleTap: () => _showSnack(
                              'Connexion Google — fonctionnalité à venir.'),
                          onAppleTap: () => _showSnack(
                              'Connexion Apple — fonctionnalité à venir.'),
                        )
                      : _ForgotContent(
                          key: const ValueKey('forgot'),
                          emailCtrl: _emailCtrl,
                          onSend: () {
                            _showSnack('Lien de réinitialisation envoyé.');
                            setState(() => _view = _AuthView.login);
                          },
                          onBack: () =>
                              setState(() => _view = _AuthView.login),
                        ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// LOGIN CONTENT
// ═══════════════════════════════════════════════════════════════════════════════
class _LoginContent extends StatelessWidget {
  const _LoginContent({
    super.key,
    required this.emailCtrl,
    required this.passCtrl,
    required this.passVisible,
    required this.onTogglePass,
    required this.onLogin,
    required this.onGoSignup,
    required this.onGoForgot,
    required this.onGoogleTap,
    required this.onAppleTap,
  });

  final TextEditingController emailCtrl;
  final TextEditingController passCtrl;
  final bool passVisible;
  final VoidCallback onTogglePass;
  final VoidCallback onLogin;
  final VoidCallback onGoSignup;
  final VoidCallback onGoForgot;
  final VoidCallback onGoogleTap;
  final VoidCallback onAppleTap;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 120),

          // ── Branding ──────────────────────────────────────────────────────
          Center(
            child: Column(children: [
              Text(
                'ImmoSpace',
                style: GoogleFonts.playfairDisplay(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "L'immobilier autrement.",
                style: GoogleFonts.inter(
                  color: _kCream,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.8,
                ),
              ),
            ]),
          ),

          const SizedBox(height: 48),

          // ── Fields ────────────────────────────────────────────────────────
          _FigmaField(
            controller: emailCtrl,
            hint: 'Adresse e-mail',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          _FigmaField(
            controller: passCtrl,
            hint: 'Mot de passe',
            obscure: !passVisible,
            suffix: IconButton(
              icon: Icon(
                passVisible ? LucideIcons.eyeOff : LucideIcons.eye,
                size: 18,
                color: Colors.white54,
              ),
              onPressed: onTogglePass,
            ),
          ),

          // Forgot password link
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onGoForgot,
              child: Text(
                'Mot de passe oublié ?',
                style: GoogleFonts.inter(
                  color: _kCream,
                  fontSize: 13,
                  decoration: TextDecoration.underline,
                  decorationColor: _kCream,
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // ── CTA ───────────────────────────────────────────────────────────
          _GoldButton(label: 'SE CONNECTER', onTap: onLogin),

          const SizedBox(height: 32),
          const _Divider(),
          const SizedBox(height: 24),

          // ── Social ────────────────────────────────────────────────────────
          _SocialButton(
            icon: LucideIcons.globe,
            label: 'Continuer avec Google',
            onTap: onGoogleTap,
          ),
          const SizedBox(height: 12),
          _SocialButton(
            icon: LucideIcons.apple,
            label: 'Continuer avec Apple',
            onTap: onAppleTap,
          ),

          const SizedBox(height: 32),

          // ── Bottom links ──────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: onGoSignup,
                child: Text(
                  'Créer un compte',
                  style: GoogleFonts.inter(
                    color: _kCream,
                    fontSize: 14,
                    decoration: TextDecoration.underline,
                    decorationColor: _kCream,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => onLogin(),
                child: Text(
                  'Accès catalogue',
                  style: GoogleFonts.inter(
                    color: Colors.white54,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SIGN UP CONTENT
// ═══════════════════════════════════════════════════════════════════════════════
class _SignupContent extends StatelessWidget {
  const _SignupContent({
    super.key,
    required this.nameCtrl,
    required this.emailCtrl,
    required this.phoneCtrl,
    required this.passCtrl,
    required this.confirmCtrl,
    required this.passVisible,
    required this.confirmVisible,
    required this.acceptTerms,
    required this.onTogglePass,
    required this.onToggleConfirm,
    required this.onToggleTerms,
    required this.onSignup,
    required this.onGoLogin,
    required this.onGoogleTap,
    required this.onAppleTap,
  });

  final TextEditingController nameCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController phoneCtrl;
  final TextEditingController passCtrl;
  final TextEditingController confirmCtrl;
  final bool passVisible;
  final bool confirmVisible;
  final bool acceptTerms;
  final VoidCallback onTogglePass;
  final VoidCallback onToggleConfirm;
  final ValueChanged<bool?> onToggleTerms;
  final VoidCallback onSignup;
  final VoidCallback onGoLogin;
  final VoidCallback onGoogleTap;
  final VoidCallback onAppleTap;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 80),

          // ── Branding ──────────────────────────────────────────────────────
          Center(
            child: Column(children: [
              Text(
                'Créer un compte',
                style: GoogleFonts.playfairDisplay(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Rejoignez ImmoSpace dès aujourd'hui",
                style: GoogleFonts.inter(
                  color: _kCream,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ]),
          ),

          const SizedBox(height: 36),

          // ── Fields ────────────────────────────────────────────────────────
          _FigmaField(controller: nameCtrl, hint: 'Nom complet'),
          const SizedBox(height: 16),
          _FigmaField(
            controller: emailCtrl,
            hint: 'Adresse e-mail',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          _FigmaField(
            controller: phoneCtrl,
            hint: 'Numéro de téléphone',
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          _FigmaField(
            controller: passCtrl,
            hint: 'Mot de passe',
            obscure: !passVisible,
            suffix: IconButton(
              icon: Icon(
                passVisible ? LucideIcons.eyeOff : LucideIcons.eye,
                size: 18,
                color: Colors.white54,
              ),
              onPressed: onTogglePass,
            ),
          ),
          const SizedBox(height: 16),
          _FigmaField(
            controller: confirmCtrl,
            hint: 'Confirmer le mot de passe',
            obscure: !confirmVisible,
            suffix: IconButton(
              icon: Icon(
                confirmVisible ? LucideIcons.eyeOff : LucideIcons.eye,
                size: 18,
                color: Colors.white54,
              ),
              onPressed: onToggleConfirm,
            ),
          ),

          const SizedBox(height: 20),

          // ── Terms ─────────────────────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: Checkbox(
                  value: acceptTerms,
                  onChanged: onToggleTerms,
                  side: const BorderSide(color: _kGold, width: 1.5),
                  checkColor: _kDark,
                  activeColor: _kGold,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text.rich(
                  TextSpan(children: [
                    TextSpan(
                      text: "J'accepte les ",
                      style: GoogleFonts.inter(
                          color: _kCream,
                          fontSize: 13,
                          fontWeight: FontWeight.w500),
                    ),
                    TextSpan(
                      text: 'conditions générales',
                      style: GoogleFonts.inter(
                        color: _kGold,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.underline,
                        decorationColor: _kGold,
                      ),
                    ),
                    TextSpan(
                      text: ' et la ',
                      style: GoogleFonts.inter(
                          color: _kCream,
                          fontSize: 13,
                          fontWeight: FontWeight.w500),
                    ),
                    TextSpan(
                      text: 'politique de confidentialité',
                      style: GoogleFonts.inter(
                        color: _kGold,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.underline,
                        decorationColor: _kGold,
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          // ── CTA ───────────────────────────────────────────────────────────
          _GoldButton(label: 'CRÉER MON COMPTE', onTap: onSignup),

          const SizedBox(height: 28),
          const _Divider(),
          const SizedBox(height: 20),

          // ── Social ────────────────────────────────────────────────────────
          _SocialButton(
            icon: LucideIcons.globe,
            label: 'Continuer avec Google',
            onTap: onGoogleTap,
          ),
          const SizedBox(height: 12),
          _SocialButton(
            icon: LucideIcons.apple,
            label: 'Continuer avec Apple',
            onTap: onAppleTap,
          ),

          const SizedBox(height: 28),

          // ── Back to login ─────────────────────────────────────────────────
          Center(
            child: GestureDetector(
              onTap: onGoLogin,
              child: Text.rich(
                TextSpan(children: [
                  TextSpan(
                    text: 'Déjà inscrit ? ',
                    style: GoogleFonts.inter(
                        color: Colors.white54, fontSize: 14),
                  ),
                  TextSpan(
                    text: 'Se connecter',
                    style: GoogleFonts.inter(
                      color: _kCream,
                      fontSize: 14,
                      decoration: TextDecoration.underline,
                      decorationColor: _kCream,
                    ),
                  ),
                ]),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// FORGOT PASSWORD CONTENT
// ═══════════════════════════════════════════════════════════════════════════════
class _ForgotContent extends StatelessWidget {
  const _ForgotContent({
    super.key,
    required this.emailCtrl,
    required this.onSend,
    required this.onBack,
  });

  final TextEditingController emailCtrl;
  final VoidCallback onSend;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 140),

          Text(
            'Mot de passe oublié',
            style: GoogleFonts.playfairDisplay(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Saisissez votre e-mail pour recevoir un lien\nde réinitialisation sécurisé.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: _kCream,
              fontSize: 14,
              height: 1.6,
            ),
          ),

          const SizedBox(height: 40),

          _FigmaField(
            controller: emailCtrl,
            hint: 'Adresse e-mail',
            keyboardType: TextInputType.emailAddress,
          ),

          const SizedBox(height: 24),

          _GoldButton(label: 'ENVOYER LE LIEN', onTap: onSend),

          const SizedBox(height: 20),

          TextButton(
            onPressed: onBack,
            child: Text(
              '← Retour à la connexion',
              style: GoogleFonts.inter(
                color: Colors.white54,
                fontSize: 14,
                decoration: TextDecoration.underline,
                decorationColor: Colors.white54,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SHARED COMPONENTS
// ═══════════════════════════════════════════════════════════════════════════════

/// Figma-styled text field — semi-transparent with gold border
class _FigmaField extends StatelessWidget {
  const _FigmaField({
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.obscure = false,
    this.suffix,
  });

  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final bool obscure;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: ShapeDecoration(
        color: _kFieldBg,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1.18, color: _kFieldBorder),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              obscureText: obscure,
              style: GoogleFonts.inter(color: Colors.white, fontSize: 15),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: GoogleFonts.inter(
                  color: Colors.white54,
                  fontSize: 15,
                ),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          if (suffix != null) suffix!,
          if (suffix == null) const SizedBox(width: 16),
        ],
      ),
    );
  }
}

/// Gold gradient CTA button (Figma exact)
class _GoldButton extends StatelessWidget {
  const _GoldButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: ShapeDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_kGold, _kGoldLight],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          shadows: const [
            BoxShadow(
              color: Color(0x66C9A84C),
              blurRadius: 28,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.inter(
              color: _kDark,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }
}

/// "ou" divider
class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: _kDivider)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'ou',
            style: GoogleFonts.inter(color: _kCream, fontSize: 13),
          ),
        ),
        Expanded(child: Container(height: 1, color: _kDivider)),
      ],
    );
  }
}

/// Social login button (Google / Apple)
class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: ShapeDecoration(
          color: const Color(0x14FFFFFF), // white 8 %
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 1.18, color: _kDivider),
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Text(
              label,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
