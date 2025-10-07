script_name('Bus Helper')
script_author('[01]Alex_Blade || t.me/@RimSnake')
script_version('2.0')
script_version_number(9)

require('moonloader')
local encoding = require 'encoding'
local imgui = require 'mimgui'
local fa = require 'fAwesome6'
local inicfg = require 'inicfg'
local sampev = require 'lib.samp.events'
require 'lib.samp.events'
local memory = require 'memory'
local json = require('json')
local lfs = require 'lfs'  -- библиотека для работы с файлами и папками
local https = require('ssl.https')
local ltn12 = require('ltn12')
local dlstatus = require('moonloader').download_status
local updateUrl = 'https://raw.githubusercontent.com/A-Blade/BusHelper/main/update.json'
local localVersion = 8
local updateFile = getWorkingDirectory() .. '\\bushelper_update.json'


local larcDataFile = 'Bus Helper//larc_data.json'
local folderPath = 'Bus Helper'

-- проверка и создание папки
local function ensureDirExists(path)
    local attr = lfs.attributes(path)
    if not attr then
        lfs.mkdir(path)
        print('[DEBUG] Created folder: ' .. path)
    end
end


local larcData = {}
local blockData = {}
local routeStartTime = nil


encoding.default = 'CP1251'
local u8 = encoding.UTF8
local wDir, this = getWorkingDirectory(), thisScript()
local mVec2, mVec4, mn = imgui.ImVec2, imgui.ImVec4, imgui.new
local zeroClr = mVec4(0,0,0,0)
local directIni = 'Bus Helper//Settings.ini'
local setts = inicfg.load({
	main = {
		pX = select(1, getScreenResolution())/2-160,
		pY = select(2, getScreenResolution())/2-121,
		infoToChat = true,
		statsSt = false,
		showCharacters = false,
		lareCost = false,
		spX = 10,
		spY = 350,
		elixiruse = 0
	},
	cost = {
		brrul = 0,
		serrul = 0,
		zolrul = 0,
		platrul = 0,
		tidex = 0,
		award = 0,
		pilot = 0,
		garbage = 0,
		supercar = 0,
		org = 0,
		rareYellow = 0,
		rareBlue = 0,
		rareRed = 0,
		vice = 0,
		marvel = 0,
		gentlemen = 0,
		minecraft = 0,
		busdriver = 0,
		superauto = 0,
		nostalgia = 0,
		oligarch = 0,
		customacc = 0,
		crafter = 0,
		mortal = 0,
		halloween2022 = 0,
		familyguards = 0,
		rooster = 0,
		fortnite = 0,
		easter2024 = 0,
		trucker = 0,
		delivery = 0,
		secondhand = 0,
		randlar = 0,
		conceptcar = 0,
		fisher = 0,
		treasure = 0,
		supermoto = 0,
		arizona = 0
	}
}, directIni)

local stats = inicfg.load({
	main = {
		money = 0,
		larec = 0,
		lcost = 0,
		reys = 0,
		hreys = 0,
		hmoney = 0,
		hlarec = 0,
		hlcost = 0
	}
}, 'Bus Helper//Stats.ini')

local statsSt, larcStatsSt, mainSt, dangSt, dangohrSt, mwSy = mn.bool(setts.main.statsSt), mn.bool(false), mn.bool(false), mn.bool(false), mn.bool(false), 500
local infoToChat, showCharacters, lareCost = mn.bool(setts.main.infoToChat), mn.bool(setts.main.showCharacters), mn.bool(setts.main.lareCost)
local f18, f25 = nil, nil
local inJob = false
local elixiroff = false
larcStatsSt = { [0] = false, selectedDate = nil }
local itemBuffer = {}

local cost = {
	brrul = mn.int(setts.cost.brrul),
	serrul = mn.int(setts.cost.serrul),
	zolrul = mn.int(setts.cost.zolrul),
	platrul = mn.int(setts.cost.platrul),
	tidex = mn.int(setts.cost.tidex),
	award = mn.int(setts.cost.award),
	pilot = mn.int(setts.cost.pilot),
	garbage = mn.int(setts.cost.garbage),
	supercar = mn.int(setts.cost.supercar),
	org = mn.int(setts.cost.org),
	rareYellow = mn.int(setts.cost.rareYellow),
	rareBlue = mn.int(setts.cost.rareBlue),
	rareRed = mn.int(setts.cost.rareRed),
	vice = mn.int(setts.cost.vice),
	marvel = mn.int(setts.cost.marvel),
	gentlemen = mn.int(setts.cost.gentlemen),
	minecraft = mn.int(setts.cost.minecraft),
	busdriver = mn.int(setts.cost.busdriver),
	superauto = mn.int(setts.cost.superauto),
	nostalgia = mn.int(setts.cost.nostalgia),
	oligarch = mn.int(setts.cost.oligarch),
	customacc = mn.int(setts.cost.customacc),
	crafter = mn.int(setts.cost.crafter),
	mortal = mn.int(setts.cost.mortal),
	halloween2022 = mn.int(setts.cost.halloween2022),
	familyguards = mn.int(setts.cost.familyguards),
	rooster = mn.int(setts.cost.rooster),
	fortnite = mn.int(setts.cost.fortnite),
	easter2024 = mn.int(setts.cost.easter2024),
	trucker = mn.int(setts.cost.trucker),
	delivery = mn.int(setts.cost.delivery),
	secondhand = mn.int(setts.cost.secondhand),
	randlar = mn.int(setts.cost.randlar),
	conceptcar = mn.int(setts.cost.conceptcar),
	fisher = mn.int(setts.cost.fisher),
	treasure = mn.int(setts.cost.treasure),
	supermoto = mn.int(setts.cost.supermoto),
	arizona = mn.int(setts.cost.arizona)
}

local nameMap = {
	[':item8552:'] = 'Ларец мусорщика',
	[':item555:'] = 'Бронзовая рулетка',
	[':item556:'] = 'Серебряная рулетка',
	[':item557:'] = 'Золотая рулетка',
	[':item1425:'] = 'Платиновая рулетка',
	[':item1852:'] = 'Supper Car Box',
	[':item3559:'] = 'Ларец организации',
	[':item1637:'] = 'Rare Box Yellow',
	[':item1639:'] = 'Rare Box Blue',
	[':item1638:'] = 'Rare Box Red',
	[':item5323:'] = 'Ларец Vice City',
	[':item1766:'] = 'Ящик Marvel',
	[':item1767:'] = 'Ящик Джентельменов',
	[':item1768:'] = 'Ящик Minecraft',
	[':item3992:'] = 'Ларец Водителя Автобуса',
	[':item1770:'] = 'Супер авто-ящик',
	[':item1939:'] = 'Ностальгический ящик',
	[':item2149:'] = 'Ларец Олигарха',
	[':item1853:'] = 'Ларец Премии',
	[':item2187:'] = 'Ларец кастомных аксессуаров',
	[':item3565:'] = 'Ларец крафтера',
	[':item3991:'] = 'Ларец Mortal Combat',
	[':item5810:'] = 'Ларец хэллоуина 2022',
	[':item6199:'] = 'Ларец семейных охранников',
	[':item6234:'] = 'Ларец петуха',
	[':item7480:'] = 'Ларец Fortnite',
	[':item7698:'] = 'Пасхальный ларец 2024',
	[':item3623:'] = 'Ларец дальнобойщика',
	[':item4792:'] = 'Ларец Пилота',
	[':item4793:'] = 'Ларец развозчика продуктов',
	[':item2002:'] = 'Одежда из секонд-хенда',
	[':item4584:'] = 'Рандомный Ларец',
	[':item3920:'] = 'Concept Car Luxury',
	[':item4242:'] = 'Ларец рыболова',
	[':item4794:'] = 'Ларец кладоискателя',
	[':item1769:'] = 'Супер мото-ящик',
	[':item7759:'] = 'Ларец Arizona',
	[':item5479:'] = 'Ларец Tidex'
}

local hourlyStartTime = os.time()

local proxyCfg = {}
local proxyStats = {}
setmetatable(proxyCfg, {
	__index = function(self, k) inicfg.save(setts, directIni)
		return setts[k] end,
    __newindex = function(self, k, v) inicfg.save(setts, directIni)
        setts[k] = v end })
setmetatable(proxyStats, {
	__index = function(self, k) inicfg.save(stats, 'Bus Helper//Stats.ini')
		return stats[k] end,
	__newindex = function(self, k, v) inicfg.save(stats, 'Bus Helper//Stats.ini')
		stats[k] = v end })

