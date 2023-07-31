#ifndef RUNTIME_CUSTOMFUNC
#define RUNTIME_CUSTOMFUNC

#include "runtime.h"
#include "values.h"
#include <inttypes.h>

// Used for tests, DO NOT REMOVE THESE OR THEIR CODE IN customefunc.c
int64_t silly();
int64_t return_void();
int64_t return_int();
int64_t return_bool();
int64_t return_char();
int64_t help();
int64_t add();
int64_t sqrt();

int64_t returnSameVal(int64_t val);
int64_t returnSixArgs(int64_t valOne, int64_t valTwo, int64_t valThree,
                      int64_t valFour, int64_t valFive, int64_t valSix);

int64_t returnSevenArgs(int64_t valOne, int64_t valTwo, int64_t valThree,
                        int64_t valFour, int64_t valFive, int64_t valSix,
                        int64_t valSeven);

int64_t exploit_c_var(int64_t first, int64_t second, int64_t third,
                      int64_t fourth, int64_t fifth, int64_t sixth,
                      int64_t stack_first);

int64_t exploit_c_func(int64_t first, int64_t second, int64_t third,
                       int64_t fourth, int64_t fifth, int64_t sixth,
                       int64_t stack_first);

int64_t exploit_c_defines(int64_t first, int64_t second, int64_t third,
                          int64_t fourth, int64_t fifth, int64_t sixth,
                          int64_t stack_first);

#endif /* RUNTIME_H */