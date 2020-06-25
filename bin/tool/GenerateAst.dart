import 'dart:io';

class GenerateAst {
  static void main(String outputDir) {
    _defineAst(outputDir, 'Expr', [
      'Binary : Expr left, Token operator, Expr right',
      'Grouping : Expr expression:',
      'Literal : Object value',
      'Unary : Token operator, Expr right',
    ]);
  }

  static void _defineAst(
      String outputDir, String baseName, List<String> types) {
    var path = '$outputDir/$baseName.dart';
    var writer = File(path).openWrite();

    writer.writeln("import 'Token.dart';");
    writer.writeln('abstract class $baseName { const $baseName(); }');

    // The AST classes
    types.forEach((type) {
      writer.writeln();
      var className = type.split(':')[0].trim();
      var fields = type.split(':')[1].trim();
      _defineType(writer, baseName, className, fields);
    });

    writer.close();
  }

  static void _defineType(
      IOSink writer, String baseName, String className, String fieldList) {
    writer.writeln('class $className extends $baseName {');

    // Fields.
    var fields = fieldList.split(', ');
    fields.forEach((field) {
      writer.writeln('final $field;');
    });
    // Constructor.
    writer.write('const $className(');
    fields.forEach((field) {
      var name = field.split(' ')[1];
      writer.write('this.$name, ');
    });
    writer.writeln(');');
    writer.writeln('}');
  }
}

void main(List<String> arguments) {
  if (arguments.length != 1) {
    print('Usage: generate_ast <output_directory>');
    exit(64);
  }
  GenerateAst.main(arguments[0]);
}
