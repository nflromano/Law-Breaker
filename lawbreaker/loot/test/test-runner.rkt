#lang racket
(provide test-runner test-runner-io)
(require rackunit)

(define (test-runner run)
    ;; nested ccalls w/ no-argument function
    (check-equal? (run
                 '(define (test a b) (let ((x (ccall add 3 2))) (ccall sqrt x)))
                 '(define (test2) (ccall help))
                 '((let ((x 1)) 
                    (let ((y 2))
                        (lambda (z) 
                                (begin (test x z) (test2)))))
                            (ccall add 1 2))
            )
                5)

    ;; nested ccalls w/ arguments
    (check-equal? (run
                 '(define (test a b) (let ((x (ccall add 3 2))) (ccall sqrt x)))
                 '(define (test2) (ccall help))
                 '((let ((x 1)) 
                    (let ((y 2))
                        (lambda (z) 
                                (test x z))))
                            (ccall add 1 2))
            )
                4)

    ;; testing bool return
    (check-equal? (run
                 '(define (test-f1) (ccall return_bool))
                 '(test-f1)
            )
                #f)

    ;; testing int return
    (check-equal? (run
                 '(define (test-f1) (ccall return_int))
                 '(test-f1)
            )
                251)

    ;; testing char return
    (check-equal? (run
                 '(define (test-f1) (ccall return_char))
                 '(test-f1)
            )
                #\g)

    ;; testing void return
    (check-equal? (run
                 '(define (test-f1) (ccall return_void))
                 '(test-f1)
            )
                (void))
)

(define (test-runner-io run)
    ;; using existing c func from older compilers
    (check-equal? (run "a"
                 '(define (test-f1) (ccall read_byte))
                 '(test-f1)
            )
                (cons 97 ""))
)
