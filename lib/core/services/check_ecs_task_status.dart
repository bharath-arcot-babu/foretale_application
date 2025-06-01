import 'package:flutter/material.dart';
import 'package:foretale_application/config_ecs.dart';
import 'package:foretale_application/config_lambda_api.dart';
import 'package:foretale_application/core/services/lambda_activities.dart';
import 'package:foretale_application/core/utils/message_helper.dart';

/// Checks the status of an ECS task and returns the final status and reason
/// 
/// [context] - The build context for showing snackbar messages
/// [taskArn] - The ARN of the ECS task to check
/// [clusterName] - The name of the ECS cluster (defaults to TestConfigECS.clusterName)
/// [pollingInterval] - The interval between status checks in seconds (defaults to 60)
/// 
/// Returns a Map containing:
/// - 'status': The final task status
/// - 'stoppedReason': The reason the task stopped (if applicable)
Future<Map<String, String>> checkEcsTaskStatus({
  required BuildContext context,
  required String taskArn,
  String? clusterName,
  int pollingInterval = 60,}) async {
    
  try {
    String taskStatus = 'UNKNOWN';
    String? stoppedReason;
    final targetClusterName = clusterName ?? TestConfigECS.clusterName;

    while (taskStatus != 'STOPPED') {
      await Future.delayed(Duration(seconds: pollingInterval));

      final statusLambdaHelper = LambdaHelper(
        apiGatewayUrl: LambdaApiConfig.ecsTaskStatusInvoker,
      );
      
      final statusResult = await statusLambdaHelper.invokeLambda(
        payload: {
          "task_arn": taskArn,
          "cluster_name": targetClusterName,
        },
      );

      taskStatus = statusResult['status'];
      stoppedReason = statusResult['stoppedReason'];
      
      SnackbarMessage.showSuccessMessage(
        context, 
        "Task status: $taskStatus"
      );
    }

    if (taskStatus == 'STOPPED') {
      if (stoppedReason == 'Completed') {
        SnackbarMessage.showSuccessMessage(
          context, 
          "Task stopped. Reason: $stoppedReason"
        );
      } else {
        SnackbarMessage.showErrorMessage(
          context, 
          "Task stopped. Reason: $stoppedReason"
        );
      }
    }

    return {
      'status': taskStatus,
      'stoppedReason': stoppedReason ?? 'Unknown',
    };
    
  } catch (e) {
    print("Error: $e");
    SnackbarMessage.showErrorMessage(
      context,
      "Failed to check task status: ${e.toString()}",
      logError: true,
      errorMessage: e.toString(),
      errorSource: 'check_ecs_task_status.dart',
      severityLevel: 'Error',
      requestPath: "Check ECS Task Status",
    );
    rethrow;
  }
}