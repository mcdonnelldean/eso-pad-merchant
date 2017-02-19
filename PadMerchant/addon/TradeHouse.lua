

-- Handles generating list items. Each list we care about (BrowseResults and Listings) require a
-- function to handle enriching the template they use for list items. We override the template selection
-- further down and provide this function to enrich our template, including our new controls.
local function GenerateListItem(validatePrice)

    -- This is the actual setup function. We use the outer function to control price validation which 
    -- is explicit Listings but forced on for BrowseResults. Other than that both lists are identical.
    return function (control, data, selected, selectedOnRebuild, enabled, activated)
        ZO_SharedGamepadEntry_OnSetup(control, data, selected, selectedOnRebuild, enabled, activated)

        -- Sets up the price control as mentioned above.
        local priceValid = false
        if (validatePrice) then
            priceValid = data.purchasePrice > GetCarriedCurrencyAmount(CURT_MONEY)
        end
        ZO_CurrencyControl_SetSimpleCurrency(control.price, CURT_MONEY, data.purchasePrice, ZO_GAMEPAD_CURRENCY_OPTIONS, CURRENCY_SHOW_ALL, priceValid)

        -- MasterMerchant injects sales data into the seller name. We need to split and parse.
        local sellerName, dealString, margin = zo_strsplit(';', data.sellerName)
        local dealValue = tonumber(dealString)

        -- Setup sellerName control
        local sellerControl = control:GetNamedChild("SellerName")
        sellerControl:SetText(ZO_FormatUserFacingDisplayName(sellerName))
        
        -- Setup BuyingAdvice control
        local buyingAdviceControl = control:GetNamedChild("BuyingAdvice")
        local r, g, b = GetInterfaceColor(INTERFACE_COLOR_TYPE_ITEM_QUALITY_COLORS, dealValue)
        if dealValue == 0 then r = 0.98; g = 0.01; b = 0.01; end
        buyingAdviceControl:SetColor(r, g, b, 1)
        if(margin ~= nil) then
            buyingAdviceControl:SetText(margin .. ' %')
        else
            buyingAdviceControl:SetText("-")
        end

        -- Set up UnitPrice control.
        local unitPriceControl = control:GetNamedChild("UnitPrice")
        if(data.stackCount ~= 1) then 
            unitPriceControl:SetHidden(false)
            unitPriceControl:SetText(zo_strformat("<<1>>|t16:16:esoui/art/currency/gamepad/gp_gold.dds|t", data.purchasePrice / data.stackCount))
        else 
            unitPriceControl:SetText(zo_strformat("<<1>>|t16:16:esoui/art/currency/gamepad/gp_gold.dds|t", data.purchasePrice))
        end

        -- Set up TimeLeft control.
        local timeRemainingControl = control:GetNamedChild("TimeLeft")
        if data.isGuildSpecificItem then
            timeRemainingControl:SetHidden(true)
        else
            timeRemainingControl:SetHidden(false)
            timeRemainingControl:SetText(zo_strformat(SI_TRADING_HOUSE_BROWSE_ITEM_REMAINING_TIME, ZO_FormatTime(data.timeRemaining, TIME_FORMAT_STYLE_SHOW_LARGEST_UNIT_DESCRIPTIVE, TIME_FORMAT_PRECISION_SECONDS, TIME_FORMAT_DIRECTION_DESCENDING)))
        end
    end
end

-- Handles adding our template (xml) to the applicable list. Our overrides 
-- below Force each list to select our template. This method ensures the 
-- template and template setup are available in each lists dataTypes table.
local function AddTemplateToList(list, template, validatePrice)
    local parametricFunction = ZO_GamepadMenuEntryTemplateParametricListFunction
    local equalityFunction = function(left, right) return left == right end 
    local parent = list:GetList().scrollControl

    list:GetList().dataTypes[template] = {
        pool = ZO_ControlPool:New(template, parent, template),
        setupFunction = GenerateListItem(validatePrice),
        parametricFunction = parametricFunction,
        equalityFunction = equalityFunction,
        hasHeader = false
    }

end

-- Our override of BuildList. Instead of showing the old template and data, add our new
-- template. We need to keep some of the old logic since we have fully overridden the old
-- function. Our only change is the template value (first param) to AddEntry.
-- NOTE: This may not be the best way to do this; still investigating.
local function BuildListOverride(template)
    local offsetHeader = SCROLL_LIST_HEADER_OFFSET_VALUE 
    local offsetSelected = SCROLL_LIST_SELECTED_OFFSET_VALUE

    -- The original logic from game, as is. We only change the template value.
    return function(self)
        for i = 1, GetNumTradingHouseListings() do
            local itemData = ZO_TradingHouse_CreateItemData(i, GetTradingHouseListingItemInfo)
            if(itemData) then
                itemData.name = zo_strformat(SI_TOOLTIP_ITEM_NAME, itemData.name)
                itemData.price = itemData.purchasePrice
                itemData.time = itemData.timeRemaining

                local entry = ZO_GamepadEntryData:New(itemData.name, itemData.iconFile)
                entry:InitializeTradingHouseVisualData(itemData)
                self:GetList():AddEntry(template, entry, offsetHeader, offsetHeader, offsetSelected, offsetSelected)
            end
        end
    end
end

-- Our override of AddEntryToList. Items are added to the list one at a time, instead of
-- as a single one time list. We shadow this and as with the Listings, all we change is
-- the template to be used. This will ensure our template and setup function is used.
local function AddEntryToListOverride(template)
    local offsetHeader = SCROLL_LIST_HEADER_OFFSET_VALUE 
    local offsetSelected = SCROLL_LIST_SELECTED_OFFSET_VALUE

    -- The original logic from game, as is. We only change the template value.
    return function(self, itemData) 
		self.footer.pageNumberLabel:SetHidden(false)
        self.footer.pageNumberLabel:SetText(zo_strformat("<<1>>", self.currentPage + 1))

        if(itemData) then
	        local entry = ZO_GamepadEntryData:New(itemData.name, itemData.iconFile)
	        entry:InitializeTradingHouseVisualData(itemData)
	        self:GetList():AddEntry(template, entry, offsetHeader, offsetHeader, offsetSelected, offsetSelected)
    	end
	end
end

-- Public method to run TradeHouse integration.
function PadMerchant.TradeHouse.Setup()
    
    -- The listing controls we care about plus our templates name.
	local Listings = GAMEPAD_TRADING_HOUSE_LISTINGS
    local BrowseResults = GAMEPAD_TRADING_HOUSE_BROWSE_RESULTS 
    local template = "PadMerchant_TradingHouse_ItemListRow"

    -- Add our template to both list types.
    AddTemplateToList(BrowseResults, template, true)
    AddTemplateToList(Listings, template, false)

    -- Add our overrides for each list, forcing our template.
    Listings.BuildList = BuildListOverride(template)
	BrowseResults.AddEntryToList = AddEntryToListOverride(template)
end