import 'package:apptree_dart_sdk/apptree.dart';

import 'features/create_task_form.dart';
import 'features/my_tasks_record_list.dart';

App buildApp() {
  var app = App(name: 'Apptree Mobile Starter Template', configVersion: 2);
  app.addFeature(
    myTasksRecordList,
    menuItem: MenuItem(
      title: 'My Tasks',
      icon: 'dashboard',
      defaultItem: false,
      order: 1,
    ),
  );
  app.addFeature(
    createTaskForm,
    menuItem: MenuItem(
      title: 'Create Task',
      icon: 'add',
      defaultItem: false,
      order: 2,
    ),
  );
  return app;
}
