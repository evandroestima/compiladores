#include "ast.h"
#include <stdlib.h>
#include <stdio.h>

Arvore arv;

static void print_noInt(NoInt *no, int indent) {
	printf("%*s INT = %d \n", indent, "", no->valor);
}

static void print_noOpBin(NoOpBin *no, int indent) {
	printf("%*s OP. SOMA \n", indent, "");
	no->esq->print(no->esq, indent+4);
	no->dir->print(no->dir, indent+4);
}

NoInt* no_intC (int in) {
	NoInt *result = malloc(sizeof(*result));
	result->no.print = print_noInt;
	result->valor = in;
	
	return result;
}

NoOpBin* no_opBinC (enum op tipo, No *esq, No *dir) {
	NoOpBin *result = malloc(sizeof(*result));
	result->no.print = print_noOpBin;
	
	result->tipo = tipo;
	result->esq = esq;
	result->dir = dir;
	
	return result;
}
