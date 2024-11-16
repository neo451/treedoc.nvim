local ut = require "treedoc.utils"
local List = require "treedoc.list"
local clone = ut.clone

-- TODO: stype | deli
local M = {
   AlignCenter = "AlignCenter",
   AlignDefault = "AlignDefault",
   AlignLeft = "AlignLeft",
   AlignRight = "AlignRight",

   DefaultStyle = "DefaultStyle",
   Example = "Example",
   Decimal = "Decimal",
   LowerRoman = "LowerRoman",
   UpperRoman = "UpperRoman",
   LowerAlpha = "LowerAlpha",
   UpperAlpha = "UpperAlpha",

   DefaultDelim = "DefaultDelim",
   Period = "Period",
   OneParen = "OneParen",
   TwoParens = "TwoParens",
}

local function eq(a, b)
   return tostring(a) == tostring(b) -- HACK:
end

--- four major types that can be walked
--- 1. block
--- 2. blocks
--- 3. inline
--- 4. inlines
---
--- 5. element components
--- 6. reader/writer opts

-- TODO: Traversal
-- "topdown",
-- "typewise", -- Element filter functions within a filter set are called in a fixed order, skipping any which are not present:

--- lists of Inline (or Inline-like) values are used directly;
-- single Inline values are converted into a list containing just that element;
-- String values are split into words, converting line breaks into SoftBreak elements, and other whitespace characters into Spaces.
local function split(t)
   local res = {}
   for v in vim.gsplit(t, " ") do
      res[#res + 1] = M.Str(v)
      res[#res + 1] = M.Space()
   end
   res[#res] = nil
   return res
end

function M.marshal(content, wrap_in_plain)
   if type(content) == "table" and content.__class == "List" then
      return content
   end
   if type(content) == "string" then
      content = split(content)
   end
   if wrap_in_plain then
      for i, v in ipairs(content) do
         if type(v) == "string" then
            content[i] = M.Plain(v)
         end
      end
   end
   return content
end

local block = {
   __class = "Block",
}

local inline = { __class = "Inline" }
inline.__index = inline
inline.__eq = eq

function inline:__tostring()
   if self.content and self.attr then
      return ("%s %s %s"):format(self.tag, self.attr, self.content)
   elseif self.text and self.attr then
      return ("%s %s %q"):format(self.tag, self.attr, self.text)
   elseif self.text then
      return ("%s %q"):format(self.tag, self.text)
   elseif self.tag then
      return self.tag
   end
end

-- TODO: test
block.__index = function(self, k)
   if not rawget(self, k) then
      if rawget(block, k) then
         return rawget(block, k)
      elseif rawget(self, "attr") then
         if rawget(rawget(self, "attr"), k) then
            return rawget(self.attr, k)
         end
      end
   end
   if k == "t" then
      return self.tag
   end
end

block.__eq = eq

function block:__tostring()
   if self.content and self.attr then
      return ("%s %s %s"):format(self.tag, self.attr, self.content)
   elseif self.text and self.attr then
      return ("%s %s %q"):format(self.tag, self.attr, self.text)
   elseif self.text then
      return ("%s %q"):format(self.tag, self.text)
   elseif self.tag then
      return self.tag
   end
end

local function Block(t)
   if t.content then
      t.content = List(M.marshal(t.content, true))
   end
   return setmetatable(t, block)
end

---@param t any
---@return table
local function Inline(t)
   if t.content then
      t.content = List(M.marshal(t.content, false))
   end
   return setmetatable(t, inline)
end

function block:clone()
   return Block(clone(self))
end

function inline:clone()
   return Inline(clone(self))
end

local function walk(t, filters)
   for i, v in ipairs(t.content) do
      if v.walk then
         v = v:walk(filters)
      end
      if filters[v.tag] then
         t.content[i] = filters[v.tag](v)
      end
   end
   return t
end

M.walk_inline = function(self, filters)
   if not self.content then
      return self
   end
   local res = self:clone()
   return walk(res, filters)
end

M.walk_block = function(self, filters)
   if not self.content then
      return self
   end
   local res = self:clone()
   return walk(res, filters)
end

-- Pandoc expects each Lua file to return a list of filters. The filters in that list are called sequentially, each on the result of the previous filter.
inline.walk = M.walk_inline
block.walk = M.walk_block

---[[inlines]]
---@param text any
---@return TDStr
M.Str = function(text)
   return Inline { tag = "Str", text = text }
end

local content_inlines = {
   "Emph",
   "Underline",
   "Strong",
   "Strikeout",
   "Superscript",
   "Subscript ",
   "SmallCaps",
   "Note",
}

for _, v in ipairs(content_inlines) do
   ---@param content any
   ---@return TDInline
   M[v] = function(content)
      return Inline {
         content = content,
         tag = v,
      }
   end
end

local tag_inlines = { "LineBreak", "SoftBreak", "Space" }

for _, v in ipairs(tag_inlines) do
   ---@return TDInline
   M[v] = function()
      return Inline {
         tag = v,
      }
   end
end

---Generic inline container with attributes
---@param content treedoc.Inline[] | treedoc.Inline
---@param attr any
---@return TDInline
M.Span = function(content, attr)
   return Inline {
      tag = "Span",
      content = content,
      attr = attr and M.Attr(attr),
   }
end

---@return TDInline
M.Figure = function(content, caption, attr)
   return Inline {
      content = content,
      caption = caption,
      attr = attr,
      tag = "Figure",
   }
end

---@param content any
---@param citations any
---@return TDInline
M.Cite = function(content, citations)
   return Inline {
      content = content,
      citations = citations,
      tag = "Cite",
   }
end

---@param text any
---@param attr any?
---@return TDInline
M.Code = function(text, attr)
   return Inline {
      text = text,
      attr = attr and M.Attr(attr),
      tag = "Code",
   }
end

---@param caption TDInline[] -- TODO: inlines?
---@param src string path to the image file
---@param title string? brief image description
---@param attr any?
---@return TDInline
M.Image = function(caption, src, title, attr)
   return Inline {
      caption = caption,
      src = src,
      title = title,
      attr = attr and M.Attr(attr),
      tag = "Image",
   }
end

---@param content TDInline[]
---@param target string the link target
---@param title any brief link description
---@param attr any
---@return TDInline
M.Link = function(content, target, title, attr)
   return Inline {
      attr = attr,
      content = content,
      title = title,
      target = target,
      tag = "Link",
   }
end

---@param content TDInline[]
---@param quotetype "SingleQuote" | "DoubleQuote"
---@return TDInline
M.Quoted = function(content, quotetype)
   return Inline {
      quotetype = quotetype,
      content = content,
      tag = "Quoted",
   }
end

---@param text string
---@param format string
---@return TDInline
M.RawInline = function(text, format)
   return Inline {
      text = text,
      format = format,
      tag = "RawInline",
   }
end

---@param text string
---@param mathtype "InlineMath" | "DisplayMath"
---@return table
M.Math = function(text, mathtype)
   return Inline {
      text = text,
      mathtype = mathtype,
      tag = "Math",
   }
end

--- [[Blocks]]

M.ListAttributes = function(start, style, delimiter)
   return Inline {
      start = start,
      style = style,
      delimiter = delimiter,
   }
end

---TODO: complete
--- TODO: ListAttributes share index in mt
M.OrderedList = function(item, listAttributes)
   return Block {
      content = item,
      tag = "OrderedList",
   }
end

---TODO: complete
--- TODO: ListAttributes share index in mt
M.BulletList = function(item, listAttributes)
   return Block {
      content = item,
      tag = "BulletList",
   }
end

---@param content treedoc.Inline | string # TODO: Inline can be a string
---@return table # TODO:
M.Plain = function(content)
   return Block {
      content = content,
      tag = "Plain",
   }
end

---@param content treedoc.Inline[] | string
M.Para = function(content)
   return Block { tag = "Para", content = content }
end

M.RawBlock = function(content, format)
   return Block {
      content = content,
      format = format,
      tag = "RawBlock",
   }
end

---@param content treedoc.Inline | string[] | string
---@return treedoc.Block
M.Div = function(content, attr)
   return Block {
      content = content,
      attr = attr and M.Attr(attr),
      tag = "Div",
   }
end

---@param level integer
---@param content treedoc.Inline[]
---@param attr? table<string, string>
M.Header = function(level, content, attr)
   return Block {
      level = level,
      content = content,
      attr = attr and M.Attr(attr),
      tag = "Header",
   }
end

M.HorizontalRule = function()
   return Block {
      tag = "HorizontalRule",
   }
end

---@param text string
---@param attr any
M.CodeBlock = function(text, attr)
   return Block {
      text = text,
      attr = attr and M.Attr(attr),
      tag = "CodeBlock",
   }
end

M.BlockQuote = function(content)
   return Block {
      content = content,
      tag = "BlockQuote",
   }
end

M.DefinitionList = function(content)
   return Block {
      content = content,
      tag = "DefinitionList",
   }
end

M.TableBody = function(body, head, attr, row_head_colums)
   return
end

M.TableFoot = function(rows, attr)
   return {
      rows = rows,
      attr = attr,
      tag = "TableFoot",
   }
end

--- TODO: attr
M.TableHead = function(rows, attr)
   return {
      rows = rows,
      attr = attr,
      tag = "TableHead",
   }
end

M.Table = function(caption, colspecs, head, bodies, foot, attr)
   return Block {
      caption = caption,
      colspecs = colspecs,
      head = head,
      bodies = bodies,
      foot = foot,
      attr = attr,
   }
end

--- [[element components]]

local attr_mt = { __class = "Attribute" }

attr_mt.__index = function(self, k)
   if not rawget(self, k) then
      if rawget(attr_mt, k) then
         return rawget(attr_mt, k)
      end
      if k == "identifier" then
         return self.id
      end
      if k == "classes" then
         return self.class
      end
   end
end
attr_mt.clone = function(self)
   return setmetatable(clone(self), attr_mt)
end

attr_mt.__tostring = function(self)
   local id = self.id
   local class = ut.list_tostring(self.class, "%q")
   local other = ut.dict_tostring(self)
   return ("(%q,%s,%s)"):format(id, class, other)
end

local function Attr(t)
   if type(t.class) == "string" then
      t.class = vim.split(t.class, " ")
   end
   return setmetatable(t, attr_mt)
end

--- TODO: convient
-- print(pandoc.Attr { id = "hello", class = "a b", a = "451", b = "asdad" })
-- print(pandoc.Attr("hello", { "a", "b" }, { a = "451", b = "asdad" }))

---@param id string
---@param class? string[]
---@param attributes? table<string, string>
M.Attr = function(id, class, attributes)
   local attr = {}
   if type(id) == "table" then
      return Attr(id)
   end
   attr.attributes = attributes
   attr.id = id
   attr.class = class
   return Attr(attr)
end

local doc = {}
doc.__index = doc

-- Applies a Lua filter to the Pandoc element. Just as for full-document filters, the order in which elements are traversed can be controlled by setting the traverse field of the filter; see the section on traversal order. Returns a (deep) copy on which the filter has been applied: the original element is left untouched.
function doc:walk(filter)
   local res = self:clone()
   for i, v in ipairs(self.blocks) do
      if v.walk then
         v = v:walk(filter)
      end
      if filter[v.tag] then
         res.blocks[i] = filter[v.tag](v)
      end
   end
   return res
end

function doc:clone()
   return Doc(clone(self))
end

function doc:__tostring()
   return ("Pandoc Meta! %s"):format(ut.list_tostring(self.blocks, "%s"))
end

function Doc(t)
   return setmetatable(t, doc)
end

--- TODO: filters for Inlines / BLOCKS

M.Inlines = function(list)
   local mt = {
      __class = "Inlines",
   }
   mt.__index = mt
   return setmetatable(List(list), mt)
end

M.Blocks = function(list)
   local mt = {
      __class = "Blocks",
   }
   mt.__index = mt
   return setmetatable(List(list), mt)
end

M.Pandoc = function(blocks, meta)
   return Doc { blocks = blocks, meta = meta }
end

M.List = List

---@param t table<string, any>
M.Meta = function(t)
   local mt = {
      __class = "Meta",
   }
   mt.__index = mt
   return setmetatable(t, mt)
end

M.Caption = function(long, short)
   return {
      long = long,
      short = short,
      tag = "Caption",
   }
end

return M
