(defmacro nlet (n letargs &rest body)
  `(labels ((,n ,(mapcar #'car letargs)
	     ,@body))
     (,n ,@(mapcar #'cadr letargs))))

(defmacro when-let1 (bindings &body body)
  "Bind 'bindings' and execute 'body', short-circuiting on 'nil'."
  (let ((symbols (mapcar #'first bindings)))
    `(let ,bindings
       (when (and ,@symbols)
	 ,@body))))

(defmacro when-let* (bindings &body body)
  (if (null bindings)
      `(progn ,@body)
      `(let ((,(first bindings)))
         (when ,@body))))

