# dlox

The `jlox` interpreter from [Crafting Interpreters](https://craftinginterpreters.com) implemented in dart.

## running
`make` will build a native executable using dart2native. From there you can run `./lox`

`make format` will run `dartfmt` on everything contained in `bin/`

`make ast` will generate classes for each kind of thing that goes in the AST. (the result of running this is committed already)