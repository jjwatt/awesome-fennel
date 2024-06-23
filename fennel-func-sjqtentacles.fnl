;; from https://gist.githubusercontent.com/sjqtentacles/33784e77479bb06334ac77c1d4831343/raw/6540c4aff1eef5320048223f4494b7e436076f5c/fennel-func

(fn table-insert [tab val]
  (var t tab)
  (table.insert t val)
  t)

(fn table-remove [tab indx]
  (var t tab)
  (table.remove t indx)
  t)

(fn car [lst]
  (. lst 1))

(fn cdr [lst]
  (table-remove lst 1))

(fn cadr [lst]
  (car (cdr lst)))

(fn caadr [lst]
  (car (car (cdr lst))))

(fn caaadr [lst]
  (car (car (car (cdr lst)))))

(fn caaaadr [lst]
  (car (car (car (car (cdr lst))))))

(fn caddr [lst]
  (car (cdr (cdr lst))))

(fn cadddr [lst]
  (car (cdr (cdr (cdr lst)))))

(fn caddddr [lst]
  (car (cdr (cdr (cdr (cdr lst))))))

(fn cons [a b]
  (table-insert a 1 b))

(fn inc [n]
  (+ n 1))

(fn dec [n]
  (- n 1))

(fn iota [amount]
  (var counter 1)
  (let [t []]
    (while (<= counter amount)
      (tset t counter counter)
      (set counter (inc counter)))
    t))

(fn iota-range [from to]
  (var table_index 1)
  (var counter from)
  (let [t []]
    (while (<= counter to)
      (tset t table_index counter)
      (set counter (inc counter))
      (set table_index (inc table_index)))
    t))

(fn map [func listOfThings]
  (let [result []]
    (each [index val (ipairs listOfThings)]
      (table.insert result (func val)))
    result))

(fn filter [func listOfThings]
  (let [result []]
    (each [index val (ipairs listOfThings)]
      (when (= true (func val))
        (table.insert result val)))
    result))

(fn reduce [func acc listOfThings]
  (var result acc)
  (each [index val (ipairs listOfThings)]
    (set result (func result val)))
  result)

(fn reject [func listOfThings]
  (filter 
    (lambda [x] (not (func x))) 
    listOfThings))

(fn drop-while [func listOfThings]
  (var t listOfThings)
  (while (and (> (length t) 0) (func (. t 1)))
    (table.remove t 1))
  t)

(fn empty? [lst]
  (= 0 (length lst)))

(fn random [from to]
  (math.random from to))

(fn pick-random [lst]
  (let [rand-ind (random 1 (length lst))]
    (. lst rand-ind)))

(fn randomize-seed []
  (math.randomseed (os.time)))

(fn shuffle [mytbl]
  (var shuffled [])
  (each [k v (ipairs mytbl)]
    (let [pos (random 1 (inc (length shuffled)))]
      (table.insert shuffled pos v)))
  shuffled)

(fn all? [ls]
  (reduce 
    (lambda [acc x] (and acc x)) 
    (car ls) 
    ls))

(fn any? [ls]
  (reduce 
    (lambda [acc x] (or acc x)) 
    (car ls) 
    ls))

(fn drop [ls amount]
  (map 
    (lambda [i] (. ls i)) 
    (iota-range (inc amount) (length ls))))

(fn reverse [lst]
  (icollect [i v (ipairs (iota-range 0 (length lst)))]
    (. lst (- (length lst) v))))

(fn take [ls amount]
  (icollect [i _ (ipairs (iota amount))]
    (. ls i)))

(fn zip [xs ys]
  (let [amount-to-zip (math.min (length xs) (length ys))
        t []]
    (each [_ v (ipairs (iota amount-to-zip))]
      (tset t v [(. xs v) (. ys v)]))
    t))

(fn odd? [n]
  (= 1 (% n 2)))

(fn even? [n]
  (= 0 (% n 2)))

(fn apply [func args]
  (func args))

(fn slice [lst start end]
  (icollect [k v (ipairs (iota-range start end))]
    (. lst v)))

(fn first [lst]
  (car lst))

(fn last [lst]
  (. lst (length lst)))

(fn repeat [val times]
  (map (lambda [] val) (iota times)))

(fn concat [...]
  (each [k v (ipairs ...)]
    (print k v)))

(fn find [lst pred]
  (each [key val (pairs lst)]
    (when (= pred val)
      (lua "return key"))))

(fn nil? [thing]
  (= nil thing))

