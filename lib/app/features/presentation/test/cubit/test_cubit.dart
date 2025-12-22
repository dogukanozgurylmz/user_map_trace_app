import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:orange_sdk/orange_sdk.dart';
import 'package:user_map_trace_app/app/features/data/models/test_model.dart';
import 'package:user_map_trace_app/app/features/data/repositories/test_repository.dart';

part 'test_state.dart';

final class TestCubit extends Cubit<TestState> {
  TestCubit({required TestRepository testRepository})
    : _testRepository = testRepository,
      super(const TestState(isLoading: false, testList: []));

  final TestRepository _testRepository;

  Future<void> getAllTests() async {
    emit(state.copyWith(isLoading: true, testList: []));
    await Future.delayed(Durations.extralong4 * 4);
    var dataResult = await _testRepository.getAll();
    if (!dataResult.success) {
      OrangeSnackBar.error(message: dataResult.message ?? "Unknown error");
      emit(state.copyWith(isLoading: false));
      return;
    }
    emit(state.copyWith(isLoading: false, testList: dataResult.data));
    OrangeSnackBar.success(message: dataResult.message ?? "Unknown error");
  }
}
