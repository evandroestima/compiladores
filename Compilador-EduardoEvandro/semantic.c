#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "symbol.h"
#include "types.h"
#include "ast.h"
#include "semantic.h"
#include "util.h"


#define TAM_LINHAS_TABNOMES 100
#define TAM_COLUNAS_TABNOMES 25

struct expty expTy(Tr_exp exp, Ty_ty ty) {
    struct expty e; e.exp=exp; e.ty=ty; return e;
}

struct expty transVar(A_var v);
struct expty transExp(A_exp a);
void transDec(A_dec d);
struct Ty_ty transTy (A_ty a);

S_table venv;
S_table tenv;


void transDecHead(A_dec d) {
	switch (d->kind) {
		case A_functionDec: {
					
		}
		break;
				
		case A_varDec: {
				
		}
		break;
		
		case A_typeDec: {
			//S_enter(tenv, d->u.type->head->name,);
		}
		break;
	}
}

char* Ty_to_String (Ty_ty tipo) {

    if (tipo->kind == Ty_Int()->kind) {
    	return "int";
    }
    				
    if (tipo->kind == Ty_String()->kind) {
    	return "string";
    }
 
    if (tipo->kind == Ty_Void()->kind) {
    	return "void";
    }
 
    if (tipo->kind == Ty_Nil()->kind) {
    	return "nil";
    }
 
    return "outro";
}

Ty_ty String_to_Ty (char* string) {

    if (!strcmp(string, "int")) {
    	return Ty_Int();
    }
    				
    if (!strcmp(string, "string")) {
    	return Ty_String();
    }
 
    if (!strcmp(string, "void")) {
    	return Ty_Void();
    }
    
   if (!strcmp(string, "nil")) {
    	return Ty_Nil();
   }
 
    return Ty_Void();
}											


Ty_fieldList InsereListB_em_ListA(A_efieldList *listaA, Ty_fieldList *listaB) {
				
	A_efieldList aux = (*listaA)->tail;
	Ty_fieldList aux2 = (*listaB);
				
	Ty_field pivo = NULL;
	while (aux != NULL) {
		pivo = checked_malloc(sizeof(*pivo));
		
		pivo->name = aux->head->name;
		pivo->ty = (transExp(aux->head->exp)).ty;
		
		aux2->tail = Ty_FieldList(pivo, NULL);
					
		aux2 = aux2->tail;
		aux = aux->tail;
	}
				
	return (*listaB);
}

bool listEquals(Ty_fieldList lista1, Ty_fieldList lista2) {
	
	if (lista1 == NULL) {
		if (lista2 == NULL) {
			return true;
		}
		else {
			return false;
		}
	
	}
	else {
		if (lista2 == NULL) {
			return false;
		}
		if (strcmp(S_name(lista1->head->name), S_name(lista2->head->name))) {
			if (lista1->head->ty->kind == lista2->head->ty->kind) {
				return listEquals(lista1->tail, lista2->tail);
			}
		}
	}
	return false;
}


struct expty transVar(A_var v) {
	
	switch (v->kind) {
		
		case A_simpleVar: {
			if (!(S_look(venv, v->u.simple))) {
				printf("\n\n Erro: Varialvel utilizada é inexistente.\n");
				exit(1);
			}
			
			return (expTy(v, String_to_Ty(S_name(S_look(venv, S_Symbol(S_name(v->u.simple)))))));
		}
		break;
		
		case A_fieldVar: {
			
		}
		break;
		
		case A_subscriptVar: {
			S_beginScope(venv);
			
			Ty_ty tipo = S_look(venv, v->u.subscript.var->u.simple);
			if ((tipo) != Ty_Array(NULL)) {
				printf("\n\n Erro: variavel usada não é um array.\n");
				exit(1);
			}
			
			S_endScope(venv);
		}
		break;
	}
	
}

