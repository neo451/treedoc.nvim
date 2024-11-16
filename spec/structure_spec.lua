local structure = require "treedoc.structure"
local pandoc = require "treedoc.contructors"

-- it("is table", function()
--    assert.are_equal(type(structure), "table")
-- end)
-- --
describe("make_sections", function()
   it("sanity check", function()
      local blks = {
         pandoc.Header(1, { pandoc.Str "First" }),
         pandoc.Header(2, { pandoc.Str "Second" }),
         pandoc.Header(2, { pandoc.Str "Third" }),
      }
      local opts = PANDOC_WRITER_OPTIONS
      local hblks = structure.make_sections(blks, opts)
      assert.are_equal("Div", hblks[1].t)
      assert.are_equal("Header", hblks[1].content[1].t)
   end)

   -- it("respects number_sections", function()
   --    local blks = {
   --       pandoc.Header(1, { pandoc.Str "First" }),
   --       pandoc.Para "Vestibulum convallis, lorem a tempus semper.",
   --    }
   --    local hblks = structure.make_sections(blks, { number_sections = true })
   --    assert.are_equal("Div", hblks[1].t)
   --    assert.are_equal("Header", hblks[1].content[1].t)
   --    assert.are_equal("1", hblks[1].content[1].attributes["number"])
   -- end)
   -- it("respects base_level", function()
   --    local blks = {
   --       pandoc.Header(1, { pandoc.Str "First" }),
   --       pandoc.Para "Curabitur lacinia pulvinar nibh.",
   --       pandoc.Header(3, { pandoc.Str "First" }), -- Skipping level 2
   --    }
   --    local opts = {
   --       number_sections = true,
   --       base_level = 1,
   --    }
   --    local hblks = structure.make_sections(blks, opts)
   --    assert.are_equal("Div", hblks[1].t)
   --    assert.are_equal("Header", hblks[1].content[1].t)
   --    assert.are_equal("1", hblks[1].content[1].attributes["number"])
   --    assert.are_equal("1.0.1", hblks[1].content[3].attributes["number"])
   -- end)
end)

-- describe("split_into_chunks", function()
--    it("is function", function()
--       assert.are_equal(type(structure.split_into_chunks), "function")
--    end)
--    it("returns a chunked doc", function()
--       assert.are_equal(pandoc.utils.type(structure.split_into_chunks(pandoc.Pandoc {})), "ChunkedDoc")
--    end)
-- end)
--
-- describe("table_of_contents", function()
--    it("is function", function()
--       assert.are_equal(type(structure.table_of_contents), "function")
--    end)
--    it("returns a bullet list", function()
--       assert.are_equal(pandoc.utils.type(structure.table_of_contents {}), "Block")
--       assert.are_equal(structure.table_of_contents({}).t, "BulletList")
--    end)
--    it("returns a toc for a list of blocks", function()
--       local body = pandoc.Blocks {
--          pandoc.Header(1, "First"),
--          pandoc.Para "A sentence placed below the first structure.",
--          pandoc.Header(2, "Subsection"),
--          pandoc.Para "Mauris ac felis vel velit tristique imperdiet.",
--          pandoc.Header(1, "Second"),
--          pandoc.Para "Integer placerat tristique nisl.",
--       }
--       assert.are_equal(
--          structure.table_of_contents(body),
--          pandoc.BulletList {
--             { pandoc.Plain "First", pandoc.BulletList { { pandoc.Plain "Subsection" } } },
--             { pandoc.Plain "Second" },
--          }
--       )
--    end)
--    it("returns a toc for a chunked doc", function()
--       local doc = pandoc.Pandoc {
--          pandoc.Header(1, "First", { id = "first" }),
--          pandoc.Para "A sentence placed below the first structure.",
--          pandoc.Header(2, "Subsection", { id = "subsection" }),
--          pandoc.Para "Mauris ac felis vel velit tristique imperdiet.",
--          pandoc.Header(1, "Second", { id = "second" }),
--          pandoc.Para "Integer placerat tristique nisl.",
--       }
--       local chunked = structure.split_into_chunks(doc, { chunk_level = 2 })
--       assert.are_equal(
--          structure.table_of_contents(chunked),
--          pandoc.BulletList {
--             {
--                pandoc.Plain { pandoc.Link("First", "chunk-001#first", "", { id = "toc-first" }) },
--                pandoc.BulletList { { pandoc.Plain { pandoc.Link("Subsection", "chunk-002#subsection", "", { id = "toc-subsection" }) } } },
--             },
--             { pandoc.Plain { pandoc.Link("Second", "chunk-003#second", "", { id = "toc-second" }) } },
--          }
--       )
--    end)
--    it("respects toc-depth option", function()
--       local doc = pandoc.Pandoc {
--          pandoc.Header(1, "First", { id = "first" }),
--          pandoc.Para "A sentence placed below the first structure.",
--          pandoc.Header(2, "Subsection", { id = "subsection" }),
--          pandoc.Para "Mauris ac felis vel velit tristique imperdiet.",
--          pandoc.Header(1, "Second", { id = "second" }),
--          pandoc.Para "Integer placerat tristique nisl.",
--       }
--       local chunked = structure.split_into_chunks(doc)
--       assert.are_equal(
--          structure.table_of_contents(chunked, { toc_depth = 1 }),
--          pandoc.BulletList {
--             { pandoc.Plain { pandoc.Link("First", "chunk-001#first", "", { id = "toc-first" }) } },
--             { pandoc.Plain { pandoc.Link("Second", "chunk-002#second", "", { id = "toc-second" }) } },
--          }
--       )
--    end)
-- end)
