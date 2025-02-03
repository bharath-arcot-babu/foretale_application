import 'package:flutter/material.dart';
//auth amplify
import 'package:amplify_authenticator/amplify_authenticator.dart';
import 'package:foretale_application/ui/themes/text_styles.dart';

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
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // App logo
              const Padding(
                padding: EdgeInsets.only(top: 32),
                child: Center(child: FlutterLogo(size: 100)),
              ),
              Container(
                constraints: const BoxConstraints(maxWidth: 600),
                child: body,
              ),
            ],
          ),
        ),
      ),
      persistentFooterButtons: [_displayFooter(context)],
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
            const Text("Already have an account? "),
            TextButton(
              onPressed: () => state.changeStep(
                AuthenticatorStep.signIn,
              ),
              child: const Text("Sign In"),
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
