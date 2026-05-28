import 'package:flutter/material.dart';
import 'package:finance/components/item_transaction.dart';
import 'package:finance/components/my_gradient.dart';
import 'package:finance/models/model_transaction.dart';
import 'package:finance/river_states/local_sum_provider.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  @override
  State<StatefulWidget> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Builder(
            builder: (context) {
              try {
                if (!Hive.isBoxOpen('history')) {
                  return const Center(
                      child: Text("Box 'history' is NOT OPEN. Check main.dart"),
                      );
                  }
                      final historyBox = Hive.box<Model_Transaction>('history');
                  return ValueListenableBuilder(
                      valueListenable: historyBox.listenable(),
                      builder: (context, Box<Model_Transaction> box, _) {
                        final hisTransactions = box.values.toList().reversed.toList();
                        final sumProvider = context.watch<LocalSumProvider>();
                        final real_balance = sumProvider.realTotalBalance;

                        return CustomScrollView(
                            physics: const BouncingScrollPhysics(),
                            slivers: [
                            SliverAppBar(
                            expandedHeight: 120.0,
                            pinned: true,
                            backgroundColor: Colors.grey,
                            flexibleSpace: FlexibleSpaceBar(
                                title: const Text("History"),
                                centerTitle: true,
                                background: Container(
                                    decoration: const BoxDecoration(gradient: myGradient),
                                ),
                            ),
                        ),

                        SliverToBoxAdapter(
                        child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                        children: [
                        const Text('Ваш баланс:'),
                        Text(
                        "${real_balance.toStringAsFixed(2)} KGS",
                        style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        ),
                        ),
                        const Divider(height: 10),
                        ],
                        ),
                        ),
                        ),
                        hisTransactions.isEmpty
                        ? const SliverFillRemaining(
                        child: Center(child: Text("No transactions yet")),
                        )
                        : SliverList(
                        delegate: SliverChildBuilderDelegate((
                        context,
                        index,
                        ) {
                        final tx = hisTransactions[index];
                        return Column(
                        children: [
                        ItemTransaction(transaction: tx),
                        Padding(
                        padding: const EdgeInsets.only(
                        right: 20,
                        bottom: 10,
                        ),
                        child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                        "Wallet :  ${tx.balanceAtPoint?.toStringAsFixed(2) ?? '0.00'} KGS",
                        style: const TextStyle(
                        color: Colors.indigo,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        ),
                        ),
                        ),
                        ),

                        const Divider(indent: 20, endIndent: 20),
                        ],
                        );
                        }, childCount: hisTransactions.length),
                        ),

                        const SliverToBoxAdapter(child: SizedBox(height: 80)),
                            ],
                        );
                      },
                  );
                } catch (e) {
                return Center(
                    child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                            "Fatal Error: $e",
                            style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                            ),
                        ),
                    ),
                );
              }
            },
        ),
    );
  }
}
