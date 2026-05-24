import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tuanhoai01/features/auth/data/repositories/auth_repository.dart';
import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthRepository authRepository;

  LoginBloc({required this.authRepository}) : super(LoginInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginLoading());
    try {
      final result = await authRepository.login(
        email: event.email.trim(),
        password: event.password,
      );

      // Đã sửa: Đảm bảo tên class State viết hoa (LoginSuccess)
      emit(LoginSuccess(result));
    } catch (e) {
      // Mọi lỗi từ server hoặc sai pass sẽ nhảy vào đây
      emit(LoginFailure(e.toString()));
    }
  }
} 