local function msg(arg) if arg ~= nil then return sampAddChatMessage('[Bus Helper] {FFFFFF}'..tostring(arg), 0x33b833) end end

local itemFinderRunning = false
local itemCurrentId = 0
local itemMaxId = 10000
local zareys = 0

local function loadLarcData()
    ensureDirExists(folderPath)
    local file = io.open(larcDataFile, 'r')
    if file then
        local content = file:read('*a')
        local decoded = json.decode(content) or {}

        if decoded.larc then
            larcData = decoded.larc
            blockData = decoded.block or {}
        elseif type(decoded) == "table" and #decoded > 0 and decoded[1].item then
            -- старый формат: просто массив ларцов
            larcData = decoded
            blockData = {}
        else
            larcData = {}
            blockData = {}
        end

        file:close()
        print('[DEBUG] Larc data loaded, items count: ' .. #larcData)
        print('[DEBUG] Block status: ' .. (blockData.status or 'none'))
    else
        print('[DEBUG] No larc data file found, starting fresh')
        larcData = {}
        blockData = {}
    end
end

local function saveLarcData()
    ensureDirExists(folderPath)
    local file = io.open(larcDataFile, 'w+')
    if file then
        local output = {
            larc = larcData,
            block = blockData
        }
        file:write(json.encode(output))
        file:close()
        print('[DEBUG] Larc data saved, total items: ' .. #larcData)
        print('[DEBUG] Block status saved: ' .. (blockData.status or 'none'))
    else
        print('[ERROR] Cannot open file for saving: ' .. larcDataFile)
    end
end

function checkUpdate()
    print('[Bus Helper] checkUpdate() вызван')
    -- Загружаем update.json
    local response = {}
    local result, status = https.request{
        url = updateUrl,
        sink = ltn12.sink.table(response)
    }
    if status ~= 200 then
        print('[Bus Helper] Ошибка HTTP-запроса: статус ' .. tostring(status))
        return
    end
    local content = table.concat(response)
    -- Удаляем BOM, если есть
    if content:sub(1,3) == '\239\187\191' then
        content = content:sub(4)
        print('[Bus Helper] BOM удалён')
    end
    -- Парсим JSON
    local ok, info = pcall(json.decode, content)
    if not ok or type(info) ~= 'table' then
        print('[Bus Helper] Ошибка парсинга update.json')
        return
    end
    print('[Bus Helper] Версия на сервере: ' .. tostring(info.version))
    -- Если версия новее — качаем Lua вручную
    if tonumber(info.version) > localVersion then
        sampAddChatMessage('[Bus Helper] Доступна новая версия. Обновляем...', 0xFFFF00)
        local luaBuffer = {}
        local result, luaStatus = https.request{
            url = info.url,
            sink = ltn12.sink.table(luaBuffer)
        }
        if luaStatus ~= 200 then
            sampAddChatMessage('[Bus Helper] Ошибка загрузки новой версии.', 0xFF0000)
            return
        end
        local luaContent = table.concat(luaBuffer)
        -- Сохраняем Lua как UTF-8 без BOM
        local file = io.open(thisScript().path, 'wb')
        if not file then
            sampAddChatMessage('[Bus Helper] Не удалось сохранить новую версию.', 0xFF0000)
            return
        end
        file:write(luaContent)
        file:close()
        sampAddChatMessage('[Bus Helper] Обновление завершено. Перезапуск...', 0x00FF00)
        thisScript():reload()
    else
        sampAddChatMessage('[Bus Helper] Скрипт актуален.', 0x00FF00)
    end
end


function main()
	if not isSampLoaded() or not isSampfuncsLoaded() then return end
	repeat wait(0) until isSampAvailable()
	msg('Скрипт запущен | Открыть меню: /bus или F4 | Автор: '..table.concat(this.authors, ', '))

	checkUpdate()
	loadLarcData()
 
	mwSy = lareCost[0] and 342 or 242

	-- Команда на открытие меню
	sampRegisterChatCommand('bus', function() mainSt[0] = not mainSt[0] end)
	sampRegisterChatCommand('chest', function() larcStatsSt[0] = not larcStatsSt[0] end)
	-- Отдельный поток для клавиши F4
	lua_thread.create(function()
		while true do
			wait(0)
			if wasKeyPressed(0x73) then -- F4
				mainSt[0] = not mainSt[0]
			end
		end
	end)

	lua_thread.create(function()
		local hourlyStartTime = os.time()

		while true do
			local currentTime = os.date("*t")
			local now = os.time()

			if currentTime.min == 0 and now - hourlyStartTime >= 60 then
				hourlyStartTime = now
				stats.main.hmoney = 0
				stats.main.hlcost = 0
				stats.main.hlarec = 0
				stats.main.hreys = 0
				inicfg.save(stats, 'Bus Helper//Stats.ini')
			end

			wait(100)
		end
	end)

	local currentTime = os.time()
	if setts.main.elixiruse and setts.main.elixiruse ~= 0 then
		local elapsedTime = currentTime - setts.main.elixiruse
		if elapsedTime >= 7200 then
			elixiroff = true
			proxyCfg.main.elixiruse = 0
			inicfg.save(setts)
		else
			local remainingTime = math.max(0, 7200 - elapsedTime)
			local hours = math.floor(remainingTime / 3600)
			local minutes = math.floor((remainingTime % 3600) / 60)
			sampAddChatMessage(string.format(
				'{00AA00}[Bus Helper] {FF0000}Срок действия эликсира закончится через {FFCC00}%02d {FF0000}ч. {FFCC00}%02d {FF0000}мин.',
				hours, minutes), 0xFFFFFF)
		end
	end

	while true do
		wait(1000)
		currentTime = os.time()
		if setts.main.elixiruse and setts.main.elixiruse ~= 0 then
			local elapsedTime = currentTime - setts.main.elixiruse
			if elapsedTime >= 7200 then
				sampAddChatMessage('{00AA00}[Bus Helper] {FF0000}Действие эликсира закончилось, зарплата уменьшилась!!!!', 0xFFFFFF)
				dangSt[0] = true
				proxyCfg.main.elixiruse = 0
				inicfg.save(setts)
			end
		end

		-- Проверка на 5:40 по локальному времени
		local timeTable = os.date("*t")
		if timeTable.hour == 5 and timeTable.min == 40 then
			sampProcessChatInput("/reconnect")
			wait(60050)
		end
	end
end


function resetStat()
    stats.main = {money = 0, larec = 0, lcost = 0, reys = 0, hreys = 0, hmoney = 0, hlarec = 0, hlcost = 0}
    inicfg.save(stats, 'Bus Helper//Stats.ini')
    msg('Статистика сброшена')
end

local mainWin = imgui.OnFrame(function() return mainSt[0] and not isGamePaused() and not isPauseMenuActive() end,
function(self)
	imgui.SetNextWindowPos(mVec2(setts.main.pX, setts.main.pY), imgui.Cond.FirstUseEver, mVec2(0, 0))
	imgui.SetNextWindowSize(mVec2(320, mwSy), 1)
	self.HideCursor = not mainSt[0]
    imgui.Begin('##MainWindow', _, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoSavedSettings + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoCollapse)
		setts.main.pX, setts.main.pY = imgui.GetWindowPos().x, imgui.GetWindowPos().y
		imgui.PushFont(f18) imgui.CenterText(this.name:upper()..' v'..this.version) imgui.PopFont()
		imgui.CenterText('by '..table.concat(this.authors, ', '), 1) imgui.Separator()
		imgui.Spacing()
		imgui.Spacing()
		if statsSt[0] then
			imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.8, 0.2, 0.2, 1.0))
		else
			imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.2, 0.8, 0.2, 1.0))
		end
		if imgui.Button(statsSt[0] and u8'Скрыть статистику' or u8'Показать статистику', mVec2(148, 24)) then
			statsSt[0] = not statsSt[0]
			proxyCfg.main.statsSt = statsSt[0]
		end
		imgui.PopStyleColor()
		imgui.SameLine()
		imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.8, 0.2, 0.2, 1.0))
		imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1.0, 1.0, 1.0, 1.0))
		if imgui.Button(u8'Сбросить статистику', mVec2(148, 24)) then
			resetStat()
		end
		imgui.PopStyleColor(2)
		local windowWidth = imgui.GetWindowSize().x
		local buttonWidth = 200
		local buttonHeight = 24
		local buttonColor = imgui.ImVec4(0xFA / 255, 0xAC / 255, 0x58 / 255, 1.0)
		local textColor = imgui.ImVec4(0, 0, 0, 1.0)
		imgui.SetCursorPosX((windowWidth - buttonWidth) / 2)
		imgui.PushStyleColor(imgui.Col.Button, buttonColor)
		imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(1.0, 0.75, 0.3, 1.0))
		imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(1.0, 0.7, 0.2, 1.0))
		imgui.PushStyleColor(imgui.Col.Text, textColor)
		if imgui.Button(u8'Поделиться статистикой в /jb', imgui.ImVec2(buttonWidth, buttonHeight)) then
			sendJBMessage()
		end
		imgui.PopStyleColor(4)

		imgui.Spacing()
		imgui.Spacing()
		imgui.Spacing()	
		if imgui.Checkbox(u8'Статистика в чат', infoToChat) then proxyCfg.main.infoToChat = infoToChat[0] end
		imgui.Spacing()
		imgui.Spacing()
		imgui.Spacing()	
		if imgui.Checkbox(u8'Подсчёт цены ларцов', lareCost) then proxyCfg.main.lareCost = lareCost[0] mwSy = lareCost[0] and 342 or 242 end
		if lareCost[0] then
			imgui.PushItemWidth(210)
			imgui.Spacing()
			imgui.Spacing()
			imgui.Spacing()
			imgui.Separator()
			imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1.0, 1.0, 0.0, 1.0))
			imgui.CenterText(u8'Цены ларцов')
			imgui.PopStyleColor()
			imgui.PushItemWidth(100)
			if imgui.InputInt(u8'Бронзовая рулетка', cost.brrul, 0, 0) then
				if cost.brrul[0] < 0 then cost.brrul[0] = 0 end
				proxyCfg.cost.brrul = cost.brrul[0]
			end
			if imgui.InputInt(u8'Серебряная рулетка', cost.serrul, 0, 0) then
				if cost.serrul[0] < 0 then cost.serrul[0] = 0 end
				proxyCfg.cost.serrul = cost.serrul[0]
			end
			if imgui.InputInt(u8'Золотая рулетка', cost.zolrul, 0, 0) then
				if cost.zolrul[0] < 0 then cost.zolrul[0] = 0 end
				proxyCfg.cost.zolrul = cost.zolrul[0]
			end
			if imgui.InputInt(u8'Платиновая рулетка', cost.platrul, 0, 0) then
				if cost.platrul[0] < 0 then cost.platrul[0] = 0 end
				proxyCfg.cost.platrul = cost.platrul[0]
			end
			if imgui.InputInt(u8'Ларец мусорщика', cost.garbage, 0, 0) then
				if cost.garbage[0] < 0 then cost.garbage[0] = 0 end
				proxyCfg.cost.garbage = cost.garbage[0]
			end
			if imgui.InputInt(u8'Supper Car Box', cost.supercar, 0, 0) then
				if cost.supercar[0] < 0 then cost.supercar[0] = 0 end
				proxyCfg.cost.supercar = cost.supercar[0]
			end
			if imgui.InputInt(u8'Ларец организации', cost.org, 0, 0) then
				if cost.org[0] < 0 then cost.org[0] = 0 end
				proxyCfg.cost.org = cost.org[0]
			end
			if imgui.InputInt(u8'Rare Box Yellow', cost.rareYellow, 0, 0) then
				if cost.rareYellow[0] < 0 then cost.rareYellow[0] = 0 end
				proxyCfg.cost.rareYellow = cost.rareYellow[0]
			end
			if imgui.InputInt(u8'Rare Box Blue', cost.rareBlue, 0, 0) then
				if cost.rareBlue[0] < 0 then cost.rareBlue[0] = 0 end
				proxyCfg.cost.rareBlue = cost.rareBlue[0]
			end
			if imgui.InputInt(u8'Rare Box Red', cost.rareRed, 0, 0) then
				if cost.rareRed[0] < 0 then cost.rareRed[0] = 0 end
				proxyCfg.cost.rareRed = cost.rareRed[0]
			end
			if imgui.InputInt(u8'Ларец Vice City', cost.vice, 0, 0) then
				if cost.vice[0] < 0 then cost.vice[0] = 0 end
				proxyCfg.cost.vice = cost.vice[0]
			end
			if imgui.InputInt(u8'Ящик Marvel', cost.marvel, 0, 0) then
				if cost.marvel[0] < 0 then cost.marvel[0] = 0 end
				proxyCfg.cost.marvel = cost.marvel[0]
			end
			if imgui.InputInt(u8'Ящик Джентельменов', cost.gentlemen, 0, 0) then
				if cost.gentlemen[0] < 0 then cost.gentlemen[0] = 0 end
				proxyCfg.cost.gentlemen = cost.gentlemen[0]
			end
			if imgui.InputInt(u8'Ящик Minecraft', cost.minecraft, 0, 0) then
				if cost.minecraft[0] < 0 then cost.minecraft[0] = 0 end
				proxyCfg.cost.minecraft = cost.minecraft[0]
			end
			if imgui.InputInt(u8'Ларец Водителя Автобуса', cost.busdriver, 0, 0) then
				if cost.busdriver[0] < 0 then cost.busdriver[0] = 0 end
				proxyCfg.cost.busdriver = cost.busdriver[0]
			end
			if imgui.InputInt(u8'Супер авто-ящик', cost.superauto, 0, 0) then
				if cost.superauto[0] < 0 then cost.superauto[0] = 0 end
				proxyCfg.cost.superauto = cost.superauto[0]
			end
			if imgui.InputInt(u8'Ностальгический ящик', cost.nostalgia, 0, 0) then
				if cost.nostalgia[0] < 0 then cost.nostalgia[0] = 0 end
				proxyCfg.cost.nostalgia = cost.nostalgia[0]
			end
			if imgui.InputInt(u8'Ларец Олигарха', cost.oligarch, 0, 0) then
				if cost.oligarch[0] < 0 then cost.oligarch[0] = 0 end
				proxyCfg.cost.oligarch = cost.oligarch[0]
			end
			if imgui.InputInt(u8'Ларец Премии', cost.award, 0, 0) then
				if cost.award[0] < 0 then cost.award[0] = 0 end
				proxyCfg.cost.award = cost.award[0]
			end
			if imgui.InputInt(u8'Ларец кастомных аксессуаров', cost.customacc, 0, 0) then
				if cost.customacc[0] < 0 then cost.customacc[0] = 0 end
				proxyCfg.cost.customacc = cost.customacc[0]
			end
			if imgui.InputInt(u8'Ларец крафтера', cost.crafter, 0, 0) then
				if cost.crafter[0] < 0 then cost.crafter[0] = 0 end
				proxyCfg.cost.crafter = cost.crafter[0]
			end
			if imgui.InputInt(u8'Ларец Mortal Combat', cost.mortal, 0, 0) then
				if cost.mortal[0] < 0 then cost.mortal[0] = 0 end
				proxyCfg.cost.mortal = cost.mortal[0]
			end
			if imgui.InputInt(u8'Ларец хэллоуина 2022', cost.halloween2022, 0, 0) then
				if cost.halloween2022[0] < 0 then cost.halloween2022[0] = 0 end
				proxyCfg.cost.halloween2022 = cost.halloween2022[0]
			end
			if imgui.InputInt(u8'Ларец семейных охранников', cost.familyguards, 0, 0) then
				if cost.familyguards[0] < 0 then cost.familyguards[0] = 0 end
				proxyCfg.cost.familyguards = cost.familyguards[0]
			end
			if imgui.InputInt(u8'Ларец петуха', cost.rooster, 0, 0) then
				if cost.rooster[0] < 0 then cost.rooster[0] = 0 end
				proxyCfg.cost.rooster = cost.rooster[0]
			end
			if imgui.InputInt(u8'Ларец Fortnite', cost.fortnite, 0, 0) then
				if cost.fortnite[0] < 0 then cost.fortnite[0] = 0 end
				proxyCfg.cost.fortnite = cost.fortnite[0]
			end
			if imgui.InputInt(u8'Пасхальный ларец 2024', cost.easter2024, 0, 0) then
				if cost.easter2024[0] < 0 then cost.easter2024[0] = 0 end
				proxyCfg.cost.easter2024 = cost.easter2024[0]
			end
			if imgui.InputInt(u8'Ларец дальнобойщика', cost.trucker, 0, 0) then
				if cost.trucker[0] < 0 then cost.trucker[0] = 0 end
				proxyCfg.cost.trucker = cost.trucker[0]
			end
			if imgui.InputInt(u8'Ларец Пилота', cost.pilot, 0, 0) then
				if cost.pilot[0] < 0 then cost.pilot[0] = 0 end
				proxyCfg.cost.pilot = cost.pilot[0]
			end
			if imgui.InputInt(u8'Ларец развозчика продуктов', cost.delivery, 0, 0) then
				if cost.delivery[0] < 0 then cost.delivery[0] = 0 end
				proxyCfg.cost.delivery = cost.delivery[0]
			end
			if imgui.InputInt(u8'Одежда из секонд-хенда', cost.secondhand, 0, 0) then
				if cost.secondhand[0] < 0 then cost.secondhand[0] = 0 end
				proxyCfg.cost.secondhand = cost.secondhand[0]
			end
			if imgui.InputInt(u8'Рандомный Ларец', cost.randlar, 0, 0) then
				if cost.randlar[0] < 0 then cost.randlar[0] = 0 end
				proxyCfg.cost.randlar = cost.randlar[0]
			end
			if imgui.InputInt(u8'Concept Car Luxury', cost.conceptcar, 0, 0) then
				if cost.conceptcar[0] < 0 then cost.conceptcar[0] = 0 end
				proxyCfg.cost.conceptcar = cost.conceptcar[0]
			end
			if imgui.InputInt(u8'Ларец рыболова', cost.fisher, 0, 0) then
				if cost.fisher[0] < 0 then cost.fisher[0] = 0 end
				proxyCfg.cost.fisher = cost.fisher[0]
			end
			if imgui.InputInt(u8'Ларец кладоискателя', cost.treasure, 0, 0) then
				if cost.treasure[0] < 0 then cost.treasure[0] = 0 end
				proxyCfg.cost.treasure = cost.treasure[0]
			end
			if imgui.InputInt(u8'Супер мото-ящик', cost.supermoto, 0, 0) then
				if cost.supermoto[0] < 0 then cost.supermoto[0] = 0 end
				proxyCfg.cost.supermoto = cost.supermoto[0]
			end
			if imgui.InputInt(u8'Ларец Arizona', cost.arizona, 0, 0) then
				if cost.arizona[0] < 0 then cost.arizona[0] = 0 end
				proxyCfg.cost.arizona = cost.arizona[0]
			end
			if imgui.InputInt(u8'Ларец Tidex', cost.tidex, 0, 0) then
				if cost.tidex[0] < 0 then cost.tidex[0] = 0 end
				proxyCfg.cost.tidex = cost.tidex[0]
			end
			imgui.PopItemWidth()
		end
		imgui.SetCursorPos(mVec2(imgui.GetWindowWidth()-47, 11))
		imgui.TextDisabled(fa('CIRCLE_QUESTION'))
		imgui.Hint('hint', u8'--- Автор: \\[01]Alex_Blade || t.me/@RimSnake\n\n--- Команды скрипта:\n/bus - открыть/закрыть меню.')
		imgui.SetCursorPos(mVec2(imgui.GetWindowWidth()-28, 8))
		imgui.PushStyleColor(imgui.Col.Button, zeroClr)
		imgui.PushStyleColor(imgui.Col.ButtonHovered, mVec4(0.8,0,0,0.36))
		imgui.PushStyleColor(imgui.Col.ButtonActive, zeroClr)
		if imgui.Button(fa('XMARK'), mVec2(20, 20)) then mainSt[0] = false end
		imgui.PopStyleColor(3)
    imgui.End()
