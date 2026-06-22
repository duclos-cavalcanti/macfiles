-- Adwaita Dark — base16 palette for config/theme.lua's M.setup() mapping.
-- Derived from Ghostty's `Adwaita Dark` (16 ANSI + background) extracted via
-- `ghostty +show-config`. Accents (base08-0F) are Adwaita's real colors;
-- base00-07 is the dark->light grayscale ramp (GNOME Adwaita neutrals).
-- Note: base09 (orange) and base0F (brown) have no ANSI source, so they're
-- Adwaita-palette approximations. Brights render from the ramp (base16 quirk),
-- not Adwaita's literal bright ANSI — same behaviour as the old gruvbox palette.

local M = {
    base00 = '#1d1d20', base01 = '#241f31', base02 = '#3d3846', base03 = '#5e5c64',
    base04 = '#9a9996', base05 = '#deddda', base06 = '#f6f5f4', base07 = '#ffffff',
    base08 = '#c01c28', base09 = '#e66100', base0A = '#f5c211', base0B = '#2ec27e',
    base0C = '#0ab9dc', base0D = '#1e78e4', base0E = '#9841bb', base0F = '#865e3c'
}

return M
