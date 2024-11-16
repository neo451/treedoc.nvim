local pandoc = require "treedoc.contructors"
local utils = require "treedoc.utils"

-- describe("blocks_to_inlines", function()
--    it("default separator", function()
--       local blocks = {
--          pandoc.Para { pandoc.Str "Paragraph1" },
--          pandoc.Para { pandoc.Emph { pandoc.Str "Paragraph2" } },
--       }
--       local expected = {
--          pandoc.Str "Paragraph1",
--          pandoc.LineBreak(),
--          pandoc.Emph { pandoc.Str "Paragraph2" },
--       }
--       assert.are_same(expected, utils.blocks_to_inlines(blocks))
--    end)
--    it("custom separator", function()
--       local blocks = {
--          pandoc.Para { pandoc.Str "Paragraph1" },
--          pandoc.Para { pandoc.Emph "Paragraph2" },
--       }
--       local expected = {
--          pandoc.Str "Paragraph1",
--          pandoc.LineBreak(),
--          pandoc.Emph { pandoc.Str "Paragraph2" },
--       }
--       assert.are_same(expected, utils.blocks_to_inlines(blocks, { pandoc.LineBreak() }))
--    end)
-- end)

describe("equals", function()
   it("compares Pandoc elements", function()
      assert.is_truthy(utils.equals(pandoc.Pandoc { "foo" }, pandoc.Pandoc { "foo" }))
   end)
   it("compares Block elements", function()
      assert.is_truthy(utils.equals(pandoc.Plain { "foo" }, pandoc.Plain { "foo" }))
      assert.is_falsy(utils.equals(pandoc.Para { "foo" }, pandoc.Plain { "foo" }))
   end)
   it("compares Inline elements", function()
      assert.is_truthy(utils.equals(pandoc.Emph { "foo" }, pandoc.Emph { "foo" }))
      assert.is_falsy(utils.equals(pandoc.Emph { "foo" }, pandoc.Strong { "foo" }))
   end)
   it("compares Inline with Block elements", function()
      assert.is_falsy(utils.equals(pandoc.Emph { "foo" }, pandoc.Plain { "foo" }))
      assert.is_falsy(utils.equals(pandoc.Para { "foo" }, pandoc.Strong { "foo" }))
   end)
   it("compares Pandoc with Block elements", function()
      assert.is_falsy(utils.equals(pandoc.Pandoc { "foo" }, pandoc.Plain { "foo" }))
      assert.is_falsy(utils.equals(pandoc.Para { "foo" }, pandoc.Pandoc { "foo" }))
   end)
end)

-- describe("make_sections", function()
--    it("sanity check", function()
--       local blks = {
--          pandoc.Header(1, { pandoc.Str "First" }),
--          pandoc.Header(2, { pandoc.Str "Second" }),
--          pandoc.Header(2, { pandoc.Str "Third" }),
--       }
--       local hblks = utils.make_sections(true, 1, blks)
--       assert.are_equal("Div", hblks[1].t)
--       assert.are_equal("Header", hblks[1].content[1].t)
--       assert.are_equal("1", hblks[1].content[1].attributes["number"])
--    end)
-- end)

-- describe("normalize_date", function()
--    it("09 Nov 1989", function()
--       assert.are_equal("1989-11-09", utils.normalize_date "09 Nov 1989")
--    end)
--    it("12/31/2017", function()
--       assert.are_equal("2017-12-31", utils.normalize_date "12/31/2017")
--    end)
-- end)

