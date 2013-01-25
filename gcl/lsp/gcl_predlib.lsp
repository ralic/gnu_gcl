;; -*-Lisp-*-
;; Copyright (C) 1994 M. Hagiya, W. Schelter, T. Yuasa

;; This file is part of GNU Common Lisp, herein referred to as GCL
;;
;; GCL is free software; you can redistribute it and/or modify it under
;;  the terms of the GNU LIBRARY GENERAL PUBLIC LICENSE as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.
;; 
;; GCL is distributed in the hope that it will be useful, but WITHOUT
;; ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
;; FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Library General Public 
;; License for more details.
;; 
;; You should have received a copy of the GNU Library General Public License 
;; along with GCL; see the file COPYING.  If not, write to the Free Software
;; Foundation, 675 Mass Ave, Cambridge, MA 02139, USA.


;;;;    predlib.lsp
;;;;
;;;;                              predicate routines

(in-package :system)

(export '(int void static 
;	      old-compiled-function 
	      non-generic-compiled-function
	      non-logical-pathname
	      non-standard-base-char
	      std-structure
	      hash-table-eq hash-table-eql hash-table-equal hash-table-equalp
	      +type-alist+ 
	      sequencep ratiop short-float-p long-float-p
	      eql-is-eq equal-is-eq equalp-is-eq eql-is-eq-tp equal-is-eq-tp equalp-is-eq-tp
	      +array-types+
	      +aet-type-object+ 
	      returns-exactly
	      immfix
	      file-input-stream file-output-stream file-io-stream file-probe-stream
	      string-input-stream string-output-stream
	      proper-sequence proper-sequencep proper-cons proper-consp
	      fcomplex dcomplex 
	      cnum-type
	      subtypep1 ;FIXME
	      resolve-type))

;(defconstant +array-types+ (si::aelttype-list))

;; (export '(lisp::upgraded-complex-part-type lisp::type-of
;; 	  lisp::deftype lisp::typep lisp::subtypep 
;; 	  lisp::coerce lisp::upgraded-array-element-type) 'lisp)

;;Exported functions need to be compiled with some safety to ensure
;;that user-supplied arguments are checked.  They should therefore
;;primarily be wrappers around computationally intensive internal
;;functions compiled with more aggressive settings. 20050718 CM

(defun ratiop (x)
  (and (rationalp x) (not (integerp x))))

