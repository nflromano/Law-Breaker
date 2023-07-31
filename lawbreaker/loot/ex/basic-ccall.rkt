#lang racket
(define (test a b) (let ((x (ccall add 3 2))) (ccall sqrt x)))
(define (test2) (ccall help))
((let ((x 1)) 
      (let ((y 2))
           (lambda (z) 
                   (begin (test x z) (test2)))))
            (ccall add 1 2))


#| (parse (list '(define (test a b) (let ((x (ccall add 3 2))) (ccall sqrt x))) '(define (test2) (ccall help)) '((let ((x 1)) 
        (let ((y 2))
             (lambda (z) 
                     (begin (test x z) (test2)))))
              (ccall add 1 2)))) |#