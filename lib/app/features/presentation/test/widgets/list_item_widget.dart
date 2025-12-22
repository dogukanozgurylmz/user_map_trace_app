part of '../test_imports.dart';

class _ListItemWidget extends StatelessWidget {
  const _ListItemWidget({required this.test});

  final TestModel test;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(test.title ?? ""),
      subtitle: Text("${test.count ?? ""}"),
      selected: test.hasTest ?? false,
    );
  }
}
