import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:user_map_trace_app/app/common/get_it/get_it.dart';
import 'package:user_map_trace_app/app/features/presentation/test/cubit/test_cubit.dart';
import 'package:user_map_trace_app/app/features/presentation/test/test_imports.dart';

@RoutePage()
class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      getIt.get<TestCubit>().getAllTests();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const TestView()),
        (_) => false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Placeholder());
  }
}
