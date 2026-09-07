import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../l10n/l10n.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/community_skyline.dart';
import '../../widgets/handshake_logo.dart';
import '../../widgets/language_selector_button.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/status_views.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static const String routeName = '/login';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  bool _sending = false;
  bool _showInvalid = false;
  Timer? _lockTicker;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.phoneDigits.isNotEmpty) {
        _phoneController.text = auth.phoneDigits;
      }
      context.read<LanguageProvider>().checkConnectivity();
      _ensureLockTicker();
    });
  }

  void _ensureLockTicker() {
    final auth = context.read<AuthProvider>();
    if (!auth.isLocked) return;
    _lockTicker ??= Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (!context.read<AuthProvider>().isLocked) {
        _lockTicker?.cancel();
        _lockTicker = null;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    _lockTicker?.cancel();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final auth = context.read<AuthProvider>();
    final language = context.read<LanguageProvider>();
    final digits = _phoneController.text.replaceAll(RegExp(r'\D'), '');
    auth.setPhoneDigits(digits);

    if (!AuthProvider.isValidMobile(digits)) {
      setState(() => _showInvalid = true);
      return;
    }

    final online = await language.checkConnectivity();
    if (!online || !mounted) return;

    setState(() => _sending = true);
    await Future<void>.delayed(const Duration(milliseconds: 700));
    final sent = await auth.sendOtp();
    if (!mounted) return;
    setState(() => _sending = false);
    _ensureLockTicker();
    if (sent) {
      Navigator.pushNamed(context, '/otp-verification');
    }
  }

  Future<void> _googleLogin() async {
    final language = context.read<LanguageProvider>();
    final online = await language.checkConnectivity();
    if (!online || !mounted) return;
    await context.read<AuthProvider>().signInWithGoogle();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/workspace-selection');
  }

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>();
    final auth = context.watch<AuthProvider>();
    final digits = _phoneController.text.replaceAll(RegExp(r'\D'), '');
    final isValid = AuthProvider.isValidMobile(digits);
    final skylineHeight = MediaQuery.sizeOf(context).height * 0.18;

    Widget body;
    if (!language.isOnline) {
      body = NetworkErrorView(
        onTryAgain: () => language.checkConnectivity(),
      );
    } else if (auth.isLocked) {
      body = TooManyAttemptsView(
        countdown: auth.formatCountdown(auth.lockRemaining),
      );
    } else {
      body = Stack(
        fit: StackFit.expand,
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: CommunitySkyline(height: skylineHeight),
          ),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              children: [
                const Row(
                  children: [
                    Spacer(),
                    LanguageSelectorButton(),
                  ],
                ),
                const HandshakeLogo(size: 64),
                const SizedBox(height: 12),
                Text(
                  context.tr('welcomeTitle'),
                  textAlign: TextAlign.center,
                  style: AppTypography.heading(fontSize: 22),
                ),
                const SizedBox(height: 6),
                Text(
                  context.tr('welcomeTagline'),
                  textAlign: TextAlign.center,
                  style: AppTypography.subtitle(fontSize: 13),
                ),
                const SizedBox(height: 28),
                _PhoneField(
                  controller: _phoneController,
                  hint: context.tr('phoneHint'),
                  isValid: isValid,
                  showInvalid: _showInvalid && !isValid && digits.isNotEmpty,
                  errorText: context.tr('invalidNumber'),
                  onChanged: (value) {
                    final next = value.replaceAll(RegExp(r'\D'), '');
                    auth.setPhoneDigits(next);
                    setState(() => _showInvalid = next.isNotEmpty && !AuthProvider.isValidMobile(next));
                  },
                ),
                const SizedBox(height: 20),
                PrimaryButton(
                  label: context.tr('sendOtp'),
                  enabled: isValid,
                  loading: _sending,
                  onPressed: _sendOtp,
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    const Expanded(child: Divider(color: AppColors.border)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        context.tr('orContinueWith'),
                        style: AppTypography.poppins(
                          fontSize: 12,
                          color: AppColors.muted,
                        ),
                      ),
                    ),
                    const Expanded(child: Divider(color: AppColors.border)),
                  ],
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: _googleLogin,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    side: const BorderSide(color: AppColors.border),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const _GoogleMark(),
                      const SizedBox(width: 10),
                      Text(
                        context.tr('continueWithGoogle'),
                        style: AppTypography.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  context.tr('termsDisclaimer'),
                  textAlign: TextAlign.center,
                  style: AppTypography.poppins(
                    fontSize: 11,
                    color: AppColors.muted,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                const SecurityBadge(),
              ],
            ),
          ),
          if (auth.googleLoading)
            ColoredBox(
              color: AppColors.overlayScrim,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: AppColors.onPrimary),
                    const SizedBox(height: 16),
                    Text(
                      context.tr('googleSigningIn'),
                      style: AppTypography.poppins(
                        color: AppColors.onPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      );
    }

    return Scaffold(backgroundColor: AppColors.background, body: body);
  }
}

class _PhoneField extends StatelessWidget {
  const _PhoneField({
    required this.controller,
    required this.hint,
    required this.isValid,
    required this.showInvalid,
    required this.errorText,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String hint;
  final bool isValid;
  final bool showInvalid;
  final String errorText;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final borderColor = showInvalid
        ? AppColors.error
        : isValid
        ? AppColors.success
        : AppColors.border;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: AppColors.inputFill,
            borderRadius: const BorderRadius.all(Radius.circular(12)),
            border: Border.all(color: borderColor, width: isValid || showInvalid ? 2 : 1),
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 14),
                child: Text(
                  '+91',
                  style: AppTypography.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                width: 1,
                height: 28,
                margin: const EdgeInsets.symmetric(horizontal: 12),
                color: AppColors.border,
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: onChanged,
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: hint,
                    hintStyle: AppTypography.poppins(
                      fontSize: 14,
                      color: AppColors.muted,
                    ),
                    border: InputBorder.none,
                    suffixIcon: isValid
                        ? const Icon(Icons.check_circle, color: AppColors.success)
                        : showInvalid
                        ? const Icon(Icons.error, color: AppColors.error)
                        : null,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showInvalid) ...[
          const SizedBox(height: 6),
          Text(
            errorText,
            style: AppTypography.poppins(fontSize: 12, color: AppColors.error),
          ),
        ],
      ],
    );
  }
}

class _GoogleMark extends StatelessWidget {
  const _GoogleMark();

  @override
  Widget build(BuildContext context) {
    return const SizedBox.square(
      dimension: 22,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.background,
          shape: BoxShape.circle,
          border: Border.fromBorderSide(BorderSide(color: AppColors.border)),
        ),
        child: Center(
          child: Text(
            'G',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 14,
              color: Color(0xFF4285F4),
            ),
          ),
        ),
      ),
    );
  }
}
