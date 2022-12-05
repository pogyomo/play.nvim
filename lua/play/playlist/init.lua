---@class PlaylistManager
---@field playlists table<string, PlaylistData> Name to playlist table.

---@class PlaylistData
---@field list_of_name string[]

---@class AddPlaylistOption
---@field force boolean Force to rewrite playlist which already exist .

---@class PlaylistManager
local M = {}

---Create a new playlist manager instance.
---@param playlists? table<string, PlaylistData>
function M:new(playlists)
    return setmetatable({
        playlists = playlists or {}
    }, {
        __index = self,
    })
end

---Add a playlist.
---@param name string Name of the playlist.
---@param playlist PlaylistData Data of the playlist.
---@param opts? AddPlaylistOption Option of add behavior.
function M:add(name, playlist, opts)
    opts = opts or { force = false }
    if self.playlists[name] and opts.force then -- When playlist already exist and force is true
        self.playlists[name] = playlist
    else
        self.playlists[name] = self.playlists[name] or playlist
    end
end

---Take a playlist which associated with the name.
---@param name string
---@return PlaylistData | nil
function M:take(name)
    return self.playlists[name]
end

return M
