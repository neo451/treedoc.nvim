local ut = require "treedoc.utils"
local treedoc = {}

local traversal_type = {
   "topdown",
   "typewise", -- Element filter functions within a filter set are called in a fixed order, skipping any which are not present:
}

local block_t = {
   "Plain", -- [Inline] Plain text, not a paragraph
   "Para", -- [Inline] Paragraph
   "LineBlock", -- [[Inline]] Multiple non-breaking lines
   "CodeBlock", -- Attr Text Code block (literal) with attributes
   -- RawBlock Format Text Raw block
   -- BlockQuote [Block] Block quote (list of blocks)
   -- OrderedList ListAttributes [[Block]] Ordered list (attributes and a list of items, each a list of blocks)
   -- BulletList [[Block]] Bullet list (list of items, each a list of blocks)
   -- DefinitionList [([Inline], [[Block]])] Definition list. Each list item is a pair consisting of a term (a list of inlines) and one or more definitions (each a list of blocks)
   -- Header Int Attr [Inline] Header - level (integer) and text (inlines)
   -- HorizontalRule Horizontal rule
   -- Table Attr Caption [ColSpec] TableHead [TableBody] TableFoot Table, with attributes, caption, optional short caption, column alignments and widths (required), table head, table bodies, and table foot
   -- Figure Attr Caption [Block] Figure, with attributes, caption, and content (list of blocks)
   -- Div Attr [Block] Generic block container with attributes
}

local List = {}

--- lists of Inline (or Inline-like) values are used directly;
-- single Inline values are converted into a list containing just that element;
-- String values are split into words, converting line breaks into SoftBreak elements, and other whitespace characters into Spaces.
List.new = function(content) -- TODO: placeholder, need custom
   if type(content) == "string" then
      content = vim.split(content, " ") -- TODO: handle linebreaks, spaces
   elseif not vim.islist(content) then
      content = { content }
   end
   return vim.iter(content)
end

--- four major types that can be walked
--- 1. block
--- 2. blocks
--- 3. inline
--- 4. inlines
---
--- 5. element components
--- 6. reader/writer opts

local block = {
   __tostring = ut.list_tostring,
}
block.__index = block

function block:walk(filters)
   for i, v in ipairs(self.blocks) do
      self.blocks[i] = v:walk_inline(filters)
   end
   return self
end

local function Block(t)
   return setmetatable(t, block)
end

local inline = {}
inline.__index = inline

function inline:__tostring()
   -- TODO: more flexible
   return ("%s %q"):format(self.tag, self.text)
end

-- Pandoc expects each Lua file to return a list of filters. The filters in that list are called sequentially, each on the result of the previous filter.
function inline:walk(filters)
   for i, v in ipairs(self.content) do
      if type(v) == "string" then
         v = treedoc.Str(v)
      end
      if filters[v.tag] ~= nil then
         return filters[v.tag](v)
      else
         self.content[i] = v:walk_inline(filters)
      end
   end
   return self
end

function Inline(t)
   return setmetatable(t, inline)
end

local function concat_str(content)
   local concated = {}
   for i = 1, #content - 1 do
      local this, next = content[i], content[i + 1]
      if this.tag == next.tag and this.tag == "Str" then
         concated[#concated + 1] = treedoc.Str(this.text .. next.text)
      end
   end
   if #concated ~= 0 then
      content = concated
   end
   return content
end

---@param content treedoc.Inline | string # TODO: Inline can be a string
---@return table # TODO:
treedoc.Plain = function(content)
   content = List.new(content)
   content = concat_str(content)
   return Block { content = content, tag = "Plain" }
end

---@param content treedoc.Inline[] | string
treedoc.Para = function(content)
   content = List.new(content)
   content = concat_str(content)
   return Block { tag = "Para", content = content }
end

---@param level integer
---@param content treedoc.Inline[]
---@param attr? table<string, string>
treedoc.Header = function(level, content, attr)
   content = List.new(content)
   content = concat_str(content)
   return Block {
      level = level,
      content = content,
      attr = attr and treedoc.attr(attr.identifier, attr.classes, attr.attributes) or {},
      tag = "Header",
   } -- TODO: aliases?
end

--- [[element components]]

---@param id string
---@param classes string[]
---@param attributes table<string, string>
treedoc.Attr = function(id, classes, attributes)
   return { id = id, classes = classes, attributes = attributes }
end

--- [[[Inlines]]]

treedoc.Str = function(text)
   return Inline { tag = "Str", text = text }
end

---@param content treedoc.Inline[] | treedoc.Inline
---@param attr any
treedoc.Span = function(content, attr)
   return Inline {
      tag = "Span",
      content = content,
      attr = treedoc.attr(attr.identifier, attr.classes, attr.attributes),
   }
end

local doc = {}
doc.__index = doc
-- Applies a Lua filter to the Pandoc element. Just as for full-document filters, the order in which elements are traversed can be controlled by setting the traverse field of the filter; see the section on traversal order. Returns a (deep) copy on which the filter has been applied: the original element is left untouched.
function doc:walk() end
function doc:clone() end

function Doc(t)
   setmetatable(t, doc)
end

treedoc.Treedoc = function(blocks, meta)
   return Doc { blocks = blocks, meta = meta }
end

return treedoc
