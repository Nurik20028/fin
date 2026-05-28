
import 'package:flutter/material.dart';
import 'package:finance/session/app_session_cubit.dart';

class LifecycleObserver with WidgetsBindingObserver {
  final AppSessionCubit session;
  LifecycleObserver({required this.session});
  void start() {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      session.lock();
    }
    if (state == AppLifecycleState.resumed) {
      session.lock();
    }
  }
}
