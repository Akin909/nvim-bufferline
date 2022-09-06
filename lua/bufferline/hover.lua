---@diagnostic disable: param-type-mismatch
local fn, api, map = vim.fn, vim.api, vim.keymap.set

local hover_time = 500
local hover_timer = nil
local previous_pos = nil

local M = {}

local function on_hover(current)
  if vim.o.laststatus == 0 then return end
  if current.screenrow == 1 then
    api.nvim_exec_autocmds("User", {
      pattern = "BufferLineHoverOver",
      data = { cursor_pos = current.screencol },
    })
  elseif previous_pos and previous_pos.screenrow == 1 and current.screenrow ~= 1 then
    api.nvim_exec_autocmds("User", { pattern = "BufferLineHoverOut", data = {} })
  end
  previous_pos = current
end

function M.setup()
  if vim.version().minor < 8 or not vim.o.mousemoveevent then return end

  map({ "", "i" }, "<MouseMove>", function()
    if hover_timer then hover_timer:close() end
    hover_timer = vim.defer_fn(function()
      hover_timer = nil
      on_hover(fn.getmousepos())
    end, hover_time)
    return "<MouseMove>"
  end, { expr = true })
end

return M
