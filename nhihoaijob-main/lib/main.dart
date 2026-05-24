  import 'package:flutter/material.dart';
  import 'package:flutter_bloc/flutter_bloc.dart';
  import 'package:shared_preferences/shared_preferences.dart';
  import 'package:tuanhoai01/core/service/http_service.dart';
  import 'package:tuanhoai01/features/auth/data/repositories/auth_repository.dart';
  import 'package:tuanhoai01/features/auth/bloc/login_bloc.dart';
  import 'package:tuanhoai01/features/auth/screens/intro_screen.dart';
  import 'package:tuanhoai01/features/candidate/screens/candidate_main_screen.dart';

  void main() async {
    WidgetsFlutterBinding.ensureInitialized();
    
    final prefs = await SharedPreferences.getInstance();
    final bool isLoggedIn = prefs.getString('auth_token') != null;

    runApp(MyApp(isLoggedIn: isLoggedIn));
  }

  class MyApp extends StatelessWidget {
    final bool isLoggedIn;
    const MyApp({super.key, required this.isLoggedIn});

    @override
    Widget build(BuildContext context) {
      return MultiRepositoryProvider(
        providers: [
          RepositoryProvider<HttpService>(
            create: (context) => HttpService(),
          ),
          RepositoryProvider<AuthRepository>(
            create: (context) => AuthRepository(
              // Đảm bảo file auth_repository.dart đã sửa constructor như Bước 1
              httpService: RepositoryProvider.of<HttpService>(context),
            ),
          ),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider<LoginBloc>(
              create: (context) => LoginBloc(
                authRepository: RepositoryProvider.of<AuthRepository>(context),
              ),
            ),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'NH.JOB TAIWAN',
            theme: ThemeData(
              useMaterial3: true, 
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            ),
            home: isLoggedIn ? const CandidateMainScreen() : const IntroScreen(),
          ),
        ),
      );
    }
  }