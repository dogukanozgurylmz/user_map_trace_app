import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orange_sdk/orange_sdk.dart';
import 'package:user_map_trace_app/app/common/constants/app_strings.dart';
import 'package:user_map_trace_app/app/features/presentation/home/cubit/home_cubit.dart';
import 'package:user_map_trace_app/app/features/presentation/home/widgets/current_lcoation_widget.dart';
import 'package:user_map_trace_app/app/features/presentation/home/widgets/statistic_item_widget.dart';

class StatusInfoWidget extends StatelessWidget {
  const StatusInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        var cubit = context.read<HomeCubit>();
        return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StatisticItemWidget(),

                  const SizedBox(height: 20),

                  // Büyük Aksiyon Butonu
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () =>
                              _showNewJourneyDialog(context, cubit),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF34D100),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            minimumSize: const Size(double.infinity, 56),
                            shadowColor: Colors.transparent,
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Yeni Yolculuk",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      CurrentLocationButton(),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showNewJourneyDialog(BuildContext context, HomeCubit cubit) {
    OrangeDialog.blur(
      context: context,
      title: AppStrings.newJourney,
      message: AppStrings.newJourneyMessage,
      actions: [
        OrangeDialogAction(
          label: AppStrings.reset,
          onPressed: () {
            Navigator.of(context).pop();
            cubit.resetRoute();
            OrangeSnackBar.success(message: AppStrings.routeReset);
          },
        ),
        OrangeDialogAction(
          label: AppStrings.saveAndReset,
          onPressed: () async {
            Navigator.of(context).pop();
            await cubit.saveCurrentRoute();
            cubit.resetRoute();
          },
        ),
      ],
    );
  }
}
