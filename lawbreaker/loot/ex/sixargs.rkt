#lang racket


;;Test with no arguments
(define (test-f1) 

        (ccall returnSixArgs 1 #t #\s #\f #f -5))

(test-f1)
