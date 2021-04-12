#pragma once

typedef struct no {
	void (*print) (struct no *self, int tabs);
} No;

typedef struct arvore {
	No *ini;
} Arvore;

extern Arvore arv;




typedef struct intt {
	struct no no;
	int valor;
} NoInt;

enum op {SOMA, MULT, SUBT, DIV};

typedef struct opbin{
	struct no no;
	enum op tipo;
	No *esq;
	No *dir;
}NoOpBin;

typedef struct sstring {
	char *s;
}NoString;

NoInt* no_intC (int in);
NoOpBin* no_opBinC (enum op tipo, No *esq, No *dir);

NoString* no_stringC (char *in);

