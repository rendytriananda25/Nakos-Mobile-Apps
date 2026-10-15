import 'features/auth/presentation/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/constants/app_constants.dart';
import 'core/design_system/tokens/app_colors.dart';
import 'core/services/local_storage/local_storage_service.dart';
import 'features/budget_allocation/presentation/bloc/budget_allocation_bloc.dart';
import 'features/dashboard/presentation/bloc/dashboard_bloc.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Set immersive system UI overlay style matching Figma dark background
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.darkBackground,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const KostSaverApp());
}

class KostSaverApp extends StatelessWidget {
  final Widget? home;
  const KostSaverApp({super.key, this.home});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<LocalStorageService>(
          create: (_) => LocalStorageService(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<DashboardBloc>(
            create: (context) => DashboardBloc(
              storageService: context.read<LocalStorageService>(),
            ),
          ),
          BlocProvider<BudgetAllocationBloc>(
            create: (context) => BudgetAllocationBloc(
              storageService: context.read<LocalStorageService>(),
            ),
          ),
        ],
        child: MaterialApp(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            scaffoldBackgroundColor: AppColors.darkBackground,
            colorScheme: const ColorScheme.dark(
              primary: AppColors.darkHeroBg,
              surface: AppColors.darkSurface,
            ),
          ),
          home: home ?? const LoginScreen(),
        ),
      ),
    );
  }
}
