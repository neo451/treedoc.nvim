local ut = {}

function ut.noop() end

ut.tree_contains = function(node, T)
   for child in node:iter_children() do
      if child:type() == T then
         return true
      end
   end
   return false
end

---@param str string
---@return TSNode
ut.get_root = function(str, language)
   local parser = vim.treesitter.get_string_parser(str, language)
   return parser:parse()[1]:root()
end

---@param node TSNode?
---@param src string
---@return string
ut.get_text = function(node, src)
   if not node then
      return "empty node"
   end
   return vim.treesitter.get_node_text(node, src)
end

ut.list_tags = function(lang)
   local info = vim.treesitter.language.inspect(lang)
   local iter = vim.iter(info.symbols)
   return iter:fold({}, function(acc, v)
      if v[2] then
         acc[#acc + 1] = v[1]
      end
      return acc
   end)
end

ut.list_tostring = function(obj)
   local buf = {}
   for _, v in ipairs(obj.content) do
      buf[#buf + 1] = tostring(v)
   end
   return ("%s [ %s ]"):format(obj.tag, table.concat(buf, " "))
end

return ut
