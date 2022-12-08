local uv = vim.loop

---A simple pipe handler.
---This only handle pipe instance. Specific operation will be implemented on child folder.
---@class PipeHander
---@field pipe userdata | nil uv_pipe_t which uv.new_pipe return, or nil when pipe is closed.
local M = {}

---Create a new pipe handler instance.
---@return PipeHander
function M:new()
    return setmetatable({
        pipe = nil
    }, {
        __index = self
    })
end

---Create a new pipe instance if no pipe was created or pipe is already closed.
function M:open()
    if self:is_opened() then
        return
    end

    local err = nil
    self.pipe, err = uv.new_pipe()
    assert(not err, err) -- When failed, self.pipe is still nil, so only abort from this function.
end

---Close opened pipe if exist.
function M:close()
    if not self:is_opened() then
        return
    end

    self.pipe:close()
    self.pipe = nil
end

---Whether pipe is opened or not.
---@return boolean # True when pipe is opened.
function M:is_opened()
    return self.pipe ~= nil
end

---Take pipe instance, or throw error if pipe == nil.
---@return userdata
function M:take()
    if self:is_opened() then
        return self.pipe
    else
        error("Failed to take pipe instance: pipe isn't opened or already closed.")
    end
end

return M
