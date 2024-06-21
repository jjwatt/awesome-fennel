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

;; {:fnlisloaded 1}

