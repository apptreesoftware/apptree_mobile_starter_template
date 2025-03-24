import 'package:apptree_dart_sdk/apptree.dart';
import '../models/models.dart';

class MyTasksEndpoint extends CollectionEndpoint<MyTasksRequest, Task> {
  const MyTasksEndpoint() : super(id: 'MyTasks');
}

class MyTasksRequest extends Request {
  final String workerId;

  MyTasksRequest({required this.workerId});
}
