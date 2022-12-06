---Simple handler for job.
---@class JobHandler
---@field id integer | nil Id which jobstart return, or nil if there isn't job exist.
local M = {}

---Create a new JobHandler instance.
---@return JobHandler
function M:new()
    return setmetatable({
        id = nil
    }, {
        __index = self
    })
end

---Start cmd as job.
---@param cmd string
function M:start(cmd)
    if self.id then
        return
    end

    self.id = vim.fn.jobstart(cmd)
    if self.id == 0 or self.id == -1 then
        self.id = nil
        error("Faild to start job: " .. cmd)
    end
end

---Stop this job.
function M:stop()
    if not self.id then
        return
    end

    vim.fn.jobstop(self.id)
    self.id = nil
end

return M
