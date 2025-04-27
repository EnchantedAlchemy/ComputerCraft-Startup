
term.setTextColor(colors.black)
if fs.find("gitget")[1] == nil then
	shell.run("wget https://gist.githubusercontent.com/SquidDev/e0f82765bfdefd48b0b15a5c06c0603b/raw/clone.min.lua gitget")
end
if fs.find("resetComputer")[1] == nil then
	shell.run("wget https://gist.githubusercontent.com/EnchantedAlchemy/407469e7a993f20c8773c835b4d6fab0/raw/03f30e8436ee9eda444f4badc967394c4df921c0/resetProgram.lua resetComputer")
end
if fs.find("utilities")[1] ~= nil then
	shell.run("delete utilities")
end
shell.run("gitget https://github.com/EnchantedAlchemy/ComputerCraft-Utilities utilities")

local textFunctions = require("utilities/textFunctions")
term.setTextColor(colors.white)
textFunctions.clear()

function initialize()

	term.setTextColor(colors.black)
	shell.run("set motd.enable false")
	
	settings.define("sourceURL", {
		description = "The URL of the main program source.",
		default = "",
		type = "string"
	})
	settings.define("sourceType", {
		description = "Whether the source is a git repository or a raw text file.",
		default = 0,
		type = "number"
	})
	
	textFunctions.clear()
	setupMode = textFunctions.choicePrompt("Enter a value:", {"Setup", "Delete Program"})
	
	if setupMode == 2 then

		textFunctions.resetComputer()
		os.reboot()
		return

	end

	textFunctions.clear()
	sourceType = textFunctions.choicePrompt("What is your code source?:", {"Git Repository", "Raw Text File", "No Source"})
	settings.set("sourceType", sourceType)

	textFunctions.clear()
	if sourceType ~= 3 then
		sourceURL = textFunctions.prompt("Enter the URL to your code source:")
		settings.set("sourceURL", sourceURL)
	end

	textFunctions.clear()

	settings.save(".settings")

end

settings.load(".settings")
if (settings.get("sourceURL") == nil or settings.get("sourceURL") == "") and settings.get("sourceType") ~= 3 then
	initialize()
end

term.setTextColor(colors.black)
shell.run("delete main")
textFunctions.clear()

if settings.get("sourceType") == 1 then

	shell.run("delete mainProgram")
	textFunctions.clear()

	local function createMain()
		shell.run("gitget " .. settings.get("sourceURL") .. " mainProgram")
		if fs.exists("mainProgram") == false then error() end
	end

	if pcall(createMain) then
		
		local foundRunner = false
		for i,v in pairs(fs.list("mainProgram")) do
			if string.lower(v) == "runner" then
				foundRunner = true
				break
			end
		end

		term.setTextColor(colors.white)
		textFunctions.clear()

		if foundRunner then
			shell.run("mainProgram/runner")
		else
			print("\nProgram has no runner. Re-Initializing.")
			term.setTextColor(colors.black)

			settings.set("sourceURL", "")
			settings.set("sourceType", 0)
			settings.save(".settings")

			os.sleep(2)
			os.reboot()
		end
		
	else

		term.setTextColor(colors.white)
		print("\nError in URL. Re-Initializing.")
		term.setTextColor(colors.black)

		settings.set("sourceURL", "")
		settings.set("sourceType", 0)
		settings.save(".settings")

		os.sleep(2)
		os.reboot()
	end

elseif settings.get("sourceType") == 2 then

	local function createMain()
		shell.run("wget " .. settings.get("sourceURL") .. " runner")
		if fs.exists("runner") == false then error() end
	end

	if pcall(createMain) then
		term.setTextColor(colors.white)
		textFunctions.clear()
		shell.run("runner")
	else
		term.setTextColor(colors.white)
		print("\nError in URL. Re-Initializing.")
		term.setTextColor(colors.black)

		settings.set("sourceURL", "")
		settings.set("sourceType", 0)
		settings.save(".settings")

		os.sleep(2)
		os.reboot()
	end

end
