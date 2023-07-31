#lang racket
(provide (all-defined-out))
(require racket/lazy-require "ast.rkt" "types.rkt" "lambdas.rkt" "fv.rkt" "compile-ops.rkt" a86/ast)
(lazy-require ["parse.rkt" (parse-e)])
(lazy-require ["compile.rkt" (compile-es)])
(lazy-require ["compile.rkt" (compile-e)])

;;Registers for System V Calling Convention Parameter Passing
(define rsi 'rsi)
(define rdx 'rdx)
(define rcx 'rcx)
(define r11 'r11)

(define (parse-ccall f elist)
    (CCall f (map parse-e elist)))

;; simplified ccall parser (no args)
#|(define (parse-ccall f elist)
    (CCall f '()))|#

;; lawbreaker ccall stuff
(define (get-ccall-externs ast)
    (match ast
        [(Prog ds e)        (remove-duplicates (append (flatten (map get-ccall-externs ds)) (get-ccall-externs e)))]
        [(Defn f xs e)      (get-ccall-externs e)]
        [(Prim1 p e)        (get-ccall-externs e)]
        [(Prim2 p e1 e2)    (append (get-ccall-externs e1) (get-ccall-externs e2))]
        [(Prim3 p e1 e2 e3) (append (get-ccall-externs e1) (get-ccall-externs e2) (get-ccall-externs e3))]
        [(If e1 e2 e3)      (append (get-ccall-externs e1) (get-ccall-externs e2) (get-ccall-externs e3))]
        [(Begin e1 e2)      (append (get-ccall-externs e1) (get-ccall-externs e2))]
        [(Let x e1 e2)      (append (get-ccall-externs e1) (get-ccall-externs e2))]
        [(App e es)         (append (get-ccall-externs e) (flatten (map get-ccall-externs es)))]
        [(Lam f xs e)       (get-ccall-externs e)]
        [(Match e ps es)    (append (get-ccall-externs e) (flatten (map get-ccall-externs es)))]
        [(CCall f es)       (cons f (flatten (map get-ccall-externs es)))]
        [_                  '()]))

(define (externs ast)
    (let ((extlist (remove-duplicates (append (list 'peek_byte 'read_byte 'write_byte 'raise_error) (get-ccall-externs ast)))))
    (externs-aux extlist)))

(define (externs-aux extlist)
  (match extlist
    ['() '()]
    [(cons ext rest)
     (seq (Extern ext)
          (externs-aux rest))]))

(define regList (list 'rdi 'rsi 'rdx 'rcx 'r8 'r9))

(define (get-first-regs es) (get-first-regs-aux es 0))

(define (get-first-regs-aux es count)
    (if (>= count (length regList))
        '()
        (match es 
            ['()            '()]
            [(cons e rest)  (cons e (get-first-regs-aux rest (+ count 1)))])))

(define (get-post-regs es) (get-post-regs-aux es 0))

(define (get-post-regs-aux es count)
    (if (>= count (length regList))
        es
        (match es 
            ['()            '()]
            [(cons e rest)  (get-post-regs-aux rest (+ count 1))])))

(define (compile-es-reg curCount es c)
    (match es
        ['()            (seq)]
        [(cons e rest)  (if (< curCount (length regList))
                            (seq (compile-e e c #f)
                                (Mov (list-ref regList curCount) 'rax)
                                (compile-es-reg (+ curCount 1) rest c))
                            (seq))]))

(define (compile-ccall f es env)
    (seq (compile-es-reg 0 (get-first-regs es) env)

         pad-stack
         ;;Put arguments not on registers onto the stack
         (compile-es (get-post-regs es) env)




         
         (Call f)
         (Add 'rsp (* 8 (length (get-post-regs es))))
         unpad-stack))














#|
(define (compile-ccall f es env)

    
    ;;Put all args in registers in order: %rdi, %rsi, %rdx, %rcx, %r8, %r9, and then start using stack

    ;;First put all arguments onto the stack
    (let ((loop (gensym 'loop)) (done (gensym 'done)) (arg2 (gensym 'arg2)) (arg3 (gensym 'arg3))
    (arg4 (gensym 'arg4)) (arg5 (gensym 'arg5)) (arg6 (gensym 'arg6)) (lstack (gensym 'lstack)) )

    (seq (compile-es es (cons #f env)) ;Push all arguments onto the stack
         
         ;Put number of arguments in r10
         (Mov r10 (length es))

         (Mov r11 1) ;Make r11 the counter for the loop starting at 1. Value of counter represents 
                     ;Which argument currently on

        ;; SKIP LOOP IF NO VARS
        (Cmp r10 0)
        (Je done)

         (Label loop)

         (Cmp r11 r10) ;Compare the counter and the length of es

         (Je done) ;If the counter = the number of args, then finished. No need to put stuff on stack
                   ;Jump to done label
        
         (Cmp r11 7) ;Compare the counter to 7 (# registers + 1)

         (Je lstack) ;If r11 == 7, Jump to label for puting args on stack since out of registers

         ;;;;;;;;;;;;;;;;;;;;;;;;;;;; Register rdi

         (Cmp r11 1) ;Check if on arg1

         (Jne arg2) ;If not arg1, jump to next conditional for arg2

         (Mov rdi (Offset rsp (* 8 (length es)))) ;Move first arg pushed on stack into rdi

         (Add r10 1) ;Increment counter

         (Jmp loop) ;Go back to loop

         ;;;;;;;;;;;;;;;;;;;;;;;;;;;; Register rsi

         (Label arg2)

         (Cmp r11 2) ;Check if on arg2

         (Jne arg3) ;If not arg2 argument, jump to next conditional for arg3

         (Mov rsi (Offset rsp (* 8 (- (length es) 1)))) ;Move the second arg pushed on stack into rdi

         (Add r10 1) ;Increment counter

         (Jmp loop) ;Go back to loop

         ;;;;;;;;;;;;;;;;;;;;;;;;;;;; Register rdx

         (Label arg3)

         (Cmp r11 3) ;Check if on arg3

         (Jne arg4) ;If not arg3 argument, jump to next conditional for arg4

         (Mov rdx (Offset rsp (* 8 (- (length es) 2)))) ;Move the third arg pushed on stack into rdx

         (Add r10 1) ;Increment counter

         (Jmp loop) ;Go back to loop

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;; Register rcx

         (Label arg4)

         (Cmp r11 4) ;Check if on arg4

         (Jne arg5) ;If not arg4 argument, jump to next conditional for arg5

         (Mov rcx (Offset rsp (* 8 (- (length es) 3)))) ;Move the fourth arg pushed on stack into rcx

         (Add r10 1) ;Increment counter

         (Jmp loop) ;Go back to loop

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;; Register r8

         (Label arg5)

         (Cmp r11 5) ;Check if on arg5

         (Jne arg6) ;If not arg5 argument, jump to next conditional for arg6

         (Mov r8 (Offset rsp (* 8 (- (length es) 4)))) ;Move the fifth arg pushed on stack into r8

         (Add r10 1) ;Increment counter

         (Jmp loop) ;Go back to loop

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;; Register r9

         (Label arg6)

         (Mov r9 (Offset rsp (* 8 (- (length es) 5)))) ;Move the fifth arg pushed on stack into r9

         (Add r10 1) ;Increment counter

         ;; Will check at top of loop if counter = length of args + 1
         ;to see if we jump to done. Will check at top of loop if counter > #registers and will
         ;jump to stack label if needed to move rest of arguments onto the stack.

         (Jmp loop) ;Go back to loop

         ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
         
         (Label lstack)

         ;;Do stack stuff here


         (Label done)

        
         pad-stack
         
         (Call f)

         unpad-stack)))|#