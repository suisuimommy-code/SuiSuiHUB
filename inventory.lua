if getgenv().SuiSuiLibrary and typeof(getgenv().SuiSuiLibrary.Destroy) == "function" then
	pcall(function() getgenv().SuiSuiLibrary:Destroy(); end);
end

library = {flags={}, items={}, connections={}};
getgenv().SuiSuiLibrary = library;

local function trackConn(conn)
	if conn then
		table.insert(library.connections, conn);
	end
	return conn;
end

library.Destroy = function(self)
	if library.connections then
		for _, conn in ipairs(library.connections) do
			pcall(function()
				if conn and typeof(conn) == "RBXScriptConnection" and conn.Connected then
					conn:Disconnect();
				end
			end);
		end
		table.clear(library.connections);
	end

	if library.cursor and typeof(library.cursor.Remove) == "function" then
		pcall(function() library.cursor:Remove(); end);
		library.cursor = nil;
	end

	if getgenv().watermark then
		pcall(function() getgenv().watermark:Destroy(); end);
		getgenv().watermark = nil;
	end

	if getgenv().uilib then
		pcall(function() getgenv().uilib:Destroy(); end);
		getgenv().uilib = nil;
	end

	local coregui = game:GetService("CoreGui");
	local oldStat = coregui:FindFirstChild("StatBySmell");
	if oldStat then
		pcall(function() oldStat:Destroy(); end);
	end
	local lp = game:GetService("Players").LocalPlayer;
	if lp and lp:FindFirstChild("PlayerGui") then
		local pStat = lp.PlayerGui:FindFirstChild("StatBySmell");
		if pStat then
			pcall(function() pStat:Destroy(); end);
		end
	end

	if library.items then
		for _, item in pairs(library.items) do
			if typeof(item) == "table" and item.Main and typeof(item.Main) == "Instance" then
				pcall(function() item.Main:Destroy(); end);
			end
		end
		table.clear(library.items);
	end
	table.clear(library.flags);
end;
library.theme = {
	fontsize = 14,
	titlesize = 20,
	font = Enum.Font.GothamSemibold,
	background = "rbxassetid://5553946656",
	tilesize = 50,
	cursor = false,
	cursorimg = "https://t0.rbxcdn.com/42f66da98c40252ee151326a82aab51f",
	backgroundcolor = Color3.fromRGB(16, 14, 24),
	tabstextcolor = Color3.fromRGB(216, 180, 254),
	bordercolor = Color3.fromRGB(88, 58, 138),
	accentcolor = Color3.fromRGB(168, 85, 247),
	accentcolor2 = Color3.fromRGB(216, 180, 254),
	outlinecolor = Color3.fromRGB(88, 58, 138),
	outlinecolor2 = Color3.fromRGB(10, 9, 16),
	sectorcolor = Color3.fromRGB(24, 21, 36),
	toptextcolor = Color3.fromRGB(251, 191, 36),
	topheight = 48,
	dpScrollBarThickness = 8,
	topcolor = Color3.fromRGB(28, 24, 44),
	topcolor2 = Color3.fromRGB(16, 14, 26),
	buttoncolor = Color3.fromRGB(38, 33, 58),
	buttoncolor2 = Color3.fromRGB(28, 24, 44),
	itemscolor = Color3.fromRGB(226, 232, 240),
	itemscolor2 = Color3.fromRGB(241, 245, 249)
};
_G.Color = Color3.fromRGB(168, 85, 247);
_G.Color2 = Color3.fromRGB(216, 180, 254);
local players = game:GetService("Players");
local uis = game:GetService("UserInputService");
local runservice = game:GetService("RunService");
local tweenservice = game:GetService("TweenService");
local marketplaceservice = game:GetService("MarketplaceService");
local textservice = game:GetService("TextService");
local coregui = (function()
	if gethui then
		local ok, h = pcall(gethui)
		if ok and h then return h end
	end
	local okCore, cg = pcall(function() return game:GetService("CoreGui") end)
	if okCore and cg then
		local canParent = pcall(function()
			local test = Instance.new("Folder")
			test.Parent = cg
			test:Destroy()
		end)
		if canParent then return cg end
	end
	local lp = game:GetService("Players").LocalPlayer
	if lp then
		local pg = lp:FindFirstChild("PlayerGui")
		if pg then return pg end
	end
	return game:GetService("CoreGui")
end)();
local httpservice = game:GetService("HttpService");
local player = players.LocalPlayer;
local mouse = player:GetMouse();
local camera = game.Workspace.CurrentCamera;
local function RainbowText(text)
	if text and typeof(text) == "Instance" and text:IsA("TextLabel") then
		text.TextColor3 = Color3.fromRGB(251, 191, 36);
	end
end
if (library.theme.cursor and Drawing) then
	local success = pcall(function()
		library.cursor = Drawing.new("Image");
		library.cursor.Data = game:HttpGet(library.theme.cursorimg);
		library.cursor.Size = Vector2.new(64, 64);
		library.cursor.Visible = uis.MouseEnabled;
		library.cursor.Rounding = 0;
		library.cursor.Position = Vector2.new(mouse.X - 32, mouse.Y + 6);
	end);
	if (success and library.cursor) then
		local c_cursor_move = uis.InputChanged:Connect(function(input)
			if uis.MouseEnabled then
				if (input.UserInputType == Enum.UserInputType.MouseMovement) then
					library.cursor.Position = Vector2.new(input.Position.X - 32, input.Position.Y + 7);
				end
			end
		end);
		table.insert(library.connections, c_cursor_move);
		local c_cursor_rs = game:GetService("RunService").RenderStepped:Connect(function()
			uis.OverrideMouseIconBehavior = Enum.OverrideMouseIconBehavior.ForceHide;
			library.cursor.Visible = uis.MouseEnabled and (uis.MouseIconEnabled or game:GetService("GuiService").MenuIsOpen);
		end);
		table.insert(library.connections, c_cursor_rs);
	elseif (not success and library.cursor) then
		library.cursor:Remove();
	end
end
library.ConfigSystem = function(self, name, customGame)
	if isfolder and makefolder then
		if not isfolder("!SuiSuiHUB") then
			pcall(makefolder, "!SuiSuiHUB");
		end
	end

	local detectedGame = customGame or _G.SuiSuiGameName;
	if not detectedGame then
		pcall(function()
			local pid = game.PlaceId;
			if pid == 97617452700163 then
				detectedGame = "Anime Eyes";
			elseif pid == 78312396550517 then
				detectedGame = "Card Origins";
			elseif pid == 6938803436 or pid == 6990129309 or pid == 6990133340 or pid == 6990131029 or pid == 7338881230 or pid == 7274690025 then
				detectedGame = "Anime Dimensions";
			else
				local info = marketplaceservice:GetProductInfo(pid);
				detectedGame = (info and info.Name) or tostring(pid);
			end
		end);
	end
	detectedGame = tostring(detectedGame or "General"):gsub('[\\/:%*%?"<>|]', "");

	local gameFolder = "!SuiSuiHUB/" .. detectedGame;
	if isfolder and makefolder then
		if not isfolder(gameFolder) then
			pcall(makefolder, gameFolder);
		end
	end

	local configSystem = {};
	configSystem.gameFolder = gameFolder;
	configSystem.configFolder = gameFolder;
	local configName = tostring(name or "config");
	local filePath = gameFolder .. "/" .. configName .. ".txt";

	if isfile and writefile then
		if not isfile(filePath) then
			pcall(writefile, filePath, "{}");
		end
	end

	configSystem.Load = function(self)
		if not isfile or not readfile then return end
		local Success, Content = pcall(readfile, filePath);
		if Success and Content and #Content > 1 then
			pcall(function()
				local ReadConfig = httpservice:JSONDecode(Content);
				local NewConfig = {};
				for i, v in pairs(ReadConfig) do
					if (typeof(v) == "table") then
						if (typeof(v[1]) == "number") and #v == 3 then
							NewConfig[i] = Color3.new(v[1], v[2], v[3]);
						elseif (typeof(v[1]) == "table") then
							NewConfig[i] = v[1];
						else
							NewConfig[i] = v;
						end
					elseif (tostring(v):find("Enum.KeyCode.")) then
						NewConfig[i] = Enum.KeyCode[tostring(v):gsub("Enum.KeyCode.", "")];
					else
						NewConfig[i] = v;
					end
				end
				library.flags = NewConfig;
				for i, v in pairs(library.flags) do
					for i2, v2 in pairs(library.items) do
						if (v2.flag and v2.flag == i) then
							pcall(function()
								v2:Set(v);
							end);
						end
					end
				end
			end);
		end
	end;

	configSystem.Save = function(self)
		if not writefile then return end
		local config = {};
		for i, v in pairs(library.flags) do
			if (v ~= nil and v ~= "") then
				if (typeof(v) == "Color3") then
					config[i] = {v.R, v.G, v.B};
				elseif (typeof(v) == "EnumItem" and tostring(v):find("Enum.KeyCode")) then
					config[i] = "Enum.KeyCode." .. v.Name;
				elseif (typeof(v) == "table") then
					config[i] = v;
				else
					config[i] = v;
				end
			end
		end
		pcall(writefile, filePath, httpservice:JSONEncode(config));
	end;

	return configSystem;
end;
local UserInputService = game:GetService("UserInputService");
local function MakeDraggable(topbarobject, object)
	local Dragging = nil;
	local DragInput = nil;
	local DragStart = nil;
	local StartPosition = nil;
	local function Update(input)
		local Delta = input.Position - DragStart;
		local pos = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + Delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + Delta.Y);
		object.Position = pos;
	end
	topbarobject.InputBegan:Connect(function(input)
		if ((input.UserInputType == Enum.UserInputType.MouseButton1) or (input.UserInputType == Enum.UserInputType.Touch)) then
			Dragging = true;
			DragStart = input.Position;
			StartPosition = object.Position;
			input.Changed:Connect(function()
				if (input.UserInputState == Enum.UserInputState.End) then
					Dragging = false;
				end
			end);
		end
	end);
	topbarobject.InputChanged:Connect(function(input)
		if ((input.UserInputType == Enum.UserInputType.MouseMovement) or (input.UserInputType == Enum.UserInputType.Touch)) then
			DragInput = input;
		end
	end);
	UserInputService.InputChanged:Connect(function(input)
		if ((input == DragInput) and Dragging) then
			Update(input);
		end
	end);
end
library.CreateWatermark = function(self, name)
	local gamename = marketplaceservice:GetProductInfo(game.PlaceId).Name;
	local watermark = {};
	watermark.Visible = true;
	watermark.text = " " .. name:gsub("{game}", gamename):gsub("{fps}", "0 FPS") .. " ";
	watermark.main = Instance.new("ScreenGui", coregui);
	watermark.main.Name = "Watermark";
	if syn then
		syn.protect_gui(watermark.main);
	end
	if getgenv().watermark then
		getgenv().watermark:Remove();
	end
	getgenv().watermark = watermark.main;
	watermark.mainbar = Instance.new("Frame", watermark.main);
	watermark.mainbar.Name = "Main";
	watermark.mainbar.BorderColor3 = Color3.fromRGB(80, 80, 80);
	watermark.mainbar.Visible = watermark.Visible;
	watermark.mainbar.BorderSizePixel = 0;
	watermark.mainbar.ZIndex = 5;
	watermark.mainbar.Position = UDim2.new(0, 1, 0, 1);
	watermark.mainbar.Size = UDim2.new(0, 0, 0, 25);
	watermark.Gradient = Instance.new("UIGradient", watermark.mainbar);
	watermark.Gradient.Rotation = 90;
	watermark.Gradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 40, 40)),ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 10, 10))});
	watermark.Outline = Instance.new("Frame", watermark.mainbar);
	watermark.Outline.Name = "outline";
	watermark.Outline.ZIndex = 4;
	watermark.Outline.BorderSizePixel = 0;
	watermark.Outline.Visible = watermark.Visible;
	watermark.Outline.BackgroundColor3 = library.theme.outlinecolor;
	watermark.Outline.Position = UDim2.fromOffset(-1, -1);
	watermark.BlackOutline = Instance.new("Frame", watermark.mainbar);
	watermark.BlackOutline.Name = "blackline";
	watermark.BlackOutline.ZIndex = 3;
	watermark.BlackOutline.BorderSizePixel = 0;
	watermark.BlackOutline.BackgroundColor3 = library.theme.outlinecolor2;
	watermark.BlackOutline.Visible = watermark.Visible;
	watermark.BlackOutline.Position = UDim2.fromOffset(-2, -2);
	watermark.label = Instance.new("TextLabel", watermark.mainbar);
	watermark.label.Name = "FPSLabel";
	watermark.label.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
	watermark.label.BackgroundTransparency = 1;
	watermark.label.Position = UDim2.new(0, 0, 0, 0);
	watermark.label.Size = UDim2.new(0, 238, 0, 25);
	watermark.label.Font = library.theme.font;
	watermark.label.ZIndex = 6;
	watermark.label.Visible = watermark.Visible;
	watermark.label.Text = watermark.text;
	watermark.label.TextColor3 = Color3.fromRGB(255, 255, 255);
	watermark.label.TextSize = 15;
	watermark.label.TextStrokeTransparency = 0;
	watermark.label.TextXAlignment = Enum.TextXAlignment.Left;
	watermark.label.Size = UDim2.new(0, watermark.label.TextBounds.X + 10, 0, 25);
	watermark.topbar = Instance.new("Frame", watermark.mainbar);
	watermark.topbar.Name = "TopBar";
	watermark.topbar.ZIndex = 6;
	watermark.topbar.BackgroundColor3 = library.theme.accentcolor;
	watermark.topbar.BorderSizePixel = 0;
	watermark.topbar.Visible = watermark.Visible;
	watermark.topbar.Size = UDim2.new(0, 0, 0, 1);
	watermark.mainbar.Size = UDim2.new(0, watermark.label.TextBounds.X, 0, 25);
	watermark.topbar.Size = UDim2.new(0, watermark.label.TextBounds.X + 6, 0, 1);
	watermark.Outline.Size = watermark.mainbar.Size + UDim2.fromOffset(2, 2);
	watermark.BlackOutline.Size = watermark.mainbar.Size + UDim2.fromOffset(4, 4);
	watermark.mainbar.Size = UDim2.new(0, watermark.label.TextBounds.X + 4, 0, 25);
	watermark.label.Size = UDim2.new(0, watermark.label.TextBounds.X + 4, 0, 25);
	watermark.topbar.Size = UDim2.new(0, watermark.label.TextBounds.X + 6, 0, 1);
	watermark.Outline.Size = watermark.mainbar.Size + UDim2.fromOffset(2, 2);
	watermark.BlackOutline.Size = watermark.mainbar.Size + UDim2.fromOffset(4, 4);
	local startTime, counter, oldfps = os.clock(), 0, nil;
local c_wm_hb = runservice.Heartbeat:Connect(function()
		watermark.label.Visible = watermark.Visible;
		watermark.mainbar.Visible = watermark.Visible;
		watermark.topbar.Visible = watermark.Visible;
		watermark.Outline.Visible = watermark.Visible;
		watermark.BlackOutline.Visible = watermark.Visible;
		if not name:find("{fps}") then
			watermark.label.Text = " " .. name:gsub("{game}", gamename):gsub("{fps}", "0 FPS") .. " ";
		end
		if name:find("{fps}") then
			local currentTime = os.clock();
			counter = counter + 1;
			if ((currentTime - startTime) >= 1) then
				local fps = math.floor(counter / (currentTime - startTime));
				counter = 0;
				startTime = currentTime;
				if (fps ~= oldfps) then
					watermark.label.Text = " " .. name:gsub("{game}", gamename):gsub("{fps}", fps .. " FPS") .. " ";
					watermark.label.Size = UDim2.new(0, watermark.label.TextBounds.X + 10, 0, 25);
					watermark.mainbar.Size = UDim2.new(0, watermark.label.TextBounds.X, 0, 25);
					watermark.topbar.Size = UDim2.new(0, watermark.label.TextBounds.X, 0, 1);
					watermark.Outline.Size = watermark.mainbar.Size + UDim2.fromOffset(2, 2);
					watermark.BlackOutline.Size = watermark.mainbar.Size + UDim2.fromOffset(4, 4);
				end
				oldfps = fps;
			end
		end
	end);
	table.insert(library.connections, c_wm_hb);
	watermark.mainbar.MouseEnter:Connect(function()
		tweenservice:Create(watermark.mainbar, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {BackgroundTransparency=1,Active=false}):Play();
		tweenservice:Create(watermark.topbar, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {BackgroundTransparency=1,Active=false}):Play();
		tweenservice:Create(watermark.label, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {TextTransparency=1,Active=false}):Play();
		tweenservice:Create(watermark.Outline, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {BackgroundTransparency=1,Active=false}):Play();
		tweenservice:Create(watermark.BlackOutline, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {BackgroundTransparency=1,Active=false}):Play();
	end);
	watermark.mainbar.MouseLeave:Connect(function()
		tweenservice:Create(watermark.mainbar, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {BackgroundTransparency=0,Active=true}):Play();
		tweenservice:Create(watermark.topbar, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {BackgroundTransparency=0,Active=true}):Play();
		tweenservice:Create(watermark.label, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {TextTransparency=0,Active=true}):Play();
		tweenservice:Create(watermark.Outline, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {BackgroundTransparency=0,Active=true}):Play();
		tweenservice:Create(watermark.BlackOutline, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {BackgroundTransparency=0,Active=true}):Play();
	end);
	watermark.UpdateTheme = function(self, theme)
		theme = theme or library.theme;
		watermark.Outline.BackgroundColor3 = theme.outlinecolor;
		watermark.BlackOutline.BackgroundColor3 = theme.outlinecolor2;
		watermark.label.Font = theme.font;
		watermark.topbar.BackgroundColor3 = theme.accentcolor;
	end;
	return watermark;
