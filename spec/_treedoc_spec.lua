local treedoc = require "_treedoc"

vim.treesitter.language.add("html", {
   path = vim.fn.expand "~/.local/share/nvim/lazy/nvim-treesitter/parser/html.so",
})

local eq = assert.same

describe("html", function()
   it("should do simple paragraph", function()
      local ast = treedoc.parse("<p>&lt;hello</p>", { language = "html" })[1]
      eq('Para [ Str "<hello" ]', tostring(ast))
   end)
   it("should do simple paragraph", function()
      local ast = treedoc.parse("<h1>&lt;hello</h1>", { language = "html" })[1]
      eq('Header [ Str "<hello" ]', tostring(ast))
   end)
end)
