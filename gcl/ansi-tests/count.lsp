;-*- Mode:     Lisp -*-
;;;; Author:   Paul Dietz
;;;; Created:  Mon Aug 19 07:31:55 2002
;;;; Contains: Tests for COUNT

(in-package :cl-test)

(deftest count-list.1
  (count 'a '(a b c d e a e f))
  2)

(deftest count-list.2
  (count 'a '(a b c d e a e f) :test #'eq)
  2)

(deftest count-list.3
  (count 'a '(a b c d e a e f) :test 'eq)
  2)

(deftest count-list.4
  (count 1 '(1 2 2 3 2 1 2 2 5 4) :key #'1-)
  5)

(deftest count-list.5
  (count 1 '(1 2 2 3 2 1 2 2 5 4) :key '1-)
  5)

(deftest count-list.6
  (count 1 '(1 2 2 3 2 1 2 2 5 4) :key #'1- :test #'equal)
  5)

(deftest count-list.7
  (count 1 '(2 1 1 2 3 1 4 1 7 6 1 8) :from-end t)
  5)

(deftest count-list.8
  (let ((c 0))
    (count 1 '(1 2 3 1 4 1 7 6 1 8)
	   :key #'(lambda (x)
		    ;; (format t "~%~A ~A" x c)
		    (prog1 (- x c) (incf c)))))
  4)

(deftest count-list.9
  (let ((c 0))
    (count 1 '(1 2 3 7 4 5 7 6 2 8)
	   :from-end t
	   :key #'(lambda (x)
		    ;; (format t "~%~A ~A" x c)
		    (prog1 (- x c) (incf c)))))
  3)

(deftest count-list.10
  (count 1 '(1 1 1 1 1 2 1 1) :start 3)
  4)

(deftest count-list.11
  (count 1 '(1 1 1 1 1 2 1 1) :end 6)
  5)

(deftest count-list.12
  (count 1 '(1 1 1 1 1 2 1 1) :start 2 :end 7)
  4)

(deftest count-list.13
  (count 1 '(1 1 1 1 1 2 1 1) :start 3 :end nil)
  4)

(deftest count-list.14
  (count 1 '(1 1 1 1 1 2 1 1)  :end nil)
  7)

(deftest count-list.15
  (count 1 '(1 1 1 1 1 2 1 1)  :test-not #'eq)
  1)

(deftest count-list.16
  (count 1 '(1 1 1 3 1 2 1 1) :start 2 :end 7
	 :test #'(lambda (x y) t))
  5)

;;; On vectors

(deftest count-vector.1
  (count 'a #(a b c d e a e f))
  2)

(deftest count-vector.2
  (count 'a #(a b c d e a e f) :test #'eq)
  2)

(deftest count-vector.3
  (count 'a #(a b c d e a e f) :test 'eq)
  2)

(deftest count-vector.4
  (count 1 #(1 2 2 3 2 1 2 2 5 4) :key #'1-)
  5)

(deftest count-vector.5
  (count 1 #(1 2 2 3 2 1 2 2 5 4) :key '1-)
  5)

(deftest count-vector.6
  (count 1 #(1 2 2 3 2 1 2 2 5 4) :key #'1- :test #'equal)
  5)

(deftest count-vector.7
  (count 1 #(2 1 1 2 3 1 4 1 7 6 1 8) :from-end t)
  5)

(deftest count-vector.8
  (let ((c 0))
    (count 1 #(1 2 3 1 4 1 7 6 1 8)
	   :key #'(lambda (x)
		    ;; (format t "~%~A ~A" x c)
		    (prog1 (- x c) (incf c)))))
  4)

(deftest count-vector.9
  (let ((c 0))
    (count 1 #(1 2 3 7 4 5 7 6 2 8)
	   :from-end t
	   :key #'(lambda (x)
		    ;; (format t "~%~A ~A" x c)
		    (prog1 (- x c) (incf c)))))
  3)

(deftest count-vector.10
  (count 1 #(1 1 1 1 1 2 1 1) :start 3)
  4)

(deftest count-vector.11
  (count 1 #(1 1 1 1 1 2 1 1) :end 6)
  5)

(deftest count-vector.12
  (count 1 #(1 1 1 1 1 2 1 1) :start 2 :end 7)
  4)

(deftest count-vector.13
  (count 1 #(1 1 1 1 1 2 1 1) :start 3 :end nil)
  4)

(deftest count-vector.14
  (count 1 #(1 1 1 1 1 2 1 1)  :end nil)
  7)

(deftest count-vector.15
  (count 1 #(1 1 1 1 1 2 1 1)  :test-not #'eq)
  1)

(deftest count-vector16
  (count 1 #(1 1 1 3 1 2 1 1) :start 2 :end 7
	 :test #'(lambda (x y) t))
  5)

;;; Non-simple vectors

(deftest count-filled-vector.1
  (count 'a (make-array 8 :initial-contents '(a b c d e a e f)
			:fill-pointer t))
  2)

(deftest count-filled-vector.2
  (count 'a (make-array 8 :initial-contents '(a b c d e a e f)
			:fill-pointer t)
	 :test #'eq)
  2)

(deftest count-filled-vector.3
  (count 'a (make-array 8 :initial-contents '(a b c d e a e f)
			:fill-pointer t)
	 :test 'eq)
  2)

(deftest count-filled-vector.4
  (count 1 (make-array 10 :initial-contents '(1 2 2 3 2 1 2 2 5 4)
		       :fill-pointer t)
	 :key #'1-)
  5)

(deftest count-filled-vector.5
  (count 1 (make-array 10 :initial-contents '(1 2 2 3 2 1 2 2 5 4)
		       :fill-pointer t)
	 :key '1-)
  5)

(deftest count-filled-vector.6
  (count 1 (make-array 10 :initial-contents '(1 2 2 3 2 1 2 2 5 4)
		       :fill-pointer t)
	 :key #'1- :test #'equal)
  5)

(deftest count-filled-vector.7
  (count 1 (make-array 12 :initial-contents '(2 1 1 2 3 1 4 1 7 6 1 8)
		       :fill-pointer t)
	 :from-end t)
  5)

(deftest count-filled-vector.8
  (let ((c 0))
    (count 1 (make-array 10 :initial-contents '(1 2 3 1 4 1 7 6 1 8)
			 :fill-pointer t)
	   :key #'(lambda (x)
		    ;; (format t "~%~A ~A" x c)
		    (prog1 (- x c) (incf c)))))
  4)

(deftest count-filled-vector.9
  (let ((c 0))
    (count 1 (make-array 10 :initial-contents '(1 2 3 7 4 5 7 6 2 8)
			 :fill-pointer t)
	   :from-end t
	   :key #'(lambda (x)
		    ;; (format t "~%~A ~A" x c)
		    (prog1 (- x c) (incf c)))))
  3)

(deftest count-filled-vector.10
  (count 1 (make-array 8 :initial-contents '(1 1 1 1 1 2 1 1)
		       :fill-pointer t)
	 :start 3)
  4)

(deftest count-filled-vector.11
  (count 1 (make-array 8 :initial-contents '(1 1 1 1 1 2 1 1)
		       :fill-pointer t)
	 :end 6)
  5)

(deftest count-filled-vector.12
  (count 1 (make-array 8 :initial-contents '(1 1 1 1 1 2 1 1)
		       :fill-pointer t)
	 :start 2 :end 7)
  4)

(deftest count-filled-vector.13
  (count 1 (make-array 8 :initial-contents '(1 1 1 1 1 2 1 1)
		       :fill-pointer t)
	 :start 3 :end nil)
  4)

(deftest count-filled-vector.14
  (count 1 (make-array 8 :initial-contents '(1 1 1 1 1 2 1 1)
		       :fill-pointer t)
	 :end nil)
  7)

(deftest count-filled-vector.15
  (count 1 (make-array 8 :initial-contents '(1 1 1 1 1 2 1 1)
		       :fill-pointer t)
	 :test-not #'eq)
  1)

(deftest count-filled-vector.16
  (count 1 (make-array 8 :initial-contents '(1 1 1 3 1 2 1 1)
		       :fill-pointer t)
	 :start 2 :end 7
	 :test #'(lambda (x y) t))
  5)

;;; Tests on bit vectors

(deftest count-bit-vector.1
  (count 1 #*00101100011011000)
  7)

(deftest count-bit-vector.2
  (count 1 #*00101100011011000 :test #'eq)
  7)

(deftest count-bit-vector.3
  (count 1 #*00101100011011000 :test 'eq)
  7)

(deftest count-bit-vector.4
  (count 1 #*00101100011011000 :key #'1+)
  10)

(deftest count-bit-vector.5
  (count 0 #*00101100011011000 :key '1-)
  7)

(deftest count-bit-vector.6
  (count 0 #*00101100011011000 :key #'1- :test #'equal)
  7)

(deftest count-bit-vector.7
  (count 1 #*00101100011011000 :from-end t)
  7)

(deftest count-bit-vector.8
  (let ((c 1))
    (count 0 #*0000110101001
	   :key #'(lambda (x) (setf c (- c)) (+ c x))))
  2)

(deftest count-bit-vector.9
  (let ((c 1))
    (count 0 #*0000011010101
	   :from-end t
	   :key #'(lambda (x) (setf c (- c)) (+ c x))))
  4)

(deftest count-bit-vector.10
  (count 1 #*11000110110 :start 3)
  4)

(deftest count-bit-vector.11
  (count 1 '#*110111110111 :end 6)
  5)

(deftest count-bit-vector.12
  (count 1 #*11111011 :start 2 :end 7)
  4)

(deftest count-bit-vector.13
  (count 1 #*11111011 :start 3 :end nil)
  4)

(deftest count-bit-vector.14
  (count 1 #*11111011 :end nil)
  7)

(deftest count-bit-vector.15
  (count 1 #*11111011  :test-not #'eq)
  1)

(deftest count-bit-vector.16
  (count 1 #*11101101 :start 2 :end 7
	 :test #'(lambda (x y) t))
  5)

;;; Tests on strings

(deftest count-string.1
  (count #\1 "00101100011011000")
  7)

(deftest count-string.2
  (count #\1 "00101100011011000" :test #'eq)
  7)

(deftest count-string.3
  (count #\1 "00101100011011000" :test 'eq)
  7)

(deftest count-string.4
  (count #\1 "00101100011011000" :key #'(lambda (x) (if (eql x #\0) #\1 #\2)))
  10)

(deftest count-string.5
  (count #\1 "00101100011011000" :key 'identity)
  7)

(deftest count-string.6
  (count #\1 "00101100011011000" :key #'identity :test #'equal)
  7)

(deftest count-string.7
  (count #\1 "00101100011011000" :from-end t)
  7)

(deftest count-string.8
  (let ((c nil))
    (count #\0 "0000110101001"
	   :key #'(lambda (x) (setf c (not c))
		    (and c x))))
  5)

(deftest count-string.9
  (let ((c nil))
    (count #\0 "0000011010101"
	   :from-end t
	   :key #'(lambda (x) (setf c (not c))
		    (and c x))))
  3)

(deftest count-string.10
  (count #\1 "11000110110" :start 3)
  4)

(deftest count-string.11
  (count #\1 '"110111110111" :end 6)
  5)

(deftest count-string.12
  (count #\1 "11111011" :start 2 :end 7)
  4)

(deftest count-string.13
  (count #\1 "11111011" :start 3 :end nil)
  4)

(deftest count-string.14
  (count #\1 "11111011" :end nil)
  7)

(deftest count-string.15
  (count #\1 "11111011"  :test-not #'eq)
  1)

(deftest count-string.16
  (count #\1 "11101101" :start 2 :end 7
	 :test #'(lambda (x y) t))
  5)

;;; Error tests

(deftest count-error.1
  (catch-type-error (count 'a 1))
  type-error)

(deftest count-error.2
  (catch-type-error (count 'a 'a))
  type-error)

(deftest count-error.3
  (catch-type-error (count 'a #\a))
  type-error)

