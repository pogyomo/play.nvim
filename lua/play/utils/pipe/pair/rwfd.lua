local uv = vim.loop

---Handle read/write file descriptor which uv.pipe create.
---This only support to create read/write file descriptor.
---@class RWFileDescriptorHandler
---@field read integer | nil Read file descriptor, or nil if it isn't created.
---@field write integer | nil Write file descriptor, or nil if it isn't created.
local M = {}

---Create a new RWFileDescriptorHandler instance.
---@return RWFileDescriptorHandler
function M:new()
    return setmetatable({
        read = nil,
        write = nil
    }, {
        __index = self
    })
end

---Create a new read/write file descriptor if not exist.
function M:create()
    if self.read and self.write then
        return
    end
    local fds, err = uv.pipe({ nonblock = true }, { nonblock = true })
    assert(not err, err)
    self.read  = fds.read
    self.write = fds.write
end

---Close file descriptors.
function M:close()
    if self.read then
        local _, err = uv.fs_close(self.read)
        assert(not err, err)
        self.read = nil
    end
    if self.write then
        local _, err = uv.fs_close(self.write)
        assert(not err, err)
        self.write = nil
    end
end

---Take read file descriptor, or throw error.
---@return integer
function M:take_read()
    return assert(self.read, "Failed to take read file descriptor.")
end

---Take write file descriptor, or throw error.
---@return integer
function M:take_write()
    return assert(self.write, "Failed to take write file descriptor.")
end

return M