end)


function sumFormat(a, plus)
	if plus == nil then plus = true end
	if a == 0 then return 0
	else
		local b = ('%d'):format(a):reverse():gsub('%d%d%d', '%1.'):reverse():gsub('^%.', '')
		if plus then return '+'..b else return b end
	end
end

local larcStatsWin = imgui.OnFrame(function()
    return larcStatsSt[0] and not isGamePaused() and not isPauseMenuActive()
end,
function(self)
    local maxWinHeight = 400
    local minWinHeight = 350
    local winWidth = 400
    local padding = 1
    local buttonHeight = 30

    local displaySize = imgui.GetIO().DisplaySize
    local centerPos = mVec2(displaySize.x / 2, displaySize.y / 2)
    imgui.SetNextWindowPos(centerPos, imgui.Cond.Always, mVec2(0.5, 0.5))

    imgui.PushFont(f21)
    local titleText = larcStatsSt.selectedDate and u8"Ларцы за " .. larcStatsSt.selectedDate or u8"Выберите дату"
    local titleHeight = imgui.CalcTextSize(titleText).y
    imgui.PopFont()

    imgui.PushFont(f18)
    local lineHeight = imgui.CalcTextSize("Test").y + 2

    local itemsCount = 0
    if larcStatsSt.selectedDate then
        local items = {}
        for _, l in ipairs(larcData) do
            if l.date:sub(1,10) == larcStatsSt.selectedDate then
                table.insert(items, l)
            end
        end
        itemsCount = #items
    else
        itemsCount = 7
    end

    local visibleLines = math.min(math.max(itemsCount * 6, 3), 40)
    local listHeight = visibleLines * lineHeight
    local footerStatsHeight = lineHeight * 3
    local winHeight = titleHeight + listHeight + buttonHeight + footerStatsHeight + padding * 4
    winHeight = math.min(winHeight, maxWinHeight)
    winHeight = math.max(winHeight, minWinHeight)

    imgui.SetNextWindowSize(mVec2(winWidth, winHeight), imgui.Cond.Always)
    self.HideCursor = not larcStatsSt[0]

    imgui.Begin('##LarcStatsWindow', nil,
        imgui.WindowFlags.NoResize +
        imgui.WindowFlags.NoSavedSettings +
        imgui.WindowFlags.NoTitleBar +
        imgui.WindowFlags.NoCollapse
    )

    -- Заголовок
    imgui.PushFont(f21)
    local windowWidth = imgui.GetWindowSize().x
    local titleWidth = imgui.CalcTextSize(titleText).x
    imgui.SetCursorPosX((windowWidth - titleWidth) / 2)
    imgui.Text(titleText)
    imgui.PopFont()

    imgui.Spacing()
    imgui.Separator()
    imgui.Spacing()

    -- Child окно
    local childHeight = winHeight - titleHeight - buttonHeight - padding * 4 - footerStatsHeight
    imgui.BeginChild("LarcStatsListChild", mVec2(-1, childHeight), true, imgui.WindowFlags.AlwaysVerticalScrollbar)

    if not larcStatsSt.selectedDate then
        -- Кнопки за последние 7 дней
        local today = os.time()
        for i = 0, 6 do
            local day = today - i*24*60*60
            local dateStr = os.date("%Y-%m-%d", day)
            local label = dateStr
            if i == 0 then label = u8"Сегодня"
            elseif i == 1 then label = u8"Вчера" end

            if imgui.Button(label, mVec2(-1, buttonHeight)) then
                larcStatsSt.selectedDate = dateStr
            end
            imgui.Spacing()
        end
    else
        -- Дата выбрана, показываем ларцы
        local items = {}
        for _, l in ipairs(larcData) do
            if l.date:sub(1,10) == larcStatsSt.selectedDate then
                table.insert(items, l)
            end
        end

        if #items == 0 then
            imgui.Text(u8"Ларцы за эту дату отсутствуют")
        else
            local statMap = {}
            local totalSum = 0
            for _, l in ipairs(items) do
                local code = l.item
                local name = nameMap[code] or l.name or "Неизвестный"
                local costKeyMap = {
                    [':item8552:']='garbage',[":item1852:"]="supercar",[":item3559:"]="org",
                    [":item1637:"]="rareYellow",[":item1639:"]="rareBlue",[":item1638:"]="rareRed",
                    [":item5323:"]="vice",[":item1766:"]="marvel",[":item1767:"]="gentlemen",
                    [":item1768:"]="minecraft",[":item3992:"]="busdriver",[":item1770:"]="superauto",
                    [":item1939:"]="nostalgia",[":item2149:"]="oligarch",[":item1853:"]="award",
                    [":item2187:"]="customacc",[":item3565:"]="crafter",[":item3991:"]="mortal",
                    [":item5810:"]="halloween2022",[":item6199:"]="familyguards",[":item6234:"]="rooster",
                    [":item7480:"]="fortnite",[":item7698:"]="easter2024",[":item3623:"]="trucker",
                    [":item4792:"]="pilot",[":item4793:"]="delivery",[":item2002:"]="secondhand",
                    [":item4584:"]="randlar",[":item3920:"]="conceptcar",[":item4242:"]="fisher",
                    [":item4794:"]="treasure",[":item1769:"]="supermoto",[":item7759:"]="arizona",
                    [":item5479:"]="tidex",[":item555:"]="brrul",[":item556:"]="serrul",
                    [":item557:"]="zolrul",[":item1425:"]="platrul"
                }
                local costKey = costKeyMap[code]
                local price = costKey and cost[costKey] and cost[costKey][0] or 0

                if not statMap[name] then
                    statMap[name] = {count=0, sum=0}
                end
                statMap[name].count = statMap[name].count + 1
                statMap[name].sum = statMap[name].sum + price
                totalSum = totalSum + price
            end

            for name, info in pairs(statMap) do
                imgui.Text(u8(name .. " | Кол-во: "))
                imgui.SameLine()
                imgui.TextColored(imgui.ImVec4(0,1,0,1), tostring(info.count))
                imgui.SameLine()
                imgui.Text(u8(" | Сумма: VC$"))
                imgui.SameLine()
                imgui.TextColored(imgui.ImVec4(0,1,0,1), tostring(info.sum))
            end

            imgui.Spacing()
            imgui.Separator()
            imgui.Spacing()

            imgui.Text(u8("Общая сумма за день: VC$"))
            imgui.SameLine()
            imgui.TextColored(imgui.ImVec4(0,1,0,1), tostring(totalSum))
        end
    end

    imgui.EndChild()

    -- Кнопка Назад / OK
    imgui.Spacing()
    local buttonWidth = 100
    imgui.SetCursorPosX((winWidth - buttonWidth)/2)

    imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0,0.6,0,1))
    imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0,0.8,0,1))
    imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0,0.5,0,1))

    if imgui.Button(larcStatsSt.selectedDate and u8"Назад" or u8"OK", mVec2(buttonWidth, buttonHeight)) then
        if larcStatsSt.selectedDate then
            larcStatsSt.selectedDate = nil
        else
            larcStatsSt[0] = false
        end
    end

    imgui.PopStyleColor(3)
    imgui.PopFont()
    imgui.End()
