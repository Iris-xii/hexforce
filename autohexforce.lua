
function run(s)
    local filename = "https://raw.githubusercontent.com/Iris-xii/hexforce/main/Rest/" .. s .. ".txt"
    local t = {filename}
    
    
    if s == "Craft_Phial" then
        t = {}
        for i=1,45 do
            t[#t+1] = "https://raw.githubusercontent.com/Iris-xii/hexforce/main/Craft_Phial/Craft_Phial_"..i..".txt"
        end
    elseif s == "Flay_Mind" then
        t = {}
        for i=1,2 do
            t[#t+1] = "https://raw.githubusercontent.com/Iris-xii/hexforce/main/Flay_Mind/Flay_Mind_"..i..".txt"
        end
    elseif s == "Consume_Wisp" then
        t = {}
        for i=1,5 do
            t[#t+1] = "https://raw.githubusercontent.com/Iris-xii/hexforce/main/Consume_Wisp/Consume_Wisp_"..i..".txt"
        end
    end
    
    print("Forcing pattern: "..s)
    shell.run("hexforce", table.unpack(t))
end

local spells = {
    "Accelerate",
    "Consume_Wisp",
    "Craft_Phial",
    "Flay_Mind",
    --"Bind_Figment",
    "Bind_Wisp",
    "Black_Suns_Zenith",
    "Blue_Suns_Zenith",
    "Create_Lava",
    "Flight",
    "Gates_Reflection",
    "Greater_Teleport",
    "Green_Suns_Zenith",
    "Propulsion",
    "Red_Suns_Zenith",
    "Summon_Greater_Sentinel",
    "Summon_Lightning",
    "Summon_Rain",
    --"Suspicious_Glyph", better not to
    "Twokais_Ideal_Condition",
    "White_Suns_Zenith",
    "Dispel_Rain",
}
for k,v in pairs(spells) do
    run(v)
    os.sleep(4)
end