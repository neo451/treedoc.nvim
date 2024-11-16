local pandoc = require "treedoc.contructors"

describe("clone", function()
   it("clones Attr", function()
      local attr = pandoc.Attr("test", { "my-class" }, { foo = "bar" })
      local cloned = attr:clone()
      attr.identifier = ""
      attr.classes = {}
      attr.attributes = {}
      assert.are_same(cloned.identifier, "test")
      assert.are_same(cloned.classes, { "my-class" })
      assert.are_same(cloned.attributes.foo, "bar")
   end)
   it("clones ListAttributes", function()
      local la = pandoc.ListAttributes(2, pandoc.DefaultStyle, pandoc.Period)
      local cloned = la:clone()
      la.start = 9
      assert.are_same(cloned.start, 2)
   end)
   it("clones Para", function()
      local para = pandoc.Para { pandoc.Str "Hello" }
      local cloned = para:clone()
      para.content[1].text = "bye"
      assert.are_same(cloned, pandoc.Para { pandoc.Str "Hello" })
   end)
   it("clones Str", function()
      local str = pandoc.Str "Hello"
      local cloned = str:clone()
      str.text = "bye"
      assert.are_same(cloned.text, "Hello")
   end)
   -- it("clones Citation", function()
   --    local cite = pandoc.Citation("leibniz", pandoc.AuthorInText)
   --    local cloned = cite:clone()
   --    cite.id = "newton"
   --    assert.are_same(cloned.id, "leibniz")
   --    assert.are_same(cite.id, "newton")
   --    assert.are_same(cite.mode, cloned.mode)
   -- end)
end)

describe("walk_inline", function()
   it("inline walking order", function()
      local acc = {}
      local nested_nums = pandoc.Span {
         pandoc.Str "1",
         pandoc.Emph {
            pandoc.Str "2",
            pandoc.Str "3",
         },
         pandoc.Str "4",
      }
      pandoc.walk_inline(nested_nums, {
         Str = function(s)
            table.insert(acc, s.text)
         end,
      })
      assert.are_equal("1234", table.concat(acc))
   end)
end)

describe("walk_block", function()
   it("block walking order", function()
      local acc = {}
      local nested_nums = pandoc.Div {
         pandoc.Para { pandoc.Str "1" },
         pandoc.Div {
            pandoc.Para { pandoc.Str "2" },
            pandoc.Para { pandoc.Str "3" },
         },
         pandoc.Para { pandoc.Str "4" },
      }
      pandoc.walk_block(nested_nums, {
         Para = function(p)
            table.insert(acc, p.content[1].text)
         end,
      })
      assert.are_equal("1234", table.concat(acc))
   end)
end)

describe("Marshal", function()
   describe("Inlines", function()
      it("Strings are broken into words", function()
         assert.are_equal(pandoc.Emph "Nice, init?", pandoc.Emph { pandoc.Str "Nice,", pandoc.Space(), pandoc.Str "init?" })
      end)
   end)
   describe("Blocks", function()
      it("Strings are broken into words and wrapped in Plain", function()
         assert.are_equal(
            pandoc.Div {
               pandoc.Plain { pandoc.Str "Nice,", pandoc.Space(), pandoc.Str "init?" },
            },
            pandoc.Div { "Nice, init?" }
         )
      end)
   end)
end)
