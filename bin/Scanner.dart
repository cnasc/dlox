import 'Token.dart';
import 'TokenType.dart';
import 'main.dart';

Map<String, TokenType> keywords = {
  'and': TokenType.AND,
  'class': TokenType.CLASS,
  'else': TokenType.ELSE,
  'false': TokenType.FALSE,
  'fun': TokenType.FUN,
  'for': TokenType.FOR,
  'if': TokenType.IF,
  'nil': TokenType.NIL,
  'or': TokenType.OR,
  'print': TokenType.PRINT,
  'return': TokenType.RETURN,
  'super': TokenType.SUPER,
  'this': TokenType.THIS,
  'true': TokenType.TRUE,
  'var': TokenType.VAR,
  'while': TokenType.WHILE,
};

class Scanner {
  final String _source;
  final List<Token> _tokens = [];
  int _start = 0;
  int _current = 0;
  int _line = 1;

  Scanner(this._source);

  List<Token> scanTokens() {
    while (!_isAtEnd()) {
      _start = _current;
      _scanToken();
    }

    _tokens.add(Token(TokenType.EOF, '', null, _line));
    return _tokens;
  }

  bool _isAtEnd() {
    return _current >= _source.length;
  }

  void _scanToken() {
    var c = _advance();
    switch (c) {
      case '(':
        _addToken(TokenType.LEFT_PAREN);
        break;
      case ')':
        _addToken(TokenType.RIGHT_PAREN);
        break;
      case '{':
        _addToken(TokenType.LEFT_BRACE);
        break;
      case '}':
        _addToken(TokenType.RIGHT_BRACE);
        break;
      case ',':
        _addToken(TokenType.COMMA);
        break;
      case '.':
        _addToken(TokenType.DOT);
        break;
      case '-':
        _addToken(TokenType.MINUS);
        break;
      case '+':
        _addToken(TokenType.PLUS);
        break;
      case ';':
        _addToken(TokenType.SEMICOLON);
        break;
      case '*':
        _addToken(TokenType.STAR);
        break;
      case '!':
        _addToken(_match('=') ? TokenType.BANG_EQUAL : TokenType.BANG);
        break;
      case '=':
        _addToken(_match('=') ? TokenType.EQUAL_EQUAL : TokenType.EQUAL);
        break;
      case '<':
        _addToken(_match('=') ? TokenType.LESS_EQUAL : TokenType.LESS);
        break;
      case '>':
        _addToken(_match('=') ? TokenType.GREATER_EQUAL : TokenType.GREATER);
        break;
      case '/':
        if (_match('/')) {
          // a comment goes until the end of the line
          while (_peek() != '\n' && !_isAtEnd()) {
            _advance();
          }
        } else if (_match('*')) {
          _blockComment();
        } else {
          _addToken(TokenType.SLASH);
        }
        break;

      case ' ':
      case '\r':
      case '\t':
        // ignore insignificant whitespace
        break;

      case '\n':
        _line++;
        break;

      case '"':
        _string();
        break;

      default:
        if (_isDigit(c)) {
          _number();
        } else if (_isAlpha(c)) {
          _identifier();
        } else {
          Lox.error(_line, 'Unexpected character "$c".');
        }
    }
  }

  void _identifier() {
    while (_isAlphanumeric(_peek())) {
      _advance();
    }

    var text = _source.substring(_start, _current);
    if (keywords.containsKey(text)) {
      _addToken(keywords[text]);
    } else {
      _addToken(TokenType.IDENTIFIER);
    }
  }

  void _blockComment() {
    var foundTerminator = () => _peek() == '*' && _peekNext() == '/';
    while (!foundTerminator() && !_isAtEnd()) {
      if (_peek() == '\n') _line++;
      _advance();
    }

    if (_isAtEnd()) {
      Lox.error(_line, 'Unterminated comment.');
    }

    // the closing */
    _advance();
    _advance();
  }

  void _string() {
    while (_peek() != '"' && !_isAtEnd()) {
      if (_peek() == '\n') _line++;
      _advance();
    }

    // Unterminated string
    if (_isAtEnd()) {
      Lox.error(_line, 'Unterminated string.');
      return;
    }

    // The closing "
    _advance();

    // Trim the surrounding quotes
    var value = _source.substring(_start + 1, _current - 1);
    _addToken(TokenType.STRING, value);
  }

  bool _isDigit(String c) {
    if (c == '\0') return false;
    return c.compareTo('0') >= 0 && c.compareTo('9') <= 0;
  }

  bool _isAlpha(String c) {
    return (c.compareTo('a') >= 0 && c.compareTo('z') <= 0) ||
        (c.compareTo('A') >= 0 && c.compareTo('Z') <= 0) ||
        c == '_';
  }

  bool _isAlphanumeric(String c) {
    return _isAlpha(c) || _isDigit(c);
  }

  void _number() {
    while (_isDigit(_peek())) {
      _advance();
    }

    if (_peek() == '.' && _isDigit(_peekNext())) {
      // consume the '.'
      _advance();
      while (_isDigit(_peek())) {
        _advance();
      }
    }

    _addToken(
        TokenType.NUMBER, double.parse(_source.substring(_start, _current)));
  }

  bool _match(String expected) {
    if (_isAtEnd()) return false;
    if (_source[_current] != expected) return false;

    _current++;
    return true;
  }

  String _peek() {
    if (_isAtEnd()) return '\0';
    return _source[_current];
  }

  String _peekNext() {
    if (_current + 1 >= _source.length) return '\0';
    return _source[_current + 1];
  }

  String _advance() {
    _current++;
    var res = _source[_current - 1];
    return res;
  }

  void _addToken(TokenType type, [Object literal]) {
    var text = _source.substring(_start, _current);
    _tokens.add(Token(type, text, literal, _line));
  }
}
