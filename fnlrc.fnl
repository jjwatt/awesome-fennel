(pcall require :luarocks.loader)
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
(local wibox (require :wibox))
(local beautiful (require :beautiful))
(local naughty (require :naughty))
(local ruled (require :ruled))
(local menubar (require :menubar))
(local hotkeys-popup (require :awful.hotkeys_popup))
(require :awful.hotkeys_popup.keys)
(local fun (require :fun))
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

;; when-let* maybe (wip)
(macro when-let* [bindings body]
  (let [empty? #(if (= nil (next $)) true false)
        car #(. $ 1)
        cdr (fn [lst] (icollect [i v (ipairs lst)] (if (not= 1 i) v)))]
    (if (empty? bindings)
        `(do ,body)
        '(let ,(car bindings)
              (when ,(car (car bindings))
                (when-let* ,(cdr bindings) ,body))))))

(let [signal "request::display_error"]
  (fn [message startup]
    (naughty.notification {: message
                           :title (.. "Oops, an error happened"
                                      (or (and startup "during startup!") "!"))
                           :urgency :critical})))
(beautiful.init :/home/jwattenb/.config/awesome/themes/default/theme.lua)

(global terminal :kitty)
(global editor (or (os.getenv :EDITOR) :nano))
(global editor-cmd (.. terminal " -e " editor))
(global modkey :Mod4)

;; (set beautiful.wallpaper beautiful.themes_path.."default/dock.jpg")
;; let* menuconfig just an example don't use
;; (global myawesomemenu (let* [[terminal :kitty]
;;                              [editor (or (os.getenv :EDITOR :nano))]
;;                              [editor-cmd (.. terminal " -e " editor)]]
;;                             [[:hotkeys (fn [] (hotkeys-popup.show_help nil (awful.screen.focused)))]
;;                              [:manual (.. terminal " -e man awesome")]
;;                              ["edit config" (.. editor-cmd " " aweesome.conffile)]
;;                              [:restart awesome.restart]
;;                              [:quit (fn [] (awesome.quit))]])
        
;; let's just see if any of this shit works
(global myawesomemenu [[:hotkeys
                        (fn []
                          (hotkeys-popup.show_help nil (awful.screen.focused)))]
                       [:manual (.. terminal " -e man awesome")]
                       ["edit config" (.. editor-cmd " " awesome.conffile)]
                       [:restart awesome.restart]
                       [:quit (fn [] (awesome.quit))]])

(global mymainmenu
        (awful.menu {:items [[:awesome myawesomemenu beautiful.awesome_icon]
                             ["open terminal" terminal]]}))

(global mylauncher
        (awful.widget.launcher {:image beautiful.awesome_icon :menu mymainmenu}))

(set menubar.utils.terminal terminal)

;; (let [gfs (require :gears.filesystem)]
;;   (let [confdir (gfs.get_dir :config)]
;;     (do
;;       (print confdir)
;;       (import-macros {: let*} :letstar))))
    
;; (let [gfs (require :gears.filesystem)]
;;   (do (print (gfs.get_themes_dir))
;;       (print (gfs.get_dir :config))))

;; Set wallpaper nested lets
;; (let [gfs (require :gears.filesystem)]
;;   (let [confdir (gfs.get_dir :config)]
;;     (let [themedir (.. confdir :themes/default)]
;;       (let [dockwp (.. themedir :/dock.jpg)]
;;         (do
;;           (set beautiful.wallpaper dockwp))))))

;; Set wallpaper with let*
;; (import-macros {: let*} :letstar)
(let* [[gfs (require :gears.filesystem)]
       [confdir (gfs.get_dir :config)]
       [themedir (.. confdir :themes/default)]
       [mywallpaper (.. themedir :/dock.jpg)]]
      (set beautiful.wallpaper mywallpaper))

(print beautiful.wallpaper)

;; {:fnlisloaded 1}

;; (set beautiful.wallpaper beautiful.themes_path.."default/background.jpg")