(defun in-interval-p (x interval)
  (let ((low '*) (high '*))
    (when interval
      (check-type  interval cons)
      (or (eq (car interval) '*)
	  (check-type (car interval) (or (cons real null) real)))
      (setq low (car interval))
      (when (cdr interval)
	(check-type (cdr interval) cons)
	(or (eq (cadr interval) '*)
	    (check-type  (cadr interval) (or (cons real null) real)))
	(setq high (cadr interval))))
    (if (not interval)
        (setq low '* high '*)
        (if (not (cdr interval))
            (setq low (car interval) high '*)
            (setq low (car interval) high (cadr interval))))
    (cond ((eq low '*))
          ((consp low)
           (when (<= x (car low)) (return-from in-interval-p nil)))
          ((when (< x low) (return-from in-interval-p nil))))
    (cond ((eq high '*))
          ((consp high)
           (when (>= x (car high)) (return-from in-interval-p nil)))
          ((when (> x high) (return-from in-interval-p nil))))
    (return-from in-interval-p t)))

(defun match-dimensions (dim pat)
  (cond ((null dim)
	 (null pat))
	((integerp dim)
	 (eql dim pat))
	((integerp pat)
	 (eql (length dim) pat))
	(t 
	 (and (or (eq (car pat) '*)
		  (eql (car dim) (car pat)))
	      (match-dimensions (cdr dim) (cdr pat))))))


(defun upgraded-complex-part-type (type &optional environment) 
  (declare (ignore environment) (optimize (safety 2)))
  type)

(defmacro check-type-eval (place type)
  `(values (assert (typep ,place ,type) (,place) 'type-error :datum ,place :expected-type ,type)));fixme

(defun function-identifierp (tp)
  (or (symbolp tp)
      (and (consp tp) (eq (car tp) 'lambda))
      (and (consp tp)
	   (eq (car tp) 'setf)
	   (consp (cdr tp))
	   (symbolp (cadr tp))
	   (not (cddr tp)))))

;;; COERCE function.
;(defconstant +coerce-list+ '(list vector string array character short-float
;				  long-float float complex function null cons))

(defun coerce (object type &aux ntype (atp (listp type)) (ctp (if atp (car type) type)) (tp (when atp (cdr type))))
  (declare (optimize (safety 2)))
  (check-type type type-spec)
  (case ctp
	(function
	 (let ((object object))
	   (check-type object (or function (and symbol (not boolean)) (cons (member lambda) t)))
	   (typecase
	    object
	    (function object) 
	    ((and symbol (not boolean)) 
	     (let* ((f (c-symbol-gfdef object))(fi (address f))(m (c-symbol-mflag object)))
	       (check-type fi (and fixnum (not (integer 0 0))))
	       (check-type m  (integer 0 0))
	       f))
	    (cons (the function (eval object))))))
	((list cons vector array member) (if (typep object type) object (replace (make-sequence type (length object)) object)))
	(character (character object))
	(short-float (float object 0.0S0))
	(long-float (float object 0.0L0))
	(float (float object))
	(complex (if (typep object type) object
	 (let ((rtp (or (car tp) t)))
	   (complex (coerce (realpart object) rtp) (coerce (imagpart object) rtp)))))
	(otherwise 
	 (cond ((typep object type) object)
	       ((setq ntype (expand-deftype type)) (coerce object ntype))
	       ((check-type-eval object type))))))

;; (defun coerce (object type &aux ntype (atp (listp type)) (ctp (if atp (car type) type)) (tp (when atp (cdr type))))
;;   (declare (optimize (safety 2)))
;;   (check-type type type-spec)
;;   (when (typep object type)
;;     (return-from coerce object))
;;   (case ctp
;; 	(function (if (symbolp object) (symbol-function object) (values (eval `(function ,object)))));FIXME
;; 	((list cons vector array member) (replace (make-sequence type (length object)) object))
;; 	(character (character object))
;; 	(short-float (float object 0.0S0))
;; 	(long-float (float object 0.0L0))
;; 	(float (float object))
;; 	(complex
;; 	 (let ((rtp (or (car tp) t)))
;; 	   (complex (coerce (realpart object) rtp) (coerce (imagpart object) rtp))))
;; 	(otherwise 
;; 	 (cond ((setq ntype (expand-deftype type)) (coerce object ntype))
;; 	       ((check-type-eval object type))))))

;; (defun coerce (object type &aux ntype (atp (listp type)) (ctp (if atp (car type) type)) (tp (when atp (cdr type))))
;;   (declare (optimize (safety 2)))
;;   (check-type type type-spec)
;;   (when (typep object type)
;;     (return-from coerce object))
;;   (case ctp
;; 	(function (if (symbolp object) (symbol-function object) (values (eval `(function ,object)))));FIXME
;; 	((list cons vector array member) (replace (make-sequence type (length object)) object))
;; 	(character (character object))
;; 	(short-float (float object 0.0S0))
;; 	(long-float (float object 0.0L0))
;; 	(float (float object))
;; 	(complex
;; 	 (let ((rtp (or (car tp) t)))
;; 	   (complex (coerce (realpart object) rtp) (coerce (imagpart object) rtp))))
;; 	(otherwise 
;; 	 (cond ((si-classp ctp) (coerce object (si-class-name ctp)))
;; 	       ((let ((tem (get ctp 'deftype-definition)))
;; 		  (when tem
;; 		    (setq ntype (apply tem tp))
;; 		    (not (eq ctp (if (listp ntype) (car ntype) ntype)))))
;; 		(coerce object ntype))
;; 	       ((check-type-eval object type))))))

;; (defun coerce (object type)
;;   (declare (optimize (safety 2)))
;;   (check-type type (and (not null) type-spec))
;;   (when (typep object type)
;;     (return-from coerce object))
;;   (let ((tp (or (car (member (if (atom type) type (car type)) +coerce-list+))
;; 		(car (member type +coerce-list+ :test 'subtypep1)))))
;;     (case tp
;;       (function
;;        (coerce 
;; 	(cond ((let ((object (funid-sym-p object))) 
;; 		 (when object 
;; 		   (cond ((fboundp object) (symbol-function object)) ((check-type-eval object type))))))
;; 	      ((and (consp object) (eq (car object) 'lambda)) (values (eval `(function ,object))))
;; 	      ((check-type-eval object type)))
;; 	type))
;;        ((null cons list)
;;        (let* ((l (length object))
;; 	      (x (sequence-type-length-type type)))
;; 	 (when x (check-type l x))
;; 	 (do ((ll nil (cons (aref object i) ll))
;; 	      (i (1- l) (1- i)))
;; 	     ((< i 0) ll))))
;;       ((vector string array)
;;        (let* ((l (length object))
;; 	      (x (sequence-type-length-type type))
;; 	      (v (typep object 'list)))
;; 	 (when x (check-type-eval l x))
;; 	 (do ((seq (make-sequence type l))
;; 	      (i 0 (1+ i))
;; 	      (p (and v object) (and p (cdr p))))
;; 	     ((>= i l) seq)
;; 	  (setf (aref seq i) (if p (car p) (aref object i))))));;FIXME
;;       (character (character object))
;;       (short-float (float object 0.0S0))
;;       (long-float (float object 0.0L0))
;;       (float (float object))
;;       (complex
;;        (if (or (atom type) (null (cdr type)) (null (cadr type)) (eq (cadr type) '*))
;; 	   (complex (realpart object) (imagpart object))
;; 	 (complex (coerce (realpart object) (cadr type))
;; 		  (coerce (imagpart object) (cadr type)))))
;;       (otherwise (check-type-eval object type)))))
;(putprop 'coerce t 'compiler::cmp-notinline);FIXME


(defun maybe-clear-tp (sym)
  (let* ((p (find-package "COMPILER")) (s (and p (find-symbol "*NORM-TP-HASH*" p))))
    (when (and s (boundp s)) (remhash sym (symbol-value s)))))

(defun satisfies-predicate (form)
  (cond ((atom form) nil)
	((consp (car form)) (when (null (cdr form)) (satisfies-predicate (car form))))
	((eq (car form) 'quote) (satisfies-predicate (cadr form)))
	((eq (car form) 'satisfies) (cadr form))))
	

;;; DEFTYPE macro.
(defmacro deftype (name lambda-list &rest body &aux decls)
  ;; Replace undefaultized optional parameter X by (X '*).
  (declare (optimize (safety 2)))
  (do ((b body body)) ((or (not b) (not (consp (car b))) (not (eq 'declare (caar b)))) (nreverse decls))
      (let ((d (pop body)))
	(unless (member-if (lambda (x) (and (consp x) (eq (car x) 'special))) (cdr d)) ;FIXME
	  (push d decls))))
  (do ((l lambda-list (cdr l))
       (m nil (cons (car l) m)))
      ((null l))
      (when (member (car l) lambda-list-keywords)
	(unless (member (car l) '(&optional &key)) (return nil))
	(setq m (cons (car l) m))
	(setq l (cdr l))
	(do ()
	    ((or (null l) (member (car l) lambda-list-keywords)))
	    (if (symbolp (car l))
		(setq m (cons (list (car l) ''*) m))
	      (setq m (cons (car l) m)))
	    (setq l (cdr l)))
	(setq lambda-list (nreconc m l))
	(return nil)))
  (let ((fun-name (gensym (string name))))
    `(eval-when (compile eval load)
		(putprop ',name
			 '(deftype ,name ,lambda-list ,@body)
			 'deftype-form)
		(defun ,fun-name ,lambda-list ,@decls (block ,name ,@body))
		(putprop ',name ',fun-name 'deftype-definition)
		(maybe-clear-tp ',name)
		(putprop ',name
			 ,(find-documentation body)
			 'type-documentation)
		,@(let* ((r (unless lambda-list (eval (cons 'progn body))))
			 (p (satisfies-predicate r)))
		    (when p
		      `((putprop ',name ',p 'type-predicate)
			(putprop ',p ',name 'predicate-type))))
		',name)))

;;; Some DEFTYPE definitions.

(deftype function-designator nil `(or (and symbol (not boolean)) function))
(deftype extended-function-designator nil `(or function-designator (cons (member setf) (cons t null))))

(deftype hash-table nil `(or hash-table-eq hash-table-eql hash-table-equal hash-table-equalp))
(deftype compiler::funcallable-symbol nil `(satisfies compiler::funcallable-symbol-p));FIXME

(defconstant +ifb+ (- (car (last (multiple-value-list (si::heap-report))))))
(defconstant +ifr+ (ash (- +ifb+)  -1))
(defconstant +ift+ (when (> #.+ifr+ 0) '(integer #.(- +ifr+) #.(1- +ifr+))))

(deftype immfix () +ift+)
(deftype eql-is-eq-tp () `(or #.+ift+ (not number)))
(deftype equal-is-eq-tp () `(or #.+ift+ (not (or cons string bit-vector pathname number))))
(deftype equalp-is-eq-tp () `(not (or array hash-table structure cons string
				      bit-vector pathname number)))

;To pevent typep/predicate loops
(defun eql-is-eq (x) (typep x (funcall (get 'eql-is-eq-tp 'deftype-definition))))
(defun equal-is-eq (x) (typep x (funcall (get 'equal-is-eq-tp 'deftype-definition))))
(defun equalp-is-eq (x) (typep x (funcall (get 'equalp-is-eq-tp 'deftype-definition))))

(deftype seqind ()
  `(integer 0 ,array-dimension-limit))
(defun seqindp (x) (and (fixnump x) (>= x 0) (<= x array-dimension-limit)))
(si::putprop 'seqindp t 'compiler::cmp-inline)

(deftype rnkind ()
  `(integer 0 ,array-rank-limit))
(deftype bit () '(integer 0 1))
(deftype mod (n)
  `(integer 0 ,(1- n)))
(deftype non-negative-byte (&optional s)
  (if (eq s '*)
      `(integer 0 *)
      `(integer 0 ,(1- (expt 2 (1- s))))))
(deftype negative-byte (&optional s)
  (if (eq s '*)
      `(integer * -1)
      `(integer ,(- (expt 2 (1- s))) -1)))
(deftype signed-byte (&optional s)
  (if (eq s '*)
      `(integer * *)
      `(integer ,(- (expt 2 (1- s))) ,(1- (expt 2 (1- s))))))
(deftype unsigned-byte (&optional s)
  (if (eq s '*)
      `(integer 0 *)
      `(integer 0 ,(1- (expt 2 s)))))

(deftype non-negative-char () `(non-negative-byte ,char-length))
(deftype negative-char () `(negative-byte ,char-length))
(deftype signed-char ()`(signed-byte ,char-length))
(deftype unsigned-char ()`(unsigned-byte ,char-length))
(deftype char ()`(signed-char))

(deftype non-negative-short () `(non-negative-byte ,short-length))
(deftype negative-short () `(negative-byte ,short-length))
(deftype signed-short ()`(signed-byte ,short-length))
(deftype unsigned-short ()`(unsigned-byte ,short-length))
(deftype short ()`(signed-short))

(deftype non-negative-int () `(non-negative-byte ,int-length))
(deftype negative-int () `(negative-byte ,int-length))
(deftype signed-int ()`(signed-byte ,int-length))
(deftype unsigned-int ()`(unsigned-byte ,int-length))
(deftype int ()`(signed-int))

(deftype non-negative-fixnum () `(non-negative-byte ,fixnum-length))
(deftype negative-fixnum () `(negative-byte ,fixnum-length))
(deftype signed-fixnum ()`(signed-byte ,fixnum-length))
(deftype unsigned-fixnum ()`(unsigned-byte ,fixnum-length))
(deftype fixnum ()`(signed-fixnum))

(deftype non-negative-lfixnum () `(non-negative-byte ,lfixnum-length))
(deftype negative-lfixnum () `(negative-byte ,lfixnum-length))
(deftype signed-lfixnum ()`(signed-byte ,lfixnum-length))
(deftype unsigned-lfixnum ()`(unsigned-byte ,lfixnum-length))
(deftype lfixnum ()`(signed-lfixnum))

(deftype fcomplex nil `(complex short-float))
(deftype dcomplex nil `(complex long-float))

;; (defun key-fn-p (x)
;;   (or (funcall x nil) t))
;; (deftype key-fn nil `(or (eql ,#'identity) (satisfies key-fn-p)))

;; (defun test-fn-p (x)
;;   (or (funcall x nil nil) t))
;; (deftype test-fn nil `(satisfies test-fn-p))

(deftype string (&optional size)
  `(array character (,size)))
(deftype base-string (&optional size)
  `(array base-char (,size)))
(deftype bit-vector (&optional size)
  `(array bit (,size)))

(deftype simple-vector (&optional size)
  `(array t (,size)))
(deftype simple-string (&optional size)
  `(array character (,size)))
(deftype simple-base-string (&optional size)
  `(array base-char (,size)))
(deftype simple-bit-vector (&optional size)
  `(array bit (,size)))

(deftype function-identifier () `(satisfies function-identifierp))


(deftype list () `(or cons null))
(deftype sequence () `(or list vector))

(defun standard-charp (x)
  (when (characterp x)
    (standard-char-p x)))

(defun non-standard-base-char-p (x)
  (and (characterp x) (not (standard-char-p x))))

(defun improper-consp (s &optional (f nil fp))
  (cond ((not fp) (cond ((atom s) nil)
			((atom (cdr s)) (when (cdr s) t))
			((improper-consp (cdr s) (cddr s)))))
	((atom f) f)
	((atom (cdr f)) (when (cdr f) t))
	((eq s f))
	((improper-consp (cdr s) (cddr f)))))

;(deftype proper-list () `(or null (and cons (not (satisfies improper-consp)))))

(deftype extended-char () nil)
(deftype base-char () `(or standard-char non-standard-base-char))
(deftype character () `(or base-char extended-char))

(deftype stream () `(or broadcast-stream concatenated-stream echo-stream
			file-stream string-stream synonym-stream two-way-stream))
(deftype file-stream nil `(or file-input-stream file-output-stream file-io-stream file-probe-stream))
(deftype string-stream nil `(or string-input-stream string-output-stream))

(deftype input-stream ()  `(and stream (satisfies  input-stream-p)))
(deftype output-stream () `(and stream (satisfies  output-stream-p)))

(deftype bignum () `(and integer (not fixnum)))
(deftype non-negative-bignum () `(and non-negative-byte (not non-negative-fixnum)))
(deftype negative-bignum () `(and negative-byte (not negative-fixnum)))
;;FIXME adjust integer bounds here?
(deftype rational (&optional (low '*) (high '*)) `(or (integer ,low ,high) (ratio ,low ,high)))
(deftype float (&optional (low '*) (high '*)) `(or (short-float ,low ,high) (long-float ,low ,high)))
(deftype single-float (&optional (low '*) (high '*)) `(long-float ,low ,high))
(deftype double-float (&optional (low '*) (high '*)) `(long-float ,low ,high))
(deftype real (&optional (low '*) (high '*)) `(or (rational ,low ,high) (float ,low ,high)))
(deftype number () `(or real complex))
(deftype atom () `(not cons))
(deftype function (&rest r) (declare (ignore r)) `(compiled-function))
;  `(or interpreted-function compiled-function))
(deftype compiled-function nil `(or generic-function non-generic-compiled-function))
;(deftype generic-function nil `(satisfies generic-function-p));Overwritten by pcl check ;FIXME

(deftype integer (&optional (low '*) (high '*)) `(integer ,low ,high))
(deftype ratio (&optional (low '*) (high '*)) `(ratio ,low ,high))
(deftype short-float (&optional (low '*) (high '*)) `(short-float ,low ,high))
(deftype long-float (&optional (low '*) (high '*)) `(long-float ,low ,high))

(deftype array (&optional (et '*) (dims '*)) `(array ,et ,(or dims 0)))
(deftype simple-array (&rest r) (cons 'array r))
;; (deftype simple-array (&optional (et '*) (dims '*)) 
;;   `(array ,et ,(if (not dims) 0 dims)))

(deftype eql (&optional (x nil xp)) (when xp `(member ,x)))

(deftype boolean () `(member t nil))
(deftype null () `(member nil))

(deftype symbol () `(or non-keyword-symbol keyword))

(deftype complex (&optional (rp 'real)) `(complex ,(if (eq rp '*) 'real rp)))
(deftype cons (&optional (car t) (cdr t)) `(cons ,(if (eq car '*) t car)  ,(if (eq cdr '*) t cdr)))
(deftype structure-object nil `(structure))
;(deftype logical-pathname nil `(and pathname (satisfies logical-pathname-p)))
(deftype pathname () `(or non-logical-pathname logical-pathname))

;; (defun non-logical-pathname-p (x)
;;   (and (pathnamep x) (not (logical-pathname-p x))))

(defun non-keyword-symbol-p (x)
  (and (symbolp x) (not (keywordp x))))

;(defun simple-array-p (x)
;  (and (arrayp x)
       ;; should be (not (expressly-adjustable-p x))
       ;; since the following will always return T
       ;; (not (adjustable-array-p x))
;       (not (array-has-fill-pointer-p x))
;       (not (displaced-array-p x))))


;(defun extended-char-p (x) (declare (ignore x)) nil)

;(defun interpreted-function-p (x) 
;  (and (function-p x) (not (compiled-function-p x))))

;(defun function-p (x)
;  (and (not (symbolp x)) (functionp x)))

(defun sequencep (x)
  (or (listp x) (vectorp x)))

(defun short-float-p (x)
  (= (c-type x) #.(c-type 0.0s0)))
;  (and (floatp x) (eql x (float x 0.0s0))))

(defun long-float-p (x)
  (= (c-type x) #.(c-type 0.0)))
;  (and (floatp x) (eql x (float x 0.0))))

(defun fcomplexp (x)
  (and (complexp x) (short-float-p (realpart x)) (short-float-p (imagpart x))))

(defun dcomplexp (x)
  (and (complexp x) (long-float-p (realpart x)) (long-float-p (imagpart x))))

;(defun proper-listp (x)
;  (or (not x) (and (consp x) (not (improper-consp x)))))

(deftype proper-sequence () `(or vector proper-list))

(deftype proper-list () `(or null proper-cons))

(defun proper-consp (x)
  (and (consp x) (not (improper-consp x))))

(defun proper-listp (x)
  (or (null x) (proper-consp x)))

(defun proper-sequencep (x)
  (or (vectorp x) (proper-listp x)))

(deftype not-type nil 'null)
(deftype list-of (y) 
  (let* ((sym (intern (string-concatenate "LIST-OF-" (symbol-name y)) 'si))) 
    (unless (fboundp sym)
      (eval `(defun ,sym (x) 
	       (declare (proper-list x))
	       (not (member-if-not (lambda (x) (typep x ',y)) x)))) )
    `(and proper-list (satisfies ,sym))))

#.`(eval-when 
    (compile load eval) 
    ,@(mapcar (lambda (x) 
		`(defun ,(intern (string-concatenate "LIST-OF-" (symbol-name x))) (w)
		   (declare (proper-list w))
		   (not (member-if-not (lambda (z) (typep z ',x)) w))))
	      '(symbol seqind proper-list)))

(deftype type-spec nil `(or symbol class structure proper-cons))
(deftype fpvec nil `(and vector (satisfies array-has-fill-pointer-p)))

(defun non-generic-compiled-function-p (x)
  (cond ((typep x 'generic-function) nil)
	((typep x 'function) (typep (caddr (c-function-plist x)) 'string))));(compiled-function-p x)

(defconstant +type-alist+ '((null . null)
	  (not-type . not)
          (symbol . symbolp)
          (eql-is-eq-tp . eql-is-eq)
          (equal-is-eq-tp . equal-is-eq)
          (equalp-is-eq-tp . equalp-is-eq)
          (keyword . keywordp)
	  ;; (non-logical-pathname . non-logical-pathname-p)
	  (logical-pathname . logical-pathname-p)
	  (proper-cons . proper-consp)
	  (proper-list . proper-listp)
	  (proper-sequence . proper-sequencep)
	  (non-keyword-symbol . non-keyword-symbol-p)
	  (standard-char . standard-charp)
	  (non-standard-base-char . non-standard-base-char-p)
;	  (interpreted-function . interpreted-function-p)
	  (real . realp)
	  (float . floatp)
	  (short-float . short-float-p)
	  (long-float . long-float-p)
	  (fcomplex . fcomplexp)
	  (dcomplex . dcomplexp)
	  (array . arrayp)
	  (vector . vectorp)
	  (bit-vector . bit-vector-p)
	  (string . stringp)
	  (complex . complexp)
	  (ratio . ratiop)
	  (sequence . sequencep)
          (atom . atom)
          (cons . consp)
          (list . listp)
          (seqind . seqindp)
          (fixnum . fixnump)
          (integer . integerp)
          (rational . rationalp)
          (number . numberp)
          (character . characterp)
          (package . packagep)
          (stream . streamp)
          (pathname . pathnamep)
          (readtable . readtablep)
          (hash-table . hash-table-p)
          (hash-table-eq . hash-table-eq-p)
          (hash-table-eql . hash-table-eql-p)
          (hash-table-equal . hash-table-equal-p)
          (hash-table-equalp . hash-table-equalp-p)
          (random-state . random-state-p)
          (structure . structurep)
          (function . functionp)
          (compiled-function . compiled-function-p)
          (non-generic-compiled-function . non-generic-compiled-function-p)
          (generic-function . generic-function-p)
          (common . commonp)))

(dolist (l +type-alist+)
  (putprop (car l) (cdr l) 'type-predicate)
  (when (symbolp (cdr l)) 
    (putprop (cdr l) (car l) 'predicate-type)))


(defconstant +singleton-types+ '(non-keyword-symbol keyword standard-char
				      non-standard-base-char 
				      package cons
				      broadcast-stream concatenated-stream echo-stream
				      file-input-stream file-output-stream file-io-stream file-probe-stream
				      string-input-stream string-output-stream
				      synonym-stream two-way-stream 
				      non-logical-pathname logical-pathname
				      readtable 
				      hash-table-eq hash-table-eql hash-table-equal hash-table-equalp
				      random-state std-structure structure 
				      non-generic-compiled-function
				      generic-function
				      ))


(defconstant +range-types+ `(integer ratio short-float long-float))

;(defconstant +array-types+ (append '(nil) +array-types+))

(deftype vector (&optional (element-type '* ep) size)
  (if ep 
      `(array ,element-type (,size))
    `(or ,@(mapcar (lambda (x) `(array ,x (,size))) +array-types+))))

(defconstant +known-types+ (append +range-types+ 
				   (mapcar (lambda (x) `(complex ,x)) +range-types+)
				   +singleton-types+
				   (mapcar (lambda (x) `(array ,x)) +array-types+)))

(defconstant +array-type-alist+ (mapcar (lambda (x) (cons x (intern (string-concatenate "ARRAY-" (string x)))))
					+array-types+))
(defconstant +complex-type-alist+ (mapcar (lambda (x) (cons x (intern (string-concatenate "COMPLEX-" (string x)))))
					+range-types+))

(defconstant +kindom-logic-ops-alist+ `(,@(mapcar (lambda (x) `(,x . range-op)) +range-types+)
					  (cons . cons-op)
					  (standard-object . standard-op)
					  (structure . structure-op)
					  ,@(mapcar (lambda (x) `(,(cdr x) . complex-op)) +complex-type-alist+)
					  ,@(mapcar (lambda (x) `(,(cdr x) . array-op)) +array-type-alist+)
					  ,@(mapcar (lambda (x) `(,x . single-op)) +singleton-types+)))

(defconstant +kindom-recon-ops-alist+ `(,@(mapcar (lambda (x) `(,x . range-recon)) +range-types+)
					  (cons . cons-recon)
					  (standard-object . standard-recon)
					  (structure . structure-recon)
					  ,@(mapcar (lambda (x) `(,(cdr x) . complex-recon)) +complex-type-alist+)
					  ,@(mapcar (lambda (x) `(,(cdr x) . array-recon)) +array-type-alist+)
					  ,@(mapcar (lambda (x) `(,x . single-recon)) +singleton-types+)))

(defconstant +kindom-load-ops-alist+ `(,@(mapcar (lambda (x) `(,x . range-load)) +range-types+)
					 (complex . complex-load)
					 (cons . cons-load)
					 (standard-object . standard-load)
					 (structure . structure-load)
					 (array . array-load)
;					 (simple-array . array-load)
					 ,@(mapcar (lambda (x) `(,x . single-load)) +singleton-types+)))



(defmacro make-ntp nil `(make-list 3))
(defconstant +tp-nil+ (make-ntp))
(defconstant +tp-t+   '(nil t nil));FIXME cannot call ntp-not as depends on setf too early
(defmacro ntp-tps (ntp) `(first ,ntp))
(defmacro ntp-def (ntp) `(second ,ntp))
(defmacro ntp-ukn (ntp) `(third ,ntp))
(defmacro ntp-ld (ntp tp) (let ((ns (gensym)) (ts (gensym)))
				`(let ((,ns ,ntp) (,ts ,tp))
				   (when ,ts
				     (if (ntp-tps ,ns) (nconc (ntp-tps
                                                               ,ns)
                                                              (list
                                                               ,ts))
                                       (setf (ntp-tps ,ns) (list ,ts)))))))
(defmacro range-num (x) `(if (atom ,x) ,x (car ,x)))
(defmacro elcomp (x) `(cond ((eq ,x '*) ,x) 
			    ((atom ,x) (list ,x)) 
			    ((car ,x))))

;;FIXME --remove these when compiler is ready

(defmacro lposition-if (fn lst)
  (let ((lsym (gensym)) (p (gensym)) (ind (gensym)))
    `(let ((,lsym ,lst))
       (do ((,ind ,lsym (cdr ,ind)) (,p 0 (1+ ,p))) ((or (not ,ind) (funcall ,fn (car ,ind))) (and ,ind ,p))
	   (declare (seqind ,p))))))

(defmacro lposition-eq (itm lst)
  (let ((lsym (gensym)) (i (gensym)) (p (gensym)) (ind (gensym)))
    `(let ((,lsym ,lst) (,i ,itm))
       (do ((,ind ,lsym (cdr ,ind)) (,p 0 (1+ ,p))) ((or (not ,ind) (eq ,i (car ,ind))) (and ,ind ,p))
	   (declare (seqind ,p))))))

(defmacro ldelete-if (fn lst)
  (let ((lsym (gensym)) (f (gensym)) (p (gensym)) (ind (gensym)))
    `(let ((,lsym ,lst))
       (do ((,p nil (or ,p ,f)) ,f (,ind ,lsym (cdr ,ind))) ((not ,ind) ,f)
	   (if (funcall ,fn (car ,ind))
	       (when ,p (setq ,p (rplacd ,p (cdr ,ind))))
	     (setq ,f (or ,f ,ind) ,p (cdr ,p)))))))

(defmacro lremove-if (fn lst)
  (let ((lsym (gensym)) (tmp (gensym)) (r (gensym)) (l (gensym)) (ind (gensym)))
    `(let ((,lsym ,lst) ,r ,l)
       (do ((,ind ,lsym (cdr ,ind))) ((not ,ind) ,r)
	   (unless (funcall ,fn (car ,ind))
	     (setf (car (setq ,l (let ((,tmp (cons nil nil))) (if ,l (cdr (rplacd ,l ,tmp)) (setq ,r ,tmp))))) (car ,ind)))))))

(defmacro lremove-if-not (fn lst)
  (let ((lsym (gensym)) (tmp (gensym)) (r (gensym)) (l (gensym)) (ind (gensym)))
    `(let ((,lsym ,lst) ,r ,l)
       (do ((,ind ,lsym (cdr ,ind))) ((not ,ind) ,r)
	   (when (funcall ,fn (car ,ind))
	     (setf (car (setq ,l (let ((,tmp (cons nil nil))) (if ,l (cdr (rplacd ,l ,tmp)) (setq ,r ,tmp))))) (car ,ind)))))))

(defvar *tp-mod* 0)
(eval-when (compile) (proclaim '(type (integer -1 1) *tp-mod*)));FIXME

(defun tp-mod (x d)
  (unless (or (not (ntp-ukn x)) (/= (let ((x *tp-mod*)) (if (>= x 0) x (- x))) 1))
    (if d (setf (ntp-tps x) nil (ntp-def x) (= *tp-mod* 1) (ntp-ukn x) nil)
      (setq x (if (= *tp-mod* 1) +tp-t+ +tp-nil+))))
  x)

(defun ntp-clean (x) ;; FIXME same for t and (ntp-def x)
 (when (and (rassoc nil (ntp-tps x) :key 'car) (not (ntp-def x)))
    (setf (ntp-tps x) (lremove-if (lambda (x) (not (cadr x))) (ntp-tps x)))))

(defun ntp-and (&rest xy)
  (when xy
    (let ((x (tp-mod (car xy) t)) (y (tp-mod (cadr xy) nil)))
      (dolist (l (ntp-tps x))
	(let ((op (cdr (assoc (car l) +kindom-logic-ops-alist+)))
	      (ny (assoc (car l) (ntp-tps y))))
	  (when (or ny (not (ntp-def y)))
	    (funcall op 'and l ny))))
      (dolist (l (ntp-tps y))
	(when (and (ntp-def x) (not (assoc (car l) (ntp-tps x))))
	  (ntp-ld x l)))
      (setf (ntp-def x) (and (ntp-def x) (ntp-def y)))
      (setf (ntp-ukn x) (or  (ntp-ukn x) (ntp-ukn y)))
      (ntp-clean x)
      x)))

(defun ntp-or (&rest xy)
  (when xy
    (let ((x (tp-mod (car xy) t)) (y (tp-mod (cadr xy) nil)))
      (dolist (l (ntp-tps x))
	(let* ((op (cdr (assoc (car l) +kindom-logic-ops-alist+)))
	      (ny (assoc (car l) (ntp-tps y)))
	      (ny (or ny (when (ntp-def y) (let ((z `(,(car l) nil))) (funcall op 'not z nil) z)))))
	  (when ny
	    (funcall op 'or l ny))))
      (dolist (l (ntp-tps y))
	(unless (or (ntp-def x) (assoc (car l) (ntp-tps x)))
	  (ntp-ld x l)))
      (setf (ntp-def x) (or (ntp-def x) (ntp-def y)))
      (setf (ntp-ukn x) (or (ntp-ukn x) (ntp-ukn y)))
      (ntp-clean x)
      x)))

(defun ntp-not (x)
  (dolist (l (ntp-tps x))
    (funcall (cdr (assoc (car l) +kindom-logic-ops-alist+)) 'not l nil))
  (setf (ntp-def x) (negate (ntp-def x)))
  (ntp-clean x)
  x)

(defun imod (x p)
  (if (eq x '*) x
    (let* ((e (atom x))
	   (x (if e x (car x)))
	   (cx (if (= p 1) (ceiling x) (floor x))))
      (cond ((/= cx x) cx)
	    (e cx)
	    ((+ cx p))))))
  
(defun integer-range-fixup (x &optional res)
  (cond ((not x) (lremove-if (lambda (x) (and (realp (car x)) (realp (cdr x)) (> (car x) (cdr x)))) (nreverse res)))
	((integer-range-fixup (cdr x) 
			      (cons (cons (imod (caar x) 1) (imod (cdar x) -1)) res)))))

(defun tp-bnd (nx a tp)
  (if (eq tp 'ratio) 
      (let ((z (rational nx))) 
	(if (and a (integerp z)) (list z) z))
    (float nx (if (eq tp 'short-float) 0.0s0 0.0))))

(defun get-tp-bnd (x tp)
  (let* ((a (atom x))
	 (nx (if a x (car x))))
    (if (or (eq nx '*) (typep nx tp)) x
      (let ((z (tp-bnd nx a tp))) (if a z (list z))))))

(defun number-range-fixup (x tp)
  (if (eq tp 'integer)
      (integer-range-fixup x)
    (lremove-if (lambda (x) (let ((a (car x)) (d (cdr x))) 
			      (let ((na (if (atom a) a (car a))) (nd (if (atom d) d (car d))))
				(and (not (eq na '*)) (not (eq nd '*))
				     (= na nd)
				     (or (listp a) (listp d))))))
					;		x)))
		(mapl (lambda (x) (let* ((x (car x))
					 (a (get-tp-bnd (car x) tp))
					 (d (get-tp-bnd (cdr x) tp))
					 (na (if (atom a) a (car a)))
					 (nd (if (atom d) d (car d))))
				    (unless (eql na nd)
				      (when (isinf nd) 
					(if (< nd 0) 
					    (setq a (if (atom d) (list nd) nd))
					  (setq d '*)))
				      (when (isinf na)
					(if (> na 0) 
					    (setq d (if (atom a) (list na) na))
					  (setq a '*))))
				    (setf (car x) a (cdr x) d))) x))))

;; GENERIC SIGMA ALGEBRA OPERATIONS

(defun memberv (x y)
  (and (consp x) (consp y)
       (eq (car x) 'member) (eq (car y) 'member)
       (let ((z (union (cdr x) (cdr y))))
	 (and z `(member ,@z)))))

(defun member- (x y)
  (and (consp x) (consp y)
       (eq (car x) 'member) (eq (car y) 'member)
       (let ((z (set-difference (cdr x) (cdr y))))
	 (and z `(member ,@z)))))


(defun clean-or (atm lst)
  (if (funcall atm lst) lst
    (or 
     (car (member t lst))
     (let ((nl (lremove-if 'not (remove-duplicates (cdr lst) :test 'equal))))
       (if (cdr nl) `(or ,@nl) (car nl))))))

(defun clean-and (atm lst)
  (if (funcall atm lst) lst
    (unless (member nil lst)
      (let ((nl (lremove-if (lambda (z) (eq z t)) (remove-duplicates (cdr lst) :test 'equal))))
	(if (cdr nl) `(and ,@nl) (or (car nl) t))))))


(defun clean-tp (op atm x &optional y)
  (let ((cf (case op (or 'clean-or) (and 'clean-and) (otherwise (error "Bad op~%"))))
	(x (if (funcall atm x) (list x) x)))
    (let ((z (cond ((eq (car y) op) (funcall cf  atm `(,op ,@x ,@(cdr y))))
		   ((member (car y) '(and not or)) `(,op ,@x ,y))
		   ((funcall cf atm  `(,op ,@x ,@y))))))
      z)))
    
(defmacro negate (lst)
  (let ((l (gensym)))
    `(let ((,l ,lst))
       (cond ((not ,l))
	     ((eq ,l t) nil)
	     ((and (consp ,l) (eq (car ,l) 'not)) (cadr ,l))
	     (`(not ,,l))))))
  

(defun sigalg-atom-op (op ox oy ^ atm)
  (let* ((cx (and (consp ox) (eq (car ox) 'not)))
	 (x (if cx (cadr ox) ox))
	 (cy (and (consp oy) (eq (car oy) 'not)))
	 (y (if cy (cadr oy) oy))
	 (^xy (funcall ^ x y))
	 (vxy (memberv x y))
	 (-xy (if vxy (member- x y) x))
	 (-yx (if vxy (member- y x) y))
	 (<xy (equal ^xy x))
	 (<yx (equal ^xy y))
	 (opor (case op (or t) (and nil) (otherwise (error "Bad op~%")))))
    (cond ((not (or cx cy)) 
	   (cond (<xy (if opor y x))
		 (<yx (if opor x y))
		 (opor (or vxy (clean-or atm `(or ,x ,y))))
		 (^xy)))
	  ((and cx cy)
	   (cond (<xy `(not ,(if opor x y)))
		 (<yx `(not ,(if opor y x)))
		 (opor (negate ^xy))
		 ((negate (sigalg-atom-op 'or x y ^ atm)))))
	  (cx (sigalg-atom-op op oy ox ^ atm))
	  ((and <xy <yx) opor)
	  (<xy (when opor 
		 (if (equal -yx y)
		     (clean-or atm `(or ,x ,(negate y)))
		   (negate -yx))))
	  (<yx (if opor t (if (equal x -xy) (clean-and atm `(and ,x ,(negate y))) -xy)))
	  (opor (if (funcall ^ ^xy -yx) (clean-or atm `(or ,^xy ,(negate -yx))) (negate -yx)))
	  ((clean-and atm (if (funcall ^ -xy ^xy) `(and ,-xy ,(negate ^xy)) -xy))))))

(defun sigalg-op (op x y ^ atm)
  (let ((ax (funcall atm x)))
    (cond ((and (not ax) (eq op (car x)))
	   (sigalg-op op (cadr x) (clean-tp op atm (cddr x) (if (funcall atm y) (list y) y)) ^ atm))
	  ((and (not ax) (eq 'not (car x)))
	   (negate (sigalg-op (if (eq op 'or) 'and 'or) (negate x) (negate y) ^ atm)))
	  ((not ax);FIXME reduce here?
	   (clean-tp 
	    (if (eq op 'or) 'and 'or) 
	    atm 
	    (mapcar (lambda (w) (sigalg-op op w y ^ atm)) (cdr x))))
	  ((funcall atm y) (sigalg-atom-op op x y ^ atm))
	  ((eq op (car y))
	   (let* ((y (if (cddr y) (sigalg-op op (cadr y) `(,op ,@(cddr y)) ^ atm) y))
		  (y (if (or (atom y) (not (eq (car y) op))) `(,op ,y) y))
		  (q (mapcar (lambda (z) (sigalg-op op x z ^ atm)) (cdr y))))
	     (let ((z 
		    (clean-tp 
		     op atm
		     (do ((y (cdr y) (cdr y)) (q q (cdr q))) 
			 ((or (not y) (not q) (equal (car y) (car q))) (if (and y q) (eq op 'and) x)))
		     (mapcar (lambda (x y) (if (funcall atm y) y x))
			     (cdr y) q))))
	       (if (funcall atm z) z 
		 (let ((ny (clean-tp op atm (cddr z)))) 
		   (if (and (equal x (cadr z)) (equal ny y)) 
		       z 
		     (sigalg-op op (cadr z) ny ^ atm)))))))
	  ((eq 'not (car y))
	   (negate (sigalg-op (if (eq op 'or) 'and 'or) (negate x) (negate y) ^ atm)))
	  (t
	    (let ((z (mapcar (lambda (w) (sigalg-op op x w ^ atm)) (cdr y))))
	      (reduce (lambda (&rest xy) (when xy (sigalg-op (if (eq op 'or) 'and 'or) (car xy) (cadr xy) ^ atm))) z))))))


;; RANGE-TYPES

(defun range-load (ntp type)
  (let* ((z `((,(cadr type) . ,(caddr type))))
	 (z (number-range-fixup z (car type))))
    (ntp-ld ntp (let ((z `(,(car type) ,z))) z))))

(defun elgt (x y)
  (cond ((or (eq (car x) '*) (eq (cdr y) '*)) nil)
	((and (integerp (car x)) (integerp (cdr y))) (> (car x) (1+ (cdr y))))
	((and (listp (car x)) (listp (cdr y))) (>= (range-num (car x)) (range-num (cdr y))))
	((> (range-num (car x)) (range-num (cdr y))))))

(defun elin (x y op)
  (cond ((eq x '*) y)
	((eq y '*) x)
	((= (range-num x) (range-num y)) (if (atom x) y x))
	((funcall op (range-num x) (range-num y)) x)
	(y)))

(defun elout (x y op)
  (cond ((eq x '*) x)
	((eq y '*) y)
	((= (range-num x) (range-num y)) (if (atom x) x y))
	((funcall op (range-num x) (range-num y)) x)
	(y)))

(defun goodel (x y)
  (cond ((eq x '*))
	((eq y '*))
	((let ((ax (range-num x))
	       (ay (range-num y)))
	   (or (< ax ay) (and (= ax ay) (atom x) (atom y)))))))

(defun range-and (x y &optional res)
  (cond ((or (not x) (not y)) (nreverse res))
	((elgt (car y) (car x)) (range-and (cdr x) y res))
	((elgt (car x) (car y)) (range-and x (cdr y) res))
	((let* ((w (elin (caar x) (caar y) '>))
		(z (elin (cdar y) (cdar x) '<))
		(zy (eq (cdar y) z))
		(nr (if (goodel w z) (cons (cons w z) res) res)))
	   (range-and (if zy x (cdr x)) (if zy (cdr y) y) nr)))))

(defun maybe-or-push (x res)
  (cond ((not res) (list x))
	((elgt x (car res)) (cons x res))
	((cons (cons (elout (caar res) (car x) '<) (elout (cdr x) (cdar res) '>)) (cdr res)))))

;;FIXME handle cleanups here and in and
(defun range-or (x y &optional res)
  (cond ((and (not x) (not y)) (nreverse res))
	((not x) (range-or x (cdr y) (maybe-or-push (car y) res)))
	((not y) (range-or (cdr x) y (maybe-or-push (car x) res)))
	((elgt (car y) (car x)) (range-or (cdr x) y (maybe-or-push (car x) res)))
	((elgt (car x) (car y)) (range-or x (cdr y) (maybe-or-push (car y) res)))
	((range-or (cdr x) (cdr y)
		    (maybe-or-push (cons (elout (caar x) (caar y) '<) (elout (cdar y) (cdar x) '>)) res)))))

(defun range-not (x &optional res (last '* lastp))
  (cond ((not x) (nreverse (if (and lastp (eq last '*)) res (cons (cons (elcomp last) '*) res))))
	((range-not (cdr x) (if (eq (caar x) last) res (cons (cons (elcomp last) (elcomp (caar x))) res)) (cdar x)))))

(defun range-op (op x y)
  (case op
	(and (setf (cadr x) (range-and (cadr x) (cadr y))))
	(or (setf (cadr x) (range-or (cadr x) (cadr y))))
	(not (setf (cadr x) (range-not (cadr x))))))

(defun range-recon (x)
  (let ((z (mapcar (lambda (y) `(,(car x) ,(car y) ,(cdr y))) (number-range-fixup (cadr x) (car x)))))
    (if (cdr z) `(or ,@z) (car z))))

;; COMPLEX

(defun complex-load (ntp type)
  (let* ((z `((,(cadr (cadr type)) . ,(caddr (cadr type)))))
	 (z (number-range-fixup z (car type))))
    (ntp-ld ntp `(,(cdr (assoc (car (cadr type)) +complex-type-alist+)) (,z . ,z)))))

(defun complex-op (op x y)
  (let ((z
	 (case op
	       (and (cons (range-and (caadr x) (caadr y)) (range-and (cdadr x) (cdadr y))))
	       (or (cons (range-or (caadr x) (caadr y)) (range-or (cdadr x) (cdadr y))))
	       (not (cons (range-not (caadr x) (caadr y)) (range-not (cdadr x) (cdadr y)))))))
    (setf (cadr x) (and (car z) (cdr z) z))))

(defun complex-recon (x)
  (let* ((tp (car (rassoc (car x) +complex-type-alist+)))
	 (z (range-or (caadr x) (cdadr x)))
	 (z (number-range-fixup z tp))
	 (z (mapcar (lambda (y) `(complex (,tp ,(car y) ,(cdr y)))) z)))
    (if (cdr z) `(or ,@z) (car z))))


;; SINGLETON-TYPES

(defun single-load (ntp type)
  (ntp-ld ntp `(,(car type) ,(or (cadr type) t))))

(defun single-atm (x)
  (cond ((or (eq x t) (not x)))
	((and (consp x) (eq (car x) 'member)))
	((and (consp x) (eq (car x) 'not)) (single-atm (cadr x)))))

(defun ordered-intersection-eq (l1 l2)
  (let (z zt)
    (do ((l l1 (cdr l))) ((not l))
      (when (memq (car l) l2)
	(setf zt (let ((p (cons (car l) nil))) (if zt (cdr (rplacd zt p)) (setf z p))))))
    z))

(defun ordered-intersection (l1 l2)
  (let (z zt)
    (do ((l l1 (cdr l))) ((not l))
      (when (member (car l) l2)
	(setf zt (let ((p (cons (car l) nil))) (if zt (cdr (rplacd zt p)) (setf z p))))))
    z))

(defun single^ (x y)
  (cond ((eq x t) y)
	((eq y t) x)
	((and x y) (let ((z (ordered-intersection (cdr x) (cdr y)))) (when z `(member ,@z))))))

(defun single-op (op x y)
  (setf (cadr x)
	(case op
	      ((and or) (sigalg-atom-op op (cadr x) (cadr y) 'single^ 'single-atm))
	      (not (negate (cadr x))))))

(defun single-recon (x)
  (cond ((eq (cadr x) t) (car x))
	((and (consp (cadr x)) (eq (caadr x) 'not)) `(and ,(car x) ,(cadr x)))
	((cadr x))))


;; ARRAY TYPES

(defun array-load (ntp type)
  (let* ((z (cadr type))
	 (z (if (eq z '*) z (car (member z +array-types+)))))
    (unless (or z (not (cadr type))) (error "Bad array type ~a~%" (cadr type)))
    (let* ((dim (caddr type))
	   (dim (cond ((eq dim '*) t)
		      ((integerp dim) (if (= 0 dim) dim (make-list dim :initial-element t)))
		      ((listp dim) (substitute t '* dim)))))
      (cond ((eq z '*) 
	     (dolist (l +array-type-alist+)
	       (ntp-ld ntp `(,(cdr l) ,(when z dim)))))
	    (z (ntp-ld ntp `(,(cdr (assoc z +array-type-alist+)) ,dim)))))))
  
(defun array-atm (x)
  (cond ((atom x))
	((eq (car x) 'not) (array-atm (cadr x)))
	((integerp (car x)))
	((eq (car x) 'member))
	((eq (car x) t))))

(defun array^ (x y)
  (cond ((not (and x y)) nil)
	((eq y t) x)
	((eq x t) y)
	((and (integerp x) (integerp y)) (when (= x y) x))
	((integerp x) (when (and (consp y) (= x (length y))) y))
	((integerp y) (array^ y x))
	((and (eq (car x) 'member) (eq (car y) 'member))
	 (let ((q (ordered-intersection-eq (cdr x) (cdr y))))
	   (when q `(member ,@q))))
	((eq (car x) 'member)
	 (let* ((y (substitute '* t y))
		(q (lremove-if-not (lambda (x) (match-dimensions (array-dimensions x) y)) (cdr x))))
	   (when q `(member ,@q))))
	((and (consp y) (eq (car y) 'member)) (array^ y x))
	((/= (length x) (length y)) nil)
	((mapcar 'array^ x y))))

(defun array-op (op x y)
  (setf (cadr x)
	(case op
	      ((and or) (sigalg-op op (cadr x) (cadr y) 'array^ 'array-atm))
	      (not (negate (cadr x))))))

(defun array-recon (x &aux (tp (pop x))(x (car x))) 
  (cond ((not (array-atm x))
	 (cons 'or (mapcar (lambda (z) (array-recon `(,tp ,z))) (cdr x))))
	((and (consp x) (eq (car x) 'member) x))
	(`(array ,(car (rassoc tp +array-type-alist+)) 
		 ,(cond ((eq x t) '*)
			((atom x) x) 
			((substitute '* t x)))))))

;; STRUCTURES

(defun structure-load (ntp type) (single-load ntp type))

(defun structure-atm (x)
  (cond ((atom x))
	((eq (car x) 'not) (structure-atm (cadr x)))
	((eq (car x) 'member))))

(defun structure^ (x y)
  (cond ((not (and x y)) nil)
	((eq x t) y)
	((eq y t) x)
	((and (consp x) (eq (car x) 'member))
	 (let ((q (lremove-if-not (lambda (z) (typep z y)) (cdr x))))
	   (when q `(member ,@q))))
	((and (consp y) (eq (car y) 'member)) (structure^ y x))
	((do ((z x (s-data-includes z))) ((or (not z) (eq z y)) (and z x))))
	((do ((z y (s-data-includes z))) ((or (not z) (eq z x)) (and z y))))))

(defun structure-op (op x y)
  (setf (cadr x)
	(case op
	      ((and or) (sigalg-op op (cadr x) (cadr y) 'structure^ 'structure-atm))
	      (not (negate (cadr x))))))

(defun structure-recon (x) (single-recon x))

;; CLASS HACKS

;(defvar *prevent-compiler-optimization* nil)

(eval-when
 (compile eval)
 (defmacro clh nil
  `(progn
     ,@(mapcar (lambda (x &aux (f (when (eq x 'find-class) `(&optional ep))) (z (intern (string-concatenate "SI-" (symbol-name x)))))
		 `(defun ,z (o ,@f &aux e)
		    (cond ((and (fboundp ',x) (fboundp 'classp))
			   (prog1 (funcall ',x o ,@(cdr f))
			     (setf (symbol-function ',z) (symbol-function ',x))))
			  ((setq e (get ',z 'early)) (values (funcall e o ,@(cdr f)))))))
	       '(classp class-precedence-list find-class class-name class-of class-direct-subclasses)))))
(clh)

;; (defun classp (object) (declare (ignore object)) (the boolean *prevent-compiler-optimization*))
;; (defun class-precedence-list (object) (declare (ignore object)) (the proper-list *prevent-compiler-optimization*))
;; (defun find-class (object &optional errorp environment
;; 			  &aux (*prevent-compiler-optimization* (car (member object '(generic-function)))));FIXME
;;   (declare (ignore errorp environment))
;;   *prevent-compiler-optimization*)
;; (defun class-name (class) (declare (ignore class)) (the symbol *prevent-compiler-optimization*))
;; (defun class-of (object) (declare (ignore object)) *prevent-compiler-optimization*)
;; (defun class-direct-subclasses (object) (declare (ignore object)) (the proper-list *prevent-compiler-optimization*))

;; (defun is-standard-class-symbol (sym) ;FIXME
;;   (or (eq sym 'generic-function)
;;       (let* ((z (unless (get sym 's-data) (get sym 'deftype-definition)))
;; 	     (z (and z (not (caddr (get sym 'deftype-form))) (funcall z)))
;; 	     (z (and (consp z) (eq (car z) 'satisfies) (cadr z))))
;; 	(and z (not (member (symbol-package z) '(lisp si compiler) :key 'find-package))))))

(defun is-standard-class (object)
  (and (si-classp object)
       (member (si-find-class 'standard-object) (si-class-precedence-list object))
       object))

(defun find-standard-class (object)
  (when (symbolp object)
    (is-standard-class (si-find-class object nil))))

(defun coerce-to-standard-class (object)
  (cond ((is-standard-class object))
	((find-standard-class object))))

;; STANDARD-OBJECTS

(defun standard-load (ntp type) (single-load ntp type))

(defun standard-atm (x) (structure-atm x))

(defun standard^ (x y)
  (cond ((not (and x y)) nil)
	((eq x t) y)
	((eq y t) x)
	((eq x y) x) ;needed for early generic function processing
	((and (consp x) (eq (car x) 'member))
	 (let ((q (lremove-if-not (lambda (z) (typep z y)) (cdr x))))
	   (when q `(member ,@q))))
	((and (consp y) (eq (car y) 'member)) (standard^ y x))
	((member y (si-class-precedence-list x)) x)
	((member x (si-class-precedence-list y)) y)
	((reduce (lambda (&rest xy) (when xy (standard^ (car xy) (cadr xy))))
		 (ordered-intersection-eq (si-class-direct-subclasses x) (si-class-direct-subclasses y))))))

(defun standard-op (op x y)
  (setf (cadr x)
	(case op
	      ((and or) (sigalg-op op (cadr x) (cadr y) 'standard^ 'standard-atm))
	      (not (negate (cadr x))))))

(defun standard-recon (x)
  (let ((z (or (si-find-class (car x) nil) (car x))))
    (cond ((eq (cadr x) t) z)
	  ((and (consp (cadr x)) (eq (caadr x) 'not)) `(and ,z ,(cadr x)))
	  ((cadr x)))))

(defun funcallable-standard-object-p (x);FIXME
  (let ((s (load-time-value nil)))
    (setq s (or s (let ((x (find-symbol "FUNCALLABLE-STANDARD-OBJECT" (find-package "PCL")))) (when x (si-find-class x nil)))))
    (when (si-classp x)
      (member s (si-class-precedence-list x)))))

(defun ntp-load (type &aux tem)
  (let ((ntp (make-ntp)))
    (cond ((eq (car type) t) (ntp-not ntp))
	  ((eq (car type) 'proper-cons) (ntp-ld ntp (list 'cons 'proper-cons)))
	  ((setq tem (cdr (assoc (car type) +kindom-load-ops-alist+)))
	   (funcall tem ntp type))
	  ((setq tem (coerce-to-standard-class (car type)))
;	   (ntp-ld ntp (if (funcallable-standard-object-p tem) `(generic-function ,tem) `(std-structure ,tem))))
	   (ntp-ld ntp `(standard-object ,tem)))
	  ((and (symbolp (car type)) (setq tem (get (car type) 's-data)))
	   (ntp-ld ntp `(structure ,tem)))
	  ((eq (car type) 'member)
	   (let ((els (cdr type)))
	     (dolist (l +known-types+)
	       (let ((z (lremove-if-not (lambda (x) (typep x l)) els)))
		 (when z
		   (setq els (set-difference els z))
		   (let* ((z (cond ((member l +range-types+)
				    (reduce 'range-or
					    (mapcar
					     (lambda (x) 
					       (number-range-fixup `((,x . ,x)) l)) z)))
				   ((and (consp l) (eq (car l) 'complex))
				    (let ((q (reduce 'range-or
						     (mapcar 
						      (lambda (x) 
							(let ((q (realpart x))(r (imagpart x)))
							  (number-range-fixup
							   `((,(min q r) . ,(max q r)))
							   (cadr l)))) z))))
				      (cons q q)))
				   (`(member ,@z))))
			  (lst (and (consp l) (if (eq (car l) 'array) +array-type-alist+ +complex-type-alist+)))
			  (z (and z `(,(if lst (cdr (assoc (cadr l) lst)) l) ,z))))
		     (ntp-ld ntp z)))))
	     (when els (let ((ntp (ntp-not ntp))) (setf (ntp-ukn ntp) t)))))
	  ((car type) (let ((ntp (ntp-not ntp))) (setf (ntp-ukn ntp) t))))
    ntp))

(defun nprocess-type (type)
  (cond	
   ((eq (car type) 'type-min) (let ((*tp-mod* -1)) (nprocess-type (cadr type))))
   ((eq (car type) 'type-max) (let ((*tp-mod*  1)) (nprocess-type (cadr type))))
   ((eq (car type) 'and)  (reduce 'ntp-and (mapcar (lambda (x) (nprocess-type x)) (cdr type))))
   ((eq (car type) 'or)   (reduce 'ntp-or (mapcar (lambda (x) (nprocess-type x)) (cdr type))))
   ((eq (car type) 'not)  (ntp-not (nprocess-type (cadr type))))
   ((ntp-load type))))

(defun normalize-type-int (type ar &aux tem)
  (cond ((atom type) (normalize-type-int (list type) ar))
	;;These are deftype accelerators  FIXME may no longer be necessary with faster deftype
	((member (car type) +range-types+)
	 (let* ((l (cadr type))
		(ln (if (cdr type) (maybe-eval l) '*))
		(h (caddr type))
		(hn (if (cddr type) (maybe-eval h) '*)))
	 (if (and (eq l ln) (eq h hn)) type `(,(car type) ,ln ,hn))))
	((eq (car type) 'complex)
	 (let* ((z (cadr type))
		(zn (if (cdr type) (maybe-eval z) 'real))
		(zn (if (eq zn '*) 'real zn))
		(zn (normalize-type-int zn ar)))
	   (cond ((member (car zn) '(and or not)) (distribute-complex zn))
		 ((and (not (cddr type)) (eq z zn)) type)
		 (`(,(car type) ,zn)))))
	((eq (car type) 'array)
	 (let* ((tp (cadr type))
		(tpn (if (cdr type) (maybe-eval tp) '*))
		(tpn (if ar (upgraded-array-element-type tpn) tpn))
		(dm (caddr type))
		(dmn (if (cddr type) (maybe-eval dm) '*))
		(dmn (or dmn 0)))
	   (if (and (not (cdddr type)) (eq tp tpn) (eq dm dmn)) type `(,(car type) ,tpn ,dmn))))
	((eq (car type) 'member) type)
	((eq (car type) 'cons)
	 (let* ((def '(t))
		(car (cadr type))
		(carn (if (cdr type) (maybe-eval car) def))
		(carn (if (eq carn '*) def carn))
		(carn (if (eq carn def) carn (normalize-type-int carn ar)))
		(cdr (caddr type))
		(cdrn (if (cddr type) (maybe-eval cdr) def))
		(cdrn (if (eq cdrn '*) def cdrn))
		(cdrn (if (eq cdrn def) cdrn (normalize-type-int cdrn ar))))
	   (if (and (not (cdddr type)) (eq car carn) (eq cdr cdrn)) type `(,(car type) ,carn ,cdrn))))
	((setq tem (coerce-to-standard-class (car type))) (if (eq (car type) tem) type `(,tem ,@(cdr type))))
	((si-classp (car type)) (normalize-type-int `(,(si-class-name (car type)) ,@(cdr type)) ar))
	((and (not (cdr type)) (member (car type) +singleton-types+)) type)
	((and (eq (car type) 'satisfies) (get (cadr type) 'predicate-type) (list (get (cadr type) 'predicate-type))));FIXME
	 ;;      (setq tem (get (cadr type) 'predicate-type)))
	 ;;      (or (not (symbolp tem)) (not (eq (get tem 'type-predicate) (cadr type)))))
	 ;; (normalize-type-int tem ar))
;	((and (symbolp (car type)) (get (car type) 'type-predicate) type)); FIXME
	((let* ((dt (and (symbolp (car type)) 
			 (get (car type) 'deftype-definition)))
		(rr (if (member 'load-time-value (cdr type) :key (lambda (x) (when (consp x) (car x))))
			(mapcar (lambda (x) (if (and (consp x) (eq (car x) 'load-time-value)) (eval (cadr x)) x))
				(cdr type))
		      (cdr type)))
		(nt (and dt (or (apply dt rr) '(nil)))))
	   (when (and nt (not (equal type nt)))
	     (normalize-type-int nt ar))))
	((member (car type) '(and or not))
	 (let ((type `(,(car type) ,@(mapcar (lambda (x) (normalize-type-int x ar)) (cdr type)))))
	   (if (cdr type)
	       type
	     (case (car type) (and '(t)) (or '(nil)) (not (error "Bad type~%"))))))
	((member (car type) '(type-min type-max)) `(,(car type) ,(normalize-type-int (cadr type) ar)))
	(type)))

(defun normalize-type (tp &optional ar);FIXME
  (normalize-type-int tp ar))

;; CONS

(defun cons-load (ntp type)
  (ntp-ld ntp `(cons (,(nprocess-type (cadr type)) . ,(nprocess-type (caddr type))))))

(defun cons-atm (x)
  (cond ((not x))
	((eq x t))
	((eq x 'proper-cons))
	((eq (car x) 'not) (cons-atm (cadr x)))
	((and (consp x) (eq (car x) 'member)))
	((and (consp x) 
	      (consp (car x)) (listp (caar x)) (= (length (car x)) 3)
	      (consp (cdr x)) (listp (cadr x)) (= (length (cdr x)) 3)))))

(defun ntp-to-nil (ntp)
  (when (or (ntp-tps ntp) (ntp-def ntp))
    ntp))

(defun cons-to-nil (cntp)
  (let* ((at (or (atom cntp) (not (cons-atm cntp)) (eq (car cntp) 'member)))
	 (car (or at (atom (car cntp)) (ntp-to-nil (car cntp))))
	 (cdr (or at (atom (cdr cntp)) (ntp-to-nil (cdr cntp)))))
    (and car cdr cntp)))

(defun cons^ (x y)
  (cond ((eq x t) y)
	((eq y t) x)
	((not (and x y)) nil)
	((and (eq x 'proper-cons) (eq y 'proper-cons)) x)
	((and (eq x 'proper-cons) (eq (car y) 'member))
	 (let ((q (lremove-if-not 'proper-consp (cdr y))))
	   (when q `(member ,@q))))
	((eq x 'proper-cons)
	 (let* ((z '(((non-keyword-symbol (member nil)) (cons proper-cons)) nil nil))
		(cy (copy-tree (cdr y)))
		(ca (ntp-and cy z)))
	   (if (equal z ca) x
	     (cons-to-nil (cons (copy-tree (car y)) ca)))));FIXME
	((eq y 'proper-cons)
	 (cons^ y x))
	((and (eq (car x) 'member) (eq (car y) 'member))
	 (let ((q (ordered-intersection-eq (cdr x) (cdr y))))
	   (when q `(member ,@q))))
	((eq (car x) 'member)
	 (let ((q (lremove-if-not
		   (lambda (x) 
		     (cons^ (cons (ntp-load `(member ,(car x))) 
				  (ntp-load `(member ,(cdr x)))) y)) (cdr x))))
	   (when q `(member ,@q))))
	((eq (car y) 'member) (cons^ y x))
	((and x y)
	 (let ((ax (copy-tree (car x)))
	       (dx (copy-tree (cdr x))))
	   (cons-to-nil
	    (cons (ntp-and ax (car y))
		  (ntp-and dx (cdr y))))))))

;; (defun cons^ (x y)
;;   (cond ((eq x t) y)
;; 	((eq y t) x)
;; 	((not (and x y)) nil)
;; 	((and (eq x 'proper-cons) (eq y 'proper-cons)) x)
;; 	((and (eq x 'proper-cons) (eq (car y) 'member))
;; 	 (let ((q (lremove-if-not 'proper-consp (cdr y))))
;; 	   (when q `(member ,@q))))
;; 	((eq x 'proper-cons)
;; 	 (let* ((z '(((non-keyword-symbol (member nil)) (cons proper-cons)) nil nil))
;; 		(cy (copy-tree (cdr y)))
;; 		(ca (ntp-and cy z)))
;; 	   (if (equal z ca) x
;; 	     (cons-to-nil (cons (copy-tree (car y)) ca)))));FIXME
;; 	((eq y 'proper-cons)
;; 	 (cons^ y x))
;; 	((and (eq (car x) 'member) (eq (car y) 'member))
;; 	 (let ((q (ordered-intersection-eq (cdr x) (cdr y))))
;; 	   (when q `(member ,@q))))
;; 	((eq (car x) 'member)
;; 	 (let ((q (lremove-if-not
;; 		   (lambda (x) 
;; 		     (cons^ (cons (ntp-load `(member ,(car x))) 
;; 				  (ntp-load `(member ,(cdr x)))) y)) (cdr x))))
;; 	   (when q `(member ,@q))))
;; 	((eq (car y) 'member) (cons^ y x))
;; 	((and x y)
;; 	 (let ((ax (copy-tree (car x)))
;; 	       (dx (copy-tree (cdr x))))
;; 	   (cons-to-nil
;; 	    (cons (ntp-and ax (car y))
;; 		  (ntp-and dx (cdr y))))))))

(defun cons-op (op x y &aux (w (cadr x)))
  (setf (cadr x)
	(case op
	      ((and or) (cons-to-nil (sigalg-op op w (cadr y) 'cons^ 'cons-atm)))
	      (not
	       (cond ((not w))
		     ((eq w t) nil)
		     ((eq w 'proper-cons) (negate w))
		     ((eq (car w) 'member) (negate w))
		     ((eq (car w) 'not) (cadr w))
		     ((cons-atm w)
		      (let ((car (ntp-to-nil (ntp-not (copy-tree (car w)))));FIXME
			    (cdr (ntp-to-nil (ntp-not (copy-tree (cdr w))))))
			(cond ((and car cdr) 
			       (cons-to-nil 
				(sigalg-op 'or `(,car . ,(nprocess-type '(t))) 
					   `(,(nprocess-type '(t)) . ,cdr) 'cons^ 'cons-atm)))
			      (car (cons car (nprocess-type '(t))))
			      (cdr (cons (nprocess-type '(t)) cdr)))))
		     (t (reduce (lambda (zx zy) 
				  (cons-to-nil
				   (sigalg-op 
				    (if (eq (car w) 'or) 'and 'or) zx zy 'cons^ 'cons-atm)))
				(mapcar (lambda (x) (cons-op 'not `(cons ,x) nil)) (cdr w))
				:initial-value (eq (car w) 'or))))))))

(defun prune-type (z q i w) ;FIXME optional tail recursion
  (declare (seqind i))
  (cond ((= i (length +array-type-alist+))
	 (setf (cadar q) '*)
	 (ldelete-if (lambda (y) (unless (eq y (car q)) (and (consp y) (eq (car y) 'array)))) z))
	((not w) z)
	((or (atom (car w)) (not (eq (caar w) 'array))) (prune-type z q i (cdr w)))
	((not q) (prune-type z w (1+ i) (cdr w)))
	((equal (caddar w) (caddar q)) (prune-type z q (1+ i) (cdr w)))
	(z)))

(defun nreconstruct-type-int (x)
  (if (ntp-ukn x) t
    (if (ntp-def x)
	(let ((z (nreconstruct-type-int (ntp-not x))))
	  (or (not z) `(not ,z)))
      (let* ((z (lremove-if 
		 'not 
		 (mapcar (lambda (x)
			   (let ((op (cdr (assoc (car x) +kindom-recon-ops-alist+))))
			     (funcall op x))) (ntp-tps x))))
	     (z (prune-type z nil 0 z)))
	(if (cdr z) `(or ,@z) (car z))))))

;; (defun last-cdr-null-p (x)
;;   (cond ((atom x) nil)
;; 	((and (eq (car x) 'cons) (equal (caddr x) '(member nil))) t)
;; 	((eq (car x) 'cons) (last-cdr-null-p (caddr x)))))

(defun cons-recon (x &aux (w (cadr x)))
  (cond ((eq t w) `(cons t t))
	((eq w 'proper-cons) w)
	((atom w) nil)
	((eq (car w) 'member) w)
	((eq (car w) 'not)
	 (let ((r (cons-recon `(cons ,(cadr w))))) 
	   (if (and (consp r) (eq (car r) 'cons))
	       `(not ,r)
	     `(and (cons t t) (not ,r)))))
	((cons-atm w)
	 (let ((car (nreconstruct-type-int (copy-tree (car w))));FIXME
	       (cdr (nreconstruct-type-int (copy-tree (cdr w)))))
	   (and car cdr (if (and (eq car t) 
				 (or (eq cdr 'proper-cons)
				     (equal cdr '(or (member nil) proper-cons))
				     (equal cdr '(or proper-cons (member nil)))));FIXME
			    'proper-cons `(cons ,car ,cdr)))))
	((let* ((z (lremove-if 'not (mapcar (lambda (x) (cons-recon `(cons ,x))) (cdr w)))))
	   (if (cdr z) `(,(car w) ,@z) (car z))))))


(defun nreconstruct-type (x)
  (list (nreconstruct-type-int x) (ntp-ukn x)))


;; (defun copy-type (type res)
;;   (cond ((atom type) (nreverse res))
;; 	((consp (car type)) (copy-type (cdr type) (cons (copy-type (car type) nil) res)))
;; 	((member (car type) '(member eql)) type)
;; 	((copy-type (cdr type) (cons (car type) res)))))

;; (defun expand-proper-cons (tp lt)
;;   (cond ((atom tp))
;; 	((equal (car tp) '(proper-cons)) (setf (car tp) `(or (cons (t) (member nil)) (cons (t) (proper-cons)) ,@lt)))
;; ;	((eq (car tp) 'cons))
;; 	((eq (car tp) 'cons) (expand-proper-cons (cddr tp) lt))
;; 	((and (expand-proper-cons (car tp) lt) (expand-proper-cons (cdr tp) lt)))))

(defun distribute-complex (type)
  (cond ((atom type) type)
	((consp (car type)) (cons (distribute-complex (car type)) (distribute-complex (cdr type))))
	((member (car type) '(and or not)) (cons (car type) (distribute-complex (cdr type))))
	(`(complex ,type))))

(defmacro maybe-eval (x) `(if (and (consp ,x) (eq (car ,x) 'load-time-value)) (eval (cadr ,x)) ,x))

;; (defun proper-cons-tp (tp end)
;;   (cond ((eq (car tp) 'cons) (cons 'cons (list '(t) (proper-cons-tp (caddr tp) end))))
;; 	(end)))

;; (defun cons-to-tp (c)
;;   (cond ((consp c) (cons 'cons (list '(t) (cons-to-tp (cdr c)))))
;; 	(c '(t))
;; 	(`(member nil))))

;; (defun list-types (tp &optional r)
;;   (cond ((atom tp) r)
;; 	((consp (car tp)) (let ((r (list-types (car tp) r))) (list-types (cdr tp) r)))
;; 	((or (eq (car tp) 'member) (eq (car tp) 'eql))
;; 	 (mapc (lambda (x) (when (consp x) (pushnew (cons-to-tp x) r :test 'equal))) (cdr tp))
;; 	 r)
;; 	((eq (car tp) 'cons) 
;; 	 (pushnew (proper-cons-tp tp '(proper-cons)) r :test 'equal)
;; 	 (pushnew (proper-cons-tp tp '(member nil)) r :test 'equal)
;; 	 (list-types (cdr tp) r))
;; 	((list-types (cdr tp) r))))

;;FIXME loose the ar and default to t

;; (let* ((tp )
;; 	 (lt (list-types tp)))
;;     (when lt (expand-proper-cons tp lt))
;;     tp))

(defun resolve-type (type)
  (nreconstruct-type (nprocess-type (normalize-type type t))))

(defun subtypep1 (t1 t2)
  (or (not t1) (eq t2 t)
    (let* ((rt (resolve-type `(and ,t1 ,(negate t2))))
	   (mt (when (cadr rt) (resolve-type `(and (type-max ,t1) ,(negate `(type-min ,t2))))))
	   (rt (when (or (not (cadr rt)) (car mt)) rt)))
      (not (car rt)))))
    
;;       (not (car (resolve-type `(and ,t1 ,(negate t2)))))
;;       (not (car (resolve-type `(and (type-max ,t1) ,(negate `(type-min ,t2))))))))

(defun subtypep (t1 t2 &optional env)
  (declare (ignore env) (optimize (safety 2)))
  (check-type t1 type-spec)
  (check-type t2 type-spec)
  (if (or (not t1) (eq t2 t))
      (values t t)
    (let* ((rt (resolve-type `(and ,t1 ,(negate t2))))
	   (mt (when (cadr rt) (resolve-type `(and (type-max ,t1) ,(negate `(type-min ,t2))))))
	   (rt (if (or (not (cadr rt)) (car mt)) rt `(nil nil))))
      (values (not (car rt))  (not (cadr rt))))))


(defun type-of (object)
  (cond ((not object) 'null)
	((eq object t) 'boolean)
	((keywordp object) 'keyword)
	((symbolp object) 'symbol);;to get around pcl bootstrap problems
	((typep object 'standard-object)
	 (let* ((c (si-class-of object))
		(n (si-class-name c)))
	     (if (and n (eq c (si-find-class n nil))) n c)))
	((let ((tp (type-of-c object)))
	   (cond ((member tp '(vector array));FIXME
		  `(,tp ,(upgraded-array-element-type (array-element-type object))))
		 ((and (symbolp tp) (string= "STD-INSTANCE" (symbol-name tp)) ;FIXME import pcl::std-instance-p
		       (string= "PCL" (package-name (symbol-package tp))))
		  (si-class-of object))
		 (tp))))))

;; (defun typep-int (object type &aux tp i tem)
(defun typep (object type &optional env &aux tem
		     (tp (if (atom type) type (car type)))
		     (i (unless (eq tp type) (cdr type))))
  (declare (ignore env) (optimize (safety 1)))
  ;; (if (atom type)
  ;;     (setq tp type i nil)
  ;;   (setq tp (car type) i (cdr type)))
  (when (and (eq tp 'function) i)
    (error "Bad type to typep: ~S" type))
  (if (eq tp 'structure-object) (setq tp 'structure))
  (when (and (eq tp 'structure) (typep object 'standard-object))
    (return-from typep nil))
  (let ((f (and (not i) (symbolp tp) (get tp 'type-predicate))))
    (when f (return-from typep (when (fboundp f) (let ((z (funcall f object))) (when z t))))))
  (case tp
	(returns-exactly
	 (when i (unless (cdr i) (typep object (car i)))))
	(values
	 (assert (when i (not (cdr i))))
	 (typep object (car i)))
	(cons (and (consp object)
		   (or (not i)
		       (and (typep (car object) (car i))
			    (or (endp (cdr i))
				(typep (cdr object) (cadr i)))))))
	(member (dolist (i i) (when (eql object i) (return t))));(member object i))
	(not (not (typep object (car i))))
	(or
	 (do ((l i (cdr l)))
	     ((null l) nil)
	     (when (typep object (car l)) (return t))))
	(and
	 (do ((l i (cdr l)))
	     ((null l) t)
	     (unless (typep object (car l)) (return nil))))
	(satisfies (when (fboundp (car i)) (let ((z (funcall (car i) object))) (when z t))))
	((t) t)
	((nil) nil)
	(boolean (or (eq object 't) (eq object 'nil)))
	(bignum (let ((tp (type-of-c object))) (dolist (i '(bignum non-negative-bignum negative-bignum)) (when (eql tp i) (return t)))))
	(ratio (eq (type-of-c object) 'ratio))
	((base-char) (characterp object))
	(integer
	 (and (integerp object) (in-interval-p object i)))
	(rational
	 (and (rationalp object) (in-interval-p object i)))
	(real
	 (and (realp object) (in-interval-p object i)))
	(float
	 (and (floatp object) (in-interval-p object i)))
	((short-float)
	 (and (eq (type-of-c object) 'short-float) (in-interval-p object i)))
	((single-float double-float long-float)
	 (and (eq (type-of-c object) 'long-float) (in-interval-p object i)))
	(complex
	 (and (complexp object)
	      (or (null i)
		  (and   (typep (realpart object) (car i))
			 ;;wfs--should only have to check one.
			 ;;Illegal to mix real and imaginary types!
			 (typep (imagpart object) (car i))))))
	(sequence (or (listp object) (vectorp object)))
	((base-string string simple-base-string simple-string) ;FIXME
	 (and (stringp object)
	      (or (endp i) (match-dimensions (array-dimensions object) i))))
	((bit-vector simple-bit-vector)
	 (and (bit-vector-p object)
	      (or (endp i) (match-dimensions (array-dimensions object) i))))
	((vector simple-vector)
	 (and (vectorp object)
	      (let ((at (cond ((eq tp 'simple-vector)) (i (upgraded-array-element-type (car i))) ('*))))
		(or (eq at '*) (eq at (upgraded-array-element-type (array-element-type object)))))
	      (or (not (cdr i)) (match-dimensions (array-dimensions object) (cdr i)))))
	((array simple-array)
	 (and (arrayp object)
	      (let ((at (if i (upgraded-array-element-type (car i)) '*)))
		(or (eq at '*) (eq at (upgraded-array-element-type (array-element-type object)))))
	      (or (not (cdr i)) (eq (cadr i) '*)
		  (if (listp (cadr i))
		      (match-dimensions (array-dimensions object) (cadr i))
		    (eql (array-rank object) (cadr i))))))
	((file-stream string-stream synonym-stream concatenated-stream
		      broadcast-stream two-way-stream echo-stream) (eq (type-of-c object) tp))
	(t (cond 
	    ((if (symbolp tp) (get tp 's-data) (typep tp 's-data))
	     (let ((z (structure-subtype-p object tp))) (when z t)))
	    ((setq tem (when (symbolp tp) (get tp 'deftype-definition)))
	     (typep object (apply tem i)))
	    ((si-classp tp)
	     (subtypep1 (si-class-of object) tp))))))
(putprop 'typep t 'compiler::cmp-notinline);FIXME
;; (defun typep (object type &optional env)
;;   (declare (ignore env) (optimize (safety 2)))
;;   (typep-int object type))
(si::putprop 'typep 'compiler::co1typep 'compiler::co1special);FIXME

;; (defun sequence-type-length-type-int (type)
;;     (case (car type)
;; 	  (cons (do ((i 0 (1+ i)) (x type (caddr type))) 
;; 		    ((not (eq 'cons (car x))) 
;; 		     (cond ((equal x '(member nil)) `(eql ,i))
;; 			   ((not (equal x '(t))) `(eql ,(1+ i)))
;; 			   ('(integer 1)))) (declare (seqind i))))
;; 	  (member (unless (cadr type) `(eql 0)))
;; 	  (array (and (cddr type) (consp (caddr type)) (= (length (caddr type)) 1) (integerp (caaddr type))
;; 		    `(eql ,(caaddr type))))
;; 	  ((or and) (reduce (lambda (&rest xy) (when xy 
;; 						 (and (integerp (car xy)) 
;; 						      (integerp (cadr xy)) 
;; 						      (equal (car xy) (cadr xy)) (car xy))))
;; 			    (mapcar 'sequence-type-length-type-int (cdr type))))))
	  
;; (defun sequence-type-length-type (type)
;;   (cond ((eq type 'null) `(eql 0));;FIXME accelerators
;; 	((eq type 'cons) `(integer 1))
;; 	((consp type) (sequence-type-length-type-int (normalize-type type)))))

;; (defun sequence-type-element-type-int (type)
;;     (case (car type)
;; 	  (cons t)
;; 	  (array (or (not (cdr type)) (upgraded-array-element-type (cadr type))))
;; 	  ((or and) (reduce 
;; 		     (lambda (&rest xy) 
;; 		       (when xy 
;; 			 (cond ((eq (car xy) '*) (cadr xy))
;; 			       ((eq (cadr xy) '*) (car xy))
;; 			       ((eq (car xy) (cadr xy)) (car xy))
;; 			       ('error))))
;; 		     (mapcar 'sequence-type-element-type-int (cdr type))))))
	  
;; (defun sequence-type-element-type (type)
;;   (let* ((type (resolve-type type))
;; 	 (type (unless (cadr type) (car type))))
;;     (let ((x (sequence-type-element-type-int type)))
;;       (or (eq x '*) x))))


;; set by unixport/init_kcl.lsp
;; warn if a file was comopiled in another version
(defvar *gcl-extra-version* nil)
(defvar *gcl-minor-version* nil)
(defvar *gcl-major-version* nil)

(defun warn-version (majvers minvers extvers)
  (and *gcl-major-version* *gcl-minor-version* *gcl-extra-version*
       (or (not (eql extvers *gcl-extra-version*))
	   (not (eql minvers *gcl-minor-version*))
	   (not (eql majvers *gcl-major-version*)))
       *load-verbose*
       (format t "[compiled in GCL ~a.~a.~a] " majvers minvers extvers)))



