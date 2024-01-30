local function requireOrInstall(lib, installer, err)
	local status, result = pcall(require, lib)
	if status then
		return result
	else
		if installer then
			shell.run(installer)
			local status, result = pcall(require, lib)
			if status then
				return result
			else
				print("Failed to install/import "..lib..":")
				error(result)
			end
		else
			error(err)
		end
	end
end

local getCCCrypt = "wget https://raw.githubusercontent.com/TheStraying11/ccCrypt/main/ccCrypt.lua ccCrypt.lua"
local getKey = [[
Create a random 32 Byte key and save it in a file "key.lua" as: 
	"return {0xFF, 0xFF, 0xFF...}"
]]
local ccCrypt = requireOrInstall("ccCrypt", getCCCrypt)
local crypt = ccCrypt(requireOrInstall("key", nil, getKey))

local protocol = "potionSelector_"..tostring(os.getComputerID())

local chest = peripheral.wrap("left")
local pylons = {
    peripheral.find("pylons:infusion_pylon")
}

local getResponseCodes = "wget https://raw.githubusercontent.com/TheStraying11/ccPotionSelector/main/responseCodes.lua responseCodes.lua"
local responseCodes = requireOrInstall("responseCodes", getResponseCodes)

rednet.open("back")

local function split(s, sep)
    if sep == nil then
        sep = "%s"
    end
    local t = {}
    for str in string.gmatch(s, "([^"..sep.."]+)") do
        table.insert(t, str)
    end

    return t
end

local function indexOf(arr, val)
    for i, v in ipairs(arr) do
        if v == val then
            return i
        end
    end

    return nil
end

local function respond(code, msg)
    if msg then
    	msg = tostring(code)..' '..responseCodes[code]..": "..msg
    else
    	msg = tostring(code)..' '..responseCodes[code]
    end

    rednet.broadcast(crypt:encrypt(msg), protocol)
end

local function activeEffects()
    local effects = {}
    for _, pylon in ipairs(pylons) do
        for slot = 1, pylon.size() do
            local slotDetail = pylon.getItemDetail(slot)
            if slotDetail then
                table.insert(effects, slotDetail.displayName)
            end
        end
    end
    
    return effects
end

local function inactiveEffects()
    local effects = {}
    for slot = 1, chest.size() do
        local slotDetail = chest.getItemDetail(slot)
        if slotDetail then
            table.insert(effects, slotDetail.displayName)
        end
    end
    
    return effects
end

local function findInactiveEffect(effect)
    for slot = 1, chest.size() do
        local detail = chest.getItemDetail(slot)
        if detail and detail.displayName == effect then
            return slot
        end
    end
end

local function findActiveEffect(effect)
    for _, pylon in ipairs(pylons) do
        for slot = 1, pylon.size() do
            local detail = pylon.getItemDetail(slot)
            if detail and detail.displayName == effect then
                return slot
            end
        end
    end
end

local commands = {
    getActiveEffects = function()
        respond(200, table.concat(activeEffects(), ","))
    end,
    
    getInactiveEffects = function()
        respond(200, table.concat(inactiveEffects(), ","))
    end,
    
    getAvailableEffects = function()
        local active = table.concat(activeEffects(), ",")
        local inactive = table.concat(inactiveEffects(), ",")
        respond(200, active..","..inactive)
    end,
    
    activateEffect = function(effect)
        if not inactiveEffects()[effect] then
            respond(404, "Effect: "..effect.." not found")
            return
        end
        
        for _, pylon in ipairs(pylons) do
            local l = pylon.list()
            if #l < pylon.size() or indexOf(l, nil) then
            	local slot = findInactiveEffect(effect)
                chest.pushItems(peripheral.getName(pylon), slot)
                respond(200, tostring(slot))
                return
            end
        end
        
        respond(409, "no free slots")
    end,
    
    deactivateEffect = function(effect)
        if not activeEffects()[effect] then
            respond(404, "Effect: "..effect.." not found")
            return
        end
        
        local l = chest.list()
        if #l < l.size() or indexOf(l1, nil) then
            local pylon, slot = findActiveEffect(effect)
            pylon.pushItems(peripheral.getName(chest), slot)
            respond(200, tostring(slot))
        else
            respond(409, "chest is full")
        end
    end
}

local function recv()
    local r = {rednet.receive(protocol)}
    local status, cmd, args = pcall(
        function()
            local msg = split(crypt:decrypt(r[2]))
            return msg[1], {table.unpack(msg, 2)}
        end
    )
    if not status then 
        respond(400, "Invalid request: "..cmd.." "..table.concat(args, " "))
        return 
    end
    if not commands[cmd] then 
        respond(501, "Invalid command: "..cmd)
        return 
    end
    commands[cmd](table.unpack(args))
end

while true do
    recv()
end
