import 'package:apptree_dart_sdk/apptree.dart';

import '../models/models.dart';

var createTaskForm = Form<Task>(
  id: 'createTaskForm',
  toolbarBuilder: null,
  fieldsBuilder:
      (context, record) => [
        Header(title: 'Create Task', id: 'Header'),
        TextInput(title: 'Name', bindTo: record.name, id: 'Name'),
        TextInput(
          title: 'Description',
          bindTo: record.description,
          id: 'Description',
        ),
        TextInput(title: 'Status', bindTo: record.status, id: 'Status'),
        TextInput(title: 'Worker', bindTo: record.worker, id: 'Worker'),
      ],
);
