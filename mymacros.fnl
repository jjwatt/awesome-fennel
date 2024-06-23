(local fun (require :fun))

(fn when-let [bindings & body]
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

;; same shape as the CL one
;; with fun
;; (macro let* [bindings body]
;;   (let [fun (require :fun)
;;         empty? (fn [t]
;;                  (if (= nil (next t))
;;                      true
;;                      false))]
;;   (if (empty? bindings)
;;       `(do ,(table.unpack body))
;;       `(let ,(fun.car bindings)
;;             (let [newbindings# ,(icollect [_ v (ipairs (fun.cdr bindings))] v)]
;;               (let* newbindings#) ,(table.unpack body))))))

;; without fun
(macro let* [bindings body]
  (let [car (fn [lst] (. lst 1))
        cdr (fn [lst] (icollect [i v (ipairs lst)] (if (not= 1 i) v)))
        empty? (fn [t]
                 (if (= nil (next t))
                     true
                     false))]
  (if (empty? bindings)
      `(do ,body)
      `(let ,(car bindings)
            (let* ,(cdr bindings) ,body)))))

{: when-let}
{: let*}
