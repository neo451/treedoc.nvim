---@alias treedoc.Block treedoc.Inline | string # TODO:

---@class treedoc.Inline
---@field type treedoc.InlineType
---@field info? table
---@field content? string | string[]

---@enum treedoc.InlineType
local InlineTypes = {
   Str = true,
   Emph = true,
   Underline = true,
   Strong = true,
   Strikeout = true,
   Superscript = true,
   Subscript = true,
   SmallCaps = true,
   Quoted = true,
   Cite = true,
   Code = true,
   Space = true,
   SoftBreak = true,
   LineBreak = true,
   Math = true,
   RawInline = true,
   Link = true,
   Image = true,
   Note = true,
   Span = true,
}

local Treedoc = {}

---@param blocks any
---@param meta any
---@return table
Treedoc.Treedoc = function(blocks, meta)
   return { blocks = blocks, meta = meta }
end

---@param str string
---@return treedoc.Inline
Treedoc.Str = function(str)
   return { tag = "Str", text = str }
end
