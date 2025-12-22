part of 'test_cubit.dart';

final class TestState extends Equatable {
  final bool isLoading;
  final List<TestModel> testList;

  const TestState({required this.isLoading, required this.testList});

  TestState copyWith({bool? isLoading, List<TestModel>? testList}) {
    return TestState(
      isLoading: isLoading ?? this.isLoading,
      testList: testList ?? this.testList,
    );
  }

  @override
  List<Object> get props => [isLoading, testList];
}
