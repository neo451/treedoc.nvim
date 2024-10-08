vim.treesitter.language.add("html", {
   path = vim.fn.expand "~/.luarocks/lib/luarocks/rocks-5.1/tree-sitter-html/0.0.29-1/parser/html.so",
})

vim.treesitter.language.add("xml", {
   path = vim.fn.expand "~/.luarocks/lib/luarocks/rocks-5.1/tree-sitter-xml/0.0.29-1/parser/xml.so",
})

local treedoc = require "treedoc"
local eq = assert.are.same

-- local sourced_file = require("plenary.debug_utils").sourced_filepath()
-- local data_dir = vim.fn.fnamemodify(sourced_file, ":h") .. "/data/"

local function xml(src)
   return treedoc.parse(src, { language = "xml" })
end

local function html(src)
   return treedoc.parse(src, { language = "html" })
end

describe("xml", function()
   it("should do simple elements", function()
      eq({ title = "arch by the way" }, xml("<title>arch by the way</title>")[1])
   end)
   it("should do nested elements", function()
      local src2 = [[<pre>
<channel>
		<title>arch</title>
		<link>https://archlinux.org/feeds/news/</link>
</channel>
</pre>]]
      local expected = {
         pre = {
            channel = {
               title = "arch",
               link = "https://archlinux.org/feeds/news/",
            },
         },
      }
      eq(expected, xml(src2)[1])
   end)
   it("should do attrs", function()
      local src = [[<rss version="2.0">rss feeds here</rss>]]
      local expected = { rss = { version = "2.0", [1] = "rss feeds here" } }
      eq(expected, xml(src)[1])
   end)
   it("should do self closing tags", function()
      local src = [[<outline a="b" c="d"/>]]
      eq({ outline = { a = "b", c = "d" } }, xml(src)[1])
   end)
   it("should put same named tags into one array", function()
      local src = [[<rss>
<item>1</item>
<item>2</item>
<item>3</item>
</rss>]]
      local expected = { rss = { item = { "1", "2", "3" } } }
      eq(expected, xml(src)[1])
   end)
end)

describe("html", function()
   it("should parse simple elements", function()
      local src = [[<html a="sda">asdasd</html>]]
      local ast = html(src)[1]
      eq({ tag = "html", a = "sda", "asdasd" }, ast)
   end)
   it("should parse self closing tags", function()
      local src = [[<html a="sda"/>]]
   end)
   it("should parse nested lists and divs", function()
      local src = [[
<div>
  <h1>Heading</h1>

  <ul>
    <li>Item 1</li>
    <li>Item 2</li>
  </ul>
</div>]]
      local expected = {
         tag = "div",
         { tag = "h1", "Heading" },
         {
            tag = "ul",
            { tag = "li", "Item 1" },
            { tag = "li", "Item 2" },
         },
      }
      local ast = html(src)[1]
      eq(ast, expected)
   end)
end)
