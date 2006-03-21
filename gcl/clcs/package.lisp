;;; -*- Mode: Lisp; Syntax: Common-Lisp; Package: ("CONDITIONS" :USE "LISP" :SHADOW ("BREAK" "ERROR" "CERROR" "WARN" "CHECK-TYPE" "ASSERT" "ETYPECASE" "CTYPECASE" "ECASE" "CCASE")); Base: 10 -*-
; From arisia.xerox.com:/cl/conditions/cond18.lisp
;;;
;;; CONDITIONS
;;;
;;; This is a sample implementation. It is not in any way intended as the definition
;;; of any aspect of the condition system. It is simply an existence proof that the
;;; condition system can be implemented.
;;;
;;; While this written to be "portable", this is not a portable condition system
;;; in that loading this file will not redefine your condition system. Loading this
;;; file will define a bunch of functions which work like a condition system. Redefining
;;; existing condition systems is beyond the goal of this implementation attempt.

(MAKE-PACKAGE "CONDITIONS" :USE '("LISP" #+lucid "LUCID-COMMON-LISP"))
(IN-PACKAGE "CONDITIONS" :USE '("LISP" #+lucid "LUCID-COMMON-LISP"))

#-(or lucid excl genera cmu )
(SHADOW '(BREAK ERROR CERROR WARN CHECK-TYPE ASSERT ETYPECASE
	  CTYPECASE ECASE CCASE))

#+gcl
(EXPORT '(;; Shadowed symbols
	    BREAK ERROR CERROR WARN CHECK-TYPE ASSERT ETYPECASE
	    CTYPECASE ECASE CCASE))
(EXPORT '(;; New symbols
	  *BREAK-ON-SIGNALS* *DEBUGGER-HOOK* SIGNAL
	  WITH-CONDITION-RESTARTS
	  HANDLER-CASE HANDLER-BIND IGNORE-ERRORS DEFINE-CONDITION MAKE-CONDITION
	  WITH-SIMPLE-RESTART RESTART-CASE RESTART-BIND RESTART-NAME
	  RESTART-NAME FIND-RESTART COMPUTE-RESTARTS INVOKE-RESTART
	  INVOKE-RESTART-INTERACTIVELY ABORT CONTINUE MUFFLE-WARNING
	  STORE-VALUE USE-VALUE INVOKE-DEBUGGER RESTART CONDITION
	  WARNING SERIOUS-CONDITION SIMPLE-CONDITION SIMPLE-WARNING SIMPLE-ERROR
	  SIMPLE-CONDITION-FORMAT-STRING SIMPLE-CONDITION-FORMAT-ARGUMENTS
	  STORAGE-CONDITION STACK-OVERFLOW STORAGE-EXHAUSTED TYPE-ERROR
	  TYPE-ERROR-DATUM TYPE-ERROR-EXPECTED-TYPE SIMPLE-TYPE-ERROR
	  PROGRAM-ERROR CONTROL-ERROR STREAM-ERROR STREAM-ERROR-STREAM
	  END-OF-FILE FILE-ERROR FILE-ERROR-PATHNAME CELL-ERROR
	  UNBOUND-VARIABLE UNDEFINED-FUNCTION ARITHMETIC-ERROR
	  ARITHMETIC-ERROR-OPERATION ARITHMETIC-ERROR-OPERANDS
	  PACKAGE-ERROR PACKAGE-ERROR-PACKAGE
	  DIVISION-BY-ZERO FLOATING-POINT-OVERFLOW FLOATING-POINT-UNDERFLOW))

(DEFVAR *THIS-PACKAGE* (FIND-PACKAGE "CONDITIONS"))


