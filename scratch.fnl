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

;; (fn map [func lst]
;;   (let [result []]
;;     (each [_ val (ipairs lst)]
;;       (table.insert result (func val)))
;;     result))
(fn table-insert [tab val]
  (var t tab)
  (table.insert t val)
  t)
(fn table-remove [tab indx]
  (var t tab)
  (table.remove t indx)
  t)

(fn car [lst]
  (. lst 1))
(fn cdr [lst]
  (icollect [i v (ipairs lst)] (if (not= 1 i) v)))
;; (fn cons [a lst]
;;   (let [newtab {}]
;;     (do (table.insert newtab a)
;;         (if (not (empty? lst))
;;             (table.insert newtab (car lst))
;;             (cons (cdr lst))))
;;     newtab))
(fn cons [head tail]
  [head (table.unpack tail)])

(fn map [func lst]
  (icollect [_ val (ipairs lst)]
    (func val)))

;; map with table.insert
(fn map2 [f lst]
  (let [result []]
    (each [i (ipairs lst)]
      (table.insert result (f i)))
    result))
(fn cadr [lst]
  (car (cdr lst)))
(fn caadr [lst]
  (car (car (cdr lst))))
(fn caddr [lst]
  (car (cdr (cdr lst))))
(fn inc [n]
  (+ n 1))
(fn dec [n]
  (- n 1))
(fn empty? [t]
             (if (= nil (next t))
                 true
                 false))

(fn atom? [t]
  (not= (type t) "table"))

(fn pair? [t]
  (case t
    [a b] true
    _ false))

(fn iota [amount]
  (var counter 1)
  (let [t []]
    (while (<= counter amount)
      (tset t counter counter)
      (set counter (inc counter)))
    t))

;; (macro when-let1 [bindings & body]
;;   (let [form (. bindings 1)
;;         tst (. bindings 2)]
;;     `(let [temp# ,tst]
;;        (when temp#
;;          (let [,form temp#]
;;            ,(unpack body))))))

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
  "Bind `bindings` and execute `body`, short-circuiting on `nil`.

  This macro combines `when` and `let`.  It takes a list of bindings
  and binds them like `let` before executing `body`, but if any
  binding's value evaluates to `nil`, then `nil` is returned.

  Examples:

  > (when-let [[a 1]
               [b 2]]
      (print a b))
   1        2
   >>
  > (when-let [[a nil]
               [b 2])
      (print a b))
    nil
    >>
"
  (let [map (fn [func lst]
              (icollect [_ val (ipairs lst)]
                (func val)))
        car (fn [lst] (. lst 1))]
    (let [symbols (map car bindings)
          bindtable {}]
      (each [_ v (ipairs bindings)]
        (each [_ innerv (ipairs v)] (table.insert bindtable innerv)))
      `(let ,bindtable
         (when (and ,(table.unpack symbols))
           ,(table.unpack body))))))

(macro when1 [condition body ...]
  "Evaluate body for side-effects only when condition is truthy."
  (assert body "expected body")
  `(if ,condition
       (do
         ,body
         ,...)))

;; let*
(macro let* [bindings body & rest]
  (let [car (fn [lst] (. lst 1))
        cdr (fn [lst] (icollect [i v (ipairs lst)] (if (not= 1 i) v)))
        empty? (fn [t]
                 (if (= nil (next t))
                     true
                     false))]
  (if (empty? bindings)
      `(do ,body ,(table.unpack rest))
      `(let ,(car bindings)
            (let* ,(cdr bindings) ,body ,rest)))))

;; when-let*
(macro when-let* [bindings conditional body]
  (let [empty? #(if (= nil (next $)) true false)
        car #(. $ 1)
        cdr (fn [lst] (icollect [i v (ipairs lst)] (if (not= 1 i) v)))]
    (if (empty? bindings)
        `(when ,conditional ,body)
        `(let ,(car bindings)
              (when ,(car (car bindings))
                    (when-let* ,(cdr bindings) ,conditional ,body))))))

;; (macrodebug (when-let* [[x 1] [y 2]] (> y x) "ok"))
;; (when-let* [[x 1] [y 2]] (> y x) "ok")

;; (macro if-let [bindings then-form else-form]
;;   (match bindings
;;     [[k v] ...]
;;     `(if (and [k v ...] nil) ,then-form ,else-form)
;;     :else
;;     `(error "if-let requires an even number of bindings")))
;; (macro if-let [bindings then-form else-form]
;;   (let [atomp (fn [t] (not= (type t) :table))
;;         car (fn [l] (. l 1))
;;         map (fn [func l]
;;                (icollect [_ val (ipairs l)]
;;                  (func val)))]
;;     `(let ,bindings
;;        (if (and ,bindings)
;;            ,then-form
;;            ,else-form))))

(macro if-let [bindings then-form else-form]
  (let [map (fn [func lst]
              (icollect [_ val (ipairs lst)]
                (func val)))
        car (fn [lst] (. lst 1))]
    (let [symbols (map car bindings)
          bindtable {}]
      (each [_ v (ipairs bindings)]
        (each [_ innerv (ipairs v)] (table.insert bindtable innerv)))
      `(let ,bindtable
         (if (and ,(table.unpack symbols))
             ,then-form
             ,else-form)))))

;; (macro named-let [name bindings & body]
;;   `(let [,name (fn ,bindings ,(table.unpack body))]
;;      ,name))
;; (fn nlet-fact (n)
;;   (named-let fact [n n]
;;              (if (= 0 n)) 1 (* n (fact (- n 1)))))

;; (macro named-let [name bindings & body]
;;   (let [map (fn [func lst]
;;               (icollect [_ val (ipairs lst)]
;;                 (func val)))]
;;     (let [params (map (fn [x] (. x 1)) bindings)
;;           args (map (fn [binding] (. binding 2)) bindings)]
;;       (list `let [[name (fn params body)]]
;;             (list name (unpack args))))))

;; (named-let fact [[n 5] [acc 1]]
;;            (if (= n 0)
;;                acc
;;                (fact (- n 1) (* acc n))))

;; not working (I don't think)
;; (macro letrec [bindings body & rest]
;;   (let [car #(. $ 1)]
;;     ((lambda []
;;        `(letrec [(car bindings)
;;                  (fn [,(table.unpack (cdr bindings))]
;;                    ,body ...)]
;;                 (let ,(table.unpack rest)))))))

;;(cons infinite (jes)) => (infinite jes)

;; {: when-let}
;; {: if-let}
;; {: let*}
;; {: when1}

;; (let [t [1 2 3]]
;;   (table.insert t 2 "a") ; t is now [1 "a" 2 3]
;;   (print (table.concat t ", "))
;;   (table.insert t "last") ; now [1 "a" 2 3 "last"]
;;   (print (table.concat t ", "))  
;;   (print (table.remove t)) ; prints "last"
;;   (table.remove t 1) ; t is now ["a" 2 3]
;;   (print (table.concat t ", "))) 
