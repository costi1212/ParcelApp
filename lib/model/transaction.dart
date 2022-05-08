import 'package:hive/hive.dart';

part 'transaction.g.dart';

@HiveType(typeId: 0)
class Transaction extends HiveObject {
  @HiveField(0)
  late String senderName;

  @HiveField(1)
  late String senderAddress;

  @HiveField(2)
  late String receiverName;

  @HiveField(3)
  late String receiverAddress;

  @HiveField(4)
  late DateTime createdDate;

  @HiveField(5)
  late bool isRegistered = true;

  @HiveField(6)
  late double value;

  @HiveField(7)
  late String content;
}
