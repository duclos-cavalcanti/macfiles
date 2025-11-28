local vim = vim

local M = {}

function M.git_root()
    local handle = io.popen("git rev-parse --show-toplevel 2>/dev/null")
    if not handle then
        return nil
	end
end

return M
