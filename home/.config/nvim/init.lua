-- loads all configs

if os.getenv("TMUX") == nil then
    return 
end

require("settings")
require("plugins")
require("map")

-- vim.opt.runtimepath:append("$HOME/.config/nvim/pack/plugins/start/example")
-- require("example").setup({})
