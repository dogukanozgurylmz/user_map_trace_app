import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:user_map_trace_app/app/common/config/config.dart';
import 'package:user_map_trace_app/app/common/get_it/get_it.dart';
import 'package:user_map_trace_app/app/common/helpers/hive/hive_helper.dart';
import 'package:user_map_trace_app/core/helpers/device/device_info_helper.dart';

final class AppFunctions {
  AppFunctions._();
  static final AppFunctions instance = AppFunctions._();
  Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();
    // FlutterNativeSplash.preserve(
    //     widgetsBinding: ensureInitialized); //Splash'te silmelisin

    await DeviceInfoHelper.instance.init();
    Config.currentEnvironment = Environment.development;

    await HiveHelper.instance.init();

    await initializeDateFormatting('tr_TR', null);

    ServiceLocator().setup();

    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }
}
