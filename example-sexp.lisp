;;;; Esrap example: a simple S-expression grammar

(require :esrap)

(defpackage :sexp-grammar
  (:use :cl :esrap))

(in-package :sexp-grammar)

;;; A couple of semantic predicates.

(defun whitespacep (char)
  (member char '(#\space #\tab #\newline)))

(defun not-doublequote (char)
  (not (eql #\" char)))

;;; Utility rules.

(defrule whitespace (whitespacep character)
  (:constant nil))

(defrule alpha (alphanumericp character))

(defrule string-char (or (not-doublequote character) (and #\\ #\")))

(defrule whitespace* (* whitespace)
  (:constant nil))

(defrule whitespace+ (+ whitespace)
  (:constant nil))

;;; Here we go: an S-expression is either a list or an atom, with possibly leading whitespace.

(defrule sexp (and whitespace* (or list atom))
  (:destructure (w s)
     (declare (ignore w))
     s))

(defrule list (and #\( sexp (* sexp) whitespace* #\))
  (:destructure (p1 car cdr w p2)
    (declare (ignore p1 p2 w))
    (cons car cdr)))

(defrule atom (or string integer symbol))

(defrule string (and #\" (* string-char) #\")
  (:destructure (q1 string q2)
    (declare (ignore q1 q2))
    (concat string)))

(defrule integer (+ (or "0" "1" "2" "3" "4" "5" "6" "7" "8" "9"))
  (:lambda (list)
    (parse-integer (concat list) :radix 10)))

(defrule symbol (+ alpha)
  (:lambda (list)
    (intern (concat list))))

;;;; Try these

(parse 'sexp "FOO123")

(parse 'sexp "123")

(parse 'sexp "\"foo\"")

(parse 'sexp "  (  1 2  3 (FOO\"foo\"123 )   )")

(describe-grammar 'sexp)