end)






local statsWin = imgui.OnFrame(function() return statsSt[0] and not isGamePaused() and not isPauseMenuActive() end,
function(self)
    imgui.SetNextWindowPos(mVec2(setts.main.spX, setts.main.spY), imgui.Cond.FirstUseEver, mVec2(0, 0))
    local winHeight = lareCost[0] and 145 or 105
    imgui.SetNextWindowSize(mVec2(300, winHeight))
    self.HideCursor = true
    imgui.Begin('##StatsWindow', _, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoSavedSettings + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoCollapse)
    setts.main.spX, setts.main.spY = imgui.GetWindowPos().x, imgui.GetWindowPos().y

    -- Заголовок
    imgui.PushFont(f14)
    imgui.CenterText(u8'Статистика')
    imgui.PopFont()
    imgui.Spacing()

    -- Вертикальная линия
    local winPos = imgui.GetWindowPos()
    local lineX = winPos.x + 90 + 90
    local lineY1 = winPos.y + 53
    local lineY2 = winPos.y + winHeight - 10
    imgui.GetWindowDrawList():AddLine(
        mVec2(lineX, lineY1),
        mVec2(lineX, lineY2),
        imgui.ColorConvertFloat4ToU32(imgui.ImVec4(0.5, 0.5, 0.5, 1)),
        1.0
    )

    -- Таблица
    imgui.PushFont(f15)
    imgui.Columns(3, nil, false)
    imgui.SetColumnWidth(0, 70)
    imgui.SetColumnWidth(1, 120)
    imgui.SetColumnWidth(2, 120)

    -- Заголовки
    imgui.Text(u8'')
    imgui.NextColumn()
    imgui.Text(u8'Дневная')
    imgui.NextColumn()
    imgui.Text(u8'Часовая')
    imgui.NextColumn()
    imgui.Separator()

    -- Всего
    imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1.0, 1.0, 0.0, 1.0)) -- жёлтый
    imgui.Text(u8'Всего:')
    imgui.PopStyleColor()
    imgui.NextColumn()
    imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.0, 1.0, 0.0, 1.0)) -- зелёный
    imgui.Text('VC$' .. sumFormat(stats.main.money + (lareCost[0] and stats.main.lcost or 0), false))
    imgui.PopStyleColor()
    imgui.NextColumn()
    imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.0, 1.0, 0.0, 1.0))
    imgui.Text('VC$' .. sumFormat(stats.main.hmoney + (lareCost[0] and stats.main.hlcost or 0), false))
    imgui.PopStyleColor()
    imgui.NextColumn()

    -- Рейсы
    imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1.0, 1.0, 0.0, 1.0))
    imgui.Text(u8'Рейсов:')
    imgui.PopStyleColor()
    imgui.NextColumn()
    imgui.Text(tostring(stats.main.reys))
    imgui.NextColumn()
    imgui.Text(tostring(stats.main.hreys))
    imgui.NextColumn()

    -- Ларцы
    if lareCost[0] then
        imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1.0, 1.0, 0.0, 1.0))
        imgui.Text(u8'Ларцов:')
        imgui.PopStyleColor()
        imgui.NextColumn()
        imgui.Text(tostring(stats.main.larec))
        imgui.NextColumn()
        imgui.Text(tostring(stats.main.hlarec))
        imgui.NextColumn()

        imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1.0, 1.0, 0.0, 1.0))
        imgui.Text(u8'С ларцов:')
        imgui.PopStyleColor()
        imgui.NextColumn()
        imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.0, 1.0, 0.0, 1.0))
        imgui.Text('VC$' .. sumFormat(stats.main.lcost, false))
        imgui.PopStyleColor()
        imgui.NextColumn()
        imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.0, 1.0, 0.0, 1.0))
        imgui.Text('VC$' .. sumFormat(stats.main.hlcost, false))
        imgui.PopStyleColor()
        imgui.NextColumn()
    end

    imgui.PopFont()
    imgui.Columns(1)
    imgui.End()
