import 'dart:convert';

import 'package:flutter/material.dart';
import '../model/transaction.dart';
import 'package:uuid/uuid.dart' as uuid;
import 'package:http/http.dart' as http;

class TransactionDialog extends StatefulWidget {
  final Transaction? transaction;
  final Function(
      String senderName,
      String senderAddress,
      String receiverName,
      String receiverAddress,
      double value,
      bool isRegistered,
      String content) onClickedDone;

  const TransactionDialog({
    Key? key,
    this.transaction,
    required this.onClickedDone,
  }) : super(key: key);

  @override
  _TransactionDialogState createState() => _TransactionDialogState();
}

class _TransactionDialogState extends State<TransactionDialog> {
  List<dynamic> _placeList = [];
  List<dynamic> _contentList = [];
  final formKey = GlobalKey<FormState>();
  final senderNameController = TextEditingController();
  final senderAddressController = TextEditingController();
  final receiverNameController = TextEditingController();
  final receiverAddressController = TextEditingController();
  final valueController = TextEditingController();
  final contentController = TextEditingController();

  bool isRegistered = true;

  @override
  void initState() {
    super.initState();

    if (widget.transaction != null) {
      final transaction = widget.transaction!;

      senderNameController.text = transaction.senderName;
      senderAddressController.text = transaction.senderAddress;
      receiverNameController.text = transaction.receiverName;
      receiverAddressController.text = transaction.receiverAddress;
      contentController.text = transaction.content;
      valueController.text = transaction.value.toString();
      isRegistered = transaction.isRegistered;
    }
    senderAddressController.addListener(() {
      onChanged();
    });
  }

  onChanged() {
    var _sessionToken = '';
    setState(() {
      _sessionToken = uuid.Uuid().v4();
    });
    getSuggestion(senderAddressController.text, _sessionToken);
  }

  void getSuggestion(String input, String _sessionToken) async {
    String kPLACES_API_KEY = "AIzaSyClnHmekdS5GEgM1TVxjpii8hJHG7H8tFg";
    String type = '(regions)';
    String baseURL =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json';
    String request =
        '$baseURL?input=$input&key=$kPLACES_API_KEY&sessiontoken=$_sessionToken';
    var response = await http.get(Uri.parse(request));
    print(response.body);
    if (response.statusCode == 200) {
      setState(() {
        _placeList = json.decode(response.body)['predictions'] as List<dynamic>;
        print(_placeList);
      });
    } else {
      throw Exception('Failed to load predictions');
    }
  }

  @override
  void dispose() {
    senderNameController.dispose();
    senderAddressController.dispose();
    receiverNameController.dispose();
    receiverAddressController.dispose();
    valueController.dispose();
    contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.transaction != null;
    final title = isEditing ? 'Edit Parcel' : 'Add Parcel';

    return AlertDialog(
      title: Text(title),
      content: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(height: 8),
              buildSenderName(),
              SizedBox(height: 8),
              buildSenderAddress(),
              ...List.generate(
                  _placeList.length,
                  (int index) => Column(
                        children: [
                          InkWell(
                              onTap: () {
                                setState(() {
                                  senderAddressController.text =
                                      _placeList[index]['description'];
                                  _placeList = [];
                                });
                              },
                              child: Text(_placeList[index]['description'])),
                          Divider(),
                        ],
                      )),
              SizedBox(height: 8),
              buildReceiverName(),
              SizedBox(height: 8),
              buildReceiverAddress(),
              SizedBox(height: 8),
              buildContent(),
              Container(
                constraints: BoxConstraints(maxHeight: 200),
                height: 20.0 * _contentList.length,
                width: 100,
                child: ListView(
                  children: List.generate(_contentList.length, (index) =>  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _contentList[index]['id'],
                      ),
                      Divider(),
                    ],
                  ),),
                    ),
              ),
              SizedBox(height: 8),
              buildValue(),
              SizedBox(height: 8),
              buildRadioButtons(isEditing),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        buildCancelButton(context),
        buildAddButton(context, isEditing: isEditing),
      ],
    );
  }

  Widget buildSenderName() => TextFormField(
        controller: senderNameController,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          hintText: 'Enter sender name',
        ),
        validator: (name) =>
            name != null && name.isEmpty ? 'Enter a name for the sender' : null,
      );

  Widget buildSenderAddress() {
    return TextFormField(
      controller: senderAddressController,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        hintText: 'Enter sender address',
      ),
      validator: (name) => name != null && name.isEmpty
          ? 'Enter an address for the sender'
          : null,
    );
  }

  Widget buildReceiverName() => TextFormField(
        controller: receiverNameController,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          hintText: 'Enter receiver name',
        ),
        validator: (name) => name != null && name.isEmpty
            ? 'Enter a name for the receiver'
            : null,
      );

  Widget buildReceiverAddress() => TextFormField(
        controller: receiverAddressController,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          hintText: 'Enter receiver address',
        ),
        validator: (name) => name != null && name.isEmpty
            ? 'Enter an address for the receiver'
            : null,
      );

  Future<void> getContent({required String search}) async {
    String baseURL = 'https://api.coinbase.com/v2/currencies';
    var response = await http.get(Uri.parse(baseURL));
    print(response.body);
    if (response.statusCode == 200) {
      setState(() {
        _contentList = json.decode(response.body)['data'] as List<dynamic>;
        _contentList = _contentList.where((element) => element['id'].contains(search)).toList();
        print(_contentList);
      });
    } else {
      throw Exception('Failed to load currencies');
    }
  }

  Widget buildContent() => TextFormField(
        controller: contentController,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          hintText: 'Enter content of the parcel',
        ),
        validator: (name) => name != null && name.isEmpty
            ? 'The content can not be unspecified'
            : null,
    onChanged: (value){
          setState(() {
            getContent(search: value);
          });

    },
      );

  Widget buildValue() => TextFormField(
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          hintText: 'Enter the value of the parcel',
        ),
        keyboardType: TextInputType.number,
        validator: (amount) => amount != null && double.tryParse(amount) == null
            ? 'Enter a valid number'
            : null,
        controller: valueController,
      );

  Widget buildRadioButtons(isEditing) => Column(
        children: [
          RadioListTile<bool>(
            title: Text('Register'),
            value: true,
            groupValue: isRegistered,
            onChanged: (value) => setState(() => isRegistered = value!),
          ),
          RadioListTile<bool>(
            title: Text('Don\'t register'),
            value: false,
            groupValue: isRegistered,
            onChanged: (value) => setState(() => isRegistered = value!),
          ),
        ],
      );

  Widget buildCancelButton(BuildContext context) => TextButton(
        child: Text('Cancel'),
        onPressed: () => Navigator.of(context).pop(),
      );

  Widget buildAddButton(BuildContext context, {required bool isEditing}) {
    final text = isEditing ? 'Save' : 'Add';

    return TextButton(
      child: Text(text),
      onPressed: () async {
        final isValid = formKey.currentState!.validate();

        if (isValid) {
          final senderName = senderNameController.text;
          final senderAddress = senderAddressController.text;
          final receiverName = receiverNameController.text;
          final receiverAddress = receiverAddressController.text;
          final content = contentController.text;
          final value = double.tryParse(valueController.text) ?? 0;

          widget.onClickedDone(senderName, senderAddress, receiverName,
              receiverAddress, value, isRegistered, content);

          Navigator.of(context).pop();
        }
      },
    );
  }
}
