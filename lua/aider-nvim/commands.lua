local M = {}

function M.setup()
    vim.api.nvim_create_user_command("AiderPlus", function(opts)
        local action = opts.fargs[1]
        local actions = {
            send_code = function() require("aider-nvim").send_code() end,
            send_selection = function() require("aider-nvim").send_selection() end,
            toggle_chat = function() require("aider-nvim.chat").toggle() end,
            call_aider_plus = function() require("aider-nvim").call_aider_plus() end,
            start = function() require("aider-nvim").start() end,
        }

        if actions[action] then
            actions[action]()
        else
            vim.notify(
                "Invalid action for AiderPlus. Available actions: send_code, send_selection, toggle_chat, call_aider_plus, start",
                vim.log.levels.ERROR)
        end
    end, {
        nargs = 1,
        range = true,
        complete = function()
            return { "send_code", "send_selection", "toggle_chat", "call_aider_plus", "start" }
        end,
        desc = "Call Aider Plus functionality with specific action"
    })
end

return M
