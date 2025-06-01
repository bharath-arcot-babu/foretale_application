import 'package:foretale_application/config_ecs.dart';
import 'package:foretale_application/config_lambda_api.dart';
import 'package:foretale_application/core/services/lambda_activities.dart';

/// A service class for processing file embeddings for responses
class EmbeddingService {
  Future<void> runEmbeddingsForResponse(int responseId, String userId) async {
      final lambdaHelper = LambdaHelper(
        apiGatewayUrl: LambdaApiConfig.ecsConfigInvoker,
      );
    
      final payload = {
        "action": "run_task",
        "cluster_name": EmbeddingECS.clusterName,
        "task_definition": EmbeddingECS.taskDefinition,
        "container_name": EmbeddingECS.containerName,
        "command": [
          EmbeddingECS.pythonPath,
          EmbeddingECS.appPath,
          responseId.toString(),
          userId
        ]
      };

      await lambdaHelper.invokeLambda(payload: payload);
    } 
  }