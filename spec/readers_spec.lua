local pandoc = require "_treedoc"

local eq = assert.are.same

vim.treesitter.language.add("html", {
   path = vim.fn.expand "~/.luarocks/lib/luarocks/rocks-5.1/tree-sitter-html/0.0.29-1/parser/html.so",
})

describe("html", function()
   it("should convert headers", function()
      local src = "<h1>hello world</h1>" -- TODO: ok for now
      local ast = pandoc.read(src, "html")
      eq("hello", ast.blocks[1].content[1].content[1].text) -- TODO: marshal
      eq(1, ast.blocks[1].level)
   end)

   it("should convert link", function()
      local src = '<a href="www.com">this is example</a>'
      local ast = pandoc.read(src, "html")
      eq("www.com", ast.blocks[1].attr.href)
      eq("this", ast.blocks[1].content[1].content[1].text)
   end)

   it("should convert em/strong", function()
      local src = "<em>emph</em>"
      local ast = pandoc.read(src, "html")
      eq("emph", ast.blocks[1].content[1].content[1].text)
      eq("Emph", ast.blocks[1].tag)

      src = "<strong>strong</strong>"
      ast = pandoc.read(src, "html")
      eq("strong", ast.blocks[1].content[1].content[1].text)
      eq("Strong", ast.blocks[1].tag)
   end)

   it("should convert div/span", function()
      local src = [[<div class="language-plaintext highlighter-rouge"><div class="highlight"><pre class="highlight"><code>:set laststatus=3 </code></pre></div> </div>]]
      local ast = pandoc.read(src, "html")
      eq({ "language-plaintext", "highlighter-rouge" }, ast.blocks[1].attr.class)
      src = [[<span class="c1">-- Using a Lua function in a key mapping prior to 0.7</span>]]
      local ast = pandoc.read(src, "html")
      eq({ "c1" }, ast.blocks[1].attr.class)
   end)

   it("should convert lists", function()
      local src = [[
<ol> 
<li>1</li> 
<li>2</li> 
</ol>
]]
      local ast = pandoc.read(src, "html")
      -- Pr(ast) -- TODO:
   end)
end)
