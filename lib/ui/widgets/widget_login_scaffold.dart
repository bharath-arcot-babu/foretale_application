import 'package:flutter/material.dart';
//auth amplify
import 'package:amplify_authenticator/amplify_authenticator.dart';
import 'package:foretale_application/ui/themes/text_styles.dart';
import 'package:foretale_application/core/constants/colors/app_colors.dart';
import 'package:foretale_application/ui/themes/button_styles.dart';

/// A widget that displays a logo, a body, and an optional footer.
class CustomLoginScaffold extends StatelessWidget {
  const CustomLoginScaffold({
    super.key,
    required this.state,
    required this.body,
    this.footer,
  });

  final AuthenticatorState state;
  final Widget body;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: TextStyles.inputMainTextStyle(context),
          filled: true,
          fillColor: Colors.transparent,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(
              color: BorderColors.secondaryColor,
              width: 1.2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(
              color: BorderColors.secondaryColor,
              width: 1.5,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(
              color: BorderColors.secondaryColor,
              width: 1.2,
            ),
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyles.elevatedButtonStyle(),
        ),
      ),
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: Center(
          child: SingleChildScrollView(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              margin: const EdgeInsets.all(24),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // App logo and title
                      Column(
                        children: [
                          const Icon(
                            Icons.analytics_outlined,
                            size: 64,
                            color: AppColors.primaryColor,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "foreTale",
                            style: TextStyles.appBarLogo(context),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Risk & Assurance Controls Testing Platform",
                            style: TextStyles.subtitleText(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      // Form body
                      Container(
                        constraints: const BoxConstraints(maxWidth: 400),
                        child: body,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        persistentFooterButtons: [_displayFooter(context)],
      ),
    );
  }

  //footer of the scaffold
  Widget _displayFooter(BuildContext context) {
    switch (state.currentStep) {
      case AuthenticatorStep.signIn:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Don't have an account?",
                style: TextStyles.footerTextSmall(context)),
            TextButton(
              onPressed: () => state.changeStep(
                AuthenticatorStep.signUp,
              ),
              child: Text("Sign Up",
                  style: TextStyles.footerLinkTextSmall(context)),
            ),
          ],
        );
      case AuthenticatorStep.signUp:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Already have an account? ",
                style: TextStyles.footerTextSmall(context)),
            TextButton(
              onPressed: () => state.changeStep(
                AuthenticatorStep.signIn,
              ),
              child: Text("Sign In",
                  style: TextStyles.footerLinkTextSmall(context)),
            ),
          ],
        );
      case AuthenticatorStep.confirmSignUp:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Already have an account? ",
                style: TextStyles.footerTextSmall(context)),
            TextButton(
              onPressed: () => state.changeStep(
                AuthenticatorStep.signIn,
              ),
              child: Text("Sign In",
                  style: TextStyles.footerLinkTextSmall(context)),
            ),
          ],
        );
      case AuthenticatorStep.resetPassword:
        return const SizedBox();
      case AuthenticatorStep.confirmResetPassword:
        return const SizedBox();
      default:
        return const SizedBox();
    }
  }
}
