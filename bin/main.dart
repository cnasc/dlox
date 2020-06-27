import 'dart:io';

import 'AstPrinter.dart';
import 'Parser.dart';
import 'Scanner.dart';
import 'Token.dart';
import 'TokenType.dart';

class Lox {
  static bool hadError = false;

  static void main(List<String> args) {
    if (args.length > 1) {
      print('Usage: dlox [script]');
      exit(64);
    } else if (args.length == 1) {
      _runFile(args[0]);
    } else {
      _runPrompt();
    }
  }

  static void _runFile(String path) {
    var bytes = File(path).readAsBytesSync();
    _run(String.fromCharCodes(bytes));

    // Indicate an error in the exit code
    if (hadError) exit(65);
  }

  static void _runPrompt() {
    for (;;) {
      stdout.write('> ');
      _run(stdin.readLineSync());
      hadError = false;
    }
  }

  static void _run(String source) {
    var scanner = Scanner(source);
    var tokens = scanner.scanTokens();
    var parser = Parser(tokens);
    var expression = parser.parse();

    // Stop if there was a syntax error.
    if (hadError) return;
    
    print(AstPrinter().print(expression));
  }

  static void error(int line, String message) {
    _report(line, '', message);
  }

  static void tokenError(Token token, String message) {
    if (token.type == TokenType.EOF) {
      _report(token.line, ' at end', message);
    } else {
      _report(token.line, ' at ${token.lexeme}', message);
    }
  }

  static void _report(int line, String where, String message) {
    print('[line $line] Error $where: $message');
  }
}

void main(List<String> arguments) {
  Lox.main(arguments);
}
