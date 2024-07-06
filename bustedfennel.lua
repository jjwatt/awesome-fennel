local function _1_()
  describe("should be awesome")
  local function _2_()
    local function _3_()
      return assert.truthy("Yup")
    end
    it("should be easy to use", _3_)
    local function _4_()
      assert.are.same({[table] = "great"}, {[table] = "great"})
      assert.are_not.equal({[table] = "great"}, {[table] = "great"})
      return assert.truthy("this is a string")
    end
    return it("should have lots of features", _4_)
  end
  return _2_
end
return describe("Busted unit testing framework", _1_)
