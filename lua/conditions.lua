local M = {}

local make_condition = require("luasnip.extras.conditions").make_condition
local get_node_at_cursor = require('nvim-treesitter-utils').get_node_at_cursor

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


local function in_text()
  local node = get_node_at_cursor()
  while node do
    if node:type() == "text_mode" then
      return true
    elseif MATH_NODES[node:type()] then
      return false
    end
    node = node:parent()
  end
  return true
end

local function in_mathzone()
  local node = get_node_at_cursor()
  while node do
    if TEXT_NODES[node:type()] then
      return false
    elseif MATH_NODES[node:type()] then
      return true
    end
    node = node:parent()
  end
  return false
end

local function environment()
  if vim.bo.filetype == 'markdown' then
    return in_mathzone()
  else
    return in_text()
  end
end

M.in_mathzone = make_condition(in_mathzone)
M.in_text = make_condition(in_text)
M.environment = make_condition(environment)
M.trivial = make_condition(function() return true end)

return M
