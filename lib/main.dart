import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orange_sdk/orange_sdk.dart';
import 'package:user_map_trace_app/app/common/constants/app_theme_data.dart';
import 'package:user_map_trace_app/app/common/functions/app_functions.dart';
import 'package:user_map_trace_app/app/common/get_it/get_it.dart';
import 'package:user_map_trace_app/app/common/router/app_router.dart';
import 'package:user_map_trace_app/app/features/presentation/home/cubit/home_cubit.dart';

void main() async {
  await AppFunctions.instance.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appRouter = getIt.get<AppRouter>();

    return MultiBlocProvider(
      providers: [BlocProvider(create: (context) => getIt.get<HomeCubit>())],
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          scaffoldMessengerKey: OrangeKeys.instance.orangeScaffoldMessengerKey,
          title: 'User Map Trace App',
          routerConfig: appRouter.config(),
          theme: AppThemeData.themeData,
        ),
      ),
    );
  }
}
