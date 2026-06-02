import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:easy_localization/easy_localization.dart'; 
import 'package:tuanhoai01/core/service/http_service.dart';
import 'package:tuanhoai01/features/auth/data/repositories/auth_repository.dart';
import 'package:tuanhoai01/features/auth/bloc/login_bloc.dart';
import 'package:tuanhoai01/features/auth/screens/intro_screen.dart';
import 'package:tuanhoai01/features/candidate/screens/candidate_main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Khởi tạo localization
  await EasyLocalization.ensureInitialized();
  
  // Load file .env
  await dotenv.load(fileName: ".env");

  // Kiểm tra API KEY mới tinh trong Debug Console
  final apiKey = dotenv.env['NEW_GEMINI_KEY'];
  print("DEBUG: API Key được load là: $apiKey");

  final prefs = await SharedPreferences.getInstance();
  final bool isLoggedIn = prefs.getString('auth_token') != null;

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('vi', 'VN'), Locale('zh', 'TW'), Locale('en', 'US')], 
      path: 'assets/translations', 
      fallbackLocale: const Locale('vi', 'VN'),
      saveLocale: true, 
      child: MyApp(isLoggedIn: isLoggedIn),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<HttpService>(create: (context) => HttpService()),
        RepositoryProvider<AuthRepository>(
          create: (context) => AuthRepository(
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
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale, 
          
          // Đã sửa: Tên thuộc tính chuẩn xác của Flutter để ẩn Banner Debug
          debugShowCheckedModeBanner: false, 
          title: 'NH.JOB TAIWAN',
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFE24C33)),
          ),
          home: isLoggedIn ? const CandidateMainScreen() : const IntroScreen(),
        ),
      ),
    );
  }
}