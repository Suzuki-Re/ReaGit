local Project = require('src.project')
local Settings = require('src.settings')

local Header = {}
Header.__index = Header

function Header.new(ctx, fonts)
    local self = { ctx = ctx, fonts = fonts }
    setmetatable(self, Header)
    return self
end

function Header:drawTitle(w, h)
    im.BeginChild(self.ctx, "header_title", w, h)
    im.PushFont(self.ctx, self.font.h1)
    im.TextColored(self.ctx, 2868903935, self.project.name)
    im.PopFont(self.ctx)
    im.EndChild(self.ctx)
    im.SameLine(self.ctx)
end

function Header:drawSync(w, h)
    local pad_x, pad_y = im.GetStyleVar(self.ctx, im.StyleVar_FramePadding)
    local pad2_x, pad2_y = pad_x * 2, pad_y * 2
    local frame_w = (w - pad2_x * 2) / 2
    local frame_h = h - pad2_y
    local button_w = frame_w
    local button_h = (frame_h - pad2_y) / 2
    im.BeginChild(self.ctx, "header_sync", w, h)
    im.PushFont(self.ctx, self.font.p)
    im.PushStyleVar(self.ctx, im.StyleVar_FramePadding, 0, 0)
    im.BeginChild(
        self.ctx,
        "header_sync_left",
        frame_w,
        frame_h,
        im.WindowFlags_NoBackground
    )
    if im.Button(self.ctx, "Push", button_w, button_h) then
        Interface:pushPressed()
    end
    if im.Button(self.ctx, "Pull", button_w, button_h) then
        Interface:pullPressed()
    end
    im.EndChild(self.ctx)

    im.SameLine(self.ctx)

    im.BeginChild(
        self.ctx,
        "header_sync_right",
        frame_w,
        frame_h,
        im.WindowFlags_NoBackground
    )
    if im.Button(self.ctx, "Remote", button_w, button_h) then
        self:remotePressed()
    end
    im.PushStyleVar(self.ctx, im.StyleVar_ItemInnerSpacing, w * 0.05, 0)
    local x, y = im.GetCursorPos(self.ctx)
    local tw, th = im.CalcTextSize(self.ctx, "--force")
    im.SetCursorPos(self.ctx, x, y + button_h / 2 - th / 2)
    if im.Checkbox(self.ctx, "--force", self.settings.force) then
        self.settings.force = not self.settings.force
    end
    im.PopStyleVar(self.ctx)
    im.PopFont(self.ctx)
    im.EndChild(self.ctx)
    im.PopStyleVar(self.ctx)

    im.EndChild(self.ctx)

end

function Header:draw(w, h)
    local pad_x, pad_y = im.GetStyleVar(self.ctx, im.StyleVar_FramePadding)
    local pad2_x = pad_x * 2
    local title_w = w * 0.6
    self:drawTitle(title_w - pad2_x, h)
    self:drawSync(w - title_w - pad2_x, h)
end

local Interface = {}
Interface.__index = Interface

function Interface:init()
    self.font = {}
    self.ctx = im.CreateContext(self.title)
    local sizeOffset = reaper.GetAppVersion():match('OSX') and 0 or 2
    self.font.h1 = im.CreateFont('sans-serif', 28 + sizeOffset)
    self.font.h2 = im.CreateFont('sans-serif', 24 + sizeOffset)
    self.font.h3 = im.CreateFont('sans-serif', 20 + sizeOffset)
    self.font.h4 = im.CreateFont('sans-serif', 18 + sizeOffset)
    self.font.h5 = im.CreateFont('sans-serif', 16 + sizeOffset)
    self.font.h6 = im.CreateFont('sans-serif', 14 + sizeOffset)
    self.font.p = im.CreateFont('sans-serif', 12 + sizeOffset)
    im.Attach(self.ctx, self.font.h1)
    im.Attach(self.ctx, self.font.h2)
    im.Attach(self.ctx, self.font.h3)
    im.Attach(self.ctx, self.font.h4)
    im.Attach(self.ctx, self.font.h5)
    im.Attach(self.ctx, self.font.p)
end

function Interface:exit()
    local dockstate, wx, wy, ww, wh = gfx.dock(-1, 0, 0, 0, 0)
    self.settings:update({
        x = wx,
        y = wy,
        width = ww,
        height = wh,
        dockstate = dockstate
    })
    self.settings:write()
end

function Interface:onExit()

end

function Interface:pushPressed()
end

function Interface:pullPressed()
end

