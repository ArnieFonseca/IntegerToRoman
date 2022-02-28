#lang racket

;; Integer to Roman Number Mapping Table
(define mapping-table (list 
                       (list 1 "I") (list 5 "V")  
                       (list 10 "X") (list 50 "L")  
                       (list 100 "C") (list 500 "D") 
                       (list 1000 "M") (list 5000 "V\u0305")
                       (list 10000 "X\u0305") (list 50000 "L\u0305")
                       (list 100000 "C\u0305") (list 500000 "D\u0305")
                       (list 1000000 "M\u0305")))
 
;; Split a given integer into its corresponding decimal parts
;; e.g.; give 574 -> 500 | give 74 -> 70 | given 4 -> 4
(define get-processing-number
  (λ (n)
    (let
        ([p (expt 10 (floor(log n 10 )))])
      (exact-floor (* (floor (/ n p)) p)))))

;; Get the Upper Bound of the Processing number
;; the next number greater or eaqual in the Mapping Table
(define get-upper-bound
  (λ (n)
    (first (filter (λ (x) (>= (first x) n)) mapping-table))))

;; Get the Lower Bound of the Processing number
;; the next number less or equal in the Mapping Table
(define get-lower-bound
  (λ (n)
    (first (reverse (filter (λ (x) (<= (first x) n)) mapping-table)))))

;; Get the lower bound of the lower bound
;; e.g.; give 90 it lower bound 50 and it previous is 10 
(define get-prev-lower-bound
  (λ (n)
    (first (reverse (filter (λ (x) (< (first x) n)) mapping-table))))) 

;; Get the exact Roman Number from an integer
(define get-exact-roman-number
  (λ (n)    
    ; Local inner function to fetch an entry from mapping table
    ; ------------------------
    (define aux
      (λ (n)
        (filter (λ (x)
                  (= n (car x))) mapping-table)))        
  
    ; Lambda body
    ; ------------------------
    (let  ([rst (aux n)])     ; Local variable rst housing aux output
      (if (empty? rst)        ; Return null when empty
          null 
          (second (car rst)))))) ; Return the Romman Number

;; Helper function to repeat a character
(define repeat
  (λ (n s)
    (string-append* (make-list (exact-floor n) s))))  

;; Convert an Integer to a Roman Number
(define get-roman-number
  (λ (process-number)
    (let*            ; Local Identifiers definition
        ([FIVE 5]
         [THOUSAN 1000]
         [ROMAN-THOUSAN "I\u0305"]

         [upper-bound (get-upper-bound process-number)]
         [lower-bound (get-lower-bound process-number)]
         [prev-lower-bound (get-prev-lower-bound (if (< process-number FIVE)
                                                     (car(get-lower-bound FIVE))
                                                     (car(get-lower-bound process-number))))]
         [diff (- (first upper-bound) process-number)]
         [diff-roman-number (if (= diff THOUSAN) ROMAN-THOUSAN (get-exact-roman-number diff))]
               
         [upper-diff (/ (- process-number (first lower-bound))  (first lower-bound))]
         [lower-diff (/ (- process-number (first lower-bound))  (first prev-lower-bound))]
               
         [next-rst (cond
                     ; Case 1) When exact match e.g.; 1,5,10,50 ... I, V, X, L 
                     [(= (first lower-bound) process-number)
                      (string-append  (second lower-bound))]

                     ; Case 2) When difference between the upper bound and processing number
                     ; exists in conversion table case for 4, 9, 90, 400 ... IV, IX, XC, CD
                     ; Thousan exception accounted in the identifier
                     [(string? diff-roman-number)
                      (string-append  diff-roman-number (second upper-bound) )]

                     ; Case 3) When processing number is less that the difference
                     ; between the upper bound and lower bound
                     ; 
                     [(< process-number (- (first upper-bound) (first lower-bound)) )
                      (string-append (second lower-bound)(repeat upper-diff (second lower-bound)))]
                          
                     ; Case 4) When processing number is greater that the difference
                     ; between the upper bound and lower bound
                     ;
                     [else
                      (string-append (second lower-bound)(repeat lower-diff (second prev-lower-bound)))]
                     )]
         )
               
      ; Return Roman Number
      next-rst)))  

;; Convert an Integer to a Roman Number
(define int->roman
  (λ (n)
    ;; Helper to convert to allow tail recurse calls 
    (define int->roman-helper
      (λ (num rst)
        (if (zero? num)
            rst                ; Returns converted Roman Number
            ; Call recursively
            (int->roman-helper (- num (get-processing-number num))
                               (string-append rst (get-roman-number (get-processing-number num)))))))
    (let
        ([EMPTY-STRING ""])
    ;; Call helperr function
    (int->roman-helper n EMPTY-STRING))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Execution starts
(for  ([number (list 1 2 3 4 5 9 10 25 26 27 66 77 88)])
  (displayln (format "~a -> ~a" number (int->roman number)))) 

