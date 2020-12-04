-- SCREEN POSITION PARAMETERS
local screenPosX = 0.165                    -- X coordinate (top left corner of HUD)
local screenPosY = 0.882                    -- Y coordinate (top left corner of HUD)

-- SPEEDOMETER PARAMETERS
local speedLimit = 100.0                    -- Speed limit for changing speed color
local speedColorText = {255, 255, 255}      -- Color used to display speed label text
local speedColorUnder = {255, 255, 255}     -- Color used to display speed when under speedLimit
local speedColorOver = {255, 96, 96}        -- Color used to display speed when over speedLimit

-- FUEL PARAMETERS
local fuelWarnLimit = 15.0                  -- Fuel limit for triggering warning color
local fuelColorText = {246, 214, 85 }       -- Color used to display fuel text
local fuelColorOver = {255, 255, 255}       -- Color used to display fuel when good
local fuelColorUnder = {255, 96, 96}        -- Color used to display fuel warning

-- GEAR PARAMETERS
local GearColor     = {100, 195, 93}
local GearColorText = {255, 255, 255}
local GearColorText2 = {255, 255, 255}
local MaxGearColor  = {100, 195, 93}

-- CRUISE CONTROL PARAMETERS
local cruiseInput = 137                     -- Toggle cruise on/off with CAPSLOCK or A button (controller)
local cruiseColorOn = {160, 255, 160}       -- Color used when seatbelt is on
local cruiseColorOff = {255, 255, 255}      -- Color used when seatbelt is off

local pedInVeh = false
local currentFuel = 0.0

-- Main thread
Citizen.CreateThread(function()
    -- Initialize local variable
    local currSpeed = 0.0
    local cruiseSpeed = 999.0
    local prevVelocity = {x = 0.0, y = 0.0, z = 0.0}
    local cruiseIsOn = false

    while true do
        -- Loop forever and update HUD every frame
        Citizen.Wait(0)

        -- Get player PED, position and vehicle and save to locals
        local player = GetPlayerPed(-1)
        local position = GetEntityCoords(player)
        local vehicle = GetVehiclePedIsIn(player, false)

        -- Set vehicle states
        if IsPedInAnyVehicle(player, false) then
            pedInVeh = true
        else
            pedInVeh = false
            cruiseIsOn = false
        end
                    
        
            -- Display remainder of HUD when engine is on and vehicle is not a bicycle
            local vehicleClass = GetVehicleClass(vehicle)
            if pedInVeh and GetIsVehicleEngineRunning(vehicle) and GetVehicleClass(vehicle) ~= 13 then
                -- Save previous speed and get current speed
                local prevSpeed = currSpeed
                currSpeed = GetEntitySpeed(vehicle)

                -- Set PED flags
                SetPedConfigFlag(PlayerPedId(), 32, true)

                 -- When player in driver seat, handle cruise control
                 if (GetPedInVehicleSeat(vehicle, -1) == player) then
                    -- Check if cruise control button pressed, toggle state and set maximum speed appropriately
                    if IsControlJustReleased(0, cruiseInput) and (enableController or GetLastInputMethod(0)) then
                        cruiseIsOn = not cruiseIsOn
                        cruiseSpeed = currSpeed
                    end
                    local maxSpeed = cruiseIsOn and cruiseSpeed or GetVehicleHandlingFloat(vehicle,"CHandlingData","fInitialDriveMaxFlatVel")
                    SetEntityMaxSpeed(vehicle, maxSpeed)
                else
                    -- Reset cruise control
                    cruiseIsOn = false
                end
                

                -- Get vehicle speed in KMH and draw speedometer
                local speed = currSpeed*3.6
                local speedColor = (speed >= speedLimit) and speedColorOver or speedColorUnder
                drawTxt(("%.3d"):format(math.ceil(speed)), 2, speedColor, 0.5, screenPosX + -0.150, screenPosY + -0.113)
                drawTxt("KMH", 2, speedColorText, 0.3, screenPosX + -0.131, screenPosY + -0.103)
                
                -- Draw fuel gauge; always displays 100 but can be modified by setting currentFuel with an API call
                local currentFuel = GetVehicleFuelLevel(vehicle)
                local fuelColor = (currentFuel >= fuelWarnLimit) and fuelColorOver or fuelColorUnder
                drawTxt(("%.3d"):format(math.ceil(currentFuel)), 2, fuelColor, 0.5, screenPosX + -0.115, screenPosY + -0.113)
                drawTxt("Fuel", 2, fuelColorText, 0.3, screenPosX + -0.096, screenPosY + -0.103)

                -- Draw Current Gear and Max Gear on Vehicle by Scar
                local currentGear = GetVehicleCurrentGear(vehicle)
                local MaxGear = GetVehicleHighGear(vehicle)
                local vehicle = GetVehiclePedIsIn(player, false)
                drawTxt(("%.1d"):format(math.ceil(currentGear)), 2, GearColor, 0.5, screenPosX + -0.080, screenPosY + -0.113)
                drawTxt(":", 2, GearColorText, 0.3, screenPosX + -0.073, screenPosY + -0.107)
                drawTxt(("%.1d"):format(math.ceil(MaxGear)), 2, MaxGearColor, 0.5, screenPosX + -0.068, screenPosY + -0.113)
                drawTxt("Gear", 2, GearColorText2, 0.3, screenPosX + -0.060, screenPosY + -0.103)

                -- Draw cruise control status
                local cruiseColor = cruiseIsOn and cruiseColorOn or cruiseColorOff
                drawTxt("CRUISE", 2, cruiseColor, 0.4, screenPosX + -0.040, screenPosY + -0.107)
        end
    end
end)

-- Helper function to draw text to screen
function drawTxt(content, font, colour, scale, x, y)
    SetTextFont(font)
    SetTextScale(scale, scale)
    SetTextColour(colour[1],colour[2],colour[3], 255)
    SetTextEntry("STRING")
    SetTextDropShadow(0, 0, 0, 0,255)
    SetTextDropShadow()
    SetTextEdge(4, 0, 0, 0, 255)
    SetTextOutline()
    AddTextComponentString(content)
    DrawText(x, y)
end
