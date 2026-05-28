import 'package:flutter/material.dart';
import 'package:finance/components/my_gradient.dart';
import 'package:finance/registration/registr_state.dart';
import 'package:finance/registration/registration_cubit.dart';
import 'package:finance/session/app_session_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class RegistrationPage extends StatelessWidget {
  const RegistrationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RegistrationCubit(),
      child: Scaffold(
        body: BlocConsumer<RegistrationCubit, RegistrState>(
          listener: (context, state) {},
          builder: (context, state) {
            return Container(
              decoration: const BoxDecoration(gradient: myGradient),
              child: SafeArea(
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    const Text(
                      "Первый вход",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text(
                        "Введите ваш Email и придумайте 4-значный PIN-код для защиты ваших данных",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),

                    // Поле ввода Email
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: TextField(
                        onChanged:
                            (val) => context
                            .read<RegistrationCubit>()
                            .updateEmail(val),
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: "example@mail.com",
                          hintStyle: const TextStyle(color: Colors.white30),
                          prefixIcon: const Icon(
                            Icons.email,
                            color: Colors.white70,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(color: Colors.white30),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(color: Colors.white),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Место ввода PIN-кода:
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        4,
                            (index) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          width: 15,
                          height: 15,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                            index < state.pin.length
                                ? Colors.white
                                : Colors.white24,
                            border: Border.all(color: Colors.white),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    //Кнопка сохранения PIN  а также входа:
                    ElevatedButton(
                      onPressed:
                      state.isValid && !state.isSubmitting
                          ? () async {
                        // Сохраняем данные во внутреннем кубите (SecureStorage)
                        bool ok =
                        await context
                            .read<RegistrationCubit>()
                            .saveRegistration();
                        if (ok) {
                          // уведомляем ГЛОБАЛЬНЫЙ кубит сессии
                          // Это обновит состояние, которое проверяет GoRouter
                          context
                              .read<AppSessionCubit>()
                              .markRegistrationComplete();

                          //После этого заходим в приложение:
                          context.go('/main_navigation_container');
                        }
                      }
                          : null,

                      child:
                      state.isSubmitting
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                          : const Text("СОХРАНИТЬ И ВОЙТИ"),

                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.indigo,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 50,
                          vertical: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Кастомная цифровая клавиатура
                    _buildKeyboard(context),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildKeyboard(BuildContext context) {
    final cubit = context.read<RegistrationCubit>();
    return Container(
      padding: const EdgeInsets.only(bottom: 20),
      height: 350,
      child: GridView.count(
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 3,
        childAspectRatio: 1.3,
        children: [
          ...[
            "1",
            "2",
            "3",
            "4",
            "5",
            "6",
            "7",
            "8",
            "9",
          ].map((n) => _keyButton(n, cubit)),
          const SizedBox(),
          _keyButton("0", cubit),
          IconButton(
            icon: const Icon(
              Icons.backspace_outlined,
              color: Colors.white,
              size: 28,
            ),
            onPressed: () => cubit.deleteDigit(),
          ),
        ],
      ),
    );
  }

  Widget _keyButton(String digit, RegistrationCubit cubit) {
    return TextButton(
      onPressed: () => cubit.addDigit(digit),
      child: Text(
        digit,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}

