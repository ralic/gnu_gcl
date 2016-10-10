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


;;;;   iolib.lsp
;;;;
;;;;        The IO library.


(in-package :si)

(proclaim '(optimize (safety 2) (space 3)))

(defun concatenated-stream-streams (stream)
  (declare (optimize (safety 2)))
  (check-type stream concatenated-stream)
  (c-stream-object0 stream))
(defun broadcast-stream-streams (stream)
  (declare (optimize (safety 2)))
  (check-type stream broadcast-stream)
  (c-stream-object0 stream))
(defun two-way-stream-input-stream (stream)
  (declare (optimize (safety 2)))
  (check-type stream two-way-stream)
  (c-stream-object0 stream))
(defun echo-stream-input-stream (stream)
  (declare (optimize (safety 2)))
  (check-type stream echo-stream)
  (c-stream-object0 stream))
(defun two-way-stream-output-stream (stream)
  (declare (optimize (safety 2)))
  (check-type stream two-way-stream)
  (c-stream-object1 stream))
(defun echo-stream-output-stream (stream)
  (declare (optimize (safety 2)))
  (check-type stream echo-stream)
  (c-stream-object1 stream))
(defun synonym-stream-symbol (stream)
  (declare (optimize (safety 2)))
  (check-type stream synonym-stream)
  (c-stream-object0 stream))

(defmacro with-open-stream ((var stream) . body)
  (multiple-value-bind (ds b)
      (find-declarations body)
    `(let ((,var ,stream))
       ,@ds
       (unwind-protect
         (progn ,@b)
         (close ,var)))))


(defmacro with-input-from-string ((var string &key index start end) . body)
  (let ((x (sgen "X")))
    (multiple-value-bind (ds b)
	(find-declarations body)
      `(let ((,var (make-string-input-stream ,string ,start ,end)))
	 ,@ds
	 (unwind-protect
	     ,(let ((f `(progn ,@b)))
		(if index
		    `(let ((,x (multiple-value-list ,f))) (setf ,index (get-string-input-stream-index ,var)) (values-list ,x))
		  f))
	 (close ,var))))))
  
(defmacro with-output-to-string ((var &optional string &key element-type) . body)
  (let ((s (sgen "STRING"))(bl (sgen "BLOCK"))(e (sgen "ELEMENT-TYPE"))(x (sgen "X")))
    (multiple-value-bind (ds b)
	(find-declarations body)
      `(let* ((,s ,string)(,e ,element-type)
	      (,var (if ,s (make-string-output-stream-from-string ,s) (make-string-output-stream :element-type ,e))))
	 ,@ds
	 (unwind-protect
	     (let ((,x (multiple-value-list (progn ,@b)))) (if ,s (values-list ,x) (get-output-stream-string ,var)))
	   (close ,var))))))


(defun read-from-string (string
                         &optional (eof-error-p t) eof-value
                         &key (start 0) (end (length string))
                              preserve-whitespace)
  (let ((stream (make-string-input-stream string start end)))
    (if preserve-whitespace
        (values (read-preserving-whitespace stream eof-error-p eof-value)
                (si:get-string-input-stream-index stream))
        (values (read stream eof-error-p eof-value)
                (si:get-string-input-stream-index stream)))))


(defun write-to-string (object &rest rest
                        &key escape radix base
                             circle pretty level length
                             case gensym array
                        &aux (stream (make-string-output-stream)))
  (declare (ignore escape radix base
                   circle pretty level length
                   case gensym array))
  (apply #'write object :stream stream rest)
  (get-output-stream-string stream))


(defun prin1-to-string (object
                        &aux (stream (make-string-output-stream)))
   (prin1 object stream)
   (get-output-stream-string stream))


(defun princ-to-string (object
                        &aux (stream (make-string-output-stream)))
  (princ object stream)
  (get-output-stream-string stream))


(defmacro with-open-file ((stream . filespec) . body)
  (multiple-value-bind (ds b)
      (find-declarations body)
    `(let ((,stream (open ,@filespec)))
       ,@ds
       (unwind-protect
         (progn ,@b)
         (if ,stream (close ,stream))))))


(defun y-or-n-p (&optional string &rest args)
  (do ((reply))
      (nil)
    (when string (format *query-io* "~&~?  (Y or N) " string args))
    (setq reply (read *query-io*))
    (cond ((string-equal (symbol-name reply) "Y")
           (return-from y-or-n-p t))
          ((string-equal (symbol-name reply) "N")
           (return-from y-or-n-p nil)))))


(defun yes-or-no-p (&optional string &rest args)
  (do ((reply))
      (nil)
    (when string (format *query-io* "~&~?  (Yes or No) " string args))
    (setq reply (read *query-io*))
    (cond ((string-equal (symbol-name reply) "YES")
           (return-from yes-or-no-p t))
          ((string-equal (symbol-name reply) "NO")
           (return-from yes-or-no-p nil)))))


(defun sharp-a-reader (stream subchar arg)
  (declare (ignore subchar))
  (let ((initial-contents (read stream nil nil t)))
    (if *read-suppress*
        nil
        (do ((i 0 (1+ i))
             (d nil (cons (length ic) d))
             (ic initial-contents (if (zerop (length ic)) ic (elt ic 0))))
            ((>= i arg)
             (make-array (nreverse d)
                         :initial-contents initial-contents))))))

(set-dispatch-macro-character #\# #\a 'sharp-a-reader)
(set-dispatch-macro-character #\# #\A 'sharp-a-reader)

;; defined in defstruct.lsp
(set-dispatch-macro-character #\# #\s 'sharp-s-reader)
(set-dispatch-macro-character #\# #\S 'sharp-s-reader)

(defvar *dribble-stream* nil)
(defvar *dribble-io* nil)
(defvar *dribble-namestring* nil)
(defvar *dribble-saved-terminal-io* nil)

(defun dribble (&optional (pathname "DRIBBLE.LOG" psp) (f :supersede))
  (cond ((not psp)
         (when (null *dribble-stream*) (error "Not in dribble."))
         (if (eq *dribble-io* *terminal-io*)
             (setq *terminal-io* *dribble-saved-terminal-io*)
             (warn "*TERMINAL-IO* was rebound while DRIBBLE is on.~%~
                   You may miss some dribble output."))
         (close *dribble-stream*)
         (setq *dribble-stream* nil)
         (format t "~&Finished dribbling to ~A." *dribble-namestring*))
        (*dribble-stream*
         (error "Already in dribble (to ~A)." *dribble-namestring*))
        (t
         (let* ((namestring (namestring pathname))
                (stream (open pathname :direction :output
                                       :if-exists f
                                       :if-does-not-exist :create)))
           (setq *dribble-namestring* namestring
                 *dribble-stream* stream
                 *dribble-saved-terminal-io* *terminal-io*
                 *dribble-io* (make-two-way-stream
                               (make-echo-stream *terminal-io* stream)
                               (make-broadcast-stream *terminal-io* stream))
                 *terminal-io* *dribble-io*)
           (multiple-value-bind (sec min hour day month year)
               (get-decoded-time)
             (format t "~&Starts dribbling to ~A (~d/~d/~d, ~d:~d:~d)."
                     namestring year month day hour min sec))))))

(defconstant char-length 8)

(defun get-byte-stream-nchars (s)
  (check-type s stream)
  (let* ((tp (stream-element-type s))
	 (tp (if (consp tp) (cadr tp) char-length))
	 (nc (ceiling tp char-length)))
    nc))

(defun write-byte (j s)
  (declare (optimize (safety 1)))
  (let ((nc (get-byte-stream-nchars s))
	(ff (1- (expt 2 char-length))))
    (do ((k 0 (1+ k))(i j (ash i (- char-length)))) ((>= k nc) j)
	(write-char (code-char (logand i ff)) s))))

(defun read-byte (s &optional (eof-error-p t) eof-value)
  (declare (optimize (safety 1)))
  (let ((nc (get-byte-stream-nchars s)))
    (do ((j 0 (1+ j)) 
	 (i 0 (logior i
	       (ash (char-code (let ((ch (read-char s eof-error-p eof-value)))
				 (if (and (not eof-error-p) (eq ch eof-value))
				     (return-from read-byte ch)
				   ch))) (* j char-length)))))
	((>= j nc) i))))


(defun read-sequence (seq strm &key (start 0) end)
  (declare (optimize (safety 1)))
  (check-type seq sequence)
  (check-type start (integer 0))
  (check-type end (or null (integer 0)))
  (let* ((start (min start array-dimension-limit))
	 (end   (if end (min end array-dimension-limit) (length seq)))
	 (l (listp seq))
	 (seq (if (and l (> start 0)) (nthcdr start seq) seq))
	 (tp (subtypep (stream-element-type strm) 'character)))
    (do ((i start (1+ i))(seq seq (if l (cdr seq) seq)))
	((or (>= i end) (when l (endp seq))) i)
	(declare (fixnum i))
	(let ((el (if tp (read-char strm nil 'eof) (read-byte strm nil 'eof))))
	  (when (eq el 'eof) (return i))
	  (if l (setf (car seq) el) (setf (aref seq i) el))))))


(defun write-sequence (seq strm &key (start 0) end)
  (declare (optimize (safety 1)))
  (check-type seq sequence)
  (check-type start (integer 0))
  (check-type end (or null (integer 0)))
  (let* ((start (min start array-dimension-limit))
	 (end   (if end (min end array-dimension-limit) (length seq)))
	 (l (listp seq))
	 (tp (subtypep (stream-element-type strm) 'character)))
    (do ((i start (1+ i))
	 (seq (if (and l (> start 0)) (nthcdr start seq) seq) (if l (cdr seq) seq))) 
	((or (>= i end) (when l (endp seq)))) 
	(declare (fixnum i))
	(let ((el (if l (car seq) (aref seq i))))
	  (if tp (write-char el strm) (write-byte el strm))))
    seq))

(defmacro with-compilation-unit (opt &rest body)   
  (declare (optimize (safety 2)))
  (declare (ignore opt)) 
  `(progn ,@body))

(defvar *print-lines* nil)
(defvar *print-miser-width* nil)
(defvar *print-pprint-dispatch* nil)
(defvar *print-right-margin* nil)

(defmacro with-standard-io-syntax (&body body)
  (declare (optimize (safety 2)))
  `(let* ((*package* (find-package :cl-user))
	  (*print-array* t)
	  (*print-base* 10)
	  (*print-case* :upcase)
	  (*print-circle* nil)
	  (*print-escape* t)
	  (*print-gensym* t)
	  (*print-length* nil)
	  (*print-level* nil)
	  (*print-lines* nil)
	  (*print-miser-width* nil)
	  (*print-pprint-dispatch* *print-pprint-dispatch*)
	  (*print-pretty* nil)
	  (*print-radix* nil)
	  (*print-readably* t)
	  (*print-right-margin* nil)
	  (*read-base* 10)
	  (*read-default-float-format* 'single-float)
	  (*read-eval* t)
	  (*read-suppress* nil)
	  (*readtable* (copy-readtable (si::standard-readtable))));FIXME copy?
     ,@body))

(defun ensure-directories-exist (ps &key verbose &aux created)
  (declare (optimize (safety 1)))
  (check-type ps pathname-designator)
  (when (wild-pathname-p ps)
    (error 'file-error :pathname ps :format-control "Pathname is wild"))
  (labels ((d (x y &aux (z (ldiff x y)) (n (namestring (make-pathname :directory z))))
	      (when (when z (stringp (car (last z))))
		(unless (eq :directory (stat n))
		  (mkdir n)
		  (setq created t)
		  (when verbose (format *standard-output* "Creating directory ~s~%" n))))
	      (when y (d x (cdr y)))))
    (let ((pd (pathname-directory ps)))
      (d pd (cdr pd)))
    (values ps created)))

(defun maybe-clear-input (&optional (x *standard-input*))
  (cond ((not (typep x 'stream)) nil)
	((typep x 'synonym-stream) (maybe-clear-input (symbol-value (synonym-stream-symbol x))))
	((typep x 'two-way-stream) (maybe-clear-input (two-way-stream-input-stream x)))
	((terminal-input-stream-p x) (clear-input t))))

(defun restrict-stream-element-type (tp)
  (cond ((member tp '(unsigned-byte signed-byte)) tp)
	((or (member tp '(character :default)) (si::subtypep1 tp 'character)) 'character)
	((si::subtypep1 tp 'integer)
	 (let* ((ntp (car (expand-ranges (cmp-norm-tp tp))))
		(min (cadr ntp))(max (caddr ntp))
		(s (if (or (eq min '*) (< min 0)) 'signed-byte 'unsigned-byte))
		(lim (unless (or (eq min '*) (eq max '*)) (max (integer-length min) (integer-length max))))
		(lim (if (and lim (eq s 'signed-byte)) (1+ lim) lim)))
	   (if lim `(,s ,lim) s)))
	((check-type tp (member character integer)))))

(defun open (f &key (direction :input)
	       (element-type 'character)
	       (if-exists nil iesp)
	       (if-does-not-exist nil idnesp)
	       (external-format :default) &aux (pf (pathname f)))
  (declare (optimize (safety 1)))
  (check-type f pathname-designator)
  (when (wild-pathname-p pf)
    (error 'file-error :pathname pf :format-control "Pathname is wild."))
  (let* ((s (open-int (namestring (translate-logical-pathname pf)) direction
		      (restrict-stream-element-type element-type)
		      if-exists iesp if-does-not-exist idnesp external-format)))
    (when (typep s 'stream) (c-set-stream-object1 s pf) s)))

(defun load-pathname (p print if-does-not-exist
			&aux (pp (merge-pathnames p))
			(epp (reduce (lambda (y x) (or y (probe-file (translate-pathname x "" p))))
				     '(#P".o" #P".lsp" #P".lisp" #P"") :initial-value nil)));FIXME newest?
  (if epp
      (let* ((*load-pathname* pp)(*load-truename* epp))
	(with-open-file
	 (s epp)
	 (if (member (peek-char nil s nil 'eof) '#.(mapcar 'code-char (list 127 #xfe #xff #x4c)))
	     (load-fasl s print)
	   (load-stream s print))))
    (when if-does-not-exist
      (error 'file-error :pathname pp :format-control "File does not exist."))))

(defun load (p &key (verbose *load-verbose*) (print *load-print*) (if-does-not-exist :error)
	       (external-format :default) &aux (*readtable* *readtable*)(*package* *package*))
  (declare (optimize (safety 1))(ignorable external-format))
  (check-type p (or stream pathname-designator))
  (when verbose (format t ";; Loading ~s~%" p))
  (prog1
      (typecase p
	(pathname-designator (load-pathname (pathname p) print if-does-not-exist))
	(stream (load-stream p print)))
    (when verbose (format t ";; Finished loading ~s~%" p))))

(defun ensure-directories-exist (ps &key verbose &aux created)
  (declare (optimize (safety 1)))
  (check-type ps pathname-designator)
  (when (wild-pathname-p ps)
    (error 'file-error :pathname ps :format-control "Pathname is wild"))
  (labels ((d (x y &aux (z (ldiff x y)) (n (namestring (make-pathname :directory z))))
	      (when (when z (stringp (car (last z))))
		(unless (eq :directory (stat n))
		  (mkdir n)
		  (setq created t)
		  (when verbose (format *standard-output* "Creating directory ~s~%" n))))
	      (when y (d x (cdr y)))))
    (let ((pd (pathname-directory ps)))
      (d pd (cdr pd)))
    (values ps created)))

