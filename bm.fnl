(fn _G.factorial-iterative [n]
  (var result 1)
  (for [i 1 n] (set result (* result i)))
  result)
(local number 1000)
(local iterations 1000)
(var start-time 0)
(set start-time (os.clock))
(for [i 1 iterations] (_G.factorial-iterative number))
(local iterative-time (- (os.clock) start-time))
(print (string.format "Iterative factorial: %.6f seconds" iterative-time))