-- describe( "references" , function()
--    it("gets references from doc", function()
--       local ref = {
--          ["author"] = {
--             { given = "Max", family = "Mustermann" },
--          },
--          ["container-title"] = pandoc.Inlines "JOSS",
--          ["id"] = "it",
--          ["issued"] = { ["date-parts"] = { { 2021 } } },
--          ["title"] = pandoc.Inlines {
--             pandoc.Quoted("DoubleQuote", "Interesting"),
--             pandoc.Space(),
--             "work",
--          },
--          ["type"] = "article-journal",
--       }
--       local nocite = pandoc.Cite("@it", { pandoc.Citation("test", "NormalCitation") })
--       local doc = pandoc.Pandoc({}, { nocite = nocite, references = { ref } })
--       assert.are_same({ ref }, pandoc.utils.references(doc))
--    end)
-- end)
--
-- describe( "run_lua_filter" , function()
--    it("runs a filter", function()
--       local doc = pandoc.Pandoc "indivisible words"
--       pandoc.system.with_temporary_directory("lua-filter", function(dir)
--          local filter_path = pandoc.path.join { dir, "it.lua" }
--          local filter = 'function Space() return " " end'
--          local fh = io.open(filter_path, "wb")
--          fh:write(filter)
--          fh:close()
--          assert.are_equal(utils.run_lua_filter(doc, filter_path), pandoc.Pandoc(pandoc.Plain(pandoc.Inlines { "indivisible", " ", "words" })))
--       end)
--    end)

--    it("doesn't change the local environment by default", function()
--       pandoc.system.with_temporary_directory("lua-filter", function(dir)
--          local filter_path = pandoc.path.join { dir, "it.lua" }
--          local foo
--          local filter = "foo = 42"
--          local fh = io.open(filter_path, "wb")
--          fh:write(filter)
--          fh:close()
--          utils.run_lua_filter(pandoc.Pandoc {}, filter_path)
--          assert.is_nil(foo)
--       end)
--    end)
--    it("accepts an environment in which the filter is executed", function()
--       pandoc.system.with_temporary_directory("lua-filter", function(dir)
--          local filter_path = pandoc.path.join { dir, "it.lua" }
--          local filter = "foo = 42"
--          local fh = io.open(filter_path, "wb")
--          fh:write(filter)
--          fh:close()
--          utils.run_lua_filter(pandoc.Pandoc {}, filter_path, _ENV)
--          assert.are_equal(_ENV.foo, 42)
--       end)
--    end)
-- end)
--
describe("sha1", function()
   it("hashing", function()
      local ref_hash = "0a0a9f2a6772942557ab5355d76af442f8f65e01"
      assert.are_equal(ref_hash, utils.sha1 "Hello, World!")
   end)
end)

describe("stringify", function()
   it("Inline", function()
      local inline = pandoc.Emph {
         pandoc.Str "Cogito",
         pandoc.Space(),
         pandoc.Str "ergo",
         pandoc.Space(),
         pandoc.Str "sum.",
      }
      assert.are_equal("Cogito ergo sum.", utils.stringify(inline))
   end)
   it("Block", function()
      local block = pandoc.Para {
         pandoc.Str "Make",
         pandoc.Space(),
         pandoc.Str "it",
         pandoc.Space(),
         pandoc.Str "so.",
      }
      assert.are_equal("Make it so.", utils.stringify(block))
   end)
   it("boolean", function()
      assert.are_equal("true", utils.stringify(true))
      assert.are_equal("false", utils.stringify(false))
   end)
   it("number", function()
      assert.are_equal("5", utils.stringify(5))
      assert.are_equal("23.23", utils.stringify(23.23))
   end)
   it("Attr", function()
      local attr = pandoc.Attr("foo", { "bar" }, { a = "b" })
      assert.are_equal("", utils.stringify(attr))
   end)
   it("List", function()
      local list = pandoc.List { pandoc.Str "a", pandoc.Blocks "b" }
      assert.are_equal("ab", utils.stringify(list))
   end)
   it("Blocks", function()
      local blocks = pandoc.Blocks { pandoc.Para "a", pandoc.Header(1, "b") }
      assert.are_equal("ab", utils.stringify(blocks))
   end)
   it("Inlines", function()
      local inlines = pandoc.Inlines { pandoc.Str "a", pandoc.Subscript "b" }
      assert.are_equal("ab", utils.stringify(inlines))
   end)
   it("Meta", function()
      local meta = pandoc.Meta {
         a = pandoc.Inlines "funny and ",
         b = "good movie",
         c = pandoc.List { pandoc.Inlines { pandoc.Str "!" } },
      }
      assert.are_equal("funny and good movie!", utils.stringify(meta))
   end)
end)

describe("to_roman_numeral", function()
   it("convertes number", function()
      assert.are_equal("MDCCCLXXXVIII", utils.to_roman_numeral(1888))
   end)
   it("fails on non-convertible argument", function()
      assert.is_falsy(pcall(utils.to_roman_numeral, "not a number"))
   end)
end)

