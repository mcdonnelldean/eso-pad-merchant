
function PadMerchant.MasterMerchant.Setup() 
  	MasterMerchant.initBuyingAdvice = function(self, ...) end
  	MasterMerchant.initSellingAdvice = function(self, ...) end
  	MasterMerchant.AddBuyingAdvice = function(rowControl, result) end
  	MasterMerchant.AddSellingAdvice = function(rowControl, result)	end
end

--[[ Globals Used & Explainations:

MasterMerchant
  Data is read via MasterMerchant which exports a global (just like we do). We 
	have MasterMerchant set as an explict dependency in PadMerchant.txt so we can 
	be assured it is available to use as a global.

]]