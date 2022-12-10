---A simple job handler.
---@class JobHandler
---@field jobid integer | nil Job id jobstart return, or nil if no job running.
local M = {}

---Create a new JobHandler instance.
---@return JobHandler
function M:new()
    return setmetatable({
        jobid = nil
    }, {
        __index = self
    })
end

---Whether job is running or not.
---@return boolean
function M:is_running()
    return self.jobid ~= nil
end

---Start cmd as a job.
---@param cmd string Name of command.
---@param args string[] Arguments to pass to command.
---@param opts? table See jobstart.
function M:start(cmd, args, opts)
    if self:is_running() then
        return
    end

    -- NOTE: When job stopped, self.jobid become invalid but still integer.
    --       By changing jobid to nil when exit, I can prevent this problem.
    opts = opts or {}
    local on_exit = opts.on_exit or function(...) end -- Preserve existing on_exit function.
    opts.on_exit = function(id, exit, type) -- Register new on_exit function.
        self.jobid = nil
        on_exit(id, exit, type) -- Call original on_exit.
    end

    for _, arg in ipairs(args) do
        cmd = string.format("%s %s", cmd, arg)
    end

    self.jobid = vim.fn.jobstart(cmd, opts)
    if self.jobid == 0 or self.jobid == -1 then
        self.jobid = nil
        assert(self.jobid ~=  0, "Failed to start job: invalid arguments or job table is full")
        assert(self.jobid ~= -1, "Failed to start job: cmd or 'shell' is not executable")
    end
end

---Stop running job.
function M:stop()
    if not self:is_running() then
        return
    end

    vim.fn.jobstop(self.jobid)
end

return M
