(local fun (require "fun"))
(local gears (require "gears"))
(local awful (require "awful"))
(require "awful.autofocus")
(local naughty (require "naughty"))

(macros
  {:with-selected-tag (fn [name body1 ...]
                     `(let [,name (. mouse.screen :selected_tag)]
                        (when ,name
                          ,body1
                          ,...)))})

(local focus-colors
  ; from https://colorhunt.co/palette/136945
  ["#cd4545" "#f3a333" "#f16821" "#fffe9a"]
  )

(local background-color "#110022")
(local unfocus-color background-color)
(local focus-border-width 2)

; Tools

(fn notify
  [text]
  (naughty.notify {:text text}))

(fn ndebug
  [x]
  (notify (gears.debug.dump_return x)))

(fn merge
  [t kvs]
  (fun.reduce #(doto $1 (tset $2 $3)) t kvs))

(fn cinv
  [k]
  (fn [c]
    (let [v (. c k)]
      (tset c k (not v)))))

(local modifiers {:mod   "Mod4"
                  :shift "Shift"
                  :ctrl  "Control"})

(fn map-mods
  [mods]
  (->> mods
       (fun.map (partial . modifiers))
       (fun.totable)))

(fn key
  [mods key-code fun]
  (awful.key (map-mods mods) key-code fun))

(fn btn
  [mods btn-code fun]
  (awful.button (map-mods mods) btn-code fun))

(fn invert-screen
  [invert?]
  (os.execute "xcalib -c -a") ; clear
  (when invert?
    (os.execute "xcalib -i -a")))

(fn get-load
  []
  (with-open [f (io.open "/proc/loadavg")]
    (tonumber
      (pick-values 1
                   (string.gsub (f:read) " .*" "")))))

(fn show-load
  [rgb ld]
  (naughty.notify {:text (tostring ld)
                   :bg rgb
                   :timeout 1
                   :border_color "#FFFFFF"
                   :fg "#FFFFFF"}))

(fn notify-load
  []
  (let [ld (get-load)]
    (if (>= ld 8) (show-load "#7f0000" ld)
        (>= ld 6) (show-load "#7f7f00" ld)
        (>= ld 4) (show-load "#007f00" ld)
        (>= ld 2) (show-load "#007f7f" ld)
        (>= ld 1) (show-load "#00007f" ld)
        nil)))

; Tag managment

(fn set-client-colspan
  [colspan c]
  (tset c :colspan colspan)
  (awful.layout.arrange c.screen))

(fn client-colspan
  [c]
  (or (. c :colspan) 1))

; each client gets an equal share over the width of workarea
(local layout-columns
  {:name
   "columns"
   :arrange
   (fn [p]
     (let [t (or p.tag (. screen p.screen :selected_tag))
           wa p.workarea
           cs p.clients]
       (when (< 0 (length cs))
         (let [client-steps (fun.map (fn [c] [(client-colspan c) c]) cs)
               client-step-count (fun.reduce (fn [x [y]] (+ x y)) 0 client-steps)
               col-width (math.floor (/ wa.width client-step-count))]
           (fun.reduce (fn [w [colspan c]]
                         (let [client-width (* col-width colspan)]
                           (tset p :geometries c {:x (+ wa.x w)
                                                  :y wa.y
                                                  :width client-width
                                                  :height wa.height})
                           (+ w client-width)))
                       0
                       client-steps)))))})

(local layouts [
                layout-columns
                awful.layout.suit.fair
                awful.layout.suit.tile
                awful.layout.suit.max.fullscreen])

(local tags {})

(var current-tag-pos [0 0])

(fn set-tag-pos
  [tag [x y]]
  (merge tag {:x-pos x
              :y-pos y}))

(fn get-tag-pos
  [tag]
  [(. tag :x-pos) (. tag :y-pos)])

(fn translate-pos
  [[x y] [off-x off-y]]
  [(+ x off-x) (+ y off-y)])

(fn tag-name
  [[x y]]
  (.. "(" x " " y ")"))

(fn get-or-create-tag
  [pos]
  (let [tn (tag-name pos)]
    (when (not (. tags tn))
      (let [[tag] (awful.tag [tn] mouse.screen (. layouts 1))]
        (tset tags tn tag)
        (set-tag-pos tag pos)))
    (. tags tn)))

(fn current-tag
  []
  (get-or-create-tag current-tag-pos))

(fn view-only
  [tag]
  (: tag :view_only))

(fn view-current-tag
  []
  (view-only (current-tag)))

(local view-all-tag-name "view-all")

(local view-all-tag
  (. (awful.tag [view-all-tag-name] mouse.screen awful.layout.suit.fair) 1))

(fn view-all-tags
  []
  (view-only view-all-tag))

(fn select-tag-by-focused-client
  [c]
  (->> (c:tags)
       (fun.filter (partial not= view-all-tag))
       (fun.each #(set current-tag-pos (get-tag-pos $1))))
  (view-current-tag))

(fn select-current-tag-by-offset
  [off]
  (with-selected-tag tag
    (set current-tag-pos (get-tag-pos tag)))
  (set current-tag-pos (translate-pos current-tag-pos off))
  (view-current-tag))

(fn move-client-relative
  [off c]
  (c:tags [(get-or-create-tag (translate-pos current-tag-pos off)) view-all-tag]))

(fn move-client-relative-and-select
  [off c]
  (move-client-relative off c)
  (select-current-tag-by-offset off))

(fn move-all-clients-relative-and-select
  [off]
  (fun.each (partial move-client-relative off)
            (awful.client.visible))
  (select-current-tag-by-offset off))

(fn focus-client-by-offset
  [off]
  (awful.client.focus.byidx off)
  (when client.focus
    (client.focus:raise)))

(fn is-inverted?
  [t]
  (if (. t :inverted?) true false))

(fn set-inverted
  [t inverted?]
  (tset t :inverted? inverted?)
  (invert-screen inverted?))

(fn toggle-invert-screen
  []
  (with-selected-tag t
    (let [inverted? (not (is-inverted? t))]
      (set-inverted t inverted?))))

(fn focus-client
  [c]
  (when c
    (let [focus-color (. c :focus_color)]
      ; focus (e.g. from rules) is applied before arrange and the client might not yet have a color
      (when focus-color
        (tset c :border_color focus-color)))))

(fn un-focus-client [c]
  (tset c :border_color unfocus-color))

(fn arrange-tag
  [screen]
  ; focus from history
  (when (not client.focus)
    (let [c (awful.client.focus.history.get screen 0)]
      (when c
        (tset client :focus c))))
  ; set a border width, if there is more than one client on the tag
  (let [cs (awful.client.visible screen)
        bw (if (> (length cs) 1) focus-border-width 0)]
    (fun.each
      (fn [c focus-color]
        (merge c {:border_width bw
                  :focus_color focus-color}))
      (fun.zip cs (fun.cycle focus-colors))))
  ; set focus color for current client (focus event is before arrange and the colors are not there yet)
  (let [c (. client :focus)]
    (focus-client c))
  ; set inverted screen state from tag
  (notify-load)
  (with-selected-tag t
    (invert-screen (is-inverted? t))))

(fn unminimize-tag
  [tag]
  (fun.each (fn [client]
              (tset client :minimized false)
              (client:redraw))
            (tag:clients)))

;;; Main Config

(local global-keys
       (gears.table.join
         (key [:mod :shift :ctrl] "Escape"    awesome.restart)
         (key [:mod :shift      ] "a"         view-all-tags)
         (key [:mod :shift      ] "w"         #(notify (tag-name current-tag-pos)))
         (key [:mod :shift      ] "i"         toggle-invert-screen)
         (key [:mod             ] "h"         #(select-current-tag-by-offset [-1  0]))
         (key [:mod             ] "l"         #(select-current-tag-by-offset [ 1  0]))
         (key [:mod             ] "k"         #(select-current-tag-by-offset [ 0 -1]))
         (key [:mod             ] "j"         #(select-current-tag-by-offset [ 0  1]))
         (key [:mod        :ctrl] "h"         #(move-all-clients-relative-and-select [-1  0]))
         (key [:mod        :ctrl] "l"         #(move-all-clients-relative-and-select [ 1  0]))
         (key [:mod        :ctrl] "k"         #(move-all-clients-relative-and-select [ 0 -1]))
         (key [:mod        :ctrl] "j"         #(move-all-clients-relative-and-select [ 0  1]))
         (key [:mod             ] "space"     #(awful.client.focus.history.previous))
         (key [:mod        :ctrl] "space"     #(awful.layout.inc layouts  1))
         (key [:mod :shift :ctrl] "space"     #(awful.layout.inc layouts -1))
         (key [:mod             ] "Tab"       #(focus-client-by-offset  1))
         (key [:mod :shift      ] "Tab"       #(focus-client-by-offset -1))
         (key [:mod        :ctrl] "Tab"       #(awful.client.swap.byidx  1))
         (key [:mod :shift :ctrl] "Tab"       #(awful.client.swap.byidx -1))
         (key [:mod :shift      ] "BackSpace" #(unminimize-tag (awful.tag.selected)))
         ))

(local client-keys
       (gears.table.join
         (key [:mod             ] "Escape" (fn [c] (c:kill)))
         (key [:mod             ] "1"      (partial set-client-colspan 1))
         (key [:mod             ] "2"      (partial set-client-colspan 2))
         (key [:mod             ] "3"      (partial set-client-colspan 3))
         (key [:mod             ] "a"      select-tag-by-focused-client)
         (key [:mod :shift      ] "f"      (cinv :focusable))
         (key [:mod :shift      ] "o"      (cinv :floating))
         (key [:mod :shift      ] "s"      (cinv :sticky))
         (key [:mod :shift      ] "x"      (cinv :maximized_horizontal))
         (key [:mod :shift      ] "y"      (cinv :maximized_vertical))
         (key [:mod :shift      ] "m"      (cinv :maximized))
         (key [:mod :shift      ] "h"      (partial move-client-relative-and-select [-1  0]))
         (key [:mod :shift      ] "l"      (partial move-client-relative-and-select [ 1  0]))
         (key [:mod :shift      ] "k"      (partial move-client-relative-and-select [ 0 -1]))
         (key [:mod :shift      ] "j"      (partial move-client-relative-and-select [ 0  1]))
         ))

(local client-buttons
       (gears.table.join
         (btn [:mod] 1 awful.mouse.client.move)
         (btn [:mod] 3 awful.mouse.client.resize)
         ))

(local rules [
              {:rule {}
               :properties {:focus true
                            :keys client-keys
                            :buttons client-buttons}}
              ])

(local client-event-handlers
  {"manage"       (fn [c]
                    (c:tags [(current-tag) view-all-tag]))
   "mouse::enter" (fn [c]
                    (if (awful.client.focus.filter c)
                      (tset client :focus c)))
   "focus"        focus-client
   "unfocus"      un-focus-client})

; Wire everything up

(fun.each client.connect_signal client-event-handlers)

(awful.screen.connect_for_each_screen
  (fn [s]
    (s:connect_signal "arrange" arrange-tag)))

(root.keys global-keys)

(tset awful.rules :rules rules)

(view-current-tag)

(gears.wallpaper.set background-color)

{}
