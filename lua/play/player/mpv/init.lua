local job = require("play.job")
local cmd = require("play.player.mpv.command")
local socket_path = "/tmp/mpvsocket"

---A simple handler of mpv.
---@class MpvHandler
---@field mpv_job JobHandler JobHandler to handle mpv.
local M = {}

---Create a new MpvHandler instance.
---@return MpvHandler
function M:new()
    return setmetatable({
        mpv_job = job:new(),
    }, {
        __index = self
    })
end

---Whether mpv is running or not.
---@return boolean # True if mpv is running.
function M:is_running()
    return self.mpv_job:is_running()
end

---Play given file without video (only sound).
---@param path string
function M:start_file_without_video(path)
    self.mpv_job:start("mpv", {
        "--input-ipc-server=" .. socket_path,
        "--no-video",
        "--no-terminal",
        path,
    }, {
        on_exit = function()
            self:stop()
        end
    })
end

---Stop playback and exit from mpv.
function M:stop()
    self.mpv_job:stop()
end

---Load file from given path/url.
---@param path string Path or url to load.
function M:loadfile(path)
    cmd:new(socket_path):execute("loadfile", vim.fn.expand(path))
end

---Seek playback time by given diff.
---@param diff integer
function M:seek(diff)
    cmd:new(socket_path):execute("seek", diff)
end

---Pause the playback.
function M:pause()
    cmd:new(socket_path):change_property("pause", true)
end

---Resume the playback.
function M:resume()
    cmd:new(socket_path):change_property("pause", false)
end

---Toggle pause and resume.
function M:toggle()
    cmd:new(socket_path):change_property_with("pause", function(property)
        return not property
    end)
end

---Increase/Decrease the volume by given diff.
---@param diff integer How much to change volume.
function M:volume(diff)
    cmd:new(socket_path):change_property_with("volume", function(property)
        return property + diff
    end)
end

return M