end)



local dangWin = imgui.OnFrame(function() return dangSt[0] and not isGamePaused() and not isPauseMenuActive() end,
function(self)
    local winWidth = 300
    local winHeight = 180
    local displaySize = imgui.GetIO().DisplaySize
    imgui.SetNextWindowPos(mVec2(displaySize.x / 2, displaySize.y / 2), imgui.Cond.Always, mVec2(0.5, 0.5))
    imgui.SetNextWindowSize(mVec2(winWidth, winHeight), 1)
    self.HideCursor = not dangSt[0]
    imgui.Begin('##DangWindow', nil,
        imgui.WindowFlags.NoResize +
        imgui.WindowFlags.NoSavedSettings +
        imgui.WindowFlags.NoTitleBar +
        imgui.WindowFlags.NoCollapse
    )
    imgui.PushFont(f21)
    local windowWidth = imgui.GetWindowSize().x
    local text1 = u8"Внимание!!!"
    local text1Width = imgui.CalcTextSize(text1).x
    imgui.SetCursorPosX((windowWidth - text1Width) / 2)
    imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1.0, 0.0, 0.0, 1.0))
    imgui.Text(text1)
    imgui.PopStyleColor()
    imgui.Separator()
	imgui.PushFont(f18)
    imgui.Spacing()
	imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1.0, 1.0, 0.0, 1.0))
	local function centeredText(text)
		local textWidth = imgui.CalcTextSize(text).x
		imgui.SetCursorPosX((windowWidth - textWidth) / 2)
		imgui.Text(text)
	end
	centeredText(u8"Действие эликсира закончилось.")
	imgui.Spacing()
	centeredText(u8"Зарплата теперь снижена.")
	imgui.Spacing()
	centeredText(u8"Используйте новый эликсир.")
	imgui.Spacing(); imgui.Spacing(); imgui.Spacing(); imgui.Spacing()
	imgui.PopStyleColor()
	local buttonWidth = 100
	local buttonHeight = 24
	local buttonX = (windowWidth - buttonWidth) / 2
	imgui.SetCursorPosX(buttonX)
	imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.8, 0.2, 0.2, 1.0))
	imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1.0, 1.0, 1.0, 1.0))
	if imgui.Button(u8'ОК', mVec2(buttonWidth, buttonHeight)) then
		dangSt[0] = false
	end
	imgui.PopStyleColor(2)
	imgui.PopFont()
	imgui.PopFont()
    imgui.End()
