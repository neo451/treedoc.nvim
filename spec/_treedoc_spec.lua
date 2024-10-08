local treedoc = require "_treedoc"
package.path = package.path .. ";/home/n451/.local/share/nvim/lazy/plenary.nvim/lua/?.lua"

vim.treesitter.language.add("html", {
   path = vim.fn.expand "~/.local/share/nvim/lazy/nvim-treesitter/parser/html.so",
})

local eq = assert.same

describe("html", function()
   it("should do simple paragraph", function()
      local ast = treedoc.parse("<p>&lt;hello</p>", { language = "html" })
      eq('Para [ Str "<hello" ]', tostring(ast))
   end)
   it("should do simple paragraph", function()
      --- <h1>hello</h1>
      -- [ Header 1 ( "hello" , [] , [] ) [ Str "hello" ] ]
      local ast = treedoc.parse("<h1>&lt;hello</h1>", { language = "html" })
      eq('Para [ Str "<hello" ]', tostring(ast))
   end)
end)

Treedoc.Treedoc({ Treedoc.Para "Hi" }):walk {
   Str = function(_)
      return "Bye"
   end,
}
