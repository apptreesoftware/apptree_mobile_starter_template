import 'package:apptree_dart_sdk/apptree.dart';
import 'models.dart';
import 'requests.dart';

class MyTasksEndpoint extends CollectionEndpoint<MyTasksRequest, Task> {
  const MyTasksEndpoint() : super(id: 'MyTasks');
}

class UpdateTaskEndpoint extends SubmissionEndpoint<UpdateTaskRequest, Task> {
  const UpdateTaskEndpoint() : super(id: 'UpdateTask', submissionType: SubmissionType.update);
}

class CreateTaskEndpoint extends SubmissionEndpoint<CreateTaskRequest, Task> {
  const CreateTaskEndpoint() : super(id: 'CreateTask', submissionType: SubmissionType.create);
}

class WorkersListEndpoint extends ListEndpoint<Worker> {
  const WorkersListEndpoint() : super(id: 'Workers');
}

