local treedoc = require "treedoc"
local conv = require "treedoc.writers.markdown"

local eq = assert.are.same

vim.treesitter.language.add("html", {
   path = vim.fn.expand "~/.luarocks/lib/luarocks/rocks-5.1/tree-sitter-html/0.0.29-1/parser/html.so",
})

local function md(str)
   return conv(treedoc.parse(str, { language = "html" })[1])
end

describe("markdown", function()
   it("should convert simple element", function()
      local res = md [[<h2>sdasdad</h2>]]
      local expected = "## sdasdad"
      eq(expected, res)
   end)

   it("should do attr", function()
      local res = md [[<a href="google.com">google</a>]]
      local expected = "[google](google.com)"
      eq(expected, res)
   end)

   it("should do nested", function()
      local res = md [[<h1><a href="g.com">google</a></h1>]]
      local expected = "# [google](g.com)"
      eq(expected, res)
   end)

   it("img", function()
      local src = [[<img src="https://erbingeditor.diershoubing.com/38/2024/09/06/0938026436.jpg" referrerpolicy="no-referrer">]]
      local expected = "![image](https://erbingeditor.diershoubing.com/38/2024/09/06/0938026436.jpg)"
      local res = md(src)
      eq(expected, res)
   end)

   it("should convert markdown to html", function()
      local src = [[
<div>
  <h1>Heading</h1>
  <h2>Heading2</h2>
  <ol>
    <li><a href="g.com">google</a> is shasdasd</li>
    <li>Item 2</li>
    <li><img src="https://erbingeditor.diershoubing.com/38/2024/09/06/0938026436.jpg" referrerpolicy="no-referrer"></li>
  </ol>
</div>
]]
      local expected = [[# Heading
## Heading2
1. [google](g.com) is shasdasd
2. Item 2
3. ![image](https://erbingeditor.diershoubing.com/38/2024/09/06/0938026436.jpg)]]
      local res = md(src)
      eq(expected, res)
   end)
end)
