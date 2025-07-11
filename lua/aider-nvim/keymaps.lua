local M = {}

function M.setup()
    local config = require("aider-nvim.config").get()
    local keybindings = config.keybindings

    vim.keymap.set("n", keybindings.send_code, function()
        require("aider-nvim").send_code()
    end, { desc = "Send code to Aider" })

    vim.keymap.set("v", keybindings.send_selection, function()
        require("aider-nvim").send_selection()
    end, { desc = "Send selection to Aider" })

    vim.keymap.set({"n", "v", "i"}, keybindings.toggle_chat, function()
        require("aider-nvim.chat").toggle()
    end, { desc = "Open Aider chat input" })

    vim.keymap.set("n", keybindings.call_aider_plus, function()
        require("aider-nvim").call_aider_plus()
    end, { desc = "Call Aider Plus" })
end

return M
