class AppSessionState {
  final bool isUnlocked;
  final bool isFirstRun;

  AppSessionState({required this.isUnlocked, required this.isFirstRun});

  AppSessionState copyWith({bool? isUnlocked, bool? isFirstRun}) {
    return AppSessionState(
      isUnlocked: isUnlocked ?? this.isUnlocked,
      isFirstRun: isFirstRun ?? this.isFirstRun,
    );
  }
}