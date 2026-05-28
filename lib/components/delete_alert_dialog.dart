import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:finance/models/model_transaction.dart';
import 'package:finance/river_states/local_sum_provider.dart';
import 'package:provider/provider.dart';

final Box<Model_Transaction> transactionBox = Hive.box<Model_Transaction>(
  'transactions',
);
Future<void> deleteAcceptDialog({
  required BuildContext context,
  required Model_Transaction modelTransaction,
}) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: const Text('Are you sure to delete this transaction?'),

        actions: <Widget>[
          TextButton(
            child: const Text(
              'No',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
            onPressed: () {
              Navigator.of(dialogContext).pop();
            },
          ),
          TextButton(
            child: const Text(
              'Yes',
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.w600,
              ),
            ),
            onPressed: () async {
              await modelTransaction.delete();
              Provider.of<LocalSumProvider>(context, listen: false).refresh();
              Navigator.of(dialogContext).pop();
            },
          ),
        ],
      );
    },
  );
}
