import 'package:flutter/material.dart';

abstract class ChatDrivingModel {
  int get selectedId;

  Future<void> fetchResponses(BuildContext context);

  Future<int> insertResponse(BuildContext context, String responseText);

  String buildStoragePath({
    required String projectId,
    required String responseId,
  });

  String getStoragePath(BuildContext context, int responseId);

  int getSelectedId(BuildContext context);
}
