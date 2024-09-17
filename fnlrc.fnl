;; this is probably not the best way to do this
;; this is copied from the antifennel of my rc.lua
;; see fennel-lang.org docs &
;; https://gist.github.com/christoph-frick/d3949076ffc8d23e9350d3ea3b6e00cb
;; Actually, now that I look at it, I think the generated one is *more* correct
;; because ':gears' is idomatic fennel for "gears". Looks better, too.
(pcall require :luarocks.loader)
(local gears (require :gears))
(local awful (require :awful))
(require :awful.autofocus)
(local keyboard (require :awful.keyboard))
(local addkb keyboard.append_global_keybindings)
(local wibox (require :wibox))
(local beautiful (require :beautiful))
(local naughty (require :naughty))
(local ruled (require :ruled))
(local menubar (require :menubar))
(local hotkeys-popup (require :awful.hotkeys_popup))
(require :awful.hotkeys_popup.keys)
(local vicious (require :vicious))
;; (local fun (require :fun))
;; gets all of them under mymacros namespace
;; (import-macros mymacros :mymacros)
;; need to get full path for this
;; or I need to figure out how to expand the fennel load path
;; otherwise, always has to run from .config/awesome dir to work!
;; (import-macros {: let*} :letstar)
;; (import-macros {: when-let} :whenlet)
;; TODO: figure out how to put stuff in fennel's path
;; For now, just include the macros.
(macro when-let [bindings & body]
  "Bind `bindings` and execute `body`, short-circuiting on `nil`."
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
 
(macro when-let* [bindings conditional body]
  (let [empty? #(if (= nil (next $)) true false)
        car #(. $ 1)
        cdr (fn [lst] (icollect [i v (ipairs lst)] (if (not= 1 i) v)))]
    (if (empty? bindings)
        `(when ,conditional ,body)
        `(let ,(car bindings)
              (when ,(car (car bindings))
                    (when-let* ,(cdr bindings) ,conditional ,body))))))

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

;; Setup early error handler.
(let [signal "request::display_error"]
  (fn [message startup]
    (naughty.notification {: message
                           :title (.. "Oops, an error happened"
                                      (or (and startup "during startup!") "!"))
                           :urgency :critical})))

(global terminal :kitty)
(global editor (or (os.getenv :EDITOR) :nano))
(global editor-cmd (.. terminal " -e " editor))
(global modkey :Mod4)
(print :terminal terminal)
(print :editor editor)
(print :editor-cmd editor-cmd)
(print :modkey modkey)

;;(global add-keybindings awful.keyboard.append_global_keybindings)

;;,-------------
;;| Screen Setup
;;`-------------
;; Get list of video outputs / screens / displays from xrandr.
(fn list-video-outputs []
  (let [outputs {}
        xrandr (io.popen "xrandr -q --current")]
    (when xrandr
      (each [line (xrandr:lines)]
        (local output (line:match "^([%w-]+) connected "))
        (when output
          (tset outputs (+ (length outputs) 1) output)))
      (xrandr:close))
    outputs))
;; Setup triple Display Port setup only when we detect 3 screens
;; Otherwise, this will all shortcircuit to nils & we do nothing.
(if-let [[_outs (list-video-outputs)]] (global xrandr-screens _outs))
;; We could check to see if it already ran, but it shouldn't
;; hurt to run it again.
(when-let* [[screens xrandr-screens]
            [screen-count (length screens)]
            [screen-layouts-path "$HOME/.screenlayout/"]
            [screen-layout "tredphdmi.sh"]
            [screen-layout-script (.. screen-layouts-path screen-layout)]]
           (= screen-count 3)
           (awful.spawn.with_shell screen-layout-script))

;;,--------------------
;;| Theme & Looks Setup
;;`--------------------

;; Init my theme file. For now, it's still in lua.
(beautiful.init :/home/jwattenb/.config/awesome/themes/default/theme.lua)
;; Setup wallpaper
;; TODO: try this as when-let* because we don't want to set it if nil.
(let* [[gfs (require :gears.filesystem)]
       [confdir (gfs.get_dir :config)]
       [themedir (.. confdir :themes/default)]
       [mywallpaper (.. themedir :/dock.jpg)]]
      (set beautiful.wallpaper mywallpaper))

;;,-----------
;;| Menu Setup
;;`-----------
;; Setup simple awesome menu from default awesome config.
(global myawesomemenu [[:hotkeys
                        #(hotkeys-popup.show_help nil (awful.screen.focused))]
                       [:manual
                        (.. terminal " -e man awesome")]
                       ["edit config"
                        (.. editor-cmd " " awesome.conffile)]
                       [:restart
                        awesome.restart]
                       [:quit
                        #(awesome.quit)]])
(global mymainmenu
        (awful.menu {:items
                     [[:awesome
                       myawesomemenu beautiful.awesome_icon]
                      ["open terminal" terminal]]}))
(global mylauncher
        (awful.widget.launcher
         {:image beautiful.awesome_icon :menu mymainmenu}))

;; Set the menubar terminal to our global terminal.
(set menubar.utils.terminal terminal)

;; Default layouts and layout order
(tag.connect_signal "request::default_layouts"
                    #(awful.layout.append_default_layouts
                      [awful.layout.suit.floating
                       awful.layout.suit.tile
                       awful.layout.suit.tile.left
                       awful.layout.suit.tile.bottom
                       awful.layout.suit.tile.top
                       awful.layout.suit.fair
                       awful.layout.suit.fair.horizontal
                       awful.layout.suit.spiral
                       awful.layout.suit.spiral.dwindle
                       awful.layout.suit.max
                       awful.layout.suit.max.fullscreen
                       awful.layout.suit.magnifier
                       awful.layout.suit.corner.nw]))

;; wallpaper signal?
(screen.connect_signal "request::wallpaper"
                       (fn [s]
                         (awful.wallpaper
                          {:screen s
                           :widget {1
                                    {:downscale true
                                     :image beautiful.wallpaper
                                     :upscale true
                                     :widget wibox.widget.imagebox}
                                    :halign :center
                                    :tiled false
                                    :valign :center
                                    :widget wibox.container.tile}})))

;; could be prettier
(global mytextclock (wibox.widget.textclock))
(lambda inc-layout [?n]
  (awful.layout.inc (or ?n 1)))
(lambda layout-incrementer [?n]
  (fn []
    (inc-layout ?n)))
(fn client-toggle-tag [tag]
   (when client.focus
     (client.focus:toggle_tag tag)))
(fn view-only [tag]
   (: tag :view_only))
(fn move-to-tag [tag]
  (when client.focus
    (client.focus:move_to_tag tag)))
(lambda awful-button [btn-num f ?mod]
  (awful.button (or ?mod {})
                btn-num
                f))
(fn minimize-client [c]
  (c:activate {:action :toggle_minimization
               :context :tasklist}))
(lambda menu-client-list [?width]
  (awful.menu.client_list
   {:theme {:width (or ?width 250)}}))
(fn make-box [layout lst]
  "Put a layout and a list of widgets into a wibox"
  (let [w lst]
    (tset w :layout layout)
    w))
;; Praise Widget from tutorial
;; (local praisewidget (wibox.widget.textbox))
;; (set praisewidget.text "You are great!")

;; Desktop Decorations: The Bar
(screen.connect_signal
 "request::desktop_decoration"
 (fn [s]
   (awful.tag [:1 :2 :3 :4 :5 :6 :7 :8 :9] s
              (. awful.layout.layouts 1))
   (set s.mypromptbox (awful.widget.prompt))
   ;; (set s.mybatbox (awful.widget.layoutbox))
   ;; (set s.mybatbox.max_value 100)
   ;; (set s.mybatbox.forced_height 20)
   ;; (set s.mybatbox.forced_width 50)
   ;; (set s.mybatbox.paddings 1)
   ;; (set s.mybatbox.border_color beautiful.border_color)
   ;; (set s.mybatbox.widget wibox.widget.progressbar)
   ;; (vicious.register s.mybatterywidget vicious.widgets.bat "$2" 61 "BAT0")
   ;; (set s.mybatbox.layout wibox.container.rotate)
   ;; TODO: Only build the battery widget if there's a BAT
   (local vicious-widgets (require :vicious.widgets.init))
   (local bat-text-widget (wibox.widget.textbox))
   (set bat-text-widget.text
        (table.concat
         (let [[a b & _]
               (vicious-widgets.bat nil "BAT0")] [a b]) " "))
   (vicious.register bat-text-widget vicious-widgets.bat "$1 $2" 61 "BAT0")
   
   (set s.mylayoutbox
        (awful.widget.layoutbox
         {:buttons [(awful-button
                     1 (layout-incrementer))
                    (awful-button
                     3 (layout-incrementer (- 1)))
                    (awful-button
                     4 (layout-incrementer (- 1)))
                    (awful-button
                     5 (layout-incrementer))]
          :screen s}))
   (set s.mytaglist
        (awful.widget.taglist
         {:buttons [(awful-button
                     1 view-only)
                    (awful-button
                     1 move-to-tag [modkey])
                    (awful-button
                     3 awful.tag.viewtoggle)
                    (awful-button
                     3 client-toggle-tag [modkey])
                    (awful-button
                     4 #(awful.tag.viewprev $.screen))
                    (awful-button
                     5 #(awful.tag.viewnext $.screen))]
          :filter awful.widget.taglist.filter.all
          :screen s}))
   (set s.mytasklist
        (awful.widget.tasklist
         {:buttons [(awful-button
                     1 minimize-client)
                    ;; A nice client menu on mouse btn 3.
                    ;; Set 300 to something else to make the
                    ;; client list wider.
                    (awful-button
                     3 #(menu-client-list 400))
                    ;; 4 and 5 happen to map to scroll up & down
                    ;; on my trackball--probably on most mice.
                    ;; So, this lets you scroll up & down between
                    ;; clients in the task list.
                    (awful-button
                     4 #(awful.client.focus.byidx (- 1)))
                    (awful-button
                     5 #(awful.client.focus.byidx 1))
                    ]
          :filter awful.widget.tasklist.filter.currenttags
          :screen s}))
   ;;    set s.mywibox to the widget defined by the table
   ;;    this sets up the horizontal bar at the top and all
   ;;    the widgets in it.
   (when-let [[topbar
               (make-box
                wibox.layout.align.horizontal
                (let [leftwidgets
                      (make-box wibox.layout.align.horizontal
                                [mylauncher s.mytaglist s.mypromptbox])
                      middlewidget s.mytasklist
                      rightwidgets
                      (make-box wibox.layout.fixed.horizontal
                                [bat-text-widget wibox.widget.systray mytextclock s.mylayoutbox])]
                  [leftwidgets middlewidget rightwidgets]))]]
             (set s.mywibox
                  (awful.wibar
                   {:position :top
                    :screen s
                    :widget topbar}))))
(awful.mouse.append_global_mousebindings
 [(awful.button {} 3 #(mymainmenu:toggle))
  (awful.button {} 4 awful.tag.viewprev)
  (awful.button {} 5 awful.tag.viewnext)]
 )

;; Key Bindings
;; General Awesom keys
;; (awful.keyboard.append_global_keybindings [(awfulkey
;;                                             [modkey] :s
;;                                             hotkeys-popup.show_help
;;                                             {:description "show help"
;;                                              :group :awesome})])

(addkb [(awful.key [modkey] :s
                   hotkeys-popup.show_help
                   {:description "show help"
                    :group :awesome})
        (awful.key [modkey] :w
                   #(mymainmenu:show)
                   {:description "show main menu"
                    :group :awesome})
        (awful.key [modkey :Control] :r
                   awesome.restart
                   {:description "reload awesome"
                    :group :awesome})
        (awful.key [modkey :Shift] :q
                   awesome.quit
                   {:description "quit awesome"
                    :group :awesome})
        (awful.key [modkey] :x
                   #(awful.prompt.run {:exe_callback awful.util.eval
                                       :history_path (.. (awful.util.get_cache_dir)
                                                         :/history_eval)
                                       :prompt "Run Lua code: "
                                       :textbox (. (awful.screen.focused)
                                                   :mypromptbox
                                                   :widget)})
                   {:description "lua execute prompt"
                    :group :awesome})
        (awful.key [modkey] :Return
                   #(awful.spawn terminal)
                   {:description "open a terminal"
                    :group :launcher})
        (awful.key [modkey] :r
                   (fn []
                     ;; Get :mypromptbox and call mypromptbox:run() on it
                     (: (. (awful.screen.focused)
                           :mypromptbox)
                        :run))
                   {:description "run prompt"
                    :group :launcher})
        (awful.key [modkey] :p
                   (fn [] (menubar.show))
                   {:description "show the menubar"
                    :group :launcher})])

(addkb [(awful.key [modkey] :Left
                   awful.tag.viewprev
                   {:description "view previous"
                    :group :tag})
        (awful.key [modkey] :Right
                   awful.tag.viewnext
                   {:description "view next"
                    :group :tag})
        (awful.key [modkey] :Escape
                   awful.tag.history.restore
                   {:description "go back"
                    :group :tag})])
(addkb [(awful.key [modkey] :j
                   #(awful.client.focus.byidx 1)
                   {:description "focus next by index"
                    :group :client})
        (awful.key [modkey] :k
                   #(awful.client.focus.byidx (- 1))
                   {:description "focus previous by index"
                    :group :client})
        (awful.key [modkey] :Tab
                   (fn []
                     (awful.client.focus.history.previous)
                     (when client.focus
                       (client.focus:raise)))
                   ;; #(when (do ((awful.client.focus.history.previous)
                   ;;             client.focus))
                   ;;    (client.focus:raise))
                   {:description "go back"
                    :group :client})
        (awful.key [modkey :Control] :j
                   #(awful.screen.focus_relative 1)
                   {:description "focus the next screen"
                    :group :screen})
        (awful.key [modkey :Control] :k
                   #(awful.screen.focus_relative (- 1))
                   {:description "focus the previous screen"
                    :group :screen})
        (awful.key [modkey :Control] :n
                   #(when-let [[c (awful.client.restore)]]
                              (c:activate {:context :key.unminimize
                                           :raise true}))
                   {:description "restore minimized"
                    :group :client})])

;; newest batch
(addkb [(awful.key [modkey :Shift] :j
                   #(awful.client.swap.byidx 1)
                   {:description "swap with next client by index"
                    :group :client})
        (awful.key [modkey :Shift] :k
                   (fn []
                     (awful.client.swap.byidx (- 1)))
                   {:description "swap with previous client by index"
                    :group :client})
        (awful.key [modkey] :u
                   awful.client.urgent.jumpto
                   {:description "jump to urgent client"
                    :group :client})
        (awful.key [modkey] :l
                   #(awful.tag.incmwfact 0.05)
                   {:description "increase master width factor"
                    :group :layout})
        (awful.key [modkey] :h
                   #(awful.tag.incmwfact (- 0.05))
                   {:description "decrease master width factor"
                    :group :layout})
        (awful.key [modkey :Shift] :h
                   #(awful.tag.incnmaster 1
                                          nil
                                          true)
                   {:description "increase the number of master clients"
                    :group :layout})
        (awful.key [modkey :Shift] :l
                   #(awful.tag.incnmaster (- 1)
                                          nil
                                          true)
                   {:description "decrease the number of master clients"
                    :group :layout})
        (awful.key [modkey :Control] :h
                   (fn []
                     (awful.tag.incncol 1
                                        nil
                                        true))
                   {:description "increase the number of columns"
                    :group :layout})
        (awful.key [modkey :Control] :l
                   (fn []
                     (awful.tag.incncol (- 1)
                                        nil
                                        true))
                   {:description "decrease the number of columns"
                    :group :layout})
        (awful.key [modkey] :space
                   (fn []
                     (awful.layout.inc 1))
                   {:description "select next"
                    :group :layout})
        (awful.key [modkey :Shift] :space
                   (fn []
                     (awful.layout.inc (- 1)))
                   {:description "select previous"
                    :group :layout})]))

(addkb [(awful.key {:description "only view tag"
                    :group :tag
                    :keygroup :numrow
                    :modifiers [modkey]
                    :on_press (fn [index]
                                (local screen
                                       (awful.screen.focused))
                                (local tag
                                       (. screen.tags
                                          index))
                                (when tag
                                  (tag:view_only)))})
        (awful.key {:description "toggle tag"
                    :group :tag
                    :keygroup :numrow
                    :modifiers [modkey
                                :Control]
                    :on_press (fn [index]
                                (local screen
                                       (awful.screen.focused))
                                (local tag
                                       (. screen.tags
                                          index))
                                (when tag
                                  (awful.tag.viewtoggle tag)))})
        (awful.key {:description "move focused client to tag"
                    :group :tag
                    :keygroup :numrow
                    :modifiers [modkey
                                :Shift]
                    :on_press (fn [index]
                                (when client.focus
                                  (local tag
                                         (. client.focus.screen.tags
                                            index))
                                  (when tag
                                    (client.focus:move_to_tag tag))))})
        (awful.key {:description "toggle focused client on tag"
                    :group :tag
                    :keygroup :numrow
                    :modifiers [modkey
                                :Control
                                :Shift]
                    :on_press (fn [index]
                                (when client.focus
                                  (local tag
                                         (. client.focus.screen.tags
                                            index))
                                  (when tag
                                    (client.focus:toggle_tag tag))))})
        (awful.key {:description "select layout directly"
                    :group :layout
                    :keygroup :numpad
                    :modifiers [modkey]
                    :on_press (fn [index]
                                (local t
                                       (. (awful.screen.focused)
                                          :selected_tag))
                                (when t
                                  (set t.layout
                                       (or (. t.layouts
                                              index)
                                           t.layout))))})])

;; {:fnlisloaded 1}
;; (set beautiful.wallpaper beautiful.themes_path.."default/background.jpg")
