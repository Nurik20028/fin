class EnterAuthState {
  final String code;
  final bool isError;
  final bool isSuccess;
  final bool isFirstRun;
  final String message;
  EnterAuthState({
  this.code = '',
  this.isError = false,
  this.isSuccess = false,
  this.isFirstRun = false,
  this.message = '',
});
  EnterAuthState copyWith({
  String? code,
  bool? isError,
  bool? isSuccess,
  bool? isFirstRun,
  String? message,
  }) {
    return EnterAuthState(
        code: code ?? this.code,
        isError: isError ?? false,
        isSuccess: isSuccess ?? false,
        isFirstRun: isFirstRun ?? this.isFirstRun,
        message: message ?? '',
    );
  }
}
