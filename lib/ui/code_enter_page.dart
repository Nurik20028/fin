import 'package:flutter/material.dart';
import 'package:finance/components/my_gradient.dart';
import 'package:finance/enter_state/enter_auth_state.dart';
import 'package:finance/enter_cubit/enter_auth_cubit.dart';
import 'package:finance/session/app_session_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CodEnterPage extends StatelessWidget {
  const CodEnterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,

      child: Scaffold(
        body: BlocConsumer<EnterAuthCubit, EnterAuthState>(
          listener: (context, state) {
            if (state.isSuccess) {
              // разблокируем сессию :
              context.read<AppSessionCubit>().unlock();
            }
            if (state.isError) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Неверный код!'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            return LayoutBuilder(
              builder: (context, constraints) {
                return Container(
                  decoration: const BoxDecoration(gradient: myGradient),
                  child: SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        const Icon(
                          Icons.lock_outline,
                          size: 50,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Введите PIN-код',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        const SizedBox(height: 30),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            4,
                                (index) => _buildDot(index < state.code.length),
                          ),
                        ),
                        const Spacer(),
                        // Основной блок цифры 1-9:
                        Container(
                          constraints: const BoxConstraints(maxWidth: 400),
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Column(
                            children: [
                              GridView.count(
                                shrinkWrap: true,
                                crossAxisCount: 3,
                                mainAxisSpacing: 10,
                                crossAxisSpacing: 10,
                                children: List.generate(
                                  9,
                                      (index) => _keyButton(
                                    context,
                                    (index + 1).toString(),
                                  ),
                                ),
                              ),

                              // Нижний ряд: Пустота, 0 , Удалить
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceEvenly,
                                  children: [
                                    const SizedBox(width: 60, height: 60),
                                    _keyButton(context, "0"),
                                    SizedBox(
                                      width: 60,
                                      height: 60,
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.backspace_outlined,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                        onPressed:
                                            () =>
                                            context
                                                .read<EnterAuthCubit>()
                                                .deleteDigit(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ОТПЕЧАТОК ПАЛЬЦА
                        InkWell(
                          onTap:
                              () =>
                              context
                                  .read<EnterAuthCubit>()
                                  .authenticateBiometrically(),
                          borderRadius: BorderRadius.circular(30),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.fingerprint,
                                color: Colors.white,
                                size: 55,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                "Использовать отпечаток",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
  Widget _buildDot(bool filled) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: filled ? Colors.white : Colors.white24,
        border: Border.all(color: Colors.white),
      ),
    );
  }

  Widget _keyButton(BuildContext context, String digit) {
    return Container(
      width: 60,
      height: 60,
      child: TextButton(
        onPressed: () => context.read<EnterAuthCubit>().addDigit(digit),
        child: Text(
          digit,
          style: const TextStyle(color: Colors.white, fontSize: 22),
        ),
      ),
    );
  }
}
