local ut = require "treedoc.utils"
local List = { __class = "List" }

List.__index = List
-- List.__eq = eq -- TODO: wrong

function List:__tostring()
   return ut.list_tostring(self, "%s")
end

function List:clone()
   return setmetatable(ut.clone(self), List)
end

function List:new(t)
   if not vim.islist(t) then
      t = { t }
   end
   return setmetatable(t or {}, List)
end

function List:extend(other)
   for _, v in ipairs(other) do
      self[#self + 1] = v
   end
end

function List:filter(f)
   return vim.iter(self):filter(f):totable()
end

function List:includes(elem)
   return vim.iter(self):find(elem) ~= nil
end

function List:find(elem, start)
   start = start or 1
   for i = start, #self do
      local v = self[i]
      if v == elem then
         return v, i
      end
   end
end

function List:find_if(f)
   for i, v in ipairs(self) do
      if f(v) then
         return v, i
      end
   end
end

function List:insert(elem_or_idx, elem)
   if elem then
      table.insert(self, elem_or_idx, elem)
   else
      table.insert(self, elem_or_idx)
   end
end

function List:map(f)
   local res = {}
   for i, v in ipairs(self) do
      res[i] = f(v)
   end
   return res
end

function List:remove(idx)
   idx = idx or #self
   return table.remove(self, idx)
end

function List:sort(f)
   f = f or function(a, b)
      return a < b
   end
   table.sort(self, f)
end

List = setmetatable(List, {
   __call = function(self, t)
      return self:new(t)
   end,
})

return List
