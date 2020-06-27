import 'Expr.dart';
import 'Token.dart';
import 'TokenType.dart';
import 'main.dart';

class ParseError extends Error {}

class Parser {
  final List<Token> _tokens;
  int _current = 0;

  Parser(this._tokens);

  Expr parse() {
    try {
      return _expression();
    } catch (error) {
      return null;
    }
  }

  Expr _expression() {
    return _equality();
  }

  Expr _equality() {
    var expr = _comparison();

    while (_match([TokenType.BANG_EQUAL, TokenType.EQUAL_EQUAL])) {
      var operator = _previous();
      var right = _comparison();
      expr = Binary(expr, operator, right);
    }

    return expr;
  }

  Expr _comparison() {
    var expr = _addition();

    while (_match([
      TokenType.GREATER,
      TokenType.GREATER_EQUAL,
      TokenType.LESS,
      TokenType.LESS_EQUAL
    ])) {
      var operator = _previous();
      var right = _addition();
      expr = Binary(expr, operator, right);
    }

    return expr;
  }

  Expr _addition() {
    var expr = _multiplication();

    while (_match([TokenType.PLUS, TokenType.MINUS])) {
      var operator = _previous();
      var right = _multiplication();
      expr = Binary(expr, operator, right);
    }

    return expr;
  }

  Expr _multiplication() {
    var expr = _unary();

    while (_match([TokenType.SLASH, TokenType.STAR])) {
      var operator = _previous();
      var right = _unary();
      expr = Binary(expr, operator, right);
    }

    return expr;
  }

  Expr _unary() {
    if (_match([TokenType.BANG, TokenType.MINUS])) {
      var operator = _previous();
      var right = _unary();
      return Unary(operator, right);
    }

    return _primary();
  }

  Expr _primary() {
    if (_match([TokenType.FALSE])) return Literal(false);
    if (_match([TokenType.TRUE])) return Literal(true);
    if (_match([TokenType.NIL])) return Literal(null);

    if (_match([TokenType.NUMBER, TokenType.STRING])) {
      return Literal(_previous().literal);
    }

    if (_match([TokenType.LEFT_PAREN])) {
      var expr = _expression();
      _consume(TokenType.RIGHT_PAREN, "Expect ')' after expression.");
      return Grouping(expr);
    }

    throw _error(_peek(), 'Expect expression.');
  }

  bool _match(List<TokenType> types) {
    for (var type in types) {
      if (_check(type)) {
        _advance();
        return true;
      }
    }

    return false;
  }

  Token _advance() {
    if (!_isAtEnd()) _current++;
    return _previous();
  }

  Token _peek() {
    return _tokens[_current];
  }

  Token _previous() {
    return _tokens[_current - 1];
  }

  ParseError _error(Token token, String message) {
    Lox.tokenError(token, message);
    return ParseError();
  }

  void _synchronize() {
    _advance();

    while (!_isAtEnd()) {
      if (_previous().type == TokenType.SEMICOLON) return;

      switch (_peek().type) {
        case TokenType.PLUS:
        case TokenType.FUN:
        case TokenType.VAR:
        case TokenType.FOR:
        case TokenType.IF:
        case TokenType.WHILE:
        case TokenType.PRINT:
        case TokenType.RETURN:
          return;
        default:
      }

      _advance();
    }
  }

  Token _consume(TokenType type, String message) {
    if (_check(type)) return _advance();

    throw _error(_peek(), message);
  }

  bool _isAtEnd() {
    return _peek().type == TokenType.EOF;
  }

  bool _check(TokenType type) {
    if (_isAtEnd()) return false;
    return _peek().type == type;
  }
}
