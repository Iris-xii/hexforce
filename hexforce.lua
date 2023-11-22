-- :) 
-- all this sucks. No I don't care -Iris


local p_ports = {peripheral.find("focal_link")}
--local fileName = "disk/bruteforce.txt"
local focalOut = peripheral.find("focal_port")
local STR_PATTERNS = {}
local curPatternExclusive = 1
local BATCH_SIZE = 500
local FOUND_ANGLESIG = ""


function strToIota(s)
    return {
        startDir="EAST",
        angles=s,
    }
end
function getNextBatchStr()
    local out = {table.unpack(STR_PATTERNS,curPatternExclusive,curPatternExclusive+BATCH_SIZE)}
    print("Attempting "..curPatternExclusive.." to "..(curPatternExclusive+BATCH_SIZE).."  of "..#STR_PATTERNS)
    
    
    if (curPatternExclusive)>(#STR_PATTERNS) then
        curPatternExclusive = 1 -- something has gone wrong/we lost a wisp message, time to reset
    else
        curPatternExclusive = curPatternExclusive+BATCH_SIZE+1
    end
    return out
end

function batchStrToIotas(strIotas)
    --local strIotas = getNextBatchStr()
    local patternList = {}
    for k,s in pairs(strIotas) do 
        patternList[#patternList +1] = strToIota(s)
    end
    return patternList
end

function split(inputstr, sep)
        if sep == nil then
                sep = "%s"
        end
        local t={}
        for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
                table.insert(t, str)
        end
        return t
end


function makeTryNextBatchFun(p_port)
    local port = p_port
    return function()
        while port.remainingIotaCount() ~= 0 do
            port.receiveIota()
        end
        while true do
            local amountToSend = 15 -- if it breaks increase this, stuff breaks if it goes too fast, for some reason
            local currentlySent = {}
            while amountToSend > 0 do
                local iotas = batchStrToIotas(getNextBatchStr())
                port.sendIota(0,iotas) -- send
                currentlySent[#currentlySent+1] = iotas
                amountToSend = amountToSend-1
            end
            
            while true do
                local event,from = os.pullEvent("received_iota")
                if from == peripheral.getName(port) then
                    os.sleep(0.1)
                    break
                end
            end
            
            local wispResults = {}
            while port.remainingIotaCount() ~= 0 do
                wispResults[#wispResults+1] = port.receiveIota()
            end
            for k0,result in pairs(wispResults) do
                for k,v in pairs(result) do
                    if v==true then
                        --if (currentlySent~=nil) and (currentlySent[k0]~=nil) and (currentlySent[k0][k]~=nil) then
                        local found = currentlySent[k0][k].angles
                        local correct = ( (string.sub(found,1,4) ~= "aqaa") and (string.sub(found,1,4) ~= "dedd") )
                        if correct then
                            print("Found! "..found)
                            local outT = {}
                            if type(focalOut.readIota()) == 'table' then 
                                outT = focalOut.readIota()
                            end
                            outT[#outT+1] = strToIota(found)
                            focalOut.writeIota(outT)
                            return found
                        end
                        --end
                    end
                end
            end
        end
    end
end

local START_TIME = os.epoch("local")

local yieldi = 1
print("This may take a while")
local anglesFile = ""
local tArgs = table.pack(arg)
--print(textutils.serialise(tArgs,{compact=true}))
for k,v in pairs(arg) do
    if k ~= 0 then
        print("Downloading file "..v)
        local respOrNil = http.get(v)
        assert(respOrNil ~= nil,"Http request failed.")
        anglesFile = anglesFile .. "\n" .. respOrNil.readAll()
    end
end
STR_PATTERNS = split(anglesFile)

print("Ready.")

local nextBatchFuns = {}
for k,p in pairs(p_ports) do
    nextBatchFuns[#nextBatchFuns +1] = makeTryNextBatchFun(p)
end

parallel.waitForAny(table.unpack(nextBatchFuns))
local currentTime = os.epoch("local")
print("Taken ".. (((currentTime - START_TIME) /1000)) .. " seconds"   )

