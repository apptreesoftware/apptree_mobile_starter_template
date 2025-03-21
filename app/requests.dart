import 'package:apptree_dart_sdk/apptree.dart';

class MyTasksRequest extends Request {
  final String workerId;

  MyTasksRequest({required this.workerId});
}

class UpdateTaskRequest extends Request {
  final String taskId;
  final String status;

  UpdateTaskRequest({required this.taskId, required this.status});
}

class CreateTaskRequest extends Request {
  final String name;
  final String description;
  final String status;
  final String workerId;

  CreateTaskRequest({required this.name, required this.description, required this.status, required this.workerId});
}