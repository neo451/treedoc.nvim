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

ut.clone = function(t)
   local new = {}
   for k, value in pairs(t) do
      new[k] = (type(value) == "table" and value.__class) and value:clone() or value
   end
   return new
end

ut.equals = function(a, b)
   return a == b
end

local list_concat = function(t)
   local buf = {}
   for _, v in ipairs(t) do
      buf[#buf + 1] = ut.stringify(v)
   end
   return table.concat(buf, "")
end

local dict_concat = function(t)
   local buf = {}
   for _, v in vim.spairs(t) do
      buf[#buf + 1] = ut.stringify(v)
   end
   return table.concat(buf, "")
end

ut.stringify = function(a)
   if type(a) == "table" then
      if a.text then
         return a.text
      elseif a.tag == "Space" then
         return " "
      elseif ut.type(a) == "Meta" then
         return dict_concat(a)
      elseif ut.type(a) == "Inline" or ut.type(a) == "Block" then
         return list_concat(a.content)
      elseif ut.type(a) == "List" or ut.type(a) == "Inlines" or ut.type(a) == "Blocks" then
         return list_concat(a)
      elseif ut.type(a) == "Attribute" then
         return ""
      end
   end
   return tostring(a)
end

ut.type = function(a)
   if type(a) == "table" and a.__class then
      return a.__class
   end
   return type(a)
end

-- ut.sha1 = require "feed.sha1" -- HACK:

-- Copyright (C) 2012 LoDC
local map = {
   I = 1,
   V = 5,
   X = 10,
   L = 50,
   C = 100,
   D = 500,
   M = 1000,
}
local numbers = { 1, 5, 10, 50, 100, 500, 1000 }
local chars = { "I", "V", "X", "L", "C", "D", "M" }

function ut.to_roman_numeral(s)
   --s = tostring(s)
   s = tonumber(s)
   if not s or s ~= s then
      error "Unable to convert to number"
   end
   if s == math.huge then
      error "Unable to convert infinity"
   end
   s = math.floor(s)
   if s <= 0 then
      return s
   end
   local ret = ""
   for i = #numbers, 1, -1 do
      local num = numbers[i]
      while s - num >= 0 and s > 0 do
         ret = ret .. chars[i]
         s = s - num
      end
      --for j = i - 1, 1, -1 do
      for j = 1, i - 1 do
         local n2 = numbers[j]
         if s - (num - n2) >= 0 and s < num and s > 0 and num - n2 ~= n2 then
            ret = ret .. chars[j] .. chars[i]
            s = s - (num - n2)
            break
         end
      end
   end
   return ret
end

function ut.roman_to_number(s)
   s = s:upper()
   local ret = 0
   local i = 1
   while i <= s:len() do
      --for i = 1, s:len() do
      local c = s:sub(i, i)
      if c ~= " " then -- allow spaces
         local m = map[c] or error("Unknown Roman Numeral '" .. c .. "'")

         local next = s:sub(i + 1, i + 1)
         local nextm = map[next]

         if next and nextm then
            if nextm > m then
               -- if string[i] < string[i + 1] then result += string[i + 1] - string[i]
               -- This is used instead of programming in IV = 4, IX = 9, etc, because it is
               -- more flexible and possibly more efficient
               ret = ret + (nextm - m)
               i = i + 1
            else
               ret = ret + m
            end
         else
            ret = ret + m
         end
      end
      i = i + 1
   end
   return ret
end

---@param t table
---@param item_format string
---@return string
ut.list_tostring = function(t, item_format)
   local buf = { "[" }
   for _, v in ipairs(t) do
      buf[#buf + 1] = (item_format):format(v)
      buf[#buf + 1] = ","
   end
   buf[#buf] = "]"
   return table.concat(buf)
end

---@param t table<string, string>
---@return string
ut.dict_tostring = function(t)
   local buf = { "[" }
   for k, v in pairs(t) do
      if k ~= "id" and k ~= "class" then
         buf[#buf + 1] = ("(%q,%q)"):format(k, v)
         buf[#buf + 1] = ","
      end
   end
   buf[#buf] = "]"
   return table.concat(buf)
end

return ut
