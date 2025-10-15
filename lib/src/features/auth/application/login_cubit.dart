// In lib/src/features/auth/application/login_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/auth_repository.dart';
import 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit({required this.authRepository}) : super(const LoginState());

  final AuthRepository authRepository;

  Future<void> init() async {
    final isRemembered = await authRepository.loadRememberMe();
    emit(state.copyWith(isRememberMeChecked: isRemembered));
  }

  void toggleRememberMe(bool newValue) {
    authRepository.saveRememberMe(newValue);
    emit(state.copyWith(isRememberMeChecked: newValue));
  }

  Future<void> login(String email, String password) async {
    emit(state.copyWith(status: LoginStatus.loading));
    try {
      // Simula una llamada a la red
      await Future.delayed(const Duration(seconds: 2));
      if (email == 'test@test.com' && password == 'password') {
        emit(state.copyWith(status: LoginStatus.success));
      } else {
        throw 'Invalid credentials';
      }
    } catch (e) {
      emit(state.copyWith(status: LoginStatus.failure, errorMessage: e.toString()));
    }
  }
}
