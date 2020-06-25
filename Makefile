default:
	dart2native bin/main.dart -o lox

ast:
	dart bin/tool/GenerateAst.dart bin && make format

format:
	dartfmt -w bin