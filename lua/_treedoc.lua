local M = {}
local ut = require "treedoc.utils"

-- https://hackage.haskell.org/package/pandoc-types-1.23.1/docs/Text-Pandoc-Definition.html#t:Block

M.rules = {}

-- TODO: lazy load handlers
M.rules.xml = require "treedoc.xml"
M.rules.html = require "treedoc.readers.html"

-- IDEA: none-ls tidy for tidying markup??

---tree-sitter powered parser to turn markup to simple lua table
---@param src string
---@param lang string
---@return treedoc.Doc
function M.read(src, lang)
   lang = lang or "markdown"
   local rules = M.rules[lang]
   local root = ut.get_root(src, lang)
   return rules[root:type()](root, src)
end

M.writer = { markdown = require "treedoc.writers.gfm" }

function M.write(ast, lang)
   return M.writer[lang].Pandoc(ast)
end

return M