end;
library.CreateWindow = function(self, name, hidebutton)
	local window = {};
	window.name = name or "";
	window.size = UDim2.fromOffset(660, 420);
	window.hidebutton = hidebutton or Enum.KeyCode.Insert;
	window.theme = library.theme;
	local updateevent = Instance.new("BindableEvent");
	window.UpdateTheme = function(self, theme)
		updateevent:Fire(theme or library.theme);
		window.theme = theme or library.theme;
	end;
	window.Destroy = function(self)
		library:Destroy();
	end;
	window.Main = Instance.new("ScreenGui", coregui);
	window.Main.Name = name;
	window.Main.DisplayOrder = 15;
	if getgenv().uilib then
		getgenv().uilib:Remove();
	end
	getgenv().uilib = window.Main;
	local dragging, dragInput, dragStart, startPos;
	local c_wdrag = uis.InputChanged:Connect(function(input)
		if ((input == dragInput) and dragging) then
			local delta = input.Position - dragStart;
			window.Frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y);
		end
	end);
	table.insert(library.connections, c_wdrag);
	local dragstart = function(input)
		if ((input.UserInputType == Enum.UserInputType.MouseButton1) or (input.UserInputType == Enum.UserInputType.Touch)) then
			dragging = true;
			dragStart = input.Position;
			startPos = window.Frame.Position;
			input.Changed:Connect(function()
				if (input.UserInputState == Enum.UserInputState.End) then
					dragging = false;
				end
			end);
		end
	end;
	local dragend = function(input)
		if ((input.UserInputType == Enum.UserInputType.MouseMovement) or (input.UserInputType == Enum.UserInputType.Touch)) then
			dragInput = input;
		end
	end;
	window.Frame = Instance.new("TextButton", window.Main);
	window.Frame.Name = "main";
	window.Frame.Position = UDim2.fromScale(0.5, 0.5);
	window.Frame.BorderSizePixel = 0;
	window.Frame.Size = window.size;
	window.Frame.AutoButtonColor = false;
	window.Frame.Text = "";
	window.Frame.BackgroundColor3 = window.theme.backgroundcolor;
	window.Frame.AnchorPoint = Vector2.new(0.5, 0.5);
	window.UIScale = Instance.new("UIScale", window.Frame);
	local function updateWindowScale()
		pcall(function()
			local cam = workspace.CurrentCamera;
			if not cam then return end
			local vp = cam.ViewportSize;
			if vp.X > 0 and vp.Y > 0 then
				local scaleX = (vp.X - 24) / 660;
				local scaleY = (vp.Y - 48) / 420;
				window.UIScale.Scale = math.clamp(math.min(scaleX, scaleY, 1), 0.62, 1);
			end
		end);
	end
	updateWindowScale();
	if workspace.CurrentCamera then
		trackConn(workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateWindowScale));
	end
	updateevent.Event:Connect(function(theme)
		window.Frame.BackgroundColor3 = theme.backgroundcolor;
	end);
	local c_whide = uis.InputBegan:Connect(function(key)
		if (key.KeyCode == window.hidebutton) then
			if window.Frame then
				window.Frame.Visible = not window.Frame.Visible;
			elseif getgenv().uilib and getgenv().uilib:FindFirstChild("main") then
				getgenv().uilib.main.Visible = not getgenv().uilib.main.Visible;
			else
				local containers = {};
				if gethui then pcall(function() table.insert(containers, gethui()) end) end
				pcall(function() table.insert(containers, game:GetService("CoreGui")) end)
				for _, c in ipairs(containers) do
					for _, v in pairs(c:GetChildren()) do
						if v:FindFirstChild("main") then
							v.main.Visible = not v.main.Visible;
						end
					end
				end
			end
		end
	end);
	table.insert(library.connections, c_whide);
	local function checkIfGuiInFront(Pos)
		local objects = coregui:GetGuiObjectsAtPosition(Pos.X, Pos.Y);
		for i, v in pairs(objects) do
			if not string.find(v:GetFullName(), window.name) then
				table.remove(objects, i);
			end
		end
		return (#objects ~= 0) and (objects[1].AbsolutePosition ~= Pos);
	end
	window.BlackOutline = Instance.new("Frame", window.Frame);
	window.BlackOutline.Name = "outline";
	window.BlackOutline.ZIndex = 1;
	window.BlackOutline.Size = window.size + UDim2.fromOffset(2, 2);
	window.BlackOutline.BorderSizePixel = 0;
	window.BlackOutline.BackgroundColor3 = window.theme.outlinecolor2;
	window.BlackOutline.Position = UDim2.fromOffset(-1, -1);
	updateevent.Event:Connect(function(theme)
		window.BlackOutline.BackgroundColor3 = theme.outlinecolor2;
	end);
	window.Outline = Instance.new("Frame", window.Frame);
	window.Outline.Name = "outline";
	window.Outline.ZIndex = 0;
	window.Outline.Size = window.size + UDim2.fromOffset(4, 4);
	window.Outline.BorderSizePixel = 0;
	window.Outline.BackgroundColor3 = window.theme.outlinecolor;
	window.Outline.Position = UDim2.fromOffset(-2, -2);
	updateevent.Event:Connect(function(theme)
		window.Outline.BackgroundColor3 = theme.outlinecolor;
	end);
	window.BlackOutline2 = Instance.new("Frame", window.Frame);
	window.BlackOutline2.Name = "outline";
	window.BlackOutline2.ZIndex = -1;
	window.BlackOutline2.Size = window.size + UDim2.fromOffset(6, 6);
	window.BlackOutline2.BorderSizePixel = 0;
	window.BlackOutline2.BackgroundColor3 = window.theme.outlinecolor2;
	window.BlackOutline2.Position = UDim2.fromOffset(-3, -3);
	updateevent.Event:Connect(function(theme)
		window.BlackOutline2.BackgroundColor3 = theme.outlinecolor2;
	end);
	window.TopBar = Instance.new("Frame", window.Frame);
	window.TopBar.Name = "top";
	window.TopBar.Size = UDim2.fromOffset(window.size.X.Offset, window.theme.topheight);
	window.TopBar.BorderSizePixel = 0;
	window.TopBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
	window.TopBar.ClipsDescendants = true;
	window.TopBar.InputBegan:Connect(dragstart);
	window.TopBar.InputChanged:Connect(dragend);
	updateevent.Event:Connect(function(theme)
		window.TopBar.Size = UDim2.fromOffset(window.size.X.Offset, theme.topheight);
	end);
	window.TopGradient = Instance.new("UIGradient", window.TopBar);
	window.TopGradient.Rotation = 90;
	window.TopGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, window.theme.topcolor),ColorSequenceKeypoint.new(1, window.theme.topcolor2)});
	updateevent.Event:Connect(function(theme)
		window.TopGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, theme.topcolor),ColorSequenceKeypoint.new(1, theme.topcolor2)});
	end);
	window.NameLabel = Instance.new("TextLabel", window.TopBar);
	window.NameLabel.TextColor3 = window.theme.toptextcolor;
	window.NameLabel.Text = window.name;
	window.NameLabel.TextXAlignment = Enum.TextXAlignment.Left;
	window.NameLabel.Font = window.theme.font;
	window.NameLabel.Name = "title";
	window.NameLabel.Position = UDim2.fromOffset(6, -2);
	window.NameLabel.BackgroundTransparency = 1;
	window.NameLabel.Size = UDim2.new(1, -12, 0, (window.TopBar.Size.Y.Offset / 2) - 2);
	window.NameLabel.TextSize = window.theme.titlesize;
	updateevent.Event:Connect(function(theme)
		window.NameLabel.TextColor3 = theme.toptextcolor;
		window.NameLabel.Font = theme.font;
		window.NameLabel.TextSize = theme.titlesize;
	end);
	window.Line2 = Instance.new("Frame", window.TopBar);
	window.Line2.Name = "line";
	window.Line2.Position = UDim2.fromOffset(0, window.TopBar.Size.Y.Offset / 2.1);
	window.Line2.Size = UDim2.fromOffset(window.size.X.Offset, 1);
	window.Line2.BorderSizePixel = 0;
	window.Line2.BackgroundColor3 = window.theme.accentcolor;
	updateevent.Event:Connect(function(theme)
		window.Line2.BackgroundColor3 = theme.accentcolor;
	end);
	window.TabList = Instance.new("ScrollingFrame", window.TopBar);
	window.TabList.Name = "tablist";
	window.TabList.BackgroundTransparency = 1;
	window.TabList.Position = UDim2.fromOffset(0, (window.TopBar.Size.Y.Offset / 2) + 1);
	window.TabList.Size = UDim2.fromOffset(window.size.X.Offset, window.TopBar.Size.Y.Offset / 2);
	window.TabList.BorderSizePixel = 0;
	window.TabList.ScrollBarThickness = 0;
	window.TabList.ScrollingDirection = Enum.ScrollingDirection.X;
	window.TabList.AutomaticCanvasSize = Enum.AutomaticSize.X;
	window.TabList.CanvasSize = UDim2.new(0, 0, 0, 0);
	window.TabList.ClipsDescendants = true;
	window.TabList.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
	window.TabList.InputBegan:Connect(dragstart);
	window.TabList.InputChanged:Connect(dragend);
	window.BlackLine = Instance.new("Frame", window.Frame);
	window.BlackLine.Name = "blackline";
	window.BlackLine.Size = UDim2.fromOffset(window.size.X.Offset, 1);
	window.BlackLine.BorderSizePixel = 0;
	window.BlackLine.ZIndex = 9;
	window.BlackLine.BackgroundColor3 = window.theme.outlinecolor2;
	window.BlackLine.Position = UDim2.fromOffset(0, window.TopBar.Size.Y.Offset);
	updateevent.Event:Connect(function(theme)
		window.BlackLine.BackgroundColor3 = theme.outlinecolor2;
	end);
	window.BackgroundImage = Instance.new("ImageLabel", window.Frame);
	window.BackgroundImage.Name = "background";
	window.BackgroundImage.BorderSizePixel = 0;
	window.BackgroundImage.ScaleType = Enum.ScaleType.Tile;
	window.BackgroundImage.Position = window.BlackLine.Position + UDim2.fromOffset(0, 1);
	window.BackgroundImage.Size = UDim2.fromOffset(window.size.X.Offset, (window.size.Y.Offset - window.TopBar.Size.Y.Offset) - 1);
	window.BackgroundImage.Image = window.theme.background or "";
	window.BackgroundImage.ImageTransparency = ((window.BackgroundImage.Image ~= "") and 0) or 1;
	window.BackgroundImage.ImageColor3 = Color3.new();
	window.BackgroundImage.BackgroundColor3 = window.theme.backgroundcolor;
	window.BackgroundImage.TileSize = UDim2.new(0, window.theme.tilesize, 0, window.theme.tilesize);
	updateevent.Event:Connect(function(theme)
		window.BackgroundImage.Image = theme.background or "";
		window.BackgroundImage.ImageTransparency = ((window.BackgroundImage.Image ~= "") and 0) or 1;
		window.BackgroundImage.BackgroundColor3 = theme.backgroundcolor;
		window.BackgroundImage.TileSize = UDim2.new(0, theme.tilesize, 0, theme.tilesize);
	end);
	window.Line = Instance.new("Frame", window.Frame);
	window.Line.Name = "line";
	window.Line.Position = UDim2.fromOffset(0, 0);
	window.Line.Size = UDim2.fromOffset(60, 1);
	window.Line.BorderSizePixel = 0;
	window.Line.BackgroundColor3 = window.theme.accentcolor;
	updateevent.Event:Connect(function(theme)
		window.Line.BackgroundColor3 = theme.accentcolor;
	end);
	window.ListLayout = Instance.new("UIListLayout", window.TabList);
	window.ListLayout.FillDirection = Enum.FillDirection.Horizontal;
	window.ListLayout.SortOrder = Enum.SortOrder.LayoutOrder;
	window.OpenedColorPickers = {};
	window.Tabs = {};
	window.CurrentOpenDropdown = nil;
	window.DropdownOverlay = Instance.new("TextButton", window.Frame);
	window.DropdownOverlay.Name = "DropdownOverlay";
	window.DropdownOverlay.BackgroundTransparency = 1;
	window.DropdownOverlay.Size = UDim2.fromScale(1, 1);
	window.DropdownOverlay.Position = UDim2.fromOffset(0, 0);
	window.DropdownOverlay.ZIndex = 110;
	window.DropdownOverlay.Visible = false;
	window.DropdownOverlay.Text = "";
	window.DropdownOverlay.AutoButtonColor = false;
	local function closeActiveDropdown()
		if window.CurrentOpenDropdown then
			pcall(function()
				window.CurrentOpenDropdown:Close();
			end);
			window.CurrentOpenDropdown = nil;
		end
		if window.DropdownOverlay then
			window.DropdownOverlay.Visible = false;
		end
	end
	window.CloseDropdown = closeActiveDropdown;
	window.DropdownOverlay.Activated:Connect(closeActiveDropdown);
	window.DropdownOverlay.MouseButton1Click:Connect(closeActiveDropdown);
	window.CreateTab = function(self, name)
		local tab = {};
		tab.name = name or "";
		local textservice = game:GetService("TextService");
		local size = textservice:GetTextSize(tab.name, window.theme.fontsize, window.theme.font, Vector2.new(200, 300));
		tab.TabButton = Instance.new("TextButton", window.TabList);
		tab.TabButton.TextColor3 = window.theme.tabstextcolor;
		tab.TabButton.Text = tab.name;
		tab.TabButton.AutoButtonColor = false;
		tab.TabButton.Font = window.theme.font;
		tab.TabButton.TextYAlignment = Enum.TextYAlignment.Center;
		tab.TabButton.BackgroundTransparency = 1;
		tab.TabButton.BorderSizePixel = 0;
		tab.TabButton.Size = UDim2.fromOffset(size.X + 15, window.TabList.Size.Y.Offset - 1);
		tab.TabButton.Name = tab.name;
		tab.TabButton.TextSize = window.theme.fontsize;
		updateevent.Event:Connect(function(theme)
			local size = textservice:GetTextSize(tab.name, theme.fontsize, theme.font, Vector2.new(200, 200));
			tab.TabButton.TextColor3 = ((tab.TabButton.Name == "SelectedTab") and theme.accentcolor) or theme.tabstextcolor;
			tab.TabButton.Font = theme.font;
			tab.TabButton.Size = UDim2.fromOffset(size.X + 15, window.TabList.Size.Y.Offset - 1);
			tab.TabButton.TextSize = theme.fontsize;
		end);
		tab.Left = Instance.new("ScrollingFrame", window.Frame);
		tab.Left.Name = "leftside";
		tab.Left.BorderSizePixel = 0;
		tab.Left.Size = UDim2.fromOffset(window.size.X.Offset / 2, window.size.Y.Offset - (window.TopBar.Size.Y.Offset + 1));
		tab.Left.BackgroundTransparency = 1;
		tab.Left.Visible = false;
		tab.Left.ScrollBarThickness = 4;
		tab.Left.ScrollBarImageColor3 = window.theme.accentcolor;
		tab.Left.ScrollingDirection = "Y";
		tab.Left.AutomaticCanvasSize = Enum.AutomaticSize.Y;
		tab.Left.CanvasSize = UDim2.new(0, 0, 0, 0);
		tab.Left.Position = window.BlackLine.Position + UDim2.fromOffset(0, 1);
		tab.LeftListLayout = Instance.new("UIListLayout", tab.Left);
		tab.LeftListLayout.FillDirection = Enum.FillDirection.Vertical;
		tab.LeftListLayout.SortOrder = Enum.SortOrder.LayoutOrder;
		tab.LeftListLayout.Padding = UDim.new(0, 12);
		tab.LeftListPadding = Instance.new("UIPadding", tab.Left);
		tab.LeftListPadding.PaddingTop = UDim.new(0, 12);
		tab.LeftListPadding.PaddingLeft = UDim.new(0, 12);
		tab.LeftListPadding.PaddingRight = UDim.new(0, 12);
		tab.Right = Instance.new("ScrollingFrame", window.Frame);
		tab.Right.Name = "rightside";
		tab.Right.ScrollBarThickness = 4;
		tab.Right.ScrollBarImageColor3 = window.theme.accentcolor;
		tab.Right.ScrollingDirection = "Y";
		tab.Right.AutomaticCanvasSize = Enum.AutomaticSize.Y;
		tab.Right.CanvasSize = UDim2.new(0, 0, 0, 0);
		tab.Right.Visible = false;
		tab.Right.BorderSizePixel = 0;
		tab.Right.Size = UDim2.fromOffset(window.size.X.Offset / 2, window.size.Y.Offset - (window.TopBar.Size.Y.Offset + 1));
		tab.Right.BackgroundTransparency = 1;
		tab.Right.Position = tab.Left.Position + UDim2.fromOffset(window.size.X.Offset / 2, 0);
		tab.RightListLayout = Instance.new("UIListLayout", tab.Right);
		tab.RightListLayout.FillDirection = Enum.FillDirection.Vertical;
		tab.RightListLayout.SortOrder = Enum.SortOrder.LayoutOrder;
		tab.RightListLayout.Padding = UDim.new(0, 12);
		tab.RightListPadding = Instance.new("UIPadding", tab.Right);
		tab.RightListPadding.PaddingTop = UDim.new(0, 12);
		tab.RightListPadding.PaddingLeft = UDim.new(0, 6);
		tab.RightListPadding.PaddingRight = UDim.new(0, 12);
		local block = false;
		tab.SelectTab = function(self)
			if window.CloseDropdown then window:CloseDropdown() end
			repeat
				wait();
			until block == false 
			block = true;
			for i, v in pairs(window.Tabs) do
				if (v ~= tab) then
					v.TabButton.TextColor3 = Color3.fromRGB(230, 230, 230);
					v.TabButton.Name = "Tab";
					v.Left.Visible = false;
					v.Right.Visible = false;
				end
			end
			tab.TabButton.TextColor3 = window.theme.accentcolor;
			tab.TabButton.Name = "SelectedTab";
			tab.Right.Visible = true;
			tab.Left.Visible = true;
			window.Line:TweenSizeAndPosition(UDim2.fromOffset(size.X + 15, 1), UDim2.new(0, tab.TabButton.AbsolutePosition.X - window.Frame.AbsolutePosition.X, 0, 0) + (window.BlackLine.Position - UDim2.fromOffset(0, 1)), Enum.EasingDirection.In, Enum.EasingStyle.Sine, 0.15);
			task.spawn(function()
				task.wait(0.05)
				for _, s in pairs(tab.SectorsLeft) do
					pcall(function() s:FixSize() end)
				end
				for _, s in pairs(tab.SectorsRight) do
					pcall(function() s:FixSize() end)
				end
			end)
			wait(0.2);
			block = false;
		end;
		if (#window.Tabs == 0) then
			tab:SelectTab();
		end
		local lastTabClick = 0;
		local function onTabTrigger()
			local now = tick();
			if (now - lastTabClick) < 0.15 then return end;
			lastTabClick = now;
			tab:SelectTab();
		end
		tab.TabButton.Activated:Connect(onTabTrigger);
		tab.TabButton.MouseButton1Click:Connect(onTabTrigger);
		tab.SectorsLeft = {};
		tab.SectorsRight = {};
		tab.CreateSector = function(self, name, side)
			local sector = {};
			sector.name = name or "";
			sector.side = side:lower() or "left";
			sector.Main = Instance.new("Frame", ((sector.side == "left") and tab.Left) or tab.Right);
			sector.Main.Name = sector.name:gsub(" ", "") .. "Sector";
			sector.Main.BorderSizePixel = 0;
			sector.Main.ZIndex = 4;
			sector.Main.Size = UDim2.fromOffset((window.size.X.Offset / 2) - 17, 20);
			sector.Main.BackgroundColor3 = window.theme.sectorcolor;
			updateevent.Event:Connect(function(theme)
				sector.Main.BackgroundColor3 = theme.sectorcolor;
			end);
			sector.Line = Instance.new("Frame", sector.Main);
			sector.Line.Name = "line";
			sector.Line.ZIndex = 4;
			sector.Line.Size = UDim2.fromOffset(sector.Main.Size.X.Offset + 4, 1);
			sector.Line.BorderSizePixel = 0;
			sector.Line.Position = UDim2.fromOffset(-2, -2);
			sector.Line.BackgroundColor3 = window.theme.accentcolor;
			updateevent.Event:Connect(function(theme)
				sector.Line.BackgroundColor3 = theme.accentcolor;
			end);
			sector.BlackOutline = Instance.new("Frame", sector.Main);
			sector.BlackOutline.Name = "outline";
			sector.BlackOutline.ZIndex = 3;
			sector.BlackOutline.Size = sector.Main.Size + UDim2.fromOffset(2, 2);
			sector.BlackOutline.BorderSizePixel = 0;
			sector.BlackOutline.BackgroundColor3 = window.theme.outlinecolor2;
			sector.BlackOutline.Position = UDim2.fromOffset(-1, -1);
			sector.Main:GetPropertyChangedSignal("Size"):Connect(function()
				sector.BlackOutline.Size = sector.Main.Size + UDim2.fromOffset(2, 2);
			end);
			updateevent.Event:Connect(function(theme)
				sector.BlackOutline.BackgroundColor3 = theme.outlinecolor2;
			end);
			sector.Outline = Instance.new("Frame", sector.Main);
			sector.Outline.Name = "outline";
			sector.Outline.ZIndex = 2;
			sector.Outline.Size = sector.Main.Size + UDim2.fromOffset(4, 4);
			sector.Outline.BorderSizePixel = 0;
			sector.Outline.BackgroundColor3 = window.theme.outlinecolor;
			sector.Outline.Position = UDim2.fromOffset(-2, -2);
			sector.Main:GetPropertyChangedSignal("Size"):Connect(function()
				sector.Outline.Size = sector.Main.Size + UDim2.fromOffset(4, 4);
			end);
			updateevent.Event:Connect(function(theme)
				sector.Outline.BackgroundColor3 = theme.outlinecolor;
			end);
			sector.BlackOutline2 = Instance.new("Frame", sector.Main);
			sector.BlackOutline2.Name = "outline";
			sector.BlackOutline2.ZIndex = 1;
			sector.BlackOutline2.Size = sector.Main.Size + UDim2.fromOffset(6, 6);
			sector.BlackOutline2.BorderSizePixel = 0;
			sector.BlackOutline2.BackgroundColor3 = window.theme.outlinecolor2;
			sector.BlackOutline2.Position = UDim2.fromOffset(-3, -3);
			sector.Main:GetPropertyChangedSignal("Size"):Connect(function()
				sector.BlackOutline2.Size = sector.Main.Size + UDim2.fromOffset(6, 6);
			end);
			updateevent.Event:Connect(function(theme)
				sector.BlackOutline2.BackgroundColor3 = theme.outlinecolor2;
			end);
			local size = textservice:GetTextSize(sector.name, 15, window.theme.font, Vector2.new(2000, 2000));
			sector.Label = Instance.new("TextLabel", sector.Main);
			sector.Label.AnchorPoint = Vector2.new(0, 0.5);
			sector.Label.Position = UDim2.fromOffset(12, -1);
			sector.Label.Size = UDim2.fromOffset(math.clamp(size.X + 13, 0, sector.Main.Size.X.Offset - 16), size.Y);
			sector.Label.TextXAlignment = Enum.TextXAlignment.Left;
			sector.Label.BackgroundTransparency = 1;
			sector.Label.BorderSizePixel = 0;
			sector.Label.ZIndex = 6;
			sector.Label.Text = sector.name;
			sector.Label.TextColor3 = Color3.new(1, 1, 2552 / 255);
			sector.Label.TextStrokeTransparency = 1;
			sector.Label.Font = window.theme.font;
			sector.Label.TextSize = 15;
			updateevent.Event:Connect(function(theme)
				local size = textservice:GetTextSize(sector.name, 15, theme.font, Vector2.new(2000, 2000));
				sector.Label.Size = UDim2.fromOffset(math.clamp(size.X + 13, 0, sector.Main.Size.X.Offset - 16), size.Y);
				sector.Label.Font = theme.font;
			end);
			sector.LabelBackFrame = Instance.new("Frame", sector.Main);
			sector.LabelBackFrame.Name = "labelframe";
			sector.LabelBackFrame.ZIndex = 5;
			sector.LabelBackFrame.Size = UDim2.fromOffset(sector.Label.Size.X.Offset, 10);
			sector.LabelBackFrame.BorderSizePixel = 0;
			sector.LabelBackFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30);
			sector.LabelBackFrame.Position = UDim2.fromOffset(sector.Label.Position.X.Offset, sector.BlackOutline2.Position.Y.Offset);
			sector.Items = Instance.new("Frame", sector.Main);
			sector.Items.Name = "items";
			sector.Items.ZIndex = 2;
			sector.Items.BackgroundTransparency = 1;
			sector.Items.Size = UDim2.fromOffset(170, 140);
			sector.Items.AutomaticSize = Enum.AutomaticSize.Y;
			sector.Items.BorderSizePixel = 0;
			sector.ListLayout = Instance.new("UIListLayout", sector.Items);
			sector.ListLayout.FillDirection = Enum.FillDirection.Vertical;
			sector.ListLayout.SortOrder = Enum.SortOrder.LayoutOrder;
			sector.ListLayout.Padding = UDim.new(0, 12);
			sector.ListPadding = Instance.new("UIPadding", sector.Items);
			sector.ListPadding.PaddingTop = UDim.new(0, 15);
			sector.ListPadding.PaddingLeft = UDim.new(0, 6);
			sector.ListPadding.PaddingRight = UDim.new(0, 6);
			table.insert(((sector.side:lower() == "left") and tab.SectorsLeft) or tab.SectorsRight, sector);
			sector.FixSize = function(self)
				local contentH = sector.ListLayout.AbsoluteContentSize.Y;
				if contentH <= 0 then
					contentH = (#sector.Items:GetChildren() - 2) * 28 + 15;
				end
				sector.Main.Size = UDim2.fromOffset((window.size.X.Offset / 2) - 17, math.max(contentH + 26, 40));
				local sizeleft, sizeright = 0, 0;
				for i, v in pairs(tab.SectorsLeft) do
					sizeleft = sizeleft + (v.Main.Size.Y.Offset > 0 and v.Main.Size.Y.Offset or v.Main.AbsoluteSize.Y);
				end
				for i, v in pairs(tab.SectorsRight) do
					sizeright = sizeright + (v.Main.Size.Y.Offset > 0 and v.Main.Size.Y.Offset or v.Main.AbsoluteSize.Y);
				end
				tab.Left.CanvasSize = UDim2.fromOffset(0, sizeleft + ((#tab.SectorsLeft + 1) * 15) + 40);
				tab.Right.CanvasSize = UDim2.fromOffset(0, sizeright + ((#tab.SectorsRight + 1) * 15) + 40);
			end;
			sector.AddButton = function(self, text, callback)
				local button = {};
				button.text = text or "";
				button.callback = callback or function()
				end;
				button.Main = Instance.new("TextButton", sector.Items);
				button.Main.BorderSizePixel = 0;
				button.Main.Text = "";
				button.Main.AutoButtonColor = false;
				button.Main.Name = "button";
				button.Main.ZIndex = 5;
				button.Main.Size = UDim2.fromOffset(sector.Main.Size.X.Offset - 12, 18);
				button.Main.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
				button.Gradient = Instance.new("UIGradient", button.Main);
				button.Gradient.Rotation = 90;
				button.Gradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, window.theme.buttoncolor),ColorSequenceKeypoint.new(1, window.theme.buttoncolor2)});
				updateevent.Event:Connect(function(theme)
					button.Gradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, theme.buttoncolor),ColorSequenceKeypoint.new(1, theme.buttoncolor2)});
				end);
				button.BlackOutline2 = Instance.new("Frame", button.Main);
				button.BlackOutline2.Name = "blackline";
				button.BlackOutline2.ZIndex = 4;
				button.BlackOutline2.Size = button.Main.Size + UDim2.fromOffset(6, 6);
				button.BlackOutline2.BorderSizePixel = 0;
				button.BlackOutline2.BackgroundColor3 = window.theme.outlinecolor2;
				button.BlackOutline2.Position = UDim2.fromOffset(-3, -3);
				updateevent.Event:Connect(function(theme)
					button.BlackOutline2.BackgroundColor3 = theme.outlinecolor2;
				end);
				button.Outline = Instance.new("Frame", button.Main);
				button.Outline.Name = "blackline";
				button.Outline.ZIndex = 4;
				button.Outline.Size = button.Main.Size + UDim2.fromOffset(4, 4);
				button.Outline.BorderSizePixel = 0;
				button.Outline.BackgroundColor3 = window.theme.outlinecolor;
				button.Outline.Position = UDim2.fromOffset(-2, -2);
				updateevent.Event:Connect(function(theme)
					button.Outline.BackgroundColor3 = theme.outlinecolor;
				end);
				button.BlackOutline = Instance.new("Frame", button.Main);
				button.BlackOutline.Name = "blackline";
				button.BlackOutline.ZIndex = 4;
				button.BlackOutline.Size = button.Main.Size + UDim2.fromOffset(2, 2);
				button.BlackOutline.BorderSizePixel = 0;
				button.BlackOutline.BackgroundColor3 = window.theme.outlinecolor2;
				button.BlackOutline.Position = UDim2.fromOffset(-1, -1);
				updateevent.Event:Connect(function(theme)
					button.BlackOutline.BackgroundColor3 = theme.outlinecolor2;
				end);
				button.Label = Instance.new("TextLabel", button.Main);
				button.Label.Name = "Label";
				button.Label.BackgroundTransparency = 1;
				button.Label.Position = UDim2.new(0, -1, 0, 0);
				button.Label.ZIndex = 5;
				button.Label.Size = button.Main.Size;
				button.Label.Font = window.theme.font;
				button.Label.Text = button.text;
				button.Label.TextColor3 = window.theme.itemscolor2;
				button.Label.TextSize = 15;
				button.Label.TextStrokeTransparency = 1;
				button.Label.TextXAlignment = Enum.TextXAlignment.Center;
				local lastBtnClick = 0;
				local function onBtnTrigger()
					local now = tick();
					if (now - lastBtnClick) < 0.18 then return end;
					lastBtnClick = now;
					pcall(button.callback);
				end
				button.Main.Activated:Connect(onBtnTrigger);
				button.Main.MouseButton1Click:Connect(onBtnTrigger);
				updateevent.Event:Connect(function(theme)
					button.Label.Font = theme.font;
					button.Label.TextColor3 = theme.itemscolor;
				end);
				button.BlackOutline2.MouseEnter:Connect(function()
					button.BlackOutline2.BackgroundColor3 = window.theme.accentcolor;
				end);
				button.BlackOutline2.MouseLeave:Connect(function()
					button.BlackOutline2.BackgroundColor3 = window.theme.outlinecolor2;
				end);
				sector:FixSize();
				return button;
			end;
			sector.AddLabel = function(self, text, ranbow)
				local label = {};
				label.Main = Instance.new("TextLabel", sector.Items);
				label.Main.Name = "Label";
				label.Main.BackgroundTransparency = 1;
				label.Main.Position = UDim2.new(0, -1, 0, 0);
				label.Main.ZIndex = 4;
				label.Main.AutomaticSize = Enum.AutomaticSize.X;
				label.Main.Font = window.theme.font;
				label.Main.Text = text;
				label.Main.TextColor3 = window.theme.itemscolor;
				if (ranbow == true) then
					RainbowText(label.Main);
				end
				label.Main.TextSize = 15;
				label.Main.TextStrokeTransparency = 1;
				label.Main.TextXAlignment = Enum.TextXAlignment.Left;
				updateevent.Event:Connect(function(theme)
					label.Main.Font = theme.font;
					label.Main.TextColor3 = theme.itemscolor;
				end);
				label.Set = function(self, value)
					label.Main.Text = value;
				end;
				sector:FixSize();
				return label;
			end;
			sector.AddToggle = function(self, text, default, callback, flag)
				local toggle = {};
				toggle.text = text or "";
				toggle.default = default or false;
				toggle.callback = callback or function(value)
				end;
				toggle.flag = flag or text or "";
				toggle.value = toggle.default;
				toggle.Main = Instance.new("TextButton", sector.Items);
				toggle.Main.Name = "toggle";
				toggle.Main.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
				toggle.Main.BorderColor3 = window.theme.outlinecolor;
				toggle.Main.BorderSizePixel = 0;
				toggle.Main.Size = UDim2.fromOffset(15, 15);
				toggle.Main.AutoButtonColor = false;
				toggle.Main.ZIndex = 5;
				toggle.Main.Font = Enum.Font.SourceSans;
				toggle.Main.Text = "";
				toggle.Main.TextColor3 = Color3.fromRGB(0, 0, 0);
				toggle.Main.TextSize = 15;
				updateevent.Event:Connect(function(theme)
					toggle.Main.BorderColor3 = theme.outlinecolor;
				end);
				toggle.BlackOutline2 = Instance.new("Frame", toggle.Main);
				toggle.BlackOutline2.Name = "blackline";
				toggle.BlackOutline2.ZIndex = 4;
				toggle.BlackOutline2.Size = toggle.Main.Size + UDim2.fromOffset(6, 6);
				toggle.BlackOutline2.BorderSizePixel = 0;
				toggle.BlackOutline2.BackgroundColor3 = window.theme.outlinecolor2;
				toggle.BlackOutline2.Position = UDim2.fromOffset(-3, -3);
				updateevent.Event:Connect(function(theme)
					toggle.BlackOutline2.BackgroundColor3 = theme.outlinecolor2;
				end);
				toggle.Outline = Instance.new("Frame", toggle.Main);
				toggle.Outline.Name = "blackline";
				toggle.Outline.ZIndex = 4;
				toggle.Outline.Size = toggle.Main.Size + UDim2.fromOffset(4, 4);
				toggle.Outline.BorderSizePixel = 0;
				toggle.Outline.BackgroundColor3 = window.theme.outlinecolor;
				toggle.Outline.Position = UDim2.fromOffset(-2, -2);
				updateevent.Event:Connect(function(theme)
					toggle.Outline.BackgroundColor3 = theme.outlinecolor;
				end);
				toggle.BlackOutline = Instance.new("Frame", toggle.Main);
				toggle.BlackOutline.Name = "blackline";
				toggle.BlackOutline.ZIndex = 4;
				toggle.BlackOutline.Size = toggle.Main.Size + UDim2.fromOffset(2, 2);
				toggle.BlackOutline.BorderSizePixel = 0;
				toggle.BlackOutline.BackgroundColor3 = window.theme.outlinecolor2;
				toggle.BlackOutline.Position = UDim2.fromOffset(-1, -1);
				updateevent.Event:Connect(function(theme)
					toggle.BlackOutline.BackgroundColor3 = theme.outlinecolor2;
				end);
				toggle.Gradient = Instance.new("UIGradient", toggle.Main);
				toggle.Gradient.Rotation = 22.5 * 13;
				toggle.Gradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 30)),ColorSequenceKeypoint.new(1, Color3.fromRGB(45, 45, 45))});
				toggle.Label = Instance.new("TextButton", toggle.Main);
				toggle.Label.Name = "Label";
				toggle.Label.AutoButtonColor = false;
				toggle.Label.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
				toggle.Label.BackgroundTransparency = 1;
				toggle.Label.Position = UDim2.fromOffset(toggle.Main.Size.X.Offset + 10, -2);
				toggle.Label.Size = UDim2.fromOffset(sector.Main.Size.X.Offset - 71, toggle.BlackOutline.Size.Y.Offset);
				toggle.Label.Font = window.theme.font;
				toggle.Label.ZIndex = 5;
				toggle.Label.Text = toggle.text;
				toggle.Label.TextColor3 = window.theme.itemscolor;
				toggle.Label.TextSize = 15;
				toggle.Label.TextStrokeTransparency = 1;
				toggle.Label.TextXAlignment = Enum.TextXAlignment.Left;
				updateevent.Event:Connect(function(theme)
					toggle.Label.Font = theme.font;
					toggle.Label.TextColor3 = (toggle.value and window.theme.itemscolor2) or theme.itemscolor;
				end);
				toggle.CheckedFrame = Instance.new("Frame", toggle.Main);
				toggle.CheckedFrame.ZIndex = 5;
				toggle.CheckedFrame.BorderSizePixel = 0;
				toggle.CheckedFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
				toggle.CheckedFrame.Size = toggle.Main.Size;
				toggle.Gradient2 = Instance.new("UIGradient", toggle.CheckedFrame);
				toggle.Gradient2.Rotation = 22.5 * 13;
				toggle.Gradient2.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, window.theme.accentcolor2),ColorSequenceKeypoint.new(1, window.theme.accentcolor)});
				updateevent.Event:Connect(function(theme)
					toggle.Gradient2.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, theme.accentcolor2),ColorSequenceKeypoint.new(1, theme.accentcolor)});
				end);
				toggle.Items = Instance.new("Frame", toggle.Main);
				toggle.Items.Name = "\n";
				toggle.Items.ZIndex = 4;
				toggle.Items.Size = UDim2.fromOffset(60, toggle.BlackOutline.Size.Y.Offset);
				toggle.Items.BorderSizePixel = 0;
				toggle.Items.BackgroundTransparency = 1;
				toggle.Items.BackgroundColor3 = Color3.new(0, 0, 0);
				toggle.Items.Position = UDim2.fromOffset(sector.Main.Size.X.Offset - 71, 0);
				toggle.ListLayout = Instance.new("UIListLayout", toggle.Items);
				toggle.ListLayout.FillDirection = Enum.FillDirection.Horizontal;
				toggle.ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right;
				toggle.ListLayout.SortOrder = Enum.SortOrder.LayoutOrder;
				toggle.ListLayout.Padding = UDim.new(0.04, 6);
				if (toggle.flag and (toggle.flag ~= "")) then
					library.flags[toggle.flag] = toggle.default or false;
				end
				toggle.Set = function(self, value)
					if value then
						toggle.Label.TextColor3 = window.theme.itemscolor2;
					else
						toggle.Label.TextColor3 = window.theme.itemscolor;
					end
					toggle.value = value;
					toggle.CheckedFrame.Visible = value;
					if (toggle.flag and (toggle.flag ~= "")) then
						library.flags[toggle.flag] = toggle.value;
					end
					pcall(toggle.callback, value);
				end;
				toggle.Get = function(self)
					return toggle.value;
				end;
				toggle:Set(toggle.default);
				toggle.AddKeybind = function(self, default, flag)
					local keybind = {};
					keybind.default = default or "None";
					keybind.value = keybind.default;
					keybind.flag = flag or ((toggle.text or "") .. tostring(#toggle.Items:GetChildren()));
					local shorter_keycodes = {LeftShift="LSHIFT",RightShift="RSHIFT",LeftControl="LCTRL",RightControl="RCTRL",LeftAlt="LALT",RightAlt="RALT"};
					local text = ((keybind.default == "None") and "[None]") or ("[" .. (shorter_keycodes[keybind.default.Name] or keybind.default.Name) .. "]");
					local size = textservice:GetTextSize(text, 15, window.theme.font, Vector2.new(2000, 2000));
					keybind.Main = Instance.new("TextButton", toggle.Items);
					keybind.Main.Name = "keybind";
					keybind.Main.BackgroundTransparency = 1;
					keybind.Main.BorderSizePixel = 0;
					keybind.Main.ZIndex = 5;
					keybind.Main.Size = UDim2.fromOffset(size.X + 2, size.Y - 7);
					keybind.Main.Text = text;
					keybind.Main.Font = window.theme.font;
					keybind.Main.TextColor3 = Color3.fromRGB(136, 136, 136);
					keybind.Main.TextSize = 15;
					keybind.Main.TextXAlignment = Enum.TextXAlignment.Right;
					keybind.Main.MouseButton1Down:Connect(function()
						keybind.Main.Text = "[...]";
						keybind.Main.TextColor3 = window.theme.accentcolor;
					end);
					updateevent.Event:Connect(function(theme)
						keybind.Main.Font = theme.font;
						if (keybind.Main.Text == "[...]") then
							keybind.Main.TextColor3 = theme.accentcolor;
						else
							keybind.Main.TextColor3 = Color3.fromRGB(136, 136, 136);
						end
					end);
					if (keybind.flag and (keybind.flag ~= "")) then
						library.flags[keybind.flag] = keybind.default;
					end
					keybind.Set = function(self, key)
						if (key == "None") then
							keybind.Main.Text = "[" .. key .. "]";
							keybind.value = key;
							if (keybind.flag and (keybind.flag ~= "")) then
								library.flags[keybind.flag] = key;
							end
						end
						keybind.Main.Text = "[" .. (shorter_keycodes[key.Name] or key.Name) .. "]";
						keybind.value = key;
						if (keybind.flag and (keybind.flag ~= "")) then
							library.flags[keybind.flag] = keybind.value;
						end
					end;
					keybind.Get = function(self)
						return keybind.value;
					end;
					uis.InputBegan:Connect(function(input, gameProcessed)
						if not gameProcessed then
							if (keybind.Main.Text == "[...]") then
								keybind.Main.TextColor3 = Color3.fromRGB(136, 136, 136);
								if (input.UserInputType == Enum.UserInputType.Keyboard) then
									keybind:Set(input.KeyCode);
								else
									keybind:Set("None");
								end
							elseif ((keybind.value ~= "None") and (input.KeyCode == keybind.value)) then
								toggle:Set(not toggle.CheckedFrame.Visible);
							end
						end
					end);
					table.insert(library.items, keybind);
					return keybind;
				end;
				toggle.AddDropdown = function(self, items, default, multichoice, callback, flag)
					local dropdown = {};
					dropdown.defaultitems = items or {};
					dropdown.default = default;
					dropdown.callback = callback or function()
					end;
					dropdown.multichoice = multichoice or false;
					dropdown.values = {};
					dropdown.flag = flag or ((toggle.text or "") .. tostring(#(sector.Items:GetChildren())) .. "a");
					dropdown.Main = Instance.new("TextButton", sector.Items);
					dropdown.Main.Name = "dropdown";
					dropdown.Main.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
					dropdown.Main.BorderSizePixel = 0;
					dropdown.Main.Size = UDim2.fromOffset(sector.Main.Size.X.Offset - 12, 16);
					dropdown.Main.Position = UDim2.fromOffset(0, 0);
					dropdown.Main.ZIndex = 5;
					dropdown.Main.AutoButtonColor = false;
					dropdown.Main.Font = window.theme.font;
					dropdown.Main.Text = "";
					dropdown.Main.TextColor3 = Color3.fromRGB(255, 255, 255);
					dropdown.Main.TextSize = 15;
					dropdown.Main.TextXAlignment = Enum.TextXAlignment.Left;
					updateevent.Event:Connect(function(theme)
						dropdown.Main.Font = theme.font;
					end);
					dropdown.Gradient = Instance.new("UIGradient", dropdown.Main);
					dropdown.Gradient.Rotation = 90;
					dropdown.Gradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(49, 49, 49)),ColorSequenceKeypoint.new(1, Color3.fromRGB(39, 39, 39))});
					dropdown.SelectedLabel = Instance.new("TextLabel", dropdown.Main);
					dropdown.SelectedLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
					dropdown.SelectedLabel.BackgroundTransparency = 1;
					dropdown.SelectedLabel.Position = UDim2.fromOffset(5, 2);
					dropdown.SelectedLabel.Size = UDim2.fromOffset(130, 13);
					dropdown.SelectedLabel.Font = window.theme.font;
					dropdown.SelectedLabel.Text = toggle.text;
					dropdown.SelectedLabel.ZIndex = 5;
					dropdown.SelectedLabel.TextColor3 = Color3.fromRGB(255, 255, 255);
					dropdown.SelectedLabel.TextSize = 15;
					dropdown.SelectedLabel.TextStrokeTransparency = 1;
					dropdown.SelectedLabel.TextXAlignment = Enum.TextXAlignment.Left;
					updateevent.Event:Connect(function(theme)
						dropdown.SelectedLabel.Font = theme.font;
					end);
					dropdown.Nav = Instance.new("ImageButton", dropdown.Main);
					dropdown.Nav.Name = "navigation";
					dropdown.Nav.BackgroundTransparency = 1;
					dropdown.Nav.LayoutOrder = 10;
					dropdown.Nav.Position = UDim2.fromOffset(sector.Main.Size.X.Offset - 26, 5);
					dropdown.Nav.Rotation = 90;
					dropdown.Nav.ZIndex = 5;
					dropdown.Nav.Size = UDim2.fromOffset(8, 8);
					dropdown.Nav.Image = "rbxassetid://4918373417";
					dropdown.Nav.ImageColor3 = Color3.fromRGB(210, 210, 210);
					dropdown.BlackOutline2 = Instance.new("Frame", dropdown.Main);
					dropdown.BlackOutline2.Name = "blackline";
					dropdown.BlackOutline2.ZIndex = 4;
					dropdown.BlackOutline2.Size = dropdown.Main.Size + UDim2.fromOffset(6, 6);
					dropdown.BlackOutline2.BorderSizePixel = 0;
					dropdown.BlackOutline2.BackgroundColor3 = window.theme.outlinecolor2;
					dropdown.BlackOutline2.Position = UDim2.fromOffset(-3, -3);
					updateevent.Event:Connect(function(theme)
						dropdown.BlackOutline2.BackgroundColor3 = theme.outlinecolor2;
					end);
					dropdown.Outline = Instance.new("Frame", dropdown.Main);
					dropdown.Outline.Name = "blackline";
					dropdown.Outline.ZIndex = 4;
					dropdown.Outline.Size = dropdown.Main.Size + UDim2.fromOffset(4, 4);
					dropdown.Outline.BorderSizePixel = 0;
					dropdown.Outline.BackgroundColor3 = window.theme.outlinecolor;
					dropdown.Outline.Position = UDim2.fromOffset(-2, -2);
					updateevent.Event:Connect(function(theme)
						dropdown.Outline.BackgroundColor3 = theme.outlinecolor;
					end);
					dropdown.BlackOutline = Instance.new("Frame", dropdown.Main);
					dropdown.BlackOutline.Name = "blackline444";
					dropdown.BlackOutline.ZIndex = 4;
					dropdown.BlackOutline.Size = dropdown.Main.Size + UDim2.fromOffset(2, 2);
					dropdown.BlackOutline.BorderSizePixel = 0;
					dropdown.BlackOutline.BackgroundColor3 = window.theme.outlinecolor2;
					dropdown.BlackOutline.Position = UDim2.fromOffset(-1, -1);
					updateevent.Event:Connect(function(theme)
						dropdown.BlackOutline.BackgroundColor3 = theme.outlinecolor2;
					end);
					dropdown.ItemsFrame = Instance.new("ScrollingFrame", dropdown.Main);
					dropdown.ItemsFrame.Name = "itemsframe";
					dropdown.ItemsFrame.BorderSizePixel = 0;
					dropdown.ItemsFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40);
					dropdown.ItemsFrame.Position = UDim2.fromOffset(0, dropdown.Main.Size.Y.Offset + 8);
					dropdown.ItemsFrame.ScrollBarThickness = library.theme.dpScrollBarThickness;
					dropdown.ItemsFrame.ScrollBarImageColor3 = library.theme.accentcolor;
					dropdown.ItemsFrame.ZIndex = 8;
					dropdown.ItemsFrame.ScrollingDirection = "Y";
					dropdown.ItemsFrame.Visible = false;
					dropdown.ItemsFrame.Size = UDim2.new(0, 0, 0, 0);
					dropdown.ItemsFrame.CanvasSize = UDim2.fromOffset(0, 0);
					dropdown.ListLayout = Instance.new("UIListLayout", dropdown.ItemsFrame);
					dropdown.ListLayout.FillDirection = Enum.FillDirection.Vertical;
					dropdown.ListLayout.SortOrder = Enum.SortOrder.LayoutOrder;
					dropdown.ListPadding = Instance.new("UIPadding", dropdown.ItemsFrame);
					dropdown.ListPadding.PaddingTop = UDim.new(0, 2);
					dropdown.ListPadding.PaddingBottom = UDim.new(0, 2);
					dropdown.ListPadding.PaddingLeft = UDim.new(0, 2);
					dropdown.ListPadding.PaddingRight = UDim.new(0, 2);
					dropdown.BlackOutline2Items = Instance.new("Frame", dropdown.Main);
					dropdown.BlackOutline2Items.Name = "blackline3";
					dropdown.BlackOutline2Items.ZIndex = 7;
					dropdown.BlackOutline2Items.Size = dropdown.ItemsFrame.Size + UDim2.fromOffset(6, 6);
					dropdown.BlackOutline2Items.BorderSizePixel = 0;
					dropdown.BlackOutline2Items.BackgroundColor3 = window.theme.outlinecolor2;
					dropdown.BlackOutline2Items.Position = dropdown.ItemsFrame.Position + UDim2.fromOffset(-3, -3);
					dropdown.BlackOutline2Items.Visible = false;
					updateevent.Event:Connect(function(theme)
						dropdown.BlackOutline2Items.BackgroundColor3 = theme.outlinecolor2;
					end);
					dropdown.OutlineItems = Instance.new("Frame", dropdown.Main);
					dropdown.OutlineItems.Name = "blackline8";
					dropdown.OutlineItems.ZIndex = 7;
					dropdown.OutlineItems.Size = dropdown.ItemsFrame.Size + UDim2.fromOffset(4, 4);
					dropdown.OutlineItems.BorderSizePixel = 0;
					dropdown.OutlineItems.BackgroundColor3 = window.theme.outlinecolor;
					dropdown.OutlineItems.Position = dropdown.ItemsFrame.Position + UDim2.fromOffset(-2, -2);
					dropdown.OutlineItems.Visible = false;
					updateevent.Event:Connect(function(theme)
						dropdown.OutlineItems.BackgroundColor3 = theme.outlinecolor;
					end);
					dropdown.BlackOutlineItems = Instance.new("Frame", dropdown.Main);
					dropdown.BlackOutlineItems.Name = "blackline3";
					dropdown.BlackOutlineItems.ZIndex = 7;
					dropdown.BlackOutlineItems.Size = dropdown.ItemsFrame.Size + UDim2.fromOffset(-2, -2);
					dropdown.BlackOutlineItems.BorderSizePixel = 0;
					dropdown.BlackOutlineItems.BackgroundColor3 = window.theme.outlinecolor2;
					dropdown.BlackOutlineItems.Position = dropdown.ItemsFrame.Position + UDim2.fromOffset(-1, -1);
					dropdown.BlackOutlineItems.Visible = false;
					updateevent.Event:Connect(function(theme)
						dropdown.BlackOutlineItems.BackgroundColor3 = theme.outlinecolor2;
					end);
					dropdown.IgnoreBackButtons = Instance.new("TextButton", dropdown.Main);
					dropdown.IgnoreBackButtons.BackgroundTransparency = 1;
					dropdown.IgnoreBackButtons.BorderSizePixel = 0;
					dropdown.IgnoreBackButtons.Position = UDim2.fromOffset(0, dropdown.Main.Size.Y.Offset + 8);
					dropdown.IgnoreBackButtons.Size = UDim2.new(0, 0, 0, 0);
					dropdown.IgnoreBackButtons.ZIndex = 7;
					dropdown.IgnoreBackButtons.Text = "";
					dropdown.IgnoreBackButtons.Visible = false;
					dropdown.IgnoreBackButtons.AutoButtonColor = false;
					if (dropdown.flag and (dropdown.flag ~= "")) then
						library.flags[dropdown.flag] = (dropdown.multichoice and {(dropdown.default or dropdown.defaultitems[1] or "")}) or dropdown.default or dropdown.defaultitems[1] or "";
					end
					dropdown.isSelected = function(self, item)
						for i, v in pairs(dropdown.values) do
							if (v == item) then
								return true;
							end
						end
						return false;
					end;
					dropdown.updateText = function(self, text)
						if (#text >= 27) then
							text = text:sub(1, 25) .. "..";
						end
						dropdown.SelectedLabel.Text = text;
					end;
					dropdown.Changed = Instance.new("BindableEvent");
					dropdown.Set = function(self, value)
						if (type(value) == "table") then
							dropdown.values = value;
							dropdown:updateText(table.concat(value, ", "));
							pcall(dropdown.callback, value);
						else
							dropdown:updateText(value);
							dropdown.values = {value};
							pcall(dropdown.callback, value);
						end
						dropdown.Changed:Fire(value);
						if (dropdown.flag and (dropdown.flag ~= "")) then
							library.flags[dropdown.flag] = (dropdown.multichoice and dropdown.values) or dropdown.values[1];
						end
					end;
					dropdown.Get = function(self)
						return (dropdown.multichoice and dropdown.values) or dropdown.values[1];
					end;
					dropdown.items = {};
					dropdown.Add = function(self, v)
						local Item = Instance.new("TextButton", dropdown.ItemsFrame);
						Item.BackgroundColor3 = Color3.fromRGB(40, 40, 40);
						Item.TextColor3 = Color3.fromRGB(255, 255, 255);
						Item.BorderSizePixel = 0;
						Item.Position = UDim2.fromOffset(0, 0);
						Item.Size = UDim2.fromOffset(dropdown.Main.Size.X.Offset - 4, 20);
						Item.ZIndex = 9;
						Item.Text = v;
						Item.Name = v;
						Item.AutoButtonColor = false;
						Item.Font = window.theme.font;
						Item.TextSize = 15;
						Item.TextXAlignment = Enum.TextXAlignment.Left;
						Item.TextStrokeTransparency = 1;
						dropdown.ItemsFrame.CanvasSize = dropdown.ItemsFrame.CanvasSize + UDim2.fromOffset(0, Item.AbsoluteSize.Y);
						Item.MouseButton1Down:Connect(function()
							if dropdown.multichoice then
								if dropdown:isSelected(v) then
									for i2, v2 in pairs(dropdown.values) do
										if (v2 == v) then
											table.remove(dropdown.values, i2);
										end
									end
									dropdown:Set(dropdown.values);
								else
									table.insert(dropdown.values, v);
									dropdown:Set(dropdown.values);
								end
								return;
							else
								dropdown.Nav.Rotation = 90;
								dropdown.ItemsFrame.Visible = false;
								dropdown.ItemsFrame.Active = false;
								dropdown.OutlineItems.Visible = false;
								dropdown.BlackOutlineItems.Visible = false;
								dropdown.BlackOutline2Items.Visible = false;
								dropdown.IgnoreBackButtons.Visible = false;
								dropdown.IgnoreBackButtons.Active = false;
							end
							dropdown:Set(v);
							return;
						end);
						if ((dropdown.multichoice and dropdown:isSelected(v)) or (dropdown.values[1] == v)) then
							Item.BackgroundColor3 = Color3.fromRGB(64, 64, 64);
							Item.TextColor3 = window.theme.accentcolor;
							Item.Text = " " .. v;
						else
							Item.BackgroundColor3 = Color3.fromRGB(40, 40, 40);
							Item.TextColor3 = Color3.fromRGB(255, 255, 255);
							Item.Text = v;
						end
						table.insert(dropdown.items, v);
						dropdown.ItemsFrame.Size = UDim2.fromOffset(dropdown.Main.Size.X.Offset, math.clamp(#dropdown.items * Item.AbsoluteSize.Y, 20, 156) + 4);
						dropdown.ItemsFrame.CanvasSize = UDim2.fromOffset(dropdown.ItemsFrame.AbsoluteSize.X, (#dropdown.items * Item.AbsoluteSize.Y) + 4);
						dropdown.OutlineItems.Size = dropdown.ItemsFrame.Size + UDim2.fromOffset(4, 4);
						dropdown.BlackOutlineItems.Size = dropdown.ItemsFrame.Size + UDim2.fromOffset(2, 2);
						dropdown.BlackOutline2Items.Size = dropdown.ItemsFrame.Size + UDim2.fromOffset(6, 6);
						dropdown.IgnoreBackButtons.Size = dropdown.ItemsFrame.Size;
					end;
					dropdown.Remove = function(self, value)
						local item = dropdown.ItemsFrame:FindFirstChild(value);
						if item then
							for i, v in pairs(dropdown.items) do
								if (v == value) then
									table.remove(dropdown.items, i);
								end
							end
							dropdown.ItemsFrame.Size = UDim2.fromOffset(dropdown.Main.Size.X.Offset, math.clamp(#dropdown.items * item.AbsoluteSize.Y, 20, 156) + 4);
							dropdown.ItemsFrame.CanvasSize = UDim2.fromOffset(dropdown.ItemsFrame.AbsoluteSize.X, (#dropdown.items * item.AbsoluteSize.Y) + 4);
							dropdown.OutlineItems.Size = dropdown.ItemsFrame.Size + UDim2.fromOffset(2, 2);
							dropdown.BlackOutlineItems.Size = dropdown.ItemsFrame.Size + UDim2.fromOffset(4, 4);
							dropdown.BlackOutline2Items.Size = dropdown.ItemsFrame.Size + UDim2.fromOffset(6, 6);
							dropdown.IgnoreBackButtons.Size = dropdown.ItemsFrame.Size;
							item:Remove();
						end
					end;
					dropdown.getList = function(self)
						return dropdown.items;
					end;
					for i, v in pairs(dropdown.defaultitems) do
						dropdown:Add(v);
					end
					if dropdown.default then
						dropdown:Set(dropdown.default);
					end
					local MouseButton1Down = function()
						if (dropdown.Nav.Rotation == 90) then
							tweenservice:Create(dropdown.Nav, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Rotation=-90}):Play();
							if (dropdown.items and (#dropdown.items ~= 0)) then
								dropdown.ItemsFrame.ScrollingEnabled = true;
								sector.Main.Parent.ScrollingEnabled = false;
								dropdown.ItemsFrame.Visible = true;
								dropdown.ItemsFrame.Active = true;
								dropdown.IgnoreBackButtons.Visible = true;
								dropdown.IgnoreBackButtons.Active = true;
								dropdown.OutlineItems.Visible = true;
								dropdown.BlackOutlineItems.Visible = true;
								dropdown.BlackOutline2Items.Visible = true;
							end
						else
							tweenservice:Create(dropdown.Nav, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Rotation=90}):Play();
							dropdown.ItemsFrame.ScrollingEnabled = false;
							sector.Main.Parent.ScrollingEnabled = true;
							dropdown.ItemsFrame.Visible = false;
							dropdown.ItemsFrame.Active = false;
							dropdown.IgnoreBackButtons.Visible = false;
							dropdown.IgnoreBackButtons.Active = false;
							dropdown.OutlineItems.Visible = false;
							dropdown.BlackOutlineItems.Visible = false;
							dropdown.BlackOutline2Items.Visible = false;
						end
					end;
					dropdown.Main.MouseButton1Down:Connect(MouseButton1Down);
					dropdown.Nav.MouseButton1Down:Connect(MouseButton1Down);
					dropdown.BlackOutline2.MouseEnter:Connect(function()
						dropdown.BlackOutline2.BackgroundColor3 = window.theme.accentcolor;
					end);
					dropdown.BlackOutline2.MouseLeave:Connect(function()
						dropdown.BlackOutline2.BackgroundColor3 = window.theme.outlinecolor2;
					end);
					sector:FixSize();
					table.insert(library.items, dropdown);
					return dropdown;
				end;
				toggle.AddTextbox = function(self, default, callback, flag)
					local textbox = {};
					textbox.callback = callback or function()
					end;
					textbox.default = default;
					textbox.value = "";
					textbox.flag = flag or ((toggle.text or "") .. tostring(#(sector.Items:GetChildren())) .. "a");
					textbox.Holder = Instance.new("Frame", sector.Items);
					textbox.Holder.Name = "holder";
					textbox.Holder.ZIndex = 5;
					textbox.Holder.Size = UDim2.fromOffset(sector.Main.Size.X.Offset - 12, 14);
					textbox.Holder.BorderSizePixel = 0;
					textbox.Holder.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
					textbox.Gradient = Instance.new("UIGradient", textbox.Holder);
					textbox.Gradient.Rotation = 90;
					textbox.Gradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(49, 49, 49)),ColorSequenceKeypoint.new(1, Color3.fromRGB(39, 39, 39))});
					textbox.Main = Instance.new("TextBox", textbox.Holder);
					textbox.Main.PlaceholderText = "";
					textbox.Main.Text = "";
					textbox.Main.BackgroundTransparency = 1;
					textbox.Main.Font = window.theme.font;
					textbox.Main.Name = "textbox";
					textbox.Main.MultiLine = false;
					textbox.Main.ClearTextOnFocus = false;
					textbox.Main.ZIndex = 5;
					textbox.Main.TextScaled = true;
					textbox.Main.Size = textbox.Holder.Size;
					textbox.Main.TextSize = 15;
					textbox.Main.TextColor3 = Color3.fromRGB(255, 255, 255);
					textbox.Main.BorderSizePixel = 0;
					textbox.Main.BackgroundColor3 = Color3.fromRGB(30, 30, 30);
					textbox.Main.TextXAlignment = Enum.TextXAlignment.Left;
					if (textbox.flag and (textbox.flag ~= "")) then
						library.flags[textbox.flag] = textbox.default or "";
					end
					textbox.Set = function(self, text)
						textbox.value = text;
						textbox.Main.Text = text;
						if (textbox.flag and (textbox.flag ~= "")) then
							library.flags[textbox.flag] = text;
						end
						pcall(textbox.callback, text);
					end;
					updateevent.Event:Connect(function(theme)
						textbox.Main.Font = theme.font;
					end);
					textbox.Get = function(self)
						return textbox.value;
					end;
					if textbox.default then
						textbox:Set(textbox.default);
					end
					textbox.Main.FocusLost:Connect(function()
						textbox:Set(textbox.Main.Text);
					end);
					textbox.BlackOutline2 = Instance.new("Frame", textbox.Main);
					textbox.BlackOutline2.Name = "blackline";
					textbox.BlackOutline2.ZIndex = 4;
					textbox.BlackOutline2.Size = textbox.Main.Size + UDim2.fromOffset(6, 6);
					textbox.BlackOutline2.BorderSizePixel = 0;
					textbox.BlackOutline2.BackgroundColor3 = window.theme.outlinecolor2;
					textbox.BlackOutline2.Position = UDim2.fromOffset(-3, -3);
					updateevent.Event:Connect(function(theme)
						textbox.BlackOutline2.BackgroundColor3 = theme.outlinecolor2;
					end);
					textbox.Outline = Instance.new("Frame", textbox.Main);
					textbox.Outline.Name = "blackline";
					textbox.Outline.ZIndex = 4;
					textbox.Outline.Size = textbox.Main.Size + UDim2.fromOffset(4, 4);
					textbox.Outline.BorderSizePixel = 0;
					textbox.Outline.BackgroundColor3 = window.theme.outlinecolor;
					textbox.Outline.Position = UDim2.fromOffset(-2, -2);
					updateevent.Event:Connect(function(theme)
						textbox.Outline.BackgroundColor3 = theme.outlinecolor;
					end);
					textbox.BlackOutline = Instance.new("Frame", textbox.Main);
					textbox.BlackOutline.Name = "blackline";
					textbox.BlackOutline.ZIndex = 4;
					textbox.BlackOutline.Size = textbox.Main.Size + UDim2.fromOffset(2, 2);
					textbox.BlackOutline.BorderSizePixel = 0;
					textbox.BlackOutline.BackgroundColor3 = window.theme.outlinecolor2;
					textbox.BlackOutline.Position = UDim2.fromOffset(-1, -1);
					updateevent.Event:Connect(function(theme)
						textbox.BlackOutline.BackgroundColor3 = theme.outlinecolor2;
					end);
					textbox.BlackOutline2.MouseEnter:Connect(function()
						textbox.BlackOutline2.BackgroundColor3 = window.theme.accentcolor;
					end);
					textbox.BlackOutline2.MouseLeave:Connect(function()
						textbox.BlackOutline2.BackgroundColor3 = window.theme.outlinecolor2;
					end);
					sector:FixSize();
					table.insert(library.items, textbox);
					return textbox;
				end;
				toggle.AddColorpicker = function(self, default, callback, flag)
					local colorpicker = {};
					colorpicker.default = default or Color3.fromRGB(255, 255, 255);
					colorpicker.value = colorpicker.default;
					colorpicker.flag = flag or ((toggle.text or "") .. "_cp");
					colorpicker.callback = callback or function() end;
					function colorpicker:Set(val)
						colorpicker.value = val;
						if colorpicker.flag and colorpicker.flag ~= "" then
							library.flags[colorpicker.flag] = val;
						end
						pcall(colorpicker.callback, val);
					end
					function colorpicker:Get()
						return colorpicker.value;
					end
					table.insert(library.items, colorpicker);
					return colorpicker;
				end;
				toggle.AddSlider = function(self, min, default, max, decimals, callback, flag)
					local slider = {};
					slider.text = text or "";
					slider.callback = callback or function(value)
					end;
					slider.min = min or 0;
					slider.max = max or 100;
					slider.decimals = decimals or 1;
					slider.default = default or slider.min;
					slider.flag = flag or ((toggle.text or "") .. tostring(#toggle.Items:GetChildren()));
					slider.value = slider.default;
					local dragging = false;
					slider.Main = Instance.new("TextButton", sector.Items);
					slider.Main.Name = "slider";
					slider.Main.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
					slider.Main.Position = UDim2.fromOffset(0, 0);
					slider.Main.BorderSizePixel = 0;
					slider.Main.Size = UDim2.fromOffset(sector.Main.Size.X.Offset - 12, 12);
					slider.Main.AutoButtonColor = false;
					slider.Main.Text = "";
					slider.Main.ZIndex = 7;
					slider.InputLabel = Instance.new("TextLabel", slider.Main);
					slider.InputLabel.BackgroundTransparency = 1;
					slider.InputLabel.Size = slider.Main.Size;
					slider.InputLabel.Font = window.theme.font;
					slider.InputLabel.Text = "0";
					slider.InputLabel.TextColor3 = Color3.fromRGB(240, 240, 240);
					slider.InputLabel.Position = slider.Main.Position;
					slider.InputLabel.Selectable = false;
					slider.InputLabel.TextSize = 15;
					slider.InputLabel.ZIndex = 9;
					slider.InputLabel.TextStrokeTransparency = 1;
					slider.InputLabel.TextXAlignment = Enum.TextXAlignment.Center;
					updateevent.Event:Connect(function(theme)
						slider.InputLabel.Font = theme.font;
						slider.InputLabel.TextColor3 = theme.itemscolor;
					end);
					slider.BlackOutline2 = Instance.new("Frame", slider.Main);
					slider.BlackOutline2.Name = "blackline";
					slider.BlackOutline2.ZIndex = 4;
					slider.BlackOutline2.Size = slider.Main.Size + UDim2.fromOffset(6, 6);
					slider.BlackOutline2.BorderSizePixel = 0;
					slider.BlackOutline2.BackgroundColor3 = window.theme.outlinecolor2;
					slider.BlackOutline2.Position = UDim2.fromOffset(-3, -3);
					updateevent.Event:Connect(function(theme)
						slider.BlackOutline2.BackgroundColor3 = theme.outlinecolor2;
					end);
					slider.Outline = Instance.new("Frame", slider.Main);
					slider.Outline.Name = "blackline";
					slider.Outline.ZIndex = 4;
					slider.Outline.Size = slider.Main.Size + UDim2.fromOffset(4, 4);
					slider.Outline.BorderSizePixel = 0;
					slider.Outline.BackgroundColor3 = window.theme.outlinecolor;
					slider.Outline.Position = UDim2.fromOffset(-2, -2);
					updateevent.Event:Connect(function(theme)
						slider.Outline.BackgroundColor3 = theme.outlinecolor;
					end);
					slider.BlackOutline = Instance.new("Frame", slider.Main);
					slider.BlackOutline.Name = "blackline";
					slider.BlackOutline.ZIndex = 4;
					slider.BlackOutline.Size = slider.Main.Size + UDim2.fromOffset(2, 2);
					slider.BlackOutline.BorderSizePixel = 0;
					slider.BlackOutline.BackgroundColor3 = window.theme.outlinecolor2;
					slider.BlackOutline.Position = UDim2.fromOffset(-1, -1);
					updateevent.Event:Connect(function(theme)
						slider.BlackOutline.BackgroundColor3 = theme.outlinecolor2;
					end);
					slider.Gradient = Instance.new("UIGradient", slider.Main);
					slider.Gradient.Rotation = 90;
					slider.Gradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(49, 49, 49)),ColorSequenceKeypoint.new(1, Color3.fromRGB(41, 41, 41))});
					slider.SlideBar = Instance.new("Frame", slider.Main);
					slider.SlideBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
					slider.SlideBar.ZIndex = 8;
					slider.SlideBar.BorderSizePixel = 0;
					slider.SlideBar.Size = UDim2.fromOffset(0, slider.Main.Size.Y.Offset);
					slider.Gradient2 = Instance.new("UIGradient", slider.SlideBar);
					slider.Gradient2.Rotation = 90;
					slider.Gradient2.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, window.theme.accentcolor),ColorSequenceKeypoint.new(1, window.theme.accentcolor2)});
					updateevent.Event:Connect(function(theme)
						slider.Gradient2.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, theme.accentcolor),ColorSequenceKeypoint.new(1, theme.accentcolor2)});
					end);
					slider.BlackOutline2.MouseEnter:Connect(function()
						slider.BlackOutline2.BackgroundColor3 = window.theme.accentcolor;
					end);
					slider.BlackOutline2.MouseLeave:Connect(function()
						slider.BlackOutline2.BackgroundColor3 = window.theme.outlinecolor2;
					end);
					if (slider.flag and (slider.flag ~= "")) then
						library.flags[slider.flag] = slider.default or slider.min or 0;
					end
					slider.Get = function(self)
						return slider.value;
					end;
					slider.Set = function(self, value)
						slider.value = math.clamp(math.round(value * slider.decimals) / slider.decimals, slider.min, slider.max);
						local percent = 1 - ((slider.max - slider.value) / (slider.max - slider.min));
						if (slider.flag and (slider.flag ~= "")) then
							library.flags[slider.flag] = slider.value;
						end
						slider.SlideBar:TweenSize(UDim2.fromOffset(percent * slider.Main.Size.X.Offset, slider.Main.Size.Y.Offset), Enum.EasingDirection.In, Enum.EasingStyle.Sine, 0.05);
						slider.InputLabel.Text = slider.value;
						pcall(slider.callback, slider.value);
					end;
					slider:Set(slider.default);
					slider.Refresh = function(self, inputX)
						local posX = inputX or (mouse and mouse.X) or 0;
						local width = math.max(slider.Main.AbsoluteSize.X, 1);
						local percent = math.clamp(posX - slider.Main.AbsolutePosition.X, 0, width) / width;
						local value = math.floor((slider.min + ((slider.max - slider.min) * percent)) * slider.decimals) / slider.decimals;
						value = math.clamp(value, slider.min, slider.max);
						slider:Set(value);
					end;
					local function startSlide(input)
						if (input.UserInputType == Enum.UserInputType.MouseButton1) or (input.UserInputType == Enum.UserInputType.Touch) then
							dragging = true;
							pcall(function() sector.Main.Parent.ScrollingEnabled = false end);
							slider:Refresh(input.Position and input.Position.X);
						end
					end
					local function endSlide(input)
						if (input.UserInputType == Enum.UserInputType.MouseButton1) or (input.UserInputType == Enum.UserInputType.Touch) then
							dragging = false;
							pcall(function() sector.Main.Parent.ScrollingEnabled = true end);
						end
					end
					slider.SlideBar.InputBegan:Connect(startSlide);
					slider.SlideBar.InputEnded:Connect(endSlide);
					slider.Main.InputBegan:Connect(startSlide);
					slider.Main.InputEnded:Connect(endSlide);
					uis.InputChanged:Connect(function(input)
						if dragging and ((input.UserInputType == Enum.UserInputType.MouseMovement) or (input.UserInputType == Enum.UserInputType.Touch)) then
							slider:Refresh(input.Position and input.Position.X);
						end
					end);
					sector:FixSize();
					table.insert(library.items, slider);
					return slider;
				end;
				local lastToggleTime = 0;
				local function onToggleTrigger()
					local now = tick();
					if (now - lastToggleTime) < 0.18 then return end;
					lastToggleTime = now;
					toggle:Set(not toggle.CheckedFrame.Visible);
				end
				toggle.Main.Activated:Connect(onToggleTrigger);
				toggle.Main.MouseButton1Click:Connect(onToggleTrigger);
				toggle.Label.Activated:Connect(onToggleTrigger);
				toggle.Label.MouseButton1Click:Connect(onToggleTrigger);
				local MouseEnter = function()
					toggle.BlackOutline2.BackgroundColor3 = window.theme.accentcolor;
				end;
				local MouseLeave = function()
					toggle.BlackOutline2.BackgroundColor3 = window.theme.outlinecolor2;
				end;
				toggle.Label.MouseEnter:Connect(MouseEnter);
				toggle.Label.MouseLeave:Connect(MouseLeave);
				toggle.BlackOutline2.MouseEnter:Connect(MouseEnter);
				toggle.BlackOutline2.MouseLeave:Connect(MouseLeave);
				sector:FixSize();
				table.insert(library.items, toggle);
				return toggle;
			end;
			sector.AddTextbox = function(self, text, default, callback, flag)
				local textbox = {};
				textbox.text = text or "";
				textbox.callback = callback or function()
				end;
				textbox.default = default;
				textbox.value = "";
				textbox.flag = flag or text or "";
				textbox.Label = Instance.new("TextButton", sector.Items);
				textbox.Label.Name = "Label";
				textbox.Label.AutoButtonColor = false;
				textbox.Label.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
				textbox.Label.BackgroundTransparency = 1;
				textbox.Label.Position = UDim2.fromOffset(sector.Main.Size.X.Offset, 0);
				textbox.Label.Size = UDim2.fromOffset(sector.Main.Size.X.Offset - 12, 0);
				textbox.Label.Font = window.theme.font;
				textbox.Label.ZIndex = 5;
				textbox.Label.Text = textbox.text;
				textbox.Label.TextColor3 = window.theme.itemscolor;
				textbox.Label.TextSize = 15;
				textbox.Label.TextStrokeTransparency = 1;
				textbox.Label.TextXAlignment = Enum.TextXAlignment.Left;
				updateevent.Event:Connect(function(theme)
					textbox.Label.Font = theme.font;
				end);
				textbox.Holder = Instance.new("Frame", sector.Items);
				textbox.Holder.Name = "holder";
				textbox.Holder.ZIndex = 5;
				textbox.Holder.Size = UDim2.fromOffset(sector.Main.Size.X.Offset - 12, 14);
				textbox.Holder.BorderSizePixel = 0;
				textbox.Holder.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
				textbox.Gradient = Instance.new("UIGradient", textbox.Holder);
				textbox.Gradient.Rotation = 90;
				textbox.Gradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(49, 49, 49)),ColorSequenceKeypoint.new(1, Color3.fromRGB(39, 39, 39))});
				textbox.Main = Instance.new("TextBox", textbox.Holder);
				textbox.Main.PlaceholderText = textbox.text;
				textbox.Main.PlaceholderColor3 = Color3.fromRGB(190, 190, 190);
				textbox.Main.Text = "";
				textbox.Main.BackgroundTransparency = 1;
				textbox.Main.Font = window.theme.font;
				textbox.Main.Name = "textbox";
				textbox.Main.MultiLine = false;
				textbox.Main.ClearTextOnFocus = false;
				textbox.Main.ZIndex = 5;
				textbox.Main.TextScaled = true;
				textbox.Main.Size = textbox.Holder.Size;
				textbox.Main.TextSize = 15;
				textbox.Main.TextColor3 = Color3.fromRGB(255, 255, 255);
				textbox.Main.BorderSizePixel = 0;
				textbox.Main.BackgroundColor3 = Color3.fromRGB(30, 30, 30);
				textbox.Main.TextXAlignment = Enum.TextXAlignment.Left;
				if (textbox.flag and (textbox.flag ~= "")) then
					library.flags[textbox.flag] = textbox.default or "";
				end
				textbox.Set = function(self, text)
					textbox.value = text;
					textbox.Main.Text = text;
					if (textbox.flag and (textbox.flag ~= "")) then
						library.flags[textbox.flag] = text;
					end
					pcall(textbox.callback, text);
				end;
				updateevent.Event:Connect(function(theme)
					textbox.Main.Font = theme.font;
				end);
				textbox.Get = function(self)
					return textbox.value;
				end;
				if textbox.default then
					textbox:Set(textbox.default);
				end
				textbox.Main.FocusLost:Connect(function()
					textbox:Set(textbox.Main.Text);
				end);
				textbox.BlackOutline2 = Instance.new("Frame", textbox.Main);
				textbox.BlackOutline2.Name = "blackline";
				textbox.BlackOutline2.ZIndex = 4;
				textbox.BlackOutline2.Size = textbox.Main.Size + UDim2.fromOffset(6, 6);
				textbox.BlackOutline2.BorderSizePixel = 0;
				textbox.BlackOutline2.BackgroundColor3 = window.theme.outlinecolor2;
				textbox.BlackOutline2.Position = UDim2.fromOffset(-3, -3);
				updateevent.Event:Connect(function(theme)
					textbox.BlackOutline2.BackgroundColor3 = theme.outlinecolor2;
				end);
				textbox.Outline = Instance.new("Frame", textbox.Main);
				textbox.Outline.Name = "blackline";
				textbox.Outline.ZIndex = 4;
				textbox.Outline.Size = textbox.Main.Size + UDim2.fromOffset(4, 4);
				textbox.Outline.BorderSizePixel = 0;
				textbox.Outline.BackgroundColor3 = window.theme.outlinecolor;
				textbox.Outline.Position = UDim2.fromOffset(-2, -2);
				updateevent.Event:Connect(function(theme)
					textbox.Outline.BackgroundColor3 = theme.outlinecolor;
				end);
				textbox.BlackOutline = Instance.new("Frame", textbox.Main);
				textbox.BlackOutline.Name = "blackline";
				textbox.BlackOutline.ZIndex = 4;
				textbox.BlackOutline.Size = textbox.Main.Size + UDim2.fromOffset(2, 2);
				textbox.BlackOutline.BorderSizePixel = 0;
				textbox.BlackOutline.BackgroundColor3 = window.theme.outlinecolor2;
				textbox.BlackOutline.Position = UDim2.fromOffset(-1, -1);
				updateevent.Event:Connect(function(theme)
					textbox.BlackOutline.BackgroundColor3 = theme.outlinecolor2;
				end);
				textbox.BlackOutline2.MouseEnter:Connect(function()
					textbox.BlackOutline2.BackgroundColor3 = window.theme.accentcolor;
				end);
				textbox.BlackOutline2.MouseLeave:Connect(function()
					textbox.BlackOutline2.BackgroundColor3 = window.theme.outlinecolor2;
				end);
				sector:FixSize();
				table.insert(library.items, textbox);
				return textbox;
			end;
			sector.AddSlider = function(self, text, min, default, max, decimals, callback, flag)
				local slider = {};
				slider.text = text or "";
				slider.callback = callback or function(value)
				end;
				slider.min = min or 0;
				slider.max = max or 100;
				slider.decimals = decimals or 1;
				slider.default = default or slider.min;
				slider.flag = flag or text or "";
				slider.value = slider.default;
				local dragging = false;
				slider.MainBack = Instance.new("Frame", sector.Items);
				slider.MainBack.Name = "MainBack";
				slider.MainBack.ZIndex = 7;
				slider.MainBack.Size = UDim2.fromOffset(sector.Main.Size.X.Offset - 12, 25);
				slider.MainBack.BorderSizePixel = 0;
				slider.MainBack.BackgroundTransparency = 1;
				slider.Label = Instance.new("TextLabel", slider.MainBack);
				slider.Label.BackgroundTransparency = 1;
				slider.Label.Size = UDim2.fromOffset(sector.Main.Size.X.Offset - 12, 6);
				slider.Label.Font = window.theme.font;
				slider.Label.Text = slider.text .. ":";
				slider.Label.TextColor3 = window.theme.itemscolor;
				slider.Label.Position = UDim2.fromOffset(0, 0);
				slider.Label.TextSize = 15;
				slider.Label.ZIndex = 4;
				slider.Label.TextStrokeTransparency = 1;
				slider.Label.TextXAlignment = Enum.TextXAlignment.Left;
				updateevent.Event:Connect(function(theme)
					slider.Label.Font = theme.font;
					slider.Label.TextColor3 = theme.itemscolor;
				end);
				local size = textservice:GetTextSize(slider.Label.Text, slider.Label.TextSize, slider.Label.Font, Vector2.new(200, 300));
				slider.InputLabel = Instance.new("TextBox", slider.MainBack);
				slider.InputLabel.BackgroundTransparency = 1;
				slider.InputLabel.ClearTextOnFocus = false;
				slider.InputLabel.Size = UDim2.fromOffset((sector.Main.Size.X.Offset - size.X) - 15, 12);
				slider.InputLabel.Font = window.theme.font;
				slider.InputLabel.Text = "0";
				slider.InputLabel.TextColor3 = window.theme.itemscolor;
				slider.InputLabel.Position = UDim2.fromOffset(size.X + 3, -3);
				slider.InputLabel.TextSize = 15;
				slider.InputLabel.ZIndex = 4;
				slider.InputLabel.TextStrokeTransparency = 1;
				slider.InputLabel.TextXAlignment = Enum.TextXAlignment.Left;
				updateevent.Event:Connect(function(theme)
					slider.InputLabel.Font = theme.font;
					slider.InputLabel.TextColor3 = theme.itemscolor;
					local size = textservice:GetTextSize(slider.Label.Text, slider.Label.TextSize, slider.Label.Font, Vector2.new(200, 300));
					slider.InputLabel.Size = UDim2.fromOffset((sector.Main.Size.X.Offset - size.X) - 15, 12);
				end);
				slider.Main = Instance.new("TextButton", slider.MainBack);
				slider.Main.Name = "slider";
				slider.Main.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
				slider.Main.Position = UDim2.fromOffset(0, 15);
				slider.Main.BorderSizePixel = 0;
				slider.Main.Size = UDim2.fromOffset(sector.Main.Size.X.Offset - 12, 12);
				slider.Main.AutoButtonColor = false;
				slider.Main.Text = "";
				slider.Main.ZIndex = 5;
				slider.BlackOutline2 = Instance.new("Frame", slider.Main);
				slider.BlackOutline2.Name = "blackline";
				slider.BlackOutline2.ZIndex = 4;
				slider.BlackOutline2.Size = slider.Main.Size + UDim2.fromOffset(6, 6);
				slider.BlackOutline2.BorderSizePixel = 0;
				slider.BlackOutline2.BackgroundColor3 = window.theme.outlinecolor2;
				slider.BlackOutline2.Position = UDim2.fromOffset(-3, -3);
				updateevent.Event:Connect(function(theme)
					slider.BlackOutline2.BackgroundColor3 = theme.outlinecolor2;
				end);
				slider.Outline = Instance.new("Frame", slider.Main);
				slider.Outline.Name = "blackline";
				slider.Outline.ZIndex = 4;
				slider.Outline.Size = slider.Main.Size + UDim2.fromOffset(4, 4);
				slider.Outline.BorderSizePixel = 0;
				slider.Outline.BackgroundColor3 = window.theme.outlinecolor;
				slider.Outline.Position = UDim2.fromOffset(-2, -2);
				updateevent.Event:Connect(function(theme)
					slider.Outline.BackgroundColor3 = theme.outlinecolor;
				end);
				slider.BlackOutline = Instance.new("Frame", slider.Main);
				slider.BlackOutline.Name = "blackline";
				slider.BlackOutline.ZIndex = 4;
				slider.BlackOutline.Size = slider.Main.Size + UDim2.fromOffset(2, 2);
				slider.BlackOutline.BorderSizePixel = 0;
				slider.BlackOutline.BackgroundColor3 = window.theme.outlinecolor2;
				slider.BlackOutline.Position = UDim2.fromOffset(-1, -1);
				updateevent.Event:Connect(function(theme)
					slider.BlackOutline.BackgroundColor3 = theme.outlinecolor2;
				end);
				slider.Gradient = Instance.new("UIGradient", slider.Main);
				slider.Gradient.Rotation = 90;
				slider.Gradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(49, 49, 49)),ColorSequenceKeypoint.new(1, Color3.fromRGB(41, 41, 41))});
				slider.SlideBar = Instance.new("Frame", slider.Main);
				slider.SlideBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
				slider.SlideBar.ZIndex = 5;
				slider.SlideBar.BorderSizePixel = 0;
				slider.SlideBar.Size = UDim2.fromOffset(0, slider.Main.Size.Y.Offset);
				slider.Gradient2 = Instance.new("UIGradient", slider.SlideBar);
				slider.Gradient2.Rotation = 90;
				slider.Gradient2.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, window.theme.accentcolor),ColorSequenceKeypoint.new(1, window.theme.accentcolor2)});
				updateevent.Event:Connect(function(theme)
					slider.Gradient2.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, theme.accentcolor),ColorSequenceKeypoint.new(1, theme.accentcolor2)});
				end);
				slider.BlackOutline2.MouseEnter:Connect(function()
					slider.BlackOutline2.BackgroundColor3 = window.theme.accentcolor;
				end);
				slider.BlackOutline2.MouseLeave:Connect(function()
					slider.BlackOutline2.BackgroundColor3 = window.theme.outlinecolor2;
				end);
				if (slider.flag and (slider.flag ~= "")) then
					library.flags[slider.flag] = slider.default or slider.min or 0;
				end
				slider.Get = function(self)
					return slider.value;
				end;
				slider.Set = function(self, value)
					local dec = (slider.decimals and slider.decimals > 0) and slider.decimals or 1;
					local rounded = (dec < 1) and (math.round(value / dec) * dec) or (math.round(value * dec) / dec);
					slider.value = tonumber(string.format("%.4f", math.clamp(rounded, slider.min, slider.max))) or slider.min;
					local percent = 1 - ((slider.max - slider.value) / (slider.max - slider.min));
					if (slider.flag and (slider.flag ~= "")) then
						library.flags[slider.flag] = slider.value;
					end
					slider.SlideBar:TweenSize(UDim2.fromOffset(percent * slider.Main.Size.X.Offset, slider.Main.Size.Y.Offset), Enum.EasingDirection.In, Enum.EasingStyle.Sine, 0.05);
					slider.InputLabel.Text = slider.value;
					pcall(slider.callback, slider.value);
				end;
				slider:Set(slider.default);
				slider.InputLabel.FocusLost:Connect(function(Return)
					if not Return then
						return;
					end
					local numVal = tonumber(slider.InputLabel.Text);
					if numVal then
						slider:Set(numVal);
					else
						slider.InputLabel.Text = tostring(slider.value);
					end
				end);
				slider.Refresh = function(self, inputX)
					local dec = (slider.decimals and slider.decimals > 0) and slider.decimals or 1;
					local posX = inputX or (mouse and mouse.X) or 0;
					local width = math.max(slider.Main.AbsoluteSize.X, 1);
					local percent = math.clamp(posX - slider.Main.AbsolutePosition.X, 0, width) / width;
					local rawVal = slider.min + ((slider.max - slider.min) * percent);
					local rounded = (dec < 1) and (math.round(rawVal / dec) * dec) or (math.round(rawVal * dec) / dec);
					local value = tonumber(string.format("%.4f", math.clamp(rounded, slider.min, slider.max))) or slider.min;
					slider:Set(value);
				end;
				local function startSliderDrag(input)
					if (input.UserInputType == Enum.UserInputType.MouseButton1) or (input.UserInputType == Enum.UserInputType.Touch) then
						dragging = true;
						pcall(function() sector.Main.Parent.ScrollingEnabled = false end);
						slider:Refresh(input.Position and input.Position.X);
					end
				end
				local function endSliderDrag(input)
					if (input.UserInputType == Enum.UserInputType.MouseButton1) or (input.UserInputType == Enum.UserInputType.Touch) then
						dragging = false;
						pcall(function() sector.Main.Parent.ScrollingEnabled = true end);
					end
				end
				slider.SlideBar.InputBegan:Connect(startSliderDrag);
				slider.SlideBar.InputEnded:Connect(endSliderDrag);
				slider.Main.InputBegan:Connect(startSliderDrag);
				slider.Main.InputEnded:Connect(endSliderDrag);
				uis.InputEnded:Connect(endSliderDrag);
				uis.InputChanged:Connect(function(input)
					if dragging and ((input.UserInputType == Enum.UserInputType.MouseMovement) or (input.UserInputType == Enum.UserInputType.Touch)) then
						slider:Refresh(input.Position and input.Position.X);
					end
				end);
				sector:FixSize();
				table.insert(library.items, slider);
				return slider;
			end;
			sector.AddColorpicker = function(self, text, default, callback, flag)
				local colorpicker = {};
				colorpicker.text = text or "";
				colorpicker.default = default or Color3.fromRGB(255, 255, 255);
				colorpicker.value = colorpicker.default;
				colorpicker.flag = flag or text or "";
				colorpicker.callback = callback or function() end;
				function colorpicker:Set(val)
					colorpicker.value = val;
					if colorpicker.flag and colorpicker.flag ~= "" then
						library.flags[colorpicker.flag] = val;
					end
					pcall(colorpicker.callback, val);
				end
				function colorpicker:Get()
					return colorpicker.value;
				end
				table.insert(library.items, colorpicker);
				return colorpicker;
			end;
			sector.AddKeybind = function(self, text, default, newkeycallback, callback, flag)
				local keybind = {};
				keybind.text = text or "";
				keybind.default = default or "None";
				keybind.callback = callback or function()
				end;
				keybind.newkeycallback = newkeycallback or function(key)
				end;
				keybind.flag = flag or text or "";
				keybind.value = keybind.default;
				keybind.Main = Instance.new("TextLabel", sector.Items);
				keybind.Main.BackgroundTransparency = 1;
				keybind.Main.Size = UDim2.fromOffset(156, 10);
				keybind.Main.ZIndex = 4;
				keybind.Main.Font = window.theme.font;
				keybind.Main.Text = keybind.text;
				keybind.Main.TextColor3 = window.theme.itemscolor;
				keybind.Main.TextSize = 15;
				keybind.Main.TextStrokeTransparency = 1;
				keybind.Main.TextXAlignment = Enum.TextXAlignment.Left;
				updateevent.Event:Connect(function(theme)
					keybind.Main.Font = theme.font;
					keybind.Main.TextColor3 = theme.itemscolor;
				end);
				keybind.Bind = Instance.new("TextButton", keybind.Main);
				keybind.Bind.Name = "keybind";
				keybind.Bind.BackgroundTransparency = 1;
				keybind.Bind.BorderColor3 = window.theme.outlinecolor;
				keybind.Bind.ZIndex = 5;
				keybind.Bind.BorderSizePixel = 0;
				keybind.Bind.Position = UDim2.fromOffset(sector.Main.Size.X.Offset - 10, 0);
				keybind.Bind.Font = window.theme.font;
				keybind.Bind.TextColor3 = Color3.fromRGB(136, 136, 136);
				keybind.Bind.TextSize = 15;
				keybind.Bind.TextXAlignment = Enum.TextXAlignment.Right;
				keybind.Bind.MouseButton1Down:Connect(function()
					keybind.Bind.Text = "[...]";
					keybind.Bind.TextColor3 = window.theme.accentcolor;
				end);
				updateevent.Event:Connect(function(theme)
					keybind.Bind.BorderColor3 = theme.outlinecolor;
					keybind.Bind.Font = theme.font;
				end);
				if (keybind.flag and (keybind.flag ~= "")) then
					library.flags[keybind.flag] = keybind.default;
				end
				local shorter_keycodes = {LeftShift="LSHIFT",RightShift="RSHIFT",LeftControl="LCTRL",RightControl="RCTRL",LeftAlt="LALT",RightAlt="RALT"};
				keybind.Set = function(self, value)
					if (value == "None") then
						keybind.value = value;
						keybind.Bind.Text = "[" .. value .. "]";
						local size = textservice:GetTextSize(keybind.Bind.Text, keybind.Bind.TextSize, keybind.Bind.Font, Vector2.new(2000, 2000));
						keybind.Bind.Size = UDim2.fromOffset(size.X, size.Y);
						keybind.Bind.Position = UDim2.fromOffset((sector.Main.Size.X.Offset - 10) - keybind.Bind.AbsoluteSize.X, 0);
						if (keybind.flag and (keybind.flag ~= "")) then
							library.flags[keybind.flag] = value;
						end
						pcall(keybind.newkeycallback, value);
					end
					keybind.value = value;
					keybind.Bind.Text = "[" .. (shorter_keycodes[value.Name or value] or value.Name or value) .. "]";
					local size = textservice:GetTextSize(keybind.Bind.Text, keybind.Bind.TextSize, keybind.Bind.Font, Vector2.new(2000, 2000));
					keybind.Bind.Size = UDim2.fromOffset(size.X, size.Y);
					keybind.Bind.Position = UDim2.fromOffset((sector.Main.Size.X.Offset - 10) - keybind.Bind.AbsoluteSize.X, 0);
					if (keybind.flag and (keybind.flag ~= "")) then
						library.flags[keybind.flag] = value;
					end
					pcall(keybind.newkeycallback, value);
				end;
				keybind:Set((keybind.default and keybind.default) or "None");
				keybind.Get = function(self)
					return keybind.value;
				end;
				uis.InputBegan:Connect(function(input, gameProcessed)
					if not gameProcessed then
						if (keybind.Bind.Text == "[...]") then
							keybind.Bind.TextColor3 = Color3.fromRGB(136, 136, 136);
							if (input.UserInputType == Enum.UserInputType.Keyboard) then
								keybind:Set(input.KeyCode);
							else
								keybind:Set("None");
							end
						elseif ((keybind.value ~= "None") and (input.KeyCode == keybind.value)) then
							pcall(keybind.callback);
						end
					end
				end);
				sector:FixSize();
				table.insert(library.items, keybind);
				return keybind;
			end;
			sector.AddDropdown = function(self, text, items, default, multichoice, callback, flag)
				local dropdown = {};
				dropdown.text = text or "";
				dropdown.defaultitems = items or {};
				dropdown.default = default;
				dropdown.callback = callback or function()
				end;
				dropdown.multichoice = multichoice or false;
				dropdown.values = {};
				dropdown.flag = flag or text or "";
				dropdown.MainBack = Instance.new("Frame", sector.Items);
				dropdown.MainBack.Name = "backlabel";
				dropdown.MainBack.ZIndex = 7;
				dropdown.MainBack.Size = UDim2.fromOffset(sector.Main.Size.X.Offset - 12, 34);
				dropdown.MainBack.BorderSizePixel = 0;
				dropdown.MainBack.BackgroundTransparency = 1;
				dropdown.Label = Instance.new("TextLabel", dropdown.MainBack);
				dropdown.Label.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
				dropdown.Label.BackgroundTransparency = 1;
				dropdown.Label.Size = UDim2.fromOffset(sector.Main.Size.X.Offset - 12, 10);
				dropdown.Label.Position = UDim2.fromOffset(0, 0);
				dropdown.Label.Font = window.theme.font;
				dropdown.Label.Text = dropdown.text;
				dropdown.Label.ZIndex = 4;
				dropdown.Label.TextColor3 = window.theme.itemscolor;
				dropdown.Label.TextSize = 15;
				dropdown.Label.TextStrokeTransparency = 1;
				dropdown.Label.TextXAlignment = Enum.TextXAlignment.Left;
				updateevent.Event:Connect(function(theme)
					dropdown.Label.Font = theme.font;
					dropdown.Label.TextColor3 = theme.itemscolor;
				end);
				dropdown.Main = Instance.new("TextButton", dropdown.MainBack);
				dropdown.Main.Name = "dropdown";
				dropdown.Main.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
				dropdown.Main.BorderSizePixel = 0;
				dropdown.Main.Size = UDim2.fromOffset(sector.Main.Size.X.Offset - 12, 16);
				dropdown.Main.Position = UDim2.fromOffset(0, 17);
				dropdown.Main.ZIndex = 5;
				dropdown.Main.AutoButtonColor = false;
				dropdown.Main.Font = window.theme.font;
				dropdown.Main.Text = "";
				dropdown.Main.TextColor3 = Color3.fromRGB(255, 255, 255);
				dropdown.Main.TextSize = 15;
				dropdown.Main.TextXAlignment = Enum.TextXAlignment.Left;
				dropdown.Main.Active = true;
				updateevent.Event:Connect(function(theme)
					dropdown.Main.Font = theme.font;
				end);
				dropdown.Gradient = Instance.new("UIGradient", dropdown.Main);
				dropdown.Gradient.Rotation = 90;
				dropdown.Gradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(49, 49, 49)),ColorSequenceKeypoint.new(1, Color3.fromRGB(39, 39, 39))});
				dropdown.SelectedLabel = Instance.new("TextLabel", dropdown.Main);
				dropdown.SelectedLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
				dropdown.SelectedLabel.BackgroundTransparency = 1;
				dropdown.SelectedLabel.Position = UDim2.fromOffset(5, 0);
				dropdown.SelectedLabel.Size = UDim2.new(1, -26, 1, 0);
				dropdown.SelectedLabel.Font = window.theme.font;
				dropdown.SelectedLabel.Text = dropdown.text;
				dropdown.SelectedLabel.ZIndex = 5;
				dropdown.SelectedLabel.TextColor3 = Color3.fromRGB(255, 255, 255);
				dropdown.SelectedLabel.TextSize = 15;
				dropdown.SelectedLabel.TextStrokeTransparency = 1;
				dropdown.SelectedLabel.TextXAlignment = Enum.TextXAlignment.Left;
				dropdown.SelectedLabel.TextYAlignment = Enum.TextYAlignment.Center;
				dropdown.SelectedLabel.TextTruncate = Enum.TextTruncate.AtEnd;
				dropdown.SelectedLabel.Active = false;
				updateevent.Event:Connect(function(theme)
					dropdown.SelectedLabel.Font = theme.font;
				end);
				dropdown.Nav = Instance.new("ImageButton", dropdown.Main);
				dropdown.Nav.Name = "navigation";
				dropdown.Nav.BackgroundTransparency = 1;
				dropdown.Nav.LayoutOrder = 10;
				dropdown.Nav.Position = UDim2.new(1, -14, 0.5, -4);
				dropdown.Nav.Rotation = 90;
				dropdown.Nav.ZIndex = 5;
				dropdown.Nav.Size = UDim2.fromOffset(8, 8);
				dropdown.Nav.Image = "rbxassetid://4918373417";
				dropdown.Nav.ImageColor3 = Color3.fromRGB(210, 210, 210);
				dropdown.Nav.Active = true;
				dropdown.BlackOutline2 = Instance.new("Frame", dropdown.Main);
				dropdown.BlackOutline2.Name = "blackline";
				dropdown.BlackOutline2.ZIndex = 4;
				dropdown.BlackOutline2.Size = dropdown.Main.Size + UDim2.fromOffset(6, 6);
				dropdown.BlackOutline2.BorderSizePixel = 0;
				dropdown.BlackOutline2.BackgroundColor3 = window.theme.outlinecolor2;
				dropdown.BlackOutline2.Position = UDim2.fromOffset(-3, -3);
				updateevent.Event:Connect(function(theme)
					dropdown.BlackOutline2.BackgroundColor3 = theme.outlinecolor2;
				end);
				dropdown.Outline = Instance.new("Frame", dropdown.Main);
				dropdown.Outline.Name = "blackline";
				dropdown.Outline.ZIndex = 4;
				dropdown.Outline.Size = dropdown.Main.Size + UDim2.fromOffset(4, 4);
				dropdown.Outline.BorderSizePixel = 0;
				dropdown.Outline.BackgroundColor3 = window.theme.outlinecolor;
				dropdown.Outline.Position = UDim2.fromOffset(-2, -2);
				updateevent.Event:Connect(function(theme)
					dropdown.Outline.BackgroundColor3 = theme.outlinecolor;
				end);
				dropdown.BlackOutline = Instance.new("Frame", dropdown.Main);
				dropdown.BlackOutline.Name = "blackline";
				dropdown.BlackOutline.ZIndex = 4;
				dropdown.BlackOutline.Size = dropdown.Main.Size + UDim2.fromOffset(2, 2);
				dropdown.BlackOutline.BorderSizePixel = 0;
				dropdown.BlackOutline.BackgroundColor3 = window.theme.outlinecolor2;
				dropdown.BlackOutline.Position = UDim2.fromOffset(-1, -1);
				updateevent.Event:Connect(function(theme)
					dropdown.BlackOutline.BackgroundColor3 = theme.outlinecolor2;
				end);

				-- FLOATING POPUP PARENTED DIRECTLY TO window.Frame FOR RELIABLE MOBILE TOUCH & SCROLLING
				dropdown.BlackOutline2Items = Instance.new("Frame", window.Frame);
				dropdown.BlackOutline2Items.Name = "dropdown_blackline2";
				dropdown.BlackOutline2Items.ZIndex = 111;
				dropdown.BlackOutline2Items.BorderSizePixel = 0;
				dropdown.BlackOutline2Items.BackgroundColor3 = window.theme.outlinecolor2;
				dropdown.BlackOutline2Items.Visible = false;
				updateevent.Event:Connect(function(theme)
					dropdown.BlackOutline2Items.BackgroundColor3 = theme.outlinecolor2;
				end);

				dropdown.OutlineItems = Instance.new("Frame", window.Frame);
				dropdown.OutlineItems.Name = "dropdown_outline";
				dropdown.OutlineItems.ZIndex = 112;
				dropdown.OutlineItems.BorderSizePixel = 0;
				dropdown.OutlineItems.BackgroundColor3 = window.theme.outlinecolor;
				dropdown.OutlineItems.Visible = false;
				updateevent.Event:Connect(function(theme)
					dropdown.OutlineItems.BackgroundColor3 = theme.outlinecolor;
				end);

				dropdown.BlackOutlineItems = Instance.new("Frame", window.Frame);
				dropdown.BlackOutlineItems.Name = "dropdown_blackline";
				dropdown.BlackOutlineItems.ZIndex = 113;
				dropdown.BlackOutlineItems.BorderSizePixel = 0;
				dropdown.BlackOutlineItems.BackgroundColor3 = window.theme.outlinecolor2;
				dropdown.BlackOutlineItems.Visible = false;
				updateevent.Event:Connect(function(theme)
					dropdown.BlackOutlineItems.BackgroundColor3 = theme.outlinecolor2;
				end);

				local isMobile = (uis.TouchEnabled and not uis.MouseEnabled);
				dropdown.ItemsFrame = Instance.new("ScrollingFrame", window.Frame);
				dropdown.ItemsFrame.Name = "dropdown_itemsframe";
				dropdown.ItemsFrame.BorderSizePixel = 0;
				dropdown.ItemsFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40);
				dropdown.ItemsFrame.ScrollBarThickness = isMobile and 10 or 8;
				dropdown.ItemsFrame.ScrollBarImageColor3 = library.theme.accentcolor;
				dropdown.ItemsFrame.ZIndex = 120;
				dropdown.ItemsFrame.ScrollingDirection = Enum.ScrollingDirection.Y;
				dropdown.ItemsFrame.Visible = false;
				dropdown.ItemsFrame.Active = true;
				dropdown.ItemsFrame.ScrollingEnabled = true;
				dropdown.ItemsFrame.CanvasSize = UDim2.fromOffset(0, 0);

				dropdown.ListLayout = Instance.new("UIListLayout", dropdown.ItemsFrame);
				dropdown.ListLayout.FillDirection = Enum.FillDirection.Vertical;
				dropdown.ListLayout.SortOrder = Enum.SortOrder.LayoutOrder;
				dropdown.ListPadding = Instance.new("UIPadding", dropdown.ItemsFrame);
				dropdown.ListPadding.PaddingTop = UDim.new(0, 2);
				dropdown.ListPadding.PaddingBottom = UDim.new(0, 2);
				dropdown.ListPadding.PaddingLeft = UDim.new(0, 2);
				dropdown.ListPadding.PaddingRight = UDim.new(0, isMobile and 12 or 8);

				if (dropdown.flag and (dropdown.flag ~= "")) then
					library.flags[dropdown.flag] = (dropdown.multichoice and {(dropdown.default or dropdown.defaultitems[1] or "")}) or dropdown.default or dropdown.defaultitems[1] or "";
				end
				dropdown.isSelected = function(self, item)
					for i, v in pairs(dropdown.values) do
						if (v == item) then
							return true;
						end
					end
					return false;
				end;
				dropdown.GetOptions = function(self)
					return dropdown.values;
				end;
				dropdown.updateText = function(self, text)
					if (#text >= 27) then
						text = text:sub(1, 25) .. "..";
					end
				dropdown.SelectedLabel.Text = text;
				end;
				dropdown.updateItemVisuals = function(self)
					pcall(function()
						for _, itemBtn in ipairs(dropdown.ItemsFrame:GetChildren()) do
							if itemBtn:IsA("TextButton") then
								local itemName = itemBtn.Name;
								if ((dropdown.multichoice and dropdown:isSelected(itemName)) or (dropdown.values[1] == itemName)) then
									itemBtn.BackgroundColor3 = Color3.fromRGB(64, 64, 64);
									itemBtn.TextColor3 = window.theme.accentcolor;
									itemBtn.Text = " " .. itemName;
								else
									itemBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40);
									itemBtn.TextColor3 = Color3.fromRGB(255, 255, 255);
									itemBtn.Text = itemName;
								end
							end
						end
					end);
				end;
				dropdown.Changed = Instance.new("BindableEvent");
				dropdown.Set = function(self, value)
					if (type(value) == "table") then
						dropdown.values = value;
						dropdown:updateText(table.concat(value, ", "));
						pcall(dropdown.callback, value);
					else
						dropdown:updateText(tostring(value));
						dropdown.values = {value};
						pcall(dropdown.callback, value);
					end
					dropdown:updateItemVisuals();
					dropdown.Changed:Fire(value);
					if (dropdown.flag and (dropdown.flag ~= "")) then
						library.flags[dropdown.flag] = (dropdown.multichoice and dropdown.values) or dropdown.values[1];
					end
				end;
				dropdown.Get = function(self)
					return (dropdown.multichoice and dropdown.values) or dropdown.values[1];
				end;

				dropdown.Close = function(self)
					if window.CurrentOpenDropdown == dropdown then
						window.CurrentOpenDropdown = nil;
					end
					tweenservice:Create(dropdown.Nav, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Rotation=90}):Play();
					dropdown.ItemsFrame.Visible = false;
					dropdown.OutlineItems.Visible = false;
					dropdown.BlackOutlineItems.Visible = false;
					dropdown.BlackOutline2Items.Visible = false;
					if window.DropdownOverlay then
						window.DropdownOverlay.Visible = false;
					end
					pcall(function()
						sector.Main.Parent.ScrollingEnabled = true;
					end);
				end;

				dropdown.Open = function(self)
					if not dropdown.items or #dropdown.items == 0 then return end
					if window.CurrentOpenDropdown and window.CurrentOpenDropdown ~= dropdown then
						pcall(function() window.CurrentOpenDropdown:Close() end);
					end
					window.CurrentOpenDropdown = dropdown;

					-- Calculate position relative to window.Frame
					local mainAbs = dropdown.Main.AbsolutePosition;
					local winAbs = window.Frame.AbsolutePosition;
					local relX = mainAbs.X - winAbs.X;
					local relY = mainAbs.Y - winAbs.Y + dropdown.Main.AbsoluteSize.Y + 4;
					local width = dropdown.Main.AbsoluteSize.X > 0 and dropdown.Main.AbsoluteSize.X or (sector.Main.Size.X.Offset - 12);

					local totalH = (#dropdown.items * 20) + 4;
					local frameH = math.clamp(totalH, 20, 156);

					-- Flip upwards if overflowing below window.Frame
					if (relY + frameH > window.Frame.AbsoluteSize.Y - 10) and (mainAbs.Y - winAbs.Y - frameH - 4 > 30) then
						relY = (mainAbs.Y - winAbs.Y) - frameH - 4;
					end

					dropdown.ItemsFrame.Position = UDim2.fromOffset(relX, relY);
					dropdown.ItemsFrame.Size = UDim2.fromOffset(width, frameH);
					dropdown.ItemsFrame.CanvasSize = UDim2.fromOffset(0, totalH);

					dropdown.OutlineItems.Position = dropdown.ItemsFrame.Position + UDim2.fromOffset(-2, -2);
					dropdown.OutlineItems.Size = dropdown.ItemsFrame.Size + UDim2.fromOffset(4, 4);

					dropdown.BlackOutlineItems.Position = dropdown.ItemsFrame.Position + UDim2.fromOffset(-1, -1);
					dropdown.BlackOutlineItems.Size = dropdown.ItemsFrame.Size + UDim2.fromOffset(2, 2);

					dropdown.BlackOutline2Items.Position = dropdown.ItemsFrame.Position + UDim2.fromOffset(-3, -3);
					dropdown.BlackOutline2Items.Size = dropdown.ItemsFrame.Size + UDim2.fromOffset(6, 6);

					tweenservice:Create(dropdown.Nav, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Rotation=-90}):Play();

					dropdown.BlackOutline2Items.Visible = true;
					dropdown.OutlineItems.Visible = true;
					dropdown.BlackOutlineItems.Visible = true;
					dropdown.ItemsFrame.Visible = true;

					if window.DropdownOverlay then
						window.DropdownOverlay.Visible = true;
					end
					dropdown:updateItemVisuals();

					pcall(function()
						sector.Main.Parent.ScrollingEnabled = false;
					end);
				end;

				dropdown.Toggle = function(self)
					if dropdown.ItemsFrame.Visible then
						dropdown:Close();
					else
						dropdown:Open();
					end
				end;

				dropdown.items = {};
				dropdown.Add = function(self, v)
					local Item = Instance.new("TextButton", dropdown.ItemsFrame);
					Item.BackgroundColor3 = Color3.fromRGB(40, 40, 40);
					Item.TextColor3 = Color3.fromRGB(255, 255, 255);
					Item.BorderSizePixel = 0;
					Item.Position = UDim2.fromOffset(0, 0);
					Item.Size = UDim2.new(1, -4, 0, 20);
					Item.ZIndex = 125;
					Item.Text = v;
					Item.Name = v;
					Item.AutoButtonColor = false;
					Item.Font = window.theme.font;
					Item.TextSize = 15;
					Item.TextXAlignment = Enum.TextXAlignment.Left;
					Item.TextStrokeTransparency = 1;
					Item.Active = true;

					local function onSelect()
						if dropdown.multichoice then
							if dropdown:isSelected(v) then
								for i2, v2 in pairs(dropdown.values) do
									if (v2 == v) then
										table.remove(dropdown.values, i2);
									end
								end
								dropdown:Set(dropdown.values);
							else
								table.insert(dropdown.values, v);
								dropdown:Set(dropdown.values);
							end
							return;
						else
							dropdown:Close();
						end
						dropdown:Set(v);
					end

					local lastSelect = 0;
					local function triggerSelect()
						local now = tick();
						if (now - lastSelect) < 0.25 then return end;
						lastSelect = now;
						onSelect();
					end

					-- Use Activated as primary for mobile touch and PC clicks without cancelling scroll gestures
					Item.Activated:Connect(triggerSelect);
					Item.MouseButton1Click:Connect(triggerSelect);

					if ((dropdown.multichoice and dropdown:isSelected(v)) or (dropdown.values[1] == v)) then
						Item.BackgroundColor3 = Color3.fromRGB(64, 64, 64);
						Item.TextColor3 = window.theme.accentcolor;
						Item.Text = " " .. v;
					else
						Item.BackgroundColor3 = Color3.fromRGB(40, 40, 40);
						Item.TextColor3 = Color3.fromRGB(255, 255, 255);
						Item.Text = v;
					end

					table.insert(dropdown.items, v);
					local totalH = (#dropdown.items * 20) + 4;
					dropdown.ItemsFrame.CanvasSize = UDim2.fromOffset(0, totalH);
				end;

				dropdown.Remove = function(self, value)
					local item = dropdown.ItemsFrame:FindFirstChild(value);
					if item then
						for i, v in pairs(dropdown.items) do
							if (v == value) then
								table.remove(dropdown.items, i);
							end
						end
						local totalH = (#dropdown.items * 20) + 4;
						dropdown.ItemsFrame.CanvasSize = UDim2.fromOffset(0, totalH);
						item:Destroy();
					end
				end;

				dropdown.getList = function(self)
					return dropdown.items;
				end;

				dropdown.Clear = function(self)
					for _, item in pairs(dropdown.ItemsFrame:GetChildren()) do
						if item:IsA("TextButton") then
							item:Destroy();
						end
					end
					dropdown.items = {};
					dropdown.ItemsFrame.CanvasSize = UDim2.fromOffset(0, 0);
				end;

				dropdown.Refresh = function(self, newItems)
					local currentVal = (dropdown.values and dropdown.values[1]) or dropdown.default;
					dropdown:Clear();
					for _, v in ipairs(newItems or {}) do
						dropdown:Add(v);
					end
					local found = false;
					if currentVal and newItems then
						for _, itm in ipairs(newItems) do
							if itm == currentVal then
								found = true;
								break;
							end
						end
					end
					if found then
						dropdown:Set(currentVal);
					elseif newItems and newItems[1] then
						dropdown:Set(newItems[1]);
					end
				end;

				for i, v in pairs(dropdown.defaultitems) do
					dropdown:Add(v);
				end
				if dropdown.default then
					dropdown:Set(dropdown.default);
				end

				local lastToggle = 0;
				local function handleDropdownToggle()
					local now = tick();
					if (now - lastToggle) < 0.25 then return end;
					lastToggle = now;
					dropdown:Toggle();
				end

				dropdown.Main.Activated:Connect(handleDropdownToggle);
				dropdown.Main.MouseButton1Click:Connect(handleDropdownToggle);
				dropdown.Nav.Activated:Connect(handleDropdownToggle);
				dropdown.Nav.MouseButton1Click:Connect(handleDropdownToggle);

				dropdown.BlackOutline2.MouseEnter:Connect(function()
					dropdown.BlackOutline2.BackgroundColor3 = window.theme.accentcolor;
				end);
				dropdown.BlackOutline2.MouseLeave:Connect(function()
					dropdown.BlackOutline2.BackgroundColor3 = window.theme.outlinecolor2;
				end);
				sector:FixSize();
				table.insert(library.items, dropdown);
				return dropdown;
			end;
			sector.AddSeperator = function(self, text, ranbow)
				local seperator = {};
				seperator.text = text or "";
				seperator.main = Instance.new("Frame", sector.Items);
				seperator.main.Name = "Main";
				seperator.main.ZIndex = 5;
				seperator.main.Size = UDim2.fromOffset(sector.Main.Size.X.Offset - 12, 10);
				seperator.main.BorderSizePixel = 0;
				seperator.main.BackgroundTransparency = 1;
				seperator.line = Instance.new("Frame", seperator.main);
				seperator.line.Name = "Line";
				seperator.line.ZIndex = 7;
				seperator.line.BackgroundColor3 = Color3.fromRGB(70, 70, 70);
				seperator.line.BorderSizePixel = 0;
				seperator.line.Size = UDim2.fromOffset(sector.Main.Size.X.Offset - 26, 1);
				seperator.line.Position = UDim2.fromOffset(7, 5);
				seperator.outline = Instance.new("Frame", seperator.line);
				seperator.outline.Name = "Outline";
				seperator.outline.ZIndex = 6;
				seperator.outline.BorderSizePixel = 0;
				seperator.outline.BackgroundColor3 = window.theme.outlinecolor2;
				seperator.outline.Position = UDim2.fromOffset(-1, -1);
				seperator.outline.Size = seperator.line.Size - UDim2.fromOffset(-2, -2);
				updateevent.Event:Connect(function(theme)
					seperator.outline.BackgroundColor3 = theme.outlinecolor2;
				end);
				seperator.label = Instance.new("TextLabel", seperator.main);
				seperator.label.Name = "Label";
				seperator.label.BackgroundTransparency = 1;
				seperator.label.Size = seperator.main.Size;
				seperator.label.Font = window.theme.font;
				seperator.label.ZIndex = 8;
				seperator.label.Text = seperator.text;
				seperator.label.TextColor3 = Color3.fromRGB(255, 255, 255);
				if (ranbow == true) then
					RainbowText(seperator.label);
				end
				seperator.label.TextSize = window.theme.fontsize;
				seperator.label.TextStrokeTransparency = 1;
				seperator.label.TextXAlignment = Enum.TextXAlignment.Center;
				updateevent.Event:Connect(function(theme)
					seperator.label.Font = theme.font;
					seperator.label.TextSize = theme.fontsize;
				end);
				local textSize = textservice:GetTextSize(seperator.text, window.theme.fontsize, window.theme.font, Vector2.new(2000, 2000));
				local textStart = (seperator.main.AbsoluteSize.X / 2) - (textSize.X / 2);
				sector.LabelBackFrame = Instance.new("Frame", seperator.main);
				sector.LabelBackFrame.Name = "LabelBack";
				sector.LabelBackFrame.ZIndex = 7;
				sector.LabelBackFrame.Size = UDim2.fromOffset(textSize.X + 12, 10);
				sector.LabelBackFrame.BorderSizePixel = 0;
				sector.LabelBackFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30);
				sector.LabelBackFrame.Position = UDim2.new(0, textStart - 6, 0, 0);
				updateevent.Event:Connect(function(theme)
					textSize = textservice:GetTextSize(seperator.text, theme.fontsize, theme.font, Vector2.new(2000, 2000));
					textStart = (seperator.main.AbsoluteSize.X / 2) - (textSize.X / 2);
					sector.LabelBackFrame.Size = UDim2.fromOffset(textSize.X + 12, 10);
					sector.LabelBackFrame.Position = UDim2.new(0, textStart - 6, 0, 0);
				end);
				seperator.Set = function(self, value)
					seperator.label.Text = value;
				end;
				sector:FixSize();
				return seperator;
			end;
			return sector;
		end;
		pcall(function()
			if isfolder and makefolder and not isfolder("!SuiSuiHUB") then
				makefolder("!SuiSuiHUB");
			end
		end);
		table.insert(window.Tabs, tab);
		return tab;
	end;
	return window;
end;
repeat
	wait();
until game:IsLoaded() 
if not game:GetService("CoreGui"):FindFirstChild("StatBySmell") then
	local GuiStat = Instance.new("ScreenGui");
	local TopbarContainer = Instance.new("Frame");
	local _1FPSCount = Instance.new("Frame");
	local IconButton = Instance.new("TextButton");
	local UICorner = Instance.new("UICorner");
	local UIStroke1 = Instance.new("UIStroke");
	local IconLabel = Instance.new("TextLabel");
	local _3PingCount = Instance.new("Frame");
	local IconButton_2 = Instance.new("TextButton");
	local UICorner_2 = Instance.new("UICorner");
	local UIStroke2 = Instance.new("UIStroke");
	local IconLabel_2 = Instance.new("TextLabel");
	local UIListLayout = Instance.new("UIListLayout");
	local _2ToggleMenu = Instance.new("Frame");
	local IconButton_3 = Instance.new("TextButton");
	local IconImage = Instance.new("ImageLabel");
	local IconLabel_3 = Instance.new("TextLabel");
	local UICorner_3 = Instance.new("UICorner");
	local UIStroke3 = Instance.new("UIStroke");

	GuiStat.Name = "StatBySmell";
	GuiStat.Parent = coregui;
	GuiStat.ResetOnSpawn = false;
	GuiStat.ZIndexBehavior = Enum.ZIndexBehavior.Sibling;
	GuiStat.IgnoreGuiInset = true;
	GuiStat.AutoLocalize = true;
	GuiStat.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets;

	TopbarContainer.Name = "Frame";
	TopbarContainer.Parent = GuiStat;
	TopbarContainer.BackgroundTransparency = 1;
	TopbarContainer.Position = UDim2.new(0.105, 0, 0, 3);
	TopbarContainer.Size = UDim2.new(0.8, 0, 0.03, 0);

	-- 1. FPS Count (Ngọc Bích Tu Tiên)
	_1FPSCount.Name = "1FPSCount";
	_1FPSCount.Parent = TopbarContainer;
	_1FPSCount.BackgroundTransparency = 1;
	_1FPSCount.LayoutOrder = 7;
	_1FPSCount.Position = UDim2.new(0, 265, 0, 4);
	_1FPSCount.Size = UDim2.new(0, 86, 0, 32);

	IconButton.Name = "IconButton";
	IconButton.Parent = _1FPSCount;
	IconButton.Active = false;
	IconButton.BackgroundColor3 = Color3.fromRGB(20, 17, 32); -- Huyền Thạch
	IconButton.BackgroundTransparency = 0.25;
	IconButton.BorderSizePixel = 0;
	IconButton.Size = UDim2.new(1, 0, 1, 0);
	IconButton.ZIndex = 10;
	IconButton.AutoButtonColor = false;
	IconButton.Text = "";
	IconButton.TextTransparency = 1;

	UICorner.CornerRadius = UDim.new(0, 6);
	UICorner.Parent = IconButton;

	UIStroke1.Color = Color3.fromRGB(88, 58, 138); -- Tử Viền
	UIStroke1.Thickness = 1.2;
	UIStroke1.ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
	UIStroke1.Parent = IconButton;

	IconLabel.Name = "IconLabel";
	IconLabel.Parent = IconButton;
	IconLabel.AnchorPoint = Vector2.new(0, 0.5);
	IconLabel.BackgroundTransparency = 1;
	IconLabel.ClipsDescendants = true;
	IconLabel.Position = UDim2.new(0, 12, 0.5, 0);
	IconLabel.Size = UDim2.new(1, -24, 0.45, 7);
	IconLabel.ZIndex = 11;
	IconLabel.Font = Enum.Font.GothamSemibold;
	IconLabel.Text = "FPS: 60";
	IconLabel.TextColor3 = Color3.fromRGB(52, 211, 153); -- Ngọc Bích
	IconLabel.TextSize = 14;

	-- 2. Ping Count (Thanh Tĩnh)
	_3PingCount.Name = "3PingCount";
	_3PingCount.Parent = TopbarContainer;
	_3PingCount.BackgroundTransparency = 1;
	_3PingCount.LayoutOrder = 8;
	_3PingCount.Position = UDim2.new(0, 363, 0, 4);
	_3PingCount.Size = UDim2.new(0, 107, 0, 32);

	IconButton_2.Name = "IconButton";
	IconButton_2.Parent = _3PingCount;
	IconButton_2.Active = false;
	IconButton_2.BackgroundColor3 = Color3.fromRGB(20, 17, 32); -- Huyền Thạch
	IconButton_2.BackgroundTransparency = 0.25;
	IconButton_2.BorderSizePixel = 0;
	IconButton_2.Size = UDim2.new(1, 0, 1, 0);
	IconButton_2.ZIndex = 10;
	IconButton_2.AutoButtonColor = false;
	IconButton_2.Text = "";
	IconButton_2.TextTransparency = 1;

	UICorner_2.CornerRadius = UDim.new(0, 6);
	UICorner_2.Parent = IconButton_2;

	UIStroke2.Color = Color3.fromRGB(88, 58, 138); -- Tử Viền
	UIStroke2.Thickness = 1.2;
	UIStroke2.ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
	UIStroke2.Parent = IconButton_2;

	IconLabel_2.Name = "IconLabel";
	IconLabel_2.Parent = IconButton_2;
	IconLabel_2.AnchorPoint = Vector2.new(0, 0.5);
	IconLabel_2.BackgroundTransparency = 1;
	IconLabel_2.ClipsDescendants = true;
	IconLabel_2.Position = UDim2.new(0, 12, 0.5, 0);
	IconLabel_2.Size = UDim2.new(1, -24, 0.45, 7);
	IconLabel_2.ZIndex = 11;
	IconLabel_2.Font = Enum.Font.GothamSemibold;
	IconLabel_2.Text = "Ping: 0 ms";
	IconLabel_2.TextColor3 = Color3.fromRGB(52, 211, 153); -- Ngọc Bích
	IconLabel_2.TextSize = 14;

	-- UI Layout
	UIListLayout.Parent = TopbarContainer;
	UIListLayout.FillDirection = Enum.FillDirection.Horizontal;
	UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center;
	UIListLayout.Padding = UDim.new(0, 10);

	-- 3. Toggle Menu (Tử Khí & Hoàng Kim Tiên Hiệp)
	_2ToggleMenu.Name = "2ToggleMenu";
	_2ToggleMenu.Parent = TopbarContainer;
	_2ToggleMenu.BackgroundTransparency = 1;
	_2ToggleMenu.LayoutOrder = 1;
	_2ToggleMenu.Position = UDim2.new(0, 171, 0, 4);
	_2ToggleMenu.Size = UDim2.new(0, 88, 0, 32);

	IconButton_3.Name = "IconButton";
	IconButton_3.Parent = _2ToggleMenu;
	IconButton_3.BackgroundColor3 = Color3.fromRGB(28, 24, 44); -- Tử Cực Đen
	IconButton_3.BackgroundTransparency = 0.2;
	IconButton_3.BorderSizePixel = 0;
	IconButton_3.Size = UDim2.new(1, 0, 1, 0);
	IconButton_3.ZIndex = 10;
	IconButton_3.AutoButtonColor = true;
	IconButton_3.Text = "";
	IconButton_3.TextTransparency = 1;

	UICorner_3.CornerRadius = UDim.new(0, 6);
	UICorner_3.Parent = IconButton_3;

	UIStroke3.Color = Color3.fromRGB(168, 85, 247); -- Viền Tử Khí Sáng
	UIStroke3.Thickness = 1.4;
	UIStroke3.ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
	UIStroke3.Parent = IconButton_3;

	IconImage.Name = "IconImage";
	IconImage.Parent = IconButton_3;
	IconImage.AnchorPoint = Vector2.new(0, 0.5);
	IconImage.BackgroundTransparency = 1;
	IconImage.Position = UDim2.new(0, 10, 0.5, 0);
	IconImage.Size = UDim2.new(0, 16, 0.65, 0);
	IconImage.ZIndex = 11;
	IconImage.Image = "http://www.roblox.com/asset/?id=2246477671";
	IconImage.ImageColor3 = Color3.fromRGB(168, 85, 247); -- Tử Khí
	IconImage.ScaleType = Enum.ScaleType.Fit;

	IconLabel_3.Name = "IconLabel";
	IconLabel_3.Parent = IconButton_3;
	IconLabel_3.AnchorPoint = Vector2.new(0, 0.5);
	IconLabel_3.BackgroundTransparency = 1;
	IconLabel_3.ClipsDescendants = true;
	IconLabel_3.Position = UDim2.new(0, 32, 0.5, 0);
	IconLabel_3.Size = UDim2.new(1, -40, 0.45, 7);
	IconLabel_3.ZIndex = 11;
	IconLabel_3.Font = Enum.Font.GothamBold;
	IconLabel_3.Text = "Menu";
	IconLabel_3.TextColor3 = Color3.fromRGB(251, 191, 36); -- Hoàng Kim
	IconLabel_3.TextSize = 14;
	IconLabel_3.TextXAlignment = Enum.TextXAlignment.Left;

	local lastMenuToggle = 0;
	local function toggleHubMenu()
		local now = tick();
		if (now - lastMenuToggle) < 0.2 then return end;
		lastMenuToggle = now;
		local found = false;
		if getgenv().uilib then
			pcall(function()
				local m = getgenv().uilib:FindFirstChild("main");
				if m then
					m.Visible = not m.Visible;
					found = true;
				end
			end);
		end
		if not found then
			local containers = {};
			if gethui then pcall(function() table.insert(containers, gethui()) end) end
			pcall(function() table.insert(containers, game:GetService("CoreGui")) end)
			pcall(function()
				local lp = game:GetService("Players").LocalPlayer;
				if lp and lp:FindFirstChild("PlayerGui") then table.insert(containers, lp.PlayerGui) end
			end);
			for _, c in ipairs(containers) do
				pcall(function()
					for _, v in pairs(c:GetChildren()) do
						local m = v:FindFirstChild("main");
						if m then
							m.Visible = not m.Visible;
							found = true;
						end
					end
				end);
				if found then break end
			end
		end
	end
	IconButton_3.Activated:Connect(toggleHubMenu);
	IconButton_3.MouseButton1Click:Connect(toggleHubMenu);

	-- FPS & Ping Loop (Không Rainbow, siêu nhẹ)
	local RS = game:GetService("RunService");
	local frames = 0;
	local fpsConn = RS.RenderStepped:Connect(function()
		frames = frames + 1;
	end);
	trackConn(fpsConn);

	task.spawn(function()
		while GuiStat and GuiStat.Parent do
			task.wait(1);
			if not (GuiStat and GuiStat.Parent) then break end
				pcall(function()
					local currFPS = frames;
					frames = 0;
					IconLabel.Text = "FPS " .. tostring(currFPS);
					if currFPS < 15 then
						IconLabel.TextColor3 = Color3.fromRGB(239, 68, 68); -- Huyết Hồng (Lag nặng)
					elseif currFPS <= 35 then
						IconLabel.TextColor3 = Color3.fromRGB(251, 191, 36); -- Hoàng Kim (Vừa)
					else
						IconLabel.TextColor3 = Color3.fromRGB(52, 211, 153); -- Ngọc Bích (Mượt)
					end

					local netStats = game:GetService("Stats"):FindFirstChild("Network")
					local sItem = netStats and netStats:FindFirstChild("ServerStatsItem")
					local dataPing = sItem and sItem:FindFirstChild("Data Ping")
					if dataPing then
						local pingStr = dataPing:GetValueString()
						local ping = math.round(tonumber(string.split(pingStr, "(")[1]) or 0)
						IconLabel_2.Text = "Ping: " .. tostring(ping) .. " ms";
						if ping < 100 then
							IconLabel_2.TextColor3 = Color3.fromRGB(52, 211, 153); -- Ngọc Bích (Tốt)
						elseif ping < 200 then
							IconLabel_2.TextColor3 = Color3.fromRGB(216, 180, 254); -- Tử Khí (Bình thường)
						elseif ping < 300 then
							IconLabel_2.TextColor3 = Color3.fromRGB(251, 191, 36); -- Hoàng Kim (Chậm)
						else
							IconLabel_2.TextColor3 = Color3.fromRGB(239, 68, 68); -- Huyết Hồng (Lag)
						end
					end
				end);
		end
	end);
end
return library;
