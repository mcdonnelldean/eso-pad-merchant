
-- Generates the tip content by reading and munching the itemPriceTip from MasterMerchant. Handles 
-- items that are not yet seen (MM returns them as nil). Returns a printable string, never nil.
local function GenerateTipContent(itemLink)
	local tip = MasterMerchant:itemPriceTip(itemLink, true, clickable)

	-- This probably should be cleaned up. Until I 
	-- get to play with regex in lua, it will do.
	if(tip ~= nil) then
		tip = string.sub(tip, 11)
		tip = string.gsub(tip, "%):", "(")
		tip = string.gsub(tip, "items,", "items) in ")
		tip = string.gsub(tip, "/", "(")
		tip = string.gsub(tip, "sales,", "sales in")
		tip = string.gsub(tip, "sale,", "sale in")
		tip = string.gsub(tip, "sales%(", "sales (")
		tip = string.gsub(tip, "sale%(", "sale (")
		tip = string.gsub(tip, "days%( ", "days (")
		tip = string.gsub(tip, "day%( ", "day (")
		tip = tip .. " |t16:16:esoui/art/currency/gamepad/gp_gold.dds|t" .. " avg)"
		return tip
	end

	-- nill means now data known yet, so we parse 
	-- that into a readable message for the user.
	return "Not yet seen"
end

-- Adds sales data from MasterMerchant data about to the provided
local function AddData(tooltip, itemLink)	
	if itemLink == nil then return end

	-- Our style is common to both header and tip
	local style = tooltip:GetStyle("bodySection")

	-- Generate our header and params
	local headerContent = "HISTORICAL PRICING"
	local headerParams = {
		fontSize = 28, 
		fontColorField = GAMEPAD_TOOLTIP_COLOR_GENERAL_COLOR_1
	}
	
	-- Generate our tip content and params
	local tipContent = GenerateTipContent(itemLink)
	local tipParams = { 
		fontSize = 26
	}

	-- Add the header and the tip to the end of the tooltip.
	tooltip:AddLine(headerContent, headerParams, style)
	tooltip:AddLine(tipContent, tipParams, style)
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

MasterMerchant
  	Data is read via MasterMerchant which exports a global (just like we do). We 
	have MasterMerchant set as an explict dependency in PadMerchant.txt so we can 
	be assured it is available to use as a global.

GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_XYZ_TOOLTIP)
	In gamepad mode the windows to the left and right are considered tooltips to
	the UI. We use the GetTooltip function of the GAMEPAD_TOOLTIPS global to get
	a reference to each of the three known tooltip windows.

GAMEPAD_TOOLTIP_COLOR_X_Y
	All colors in ESOUI are exported as globals and can be found either in the source
	code or on the ESOUI wiki at http://wiki.esoui.com/Globals. Use Ctrl+F and search 
	GamepadTooltipColors to find the complete list for the gamepad ui.

]]
