-- Our "namespace". Lua doesn't have a concept of explicit namespacing, but we 
-- can use tables as a proxy. The files in /addons will populate the TradeHouse, 
-- ToolTips, and Options tables once they load. This way our addon only exports 
-- a single global 'namespace' table instead of many misc globals variables.
PadMerchant = {
	name = "PadMerchant",
	version = "1.0",
	TradeHouse = {},
	ToolTips = {},
	MasterMerchant = {},
	Options = {}
}

-- Our addons Initialize event. This will be 
-- called once per EVENT_ADD_ON_LOADED event.
local function Initialize(event, addon)
	
	-- The EVENT_ADD_ON_LOADED event is called once per addon, 
	-- hence why we need to name check and de register from the 
	-- event once our event has come through. 
	if addon ~= PadMerchant.name then return end
	GetEventManager():UnregisterForEvent(PadMerchant.name, EVENT_ADD_ON_LOADED)

	-- Core of the addon only activates in Gamepad Preferred Mode to allow
	-- MasterMerchant to be used in PC mode by swapping modes and reloading
	-- the UI. (Some people play with gampad ui and shop with pc ui).
	if(IsInGamepadPreferredMode()) then
		PadMerchant.MasterMerchant.Setup()
		PadMerchant.TradeHouse.Setup()
		PadMerchant.ToolTips.Setup()
	end

	-- Setup the options regardless of mode as we
	-- always want the settings window available.
	PadMerchant.Options.Setup()
end

-- Register our Initialize method to the EVENT_ADD_ON_LOADED event. This event is fired by 
-- the game when it loads addons. It fires once per addon, per login or /uireload command.
GetEventManager():RegisterForEvent(PadMerchant.name, EVENT_ADD_ON_LOADED, Initialize)



--[[ Globals Used & Explainations:

EVENT_ADD_ON_LOADED
  The game event for loading addins

GetEventManager()
  Built in function for getting access to the games event manager. Allows
	our addon to register functions as listeners for various events.

]]