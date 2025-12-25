import 'package:flutter/material.dart';
import 'package:orange_sdk/orange_sdk.dart';
import 'package:user_map_trace_app/app/common/constants/app_strings.dart';
import 'package:user_map_trace_app/app/features/presentation/home/cubit/home_cubit.dart';

mixin JourneyMixin {
  Future<void> startNewJourney(BuildContext context, HomeCubit cubit) async {
    await cubit.startService(context);
  }

  Future<void> stopJourney(BuildContext context, HomeCubit cubit) async {
    final result = await OrangeDialog.confirm(
      context: context,
      style: OrangeDialogStyle.blur,
      title: AppStrings.stopJourney,
      message: AppStrings.stopJourneyMessage,
      cancelLabel: AppStrings.cancel,
      confirmLabel: AppStrings.saveAndReset,
      isDestructive: true,
    );

    if (result == true) {
      await cubit.stopService();
      await cubit.resetRoute();
      OrangeSnackBar.success(message: AppStrings.routeReset);
    }
  }

  void showNewJourneyDialog(BuildContext context, HomeCubit cubit) {
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
