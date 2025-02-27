;; trying to rewrite a gnarly piece of lua conversion for awesome
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

(fn make-box [layout lst]
  "Put a layout and a list of widgets into a wibox"
  (let [w lst]
    (tset w :layout layout)
    w))

;; mocks
(let* [[s {}]
       [awful {}]
       [mytaglist :mytaglist]
       [mytasklist :mytasklist]
       [mypromptbox :mypromtpbox]
       [mylayoutbox :mylayoutbox]
       [mylauncher :mylauncher]
       [mytextclock :mytextclock]
       [wibox {}]
       [wiboxwidget {}]
       [systray :systray]
       [wiboxlayoutfixedhorizontal :fixed-horizontal]]
      (set s.mytaglist mytaglist)
      (set s.mytasklist mytasklist)
      (set s.mylayoutbox mylayoutbox)
      (set s.mypromptbox mypromptbox)
      (set wibox.widget wiboxwidget)
      (set wibox.widget.systray systray)
      (set wibox.layout {})
      (set wibox.layout.fixed {})
      (set wibox.layout.fixed.horizontal :fixed-horizontal)
      (set wibox.layout.align {})
      (set wibox.layout.align.horizontal :align-horizontal)
      (set awful.wibar :awful.wibar)
      (let [megawidget
            (make-box
             wibox.layout.align.horizontal
             (let [leftwidgets (make-box
                                wibox.layout.fixed.horizontal
                                [mylauncher s.mytaglist s.mypromptbox])
                   middlewidget s.mytasklist
                   rightwidgets (make-box
                                 wibox.layout.fixed.horizontal
                                 [wibox.widget.systray mytextclock s.mylayoutbox])]
               [leftwidgets middlewidget rightwidgets]))]
        (set s.mywibox
             [awful.wibar
              {:position :top
               :screen :s
               :widget megawidget}]) s))
