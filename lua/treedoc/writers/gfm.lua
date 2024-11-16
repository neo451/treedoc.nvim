-- md.br = function(_)
--    return "\n"
-- end
--
-- md.hr = function(_)
--    return "\n==================================================\n"
-- end

--- TODO: typewise traversal!!!!
local M = {}

setmetatable(M, {
   __index = function(t, k)
      -- print(k)
      if not rawget(t, k) then
         return function(node)
            -- print(vim.inspect(node))
            return "<<<" .. vim.inspect(node) .. ">>>"
         end
      end
   end,
})

local ut = require "treedoc.utils"

function M.Header(node)
   local hash = ("#"):rep(node.level) .. " "
   return hash .. ut.stringify(node)
end

function M.Link(node)
   return ("[%s](%s)"):format(table.concat(node.content, " "), node.target)
end

function M.Str(node)
   return node.text
end

function M.Space(_)
   return " "
end

function M.SoftBreak(_)
   return "\n"
end

function M.Para(node)
   return table.concat(node.content, " ")
end

function M.Strong(node)
   return ("**%s**"):format(table.concat(node.content, ""))
end

function M.Emph(node)
   return ("*%s*"):format(table.concat(node.content, ""))
end

function M.Plain(node)
   return table.concat(node.content)
end

function M.OrderedList(node)
   local buf = {}
   for i, v in ipairs(node.content) do
      buf[#buf + 1] = i .. ". " .. v
   end
   buf[#buf + 1] = "\n"
   return table.concat(buf, "\n")
end

function M.BulletList(node)
   local buf = {}
   for i, v in ipairs(node.content) do
      buf[i] = "- " .. v
   end
   buf[#buf + 1] = "\n"
   return table.concat(buf, "\n")
end

function M.Div(node)
   return "\n" .. table.concat(node.content, "\n\n") .. "\n"
end

function M.Span(node)
   return table.concat(node.content, " ")
end

function M.Code(node) -- TODO:
   return ("`%s`"):format(node.text)
end

---@param node TDInline
---@return string
function M.CodeBlock(node)
   return ([[```%s
%s
```]]):format(node.attr.lang, node.text) .. "\n"
end

function M.Image(node)
   return ("![image](%s)"):format(node.src)
end

function M.Figure(node)
   return table.concat(node.content, "\n")
end

function M.Caption(node)
   return table.concat(node.short)
end

function M.BlockQuote(node)
   return "\n>  " .. table.concat(node.content, " ") .. "\n"
end

function M.RawBlock(node)
   return table.concat(node.content, " ")
end

function M.LineBreak()
   return "\n"
end

function M.DefinitionList(node)
   local buf = {}
   for i = 1, #node.content, 2 do
      local dt, dd = node.content[i], node.content[i + 1]
      buf[#buf + 1] = dt
      buf[#buf + 1] = "\n"
      buf[#buf + 1] = dd
      buf[#buf + 1] = "\n\n"
   end
   return table.concat(buf, "")
end

function M.Pandoc(doc) -- DOC walk
   local res = doc:walk(M)
   return table.concat(res.blocks, "\n\n")
end

return M
