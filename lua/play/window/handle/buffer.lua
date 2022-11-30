---Simple wrapper of buffer handle.
---@class BufferHandle
---@field handle integer Buffer handle.
---@field maybe_valid boolean False if this handle is absolutely invalid.
local M = {}

---Create new buffer handle instance.
function M:new()
    return setmetatable({
        handle = 0,
        maybe_valid = false,
    }, {
        __index = self,
    })
end

---Whether this buffer handle is valid or not.
function M:is_valid()
    return self.maybe_valid and vim.api.nvim_buf_is_valid(self.handle)
end

---Initialize this buffer handle using empty buffer.
---@param listed boolean Same as {listed} in nvim_create_buf.
---@param scratch boolean Same as {scratch} in nvim_create_buf.
function M:init(listed, scratch)
    self:delete()
    self.handle = vim.api.nvim_create_buf(listed, scratch)
    self.maybe_valid = true
end

---Delete buffer that is associated with this window handle.
function M:delete()
    if self:is_valid() then
        vim.api.nvim_buf_delete(self.handle, {})
    end
end

return M
