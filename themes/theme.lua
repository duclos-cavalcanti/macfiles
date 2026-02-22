local theme = "gruvbox"

local path = os.getenv("MACFILES") .. "/themes/" .. theme .. ".lua"

local M = dofile(path)
return M
