local List = require "treedoc.list"

describe("List as function", function()
   it("equivalent to List:new", function(x)
      local new = List:new { "ramen" }
      local list = List { "ramen" }
      assert.are_same(new, list)
      assert.are_equal(getmetatable(new), getmetatable(list))
   end)
end)

describe("clone", function()
   it("changing the clone does not affect original", function()
      local orig = List:new { 23, 42 }
      local copy = orig:clone()
      copy[1] = 5
      assert.are_same({ 23, 42 }, orig)
      assert.are_same({ 5, 42 }, copy)
   end)
   it("result is a list", function()
      local orig = List:new { 23, 42 }
      assert.are_equal(List, getmetatable(orig:clone()))
   end)
end)

describe("extend", function()
   it("extends list with other list", function()
      local primes = List:new { 2, 3, 5, 7 }
      primes:extend { 11, 13, 17 }
      assert.are_same({ 2, 3, 5, 7, 11, 13, 17 }, primes)
   end)
end)

describe("filter", function()
   it("keep elements for which property is truthy", function()
      local is_small_prime = function(x)
         return List.includes({ 2, 3, 5, 7 }, x)
      end
      local numbers = List:new { 4, 7, 2, 9, 5, 11 }
      assert.are_same({ 7, 2, 5 }, numbers:filter(is_small_prime))
   end)
end)

describe("find", function()
   it("returns element and index if found", function()
      local list = List:new { 5, 23, 71 }
      local elem, idx = list:find(71)
      assert.are_same(71, elem)
      assert.are_same(3, idx)
   end)
   it("respects start index", function()
      local list = List:new { 19, 23, 29, 71 }
      assert.are_equal(23, list:find(23, 1))
      assert.are_equal(23, list:find(23, 2))
      assert.is_nil(list:find(23, 3))
   end)
   it("returns nil if element not found", function()
      assert.is_nil((List:new { 18, 20, 22, 0, 24 }):find "0")
   end)
end)

describe("find_if", function()
   it("returns element and index if found", function()
      local perm_prime = List:new { 2, 3, 5, 7, 11, 13, 17, 31, 37, 71 }
      local elem, idx = perm_prime:find_if(function(x)
         return x >= 10
      end)
      assert.are_same(11, elem)
      assert.are_same(5, idx)
   end)
   it("returns nil if element not found", function()
      local is_null = function(n)
         return List.includes({ 23, 35, 46, 59 }, n)
      end
      assert.is_nil((List:new { 18, 20, 22, 24, 27 }):find_if(is_null))
   end)
end)

describe("includes", function()
   it("finds elements in list", function()
      local lst = List:new { "one", "two", "three" }
      assert.is_truthy(lst:includes "one")
      assert.is_truthy(lst:includes "two")
      assert.is_truthy(lst:includes "three")
      assert.is_falsy(lst:includes "four")
   end)
end)

describe("insert", function()
   it("insert value at end of list.", function()
      local count_norsk = List { "en", "to", "tre" }
      count_norsk:insert "fire"
      assert.are_same({ "en", "to", "tre", "fire" }, count_norsk)
   end)
   it("insert value in the middle of list.", function()
      local count_norsk = List { "fem", "syv" }
      count_norsk:insert(2, "seks")
      assert.are_same({ "fem", "seks", "syv" }, count_norsk)
   end)
end)

describe("map", function()
   it("applies function to elements", function()
      local primes = List:new { 2, 3, 5, 7 }
      local squares = primes:map(function(x)
         return x ^ 2
      end)
      assert.are_same({ 4, 9, 25, 49 }, squares)
   end)
   it("leaves original list unchanged", function()
      local primes = List:new { 2, 3, 5, 7 }
      local squares = primes:map(function(x)
         return x ^ 2
      end)
      assert.are_same({ 2, 3, 5, 7 }, primes)
   end)
end)

describe("new", function()
   it("make table usable as list", function()
      local it = List:new { 1, 1, 2, 3, 5 }
      assert.are_same(
         { 1, 1, 4, 9, 25 },
         it:map(function(x)
            return x ^ 2
         end)
      )
   end)
   it("return empty list if no argument is given", function()
      assert.are_same({}, List:new())
   end)
   it("metatable of result is pandoc.List", function()
      local it = List:new { 5 }
      assert.are_equal(List, getmetatable(it))
   end)
end)

describe("remove", function()
   it("remove value at end of list.", function()
      local understand = List { "jeg", "forstår", "ikke" }
      local norsk_not = understand:remove()
      assert.are_same({ "jeg", "forstår" }, understand)
      assert.are_equal("ikke", norsk_not)
   end)
   it("remove value at beginning of list.", function()
      local count_norsk = List { "en", "to", "tre" }
      count_norsk:remove(1)
      assert.are_same({ "to", "tre" }, count_norsk)
   end)
end)

describe("sort", function()
   it("sort numeric list", function()
      local numbers = List { 71, 5, -1, 42, 23, 0, 1 }
      numbers:sort()
      assert.are_same({ -1, 0, 1, 5, 23, 42, 71 }, numbers)
   end)
   it("reverse-sort numeric", function()
      local numbers = List { 71, 5, -1, 42, 23, 0, 1 }
      numbers:sort(function(x, y)
         return x > y
      end)
      assert.are_same({ 71, 42, 23, 5, 1, 0, -1 }, numbers)
   end)
end)