(fn exists? [thing]
  (not (nil? thing)))

(fn number? [thing]
  (= "number" (type thing)))

(fn string? [thing]
  (= "string" (type thing)))

(fn table? [thing]
  (= "table" (type thing)))

(fn sort [lst ?order]
  (var t lst)
  (match ?order
    (:desc) (do (table.sort t (lambda [a b] (> a b))) t)
    (_) (do (table.sort t) t)))

(fn sort-by [lst func ?order]
  (var t lst)
  (table.sort t func)
  t)

(fn join [lst ?sep]
  (match ?sep
    (nil) (table.concat lst "")
    (s) (table.concat lst s)))

(fn sum [lst]
  (reduce (lambda [a b] (+ a b)) 0 lst))

(fn mean [lst]
  (/ (sum lst) (length lst)))

(fn pop [lst]
  (let [last (last lst)]
    (table.remove lst (length lst))
    last))

(fn cycle [lst]
  (table.insert lst 1 (pop lst))
  (. lst 1))

(fn make-set [lst]
  (var t [])
  (each [k v (ipairs lst)]
    (tset t v true))
  t)

(fn find-in-set [lst val]
  (. lst val))

(fn remove-from-set [lst val]
  (tset lst val nil))

(local colorsRGB {
  :aliceblue [0.94117647058824 0.97254901960784 1.0]
  :antiquewhite [0.98039215686275 0.92156862745098 0.84313725490196]
  :aqua [0.0 1.0 1.0]
  :aquamarine [0.49803921568627 1.0 0.83137254901961]
  :azure [0.94117647058824 1.0 1.0]
  :beige [0.96078431372549 0.96078431372549 0.86274509803922]
  :bisque [1.0 0.89411764705882 0.76862745098039]
  :black [0.0 0.0 0.0]
  :blanchedalmond [1.0 0.92156862745098 0.80392156862745]
  :blue [0.0 0.0 1.0]
  :blueviolet [0.54117647058824 0.16862745098039 0.88627450980392]
  :brown [0.64705882352941 0.16470588235294 0.16470588235294]
  :burlywood [0.87058823529412 0.72156862745098 0.52941176470588]
  :cadetblue [0.37254901960784 0.61960784313725 0.62745098039216]
  :chartreuse [0.49803921568627 1.0 0.0]
  :chocolate [0.82352941176471 0.41176470588235 0.11764705882353]
  :coral [1.0 0.49803921568627 0.31372549019608]
  :cornflowerblue [0.3921568627451 0.5843137254902 0.92941176470588]
  :cornsilk [1.0 0.97254901960784 0.86274509803922]
  :crimson [0.86274509803922 0.07843137254902 0.23529411764706]
  :cyan [0.0 1.0 1.0]
  :darkblue [0.0 0.0 0.54509803921569]
  :darkcyan [0.0 0.54509803921569 0.54509803921569]
  :darkgoldenrod [0.72156862745098 0.52549019607843 0.043137254901961]
  :darkgray [0.66274509803922 0.66274509803922 0.66274509803922]
  :darkgreen [0.0 0.3921568627451 0.0]
  :darkgrey [0.66274509803922 0.66274509803922 0.66274509803922]
  :darkkhaki [0.74117647058824 0.71764705882353 0.41960784313725]
  :darkmagenta [0.54509803921569 0.0 0.54509803921569]
  :darkolivegreen [0.33333333333333 0.41960784313725 0.1843137254902]
  :darkorange [1.0 0.54901960784314 0.0]
  :darkorchid [0.6 0.19607843137255 0.8]
  :darkred [0.54509803921569 0.0 0.0]
  :darksalmon [0.91372549019608 0.58823529411765 0.47843137254902]
  :darkseagreen [0.56078431372549 0.73725490196078 0.56078431372549]
  :darkslateblue [0.28235294117647 0.23921568627451 0.54509803921569]
  :darkslategray [0.1843137254902 0.30980392156863 0.30980392156863]
  :darkslategrey [0.1843137254902 0.30980392156863 0.30980392156863]
  :darkturquoise [0.0 0.8078431372549 0.81960784313725]
  :darkviolet [0.58039215686275 0.0 0.82745098039216]
  :deeppink [1.0 0.07843137254902 0.57647058823529]
  :deepskyblue [0.0 0.74901960784314 1.0]
  :dimgray [0.41176470588235 0.41176470588235 0.41176470588235]
  :dimgrey [0.41176470588235 0.41176470588235 0.41176470588235]
  :dodgerblue [0.11764705882353 0.56470588235294 1.0]
  :firebrick [0.69803921568627 0.13333333333333 0.13333333333333]
  :floralwhite [1.0 0.98039215686275 0.94117647058824]
  :forestgreen [0.13333333333333 0.54509803921569 0.13333333333333]
  :fuchsia [1.0 0.0 1.0]
  :gainsboro [0.86274509803922 0.86274509803922 0.86274509803922]
  :ghostwhite [0.97254901960784 0.97254901960784 1.0]
  :gold [1.0 0.84313725490196 0.0]
  :goldenrod [0.85490196078431 0.64705882352941 0.12549019607843]
  :gray [0.50196078431373 0.50196078431373 0.50196078431373]
  :green [0.0 0.50196078431373 0.0]
  :greenyellow [0.67843137254902 1.0 0.1843137254902]
  :grey [0.50196078431373 0.50196078431373 0.50196078431373]
  :honeydew [0.94117647058824 1.0 0.94117647058824]
  :hotpink [1.0 0.41176470588235 0.70588235294118]
  :indianred [0.80392156862745 0.36078431372549 0.36078431372549]
  :indigo [0.29411764705882 0.0 0.50980392156863]
  :ivory [1.0 1.0 0.94117647058824]
  :khaki [0.94117647058824 0.90196078431373 0.54901960784314]
  :lavender [0.90196078431373 0.90196078431373 0.98039215686275]
  :lavenderblush [1.0 0.94117647058824 0.96078431372549]
  :lawngreen [0.48627450980392 0.98823529411765 0.0]
  :lemonchiffon [1.0 0.98039215686275 0.80392156862745]
  :lightblue [0.67843137254902 0.84705882352941 0.90196078431373]
  :lightcoral [0.94117647058824 0.50196078431373 0.50196078431373]
  :lightcyan [0.87843137254902 1.0 1.0]
  :lightgoldenrodyellow [0.98039215686275 0.98039215686275 0.82352941176471]
  :lightgray [0.82745098039216 0.82745098039216 0.82745098039216]
  :lightgreen [0.56470588235294 0.93333333333333 0.56470588235294]
  :lightgrey [0.82745098039216 0.82745098039216 0.82745098039216]
  :lightpink [1.0 0.71372549019608 0.75686274509804]
  :lightsalmon [1.0 0.62745098039216 0.47843137254902]
  :lightseagreen [0.12549019607843 0.69803921568627 0.66666666666667]
  :lightskyblue [0.52941176470588 0.8078431372549 0.98039215686275]
  :lightslategray [0.46666666666667 0.53333333333333 0.6]
  :lightslategrey [0.46666666666667 0.53333333333333 0.6]
  :lightsteelblue [0.69019607843137 0.76862745098039 0.87058823529412]
  :lightyellow [1.0 1.0 0.87843137254902]
  :lime [0.0 1.0 0.0]
  :limegreen [0.19607843137255 0.80392156862745 0.19607843137255]
  :linen [0.98039215686275 0.94117647058824 0.90196078431373]
  :magenta [1.0 0.0 1.0]
  :maroon [0.50196078431373 0.0 0.0]
  :mediumaquamarine [0.4 0.80392156862745 0.66666666666667]
  :mediumblue [0.0 0.0 0.80392156862745]
  :mediumorchid [0.72941176470588 0.33333333333333 0.82745098039216]
  :mediumpurple [0.57647058823529 0.43921568627451 0.85882352941176]
  :mediumseagreen [0.23529411764706 0.70196078431373 0.44313725490196]
  :mediumslateblue [0.48235294117647 0.4078431372549 0.93333333333333]
  :mediumspringgreen [0.0 0.98039215686275 0.60392156862745]
  :mediumturquoise [0.28235294117647 0.81960784313725 0.8]
  :mediumvioletred [0.78039215686275 0.082352941176471 0.52156862745098]
  :midnightblue [0.098039215686275 0.098039215686275 0.43921568627451]
  :mintcream [0.96078431372549 1.0 0.98039215686275]
  :mistyrose [1.0 0.89411764705882 0.88235294117647]
  :moccasin [1.0 0.89411764705882 0.70980392156863]
  :navajowhite [1.0 0.87058823529412 0.67843137254902]
  :navy [0.0 0.0 0.50196078431373]
  :oldlace [0.9921568627451 0.96078431372549 0.90196078431373]
  :olive [0.50196078431373 0.50196078431373 0.0]
  :olivedrab [0.41960784313725 0.55686274509804 0.13725490196078]
  :orange [1.0 0.64705882352941 0.0]
  :orangered [1.0 0.27058823529412 0.0]
  :orchid [0.85490196078431 0.43921568627451 0.83921568627451]
  :palegoldenrod [0.93333333333333 0.90980392156863 0.66666666666667]
  :palegreen [0.59607843137255 0.9843137254902 0.59607843137255]
  :paleturquoise [0.68627450980392 0.93333333333333 0.93333333333333]
  :palevioletred [0.85882352941176 0.43921568627451 0.57647058823529]
  :papayawhip [1.0 0.93725490196078 0.83529411764706]
  :peachpuff [1.0 0.85490196078431 0.72549019607843]
  :peru [0.80392156862745 0.52156862745098 0.24705882352941]
  :pink [1.0 0.75294117647059 0.79607843137255]
  :plum [0.86666666666667 0.62745098039216 0.86666666666667]
  :powderblue [0.69019607843137 0.87843137254902 0.90196078431373]
  :purple [0.50196078431373 0.0 0.50196078431373]
  :red [1.0 0.0 0.0]
  :rosybrown [0.73725490196078 0.56078431372549 0.56078431372549]
  :royalblue [0.25490196078431 0.41176470588235 0.88235294117647]
  :saddlebrown [0.54509803921569 0.27058823529412 0.074509803921569]
  :salmon [0.98039215686275 0.50196078431373 0.44705882352941]
  :sandybrown [0.95686274509804 0.64313725490196 0.37647058823529]
  :seagreen [0.18039215686275 0.54509803921569 0.34117647058824]
  :seashell [1.0 0.96078431372549 0.93333333333333]
  :sienna [0.62745098039216 0.32156862745098 0.17647058823529]
  :silver [0.75294117647059 0.75294117647059 0.75294117647059]
  :skyblue [0.52941176470588 0.8078431372549 0.92156862745098]
  :slateblue [0.4156862745098 0.35294117647059 0.80392156862745]
  :slategrey [0.43921568627451 0.50196078431373 0.56470588235294]
  :snow [1.0 0.98039215686275 0.98039215686275]
  :springgreen [0.0 1.0 0.49803921568627]
  :steelblue [0.27450980392157 0.50980392156863 0.70588235294118]
  :tan [0.82352941176471 0.70588235294118 0.54901960784314]
  :teal [0.0 0.50196078431373 0.50196078431373]
  :thistle [0.84705882352941 0.74901960784314 0.84705882352941]
  :tomato [1.0 0.38823529411765 0.27843137254902]
  :turquoise [0.25098039215686 0.87843137254902 0.8156862745098]
  :violet [0.93333333333333 0.50980392156863 0.93333333333333]
  :wheat [0.96078431372549 0.87058823529412 0.70196078431373]
  :white [1.0 1.0 1.0]
  :whitesmoke [0.96078431372549 0.96078431372549 0.96078431372549]
  :yellow [1.0 1.0 0.0]
  :yellowgreen [0.60392156862745 0.80392156862745 0.19607843137255]})

