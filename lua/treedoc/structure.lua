local M = {}

local td = require "treedoc.contructors"

M.make_sections = function(blks, opts)
   return { td.Div(blks) }
end

return M
