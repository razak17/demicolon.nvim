local ts_repeatable_move = require('nvim-treesitter.textobjects.repeatable_move')

local M = {}

---@param func fun(opts: table | { forward: boolean }) Repeatable function to be called. It should determine by the `forward` boolean whether to move forward or backward
---@param opts table | { forward: boolean } Options to pass to the function. Make sure to include the `forward` boolean
function M.repeatably_do(func, opts)
  opts = opts or {}
  ts_repeatable_move.last_move = {
    func = func,
    opts = opts,
    additional_args = {},
  }

  func(opts)
end

---@param key 't' | 'T' | 'f' | 'F'
---@return fun(): string
function M.horizontal_jump(key)
  return function()
    return ts_repeatable_move['builtin_' .. key .. '_expr']()
  end
end

---@deprecated Use horizontal_jump instead
function M.horizontal_jump_repeatably(opts)
  vim.notify('diagnostic.nvim: `horizontal_jump_repeatably` is deprecated. Use `horizontal_jump` instead.')
  return M.horizontal_jump(opts)
end

---@class DemicolonDiagnosticJumpOpts: vim.diagnostic.JumpOpts
---@field forward boolean

---@param opts DemicolonDiagnosticJumpOpts Note that the `count` field will be overridden by `vim.v.count1`
---@return function
function M.diagnostic_jump(opts)
  return function()
    M.repeatably_do(function(o)
      o = o or {}
      local options = require('demicolon').get_options()
      o.float = vim.tbl_extend('force', o, options.diagnostic.float)

      local count = o.forward and 1 or -1
      o.count = count * vim.v.count1

      vim.diagnostic.jump(o)
    end, opts)
  end
end

---@deprecated Use `diagnostic_jump` instead
function M.diagnostic_jump_repeatably(opts)
  vim.notify('diagnostic.nvim: `diagnostic_jump_repeatably` is deprecated. Use `diagnostic_jump` instead.')
  return M.diagnostic_jump(opts)
end

return M
