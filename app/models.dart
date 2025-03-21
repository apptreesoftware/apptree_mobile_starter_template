import 'package:apptree_dart_sdk/apptree.dart';
import 'endpoints.dart';

class Task extends Record {
  @PkField()
  final StringField id = StringField();
  final StringField name = StringField();
  final StringField description = StringField();
  final StringField status = StringField();
  @ExternalField(endpoint: WorkersListEndpoint(), key: 'workerId')
  final Worker worker = Worker();
  final ListField<Asset> assets = ListField<Asset>();
}

class Asset extends Record {
  @PkField()
  final StringField id = StringField();
  final StringField name = StringField();
  final StringField description = StringField();
  final IntField price = IntField();
  final IntField quantity = IntField();
}

class Worker extends Record {
  @PkField()
  final StringField id = StringField();
  final StringField name = StringField();
  final StringField email = StringField();
  final StringField phone = StringField();
}
