---A simple job handler.
---@class JobHander
---@field jobid integer | nil Running job's id, or nil when no job is running.
local M = {}

---Create a new JobHander instance.
---@return JobHander
function M:new()
    return setmetatable({
        jobid = nil
    }, {
        __index = self
    })
end

---Whether job is running or not.
---@return boolean # True if job is running.
function M:is_running()
    return self.jobid ~= nil
end

---Start cmd as a job.
---@param cmd string Name of command.
---@param args string[] Argument to pass to this command.
---@param opts? table See jobstart.
function M:start(cmd, args, opts)
    if self:is_running() then
        return
    end

    for _, arg in ipairs(args) do
        cmd = string.format("%s %s", cmd, arg)
    end

    opts = opts or {}
    opts.on_exit = opts.on_exit or function(...) end
    local extended_opts = vim.tbl_extend("keep", {
        on_exit = function(id, exit, event)
            self.jobid = nil -- When exit, set jobid to nil.
            opts.on_exit(id, exit, event)
        end
    }, opts)

    local jobid = vim.fn.jobstart(cmd, extended_opts)
    assert(jobid > 0, string.format("Failed to execute %s: jobstart returns %d", cmd, jobid))
    self.jobid = jobid
end

---Stop running job.
function M:stop()
    if not self:is_running() then
        return
    end

    vim.fn.jobstop(self.jobid)
end

return M
