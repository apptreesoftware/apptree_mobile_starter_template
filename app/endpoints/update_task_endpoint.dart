import 'package:apptree_dart_sdk/apptree.dart';
import '../models/models.dart';

class UpdateTaskEndpoint extends SubmissionEndpoint<UpdateTaskRequest, Task> {
  const UpdateTaskEndpoint()
    : super(id: 'UpdateTask', submissionType: SubmissionType.update);
}

class UpdateTaskRequest extends Request {
  final String taskId;
  final String status;

  UpdateTaskRequest({required this.taskId, required this.status});
}
