(describe "Busted unit testing framework"
          (fn []
            (describe "should be awesome")
            (fn []
              (it "should be easy to use" (fn []
                                            (assert.truthy "Yup")))
              (it "should have lots of features"
                  (fn []
                    (assert.are.same { table "great"} {table "great"})
                    (assert.are_not.equal {table "great"} {table "great"})
                    (assert.truthy "this is a string")
                    (assert.True (= 1 1))
                    (assert.is_true (= 1 1))
                    (assert.falsy nil)
                    (assert.has_error (fn [] (error "Wat")) "Wat"))))))