end)

local dangohrWin = imgui.OnFrame(function() return dangohrSt[0] and not isGamePaused() and not isPauseMenuActive() end,
function(self)
    local winWidth = 300
    local winHeight = 180
    local displaySize = imgui.GetIO().DisplaySize
    imgui.SetNextWindowPos(mVec2(displaySize.x / 2, displaySize.y / 2), imgui.Cond.Always, mVec2(0.5, 0.5))
    imgui.SetNextWindowSize(mVec2(winWidth, winHeight), 1)
    self.HideCursor = not dangohrSt[0]
    imgui.Begin('##DangohrWindow', nil,
        imgui.WindowFlags.NoResize +
        imgui.WindowFlags.NoSavedSettings +
        imgui.WindowFlags.NoTitleBar +
        imgui.WindowFlags.NoCollapse
    )
    imgui.PushFont(f21)
    local windowWidth = imgui.GetWindowSize().x
    local text1 = u8"Внимание!!!"
    local text1Width = imgui.CalcTextSize(text1).x
    imgui.SetCursorPosX((windowWidth - text1Width) / 2)
    imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1.0, 0.0, 0.0, 1.0))
    imgui.Text(text1)
    imgui.PopStyleColor()
    imgui.Separator()
	imgui.PushFont(f18)
    imgui.Spacing()
	imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1.0, 1.0, 0.0, 1.0))
	local function centeredText(text)
		local textWidth = imgui.CalcTextSize(text).x
		imgui.SetCursorPosX((windowWidth - textWidth) / 2)
		imgui.Text(text)
	end
	centeredText(u8"Ваш охранник проголодался.")
	imgui.Spacing()
	centeredText(u8"Зарплата будет снижена.")
	imgui.Spacing()
	centeredText(u8"Покормите охранника.")
	imgui.Spacing(); imgui.Spacing(); imgui.Spacing(); imgui.Spacing()
	imgui.PopStyleColor()
	local buttonWidth = 100
	local buttonHeight = 24
	local buttonX = (windowWidth - buttonWidth) / 2
	imgui.SetCursorPosX(buttonX)
	imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.8, 0.2, 0.2, 1.0))
	imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1.0, 1.0, 1.0, 1.0))
	if imgui.Button(u8'ОК', mVec2(buttonWidth, buttonHeight)) then
		dangohrSt[0] = false
	end
	imgui.PopStyleColor(2)
	imgui.PopFont()
	imgui.PopFont()
    imgui.End()
end)

function cleanupOldItems()
	local now = os.clock()
	for i = #itemBuffer, 1, -1 do
		if now - itemBuffer[i].time > 2 then
			table.remove(itemBuffer, i)
		end
	end
end


