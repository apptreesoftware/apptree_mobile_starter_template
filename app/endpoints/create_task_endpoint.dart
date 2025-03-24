import 'package:apptree_dart_sdk/apptree.dart';
import '../models/models.dart';

class CreateTaskEndpoint extends SubmissionEndpoint<CreateTaskRequest, Task> {
  const CreateTaskEndpoint()
    : super(id: 'CreateTask', submissionType: SubmissionType.create);
}

class CreateTaskRequest extends Request {
  final String name;
  final String description;
  final String status;
  final String workerId;

  CreateTaskRequest({
    required this.name,
    required this.description,
    required this.status,
    required this.workerId,
  });
}
