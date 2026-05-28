import 'package:flutter/material.dart';
import 'package:finance/components/delete_alert_dialog.dart';
import 'package:finance/components/item_transaction.dart';
import 'package:finance/components/my_gradient.dart';
import 'package:finance/models/model_transaction.dart';
import 'package:finance/river_states/currency_provider.dart';
import 'package:finance/river_states/local_sum_provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Box<Model_Transaction> transactionBox = Hive.box<Model_Transaction>(
    'transactions',
  );

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<CurrencyProvider>().fetchCurrency());
  }

  @override
  Widget build(BuildContext context) {
    final sumProvider = context.watch<LocalSumProvider>();
    final realBalance = sumProvider.realTotalBalance;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      floatingActionButton: Container(
        height: 60,
        width: 60,
        decoration: BoxDecoration(
          gradient: myGradient,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.green.withValues(alpha: 0.4),
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
            context.push('/add_operation');
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add, color: Colors.white, size: 32),
        ),
      ),
      body: SafeArea(
        child: ValueListenableBuilder(
          valueListenable: transactionBox.listenable(),
          builder: (context, Box<Model_Transaction> box, _) {
            final transactions = box.values.toList().reversed.toList();
            
            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0, bottom: 30.0),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24.0),
                      decoration: BoxDecoration(
                        gradient: myGradient,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.indigo.withValues(alpha: 0.3),
                            blurRadius: 15,
                            spreadRadius: 5,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total Balance',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Icon(Icons.account_balance_wallet, color: Colors.white.withValues(alpha: 0.8)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "${realBalance.toStringAsFixed(2)} KGS",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                    child: Text(
                      'Recent Transactions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.titleMedium?.color,
                      ),
                    ),
                  ),
                ),

                transactions.isEmpty
                    ? SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.receipt_long, size: 64, color: Theme.of(context).disabledColor),
                              const SizedBox(height: 16),
                              Text(
                                'No transactions yet',
                                style: TextStyle(color: Theme.of(context).disabledColor, fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      )
                    : SliverPadding(
                        padding: const EdgeInsets.only(bottom: 80.0), // padding for FAB
                        sliver: SliverList.builder(
                          itemCount: transactions.length,
                          itemBuilder: (context, index) {
                            final tx = transactions[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                              child: Material(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(20),
                                clipBehavior: Clip.antiAlias,
                                elevation: 2,
                                shadowColor: Colors.black.withValues(alpha: 0.1),
                                child: InkWell(
                                  splashColor: Colors.indigo.withValues(alpha: 0.1),
                                  highlightColor: Colors.indigo.withValues(alpha: 0.05),
                                  onTap: () {
                                    deleteAcceptDialog(
                                      context: context,
                                      modelTransaction: tx,
                                    );
                                  },
                                  child: ItemTransaction(transaction: tx),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
              ],
            );
          },
        ),
      ),
    );
  }
}
