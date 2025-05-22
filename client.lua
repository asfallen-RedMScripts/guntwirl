local TrickDoPrompt
local TrickEndPrompt
local TrickNext
local TrickPrev
local TrickPrompts = GetRandomIntInRange(0, 0xffffff)

local tricking = false
local index = 1

local StartKey = 0x3F4DC0EF                          
local Prompts = {
    Do = { Key = 0x2CD5343E, LocalText = 'Yap' },   
    End = { Key = 0x3F4DC0EF, LocalText = 'Bitir' },   
    Prev = { Key = 0x6319DB71, LocalText = 'Önceki' },  
    Next = { Key = 0x05CA7C52, LocalText = 'Sonraki' }, 
}

local playingGunTrick = nil

local tricks = {
    { GetHashKey("KIT_EMOTE_TWIRL_GUN"),       "Çevir" },
    { GetHashKey("KIT_EMOTE_TWIRL_GUN_DUAL"),  "İkili Çevir" },
    { GetHashKey("KIT_EMOTE_TWIRL_GUN_VAR_A"), "Çevir_A" },
    { GetHashKey("KIT_EMOTE_TWIRL_GUN_VAR_B"), "Çevir_B" },
    { GetHashKey("KIT_EMOTE_TWIRL_GUN_VAR_C"), "Çevir_C" },
    { GetHashKey("KIT_EMOTE_TWIRL_GUN_VAR_D"), "Çevir_D" },
}

function SetupTrickPrompt()
    Citizen.CreateThread(function()
        local str = Prompts.Do.LocalText
        TrickDoPrompt = PromptRegisterBegin()
        PromptSetControlAction(TrickDoPrompt, Prompts.Do.Key)
        str = CreateVarString(10, 'LITERAL_STRING', str)
        PromptSetText(TrickDoPrompt, str)
        PromptSetEnabled(TrickDoPrompt, 1)
        PromptSetVisible(TrickDoPrompt, 1)
        PromptSetStandardMode(TrickDoPrompt, 1)
        PromptSetGroup(TrickDoPrompt, TrickPrompts)
        Citizen.InvokeNative(0xC5F428EE08FA7F2C, TrickDoPrompt, true)
        PromptRegisterEnd(TrickDoPrompt)

        local str2 = Prompts.End.LocalText
        TrickEndPrompt = PromptRegisterBegin()
        PromptSetControlAction(TrickEndPrompt, Prompts.End.Key)
        str2 = CreateVarString(10, 'LITERAL_STRING', str2)
        PromptSetText(TrickEndPrompt, str2)
        PromptSetEnabled(TrickEndPrompt, 1)
        PromptSetVisible(TrickEndPrompt, 1)
        PromptSetStandardMode(TrickEndPrompt, 1)
        PromptSetGroup(TrickEndPrompt, TrickPrompts)
        Citizen.InvokeNative(0xC5F428EE08FA7F2C, TrickEndPrompt, true)
        PromptRegisterEnd(TrickEndPrompt)

        local str3 = Prompts.Next.LocalText
        TrickNext = PromptRegisterBegin()
        PromptSetControlAction(TrickNext, Prompts.Next.Key)
        str3 = CreateVarString(10, 'LITERAL_STRING', str3)
        PromptSetText(TrickNext, str3)
        PromptSetEnabled(TrickNext, 1)
        PromptSetVisible(TrickNext, 1)
        PromptSetStandardMode(TrickNext, 1)
        PromptSetGroup(TrickNext, TrickPrompts)
        Citizen.InvokeNative(0xC5F428EE08FA7F2C, TrickNext, true)
        PromptRegisterEnd(TrickNext)

        local str4 = Prompts.Prev.LocalText
        TrickPrev = PromptRegisterBegin()
        PromptSetControlAction(TrickPrev, Prompts.Prev.Key)
        str4 = CreateVarString(10, 'LITERAL_STRING', str4)
        PromptSetText(TrickPrev, str4)
        PromptSetEnabled(TrickPrev, 1)
        PromptSetVisible(TrickPrev, 1)
        PromptSetStandardMode(TrickPrev, 1)
        PromptSetGroup(TrickPrev, TrickPrompts)
        Citizen.InvokeNative(0xC5F428EE08FA7F2C, TrickPrev, true)
        PromptRegisterEnd(TrickPrev)
    end)