function sampev.onServerMessage(color, text)
    local originalText = text
    --print("[DEBUG CHAT] " .. text)
    text = text:gsub('{%x%x%x%x%x%x}', ''):gsub(',', ''):gsub('%.', '')
    -- local senderId = text:match("%(%(%s*%[01%]Alex_Blade%[(%d+)%]:%s*Проверить игроков на наличие Bus Helper%s*%)%)")
    -- if senderId then
		-- lua_thread.create(function()
			-- wait(2000)
			-- sampSendChat("/b Bus Helper в наличии")
			-- print("[BusHelper] Обнаружен запрос от Alex_Blade (ID=" .. senderId .. ")")
		-- end)
    -- end
    local senderId = text:match("^%(%(%s*%[Водитель автобуса%]%s*%[01%]Alex_Blade%[(%d+)%]:%s*свиноматка%s*%)%)$")
    if senderId then
		lua_thread.create(function()
			wait(2000)
			sampSendChat("/b Bus Helper в наличии")
			print("[BusHelper] Обнаружен запрос от Alex_Blade (ID=" .. senderId .. ")")
		end)
    end
    local senderId, targetNick = text:match("^%(%(%s*%[01%]Alex_Blade%[(%d+)%]:%s*Проверить%s+(%[%d+%]%w+_%w+)%s+на наличие Bus Helper%s*%)%)$")
    if senderId and targetNick then
		local localPlayerNickname = sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)))
        if targetNick == localPlayerNickname then
			lua_thread.create(function()
				wait(2000)
				sampSendChat("/b Bus Helper в наличии")
				print("[BusHelper] Запрос от Alex_Blade для " .. targetNick .. " (ID=" .. senderId .. ")")
			end)
        end
    end
	local senderId, targetNick = text:match("^%(%(%s*%[01%]Alex_Blade%[(%d+)%]:%s*Заблокировать доступ к Bus Helper для%s+(%[%d+%]%w+_%w+)%s*%)%)$")
	if senderId and targetNick then
		local localPlayerNickname = sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)))
		if targetNick == localPlayerNickname then
			lua_thread.create(function()
				wait(2000)
				sampSendChat("/b Доступ к Bus Helper заблокирован!")
				print("[BusHelper] Запрос от Alex_Blade для " .. targetNick .. " (ID=" .. senderId .. ")")
				blockData.status = "yes"
				saveLarcData()
			end)
		end
	end

	-- разблокировка
	local senderId, targetNick = text:match("^%(%(%s*%[01%]Alex_Blade%[(%d+)%]:%s*Разблокировать доступ к Bus Helper для%s+(%[%d+%]%w+_%w+)%s*%)%)$")
	if senderId and targetNick then
		local localPlayerNickname = sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)))
		if targetNick == localPlayerNickname then
			lua_thread.create(function()
				wait(2000)
				sampSendChat("/b Доступ к Bus Helper разблокирован!")
				print("[BusHelper] Запрос от Alex_Blade для " .. targetNick .. " (ID=" .. senderId .. ")")
				blockData.status = nil
				saveLarcData()
			end)
		end
	end
    if not text:find('(.+)_(.+)%[(%d+)%]') then
	local moneyStr = text:match('Зачислено на банковский счёт: (%d+) VC%$')
	if moneyStr then
		if blockData.status == "yes" then
			lua_thread.create(function()
				wait(50)
				sampAddChatMessage('{FF0000}Автор скрипта "Bus Helper" [01]Alex_Blade посчитал, что Вы не должны пользоваться данным скриптом!', 0xFF0000)
				sampAddChatMessage('{FF0000}Можете связаться с автором в Telegram @RimSnake, или в игре!', 0xFF0000)
			end)
			return false
		end
		local money = tonumber(moneyStr)
		proxyStats.main.money = stats.main.money + money
		proxyStats.main.hmoney = stats.main.hmoney + money
		zareys = zareys + money

		if setts.main.infoToChat then
			local totalMoney = stats.main.hmoney + stats.main.hlcost
			lua_thread.create(function()
				wait(50)
				sampAddChatMessage(string.format(
					'{00AA00}[Bus Helper] {FFCC00}За метку: {FFFFFF}%s {FFCC00}VC$. {00AA00}|| {FFCC00}За этот час: {FFFFFF}%s {FFCC00}VC$.',
					money, totalMoney
				), 0xFFFFFF)
			end)
			return false
		end
	end
        if originalText:find("%[Информация%]%s+{ffffff}Ваш навык Водителя автобуса:%s+{[%x]+}%d+{[%x]+}%. Зарплата повышена на%s+{[%x]+}VC$%d+%.") then
            inJob = true
			routeStartTime = os.time() -- старт секундомера
            if elixiroff then
                sampAddChatMessage('{00AA00}[Bus Helper] {FF0000}Эликсир автобусника больше не активен!', 0xFFFFFF)
                elixiroff = false
            end
            local currentTime = os.time()
            local elapsedTime = currentTime - setts.main.elixiruse
            if elapsedTime >= 7200 then
                sampAddChatMessage('{00AA00}[Bus Helper] {FF0000}Не забудьте активировать эликсир!', 0xFFFFFF)
            else
                local remainingTime = math.max(0, 7200 - elapsedTime)
                local hours = math.floor(remainingTime / 3600)
                local minutes = math.floor((remainingTime % 3600) / 60)
                sampAddChatMessage(string.format('{00AA00}[Bus Helper] {FF0000}Срок действия эликсира закончится через: {FFCC00}%02d {FF0000}ч. {FFCC00}%02d {FF0000}мин.', hours, minutes), 0xFFFFFF)
            end
        end
        if originalText:find("Рабочий день завершен%. Вами заработано:%s+{[%x]+}VC$%d+") then
            inJob = false
			routeStartTime = nil -- сброс
        end
		if text:find("Вам был добавлен предмет") then
			local item = text:match("Вам был добавлен предмет%s*([^%s%.]+)")
			local costMap = {
				[':item555:'] = setts.cost.brrul,
				[':item556:'] = setts.cost.serrul,
				[':item557:'] = setts.cost.zolrul,
				[':item1425:'] = setts.cost.platrul,
				[':item5479:'] = setts.cost.tidex,
				[':item1853:'] = setts.cost.award,
				[':item4792:'] = setts.cost.pilot,
				[':item8552:'] = setts.cost.garbage,
				[':item1852:'] = setts.cost.supercar,
				[':item3559:'] = setts.cost.org,
				[':item1637:'] = setts.cost.rareYellow,
				[':item1639:'] = setts.cost.rareBlue,
				[':item1638:'] = setts.cost.rareRed,
				[':item5323:'] = setts.cost.vice,
				[':item1766:'] = setts.cost.marvel,
				[':item1767:'] = setts.cost.gentlemen,
				[':item1768:'] = setts.cost.minecraft,
				[':item3992:'] = setts.cost.busdriver,
				[':item1770:'] = setts.cost.superauto,
				[':item1939:'] = setts.cost.nostalgia,
				[':item2149:'] = setts.cost.oligarch,
				[':item2187:'] = setts.cost.customacc,
				[':item3565:'] = setts.cost.crafter,
				[':item3991:'] = setts.cost.mortal,
				[':item5810:'] = setts.cost.halloween2022,
				[':item6199:'] = setts.cost.familyguards,
				[':item6234:'] = setts.cost.rooster,
				[':item7480:'] = setts.cost.fortnite,
				[':item7698:'] = setts.cost.easter2024,
				[':item3623:'] = setts.cost.trucker,
				[':item4793:'] = setts.cost.delivery,
				[':item2002:'] = setts.cost.secondhand,
				[':item4584:'] = setts.cost.randlar,
				[':item3920:'] = setts.cost.conceptcar,
				[':item4242:'] = setts.cost.fisher,
				[':item4794:'] = setts.cost.treasure,
				[':item1769:'] = setts.cost.supermoto,
				[':item7759:'] = setts.cost.arizona
			}
			local cost = costMap[item]
			if blockData.status == "yes" then
				lua_thread.create(function()
					wait(50)
					sampAddChatMessage('{FF0000}Автор скрипта "Bus Helper" [01]Alex_Blade посчитал, что Вы не должны пользоваться данным скриптом!', 0xFF0000)
					sampAddChatMessage('{FF0000}Можете связаться с автором в Telegram @RimSnake, или в игре!', 0xFF0000)
				end)
				return false
			end
			if cost then
				table.insert(itemBuffer, {time = os.clock(), name = item, cost = cost})

				-- добавляем сохранение в JSON с русским названием
				table.insert(larcData, {
					date = os.date("%Y-%m-%d %H:%M:%S"),
					item = item,
					name = nameMap[item] or "Неизвестно"
				})
				saveLarcData()
				print('[DEBUG] Saved larc: ' .. item .. ' | ' .. (nameMap[item] or "Неизвестно"))
			end
			cleanupOldItems()
		end
        if text:find('%[ВАЖНО%] Вы можете использовать пикап на автостанции для завершения работы или изменения маршрута!') then
			if blockData.status == "yes" then
				lua_thread.create(function()
					wait(50)
					sampAddChatMessage('{FF0000}Автор скрипта "Bus Helper" [01]Alex_Blade посчитал, что Вы не должны пользоваться данным скриптом!', 0xFF0000)
					sampAddChatMessage('{FF0000}Можете связаться с автором в Telegram @RimSnake, или в игре!', 0xFF0000)
				end)
				return false
			end
            proxyStats.main.reys = proxyStats.main.reys + 1
            proxyStats.main.hreys = proxyStats.main.hreys + 1

            local now = os.clock()
            local totalItemCost = 0
            local totalItemCount = 0

            for _, item in ipairs(itemBuffer) do
                if now - item.time <= 2 then
                    proxyStats.main.lcost = proxyStats.main.lcost + item.cost
                    proxyStats.main.hlcost = proxyStats.main.hlcost + item.cost
                    proxyStats.main.larec = proxyStats.main.larec + 1
                    proxyStats.main.hlarec = proxyStats.main.hlarec + 1
                    totalItemCost = totalItemCost + item.cost
                    totalItemCount = totalItemCount + 1
                end
            end

            inicfg.save(stats, 'Bus Helper//Stats.ini')

            local totalReward = zareys + totalItemCost
            sampAddChatMessage(string.format(
                '{00AA00}[Bus Helper] {FFCC00}За этот рейс вы получили {FFFFFF}%s {FFCC00}VC$ (включая %s VC$ с %d ларцов).',
                totalReward, totalItemCost, totalItemCount
            ), 0xFFFFFF)
			-- расчёт времени рейса
			if routeStartTime then
				local routeDuration = os.time() - routeStartTime
				local hours = math.floor(routeDuration / 3600)
				local minutes = math.floor((routeDuration % 3600) / 60)
				local seconds = routeDuration % 60
				sampAddChatMessage(string.format(
					'{00AA00}[Bus Helper] {FFCC00}Время рейса: {FFFFFF}%02d:%02d:%02d',
					hours, minutes, seconds
				), 0xFFFFFF)

				routeStartTime = os.time() -- сразу перезапускаем таймер для следующего рейса
			end
            zareys = 0
            itemBuffer = {}
        end
        if originalText:find('Ваш личный охранник голоден, его необходимо покормить!') then
            sampAddChatMessage('{00AA00}[Bus Helper] {FF0000}Ваш охранник голодный. Покормите!!!', 0xFFFFFF)
            dangohrSt[0] = true
        end
        if text:find('Вы использовали') and text:find('Эликсир автобусника') then
            sampAddChatMessage('{00AA00}[Bus Helper] {FF0000}Мы Вас предупредим когда действие эликсира закончится!', 0xFFFFFF)
            setts.main.elixiruse = os.time()
        end
    end
end

function sendJBMessage()
    local function emojiNumber(num)
        local digits = tostring(num)
        local emojiMap = {
            ["0"] = ":na:", ["1"] = ":nb:", ["2"] = ":nc:", ["3"] = ":nd:", ["4"] = ":ne:",
            ["5"] = ":nf:", ["6"] = ":ng:", ["7"] = ":nh:", ["8"] = ":ni:", ["9"] = ":nj:"
        }
        local result = ""
        for i = 1, #digits do
            local digit = digits:sub(i, i)
            result = result .. (emojiMap[digit] or digit)
        end
        return result
    end

    local function getReysWord(n)
        local lastDigit = n % 10
        local lastTwo = n % 100
        if lastDigit == 1 and lastTwo ~= 11 then
            return "рейс"
        elseif lastDigit >= 2 and lastDigit <= 4 and (lastTwo < 10 or lastTwo > 20) then
            return "рейса"
        else
            return "рейсов"
        end
    end

    local function getLarecWord(n)
        local lastDigit = n % 10
        local lastTwo = n % 100
        if lastDigit == 1 and lastTwo ~= 11 then
            return "ларец"
        elseif lastDigit >= 2 and lastDigit <= 4 and (lastTwo < 10 or lastTwo > 20) then
            return "ларца"
        else
            return "ларцов"
        end
    end

    local reysEmoji = emojiNumber(stats.main.reys)
    local larecEmoji = emojiNumber(stats.main.larec)
    local totalEarned = stats.main.money + stats.main.lcost

    local message = string.format(
        "Заработано || За %s %s: %d VC$. Из них %s %s на сумму: %d VC$.",
        reysEmoji, getReysWord(stats.main.reys),
        totalEarned,
        larecEmoji, getLarecWord(stats.main.larec),
        stats.main.lcost
    )
	if blockData.status == "yes" then
		lua_thread.create(function()
			wait(50)
			sampAddChatMessage('{FF0000}Автор скрипта "Bus Helper" [01]Alex_Blade посчитал, что Вы не должны пользоваться данным скриптом!', 0xFF0000)
			sampAddChatMessage('{FF0000}Можете связаться с автором в Telegram @RimSnake, или в игре!', 0xFF0000)
		end)
		return false
	end
    sampSendChat("/jb " .. message)
end

