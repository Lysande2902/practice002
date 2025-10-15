import 'package:equatable/equatable.dart';

enum LoginStatus { initial, loading, success, failure }

class LoginState extends Equatable {
  const LoginState({
    this.status = LoginStatus.initial,
    this.isRememberMeChecked = false,
    this.errorMessage,
  });

  final LoginStatus status;
  final bool isRememberMeChecked;
  final String? errorMessage;

  LoginState copyWith({
    LoginStatus? status,
    bool? isRememberMeChecked,
    String? errorMessage,
  }) {
    return LoginState(
      status: status ?? this.status,
      isRememberMeChecked: isRememberMeChecked ?? this.isRememberMeChecked,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, isRememberMeChecked, errorMessage];
}