#include "customfunc.h"
#include <stdio.h>

int64_t silly() {
    // printf("hi!");
    return val_wrap_int(32984589245);
}

int64_t return_void() { return val_wrap_void(); }
int64_t return_int() { return val_wrap_int(251); }
int64_t return_bool() { return val_wrap_bool(0); }
int64_t return_char() { return val_wrap_char('g'); }

int64_t help() { return val_wrap_int(5); }
int64_t add() { return val_wrap_int(3); }
int64_t sqrt() { return val_wrap_int(1); }

// In theory: since seventh arg is first on stack, use it to work backwards to
// access x and change it
int64_t exploit_c_var(int64_t first, int64_t second, int64_t third,
                      int64_t fourth, int64_t fifth, int64_t sixth,
                      int64_t stack_first) {
    /*printf("first: %p\n", &first);
    printf("second: %p\n", &second);
    printf("third: %p\n", &third);
    printf("fourth: %p\n", &fourth);
    printf("fifth: %p\n", &fifth);
    printf("sixth: %p\n", &sixth);
    printf("seventh: %p\n", &stack_first);*/

    /*
    int i = -5;
    for (i; i <= 5; i++) {
        printf("val? %d - %d\n", i, *(xLoc + i));
    }
    printf("compare to: %d\n", val_wrap_int(5));
    */

    int64_t *xLoc = &stack_first;
    *(xLoc + 1) = val_wrap_int(41); // go 1 value up the stack to x

    return val_wrap_void();
}

int64_t exploit_c_func(int64_t first, int64_t second, int64_t third,
                       int64_t fourth, int64_t fifth, int64_t sixth,
                       int64_t stack_first) {
    int64_t *xLoc = &stack_first;
    *(xLoc + 1) = *(xLoc + 2); // replace "run me" with "dont run me" lambda

    return val_wrap_void();
}

int64_t exploit_c_defines(int64_t first, int64_t second, int64_t third,
                          int64_t fourth, int64_t fifth, int64_t sixth,
                          int64_t stack_first) {
    int64_t *xLoc = &stack_first;
    *(xLoc + 2) = *(xLoc + 1); // replace "run me" with "dont run me" lambda

    return val_wrap_void();
}

int64_t returnSameVal(int64_t val) {
    printf("val: %d\n", val_unwrap_int(val));
    return val;
}

int64_t returnSixArgs(int64_t valOne, int64_t valTwo, int64_t valThree,
                      int64_t valFour, int64_t valFive, int64_t valSix) {
    printf("val 1: %d\n", val_unwrap_int(valOne));
    printf("val 2: %d\n", val_unwrap_bool(valTwo));
    printf("val 3: %c\n", val_unwrap_char(valThree));
    printf("val 4: %c\n", val_unwrap_char(valFour));
    printf("val 5: %d\n", val_unwrap_bool(valFive));
    printf("val 6: %d\n", val_unwrap_int(valSix));
    return val_wrap_void();
}

int64_t returnSevenArgs(int64_t valOne, int64_t valTwo, int64_t valThree,
                        int64_t valFour, int64_t valFive, int64_t valSix,
                        int64_t valSeven) {
    printf("val 1: %d\n", val_unwrap_int(valOne));
    printf("val 2: %d\n", val_unwrap_bool(valTwo));
    printf("val 3: %c\n", val_unwrap_char(valThree));
    printf("val 4: %c\n", val_unwrap_char(valFour));
    printf("val 5: %d\n", val_unwrap_bool(valFive));
    printf("val 6: %d\n", val_unwrap_int(valSix));
    printf("val 7: %d\n", val_unwrap_int(valSeven));
    return val_wrap_void();
}