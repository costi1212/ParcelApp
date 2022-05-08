import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive_database_example/boxes.dart';
import 'package:hive_database_example/model/transaction.dart';
import 'package:hive_database_example/widget/transaction_dialog.dart';
import 'package:intl/intl.dart';

class TransactionPage extends StatefulWidget {
  @override
  _TransactionPageState createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  @override
  void dispose() {
    Hive.close();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('Parcel List'),
          centerTitle: true,
        ),
        body: ValueListenableBuilder<Box<Transaction>>(
          valueListenable: Boxes.getTransactions().listenable(),
          builder: (context, box, _) {
            final transactions = box.values.toList().cast<Transaction>();

            return buildContent(transactions);
          },
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () => showDialog(
            context: context,
            builder: (context) => TransactionDialog(
              onClickedDone: addTransaction,
            ),
          ),
        ),
      );

  Widget buildContent(List<Transaction> transactions) {
    if (transactions.isEmpty) {
      return Center(
        child: Text(
          'No parcels saved yet!',
          style: TextStyle(fontSize: 24),
        ),
      );
    } else {
      final parcelAmount = transactions.fold<int>(
        0,
        (previousValue, transaction) => previousValue + 1
      );
      final newExpenseString = '${parcelAmount.toString()}';
      final color = parcelAmount > 0 ? Colors.green : Colors.red;

      return Column(
        children: [
          SizedBox(height: 24),
          Text(
            'Parcel number: $newExpenseString',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: color,
            ),
          ),
          SizedBox(height: 24),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(8),
              itemCount: transactions.length,
              itemBuilder: (BuildContext context, int index) {
                final transaction = transactions[index];

                return buildTransaction(context, transaction);
              },
            ),
          ),
        ],
      );
    }
  }

  Widget buildTransaction(
    BuildContext context,
    Transaction transaction,
  ) {
    final color = transaction.isRegistered ? Colors.blue : Colors.green;
    final date = DateFormat.yMMMd().format(transaction.createdDate);
    final value = transaction.value.toStringAsFixed(2);

    return Card(
      color: Colors.white,
      child: ExpansionTile(
        tilePadding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        title: Text(
          transaction.senderName,
          maxLines: 2,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Text(date),
        trailing: Text(
          value,
          style: TextStyle(
              color: color, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        children: [
          buildButtons(context, transaction),
        ],
      ),
    );
  }

  Widget buildButtons(BuildContext context, Transaction transaction) => Row(
        children: [
          Expanded(
            child: TextButton.icon(
              label: Text('Edit'),
              icon: Icon(Icons.edit),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => TransactionDialog(
                    transaction: transaction,
                    onClickedDone: (senderName, senderAddress, receiverName,
                        receiverAddress, value, isregistered, content) =>
                        editTransaction(transaction, senderName, senderAddress, receiverName,
                            receiverAddress, value, isregistered, content),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: TextButton.icon(
              label: Text('Delete'),
              icon: Icon(Icons.delete),
              onPressed: () => deleteTransaction(transaction),
            ),
          )
        ],
      );

  Future addTransaction(String senderName, String senderAddress,
      String receiverName, String receiverAddress, double value,
      bool isRegistered, String content) async {
    final transaction = Transaction()
      ..senderName = senderName
      ..senderAddress = senderAddress
      ..receiverName = receiverName
      ..receiverAddress = receiverAddress
      ..createdDate = DateTime.now()
      ..value = value
      ..content = content
      ..isRegistered = isRegistered;

    final box = Boxes.getTransactions();
    box.add(transaction);

  }

  void editTransaction(
    Transaction transaction,
      String senderName, String senderAddress,
      String receiverName, String receiverAddress, double value,
      bool isRegistered, String content
  ) {
    transaction.senderName = senderName;
    transaction.senderAddress = senderAddress;
    transaction.receiverName = receiverName;
    transaction.receiverAddress = receiverAddress;
    transaction.value = value;
    transaction.isRegistered = isRegistered;
    transaction.content = content;
    transaction.save();
  }

  void deleteTransaction(Transaction transaction) {
    transaction.delete();
  }
}
