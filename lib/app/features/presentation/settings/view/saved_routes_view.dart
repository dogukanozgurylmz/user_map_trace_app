import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_map_trace_app/app/common/constants/app_colors.dart';
import 'package:user_map_trace_app/app/common/constants/app_strings.dart';
import 'package:user_map_trace_app/app/common/get_it/get_it.dart';
import 'package:user_map_trace_app/app/common/router/app_router.dart';
import 'package:user_map_trace_app/app/features/data/models/route_model.dart';
import 'package:user_map_trace_app/app/features/presentation/settings/cubit/settings_cubit.dart';
import 'package:user_map_trace_app/app/features/presentation/settings/mixin/route_format_mixin.dart';

@RoutePage()
class SavedRoutesView extends StatelessWidget with RouteFormatMixin {
  const SavedRoutesView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt.get<SettingsCubit>(),
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.black2),
            onPressed: () => context.router.pop(),
          ),
          title: const Text(
            AppStrings.savedRoutes,
            style: TextStyle(
              color: AppColors.black2,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
        ),
        body: BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.green),
              );
            }

            if (state.routes.isEmpty) {
              return const Center(
                child: Text(
                  AppStrings.noSavedRoutes,
                  style: TextStyle(color: AppColors.grey, fontSize: 16),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => context.read<SettingsCubit>().loadRoutes(),
              color: AppColors.green,
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: state.routes.length,
                itemBuilder: (context, index) {
                  final route = state.routes[index];
                  return _RouteItem(
                    route: route,
                    formatDate: formatRouteDate,
                    formatDuration: formatRouteDuration,
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class _RouteItem extends StatelessWidget {
  const _RouteItem({
    required this.route,
    required this.formatDate,
    required this.formatDuration,
  });

  final RouteModel route;
  final String Function(DateTime) formatDate;
  final String Function(DateTime, DateTime) formatDuration;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.read<SettingsCubit>().selectRoute(route);
        context.router.push(const RouteDetailRoute());
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.grey.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              route.name,
              style: const TextStyle(
                color: AppColors.black2,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: AppColors.grey),
                const SizedBox(width: 4),
                Text(
                  formatDate(route.startDate),
                  style: const TextStyle(color: AppColors.grey, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.timer_outlined,
                  size: 16,
                  color: AppColors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  formatDuration(route.startDate, route.endDate),
                  style: const TextStyle(color: AppColors.grey, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: AppColors.grey),
                const SizedBox(width: 4),
                Text(
                  '${route.locations.length} konum',
                  style: const TextStyle(color: AppColors.grey, fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
