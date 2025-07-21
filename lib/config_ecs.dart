class TestConfigECS {
    // Base URL for APIs
    static const String clusterName = 'create-test-config-v1';
    static const String taskDefinition = 'test-config-task:1';
    static const String containerName = 'test-config-repo';
    static const String agentPath = '/opt/python/ai_agents/agent.py';
    static const String pythonPath = 'python3.12';
  
}

class EmbeddingECS {
    // Base URL for APIs
    static const String clusterName = 'create-vector-embeddings-v1';
    static const String taskDefinition = 'embed-documents-task:2';
    static const String containerName = 'container-embed-documents';
    static const String appPath = '/opt/python/embed_documents/app.py';
    static const String pythonPath = 'python3.12';
}

class WebSocketECSForQueryGeneration {
  static const String healthCheck = 'http://alb-fastapi-agent-423791108.us-east-1.elb.amazonaws.com/health';
  static const String restApi = 'http://alb-fastapi-agent-423791108.us-east-1.elb.amazonaws.com/agent';
  static const String webSocket = 'ws://alb-fastapi-agent-423791108.us-east-1.elb.amazonaws.com/ws';
}