describe("type", function()
   it("nil", function()
      assert.are_equal(utils.type(nil), "nil")
   end)
   it("boolean", function()
      assert.are_equal(utils.type(true), "boolean")
      assert.are_equal(utils.type(false), "boolean")
   end)
   it("number", function()
      assert.are_equal(utils.type(5), "number")
      assert.are_equal(utils.type(-3.02), "number")
   end)
   it("string", function()
      assert.are_equal(utils.type "", "string")
      assert.are_equal(utils.type "asdf", "string")
   end)
   it("plain table", function()
      assert.are_equal(utils.type {}, "table")
   end)
   it("List", function()
      assert.are_equal(utils.type(pandoc.List {}), "List")
   end)
   it("Inline", function()
      assert.are_equal(utils.type(pandoc.Str "a"), "Inline")
      assert.are_equal(utils.type(pandoc.Emph "emphasized"), "Inline")
   end)
   it("Inlines", function()
      assert.are_equal(utils.type(pandoc.Inlines { pandoc.Str "a" }), "Inlines")
      assert.are_equal(utils.type(pandoc.Inlines { pandoc.Emph "b" }), "Inlines")
   end)
   it("Blocks", function()
      assert.are_equal(utils.type(pandoc.Para "a"), "Block")
      assert.are_equal(utils.type(pandoc.CodeBlock "true"), "Block")
   end)
   it("Inlines", function()
      assert.are_equal(utils.type(pandoc.Blocks { "a" }), "Blocks")
      assert.are_equal(utils.type(pandoc.Blocks { pandoc.CodeBlock "b" }), "Blocks")
   end)
end)

-- describe( "to_simple_table" , function()
--    it("convertes Table", function()
--       function simple_cell(blocks)
--          return {
--             attr = pandoc.Attr(),
--             alignment = "AlignDefault",
--             contents = blocks,
--             col_span = 1,
--             row_span = 1,
--          }
--       end
--       local tbl = pandoc.Table(
--          { long = { pandoc.Plain {
--             pandoc.Str "the",
--             pandoc.Space(),
--             pandoc.Str "caption",
--          } } },
--          { { pandoc.AlignDefault, nil } },
--          pandoc.TableHead { pandoc.Row { simple_cell { pandoc.Plain "head1" } } },
--          {
--             {
--                attr = pandoc.Attr(),
--                body = { pandoc.Row { simple_cell { pandoc.Plain "cell1" } } },
--                head = {},
--                row_head_columns = 0,
--             },
--          },
--          pandoc.TableFoot(),
--          pandoc.Attr()
--       )
--       local stbl = utils.to_simple_table(tbl)
--       assert.are_equal("SimpleTable", stbl.t)
--       assert.are_equal("head1", utils.stringify(stbl.headers[1]))
--       assert.are_equal("cell1", utils.stringify(stbl.rows[1][1]))
--       assert.are_equal("the caption", utils.stringify(pandoc.Span(stbl.caption)))
--    end)
--    it("fails on para", function()
--       assert.is_falsy(pcall(utils.to_simple_table, pandoc.Para "nope"))
--    end)
-- end)
--
-- describe("from_simple_table", function()
--    it("converts SimpleTable to Table", function()
--       local caption = { pandoc.Str "Overview" }
--       local aligns = { pandoc.AlignDefault, pandoc.AlignDefault }
--       local widths = { 0, 0 } -- let pandoc determine col widths
--       local headers = {
--          { pandoc.Plain "Language" },
--          { pandoc.Plain "Typing" },
--       }
--       local rows = {
--          { { pandoc.Plain "Haskell" }, { pandoc.Plain "static" } },
--          { { pandoc.Plain "Lua" }, { pandoc.Plain "Dynamic" } },
--       }
--       local simple_table = pandoc.SimpleTable(caption, aligns, widths, headers, rows)
--       local tbl = utils.from_simple_table(simple_table)
--       assert.are_equal("Table", tbl.t)
--       assert.are_same({ pandoc.Plain(caption) }, tbl.caption.long)
--       -- reversible
--       assert.are_same(simple_table, utils.to_simple_table(tbl))
--    end)
--    it("empty caption", function()
--       local simple_table = pandoc.SimpleTable({}, { pandoc.AlignDefault }, { 0 }, { { pandoc.Plain "a" } }, { { { pandoc.Plain "b" } } })
--       local tbl = utils.from_simple_table(simple_table)
--       assert.are_equal(pandoc.Blocks {}, tbl.caption.long)
--       assert.is_nil(tbl.caption.short)
--    end)
--    it("empty body", function()
--       local simple_table = pandoc.SimpleTable(pandoc.Inlines "a nice caption", { pandoc.AlignDefault }, { 0 }, { { pandoc.Plain "a" } }, {})
--       local tbl = utils.from_simple_table(simple_table)
--       tbl.bodies:map(print)
--       assert.are_same(pandoc.List(), tbl.bodies)
--    end)
-- end)
