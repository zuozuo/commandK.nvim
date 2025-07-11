local M = {}

local input_win = nil
local original_buf = nil
local original_cursor_pos = nil
local original_visual_selection = nil
local last_user_input = ""  -- 新增变量存储用户输入
local current_input_value = "" -- 存储当前输入

local function reset_state()
  input_win = nil
  -- 保留 last_user_input 不清除
  original_buf = nil
  original_cursor_pos = nil
  original_visual_selection = nil
end

function M.get_code_context(window_size)
  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  local current_line = cursor_pos[1]
  local buf = vim.api.nvim_get_current_buf()

  local start_line = math.max(1, current_line - window_size)
  local end_line = current_line + window_size

  local lines = vim.api.nvim_buf_get_lines(buf, start_line - 1, end_line, false)

  -- Add line numbers to each line
  local numbered_lines = {}
  for i, line in ipairs(lines) do
    table.insert(numbered_lines, string.format("%d: %s", start_line + i - 1, line))
  end

  return table.concat(numbered_lines, "\n")
end

function M.create()
  local config = require("aider-nvim.config").get()

  -- If input window is already open, close it and return to visual mode
  if M.is_open() then
    input_win:close()
    vim.cmd("stopinsert")  -- Ensure we're in normal mode
    last_user_input = current_input_value
    reset_state()
    return
  end

  -- Save original buffer and cursor position
  original_buf = vim.api.nvim_get_current_buf()
  original_cursor_pos = vim.api.nvim_win_get_cursor(0)

  -- Clear previous selection
  original_visual_selection = nil

  -- Save visual selection before mode changes
  local mode = vim.fn.mode()
  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")
  local start_line = start_pos[2]
  local end_line = end_pos[2]

  -- Check if there's an actual selection (start and end positions differ)
  if mode:match("[vV]") then
    local lines = vim.api.nvim_buf_get_lines(original_buf, start_line - 1, end_line, false)
    local numbered_lines = {}
    for i, line in ipairs(lines) do
      table.insert(numbered_lines, string.format("%d: %s", start_line + i - 1, line))
    end
    -- Adjust start_line and end_line to be absolute positions
    start_line = start_line
    end_line = end_line

    original_visual_selection = {
      start_line = start_line,
      end_line = end_line,
      content = numbered_lines
    }
  end

  local on_confirm = function(value)
    -- Store the original buffer before resetting state
    local current_original_buf = original_buf

    -- Always reset state variables whether confirmed or canceled
    if value == nil then
      last_user_input = current_input_value
    else
      last_user_input = ""
      current_input_value = ""
    end
    reset_state()

    if value and #value > 0 then
      -- Restore original buffer reference for the submit
      original_buf = current_original_buf
      -- Get all context information
      local cursor_context = M.get_cursor_context()
      local code_context = M.get_code_context(5)  -- Use window_size of 5
      local visual_selection = M.get_original_visual_selection()

      -- Build the context message
      local context_message = "Current Cursor Line:\n"
      context_message = context_message .. string.format("Line %d, Col %d: %s\n\n", 
        cursor_context.line, cursor_context.col, cursor_context.content)

      context_message = context_message .. "Code Context:\n" .. code_context .. "\n\n"

      if visual_selection then
        context_message = context_message .. "User Selection:\n"
        context_message = context_message .. table.concat(visual_selection.content, "\n") .. "\n\n"
      end

      -- Combine context with user input
      local full_message = context_message .. "User Requirement:\n" .. value

      -- require("aider-nvim.chat").submit(full_message)
      require("aider-nvim.chat").submit_to_terminal(full_message)
    end
  end

  -- Get current cursor position and window information
  local current_cursor = vim.api.nvim_win_get_cursor(0)
  local cursor_row, cursor_col = unpack(current_cursor)
  local win_info = vim.fn.getwininfo(vim.api.nvim_get_current_win())[1]

  -- Calculate absolute row position relative to editor
  local win_topline = win_info.topline - 1  -- 0-based
  local win_height = win_info.height
  local win_row = cursor_row - 1 - win_topline  -- 0-based relative to window

  -- Calculate absolute position considering window position
  local abs_row = win_info.winrow + win_row -1 -- 0-based screen position

  -- Ensure minimum left position from config
  local input_min_left_position = config.input_min_left_position or 8
  cursor_col = math.max(cursor_col, input_min_left_position)

  input_win = require("snacks.input").input({
    prompt = config.prompt,
    default = last_user_input,  -- 恢复上次输入
    win = {
      relative = "editor",
      height = 1,
      width = 100,
      wo = {
        winhighlight = "NormalFloat:SnacksInputNormal,FloatBorder:SnacksInputBorder,FloatTitle:SnacksInputTitle",
        cursorline = false,
      },
      anchor = "NW",
      row = abs_row,  -- Use absolute screen position
      col = cursor_col
    },
  }, on_confirm)

  vim.api.nvim_buf_attach(input_win.buf, false, {                                     
    on_lines = function(_, _, _, _, _, _)                                             
      local lines = vim.api.nvim_buf_get_lines(input_win.buf, 0, -1, false)           
      current_input_value = lines[1] or ""                                                  
    end                                                                               
  })                                                                                  

  vim.api.nvim_buf_set_option(input_win.buf, "completefunc", "v:lua.require'aider-nvim.chat.buffer'.complete_quick_commands")
  vim.api.nvim_buf_set_keymap(input_win.buf, "i", "/", "<cmd>call complete(col('.'), v:lua.require'aider-nvim.chat.buffer'.complete_quick_commands())<CR>", {noremap = true, silent = true})
end

function M.is_open()
  return input_win ~= nil
end

function M.get_original_buf()
  return original_buf
end

function M.get_original_cursor_pos()
  return original_cursor_pos
end

function M.get_original_visual_selection()
  return original_visual_selection
end

function M.get_cursor_context()
  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  local current_line = cursor_pos[1]
  local current_col = cursor_pos[2]
  local buf = vim.api.nvim_get_current_buf()
  local line_content = vim.api.nvim_buf_get_lines(buf, current_line - 1, current_line, false)[1] or ""

  return {
    line = current_line,
    col = current_col + 1,  -- 转换为1-based列号
    content = line_content
  }
end

function M.get_current_input_value()                                                        
  return current_input_value                                                                
end                                                                                   

-- 自动补全函数
function M.complete_quick_commands()
  local line = vim.api.nvim_get_current_line()
  local prefix = line:match(".*/(.*)") or ""

  local config = require("aider-nvim.config").get()
  local matches = {}
  for _, cmd in ipairs(config.quick_commands) do
    if cmd:lower():find(prefix:lower(), 1, true) then
      table.insert(matches, {word = cmd, kind = "Quick Command"})
    end
  end

  return matches
end

return M
