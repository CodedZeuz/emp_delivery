local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
zeU = Tunnel.getInterface("emp_delivery")

-----------------------------------------------------------------------------------------------------------------------------------------
--[ VARIÁVEIS ]--------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------

local blips = false
local servico = false
local selecionado = 0

-----------------------------------------------------------------------------------------------------------------------------------------
--[ LOCAIS ]-----------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------´

-- PEGAR BLIP --

local CoordenadaX = 165.99
local CoordenadaY = -1451.58
local CoordenadaZ = 29.25

-----------------------------------------------------------------------------------------------------------------------------------------
--[ RESIDENCIAS ]------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------

local locs = {
	[1] = { ['x'] = -1250.78, ['y'] = -1328.77, ['z'] = 3.88 }, 
	[2] = { ['x'] = -1152.32, ['y'] = -1520.27, ['z'] = 4.37 },  
	[3] = { ['x'] = -1091.08, ['y'] = -1041.17, ['z'] = 2.16 }, 
	[4] = { ['x'] = -928.67, ['y'] = -936.23, ['z'] = 2.16 }, 
	[5] = { ['x'] = -1356.07, ['y'] = -774.92, ['z'] = 19.98 }, 
	[6] = { ['x'] = -1881.62, ['y'] = -578.21, ['z'] = 11.81 },
	[7] = { ['x'] = -1811.61, ['y'] = -637.68, ['z'] = 10.94 }, 
	[8] = { ['x'] = -1766.43, ['y'] = -677.17, ['z'] = 10.18 }, 
	[9] = { ['x'] = -1742.21, ['y'] = -700.02, ['z'] = 10.13 }, 
	[10] = { ['x'] = -1862.61, ['y'] = -353.89, ['z'] = 49.24 }, 
	[11] = { ['x'] = -1663.37, ['y'] = -535.97, ['z'] = 35.32 }, 
	[12] = { ['x'] = -1541.22, ['y'] = 125.65, ['z'] = 56.78 }, 
	[13] = { ['x'] = -1494.61, ['y'] = 420.16, ['z'] = 111.24 }, 
	[14] = { ['x'] = -1498.97, ['y'] = 520.31, ['z'] = 118.28 }, 
	[15] = { ['x'] = -1358.73, ['y'] = 553.21, ['z'] = 130.0 }, 
	[16] = { ['x'] = -1287.92, ['y'] = 625.41, ['z'] = 138.85 }, 
	[17] = { ['x'] = -1241.85, ['y'] = 672.91, ['z'] = 142.83 }, 
	[18] = { ['x'] = -1197.79, ['y'] = 692.6, ['z'] = 147.39 }, 
	[19] = { ['x'] = -1033.87, ['y'] = 686.04, ['z'] = 161.31 }, 
	[20] = { ['x'] = -951.24, ['y'] = 683.8, ['z'] = 153.58 } 
}	

-----------------------------------------------------------------------------------------------------------------------------------------
--[ ENTREGAR DELIVERY ]------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------

Citizen.CreateThread(function()
	while true do
		local zeuzwait = 1000
		if servico then
			local ped = PlayerPedId()
			local x,y,z = table.unpack(GetEntityCoords(ped))
			local bowz,cdz = GetGroundZFor_3dCoord(locs[selecionado].x,locs[selecionado].y,locs[selecionado].z)
			local distance = GetDistanceBetweenCoords(locs[selecionado].x,locs[selecionado].y,cdz,x,y,z,true)

			if distance <= 30 then
				zeuzwait = 4
				DrawMarker(21,locs[selecionado].x,locs[selecionado].y,locs[selecionado].z+0.20,0,0,0,0,180.0,130.0,2.0,2.0,1.0,216, 151, 60,100,1,0,0,1)
				if IsControlJustPressed(0,38) then
					-- VEÍCULO DE ENTREGAS
					if IsVehicleModel(GetVehiclePedIsUsing(ped),GetHashKey("pcj")) then
						if zeU.checkPayment() then
							RemoveBlip(blips)
							backentrega = selecionado
							while true do
								if backentrega == selecionado then
										selecionado = math.random(20)
								else
									break
								end
								Citizen.Wait(1)
							end
							CriandoBlip(locs,selecionado)
							TriggerEvent("Notify","aviso","Vá até o próximo local e <b>realize o delivery.</b>")
						end
					end
				end
			end
		end
		Citizen.Wait(zeuzwait)
	end
end)

-----------------------------------------------------------------------------------------------------------------------------------------
--[ PEGAR BLIP ]-------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------

