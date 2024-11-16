local ut = require "treedoc.utils"
local html = {}

local treedoc = require "treedoc.contructors"
-- local guesslang = require "treedoc.guesslang"

local get_text = ut.get_text
local noop = ut.noop

setmetatable(html, {
   __index = function(t, k)
      if not rawget(t, k) then
         return noop
      end
   end,
})

local ENTITIES = {
   ["&lt;"] = "<",
   ["&gt;"] = ">",
   ["&amp;"] = "&",
   ["&apos;"] = "'",
   ["&quot;"] = '"',
}

html.document = function(root, src)
   local iterator = vim.iter(root:iter_children())
   local blocks = iterator:fold({}, function(acc, node)
      local T = node:type()
      if not html[T] then
         print(T)
      end
      acc[#acc + 1] = html[T](node, src)
      return acc
   end)
   return treedoc.Pandoc(blocks, {})
end

html.element = function(node, src)
   local tag, attrs = html.start_tag(node:child(0), src)
   local n = node:child_count()
   local content = {}
   for i = 1, n - 2 do
      local child = node:child(i)
      content[#content + 1] = html[child:type()](child, src)
   end
   if tag == "p" then
      return treedoc.Para(content)
   elseif tag:find "h" then
      local level = tonumber(tag:match "%d")
      return treedoc.Header(level or 1, content, attrs)
   elseif tag == "strong" or tag == "b" then
      return treedoc.Strong(content)
   elseif tag == "em" then
      return treedoc.Emph(content)
   elseif tag == "small" then
      return content[1]
   elseif tag == "a" then
      return treedoc.Link(content, attrs.href, nil, attrs) -- TODO: ?
   elseif tag == "code" then
      local text = vim.iter(content):fold("", function(acc, k)
         acc = acc .. "\n" .. ut.stringify(k)
         return acc
      end)
      if #content > 1 then
         local lang
         -- local lang = guesslang(text)
         attrs.lang = lang or ""
         return treedoc.CodeBlock(text, attrs)
      end
      return treedoc.Code(text, attrs)
   elseif tag == "img" then
      return treedoc.Image(content, attrs.src, nil, attrs)
   elseif tag == "pre" then
      return treedoc.RawBlock(content, attrs) -- TODO: ???
   elseif tag == "div" then
      return treedoc.Div(content, attrs)
   elseif tag == "span" then
      return treedoc.Span(content, attrs)
   elseif tag == "blockquote" then
      return treedoc.BlockQuote(content)
   elseif tag == "kbd" then
      return treedoc.Plain(content)
   -- elseif tag == "head" or tag == "meta" then
   --    return treedoc.Meta(content) -- WRONG
   elseif tag == "li" then
      return treedoc.Span(content, attrs) -- HACK:
   elseif tag == "ol" then
      return treedoc.OrderedList(content, attrs)
   elseif tag == "ul" then
      return treedoc.BulletList(content, attrs)
   elseif tag == "figcaption" then
      return treedoc.Caption(content, content) -- TODO:
   elseif tag == "figure" then
      local caption
      if content[#content].tag == "Caption" then
         caption = table.remove(content, #content)
      end
      return treedoc.Figure(content, caption, attrs) -- TODO:
   elseif tag == "sup" then
      return treedoc.Superscript(content)
   elseif tag == "hr" then
      return treedoc.LineBreak()
   elseif tag == "dl" then
      return treedoc.DefinitionList(content)
   elseif tag == "dd" then
      return treedoc.Span(content)
   elseif tag == "dt" then
      return treedoc.Span(content)
   elseif tag == "td" then
      return treedoc.Span(content)
   elseif tag == "th" then
      return treedoc.Span(content)
   elseif tag == "table" then
      local head = table.remove(content, #content)
      return treedoc.Table(nil, nil, head, content, nil)
   end
   return content
end

html.text = function(node, src)
   local text = get_text(node, src)
   return treedoc.Plain(text)
end

html.entity = function(node, src)
   local text = get_text(node, src)
   return treedoc.Str(ENTITIES[text])
end

html.attribute = function(node, src)
   if node:child_count() == 1 then
      return get_text(node, src)
   end
   local k, v = get_text(node:child(0), src), get_text(node:child(2):child(1), src)
   return k, v
end

html.start_tag = function(node, src)
   local tag = get_text(node:child(1), src)
   local attrs = {}
   for child in node:iter_children() do
      if child:type() == "attribute" then
         local k, v = html.attribute(child, src)
         attrs[k] = v
      end
   end
   return tag, attrs
end

html.end_tag = noop

return html
