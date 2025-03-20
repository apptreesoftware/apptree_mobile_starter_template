// IMPORTANT: This file is auto-generated. Do not edit it directly.
import 'package:apptree_dart_sdk/apptree.dart';
import 'app/app.dart';


void main() {
  final App app = App(name: 'Apptree Mobile Starter Template', configVersion: 2);
  app.addFeature(
    myTasksRecordList,
    menuItem: MenuItem(title: 'My Tasks', icon: 'dashboard', defaultItem: false, order: 1),
  );
  app.initialize();
}
