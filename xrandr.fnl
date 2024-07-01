(local gtable (require :gears.table))

(local spawn (require :awful.spawn))

(local naughty (require :naughty))

(local icon-path "")

(fn outputs []
  (let [outputs {}
        xrandr (io.popen "xrandr -q --current")]
    (when xrandr
      (each [line (xrandr:lines)]
        (local output (line:match "^([%w-]+) connected "))
        (when output
          (tset outputs (+ (length outputs) 1) output)))
      (xrandr:close))
    outputs))

(fn arrange [out]
  (var choices {})
  (var previous [{}])
  (for [i 1 (length out)]
    (local new {})
    (each [_ p (pairs previous)]
      (each [_ o (pairs out)]
        (when (not (gtable.hasitem p o))
          (tset new (+ (length new) 1) (gtable.join p [o])))))
    (set choices (gtable.join choices new))
    (set previous new))
  choices)

(fn menu []
  (let [menu {}
        out (outputs)
        choices (arrange out)]
    (each [_ choice (pairs choices)]
      (var cmd :xrandr)
      (each [i o (pairs choice)]
        (set cmd (.. cmd " --output " o " --auto"))
        (when (> i 1)
          (set cmd (.. cmd " --right-of " (. choice (- i 1))))))
      (each [_ o (pairs out)]
        (when (not (gtable.hasitem choice o))
          (set cmd (.. cmd " --output " o " --off"))))
      (var label "")
      (if (= (length choice) 1)
          (set label (.. "Only <span weight=\"bold\">" (. choice 1) :</span>))
          (each [i o (pairs choice)]
            (when (> i 1) (set label (.. label " + ")))
            (set label (.. label "<span weight=\"bold\">" o :</span>))))
      (tset menu (+ (length menu) 1) [label cmd]))
    menu))

(local state {:cid nil})

(fn naughty-destroy-callback [reason]
  (when (or (= reason naughty.notificationClosedReason.expired)
            (= reason naughty.notificationClosedReason.dismissedByUser))
    (local action (and state.index (. state.menu (- state.index 1) 2)))
    (when action (spawn action false) (set state.index nil))))

(fn xrandr []
  (when (not state.index) (set state.menu (menu)) (set state.index 1))
  (var (label action) nil)
  (local next (. state.menu state.index))
  (set state.index (+ state.index 1))
  (if (not next) (do
                   (set label "Keep the current configuration")
                   (set state.index nil))
      (set (label action) (values (. next 1) (. next 2))))
  (set state.cid (. (naughty.notify {:destroy naughty-destroy-callback
                                     :icon icon-path
                                     :replaces_id state.cid
                                     :screen mouse.screen
                                     :text label
                                     :timeout 4}) :id)))

{: arrange : menu : outputs : xrandr}

