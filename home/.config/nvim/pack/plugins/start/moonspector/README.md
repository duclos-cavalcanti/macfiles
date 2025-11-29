# Moonspector

Ridiculously small plugin for quick Lua code experimentation and debugging.
`Moonspector` provides a floating scratch buffer where you can write and execute Lua code.

- `:MoonLaunch` - Opens the Moonspector floating window
- **`:w`** - Executes the Lua code

### Example

1.  `:MoonLaunch`
2. Write Lua code:
   ```lua
   local result = vim.api.nvim_get_current_buf()
   print("Current buffer:", result)
   return {buffer = result, success = true}
   ```
3. `:w` to source.

---

*Moonspector: Lua Inspector*
