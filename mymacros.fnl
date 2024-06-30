;; (local fun (require :fun))

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

;; kind of broken let*, only runs one form.
;; (fn let* [bindings body]
;;   (let [car (fn [lst] (. lst 1))
;;         cdr (fn [lst] (icollect [i v (ipairs lst)] (if (not= 1 i) v)))
;;         empty? (fn [t]
;;                  (if (= nil (next t))
;;                      true
;;                      false))]
;;   (if (empty? bindings)
;;       `(do ,body)
;;       `(let ,(car bindings)
;;             (let* ,(cdr bindings) ,body)))))

;; let* without libs
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

(fn if-let [bindings then-form else-form]
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


{: when-let
 : let*
 : when-let*
 : if-let }

;; (macro letrec [bindings & body]
;;   (let [bindings (table.pack-bindings bindings)]
;;     (let [names (map car bindings)
;;           fns (map (fn [[name _ _ :as b]]
;;                      `(local ,name (fn [,(table.unpack (cdr b))]
;;                                      ,(table.unpack body))))) bindings] 
;;       (do ,(table.unpack fns)))))

