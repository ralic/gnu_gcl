(defun fix-struct-ref ()
  (interactive)
  (while (re-search-forward "->\\([a-z]+\\)+[.]\\([A-Z][a-zA-Z]+\\)")
    (sit-for 0)
    (cond ((y-or-n-p "do it?")
	   (downcase-region (match-beginning 2) (match-end 2))
	   (let ((xx (buffer-substring  (match-beginning 2) (match-end 2)))
		 (tem (buffer-substring (match-beginning 1) (match-end 1))))
	     (delete-region (match-beginning 2) (match-end 2))
	     (goto-char (match-beginning 2))
	     (insert tem "_")
	     (let ((u (assoc xx '(("bind" . "dbind")
				  ("body" . "self")
				  ))))
	       (insert (or (cdr u) xx))))))))
    
  
