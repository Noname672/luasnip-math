local M = {}

local util = require("luasnip.util.util")

function M.consume_slash(snippet, line_to_cursor, match, captures) 
  local index = -1-#match
  local has_slash = line_to_cursor:sub(index,index) == '\\'

  local pos = util.get_cursor_0ind()

  local res = {
    env_override = {
      FULL = (has_slash and '\\' or '') .. match
    },
    clear_region= {
      from = {pos[1], pos[2] - #match - (has_slash and 1 or 0)},
      to = pos
    }
  }

  return res
end

return M
