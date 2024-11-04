local M = {}
local ls = require('luasnip')
local parse_snippet = ls.parser.parse_snippet
local postfix = require('luasnip.extras.postfix').postfix


local apply = require('luasnip.util.extend_decorator').apply
local register = require('luasnip.util.extend_decorator').register

local conditions = require('luasnip-math.conditions')
local resolver = require('luasnip-math.resolver')

local function condition_wrapper(place, condition)
  local ncondition = conditions[place or 'in_mathzone']
  if condition then
    return ncondition * condition
  end

  return ncondition
end

function M.make_math_parser(parser, context)
  local function nparser(ctx, body)
    if type(ctx) == 'string' then
      ctx = {trig = ctx}
    end

    local condition = condition_wrapper(ctx.place, ctx.condition)
    local show_condition = condition_wrapper(ctx.place, ctx.show_condition)
    ctx.place = nil
    ctx.condition = nil
    ctx.show_condition = nil
    ctx.consume_slash = false

    return parser(vim.tbl_extend('keep', ctx, {
      condition = condition,
      show_condition = show_condition,
      snippetType = "autosnippet",
      resolveExpandParams = resolver.consume_slash,
    }), body)
  end

  register(nparser, {arg_indx=1})

  return apply(nparser, context)
end

function M.add_math_snippets(snippets, opts)
  ls.add_snippets('markdown', snippets, opts)
  ls.add_snippets('tex', snippets, opts)
end

function M.math_postfix(context, body)
  local parser = M.make_math_parser(postfix, {
    match_pattern = [[\?[%w%.%_%-]+$]],
    resolveExpandParams = function() return {} end
  })
  return parser(context, body)
end

register(M.math_postfix, {arg_indx=1})

function M.operator_snippet(context, count)
  count = count or 0
  local body
  if type(context)=='string' then
    context = {trig = context}
  end
  body = '\\' .. (context.name or context.trig)
  for i=1,count do
    body = body .. '{$' .. tostring(i) .. '}'
  end

  local parser = M.make_math_parser(parse_snippet)
  return parser(context, body)
end

register(M.operator_snippet, {arg_indx=1}, {arg_indx=2})


local setup = false

function M.setup()
  if not setup then
    local math = {
      trig ='mk',
      name = "Math",
    }

    local math_block = {
      trig = 'dm',
      name = "Block Math",
    }

    local parser = M.make_math_parser(parse_snippet, {place = 'in_text'})

    ls.add_snippets('markdown', {
      parser(math, "$$1$"),
      parser(math_block, [[
      $$
      $1 
      $$
      ]])
    })

    ls.add_snippets('tex', {
      parser(math, "$$1$"),
      parser(math_block, [[
      \[
      $1 
      \]
      ]])
    })
    setup = true
  end

  return M
end

return M
