#include "ast.h"
#include <stdlib.h>
#include <stdio.h>

Arvore arv;



// #################### PRINTS ######################

static void print_noInt(NoInt *no, int indent) {
	printf("%*s INT = %d \n", indent, "", no->valor);
}

static void print_noOpBin(NoOpBin *no, int indent) {
	
	switch (no->tipo) {
		case SOMA:
			printf("%*s OP. SOMA \n", indent, "");
			break;
		
		case MULT:
			printf("%*s OP. MULT \n", indent, "");
			break;
		
		case SUBT:
			printf("%*s OP. SUBT \n", indent, "");
			break;
			
		case DIV:
			printf("%*s OP. DIV \n", indent, "");
			break;
		
		default;
	}
	no->esq->print(no->esq, indent+4);
	no->dir->print(no->dir, indent+4);
}

static void print_noString(NoString *no, int indent) {
	printf("%*s STRING = %s \n", indent, "", no->s);
}


// #################### CONTRUTORES ######################


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

NoString* no_stringC (char *in) {
	NoString *result = (NoString*) malloc(sizeof(*result));
	result->no.print = print_noString;
	
	result->s = (char*) malloc(sizeof(char));
	result->s = in;
	
	return result;
}
