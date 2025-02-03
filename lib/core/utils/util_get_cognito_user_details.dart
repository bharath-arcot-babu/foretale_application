//libraries
import 'package:flutter/material.dart';
import 'package:foretale_application/core/services/database_connect.dart';
//state management
import 'package:provider/provider.dart';
//amplify
import 'package:amplify_flutter/amplify_flutter.dart';
//models
import 'package:foretale_application/models/user_details_model.dart'; // Ensure this path is correct

Future<void> getUserSignInDetails(BuildContext context) async {
  try {
    var userModel = Provider.of<UserDetailsModel>(context, listen: false);
    // Check if the user is currently signed in
    var user = await Amplify.Auth.getCurrentUser();
    
    // Get user attributes
    var userAttributes = await Amplify.Auth.fetchUserAttributes();

    // Find the email attribute
    var emailAttribute = userAttributes.firstWhere(
      (attr) => attr.userAttributeKey.toString() == 'email',
      orElse: () => const AuthUserAttribute(userAttributeKey: AuthUserAttributeKey.email, value: "empty_email_address"),
    );

    // Handle missing name attribute
    var nameAttribute = userAttributes.firstWhere(
      (attr) => attr.userAttributeKey.toString() == 'name',
      orElse: () => const AuthUserAttribute(userAttributeKey: AuthUserAttributeKey.name, value: "empty_name"),
    );

    if(emailAttribute.value != "empty_email_address"){
      //save details to the model
      userModel.saveUserDetails(
        user.userId,
        nameAttribute.value,
        emailAttribute.value,
      );

      //setup an user record in the database
      userModel.initializeUser(context);

    } else {
      throw Exception('Unable to find the associated email address.');
    }

  } catch (e) {
    throw Exception('Unable to get user details. Please try again later.');
  }
}
