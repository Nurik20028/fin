import 'package:flutter/material.dart';
import 'package:finance/models/model_transaction.dart';

class ItemTransaction extends StatelessWidget {
  final Model_Transaction transaction;

  ItemTransaction({super.key, required this.transaction});

  Widget _getCategoryIcon(String categoryName) {
    switch (categoryName) {
      case 'Food':
        return const Icon(Icons.fastfood_outlined, color: Colors.red);
      case 'Transport':
        return const Icon(
          Icons.emoji_transportation_outlined,
          color: Colors.red,
        );
      case 'Hobby/Fun':
        return const Icon(Icons.sports_football_sharp, color: Colors.red);
      case 'Salary':
        return const Icon(Icons.currency_bitcoin_sharp, color: Colors.green);
      case 'Gift':
        return const Icon(Icons.card_giftcard_sharp, color: Colors.green);
      case 'Bonus':
        return const Icon(Icons.star, color: Colors.green);
      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isIncome = transaction.type == 'income';
    String textDollarsSum = transaction.dollarSum.toStringAsFixed(2);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.transparent),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: isIncome ? Colors.green : Colors.red,
                width: 2,
              ),
            ),
            child: _getCategoryIcon(transaction.category),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${isIncome ? '+' : '-'} ${transaction.amount} KGS",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  "${isIncome ? '+' : '-'} ${textDollarsSum} USD",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.cyan,
                  ),
                ),
                Text(
                  transaction.category,
                  style: const TextStyle(
                    color: Colors.indigo,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  transaction.comment,
                  style: const TextStyle(fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
          Text(
            "${transaction.date.day}/${transaction.date.month.toString().padLeft(2, '0')}/${transaction.date.year}",
          ),
        ],
      ),
    );
  }
}
