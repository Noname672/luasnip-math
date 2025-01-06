local M = {}

local make_condition = require("luasnip.extras.conditions").make_condition
local get_node_at_cursor = require('nvim-treesitter.ts_utils').get_node_at_cursor

local MATH_NODES = {
  displayed_equation = true,
  inline_formula = true,
  math_environment = true,
}

local TEXT_NODES = {
  text_mode = true,
  label_definition = true,
  label_reference = true,
}

local MAX_DEPTH = 1000


local function in_text()
  local node = get_node_at_cursor()
  local i = 0
  while (node and i < MAX_DEPTH) do
    if node:type() == "text_mode" then
      local parent = node:parent()
      if parent and MATH_NODES[parent:type()] then
        return false
      end
      return true
    elseif MATH_NODES[node:type()] then
      return false
    end
    node = node:parent()
    i = i + 1
  end
  return true
end

local function in_mathzone()
  local node = get_node_at_cursor()
  local i = 0
  while (node and i < MAX_DEPTH) do
    if TEXT_NODES[node:type()] then
      return false
    elseif MATH_NODES[node:type()] then
      return true
    end
    node = node:parent()
    i = i + 1
  end
  return false
end

local function environment()
  if vim.bo.filetype == 'markdown' then
    return in_mathzone()
  else
    return true
  end
end

local function after_expression(line_to_cursor, matched_trigger)
  local index = -1-#matched_trigger
  local char = line_to_cursor:sub(index,index)
  if (char:match('%a')) then
    return true
  end
  return false
end

M.in_mathzone = make_condition(in_mathzone)
M.in_text = make_condition(in_text)
M.environment = make_condition(environment)
M.after_expression = make_condition(after_expression)
M.trivial = make_condition(function() return true end)

return M