function Interface:drawInit(w, h)
    im.Text(self.ctx, "ReaGit uninitiated.")
    im.PushFont(self.ctx, self.font.h2)
    if im.Button(self.ctx, "INITIATE NEW REPOSITORY") then
        self.project:init()
    end
    im.PopFont(self.ctx)
    im.PushTextWrapPos(self.ctx, im.GetFontSize(self.ctx) * 35.0)
    im.Text(self.ctx, "Note this will create a '.reagit' folder in the space directory as the project file.")
    im.Text(self.ctx, "You can also:")
    im.PopTextWrapPos(self.ctx)
    im.PushFont(self.ctx, self.font.h2)
    if im.Button(self.ctx, "LOCATE EXISTING REPOSITORY") then
        local retval, path = reaper.GetUserFileNameForRead('', 'Select Existing Reagit Repository Main File', '')
        if retval then
            self.project = Project(path)
            reaper.SetExtState("ReaGit", "repository", path)
        end
    end
    im.PopFont(self.ctx)
end

function Interface:drawSync(w, h)
    local pad_x, pad_y = im.GetStyleVar(self.ctx, im.StyleVar_FramePadding)
    local pad2_x, pad2_y = pad_x * 2, pad_y * 2
    local frame_w = (w - pad2_x * 2) / 2
    local frame_h = h - pad2_y
    local button_w = frame_w
    local button_h = (frame_h - pad2_y) / 2
    im.BeginChild(self.ctx, "header_sync", w, h)
    im.PushFont(self.ctx, self.font.p)
    im.PushStyleVar(self.ctx, im.StyleVar_FramePadding, 0, 0)
    im.BeginChild(
        self.ctx,
        "header_sync_left",
        frame_w,
        frame_h,
        im.WindowFlags_NoBackground
    )
    if im.Button(self.ctx, "Push", button_w, button_h) then
        Interface:pushPressed()
    end
    if im.Button(self.ctx, "Pull", button_w, button_h) then
        Interface:pullPressed()
    end
    im.EndChild(self.ctx)

    im.SameLine(self.ctx)

    im.BeginChild(
        self.ctx,
        "header_sync_right",
        frame_w,
        frame_h,
        im.WindowFlags_NoBackground
    )
    if im.Button(self.ctx, "Remote", button_w, button_h) then
        self:remotePressed()
    end
    im.PushStyleVar(self.ctx, im.StyleVar_ItemInnerSpacing, w * 0.05, 0)
    local x, y = im.GetCursorPos(self.ctx)
    local tw, th = im.CalcTextSize(self.ctx, "--force")
    im.SetCursorPos(self.ctx, x, y + button_h / 2 - th / 2)
    if im.Checkbox(self.ctx, "--force", self.settings.force) then
        self.settings.force = not self.settings.force
    end
    im.PopStyleVar(self.ctx)
    im.PopFont(self.ctx)
    im.EndChild(self.ctx)
    im.PopStyleVar(self.ctx)

    im.EndChild(self.ctx)

end

function Interface:drawTitle(w, h)
    local pad_x, pad_y = im.GetStyleVar(self.ctx, im.StyleVar_FramePadding)
    local pad2_x = pad_x * 2
    local title_w = w * 0.6
    im.BeginChild(self.ctx, "header_title", title_w - pad2_x, h)
    im.PushFont(self.ctx, self.font.h1)
    im.TextColored(self.ctx, 2868903935, self.project.name)
    im.PopFont(self.ctx)
    im.EndChild(self.ctx)
    im.SameLine(self.ctx)
    self:drawSync(w - title_w - pad2_x, h)
end

function Interface:drawGroup(w, h, name, child)
    local buttons_per_row = 4
    local pad_x, pad_y = im.GetStyleVar(self.ctx, im.StyleVar_FramePadding)

    local fw = w - pad_x * 2
    local fh = h - pad_y * 2
    local name_h = fh * 0.4
    local text_h
    im.BeginChild(self.ctx, "group_" .. name, w, h)

    im.PushFont(self.ctx, self.font.h2)
    im.Text(self.ctx, "Group: " .. name)
    local tw, th = im.GetItemRectSize(self.ctx)
    text_h = th + pad_y
    im.PopFont(self.ctx)
    im.Text(self.ctx, "Branch: " .. child:current_branch())
    local tw, th = im.GetItemRectSize(self.ctx)
    text_h = text_h + th + pad_y


    local button_w = (w - pad_x * (buttons_per_row * 2)) / buttons_per_row
    local button_h = (h - text_h - pad_y * (8 / buttons_per_row + 2)) / (8 / buttons_per_row)
    im.PushStyleColor(self.ctx, im.Col_FrameBg, 0)
    im.Button(self.ctx, "Update", button_w, button_h)
    im.SameLine(self.ctx)
    im.Button(self.ctx, "Amend", button_w, button_h)
    im.SameLine(self.ctx)
    im.Button(self.ctx, "List Tracks", button_w, button_h)
    im.SameLine(self.ctx)
    im.Button(self.ctx, "Switch Branch", button_w, button_h)

    im.Button(self.ctx, "Log", button_w, button_h)
    im.SameLine(self.ctx)
    im.Button(self.ctx, "Revert", button_w, button_h)
    im.SameLine(self.ctx)
    im.Button(self.ctx, "List Branches", button_w, button_h)
    im.SameLine(self.ctx)
    im.Button(self.ctx, "Delete Branch", button_w, button_h)
    im.PopStyleColor(self.ctx)
    im.EndChild(self.ctx)
