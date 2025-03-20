import 'package:apptree_dart_sdk/apptree.dart';
import 'endpoints.dart';
import 'models.dart';
import 'requests.dart';

var myTasksRecordList = RecordList(
    id: 'myTasksRecordList',
    dataSource: MyTasksEndpoint(),
    noResultsText: 'No tasks found',
    showDivider: true,
    template: (BuildContext context, Task task) => Workbench(
      title: '${task.name}',
      subtitle: '${task.description}',
    ),
    onItemSelected: (BuildContext context, Task task) => NavigateTo(
      feature: updateTaskForm,
    ),
    toolbar: (context) => Toolbar(
      items: [
        ToolbarItem(
          title: 'Sort',
          icon: Icon.sort,
          actions: [ShowSortDialogAction(analytics: Analytics(tag: 'sort'))],
        ),
      ],
    ),
    onLoadRequest: (context) => MyTasksRequest(workerId: '${context.user.uid}'),
    filter: (context, record) => [
      ListFilter(
        when: record.name.contains('John'),
        statement: record.name.equals('John'),
      ),
    ],
    mapSettings: (context, record) => MapSettings(
      initialZoomMode: MapZoomMode.markers,
    ),
  );


var updateTaskForm = Form<Task>(
  id: 'updateTaskForm',
  toolbarBuilder: null,
  fieldsBuilder: (context, record) => [
      Header(title: 'Update Task', id: 'Header'),
      TextInput(title: 'Name', bindTo: record.name, id: 'Name'),
      TextInput(title: 'Description', bindTo: record.description, id: 'Description'),
      TextInput(title: 'Status', bindTo: record.status, id: 'Status'),
      TextInput(title: 'Worker', bindTo: record.worker, id: 'Worker'),
    ],
  );