Citizen.CreateThread(function()
	while true do
		local zeuzwait = 1000
		if not servico then
			local ped = PlayerPedId()
			local x,y,z = table.unpack(GetEntityCoords(ped))
			local bowz,cdz = GetGroundZFor_3dCoord(CoordenadaX,CoordenadaY,CoordenadaZ)
			local distance = GetDistanceBetweenCoords(CoordenadaX,CoordenadaY,cdz,x,y,z,true)

			if distance <= 3 then
				zeuzwait = 4
				DrawMarker(23,CoordenadaX,CoordenadaY,CoordenadaZ-0.97,0,0,0,0,0,0,1.0,1.0,0.5,216, 151, 60,100,0,0,0,0)
				if distance <= 1.2 then
					txtDraw("~w~PRESSIONE  ~o~E~w~  PARA INCIAR ENTREGAS",4,0.5,0.93,0.5216, 151, 60,255,180)
					if IsControlJustPressed(0,38) then
						servico = true
						selecionado = math.random(20)
						CriandoBlip(locs,selecionado)
						TriggerEvent("Notify","sucesso","Você entrou em serviço.")
						TriggerEvent("Notify","aviso","Vá até o próximo local e <b>realize o delivery</b>.")
					end
				end
			end
		end
		Citizen.Wait(zeuzwait)
	end
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- CANCELAR
-----------------------------------------------------------------------------------------------------------------------------------------

Citizen.CreateThread(function()
	while true do
		local zeuzwait = 1000
		if servico then
			zeuzwait = 4
			if IsControlJustPressed(0,168) then
				servico = false
				RemoveBlip(blips)
				TriggerEvent("Notify","aviso","Você saiu de serviço.")
			end
		end
		Citizen.Wait(zeuzwait)
	end
end)

-----------------------------------------------------------------------------------------------------------------------------------------
--[ FUNÇÕES ]----------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------

function txtDraw(text,font,x,y,scale,r,g,b,a)
	SetTextFont(font)
	SetTextScale(scale,scale)
	SetTextColour(r,g,b,a)
	SetTextOutline()
	SetTextCentre(1)
	SetTextEntry("STRING")
	AddTextComponentString(text)
	DrawText(x,y)
end

function DrawText3Ds(x,y,z, text)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
    local factor = (string.len(text)) / 370
    DrawRect(_x,_y+0.0125, 0.015+ factor, 0.03, 41, 11, 41, 68)
end

function CriandoBlip(locs,selecionado)
	blips = AddBlipForCoord(locs[selecionado].x,locs[selecionado].y,locs[selecionado].z)
	SetBlipSprite(blips,433)
	SetBlipColour(blips,47)
	SetBlipScale(blips,0.4)
	SetBlipAsShortRange(blips,false)
	SetBlipRoute(blips,true)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString("Ponto de Entrega")
	EndTextCommandSetBlipName(blips)
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- TEXTO 3D
-----------------------------------------------------------------------------------------------------------------------------------------

function Text3D(x,y,z,textInput,fontId,scaleX,scaleY,r, g, b, a)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    local dist = GetDistanceBetweenCoords(px,py,pz, x,y,z, 1)

    local scale = (1/dist)*20
    local fov = (1/GetGameplayCamFov())*100
    local scale = scale*fov

    SetTextScale(scaleX*scale, scaleY*scale)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(r, g, b, a)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextEdge(2, 0, 0, 0, 150)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    SetTextCentre(1)	
    AddTextComponentString(textInput)
    SetDrawOrigin(x,y,z+2, 0)
    DrawText(0.0, 0.0)
    ClearDrawOrigin()
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- NPC
-----------------------------------------------------------------------------------------------------------------------------------------

local pedlist = {
	{['x'] = 166.37, ['y'] = -1451.08, ['z'] = 29.25, ['h'] = 141.443, ['hash'] = 0x0F977CEB, ['hash2'] = "s_m_y_chef_01"}
}

Citizen.CreateThread(function()
	for k,v in pairs(pedlist) do 
		RequestModel(GetHashKey(v.hash2))

		while not HasModelLoaded(GetHashKey(v.hash2)) do
			Citizen.Wait(100)
		end
		
		local ped = CreatePed(4,v.hash,v.x,v.y,v.z-1,v.h,false)
		FreezeEntityPosition(ped,true)
		SetEntityInvincible(ped,true)
		SetBlockingOfNonTemporaryEvents(ped,true)
	end	
end)