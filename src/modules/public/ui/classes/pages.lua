--> @Desc page system user interfaces
--> @Author Tykind
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local quickData = require(ReplicatedStorage.Modules.quickData)

local CoreTypes = require(quickData.modules.Types.Module)

---> @Section Library functions

local pages : CoreTypes.UIPages = {}
pages.__index = pages

function pages.new(pageGroup : CoreTypes.Array<CoreTypes.PagePair>, OnReplace : (CoreTypes.PagePair) -> (), OnNew : (CoreTypes.PagePair) -> ()) : Pages
    return setmetatable({
        PageGroup = pageGroup,
        ActivatedPage = nil,

        OnReplace = OnReplace,
        OnNew = OnNew
    }, pages):setupLiseners()
end

function pages:processPage(page : CoreTypes.PagePair)
    local btn, friend = page.first, page.second

    btn:registerOnClick(function()
        if self:setMainPage(page) then
            self.OnNew(page.first, page.second) --> @ACTIVATE_NEW_PAGE
        end
    end)
end

---> @Section Useful functions

function pages:newPage(page : CoreTypes.PagePair)
    table.insert(self.PageGroup, page)
    self:processPage(page)
end

function pages:setMainPage(page : CoreTypes.PagePair) : boolean
    if not(self.Activatedpage) then --> @CHECK_IF_A_PAGE_OPEN
        self.Activatedpage = page
        return true
    end

    local ret

    if self.Activatedpage.second ~= page.second then --> @CHECK_IF_NEW_PAGE
        self.OnReplace(self.Activatedpage.first, self.Activatedpage.second)
        self.Activatedpage = page
        ret = true
    else
        self.OnReplace(self.Activatedpage.first, self.Activatedpage.second)
        self.Activatedpage = nil
    end

    return ret
end

function pages:setupLiseners() : Pages
    for _, page : CoreTypes.PagePair in pairs(self.PageGroup) do
        self:processPage(page)
    end

    return self --> Initiates pages
end

return pages