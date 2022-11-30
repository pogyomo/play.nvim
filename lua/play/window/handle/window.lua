---Simple wrapper of window handle.
---@class WindowHandle
---@field handle integer Window handle.
---@field maybe_valid boolean False if this handle is absolutely invalid.
local M = {}

---Create new window handle instance.
function M:new()
    return setmetatable({
        handle = 0,
        maybe_valid = false,
    }, {
        __index = self,
    })
end

---Whether this window handle is valid or not.
function M:is_valid()
    return self.maybe_valid and vim.api.nvim_win_is_valid(self.handle)
end

---Initialize this window handle using given buffer.
---@param buffer integer Buffer handle.
---@param enter boolean Enter this window when initialized.
---@param config table Config that nvim_open_win accept.
function M:init(buffer, enter, config)
    self:close()
    self.handle = vim.api.nvim_open_win(buffer, enter, config)
    self.maybe_valid = true
end

---Close window that is associated with this window handle.
function M:close()
    if self:is_valid() then
        vim.api.nvim_win_close(self.handle, {})
    end
end

return M
