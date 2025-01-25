//libraries
import 'package:flutter/material.dart';
import 'package:foretale_application/amplifyconfiguration.dart';
import 'package:provider/provider.dart';
//screens

//models
import 'package:foretale_application/models/project_details_model.dart';
//auth amplify
import 'package:amplify_authenticator/amplify_authenticator.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';

//configure amplify related activities
Future<void> _configureAmplify() async {
  try {
    final authPlugin = AmplifyAuthCognito();
    await Amplify.addPlugin(authPlugin);
    await Amplify.configure(amplifyconfig);
  } catch (e) {
    print('Error configuring Amplify: $e');
  }
}

//entry
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await _configureAmplify();
  } catch (e) {
    print('Error configuring Amplify: $e');
  }

  runApp(const ForeTaleApp());
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
          ChangeNotifierProvider(create: (_) => ProjectDetailsModel())
        ],
        child: Authenticator(
            child: MaterialApp(
                builder: Authenticator.builder(),
                debugShowCheckedModeBanner: false,
                title: "foreTale",
                initialRoute: '/',
                routes: {
              '/': (context) => const Placeholder(),
            })));
  }
}
