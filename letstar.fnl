
(fn let* [bindings body]
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

{: let*}
