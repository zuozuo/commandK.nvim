local M = {}

M.default_config = {
    auto_start = true,
    prompt = "Send text to Aider:  ",
    code_context_window = 2,  -- 获取光标上下20行代码作为上下文
    input_min_left_position = 8,  -- 输入窗口左侧的最小位置
    quick_commands = {
        "/explain this",
        "/fix that", 
        "/refactor this",
        "/add comments"
    },
    keybindings = {
        send_code = "<leader>ac",
        send_selection = "<leader>as",
        toggle_chat = "<D-k>",
        call_aider_plus = "<leader>ap",
    },
    floaterm_command = "FloatermNew --name=AiderPlus-Chat --wintype=vsplit --width=0.4 aider",
}

function M.setup(user_config)
    M.config = vim.tbl_deep_extend("force", M.default_config, user_config or {})
    return M.config
end

function M.get()
    return M.config
end

return M
