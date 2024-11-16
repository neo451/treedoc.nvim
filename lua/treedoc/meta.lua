---@alias treedoc.Block treedoc.Inline | string # TODO:

---@class treedoc.Inline
---@field type treedoc.InlineType
---@field info? table
---@field content? string | string[]

---@class TDInline
---@field tag string
---@field t string
---@field content TDInline[]
---@field text string

local a = {}

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
   Note = true,

   Space = true,
   SoftBreak = true,
   LineBreak = true,

   Cite = true,
   Code = true,

   Quoted = true,
   Math = true,
   RawInline = true,
   Link = true,
   Image = true,
   Span = true,
}
