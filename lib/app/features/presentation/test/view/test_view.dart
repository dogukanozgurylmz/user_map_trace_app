part of '../test_imports.dart';

@RoutePage()
class TestView extends StatelessWidget {
  const TestView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: BlocBuilder<TestCubit, TestState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(
              child: CircularProgressIndicator.adaptive(
                backgroundColor: AppColors.black,
              ),
            );
          }
          if (state.testList.isEmpty) {
            return const Center(
              child: Text(
                AppStrings.noData,
                style: TextStyle(color: AppColors.black),
              ),
            );
          }
          return ListView.separated(
            itemBuilder: (context, index) {
              final test = state.testList[index];
              return _ListItemWidget(test: test);
            },
            separatorBuilder: (context, index) {
              return const SizedBox(height: 8);
            },
            itemCount: state.testList.length,
          );
        },
      ),
    );
  }
}
