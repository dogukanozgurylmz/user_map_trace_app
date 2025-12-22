class Either<L, R> {
  late final L _left;
  late final R _right;
  final bool _isLeft;

  Either.left(L l)
      : _left = l,
        _isLeft = true;

  Either.right(R r)
      : _right = r,
        _isLeft = false;

  bool get isLeft => _isLeft;
  bool get isRight => !_isLeft;

  L get left {
    if (!_isLeft) {
      throw StateError('Tried to access left value on a right Either');
    }
    return _left;
  }

  R get right {
    if (_isLeft) {
      throw StateError('Tried to access right value on a left Either');
    }
    return _right;
  }
}
