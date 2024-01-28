
GOLD_ICON = "|t32:32:esoui/art/currency/gamepad/gp_gold.dds|t"


local function GenerateTipContent(itemLink)
	local itemInfo = TamrielTradeCentre_ItemInfo:New(itemLink)
	local pricing = TamrielTradeCentrePrice:GetPriceInfo(itemInfo)

	d(itemInfo)

	if pricing == nil then
		pricing = {}
	end

	local suggested = "No Suggestion Available"
	if pricing.SuggestedPrice ~= nil then
		local suggestedMin = TamrielTradeCentre:FormatNumber(pricing.SuggestedPrice, 0) .. GOLD_ICON
		local suggestedMax = TamrielTradeCentre:FormatNumber(pricing.SuggestedPrice * 1.25, 0) .. GOLD_ICON

		suggested = suggestedMin .. " to " .. suggestedMax
	end

	local range = ""
	if pricing.Avg ~= nil then
		local priceMin = TamrielTradeCentre:FormatNumber(pricing.Min, 0) .. GOLD_ICON
		local priceMax = TamrielTradeCentre:FormatNumber(pricing.Max, 0) .. GOLD_ICON
		local priceAvg = TamrielTradeCentre:FormatNumber(pricing.Avg, 0) .. GOLD_ICON

		range = "Listings from " .. priceMin .. " to " .. priceMax
		
		pricing.Min = priceMin
		pricing.Avg = priceAvg
		pricing.Max = priceMax
	end

	local frequency = "No historical data available"
	if pricing.EntryCount ~= nil then
		local listings = TamrielTradeCentre:FormatNumber(pricing.EntryCount, 0)

		frequency = listings .. " listings, averaging " .. pricing.Avg .. "."

	end

	pricing.Suggested = suggested
	pricing.Range = range
	pricing.Frequency = frequency

	return pricing
end

-- Adds sales data from MasterMerchant data about to the provided
local function AddData(tooltip, itemLink)
	if itemLink == nil then return end

	-- Our style is common to both header and tip
	local style = tooltip:GetStyle("bodySection")

	-- Generate our header and params
	local headerParams = {
		fontSize = 32
	}

	-- Generate our tip content and params
	local tipContent = GenerateTipContent(itemLink)
	local tipParams = {
		fontSize = 42,
		fontColorField = GAMEPAD_TOOLTIP_COLOR_GENERAL_COLOR_1
	}

	local FreqParams = {
		fontSize = 36
	}

	tooltip:AddLine("SUGGESTED PRICING, PER UNIT", headerParams, style)
	tooltip:AddLine(tipContent.Suggested, tipParams, style)
	tooltip:AddLine(tipContent.Frequency, FreqParams, style)
	tooltip:AddLine(tipContent.Range, FreqParams, style)
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