end

Citizen.CreateThread(function()
    SetupTrickPrompt()
    while true do
        Citizen.Wait(4)
        if Citizen.InvokeNative(0x580417101DDB492F, 0, StartKey) then
            tricking = not tricking
        end
        if tricking == true and not IsEntityDead(PlayerPedId()) then
            local label = CreateVarString(10, 'LITERAL_STRING', "" .. tricks[index][2])
            PromptSetActiveGroupThisFrame(TrickPrompts, label)
            if Citizen.InvokeNative(0xC92AC953F0A982AE, TrickDoPrompt) then
                if index <= 2 then 
                    StartTrick(tricks[index][1])
                else
                    TrickVariation(index - 2)
                end
            end
            if Citizen.InvokeNative(0xC92AC953F0A982AE, TrickEndPrompt) then
                tricking = false
                ClearPedTasksImmediately(PlayerPedId())
            end

            if IsControlJustPressed(0, 0x53296B75) then
                tricking = false
                ClearPedTasksImmediately(PlayerPedId())
            end
            if Citizen.InvokeNative(0xC92AC953F0A982AE, TrickNext) then
                index = index + 1
                if index > #tricks then
                    index = 1
                end
            end
            if Citizen.InvokeNative(0xC92AC953F0A982AE, TrickPrev) then
                index = index - 1
                if index == 0 then
                    index = #tricks
                end
            end
        end
    end
end)

function CanTwirl(hash)
    if (IsWeaponRevolver(hash) or IsWeaponPistol(hash)) then
        return true
    else
        return false
    end
end

function IsWeaponRevolver(hash)
    return Citizen.InvokeNative(0xC212F1D05A8232BB, hash)
end

function IsWeaponPistol(hash)
    return Citizen.InvokeNative(0xDDC64F5E31EEDAB6, hash)
end

function StartTrick(trickhash)
    local hasw, playerw = GetCurrentPedWeapon(PlayerPedId(), true)
    if CanTwirl(playerw) then
        playingGunTrick = trickhash
        Citizen.InvokeNative(0xB31A277C1AC7B7FF, PlayerPedId(), 4, 1, trickhash, 1, 1, 0, 0)
    end
end

function TrickVariation(variationIndex)
    local ped = PlayerPedId()
    local hasw, playerw = GetCurrentPedWeapon(ped, true)
    if CanTwirl(playerw) then
        local baseEmote = GetHashKey("KIT_EMOTE_TWIRL_GUN")
        if playingGunTrick ~= nil then
            baseEmote = playingGunTrick
        end


        Citizen.InvokeNative(0xCBCFFF805F1B4596, ped, baseEmote)


        local currentVariation = Citizen.InvokeNative(0x2C4FEC3D0EFA9FC0, ped)
        Citizen.InvokeNative(0xB31A277C1AC7B7FF, ped, 4, 1, currentVariation, true, false, false, false, false)

        local variationHash = Citizen.InvokeNative(0xF4601C1203B1A78D, baseEmote, variationIndex)
        if variationHash and variationHash ~= 0 then
            Citizen.InvokeNative(0x01F661BB9C71B465, ped, 4, variationHash)
            Citizen.InvokeNative(0x408CF580C5E96D49, ped, 4)
        end
    end
end

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end
    tricking = false
    if PlayerPedId() and DoesEntityExist(PlayerPedId()) then
        ClearPedTasksImmediately(PlayerPedId())
    end
end)
