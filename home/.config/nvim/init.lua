-- loads all configs

if os.getenv("TMUX") == nil then
    return
end

require("settings")
require("keys")
require("plugins")
require("commands")

-- vim.opt.runtimepath:append("$HOME/.config/nvim/pack/plugins/start/example")
-- require("example").setup({})
