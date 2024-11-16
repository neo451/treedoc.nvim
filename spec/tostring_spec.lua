local pandoc = require "treedoc.contructors"

local eq = assert.equal

--- TODO: pipe to pandoc-lua to verify

describe("", function()
   it("should do inline with text", function()
      local res = tostring(pandoc.Str "hello")
      eq('Str "hello"', res)
   end)
   it("should do inline with attr", function()
      local res = pandoc.Attr("hello", { "a", "b" }, { other = "c" })
      eq([[("hello",["a","b"],[("other","c")])]], tostring(res))
      local code = pandoc.Code("local a = 1", { id = "hello", class = "a b", other = "c" })
      eq([[Code ("hello",["a","b"],[("other","c")]) "local a = 1"]], tostring(code))
      local span = pandoc.Span({ pandoc.Str "hi", pandoc.Space(), pandoc.Str "yoo" }, { id = "hello", class = "a b", other = "c" })
      eq([=[Span ("hello",["a","b"],[("other","c")]) [Str "hi",Space,Str "yoo"]]=], tostring(span))
   end)

   it("should do blocks with attr", function()
      local res = pandoc.Header(1, { pandoc.Str "hello" }, { id = "a", class = "b", other = "c" })
      print(res)
      -- eq([[("hello",["a","b"],[("other","c")])]], tostring(res))
   end)
end)
