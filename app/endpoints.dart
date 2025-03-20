import 'package:apptree_dart_sdk/apptree.dart';
import 'models.dart';
import 'requests.dart';

class MyTasksEndpoint extends CollectionEndpoint<MyTasksRequest, Task> {
  const MyTasksEndpoint() : super(id: 'MyTasks');
}

class WorkersListEndpoint extends ListEndpoint<Worker> {
  const WorkersListEndpoint() : super(id: 'Workers');
}

