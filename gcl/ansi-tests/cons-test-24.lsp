;-*- Mode:     Lisp -*-
;;;; Author:   Paul Dietz
;;;; Created:  Wed Apr  1 22:10:54 1998
;;;; Contains: Testing of CL Features related to "CONS", part 24

(in-package :cl-test)
(use-package :rt)
(declaim (optimize (safety 3)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; subsetp

(defvar cons-test-24-var '(78 "z" (8 9)))

(deftest subsetp-1
    (subsetp-with-check (copy-tree '(78)) cons-test-24-var)
  t)

(deftest subsetp-2
    (subsetp-with-check (copy-tree '((8 9))) cons-test-24-var)
  nil)

(deftest subsetp-3
    (subsetp-with-check (copy-tree '((8 9)))
			cons-test-24-var :test 'equal)
  t)

(deftest subsetp-4
    (subsetp-with-check (list 78 (copy-seq "Z")) cons-test-24-var
			:test #'equalp)
  t)

(deftest subsetp-5
    (subsetp-with-check (list 1) (list 0 2 3 4)
			:key #'(lambda (i) (floor (/ i 2))))
  t)

(deftest subsetp-6
    (subsetp-with-check (list 1 6) (list 0 2 3 4)
			:key #'(lambda (i) (floor (/ i 2))))
  nil)

(deftest subsetp-7
    (subsetp-with-check (list '(a . 10) '(b . 20) '(c . 30))
			(list '(z . c) '(a . y) '(b . 100) '(e . f)
			      '(c . foo))
			:key #'car)
  t)

(deftest subsetp-8
    (subsetp-with-check (copy-tree '((a . 10) (b . 20) (c . 30)))
			(copy-tree '((z . c) (a . y) (b . 100) (e . f)
			      (c . foo)))
			:key 'car)
  t)

(deftest subsetp-9
    (subsetp-with-check (list 'a 'b 'c)
			(copy-tree
			 (list '(z . c) '(a . y) '(b . 100) '(e . f)
			      '(c . foo)))
			:test #'(lambda (e1 e2)
				   (eqt e1 (car e2))))
  t)

(deftest subsetp-10
  (subsetp-with-check (list 'a 'b 'c)
		      (copy-tree
		       (list '(z . c) '(a . y) '(b . 100) '(e . f)
			     '(c . foo)))
		      :test #'(lambda (e1 e2)
				(eqt e1 (car e2)))
		      :key nil)
  t)

(deftest subsetp-11
    (subsetp-with-check (list 'a 'b 'c)
			(copy-tree
			 (list '(z . c) '(a . y) '(b . 100) '(e . f)
			       '(c . foo)))
			:test-not  #'(lambda (e1 e2)
				       (not (eqt e1 (car e2)))))
  t)

;; Check that it maintains order of arguments

(deftest subsetp-12
    (block fail
      (subsetp-with-check
       (list 1 2 3)
       (list 4 5 6)
       :test #'(lambda (x y)
		 (when (< y x) (return-from fail 'fail))
		 t)))
  t)

(deftest subsetp-13
    (block fail
      (subsetp-with-check
       (list 1 2 3)
       (list 4 5 6)
       :key #'identity
       :test #'(lambda (x y)
		 (when (< y x) (return-from fail 'fail))
		 t)))
  t)

(deftest subsetp-14
    (block fail
      (subsetp-with-check
       (list 1 2 3)
       (list 4 5 6)
       :test-not #'(lambda (x y)
		 (when (< y x) (return-from fail 'fail))
		 nil)))
  t)

(deftest subsetp-15
    (block fail
      (subsetp-with-check
       (list 1 2 3)
       (list 4 5 6)
       :key #'identity
       :test-not #'(lambda (x y)
		 (when (< y x) (return-from fail 'fail))
		 nil)))
  t)

(deftest subsetp-16
  (notnot (subsetp '(1 2 3 4) '(0 1 2 3 4 5) :bad t :allow-other-keys 67))
  t)

(deftest subsetp-17
  (notnot (subsetp '(1 2 3 4) '(0 1 2 3 4 5)
		   :allow-other-keys #'cons :bad t))
  t)

(deftest subsetp-18
  (notnot (subsetp '(1 2 3 4) '(0 1 2 3 4)
		   :allow-other-keys (make-hash-table)
		   :bad t
		   :test #'(lambda (x y) (= (1+ x) y))))
  nil)

(deftest subsetp.error.1
  (classify-error (subsetp))
  program-error)

(deftest subsetp.error.2
  (classify-error (subsetp nil))
  program-error)

(deftest subsetp.error.3
  (classify-error (subsetp nil nil :bad t))
  program-error)

(deftest subsetp.error.4
  (classify-error (subsetp nil nil :key))
  program-error)

(deftest subsetp.error.5
  (classify-error (subsetp nil nil 1 2))
  program-error)

(deftest subsetp.error.6
  (classify-error (subsetp nil nil :bad t :allow-other-keys nil))
  program-error)