(fn color [name]
  (values (. colorsRGB name)))

{
  :cycle cycle
  :color color
  :colorsRGB colorsRGB
  :remove-from-set remove-from-set
  :find-in-set find-in-set
  :make-set make-set
  :pop pop
  :mean mean
  :sum sum
  :join join
  :sort-by sort-by
  :sort sort
  :table? table?
  :string? string?
  :number? number?
  :exists? exists?
  :nil? nil?
  :find find 
  :concat concat
  :repeat repeat
  :first first
  :last last
  :slice slice
  :apply apply
  :odd? odd?
  :even? even?
  :zip zip
  :take take
  :repeat repeat
  :table-insert table-insert
  :table-remove table-remove
  :drop drop
  :any? any?
  :all? all?
  :shuffle shuffle
  :randomize-seed randomize-seed
  :random random
  :empty? empty?
  :pick-random pick-random
  :drop-while drop-while
  :reject reject
  :map map
  :filter filter
  :reduce reduce
  :iota iota
  :inc inc
  :dec dec 
  :iota-range iota-range
  :cons cons
  :car car 
  :cdr cdr 
  :cadr cadr
  :caadr caadr
  :caaadr caaadr
  :caaaadr caaaadr
  :caddddr caddddr
  :cadddr cadddr
  :caddr caddr
}
