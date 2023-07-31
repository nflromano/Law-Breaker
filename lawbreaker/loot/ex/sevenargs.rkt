#lang racket


;;Test with 7 arguments
(define (test-f2) 

        (ccall returnSevenArgs 1 #t #\s #\f #f -5 9))

(test-f2)
