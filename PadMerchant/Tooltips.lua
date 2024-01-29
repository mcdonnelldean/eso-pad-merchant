
GOLD_ICON = "|t32:32:esoui/art/currency/gamepad/gp_gold.dds|t"

local GENERAL_COLOR_WHITE = GAMEPAD_TOOLTIP_COLOR_GENERAL_COLOR_1
local GENERAL_COLOR_GREY = GAMEPAD_TOOLTIP_COLOR_GENERAL_COLOR_2
local GENERAL_COLOR_OFF_WHITE = GAMEPAD_TOOLTIP_COLOR_GENERAL_COLOR_3


local function GenerateTipContent(itemLink)
	local itemInfo = TamrielTradeCentre_ItemInfo:New(itemLink)
	local pricing = TamrielTradeCentrePrice:GetPriceInfo(itemInfo)


	if pricing == nil then
		pricing = {}
	end

	local suggested = "No Suggestion Available"
	if pricing.SuggestedPrice ~= nil then
		local suggestedMin = TamrielTradeCentre:FormatNumber(pricing.SuggestedPrice, 0) .. GOLD_ICON
		local suggestedMax = TamrielTradeCentre:FormatNumber(pricing.SuggestedPrice * 1.25, 0) .. GOLD_ICON

		suggested = suggestedMin .. " to " .. suggestedMax
	end

	local listingsNote = "No historical data available"
	if pricing.EntryCount ~= nil and pricing.Avg ~= nill then
		local listings = TamrielTradeCentre:FormatNumber(pricing.EntryCount, 0)
		local priceAvg = TamrielTradeCentre:FormatNumber(pricing.Avg, 0) .. GOLD_ICON

		listingsNote = listings .. " listings, averaging " .. priceAvg
	end

	local salesNote = "No historical data available"
	if pricing.SaleEntryCount ~= nil and pricing.SaleAvg ~= nill then
		local sales = TamrielTradeCentre:FormatNumber(pricing.SaleEntryCount, 0)
		local saleAvg = TamrielTradeCentre:FormatNumber(pricing.SaleAvg, 0) .. GOLD_ICON

		salesNote = sales .. " sales, averaging " .. saleAvg
	end

	pricing.Suggested = suggested
	pricing.Sales = salesNote
	pricing.Listings = listingsNote

	return pricing
end

-- Adds sales data from MasterMerchant data about to the provided
local function AddData(tooltip, itemLink)
	if itemLink == nil then return end

	-- Our style is common to both header and tip
	local style = tooltip:GetStyle("bodySection")

	-- Generate our header and params
	local headerParams = {
		fontFace = "$(GAMEPAD_BOLD_FONT)",
        fontSize = "$(GP_27)",
        fontStyle = "soft-shadow-thick",
        uppercase = true,
        fontColorField = GENERAL_COLOR_OFF_WHITE,
        height = 24,
	}

	-- Generate our tip content and params
	local tipContent = GenerateTipContent(itemLink)
	local tipParams = {
		fontColorField = GENERAL_COLOR_WHITE,
        fontFace = "$(GAMEPAD_LIGHT_FONT)",
        fontSize = "$(GP_34)"
	}

	local tipParams2 = {
		fontColorField = GENERAL_COLOR_WHITE,
        fontFace = "$(GAMEPAD_MEDIUM_FONT)",
        fontSize = "$(GP_42)"
	}


	local FreqParams = {
		fontSize = 27,
		fontColorField = GENERAL_COLOR_WHITE
	}

	tooltip:AddLine("SUGGESTED PRICING", headerParams, style)
	tooltip:AddLine(tipContent.Suggested, tipParams2, style)
	tooltip:AddLine("SALES & LISTINGS", headerParams, style)
	tooltip:AddLine(tipContent.Sales, tipParams, style)
	tooltip:AddLine(tipContent.Listings, tipParams, style)

	tooltip:AddLine("Pricing is per unit.", FreqParams, style)

end

-- Integrates with the given tooltip panel.
local function IntegrateWith(tooltip)
	local method = "LayoutItem"
	local original = tooltip[method]

	-- The wrapper will call the old method first, we will add our data at the bottom of 
	-- the list. The original method returns a context that needs to be returned by the 
	-- wrapper. If this is not returned 'equipped' windows will break see (#3).
	local function Wrapper(self, itemLink, ...)
		local context = original(self, itemLink, ...)
		AddData(self, itemLink)
		return context
	end

	tooltip[method] = Wrapper
end

-- Public method to run the tooltip integration.
function PadMerchant.ToolTips.Setup()
	local tooltips = {
		left = GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_LEFT_TOOLTIP),
		right = GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_RIGHT_TOOLTIP),
		movable = GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_MOVABLE_TOOLTIP)
	}

	-- Hook into the inventory call so we can add our data 
	-- along with the orignal data that was in the tooltip
	IntegrateWith(tooltips.left)
	IntegrateWith(tooltips.right)
	IntegrateWith(tooltips.movable)
end

--[[ Globals Used & Explainations:

GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_XYZ_TOOLTIP)
	In gamepad mode the windows to the left and right are considered tooltips to
	the UI. We use the GetTooltip function of the GAMEPAD_TOOLTIPS global to get
	a reference to each of the three known tooltip windows.

GAMEPAD_TOOLTIP_COLOR_X_Y
	All colors in ESOUI are exported as globals and can be found either in the source
	code or on the ESOUI wiki at http://wiki.esoui.com/Globals. Use Ctrl+F and search 
	GamepadTooltipColors to find the complete list for the gamepad ui.

]]
