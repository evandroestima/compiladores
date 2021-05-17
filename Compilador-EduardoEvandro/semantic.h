#pragma once

#include "types.h"

struct expty {Tr_exp exp; Ty_ty ty;};
struct expty expTy(Tr_exp exp, Ty_ty ty);

extern S_table venv;
extern S_table tenv;

struct expty transVar(A_var v);
struct expty transExp(A_exp a);
void transDec(A_dec d);
struct Ty_ty transTy (A_ty a);

