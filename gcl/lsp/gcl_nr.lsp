(in-package :si)


(eval-when
 (compile eval)

 (defmacro defcomp ((fn fn2))
   `(defun ,fn (n1 &optional (n2 n1 n2p) &rest r) 
      (declare (:dynamic-extent r))
      (declare (optimize (safety 1)))
      (check-type n1 ,(if (member fn '(= /=)) 'number 'real))
      (check-type n2 ,(if (member fn '(= /=)) 'number 'real))
      (cond ((not n2p))
	    ((not (,fn2 n1 n2)) nil)
	    ((not r))
	    ((apply ',fn n2 (car r) (cdr r))))))

 (defmacro defpt ((fn fn2) &aux (def (if (eq fn '+) 0 1)))
   `(defun ,fn (&optional (n1 ,def) (n2 ,def) &rest r) 
      (declare (:dynamic-extent r))
      (declare (optimize (safety 1)))
      (check-type n1 number)
      (check-type n2 number)
      (let ((z (,fn2 n1 n2)))
	(if r (apply ',fn z (car r) (cdr r)) z))))

 (defmacro defmm ((fn c))
   `(defun ,fn (n1 &optional (n2 n1) &rest r) 
      (declare (:dynamic-extent r))
      (declare (optimize (safety 1)))
      (check-type n1 real)
      (check-type n2 real)
      (let ((z (if (,c n1 n2) n1 n2)))
	(if r (apply ',fn z (car r) (cdr r)) z))))

 (defmacro defmd ((fn fn2))
   `(defun ,fn (n1 &optional (n2 n1 n2p) &rest r) 
      (declare (:dynamic-extent r))
      (declare (optimize (safety 1)))
      (check-type n1 number)
      (check-type n2 number)
      (let* ((n1 (if n2p n1 ,(if (eq fn '-) 0 1)))
	     (z (,fn2 n1 n2)))
	(if r (apply ',fn z (car r) (cdr r)) z)))))

(defcomp (<  <2))
(defcomp (<= <=2))
(defcomp (=  =2))
(defcomp (/= /=2))
(defcomp (>= >=2))
(defcomp (>  >2))

(defpt (+ number-plus))
(defpt (* number-times))
(defmm (max >=))
(defmm (min <=))

(defmd (- number-minus))
(defmd (/ number-divide))

(labels ((fgcd2 (x y &aux (tx (ctzl x))(ty (ctzl y))(tx (min tx ty)))
		(lgcd2 (>> x tx) (>> y ty) tx (if (oddp x) (- y) (>> x 1))))
	 (lgcd2 (x y tx tt &aux (tt (>> tt (ctzl tt))))
		(if (plusp tt) (setq x tt) (setq y (- tt)))
		(if (= x y) (<< x tx) (lgcd2 x y tx (- x y))))
	 (zgcd2 (x y) (cond ((= x 0) y) ((= y 0) x) ((fgcd2 x y)))))

  (defun gcd (&rest r &aux (s (if (cdr r) r (cons 0 r))))
    (declare (optimize (safety 1))(dynamic-extent r s))
    (labels ((gcd2 (x y &aux (tp `(integer #.(1+ most-negative-fixnum) #.most-positive-fixnum)))
		   (check-type x integer)
		   (check-type y integer)
		   (if (and (typep x tp) (typep y tp))
		       (zgcd2 (abs x) (abs y))
		     (mpz_gcd x y))))
      (reduce #'gcd2 s)))
  
  (defun lcm (&rest r &aux (s (if (cdr r) r (cons 1 r)))) 
    (declare (optimize (safety 1))(dynamic-extent r s))
    (labels ((lcm2 (x y &aux (tp `(integer #.(1+ most-negative-fixnum) #.most-positive-fixnum)))
		   (check-type x integer)
		   (check-type y integer)
		   (if (and (typep x tp) (typep y tp))
		       (let* ((x (abs x))(y (abs y))(g (zgcd2 x y)))
			 (if (= 0 g) g (* x (truncate y g))))
		     (mpz_lcm x y))))
      (reduce #'lcm2 s))))