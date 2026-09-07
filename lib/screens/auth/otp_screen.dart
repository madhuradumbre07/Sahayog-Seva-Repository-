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

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  static const String routeName = '/otp-verification';

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _controllers = List.generate(6, (_) => TextEditingController());
  final _nodes = List.generate(6, (_) => FocusNode());
  Timer? _ticker;
  bool _invalid = false;
  bool _expiredMessage = false;
  bool _verifying = false;
  bool _success = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _nodes.first.requestFocus();
      _scheduleTick();
    });
  }

  void _scheduleTick() {
    _ticker?.cancel();
    if (!mounted) return;
    final remaining = _remaining(context.read<AuthProvider>());
    if (remaining <= Duration.zero) return;
    _ticker = Timer(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() {});
      _scheduleTick();
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _nodes) {
      node.dispose();
    }
    super.dispose();
  }

  String get _code => _controllers.map((c) => c.text).join();

  Duration _remaining(AuthProvider auth) {
    final expires = auth.otpExpiresAt;
    if (expires == null) return Duration.zero;
    final remaining = expires.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  void _onChanged(int index, String value) {
    if (value.isNotEmpty && !RegExp(r'^\d+$').hasMatch(value)) {
      _controllers[index].clear();
      setState(() {
        _invalid = true;
        _errorText = context.tr('digitsOnly');
      });
      return;
    }

    if (value.length > 1) {
      final digits = value.replaceAll(RegExp(r'\D'), '');
      for (var i = 0; i < 6; i++) {
        _controllers[i].text = i < digits.length ? digits[i] : '';
      }
      final next = digits.length.clamp(0, 5);
      _nodes[next].requestFocus();
      setState(() {
        _invalid = false;
        _errorText = null;
      });
      return;
    }

    if (value.isNotEmpty && index < 5) {
      _nodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _nodes[index - 1].requestFocus();
    }
    setState(() {
      _invalid = false;
      _expiredMessage = false;
      _errorText = null;
    });
  }

  Future<void> _verify() async {
    final auth = context.read<AuthProvider>();
    final language = context.read<LanguageProvider>();
    final online = await language.checkConnectivity();
    if (!online || !mounted) return;

    if (_code.length != 6) {
      setState(() {
        _invalid = true;
        _errorText = context.tr('invalidOtp');
      });
      return;
    }

    setState(() {
      _verifying = true;
      _errorText = null;
    });
    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    final result = auth.verifyOtp(_code);
    if (result == OtpVerifyResult.success) {
      // Sync live profile from database for returning users
      await auth.syncUserProfileFromBackend(mobile: auth.phoneDigits);
      if (!mounted) return;

      setState(() {
        _verifying = false;
        _success = true;
      });
      await Future<void>.delayed(const Duration(milliseconds: 900));
      if (!mounted) return;

      if (auth.hasSelectedRole && auth.isCurrentRoleRegistered) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        Navigator.pushReplacementNamed(context, '/workspace-selection');
      }
      return;
    }

    setState(() {
      _verifying = false;
      _invalid = result == OtpVerifyResult.invalid;
      _expiredMessage = result == OtpVerifyResult.expired;
      _errorText = result == OtpVerifyResult.expired
          ? context.tr('otpExpired')
          : context.tr('invalidOtp');
    });
  }

  Future<void> _resend() async {
    final language = context.read<LanguageProvider>();
    final online = await language.checkConnectivity();
    if (!online || !mounted) return;
    await context.read<AuthProvider>().sendOtp();
    for (final controller in _controllers) {
      controller.clear();
    }
    _nodes.first.requestFocus();
    setState(() {
      _invalid = false;
      _expiredMessage = false;
      _errorText = null;
    });
    _scheduleTick();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final language = context.watch<LanguageProvider>();
    final remaining = _remaining(auth);
    final canResend = remaining == Duration.zero;
    final timeLabel = auth.formatCountdown(remaining);
    final skylineHeight = MediaQuery.sizeOf(context).height * 0.16;

    if (!language.isOnline) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: NetworkErrorView(
          onTryAgain: () => language.checkConnectivity(),
        ),
      );
    }

    if (auth.isLocked) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: TooManyAttemptsView(
          countdown: auth.formatCountdown(auth.lockRemaining),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: CommunitySkyline(height: skylineHeight),
          ),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(
                              Icons.arrow_back,
                              color: AppColors.primary,
                            ),
                          ),
                          const Spacer(),
                          const LanguageSelectorButton(),
                        ],
                      ),
                      const HandshakeLogo(size: 56),
                      const SizedBox(height: 12),
                      Text(
                        context.tr('verifyNumber'),
                        textAlign: TextAlign.center,
                        style: AppTypography.heading(fontSize: 22),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        context.tr(
                          'otpSentTo',
                          params: {'phone': auth.formattedPhone},
                        ),
                        textAlign: TextAlign.center,
                        style: AppTypography.subtitle(fontSize: 13),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          context.tr('changeNumber'),
                          style: AppTypography.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          context.tr('enterOtp'),
                          style: AppTypography.subtitle(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(6, (index) {
                          return _OtpBox(
                            controller: _controllers[index],
                            focusNode: _nodes[index],
                            invalid: _invalid || _expiredMessage,
                            onChanged: (value) => _onChanged(index, value),
                          );
                        }),
                      ),
                      if (_errorText != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          _errorText!,
                          style: AppTypography.poppins(
                            fontSize: 13,
                            color: AppColors.error,
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      Text(
                        '${context.tr('didntGetOtp')} ${canResend ? '' : timeLabel}'
                            .trim(),
                        textAlign: TextAlign.center,
                        style: AppTypography.subtitle(fontSize: 13),
                      ),
                      TextButton(
                        onPressed: canResend ? _resend : null,
                        child: Text(
                          canResend
                              ? context.tr('resendOtp')
                              : context.tr(
                                  'resendAvailableAfter',
                                  params: {'time': timeLabel},
                                ),
                          style: AppTypography.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: canResend
                                ? AppColors.primary
                                : AppColors.muted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: Column(
                    children: [
                      PrimaryButton(
                        label: _expiredMessage
                            ? context.tr('resendOtp')
                            : context.tr('verifyOtp'),
                        enabled: _expiredMessage || _code.length == 6,
                        allowTapWhenDisabled: true,
                        loading: _verifying,
                        onPressed: _expiredMessage ? _resend : _verify,
                      ),
                      const SizedBox(height: 12),
                      TextButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(context.tr('contactUs'))),
                          );
                        },
                        icon: const Icon(
                          Icons.headset_mic,
                          color: AppColors.primary,
                        ),
                        label: Text(
                          context.tr('contactUs'),
                          style: AppTypography.poppins(
                            fontSize: 13,
                            color: AppColors.subtitle,
                          ),
                        ),
                      ),
                      const SecurityBadge(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_verifying || _success)
            ColoredBox(
              color: AppColors.overlayScrim,
              child: Center(
                child: _success
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: AppColors.success,
                            size: 72,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            context.tr('success'),
                            style: AppTypography.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onPrimary,
                            ),
                          ),
                          Text(
                            context.tr('redirecting'),
                            style: AppTypography.poppins(
                              color: AppColors.onPrimary,
                            ),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(
                            color: AppColors.onPrimary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            context.tr('verifyingOtp'),
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
      ),
    );
  }
}

class _OtpBox extends StatelessWidget {
  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.invalid,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool invalid;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 56,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 6,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: onChanged,
        style: AppTypography.poppins(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: AppColors.background,
          enabledBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(
              color: invalid ? AppColors.error : AppColors.border,
              width: invalid ? 2 : 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(
              color: invalid ? AppColors.error : AppColors.primary,
              width: 2,
            ),
          ),
        ),
      ),
    );
  }
}
