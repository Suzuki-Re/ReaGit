if not reaper.ImGui_GetBuiltinPath then
    reaper.MB("Missing dependency: ReaImGui extension.\nDownload it via Reapack ReaTeam extension repository.", "Error", 0)
    return reaper.ReaPack_BrowsePackages('dear imgui')
end

package.path = reaper.ImGui_GetBuiltinPath() .. '/?.lua'
im = require 'imgui' '0.9.1'

local workspace_folder = debug.getinfo(1).source:match("@(.*[/\\])")
package.path = package.path .. ';' .. workspace_folder ..'?.lua'

require('src.std+')
local INTERFACE = require('src.interface')

local PROJECT, PROJECT_FILEPATH = reaper.EnumProjects(-1)
local retval, REAGIT_REPO = reaper.GetProjExtState(PROJECT, "reagit", "repo")
if ~retval then
    REAGIT_REPO = PROJECT_FILEPATH
end

local GUI


function init()
    GUI = INTERFACE(REAGIT_REPO)
    return true
end

function loop()
    local open = GUI:loop()
    if open then
        reaper.defer(loop)
    else
        GUI:exit()
    end
end


if init() then
    reaper.defer(loop)
end
