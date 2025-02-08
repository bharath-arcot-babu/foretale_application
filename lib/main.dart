//libraries
import 'package:flutter/material.dart';
import 'package:foretale_application/models/inquiry_question_model.dart';

import 'package:foretale_application/models/project_settings_model.dart';
import 'package:foretale_application/models/question_model.dart';
import 'package:foretale_application/models/team_contacts_model.dart';
import 'package:provider/provider.dart';
import 'package:foretale_application/amplifyconfiguration.dart';
//screens
import 'package:foretale_application/ui/screens/widget_app_layout.dart';
import 'package:foretale_application/ui/widgets/widget_login_scaffold.dart';
//models
import 'package:foretale_application/models/project_details_model.dart';
import 'package:foretale_application/models/user_details_model.dart';
import 'package:foretale_application/models/client_contacts_model.dart';
//auth amplify
import 'package:amplify_authenticator/amplify_authenticator.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';

//entry
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await _configureAmplify();
  } catch (e) {
    
  }
  runApp(const ForeTaleApp());
}

//configure amplify related activities
Future<void> _configureAmplify() async {
  final authPlugin = AmplifyAuthCognito();
  await Amplify.addPlugin(authPlugin);
  await Amplify.configure(amplifyconfig);
}

SignUpForm customSignUpForm() {
  return SignUpForm.custom(
    fields: [
      SignUpFormField.email(required: true),
      SignUpFormField.custom(
        required: true,
        validator: ((value) {
          if (value == null || value.trim().isEmpty) {
            return 'Name must not be blank.';
          }     
          return null;
        }),
        title: 'Name',
        attributeKey: CognitoUserAttributeKey.name,
      ),
      SignUpFormField.password(),
      SignUpFormField.passwordConfirmation(),
    ],
  );
}

//login body to be displayed
Widget _displayBody(AuthenticatorState state) {
  switch (state.currentStep) {
    case AuthenticatorStep.signIn:
      return SignInForm();
    case AuthenticatorStep.signUp:
      return customSignUpForm();
    case AuthenticatorStep.confirmSignUp:
      return ConfirmSignUpForm();
    case AuthenticatorStep.resetPassword:
      return ResetPasswordForm();
    case AuthenticatorStep.confirmResetPassword:
      return const ConfirmResetPasswordForm();
    default:
      return SignInForm();
  }
}

//authenticator builder
Widget _authenticatorBuilder(BuildContext context, AuthenticatorState state){
  return CustomLoginScaffold(
      state: state, 
      body: _displayBody(state)
    );
}

//application
class ForeTaleApp extends StatelessWidget {
  //constructor
  const ForeTaleApp({super.key});
  //build
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ProjectDetailsModel()),
          ChangeNotifierProvider(create: (_) => ProjectSettingsModel()),
          ChangeNotifierProvider(create: (_) => UserDetailsModel()),
          ChangeNotifierProvider(create: (_) => ClientContactsModel()),
          ChangeNotifierProvider(create: (_) => TeamContactsModel()),
          ChangeNotifierProvider(create: (_) => QuestionsModel()),
          ChangeNotifierProvider(create: (_) => InquiryQuestionModel()),
        ],
        child: Authenticator(
            authenticatorBuilder: _authenticatorBuilder,
            child: MaterialApp(
                builder: Authenticator.builder(),
                debugShowCheckedModeBanner: false,
                title: "foreTale",
                initialRoute: '/',
                routes: {
                  '/': (context) => const AppLayout(),
                })));
  }
}