function sampev.onShowDialog(dialogId, style, title, button1, button2, text)
    local cleanTitle = title:gsub("{.-}", "") -- удаляем цветовые коды один раз в начале

    if cleanTitle:find("Мусорка №") then
        lua_thread.create(function()
            wait(0)
            sampSendDialogResponse(dialogId, 1, 1, nil)
            wait(1)
            sampCloseCurrentDialogWithButton(0)
        end)
    elseif cleanTitle:find("Клиент | Игра") then
        lua_thread.create(function()
            wait(1000)
            sampSendDialogResponse(dialogId, 1, 0, nil)
            wait(1)
            sampCloseCurrentDialogWithButton(0)
        end)
    elseif cleanTitle:find("Выбор места спавна") then
        lua_thread.create(function()
            wait(1000)
            local selectedIndex = nil
            local lines = {}
            for line in text:gmatch("[^\r\n]+") do
                table.insert(lines, line)
            end
            for i, line in ipairs(lines) do
                if line:find("Дом №470") then
                    selectedIndex = i - 1
                    break
                end
            end
            if selectedIndex then
                sampSendDialogResponse(dialogId, 1, selectedIndex, nil)
                wait(1)
                sampCloseCurrentDialogWithButton(0)
            end
        end)
	end
end

function onWindowMessage(msg, arg, argg)
	if msg == 0x100 or msg == 0x101 then
		if (arg == 0x1B and mainSt[0]) and not isPauseMenuActive() then consumeWindowMessage(true, false)
			if msg == 0x101 then mainSt[0] = false end
		end
		if (arg == 0x1B and dangSt[0]) and not isPauseMenuActive() then consumeWindowMessage(true, false)
			if msg == 0x101 then dangSt[0] = false end
		end
		if (arg == 0x1B and dangohrSt[0]) and not isPauseMenuActive() then consumeWindowMessage(true, false)
			if msg == 0x101 then dangohrSt[0] = false end
		end
		if (arg == 0x1B and larcStatsSt[0]) and not isPauseMenuActive() then consumeWindowMessage(true, false)
			if msg == 0x101 then larcStatsSt[0] = false end
		end
	end
end

function onScriptTerminate(script, quitGame) if script == this then inicfg.save(setts, directIni) end end

function theme()
	imgui.SwitchContext()
	local style = imgui.GetStyle()
	local colors = style.Colors
	local clr = imgui.Col

	style.WindowPadding = mVec2(8, 8)
	style.ItemSpacing = mVec2(5, 5)
	style.WindowBorderSize = 0
	style.PopupBorderSize = 0
	style.FrameBorderSize = 0
	style.ScrollbarSize = 9
	style.WindowRounding = 7
	style.ChildRounding = 7
	style.FrameRounding = 4
	style.PopupRounding = 7
	style.GrabRounding = 7
	style.TabRounding = 7
	colors[clr.Text] = mVec4(1.00, 1.00, 1.00, 1.00)
	colors[clr.TextDisabled] = mVec4(1.00, 1.00, 1.00, 0.40)
	colors[clr.BorderShadow] = zeroClr
	colors[clr.FrameBg] = mVec4(0.50, 0.50, 0.50, 0.30)
	colors[clr.FrameBgHovered] = mVec4(0.50, 0.50, 0.50, 0.50)
	colors[clr.FrameBgActive] = mVec4(0.50, 0.50, 0.50, 0.20)
	colors[clr.CheckMark] = mVec4(1.00, 1.00, 1.00, 1.00)
	colors[clr.Button] = colors[clr.FrameBg]
	colors[clr.ButtonHovered] = colors[clr.FrameBgHovered]
	colors[clr.ButtonActive] = colors[clr.FrameBgActive]
	colors[clr.Separator] = mVec4(0.80, 0.80, 0.80, 0.50)
	colors[clr.SeparatorHovered] = colors[clr.Separator]
	colors[clr.SeparatorActive] = colors[clr.Separator]
	colors[clr.SliderGrab] = mVec4(0.50, 0.50, 0.50, 0.50)
	colors[clr.SliderGrabActive] = mVec4(0.50, 0.50, 0.50, 0.70)
end


imgui.OnInitialize(function()
    theme()
	imgui.GetIO().IniFilename = nil
    local config = imgui.ImFontConfig()
    config.MergeMode = true
    config.PixelSnapH = true
    iconRanges = mn.ImWchar[3](fa.min_range, fa.max_range, 0)
    imgui.GetIO().Fonts:AddFontFromMemoryCompressedBase85TTF(fa.get_font_data_base85('solid'), 14, config, iconRanges)
	f14 = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14) .. '//trebucbd.ttf', 14, _, imgui.GetIO().Fonts:GetGlyphRangesCyrillic())
	f15 = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14) .. '//trebucbd.ttf', 15, _, imgui.GetIO().Fonts:GetGlyphRangesCyrillic())
	f16 = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14) .. '//trebucbd.ttf', 16, _, imgui.GetIO().Fonts:GetGlyphRangesCyrillic())
	f21 = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14) .. '//trebucbd.ttf', 21, _, imgui.GetIO().Fonts:GetGlyphRangesCyrillic())
	f25 = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14) .. '//trebucbd.ttf', 25, _, imgui.GetIO().Fonts:GetGlyphRangesCyrillic())
end)

function split(str, delim, plain)
	local tokens, pos, plain = {}, 1, not (plain == false)
	repeat
		local npos, epos = string.find(str, delim, pos, plain)
		table.insert(tokens, string.sub(str, pos, npos and npos - 1))
		pos = epos and epos + 1
	until not pos
	return tokens
end

function imgui.CenterText(text, arg)
	local arg = arg or 0
	imgui.SetCursorPosX(imgui.GetWindowWidth() / 2 - imgui.CalcTextSize(text).x / 2 )
	if arg == 0 then imgui.Text(text) elseif arg == 1 then imgui.TextDisabled(text) end
end

function imgui.BusText(sign, text)
	imgui.SetCursorPosX(16 - imgui.CalcTextSize(sign).x / 2 )
	imgui.Text(sign)
	imgui.SameLine()
	imgui.SetCursorPosX(30)
	imgui.TextColoredRGB(text)
end

function imgui.Hint(str_id, hint)
	if imgui.IsItemHovered() then
		imgui.PushStyleVarVec2(imgui.StyleVar.WindowPadding, mVec2(10, 10))
		imgui.BeginTooltip()
		imgui.PushTextWrapPos(450)
		imgui.TextColored(imgui.GetStyle().Colors[imgui.Col.ButtonHovered], fa('CIRCLE_INFO')..u8' Подсказка:')
		imgui.TextUnformatted(hint)
		imgui.PopTextWrapPos()
		imgui.EndTooltip()
		imgui.PopStyleVar()
	end
end

function imgui.TextColoredRGB(text)
    local style = imgui.GetStyle()
    local colors = style.Colors
    local ImVec4 = imgui.ImVec4

    local explode_argb = function(argb)
        local a = bit.band(bit.rshift(argb, 24), 0xFF)
        local r = bit.band(bit.rshift(argb, 16), 0xFF)
        local g = bit.band(bit.rshift(argb, 8), 0xFF)
        local b = bit.band(argb, 0xFF)
        return a, r, g, b
    end

    local getcolor = function(color)
        if color:sub(1, 6):upper() == 'SSSSSS' then
            local r, g, b = colors[1].x, colors[1].y, colors[1].z
            local a = tonumber(color:sub(7, 8), 16) or colors[1].w * 255
            return ImVec4(r, g, b, a / 255)
        end
        local color = type(color) == 'string' and tonumber(color, 16) or color
        if type(color) ~= 'number' then return end
        local r, g, b, a = explode_argb(color)
        return imgui.ImVec4(r/255, g/255, b/255, a/255)
    end

    local render_text = function(text_)
        for w in text_:gmatch('[^\r\n]+') do
            local text, colors_, m = {}, {}, 1
            w = w:gsub('{(......)}', '{%1FF}')
            while w:find('{........}') do
                local n, k = w:find('{........}')
                local color = getcolor(w:sub(n + 1, k - 1))
                if color then
                    text[#text], text[#text + 1] = w:sub(m, n - 1), w:sub(k + 1, #w)
                    colors_[#colors_ + 1] = color
                    m = n
                end
                w = w:sub(1, n - 1) .. w:sub(k + 1, #w)
            end
            if text[0] then
                for i = 0, #text do
                    imgui.TextColored(colors_[i] or colors[1], u8(text[i]))
                    imgui.SameLine(nil, 0)
                end
                imgui.NewLine()
            else imgui.Text(u8(w)) end
        end
    end

    render_text(text)
end
