local mpv = require("play.player.mpv")

---@class Play
---@field mpv MpvHandler
local M = {
    mpv = mpv:new()
}

function M:loadfile(path)
    if self.mpv:is_running() then
        self.mpv:loadfile(path)
    else
        self.mpv:start_file_without_video(path)
    end
end

function M:stop()
    self.mpv:stop()
end

function M:pause()
    self.mpv:pause()
end

function M:resume()
    self.mpv:resume()
end

function M:toggle()
    self.mpv:toggle()
end

function M:seek(diff)
    self.mpv:seek(diff)
end

function M:volume(diff)
    self.mpv:volume(diff)
end

return M
