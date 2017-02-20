
-- Wraps the original method provided in a guarded call. The original method 
-- will conditionally fire based on the mode the game is in. This should allow 
-- folks to use MM in PC and Gamepad Mode with no loss of functionality.
local function GuardedCall(original)
	return function (...)
		if (not IsInGamepadPreferredMode()) then
			return original(...)
		end
	end
end

-- Called in PadMerchant.Initialize(). Sets up our guarded
-- overrides for MasterMerchant. These guards will stop any
-- Gamepad mode crashes due to PC mode specific functionality.
function PadMerchant.MasterMerchant.Setup()
		-- A table of the original MM methods we will override
		local original = {
			initBuyingAdvice = MasterMerchant.initBuyingAdvice,
  		initSellingAdvice = MasterMerchant.initSellingAdvice,
  		AddBuyingAdvice = MasterMerchant.AddBuyingAdvice,
  		AddSellingAdvice = MasterMerchant.AddSellingAdvice
		}

		-- Override applicable MM methods with our guard. Note we aren't changing
		-- any functionality regardless. We just don't want these methods to fire
		-- in Gamepad mode as they break the core UI while active.
  	MasterMerchant.initBuyingAdvice = GuardedCall(original.initBuyingAdvice)
  	MasterMerchant.initSellingAdvice = GuardedCall(original.initSellingAdvice)
  	MasterMerchant.AddBuyingAdvice = GuardedCall(original.AddBuyingAdvice)
  	MasterMerchant.AddSellingAdvice = GuardedCall(original.AddSellingAdvice)
end

--[[ Globals Used & Explainations:

MasterMerchant
  Data is read via MasterMerchant which exports a global (just like we do). We 
	have MasterMerchant set as an explict dependency in PadMerchant.txt so we can 
	be assured it is available to use as a global.

]]