(defmacro nlet (n letargs &rest body)
  `(labels ((,n ,(mapcar #'car letargs)
	     ,@body))
     (,n ,@(mapcar #'cadr letargs))))

(defmacro when-let (bindings &body body)
  "Bind 'bindings' and execute 'body', short-circuiting on 'nil'."
  (let ((symbols (mapcar #'first bindings)))
    `(let ,bindings
       (when (and ,@symbols)
	 ,@body))))
