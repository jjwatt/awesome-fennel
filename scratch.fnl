;; (macro when-let [bindings &body]
;;   (let [symbols (mapcar (first bindings))]
;;     '(let ,bindings
;;        (when (and ,@symbols)
;;          ,@body))))
;; broken from clojure
;; (macro when-let [bindings & body]
;;   (let [symbol (bindings 0) tst (bindings 1)]
;;   '(let [temp# ,tst]
;;      (when temp#
;;        (let [,symbol temp#]
;;          ,(unpack body))))))

(fn car [lst]
  (. lst 1))
;; (fn map [func lst]
;;   (let [result []]
;;     (each [_ val (ipairs lst)]
;;       (table.insert result (func val)))
;;     result))
(fn map [func lst]
  (icollect [_ val (ipairs lst)]
    (func val)))

(macro when-let1 [bindings & body]
  (let [form (. bindings 1)
        tst (. bindings 2)]
    `(let [temp# ,tst]
       (when temp#
         (let [,form temp#]
           ,(unpack body))))))

;; (macro when-let [bindings & body]
;;   (fn map [func lst]
;;     (icollect [_ val (ipairs lst)]
;;       (func val)))
;;   (fn car [lst]
;;     (. lst 1))
;;   (let [symbols (map car bindings)]
;;     `(let ,bindings
;;        (when (and ,symbols)
;;          ,(table.unpack body)))))

(macro when-let [bindings & body]
  (let [map (fn [func lst] (icollect [_ val (ipairs lst)] (func val)))
        car (fn [lst] (. lst 1))]
    (let [symbols (map car bindings)
          bindtable {}]
        (each [_ v (ipairs bindings)] (each [_ vp (ipairs v)] (table.insert bindtable vp)))
        `(let ,bindtable
           (when (and ,symbols)
             ,(table.unpack body))))))

(macro when1 [condition body ...]
  "Evaluate body for side-effects only when condition is truthy."
  (assert body "expected body")
  `(if ,condition
       (do
         ,body
         ,...)))

(let [t [1 2 3]]
  (table.insert t 2 "a") ; t is now [1 "a" 2 3]
  (print (table.concat t ", "))
  (table.insert t "last") ; now [1 "a" 2 3 "last"]
  (print (table.concat t ", "))  
  (print (table.remove t)) ; prints "last"
  (table.remove t 1) ; t is now ["a" 2 3]
  (print (table.concat t ", "))) 