struct expty transExp(A_exp a) {
    				
	
	switch (a->kind) {
		
		case A_varExp: 
			return transVar(a->u.var);
    		case A_nilExp:
    			return(expTy(a, Ty_Nil()));
    		case A_intExp:
    			return(expTy(a, Ty_Int()));
    			
    		case A_stringExp:
    			return(expTy(a, Ty_String()));
    			
    		case A_callExp: {
    		
    			A_fundec funnn = S_look(venv, a->u.call.func);
    			if (!(funnn)) {
				printf("\n\n Erro: Função utilizada é inexistente.\n");
				exit(1);
			}
			
			A_expList args = a->u.call.args;
			A_fieldList params = funnn->params;
    			
    			while ((args != NULL) && (params != NULL)) {
    				A_field fld = params->head;
    				Ty_ty tipoArg = transExp(args->head).ty;
    				
    				//printf("\n\n CallExp %s , %s , %s\n", Ty_to_String(tipoExp), S_name(fld->typ), S_name(fld->name));
    				if (strcmp(Ty_to_String(tipoArg), S_name(fld->typ))) {
    					printf("\n\n Erro: O tipo de um parâmetro de uma das funções não corresponde ao do código.\n");
    					exit(1);
    				}
    				
    				args = args->tail;
    				params = params->tail;
    			}
    			if ((args) || (params)) {
    				printf("\n\n Erro: Numero diferentes de parâmetros e argumentos.\n");
    				exit(1);
    			}
			
			return (expTy(a, String_to_Ty(S_name(funnn->result))));
    			
    		}
    		break;
    			
    		case A_opExp: ;
    		
    			struct expty esquerda;
			struct expty direita;
		
			esquerda = transExp(a->u.op.left);
			direita = transExp(a->u.op.right);
	
    			switch (a->u.op.oper) {
    				case A_plusOp: {
    					if((esquerda.ty != Ty_Int()) || (direita.ty != Ty_Int())) {
    						printf("\n\n Tentativa de soma falhou: ambos os argumentos tem de ser inteiros.\n");
    						exit(1);
    					}
    					return (expTy(a, Ty_Int()));
    				}
    				break;
    				
    				case A_minusOp: {
    					if((esquerda.ty != Ty_Int()) || (direita.ty != Ty_Int())) {
    						printf("\n\n Tentativa de subtração falhou: ambos os argumentos tem de ser inteiros.\n");
    						exit(1);
    					}
    					return (expTy(a, Ty_Int()));
    				}
    				
    				break;
    				
    				case A_timesOp: {
    					if((esquerda.ty != Ty_Int()) || (direita.ty != Ty_Int())) {
    						printf("\n\n Tentativa de multiplicação falhou: ambos os argumentos tem de ser inteiros.\n");
    						exit(1);
    					}
    					return (expTy(a, Ty_Int()));
    				}
    				
    				break;
    				
    				case A_divideOp: {
    					if((esquerda.ty != Ty_Int()) || (direita.ty != Ty_Int())) {
    						printf("\n\n Tentativa de divisão falhou: ambos os argumentos tem de ser inteiros.\n");
    						exit(1);
    					}
    					return (expTy(a, Ty_Int()));
    				}
    				
    				break;
    				
    				case A_eqOp: {
    					if (esquerda.ty->kind != direita.ty->kind) {
    						printf("\n\n Operação de igualdade falhou: ambos os argumentos tem de ser do mesmo tipo.\n");
    						exit(1);
    					}
    					
    					switch (esquerda.ty->kind) {
    						case Ty_record: {
    							if (listEquals(esquerda.ty->u.record, esquerda.ty->u.record)) {
    								return (expTy(a, Ty_Record(esquerda.ty->u.record)));
    							}
    						}
    						break;
    						
    						case Ty_nil: {
    							printf("\n\n Operação de igualdade falhou: não se pode comparar nil = nil.\n");
    							exit(1);
    						}
    						break;
    						
    						case Ty_int: {
    							return (expTy(a, Ty_Int()));
    						}
    						break;
    						
    						case Ty_string: {
    							return (expTy(a, Ty_String()));
    						}
    						break;
    						
    						case Ty_array: {
    							if (esquerda.ty->u.array != direita.ty->u.array) {
    								printf("\n\n Operação de igualdade falhou: ambos os arrays tem de ser do mesmo tipo.\n");
    								exit(1);
    							}
    							return (expTy(a, Ty_Array(esquerda.ty->u.array)));
    						}
    						break;
    						
    						case Ty_name: {
    						//	if (esquerda.ty != direita.ty) {
    						//		printf("\n\n Operação de igualdade falhou: ambos os nomes de tipo  tem devem ter a mesma tipagem de origem.\n");
    						//		exit(1);
    						//	}
    						//	return (expTy(a, Ty_Name(esquerda.ty->u.name.sym, esquerda.ty->u.name.ty)));
    							printf("\n\n Operação de igualdade falhou: Não é possivel fazer uma operação  entre nomes de tipos.\n");
    							exit(1);
    						}
    						break;
    						
    						case Ty_void: {
    							
    							return (expTy(a, Ty_Void()));
    						}
    					}
    				
    				}
    				break;
    				
    				case A_neqOp: {
    					if (esquerda.ty->kind != direita.ty->kind) {
    						printf("\n\n Operação de diferença falhou: ambos os argumentos tem de ser do mesmo tipo.\n");
    						exit(1);
    					}
    					
    					switch (esquerda.ty->kind) {
    						case Ty_record: {
    							if (listEquals(esquerda.ty->u.record, esquerda.ty->u.record)) {
    								return (expTy(a, Ty_Record(esquerda.ty->u.record)));
    							}
    						}
    						break;
    						
    						case Ty_nil: {
    							printf("\n\n Operação de diferença falhou: não se pode comparar nil = nil.\n");
    							exit(1);
    						}
    						break;
    						
    						case Ty_int: {
    							return (expTy(a, Ty_Int()));
    						}
    						break;
    						
    						case Ty_string: {
    							return (expTy(a, Ty_String()));
    						}
    						break;
    						
    						case Ty_array: {
    							if (esquerda.ty->u.array != direita.ty->u.array) {
    								printf("\n\n Operação de diferença falhou: ambos os arrays tem de ser do mesmo tipo.\n");
    								exit(1);
    							}
    							return (expTy(a, Ty_Array(esquerda.ty->u.array)));
    						}
    						break;
    						
    						case Ty_name: {
    						//	if (esquerda.ty != direita.ty) {
    						//		printf("\n\n Operação de igualdade falhou: ambos os nomes de tipo  tem devem ter a mesma tipagem de origem.\n");
    						//		exit(1);
    						//	}
    						//	return (expTy(a, Ty_Name(esquerda.ty->u.name.sym, esquerda.ty->u.name.ty)));
    							printf("\n\n Operação de diferença falhou: Não é possivel fazer uma operação  entre nomes de tipos.\n");
    							exit(1);
    						}
    						break;
    						
    						case Ty_void: {
    							return (expTy(a, Ty_Void()));
    						}
    					}
    				
    				}
    				break;
    				
    				case A_ltOp: {
    					if (esquerda.ty->kind != direita.ty->kind) {
    						printf("\n\n Operação de 'menor que' falhou: ambos os argumentos tem de ser do mesmo tipo.\n");
    						exit(1);
    					}
    					
    					switch (esquerda.ty->kind) {
    						case Ty_record: {
    							printf("\n\n Operação de 'menor que' falhou: não se pode utilizar registros nesse tipo de operação.\n");
    							exit(1);
    						}
    						break;
    						
    						case Ty_nil: {
    							printf("\n\n Operação de 'menor que' falhou: não se pode comparar nil = nil.\n");
    							exit(1);
    						}
    						
    						break;
    						
    						case Ty_int: {
    							return (expTy(a, Ty_Int()));
    						}
    						break;
    						
    						case Ty_string: {
    							return (expTy(a, Ty_String()));
    						}
    						break;
    						
    						case Ty_array: {
    							printf("\n\n Operação de 'menor que' falhou: não se pode utilizar arrays nesse tipo de operação.\n");
    							exit(1);
    						}
    						break;
    						
    						case Ty_name: {
    						//	if (esquerda.ty != direita.ty) {
    						//		printf("\n\n Operação de igualdade falhou: ambos os nomes de tipo  tem devem ter a mesma tipagem de origem.\n");
    						//		exit(1);
    						//	}
    						//	return (expTy(a, Ty_Name(esquerda.ty->u.name.sym, esquerda.ty->u.name.ty)));
    						printf("\n\n Operação de 'menor que' falhou: Não é possivel fazer uma operação  entre nomes de tipos.\n");
    						exit(1);
    						}
    						break;
    						
    						case Ty_void: {
    							return (expTy(a, Ty_Void()));
    						}
    					}
    				
    				}
    				break;
    				
    				case A_leOp: {
    					if (esquerda.ty->kind != direita.ty->kind) {
    						printf("\n\n Operação de 'menor ou igual que' falhou: ambos os argumentos tem de ser do mesmo tipo.\n");
    						exit(1);
    					}
    					
    					switch (esquerda.ty->kind) {
    						case Ty_record: {
    							printf("\n\n Operação de 'menor ou igual que' falhou: não se pode utilizar registros nesse tipo de operação.\n");
    							exit(1);
    						}
    						break;
    						
    						case Ty_nil: {
    							printf("\n\n Operação de 'menor ou igual que' falhou: não se pode comparar nil = nil.\n");
    							exit(1);
    						}
    						break;
    						
    						case Ty_int: {
    							return (expTy(a, Ty_Int()));
    						}
    						break;
    						
    						case Ty_string: {
    							return (expTy(a, Ty_String()));
    						}
    						break;
    						
    						case Ty_array: {
    							printf("\n\n Operação de 'menor ou igual que' falhou: não se pode utilizar arrays nesse tipo de operação.\n");
    							exit(1);
    						}
    						break;
    						
    						case Ty_name: {
    						//	if (esquerda.ty != direita.ty) {
    						//		printf("\n\n Operação de igualdade falhou: ambos os nomes de tipo  tem devem ter a mesma tipagem de origem.\n");
    						//		exit(1);
    						//	}
    						//	return (expTy(a, Ty_Name(esquerda.ty->u.name.sym, esquerda.ty->u.name.ty)));
    							printf("\n\n Operação de 'menor ou igual que' falhou: Não é possivel fazer uma operação  entre nomes de tipos.\n");
    							exit(1);
    						}
    						break;
    						
    						case Ty_void: {
    							return (expTy(a, Ty_Void()));
    						}
    					}
    				
    				}
    				break;
    				
    				case A_gtOp:  {
    					if (esquerda.ty->kind != direita.ty->kind) {
    						printf("\n\n Operação de 'maior que' falhou: ambos os argumentos tem de ser do mesmo tipo.\n");
    						exit(1);
    					}
    					
    					switch (esquerda.ty->kind) {
    						case Ty_record: {
    							printf("\n\n Operação de 'maior que' falhou: não se pode utilizar registros nesse tipo de operação.\n");
    							exit(1);
    						}
    						break;
    						
    						case Ty_nil: {
    							printf("\n\n Operação de 'maior que' falhou: não se pode comparar nil = nil.\n");
    							exit(1);
    						}
    						break;
    						
    						case Ty_int: {
    							return (expTy(a, Ty_Int()));
    						}
    						break;
    						
    						case Ty_string: {
    							return (expTy(a, Ty_String()));
    						}
    						break;
    						
    						case Ty_array: {
    							printf("\n\n Operação de 'maior que' falhou: não se pode utilizar arrays nesse tipo de operação.\n");
    							exit(1);
    						}
    						break;
    						
    						case Ty_name: {
    						//	if (esquerda.ty != direita.ty) {
    						//		printf("\n\n Operação de igualdade falhou: ambos os nomes de tipo  tem devem ter a mesma tipagem de origem.\n");
    						//		exit(1);
    						//	}
    						//	return (expTy(a, Ty_Name(esquerda.ty->u.name.sym, esquerda.ty->u.name.ty)));
    						printf("\n\n Operação de 'maior que' falhou: Não é possivel fazer uma operação  entre nomes de tipos.\n");
    						exit(1);
    						}
    						break;
    						
    						case Ty_void: {
    							return (expTy(a, Ty_Void()));
    						}
    					}
    				
    				}
    				break; 
    				
    				case A_geOp: {
    					if (esquerda.ty->kind != direita.ty->kind) {
    						printf("\n\n Operação de 'maior ou igual que' falhou: ambos os argumentos tem de ser do mesmo tipo.\n");
    						exit(1);
    					}
    					
    					switch (esquerda.ty->kind) {
    						case Ty_record: {
    							printf("\n\n Operação de 'maior ou igual que' falhou: não se pode utilizar registros nesse tipo de operação.\n");
    							exit(1);
    						}
    						break;
    						
    						case Ty_nil: {
    							printf("\n\n Operação de 'maior ou igual que' falhou: não se pode comparar nil = nil.\n");
    							exit(1);
    						}
    						break;
    						
    						case Ty_int: {
    							return (expTy(a, Ty_Int()));
    						}
    						break;
    						
    						case Ty_string: {
    							return (expTy(a, Ty_String()));
    						}
    						break;
    						
    						case Ty_array: {
    							printf("\n\n Operação de 'maior ou igual' falhou: não se pode utilizar arrays nesse tipo de operação.\n");
    							exit(1);
    						}
    						break;
    						
    						case Ty_name: {
    						//	if (esquerda.ty != direita.ty) {
    						//		printf("\n\n Operação de igualdade falhou: ambos os nomes de tipo  tem devem ter a mesma tipagem de origem.\n");
    						//		exit(1);
    						//	}
    						//	return (expTy(a, Ty_Name(esquerda.ty->u.name.sym, esquerda.ty->u.name.ty)));
    						printf("\n\n Operação de 'maior ou igual' falhou: Não é possivel fazer uma operação  entre nomes de tipos.\n");
    						exit(1);
    						}
    						break;
    						
    						case Ty_void: {
    							return (expTy(a, Ty_Void()));
    						}
    					}
    				
    				}
    				break;
    				
    				case A_orOp: {
    					if (esquerda.ty->kind != direita.ty->kind) {
    						printf("\n\n Operação lógica 'OR' falhou: ambos os argumentos tem de ser do mesmo tipo.\n");
    						exit(1);
    					}
    					
    					switch (esquerda.ty->kind) {
    						case Ty_record: {
    							printf("\n\n Operação lógica 'OR' falhou: não se pode utilizar registros nesse tipo de operação.\n");
    							exit(1);
    						}
    						break;
    						
    						case Ty_nil: {
    							printf("\n\n Operação lógica 'OR' falhou: não se pode comparar nil = nil.\n");
    							exit(1);
    						}
    						break;
    						
    						case Ty_int: {
    							return (expTy(a, Ty_Int()));
    						}
    						break;
    						
    						case Ty_string: {
    							return (expTy(a, Ty_String()));
    						}
    						break;
    						
    						case Ty_array: {
    							printf("\n\n Operação lógica 'OR' falhou: não se pode utilizar arrays nesse tipo de operação.\n");
    							exit(1);
    						}
    						break;
    						
    						case Ty_name: {
    						//	if (esquerda.ty != direita.ty) {
    						//		printf("\n\n Operação de igualdade falhou: ambos os nomes de tipo  tem devem ter a mesma tipagem de origem.\n");
    						//		exit(1);
    						//	}
    						//	return (expTy(a, Ty_Name(esquerda.ty->u.name.sym, esquerda.ty->u.name.ty)));
    						printf("\n\n Operação lógica 'OR' falhou: Não é possivel fazer uma operação  entre nomes de tipos.\n");
    						exit(1);
    						}
    						break;
    						
    						case Ty_void: {
    							return (expTy(a, Ty_Void()));
    						}
    					}
    				
    				}
    				break;
    				
    				case A_andOp: {
    					if (esquerda.ty->kind != direita.ty->kind) {
    						printf("\n\n Operação lógica 'AND' falhou: ambos os argumentos tem de ser do mesmo tipo.\n");
    						exit(1);
    					}
    					
    					switch (esquerda.ty->kind) {
    						case Ty_record: {
    							printf("\n\n Operação lógica 'AND' falhou: não se pode utilizar registros nesse tipo de operação.\n");
    							exit(1);
    						}
    						break;
    						
    						case Ty_nil: {
    							printf("\n\n Operação lógica 'AND' falhou: não se pode comparar nil = nil.\n");
    							exit(1);
    						}
    						break;
    						
    						case Ty_int: {
    							return (expTy(a, Ty_Int()));
    						}
    						break;
    						
    						case Ty_string: {
    							return (expTy(a, Ty_String()));
    						}
    						break;
    						
    						case Ty_array: {
    							printf("\n\n Operação lógica 'AND' falhou: não se pode utilizar arrays nesse tipo de operação.\n");
    							exit(1);
    						}
    						break;
    						
    						case Ty_name: {
    						//	if (esquerda.ty != direita.ty) {
    						//		printf("\n\n Operação de igualdade falhou: ambos os nomes de tipo  tem devem ter a mesma tipagem de origem.\n");
    						//		exit(1);
    						//	}
    						//	return (expTy(a, Ty_Name(esquerda.ty->u.name.sym, esquerda.ty->u.name.ty)));
    							printf("\n\n Operação lógica 'AND' falhou: Não é possivel fazer uma operação  entre nomes de tipos.\n");
    							exit(1);
    						}
    						break;
    						
    						case Ty_void: {
    							return (expTy(a, Ty_Void()));
    						}
    					}
    					break;
    				}
    				
    			}
    			break;
    			
      			case A_recordExp: { 
      			
      				A_efieldList listaA = a->u.record.fields;
      				
      				Ty_fieldList listaB = Ty_FieldList(Ty_Field(listaA->head->name, (transExp(listaA->head->exp)).ty), NULL);
      				
      				listaB = InsereListB_em_ListA(&listaA, &listaB);
      				
      				return(expTy(a, Ty_Record(listaB)));
      			}
      			break;
    		
    			case A_seqExp: {
    				
    				A_expList aux = a->u.seq;
    				A_exp E = a->u.seq->head;
    				
    				while ((aux != NULL) && (E != NULL)) {
    					transExp(E);
    					
    					aux = aux->tail;
    					if (aux != NULL) {
    						E = aux->head;
    					}
    				}
    				
    				return (expTy(a, Ty_Void()));
    			}
    			break;
    			
    			case A_assignExp: {
    				
    				transExp(a->u.assign.exp);
    				transVar(a->u.assign.var);
    				
    				return (expTy(a, Ty_Void()));
    			}
    			break;
    			
    			case A_ifExp: {
    				transExp(a->u.iff.test);
    				
    				struct expty then_ty = transExp(a->u.iff.then);
    				
    				struct expty else_ty = {NULL, Ty_Void()};
    				
    				if (a->u.iff.elsee) {
    					else_ty = transExp(a->u.iff.elsee);
    				}
    				
    				if (then_ty.ty != else_ty.ty) {
    				
    					if (a->u.iff.elsee) {
    						printf("\n\n Erro semantico, ambos o 'then' e o 'else' devem ser iguais. \n");
    					}
    					else {
    						printf("\n\n Erro: Quando não tem else, o then não pode produzir valor.");
    					}
    					
    					exit(1);
    				}
    				
    				
    				return (expTy(a, Ty_Void()));
    			}
    			break;
    			
    			case A_whileExp: {
    				if (transExp(a->u.whilee.test).ty != Ty_Int()) {
    					printf("\n\n Erro: condição do while inválida.\n");
    					exit(1);
    				}
    				if (transExp(a->u.whilee.body).ty != Ty_Void()) {
    					printf("\n\n Erro: corpo do while não pode produzir valor.\n");
    					exit(1);
    				}
    				
    				return (expTy(a, Ty_Void()));
    			}
    			break;
    			
    			case A_forExp: {
    				//Verificar Symbol??
    				
    				transExp(a->u.forr.lo);
    				transExp(a->u.forr.hi);
    				transExp(a->u.forr.body);
    				
    				return (expTy(a, Ty_Void()));
    			}
    			break;
    			
    			case A_breakExp: {
    				return (expTy(a, Ty_Void()));
    			}
    			break;
    			
    			case A_letExp: {
    				
    				A_decList aux = a->u.let.decs;
    				A_dec D = a->u.let.decs->head;
    				
    				while ((aux != NULL) && (D != NULL)) {
    					
    					transDecHead(D);
    					
    					aux = aux->tail;
    					if (aux != NULL) {
    						D = aux->head;
    					}
    				}
    				
    				aux = a->u.let.decs;
    				D = a->u.let.decs->head;
    				
    				S_beginScope(venv);
    				S_beginScope(tenv);
    				
    				while ((aux != NULL) && (D != NULL)) {
    					
    					transDec(D);
    					
    					aux = aux->tail;
    					if (aux != NULL) {
    						D = aux->head;
    					}
    				}
    				
    				Ty_ty tipoResultante = NULL;
    				A_expList aux2 = a->u.let.body;
    				A_exp E = a->u.let.body->head;
    				int cont = 1;
    				
    				while ((aux2 != NULL) && (E != NULL)) {
    					if (cont == 1) {
    						tipoResultante = transExp(E).ty;
    					}
    					else {
    						transExp(E);
    					}
    					aux2 = aux2->tail;
    					if (aux != NULL) {
    						E = aux2->head;
    					}
    					cont++;
    				}
    				
    				S_endScope(venv);
    				S_endScope(tenv);
    				
    				return (expTy(a, tipoResultante));
    			}
    			break;
    		
    			case A_arrayExp: {
    				//Verificar Symbol??
    				
    				transExp(a->u.array.size);
    				transExp(a->u.array.init);
    				
    				return (expTy(a, Ty_Void()));
    			}
    			break;
    			
	}
	
	
    	
}


