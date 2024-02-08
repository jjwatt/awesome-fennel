(pcall require :luarocks.loader)
;; this is probably not the best way to do this
;; this is copied from the antifennel of my rc.lua
;; see fennel-lang.org docs & https://gist.github.com/christoph-frick/d3949076ffc8d23e9350d3ea3b6e00cb#file-cfg-fnl
;; Actually, now that I look at it, I think the generated one is *more* correct
;; because ':gears' is idomatic fennel for "gears". Looks better, too.
(local gears (require :gears))
(local awful (require :awful))

(local fun (require "fun"))
{:fnlisloaded 1}
