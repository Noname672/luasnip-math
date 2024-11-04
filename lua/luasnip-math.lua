M = {}
local ls = require('luasnip')
local parse_snippet = ls.parser.parse_snippet


local apply = require('luasnip.util.extend_decorator').apply
local conditions = require('condition')
local resolver = require('resolver')

local function condition_wrapper(place, condition)
  local ncondition = conditions[place or 'in_mathzone']
  if condition then
    ncondition = ncondition * condition
  end

  return ncondition
end

function M.make_math_parser(parser, context)
  local condition = condition_wrapper(context.place, context.condition)
  local show_condition = condition_wrapper(context.place, context.condition)

  context.place = nil
  context.condition = nil

  local nparser = apply(parser, {
    condition = condition,
    show_condition = show_condition,
    snippetType = "autosnippet",
    resolveExpandParams = resolver.consume_slash,
  })

  nparser = apply(nparser, context)

  return nparser
end

function M.add_math_snippets(snippets, opts)
  ls.add_snippets('markdown', snippets, opts)
  ls.add_snippets('tex', snippets, opts)
end

function M.math_postfix()
  return 1
end

function M.operator_snippet(context, count)
  count = count or 0
  local body = context.name or context.trig or context
  for i=1,count do
    body = body .. '{$' .. tostring(i) .. '}'
  end

  local parser = M.make_math_parser(parse_snippet, context)

  return parser(body)
end



function M.setup()


  return M
end

return M
