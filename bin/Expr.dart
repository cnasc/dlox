import 'Token.dart';

abstract class Expr {
  const Expr();
}

class Binary extends Expr {
  final Expr left;
  final Token operator;
  final Expr right;
  const Binary(
    this.left,
    this.operator,
    this.right,
  );
}

class Grouping extends Expr {
  final Expr expression;
  const Grouping(
    this.expression,
  );
}

class Literal extends Expr {
  final Object value;
  const Literal(
    this.value,
  );
}

class Unary extends Expr {
  final Token operator;
  final Expr right;
  const Unary(
    this.operator,
    this.right,
  );
}