---Simple job handler.
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

---Start cmd as a job.
---@param cmd  string Name of command to start as a job.
---@param args string[] Arguments of this command.
function M:start(cmd, args)
    if self.id then
        return
    end

    for _, arg in ipairs(args) do
        cmd = string.format("%s %s", cmd, arg)
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
