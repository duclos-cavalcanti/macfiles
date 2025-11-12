-- loads all configs

if os.getenv("TMUX") == nil then
    return
end

require("settings")
require("keys")
require("commands")
require("plugins")

-- vim.opt.runtimepath:append("$HOME/.config/nvim/pack/plugins/start/example")
-- require("example").setup({})
