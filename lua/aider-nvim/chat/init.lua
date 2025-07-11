local M = {}
local buffer = require("aider-nvim.chat.buffer")

function M.toggle()
  buffer.create()
end

-- Cache for sent file paths
local sent_files = {}

function M.submit(full_message)
  -- Print the full message for debugging
  -- vim.notify("Submitting full message:\n" .. full_message)
  dd(full_message)

  if not full_message or #full_message == 0 then return end

  local config = require("aider-nvim.config").get()

  -- Create or show the AiderPlus-Chat terminal
  local term_bufnr = vim.fn["floaterm#terminal#get_bufnr"]("AiderPlus-Chat")
  
  if term_bufnr == -1 then
    require("aider-nvim.init").start()
    
    -- Wait for terminal to be ready
    local max_attempts = 6  -- 3 seconds total with 0.5s interval
    local attempt = 1
    local delay = 500  -- milliseconds

    local function wait_for_terminal()
      term_bufnr = vim.fn["floaterm#terminal#get_bufnr"]("AiderPlus-Chat")
      if term_bufnr ~= -1 then
        -- Show the terminal after it's ready
        vim.fn["floaterm#terminal#open_existing"](term_bufnr)
      elseif attempt <= max_attempts then
        attempt = attempt + 1
        vim.defer_fn(wait_for_terminal, delay)
      else
        vim.notify("Failed to start AiderPlus-Chat terminal after 3 seconds", vim.log.levels.ERROR)
        return
      end
    end

    wait_for_terminal()
  else
    -- Show existing terminal immediately
    vim.fn["floaterm#terminal#open_existing"](term_bufnr)
  end

  -- 将输入发送到 floaterm

  -- Get original buffer's file path and send it first
  local original_buf = require("aider-nvim.chat.buffer").get_original_buf()
  if original_buf and vim.api.nvim_buf_is_valid(original_buf) then
    local full_path = vim.api.nvim_buf_get_name(original_buf)
    if full_path and #full_path > 0 and not full_path:match("^term://") then
      -- Get relative path from current working directory
      local cwd = vim.fn.getcwd()
      local rel_path = full_path:gsub("^" .. cwd .. "/", "")

      -- Only send if we haven't sent this file before
      if not sent_files[rel_path] then
        vim.fn["floaterm#terminal#send"](term_bufnr, {"/add " .. rel_path})
        sent_files[rel_path] = true  -- Mark as sent
      end
    end
  end

  -- Send the user input with context info
  vim.fn["floaterm#terminal#send"](term_bufnr, {full_message})
end

function M.submit_to_terminal(full_message)
  -- Print the full message for debugging
  dd(full_message)

  if not full_message or #full_message == 0 then return end

  -- Get the init module with terminal functions
  local init = require("aider-nvim.init")

  -- Start terminal if not already running
  if not init.terminal_job_id then
    init.start_terminal()
  end

  -- Get original buffer's file path and send it first
  local original_buf = require("aider-nvim.chat.buffer").get_original_buf()
  if original_buf and vim.api.nvim_buf_is_valid(original_buf) then
    local full_path = vim.api.nvim_buf_get_name(original_buf)
    if full_path and #full_path > 0 and not full_path:match("^term://") then
      -- Get relative path from current working directory
      local cwd = vim.fn.getcwd()
      local rel_path = full_path:gsub("^" .. cwd .. "/", "")

      -- Only send if we haven't sent this file before
      if not sent_files[rel_path] then
        init.send_to_terminal("/add " .. rel_path)
        sent_files[rel_path] = true  -- Mark as sent
      end
    end
  end

  -- Verify terminal is ready before sending
  local max_attempts = 6  -- 3 seconds total with 0.5s interval
  local attempt = 1
  local delay = 500  -- milliseconds

  local function wait_and_send()
    if init.terminal_job_id then
      -- Terminal is ready, send the message
      init.send_to_terminal(full_message)
    elseif attempt <= max_attempts then
      attempt = attempt + 1
      vim.defer_fn(wait_and_send, delay)
    else
      vim.notify("Failed to start AiderPlus-Chat terminal after 3 seconds", vim.log.levels.ERROR)
      return
    end
  end

  wait_and_send()
end

return M
