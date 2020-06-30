import 'Expr.dart';
import 'TokenType.dart';

class Interpreter implements Visitor<Object> {
  @override
  Object visitLiteralExpr(Literal expr) {
    return expr.value;
  }

  @override
  Object visitGroupingExpr(Grouping expr) {
    return _evaluate(expr.expression);
  }

  @override 
  Object visitUnaryExpr(Unary expr) {
    var right = _evaluate(expr.right);
    switch (expr.operator.type) {
      case TokenType.MINUS:
        return -(right as double);
      case TokenType.BANG:
        return !_isTruthy(right);
      default:
    }

    return null;
  }

  @override
  Object visitBinaryExpr(Binary expr) {
    var left = _evaluate(expr.left);
    var right = _evaluate(expr.right);

    switch (expr.operator.type) {
      case TokenType.MINUS:
        return (left as double) - (right as double);
      case TokenType.SLASH:
        return (left as double) / (right as double);
      case TokenType.STAR:
        return (left as double) * (right as double);
      case TokenType.PLUS:
        if (left.runtimeType == double && right.runtimeType == double) {
          return (left as double) + (right as double);
        }
        if (left.runtimeType == String && right.runtimeType == String) {
          return (left as String) + (right as String);
        }
        break;
      case TokenType.GREATER:
        return (left as double) > (right as double);
      case TokenType.GREATER_EQUAL:
        return (left as double) >= (right as double);
      case TokenType.LESS:
        return (left as double) < (right as double);
      case TokenType.LESS_EQUAL:
        return (left as double) <= (right as double);
      case TokenType.BANG_EQUAL: return !_isEqual(left, right);
      case TokenType.EQUAL_EQUAL: return _isEqual(left, right);
      default:
    }

    // Unreachable.
    return null;
  }

  Object _evaluate(Expr expr) {
    return expr.accept(this);
  }

  bool _isTruthy(Object object) {
    if (object == null) return false;
    if (object is bool) return object;
    return true;
  }

  bool _isEqual(Object a, Object b) {
    // nil is only equal to nil.
    if (a == null && b == null) return true;
    if (a == null) return false;

    return a == b;
  }
}