void transDec(A_dec d) {
	
	switch (d->kind) {
		
		case A_functionDec: {
			
			A_fundecList aux = d->u.function;
			A_fundec func = d->u.function->head;
    			
    			S_beginScope(venv);
    			
    			while ((aux != NULL) && (func != NULL)) {
    				
    				A_fieldList aux2 = func->params;
				A_field fld = func->params->head;
				
    				while ((aux2 != NULL) && (fld != NULL)) {
    					
    					printf("\n\n Declarando parametros\n %s      %s", S_name(fld->name), S_name(fld->typ));
    					S_enter(venv, fld->name, fld->typ);
    					
    					aux2 = aux2->tail;
    					if (aux2 != NULL) {
    						fld = aux2->head;
    					}
    				}
    				
    				Ty_ty tipoExp = transExp(aux->head->body).ty;
    				
    				if (strcmp(Ty_to_String(tipoExp), S_name(aux->head->result))) {
    					printf("\n\n Erro: O corpo da função retorna um valor de tipo diferente do que o declarado.\n");
    					exit(1);
    				}
    				
    				aux = aux->tail;
    				if (aux != NULL) {
    					func = aux->head;
    				}
    			}
			S_endScope(venv);
			
			S_enter(venv, d->u.function->head->name, d->u.function->head);
		}
		break;
		
		case A_varDec: {	
			S_beginScope(venv);
			
			Ty_ty tipoArg = transExp(d->u.var.init).ty;
			
			if (d->u.var.typ != NULL) {
				if (strcmp(Ty_to_String(tipoArg), S_name(d->u.var.typ))) {
					printf("\n\n Erro: Declaração não tem o mesmo tipo que a expressão que o representa.\n");
					exit(1);
				}
				S_enter(venv, d->u.var.var, d->u.var.typ);
			}
			else { 
				S_enter(venv, d->u.var.var, S_Symbol(Ty_to_String(tipoArg)));
			}
			
			
			S_endScope(venv);
		}
		break;
		
		case A_typeDec: {
			
			A_namety novo = d->u.type->head;
    			
			switch (novo->ty->kind) {
				case A_nameTy: {
					S_symbol nome = novo->ty->u.name;
					
					A_ty atual = S_look(tenv, nome);
					
					if (!atual) {
						printf("\n\n Erro: Tipo utilizado é inexistente.\n");
						exit(1);
					}
			
					char *pivo = S_name(novo->name);
					
					
		    			while (atual->kind == A_nameTy) {
		  				
			    			if (!strcmp(S_name(atual->u.name), pivo)) {
			    				printf("\n\n Erro: tipos recursivos entre tipos primitivos não é permtido.");
							exit(1);
			    			}
			    			atual = S_look(tenv, atual->u.name);
    					}
    					S_enter(tenv, novo->name, novo->ty);
				}
				break;
				
				case A_recordTy: {
					
				}
				break;
				
				case A_arrayTy: {
					
				}
				break;
			}
			
			
    			
    			S_endScope(tenv);
		}
	}
}



struct Ty_ty transTy (A_ty a);