end

function Interface:drawAddNewChild(w, h)
    local pad_x, pad_y = im.GetStyleVar(self.ctx, im.StyleVar_FramePadding)
    local button_s = h * 0.5
    im.PushStyleColor(self.ctx, im.Col_FrameBg, 0)
    im.BeginChild(self.ctx, "new_group", w, h)
    im.PushStyleVar(self.ctx, im.StyleVar_FrameRounding, button_s)
    im.PushFont(self.ctx, self.font.h2)
    local x, y = im.GetCursorPos(self.ctx)
    im.SetCursorPos(self.ctx, x + w / 2 - button_s / 2, y + h / 2 - button_s / 2 - pad_y)
    if im.Button(self.ctx, "+", button_s, button_s) then
        local retval, s = reaper.GetUserInputs("New group from selected tracks", 2,
            "Group name without space,commit message,extrawidth=100", "")
        if retval then
            local name, commit_msg = table.unpack(s:split(','))
            local track_chunks = {}
            for i = 0, reaper.CountSelectedTracks(-1) - 1, 1 do
                local track = reaper.GetSelectedTrack(-1, i)
                local _, chunk = reaper.GetTrackStateChunk(track, "", false)
                table.insert(track_chunks, chunk)
            end
            self.project:add(
                name:gsub("[%s\t\n]+", "-"),
                commit_msg == "" and nil or commit_msg,
                track_chunks
            )
        end
    end
    im.PopFont(self.ctx)
    im.PopStyleVar(self.ctx)
    im.EndChild(self.ctx)
    im.PopStyleColor(self.ctx)
end

function Interface:drawGroups(w, h)
    local pad_x, pad_y = im.GetStyleVar(self.ctx, im.StyleVar_FramePadding)
    local pad2_x, pad2_y = pad_x * 2, pad_y * 2
    local group_w = w - pad2_x
    local group_h = (h - pad2_y) * 0.2
    im.BeginChild(self.ctx, "groups", w, h)
    for k, child in pairs(self.project.children) do
        self:drawGroup(group_w, group_h, k, child)
    end
    self:drawAddNewChild(group_w, group_h)
    im.EndChild(self.ctx)
end

function Interface:update()
    local pad_x, pad_y = im.GetStyleVar(self.ctx, im.StyleVar_FramePadding)
    local pad2_x, pad2_y = pad_x * 2, pad_y * 2
    local w, h = im.GetWindowContentRegionMax(self.ctx)
    self.settings.width = w
    self.settings.height = h
    if not self.project.initiated then
        self:drawInit(w, h)
        return
    end

    local header_h = h * 0.10
    self:drawTitle(w, header_h - pad2_y * 2)
    im.Spacing(self.ctx)
    self:drawGroups(w, h - header_h - pad2_y * 2)
end

function Interface:loop()
    im.PushFont(self.ctx, self.font.p)
    im.SetNextWindowSize(
        self.ctx,
        self.settings.width,
        self.settings.height,
        im.Cond_FirstUseEver
    )
    local visible, open = im.Begin(self.ctx, self.title, true)
    if visible then
        self:update()
        im.End(self.ctx)
    end
    im.PopFont(self.ctx)

    return open
end

function Interface.new(project_file)
    local self = {
        select_index = 0,
        scroll_index = 0,
        pending_close = false
    }
    setmetatable(self, Interface)
    self.settings = Settings()
    self.project = Project(project_file)
    self.title = 'ReaGit: '
    self:init()

    return self
end

setmetatable(Interface, {
    __call = function(_, ...)
        return Interface.new(...)
    end
})

return Interface
