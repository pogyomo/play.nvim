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
---@param args? string[] Arguments of this command.
---@param opts? table See jobstart.
function M:start(cmd, args, opts)
    if self:is_running() then
        return
    end

    for _, arg in ipairs(args or {}) do
        cmd = string.format("%s %s", cmd, arg)
    end

    if opts then
        self.id = vim.fn.jobstart(cmd, opts)
    else
        self.is = vim.fn.jobstart(cmd)
    end
    if self.id == 0 or self.id == -1 then
        self.id = nil
        error("Faild to start job: " .. cmd)
    end
end

---Stop this job.
function M:stop()
    if not self:is_running() then
        return
    end

    vim.fn.jobstop(self.id)
    self.id = nil
end

---Whether job is running or not.
---@return boolean # True if job is running.
function M:is_running()
    return self.id ~= nil
end

return M
