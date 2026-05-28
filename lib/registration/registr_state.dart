class RegistrState {
  final String email;
  final String pin;
  final bool isSubmitting;
  RegistrState({this.email = '', this.pin ='', this.isSubmitting = false});
  RegistrState copyWith({String? email, String? pin, bool? isSubmitting}) {
    return RegistrState(
        email: email ?? this.email,
        pin: pin ?? this.pin,
        isSubmitting: isSubmitting ?? this.isSubmitting);
  }
  bool get isValid => email.contains('@') && pin.length == 4;

}

