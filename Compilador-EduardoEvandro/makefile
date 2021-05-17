all: tiger.y tiger.lex
	 bison -d tiger.y
	 flex tiger.lex
	 gcc *.c -o tc
