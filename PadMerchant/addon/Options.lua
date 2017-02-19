
-- Called in PadMerchant.Initialize(). Creates and shows LibAddonMenu style 
-- options window. Right now we have no options so we just show some basic
-- data about our Addon. It lets people know the addon has loaded properly.
function PadMerchant.Options.Setup()

	-- Set up an options panel with some bare
	-- bones info about the addon and version.
	local panel = {
		type = "panel",
		name = PadMerchant.name,
		displayName = "PadMerchant",
		author = "Dean McDonnell (mcdonnelldean)",
		version = PadMerchant.version
	}

	-- Grab a copy of LibAddonMenu via LibStub so we get the shared version 
	-- of it if available. Otherwise load it from 'lib/LibAddonMenu-2.0'. 
	-- Once we have it, register our panel into the Addons Menu in game.
	local AddonMenu = LibStub:GetLibrary("LibAddonMenu-2.0")
	AddonMenu:RegisterAddonPanel("PadMerchant", panel)
end

--[[ Globals Used & Explainations:

LibStub
  A library loader (in /lib/LibStub). Used to ensure only one 'lib' is loaded at a 
	time. Since there are other modules that also use LibAddonMenu-2.0. We want to ensure
	it is only loaded if it wasn't already. If it was loaded LibStub returns that version
	instead of loading it's own.

]]