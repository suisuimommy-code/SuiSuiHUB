repeat task.wait(0.5) until game:IsLoaded()
local localPlayer = game:GetService("Players").LocalPlayer
repeat task.wait(0.5) until localPlayer and localPlayer:FindFirstChild("PlayerGui")

MapSelection = {}
RaidSelection = {}

if game.PlaceId == 6938803436 or game.PlaceId == 6990129309 or game.PlaceId == 6990133340 or game.PlaceId == 6990131029 or game.PlaceId == 7338881230 or game.PlaceId == 7274690025 then

    local library = (function()
library = {flags={},items={}};
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
if (_G.Color == nil) then
	_G.Color = Color3.fromRGB(168, 85, 247);
end
if (_G.Color2 == nil) then
	_G.Color2 = Color3.fromRGB(216, 180, 254);
end
local players = game:GetService("Players");
local uis = game:GetService("UserInputService");
local runservice = game:GetService("RunService");
local tweenservice = game:GetService("TweenService");
local marketplaceservice = game:GetService("MarketplaceService");
local textservice = game:GetService("TextService");
local coregui = game:GetService("CoreGui");
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
		uis.InputChanged:Connect(function(input)
			if uis.MouseEnabled then
				if (input.UserInputType == Enum.UserInputType.MouseMovement) then
					library.cursor.Position = Vector2.new(input.Position.X - 32, input.Position.Y + 7);
				end
			end
		end);
		game:GetService("RunService").RenderStepped:Connect(function()
			uis.OverrideMouseIconBehavior = Enum.OverrideMouseIconBehavior.ForceHide;
			library.cursor.Visible = uis.MouseEnabled and (uis.MouseIconEnabled or game:GetService("GuiService").MenuIsOpen);
		end);
	elseif (not success and library.cursor) then
		library.cursor:Remove();
	end
end
library.ConfigSystem = function(self, name)
	if not isfolder("!SuiSuiHUB") then
		makefolder("!SuiSuiHUB");
	end
	local configSystem = {};
	configSystem.configFolder = "!SuiSuiHUB/" .. tostring(game.Players.LocalPlayer.Name) .. "";
	if not isfolder(configSystem.configFolder) then
		makefolder(tostring(configSystem.configFolder));
	end
	if not isfile(configSystem.configFolder .. "/" .. name .. ".txt") then
		writefile(configSystem.configFolder .. "/" .. name .. ".txt", "[]");
	end
	configSystem.Load = function(self)
		local Success = pcall(readfile, configSystem.configFolder .. "/" .. name .. ".txt");
		if Success then
			pcall(function()
				local ReadConfig = httpservice:JSONDecode(readfile(configSystem.configFolder .. "/" .. name .. ".txt"));
				local NewConfig = {};
				for i, v in pairs(ReadConfig) do
					if (typeof(v) == "table") then
						if (typeof(v[1]) == "number") then
							NewConfig[i] = Color3.new(v[1], v[2], v[3]);
						elseif (typeof(v[1]) == "table") then
							NewConfig[i] = v[1];
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
						if ((i ~= nil) and (i ~= "") and (i ~= "Configs_Name") and (i ~= "Configs") and (v2.flag ~= nil)) then
							if (v2.flag == i) then
								pcall(function()
									v2:Set(v);
									print(v2.flag, v);
								end);
							end
						end
					end
				end
			end);
		end
	end;
	configSystem.Save = function(self)
		config = {};
		for i, v in pairs(library.flags) do
			if ((v ~= nil) and (v ~= "")) then
				if (typeof(v) == "Color3") then
					config[i] = {v.R,v.G,v.B};
				elseif (tostring(v):find("Enum.KeyCode")) then
					config[i] = "Enum.KeyCode." .. v.Name;
				elseif (typeof(v) == "table") then
					config[i] = {v};
				else
					config[i] = v;
				end
			end
		end
		writefile(configSystem.configFolder .. "/" .. name .. ".txt", httpservice:JSONEncode(config));
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
	runservice.Heartbeat:Connect(function()
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
	window.Main = Instance.new("ScreenGui", coregui);
	window.Main.Name = name;
	window.Main.DisplayOrder = 15;
	if getgenv().uilib then
		getgenv().uilib:Remove();
	end
	getgenv().uilib = window.Main;
	local dragging, dragInput, dragStart, startPos;
	uis.InputChanged:Connect(function(input)
		if ((input == dragInput) and dragging) then
			local delta = input.Position - dragStart;
			window.Frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y);
		end
	end);
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
	updateevent.Event:Connect(function(theme)
		window.Frame.BackgroundColor3 = theme.backgroundcolor;
	end);
	uis.InputBegan:Connect(function(key)
		if (key.KeyCode == window.hidebutton) then
			for i, v in pairs(game:GetService("CoreGui"):GetChildren()) do
				if v:FindFirstChild("main") then
					v.main.Visible = not v.main.Visible;
				end
			end
		end
	end);
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
	window.NameLabel.Size = UDim2.new(1, -12, 0, (window.TopBar.AbsoluteSize.Y / 2) - 2);
	window.NameLabel.TextSize = window.theme.titlesize;
	updateevent.Event:Connect(function(theme)
		window.NameLabel.TextColor3 = theme.toptextcolor;
		window.NameLabel.Font = theme.font;
		window.NameLabel.TextSize = theme.titlesize;
	end);
	window.Line2 = Instance.new("Frame", window.TopBar);
	window.Line2.Name = "line";
	window.Line2.Position = UDim2.fromOffset(0, window.TopBar.AbsoluteSize.Y / 2.1);
	window.Line2.Size = UDim2.fromOffset(window.size.X.Offset, 1);
	window.Line2.BorderSizePixel = 0;
	window.Line2.BackgroundColor3 = window.theme.accentcolor;
	updateevent.Event:Connect(function(theme)
		window.Line2.BackgroundColor3 = theme.accentcolor;
	end);
	window.TabList = Instance.new("ScrollingFrame", window.TopBar);
	window.TabList.Name = "tablist";
	window.TabList.BackgroundTransparency = 1;
	window.TabList.Position = UDim2.fromOffset(0, (window.TopBar.AbsoluteSize.Y / 2) + 1);
	window.TabList.Size = UDim2.fromOffset(window.size.X.Offset, window.TopBar.AbsoluteSize.Y / 2);
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
	window.BlackLine.Position = UDim2.fromOffset(0, window.TopBar.AbsoluteSize.Y);
	updateevent.Event:Connect(function(theme)
		window.BlackLine.BackgroundColor3 = theme.outlinecolor2;
	end);
	window.BackgroundImage = Instance.new("ImageLabel", window.Frame);
	window.BackgroundImage.Name = "background";
	window.BackgroundImage.BorderSizePixel = 0;
	window.BackgroundImage.ScaleType = Enum.ScaleType.Tile;
	window.BackgroundImage.Position = window.BlackLine.Position + UDim2.fromOffset(0, 1);
	window.BackgroundImage.Size = UDim2.fromOffset(window.size.X.Offset, (window.size.Y.Offset - window.TopBar.AbsoluteSize.Y) - 1);
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
		tab.TabButton.Size = UDim2.fromOffset(size.X + 15, window.TabList.AbsoluteSize.Y - 1);
		tab.TabButton.Name = tab.name;
		tab.TabButton.TextSize = window.theme.fontsize;
		updateevent.Event:Connect(function(theme)
			local size = textservice:GetTextSize(tab.name, theme.fontsize, theme.font, Vector2.new(200, 200));
			tab.TabButton.TextColor3 = ((tab.TabButton.Name == "SelectedTab") and theme.accentcolor) or theme.tabstextcolor;
			tab.TabButton.Font = theme.font;
			tab.TabButton.Size = UDim2.fromOffset(size.X + 15, window.TabList.AbsoluteSize.Y - 1);
			tab.TabButton.TextSize = theme.fontsize;
		end);
		tab.Left = Instance.new("ScrollingFrame", window.Frame);
		tab.Left.Name = "leftside";
		tab.Left.BorderSizePixel = 0;
		tab.Left.Size = UDim2.fromOffset(window.size.X.Offset / 2, window.size.Y.Offset - (window.TopBar.AbsoluteSize.Y + 1));
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
		tab.Right.Size = UDim2.fromOffset(window.size.X.Offset / 2, window.size.Y.Offset - (window.TopBar.AbsoluteSize.Y + 1));
		tab.Right.BackgroundTransparency = 1;
		tab.Right.Position = tab.Left.Position + UDim2.fromOffset(tab.Left.AbsoluteSize.X, 0);
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
		tab.TabButton.MouseButton1Down:Connect(function()
			tab:SelectTab();
		end);
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
			sector.Label.Size = UDim2.fromOffset(math.clamp(textservice:GetTextSize(sector.name, 15, window.theme.font, Vector2.new(200, 300)).X + 13, 0, sector.Main.Size.X.Offset), size.Y);
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
				sector.Label.Size = UDim2.fromOffset(math.clamp(textservice:GetTextSize(sector.name, 15, theme.font, Vector2.new(200, 300)).X + 13, 0, sector.Main.Size.X.Offset), size.Y);
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
				button.Main.Size = UDim2.fromOffset(sector.Main.Size.X.Offset - 12, 14);
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
				button.Main.MouseButton1Down:Connect(button.callback);
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
				toggle.Label.Position = UDim2.fromOffset(toggle.Main.AbsoluteSize.X + 10, -2);
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
				toggle.Items.Size = UDim2.fromOffset(60, toggle.BlackOutline.AbsoluteSize.Y);
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
						runservice.RenderStepped:Connect(function()
							if ((dropdown.multichoice and dropdown:isSelected(v)) or (dropdown.values[1] == v)) then
								Item.BackgroundColor3 = Color3.fromRGB(64, 64, 64);
								Item.TextColor3 = window.theme.accentcolor;
								Item.Text = " " .. v;
							else
								Item.BackgroundColor3 = Color3.fromRGB(40, 40, 40);
								Item.TextColor3 = Color3.fromRGB(255, 255, 255);
								Item.Text = v;
							end
						end);
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
					colorpicker.callback = callback or function()
					end;
					colorpicker.default = default or Color3.fromRGB(255, 255, 255);
					colorpicker.value = colorpicker.default;
					colorpicker.flag = flag or ((toggle.text or "") .. tostring(#toggle.Items:GetChildren()));
					colorpicker.Main = Instance.new("Frame", toggle.Items);
					colorpicker.Main.ZIndex = 6;
					colorpicker.Main.BorderSizePixel = 0;
					colorpicker.Main.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
					colorpicker.Main.Size = UDim2.fromOffset(16, 10);
					colorpicker.Gradient = Instance.new("UIGradient", colorpicker.Main);
					colorpicker.Gradient.Rotation = 90;
					local clr = Color3.new(math.clamp(colorpicker.value.R / 1.7, 0, 1), math.clamp(colorpicker.value.G / 1.7, 0, 1), math.clamp(colorpicker.value.B / 1.7, 0, 1));
					colorpicker.Gradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, colorpicker.value),ColorSequenceKeypoint.new(1, clr)});
					colorpicker.BlackOutline2 = Instance.new("Frame", colorpicker.Main);
					colorpicker.BlackOutline2.Name = "blackline";
					colorpicker.BlackOutline2.ZIndex = 4;
					colorpicker.BlackOutline2.Size = colorpicker.Main.Size + UDim2.fromOffset(6, 6);
					colorpicker.BlackOutline2.BorderSizePixel = 0;
					colorpicker.BlackOutline2.BackgroundColor3 = window.theme.outlinecolor2;
					colorpicker.BlackOutline2.Position = UDim2.fromOffset(-3, -3);
					updateevent.Event:Connect(function(theme)
						if window.OpenedColorPickers[colorpicker.MainPicker] then
							colorpicker.BlackOutline2.BackgroundColor3 = theme.accentcolor;
						else
							colorpicker.BlackOutline2.BackgroundColor3 = theme.outlinecolor2;
						end
					end);
					colorpicker.Outline = Instance.new("Frame", colorpicker.Main);
					colorpicker.Outline.Name = "blackline";
					colorpicker.Outline.ZIndex = 4;
					colorpicker.Outline.Size = colorpicker.Main.Size + UDim2.fromOffset(4, 4);
					colorpicker.Outline.BorderSizePixel = 0;
					colorpicker.Outline.BackgroundColor3 = window.theme.outlinecolor;
					colorpicker.Outline.Position = UDim2.fromOffset(-2, -2);
					updateevent.Event:Connect(function(theme)
						colorpicker.Outline.BackgroundColor3 = theme.outlinecolor;
					end);
					colorpicker.BlackOutline = Instance.new("Frame", colorpicker.Main);
					colorpicker.BlackOutline.Name = "blackline";
					colorpicker.BlackOutline.ZIndex = 4;
					colorpicker.BlackOutline.Size = colorpicker.Main.Size + UDim2.fromOffset(2, 2);
					colorpicker.BlackOutline.BorderSizePixel = 0;
					colorpicker.BlackOutline.BackgroundColor3 = window.theme.outlinecolor2;
					colorpicker.BlackOutline.Position = UDim2.fromOffset(-1, -1);
					updateevent.Event:Connect(function(theme)
						colorpicker.BlackOutline.BackgroundColor3 = theme.outlinecolor2;
					end);
					colorpicker.BlackOutline2.MouseEnter:Connect(function()
						colorpicker.BlackOutline2.BackgroundColor3 = window.theme.accentcolor;
					end);
					colorpicker.BlackOutline2.MouseLeave:Connect(function()
						if not window.OpenedColorPickers[colorpicker.MainPicker] then
							colorpicker.BlackOutline2.BackgroundColor3 = window.theme.outlinecolor2;
						end
					end);
					colorpicker.MainPicker = Instance.new("TextButton", colorpicker.Main);
					colorpicker.MainPicker.Name = "picker";
					colorpicker.MainPicker.ZIndex = 100;
					colorpicker.MainPicker.Visible = false;
					colorpicker.MainPicker.AutoButtonColor = false;
					colorpicker.MainPicker.Text = "";
					window.OpenedColorPickers[colorpicker.MainPicker] = false;
					colorpicker.MainPicker.Size = UDim2.fromOffset(180, 196);
					colorpicker.MainPicker.BorderSizePixel = 0;
					colorpicker.MainPicker.BackgroundColor3 = Color3.fromRGB(40, 40, 40);
					colorpicker.MainPicker.Rotation = 1e-15;
					colorpicker.MainPicker.Position = UDim2.fromOffset(-colorpicker.MainPicker.AbsoluteSize.X + colorpicker.Main.AbsoluteSize.X, 17);
					colorpicker.BlackOutline3 = Instance.new("Frame", colorpicker.MainPicker);
					colorpicker.BlackOutline3.Name = "blackline";
					colorpicker.BlackOutline3.ZIndex = 98;
					colorpicker.BlackOutline3.Size = colorpicker.MainPicker.Size + UDim2.fromOffset(6, 6);
					colorpicker.BlackOutline3.BorderSizePixel = 0;
					colorpicker.BlackOutline3.BackgroundColor3 = window.theme.outlinecolor2;
					colorpicker.BlackOutline3.Position = UDim2.fromOffset(-3, -3);
					updateevent.Event:Connect(function(theme)
						colorpicker.BlackOutline3.BackgroundColor3 = theme.outlinecolor2;
					end);
					colorpicker.Outline2 = Instance.new("Frame", colorpicker.MainPicker);
					colorpicker.Outline2.Name = "blackline";
					colorpicker.Outline2.ZIndex = 98;
					colorpicker.Outline2.Size = colorpicker.MainPicker.Size + UDim2.fromOffset(4, 4);
					colorpicker.Outline2.BorderSizePixel = 0;
					colorpicker.Outline2.BackgroundColor3 = window.theme.outlinecolor;
					colorpicker.Outline2.Position = UDim2.fromOffset(-2, -2);
					updateevent.Event:Connect(function(theme)
						colorpicker.Outline2.BackgroundColor3 = theme.outlinecolor;
					end);
					colorpicker.BlackOutline3 = Instance.new("Frame", colorpicker.MainPicker);
					colorpicker.BlackOutline3.Name = "blackline";
					colorpicker.BlackOutline3.ZIndex = 98;
					colorpicker.BlackOutline3.Size = colorpicker.MainPicker.Size + UDim2.fromOffset(2, 2);
					colorpicker.BlackOutline3.BorderSizePixel = 0;
					colorpicker.BlackOutline3.BackgroundColor3 = window.theme.outlinecolor2;
					colorpicker.BlackOutline3.Position = UDim2.fromOffset(-1, -1);
					updateevent.Event:Connect(function(theme)
						colorpicker.BlackOutline3.BackgroundColor3 = theme.outlinecolor2;
					end);
					colorpicker.hue = Instance.new("ImageLabel", colorpicker.MainPicker);
					colorpicker.hue.ZIndex = 101;
					colorpicker.hue.Position = UDim2.new(0, 3, 0, 3);
					colorpicker.hue.Size = UDim2.new(0, 172, 0, 172);
					colorpicker.hue.Image = "rbxassetid://4155801252";
					colorpicker.hue.ScaleType = Enum.ScaleType.Stretch;
					colorpicker.hue.BackgroundColor3 = Color3.new(1, 0, 0);
					colorpicker.hue.BorderColor3 = window.theme.outlinecolor2;
					updateevent.Event:Connect(function(theme)
						colorpicker.hue.BorderColor3 = theme.outlinecolor2;
					end);
					colorpicker.hueselectorpointer = Instance.new("ImageLabel", colorpicker.MainPicker);
					colorpicker.hueselectorpointer.ZIndex = 101;
					colorpicker.hueselectorpointer.BackgroundTransparency = 1;
					colorpicker.hueselectorpointer.BorderSizePixel = 0;
					colorpicker.hueselectorpointer.Position = UDim2.new(0, 0, 0, 0);
					colorpicker.hueselectorpointer.Size = UDim2.new(0, 7, 0, 7);
					colorpicker.hueselectorpointer.Image = "rbxassetid://6885856475";
					colorpicker.selector = Instance.new("TextLabel", colorpicker.MainPicker);
					colorpicker.selector.ZIndex = 100;
					colorpicker.selector.Position = UDim2.new(0, 3, 0, 181);
					colorpicker.selector.Size = UDim2.new(0, 173, 0, 10);
					colorpicker.selector.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
					colorpicker.selector.BorderColor3 = window.theme.outlinecolor2;
					colorpicker.selector.Text = "";
					updateevent.Event:Connect(function(theme)
						colorpicker.selector.BorderColor3 = theme.outlinecolor2;
					end);
					colorpicker.gradient = Instance.new("UIGradient", colorpicker.selector);
					colorpicker.gradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.new(1, 0, 0)),ColorSequenceKeypoint.new(0.17, Color3.new(1, 0, 1)),ColorSequenceKeypoint.new(0.33, Color3.new(0, 0, 1)),ColorSequenceKeypoint.new(0.5, Color3.new(0, 1, 1)),ColorSequenceKeypoint.new(0.67, Color3.new(0, 1, 0)),ColorSequenceKeypoint.new(0.83, Color3.new(1, 1, 0)),ColorSequenceKeypoint.new(1, Color3.new(1, 0, 0))});
					colorpicker.pointer = Instance.new("Frame", colorpicker.selector);
					colorpicker.pointer.ZIndex = 101;
					colorpicker.pointer.BackgroundColor3 = Color3.fromRGB(40, 40, 40);
					colorpicker.pointer.Position = UDim2.new(0, 0, 0, 0);
					colorpicker.pointer.Size = UDim2.new(0, 2, 0, 10);
					colorpicker.pointer.BorderColor3 = Color3.fromRGB(255, 255, 255);
					if (colorpicker.flag and (colorpicker.flag ~= "")) then
						library.flags[colorpicker.flag] = colorpicker.default;
					end
					colorpicker.RefreshHue = function(self)
						local x = (mouse.X - colorpicker.hue.AbsolutePosition.X) / colorpicker.hue.AbsoluteSize.X;
						local y = (mouse.Y - colorpicker.hue.AbsolutePosition.Y) / colorpicker.hue.AbsoluteSize.Y;
						colorpicker.hueselectorpointer:TweenPosition(UDim2.new(math.clamp(x * colorpicker.hue.AbsoluteSize.X, 0.5, 0.952 * colorpicker.hue.AbsoluteSize.X) / colorpicker.hue.AbsoluteSize.X, 0, math.clamp(y * colorpicker.hue.AbsoluteSize.Y, 0.5, 0.885 * colorpicker.hue.AbsoluteSize.Y) / colorpicker.hue.AbsoluteSize.Y, 0), Enum.EasingDirection.In, Enum.EasingStyle.Sine, 0.05);
						colorpicker:Set(Color3.fromHSV(colorpicker.color, math.clamp(x * colorpicker.hue.AbsoluteSize.X, 0.5, 1 * colorpicker.hue.AbsoluteSize.X) / colorpicker.hue.AbsoluteSize.X, 1 - (math.clamp(y * colorpicker.hue.AbsoluteSize.Y, 0.5, 1 * colorpicker.hue.AbsoluteSize.Y) / colorpicker.hue.AbsoluteSize.Y)));
					end;
					colorpicker.RefreshSelector = function(self)
						local pos = math.clamp((mouse.X - colorpicker.hue.AbsolutePosition.X) / colorpicker.hue.AbsoluteSize.X, 0, 1);
						colorpicker.color = 1 - pos;
						colorpicker.pointer:TweenPosition(UDim2.new(pos, 0, 0, 0), Enum.EasingDirection.In, Enum.EasingStyle.Sine, 0.05);
						colorpicker.hue.BackgroundColor3 = Color3.fromHSV(1 - pos, 1, 1);
						local x = (colorpicker.hueselectorpointer.AbsolutePosition.X - colorpicker.hue.AbsolutePosition.X) / colorpicker.hue.AbsoluteSize.X;
						local y = (colorpicker.hueselectorpointer.AbsolutePosition.Y - colorpicker.hue.AbsolutePosition.Y) / colorpicker.hue.AbsoluteSize.Y;
						colorpicker:Set(Color3.fromHSV(colorpicker.color, math.clamp(x * colorpicker.hue.AbsoluteSize.X, 0.5, 1 * colorpicker.hue.AbsoluteSize.X) / colorpicker.hue.AbsoluteSize.X, 1 - (math.clamp(y * colorpicker.hue.AbsoluteSize.Y, 0.5, 1 * colorpicker.hue.AbsoluteSize.Y) / colorpicker.hue.AbsoluteSize.Y)));
					end;
					colorpicker.Set = function(self, value)
						local color = Color3.new(math.clamp(value.r, 0, 1), math.clamp(value.g, 0, 1), math.clamp(value.b, 0, 1));
						colorpicker.value = color;
						if (colorpicker.flag and (colorpicker.flag ~= "")) then
							library.flags[colorpicker.flag] = color;
						end
						local clr = Color3.new(math.clamp(color.R / 1.7, 0, 1), math.clamp(color.G / 1.7, 0, 1), math.clamp(color.B / 1.7, 0, 1));
						colorpicker.Gradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, color),ColorSequenceKeypoint.new(1, clr)});
						pcall(colorpicker.callback, color);
					end;
					colorpicker.Get = function(self, value)
						return colorpicker.value;
					end;
					colorpicker:Set(colorpicker.default);
					local dragging_selector = false;
					local dragging_hue = false;
					colorpicker.selector.InputBegan:Connect(function(input)
						if (input.UserInputType == Enum.UserInputType.MouseButton1) then
							dragging_selector = true;
							colorpicker:RefreshSelector();
						end
					end);
					colorpicker.selector.InputEnded:Connect(function(input)
						if (input.UserInputType == Enum.UserInputType.MouseButton1) then
							dragging_selector = false;
							colorpicker:RefreshSelector();
						end
					end);
					colorpicker.hue.InputBegan:Connect(function(input)
						if (input.UserInputType == Enum.UserInputType.MouseButton1) then
							dragging_hue = true;
							colorpicker:RefreshHue();
						end
					end);
					colorpicker.hue.InputEnded:Connect(function(input)
						if (input.UserInputType == Enum.UserInputType.MouseButton1) then
							dragging_hue = false;
							colorpicker:RefreshHue();
						end
					end);
					uis.InputChanged:Connect(function(input)
						if (dragging_selector and (input.UserInputType == Enum.UserInputType.MouseMovement)) then
							colorpicker:RefreshSelector();
						end
						if (dragging_hue and (input.UserInputType == Enum.UserInputType.MouseMovement)) then
							colorpicker:RefreshHue();
						end
					end);
					local inputBegan = function(input)
						if (input.UserInputType == Enum.UserInputType.MouseButton1) then
							for i, v in pairs(window.OpenedColorPickers) do
								if (v and (i ~= colorpicker.MainPicker)) then
									i.Visible = false;
									window.OpenedColorPickers[i] = false;
								end
							end
							colorpicker.MainPicker.Visible = not colorpicker.MainPicker.Visible;
							window.OpenedColorPickers[colorpicker.MainPicker] = colorpicker.MainPicker.Visible;
							if window.OpenedColorPickers[colorpicker.MainPicker] then
								colorpicker.BlackOutline2.BackgroundColor3 = window.theme.accentcolor;
							else
								colorpicker.BlackOutline2.BackgroundColor3 = window.theme.outlinecolor2;
							end
						end
					end;
					colorpicker.Main.InputBegan:Connect(inputBegan);
					colorpicker.Outline.InputBegan:Connect(inputBegan);
					colorpicker.BlackOutline2.InputBegan:Connect(inputBegan);
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
						slider.SlideBar:TweenSize(UDim2.fromOffset(percent * slider.Main.AbsoluteSize.X, slider.Main.AbsoluteSize.Y), Enum.EasingDirection.In, Enum.EasingStyle.Sine, 0.05);
						slider.InputLabel.Text = slider.value;
						pcall(slider.callback, slider.value);
					end;
					slider:Set(slider.default);
					slider.Refresh = function(self)
						local mousePos = camera:WorldToViewportPoint(mouse.Hit.p);
						local percent = math.clamp(mousePos.X - slider.SlideBar.AbsolutePosition.X, 0, slider.Main.AbsoluteSize.X) / slider.Main.AbsoluteSize.X;
						local value = math.floor((slider.min + ((slider.max - slider.min) * percent)) * slider.decimals) / slider.decimals;
						value = math.clamp(value, slider.min, slider.max);
						slider:Set(value);
					end;
					slider.SlideBar.InputBegan:Connect(function(input)
						if (input.UserInputType == Enum.UserInputType.MouseButton1) then
							dragging = true;
							slider:Refresh();
						end
					end);
					slider.SlideBar.InputEnded:Connect(function(input)
						if (input.UserInputType == Enum.UserInputType.MouseButton1) then
							dragging = false;
						end
					end);
					slider.Main.InputBegan:Connect(function(input)
						if (input.UserInputType == Enum.UserInputType.MouseButton1) then
							dragging = true;
							slider:Refresh();
						end
					end);
					slider.Main.InputEnded:Connect(function(input)
						if (input.UserInputType == Enum.UserInputType.MouseButton1) then
							dragging = false;
						end
					end);
					uis.InputChanged:Connect(function(input)
						if (dragging and (input.UserInputType == Enum.UserInputType.MouseMovement)) then
							slider:Refresh();
						end
					end);
					sector:FixSize();
					table.insert(library.items, slider);
					return slider;
				end;
				toggle.Main.MouseButton1Down:Connect(function()
					toggle:Set(not toggle.CheckedFrame.Visible);
				end);
				toggle.Label.InputBegan:Connect(function(input)
					if (input.UserInputType == Enum.UserInputType.MouseButton1) then
						toggle:Set(not toggle.CheckedFrame.Visible);
					end
				end);
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
					slider.value = math.clamp(math.round(value * slider.decimals) / slider.decimals, slider.min, slider.max);
					local percent = 1 - ((slider.max - slider.value) / (slider.max - slider.min));
					if (slider.flag and (slider.flag ~= "")) then
						library.flags[slider.flag] = slider.value;
					end
					slider.SlideBar:TweenSize(UDim2.fromOffset(percent * slider.Main.AbsoluteSize.X, slider.Main.AbsoluteSize.Y), Enum.EasingDirection.In, Enum.EasingStyle.Sine, 0.05);
					slider.InputLabel.Text = slider.value;
					pcall(slider.callback, slider.value);
				end;
				slider:Set(slider.default);
				slider.InputLabel.FocusLost:Connect(function(Return)
					if not Return then
						return;
					end
					if (slider.InputLabel.Text:match("^%d+$")) then
						slider:Set(tonumber(slider.InputLabel.Text));
					else
						slider.InputLabel.Text = tostring(slider.value);
					end
				end);
				slider.Refresh = function(self)
					local mousePos = camera:WorldToViewportPoint(mouse.Hit.p);
					local percent = math.clamp(mousePos.X - slider.SlideBar.AbsolutePosition.X, 0, slider.Main.AbsoluteSize.X) / slider.Main.AbsoluteSize.X;
					local value = math.floor((slider.min + ((slider.max - slider.min) * percent)) * slider.decimals) / slider.decimals;
					value = math.clamp(value, slider.min, slider.max);
					slider:Set(value);
				end;
				slider.SlideBar.InputBegan:Connect(function(input)
					if (input.UserInputType == Enum.UserInputType.MouseButton1) then
						dragging = true;
						slider:Refresh();
					end
				end);
				slider.SlideBar.InputEnded:Connect(function(input)
					if (input.UserInputType == Enum.UserInputType.MouseButton1) then
						dragging = false;
					end
				end);
				slider.Main.InputBegan:Connect(function(input)
					if (input.UserInputType == Enum.UserInputType.MouseButton1) then
						dragging = true;
						slider:Refresh();
					end
				end);
				slider.Main.InputEnded:Connect(function(input)
					if (input.UserInputType == Enum.UserInputType.MouseButton1) then
						dragging = false;
					end
				end);
				uis.InputChanged:Connect(function(input)
					if (dragging and (input.UserInputType == Enum.UserInputType.MouseMovement)) then
						slider:Refresh();
					end
				end);
				sector:FixSize();
				table.insert(library.items, slider);
				return slider;
			end;
			sector.AddColorpicker = function(self, text, default, callback, flag)
				local colorpicker = {};
				colorpicker.text = text or "";
				colorpicker.callback = callback or function()
				end;
				colorpicker.default = default or Color3.fromRGB(255, 255, 255);
				colorpicker.value = colorpicker.default;
				colorpicker.flag = flag or text or "";
				colorpicker.Label = Instance.new("TextLabel", sector.Items);
				colorpicker.Label.BackgroundTransparency = 1;
				colorpicker.Label.Size = UDim2.fromOffset(156, 10);
				colorpicker.Label.ZIndex = 4;
				colorpicker.Label.Font = window.theme.font;
				colorpicker.Label.Text = colorpicker.text;
				colorpicker.Label.TextColor3 = window.theme.itemscolor;
				colorpicker.Label.TextSize = 15;
				colorpicker.Label.TextStrokeTransparency = 1;
				colorpicker.Label.TextXAlignment = Enum.TextXAlignment.Left;
				updateevent.Event:Connect(function(theme)
					colorpicker.Label.Font = theme.font;
					colorpicker.Label.TextColor3 = theme.itemscolor;
				end);
				colorpicker.Main = Instance.new("Frame", colorpicker.Label);
				colorpicker.Main.ZIndex = 6;
				colorpicker.Main.BorderSizePixel = 0;
				colorpicker.Main.Position = UDim2.fromOffset(sector.Main.Size.X.Offset - 29, 0);
				colorpicker.Main.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
				colorpicker.Main.Size = UDim2.fromOffset(16, 10);
				colorpicker.Gradient = Instance.new("UIGradient", colorpicker.Main);
				colorpicker.Gradient.Rotation = 90;
				local clr = Color3.new(math.clamp(colorpicker.value.R / 1.7, 0, 1), math.clamp(colorpicker.value.G / 1.7, 0, 1), math.clamp(colorpicker.value.B / 1.7, 0, 1));
				colorpicker.Gradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, colorpicker.value),ColorSequenceKeypoint.new(1, clr)});
				colorpicker.BlackOutline2 = Instance.new("Frame", colorpicker.Main);
				colorpicker.BlackOutline2.Name = "blackline";
				colorpicker.BlackOutline2.ZIndex = 4;
				colorpicker.BlackOutline2.Size = colorpicker.Main.Size + UDim2.fromOffset(6, 6);
				colorpicker.BlackOutline2.BorderSizePixel = 0;
				colorpicker.BlackOutline2.BackgroundColor3 = window.theme.outlinecolor2;
				colorpicker.BlackOutline2.Position = UDim2.fromOffset(-3, -3);
				updateevent.Event:Connect(function(theme)
					colorpicker.BlackOutline2.BackgroundColor3 = (window.OpenedColorPickers[colorpicker.MainPicker] and theme.accentcolor) or theme.outlinecolor2;
				end);
				colorpicker.Outline = Instance.new("Frame", colorpicker.Main);
				colorpicker.Outline.Name = "blackline";
				colorpicker.Outline.ZIndex = 4;
				colorpicker.Outline.Size = colorpicker.Main.Size + UDim2.fromOffset(4, 4);
				colorpicker.Outline.BorderSizePixel = 0;
				colorpicker.Outline.BackgroundColor3 = window.theme.outlinecolor;
				colorpicker.Outline.Position = UDim2.fromOffset(-2, -2);
				updateevent.Event:Connect(function(theme)
					colorpicker.Outline.BackgroundColor3 = theme.outlinecolor;
				end);
				colorpicker.BlackOutline = Instance.new("Frame", colorpicker.Main);
				colorpicker.BlackOutline.Name = "blackline";
				colorpicker.BlackOutline.ZIndex = 4;
				colorpicker.BlackOutline.Size = colorpicker.Main.Size + UDim2.fromOffset(2, 2);
				colorpicker.BlackOutline.BorderSizePixel = 0;
				colorpicker.BlackOutline.BackgroundColor3 = window.theme.outlinecolor2;
				colorpicker.BlackOutline.Position = UDim2.fromOffset(-1, -1);
				updateevent.Event:Connect(function(theme)
					colorpicker.BlackOutline.BackgroundColor3 = theme.outlinecolor2;
				end);
				colorpicker.BlackOutline2.MouseEnter:Connect(function()
					colorpicker.BlackOutline2.BackgroundColor3 = window.theme.accentcolor;
				end);
				colorpicker.BlackOutline2.MouseLeave:Connect(function()
					if not window.OpenedColorPickers[colorpicker.MainPicker] then
						colorpicker.BlackOutline2.BackgroundColor3 = window.theme.outlinecolor2;
					end
				end);
				colorpicker.MainPicker = Instance.new("TextButton", colorpicker.Main);
				colorpicker.MainPicker.Name = "picker";
				colorpicker.MainPicker.ZIndex = 100;
				colorpicker.MainPicker.Visible = false;
				colorpicker.MainPicker.AutoButtonColor = false;
				colorpicker.MainPicker.Text = "";
				window.OpenedColorPickers[colorpicker.MainPicker] = false;
				colorpicker.MainPicker.Size = UDim2.fromOffset(180, 196);
				colorpicker.MainPicker.BorderSizePixel = 0;
				colorpicker.MainPicker.BackgroundColor3 = Color3.fromRGB(40, 40, 40);
				colorpicker.MainPicker.Rotation = 1e-15;
				colorpicker.MainPicker.Position = UDim2.fromOffset(-colorpicker.MainPicker.AbsoluteSize.X + colorpicker.Main.AbsoluteSize.X, 15);
				colorpicker.BlackOutline3 = Instance.new("Frame", colorpicker.MainPicker);
				colorpicker.BlackOutline3.Name = "blackline";
				colorpicker.BlackOutline3.ZIndex = 98;
				colorpicker.BlackOutline3.Size = colorpicker.MainPicker.Size + UDim2.fromOffset(6, 6);
				colorpicker.BlackOutline3.BorderSizePixel = 0;
				colorpicker.BlackOutline3.BackgroundColor3 = window.theme.outlinecolor2;
				colorpicker.BlackOutline3.Position = UDim2.fromOffset(-3, -3);
				updateevent.Event:Connect(function(theme)
					colorpicker.BlackOutline3.BackgroundColor3 = theme.outlinecolor2;
				end);
				colorpicker.Outline2 = Instance.new("Frame", colorpicker.MainPicker);
				colorpicker.Outline2.Name = "blackline";
				colorpicker.Outline2.ZIndex = 98;
				colorpicker.Outline2.Size = colorpicker.MainPicker.Size + UDim2.fromOffset(4, 4);
				colorpicker.Outline2.BorderSizePixel = 0;
				colorpicker.Outline2.BackgroundColor3 = window.theme.outlinecolor;
				colorpicker.Outline2.Position = UDim2.fromOffset(-2, -2);
				updateevent.Event:Connect(function(theme)
					colorpicker.Outline2.BackgroundColor3 = theme.outlinecolor;
				end);
				colorpicker.BlackOutline3 = Instance.new("Frame", colorpicker.MainPicker);
				colorpicker.BlackOutline3.Name = "blackline";
				colorpicker.BlackOutline3.ZIndex = 98;
				colorpicker.BlackOutline3.Size = colorpicker.MainPicker.Size + UDim2.fromOffset(2, 2);
				colorpicker.BlackOutline3.BorderSizePixel = 0;
				colorpicker.BlackOutline3.BackgroundColor3 = window.theme.outlinecolor2;
				colorpicker.BlackOutline3.Position = UDim2.fromOffset(-1, -1);
				updateevent.Event:Connect(function(theme)
					colorpicker.BlackOutline3.BackgroundColor3 = theme.outlinecolor2;
				end);
				colorpicker.hue = Instance.new("ImageLabel", colorpicker.MainPicker);
				colorpicker.hue.ZIndex = 101;
				colorpicker.hue.Position = UDim2.new(0, 3, 0, 3);
				colorpicker.hue.Size = UDim2.new(0, 172, 0, 172);
				colorpicker.hue.Image = "rbxassetid://4155801252";
				colorpicker.hue.ScaleType = Enum.ScaleType.Stretch;
				colorpicker.hue.BackgroundColor3 = Color3.new(1, 0, 0);
				colorpicker.hue.BorderColor3 = window.theme.outlinecolor2;
				updateevent.Event:Connect(function(theme)
					colorpicker.hue.BorderColor3 = theme.outlinecolor2;
				end);
				colorpicker.hueselectorpointer = Instance.new("ImageLabel", colorpicker.MainPicker);
				colorpicker.hueselectorpointer.ZIndex = 101;
				colorpicker.hueselectorpointer.BackgroundTransparency = 1;
				colorpicker.hueselectorpointer.BorderSizePixel = 0;
				colorpicker.hueselectorpointer.Position = UDim2.new(0, 0, 0, 0);
				colorpicker.hueselectorpointer.Size = UDim2.new(0, 7, 0, 7);
				colorpicker.hueselectorpointer.Image = "rbxassetid://6885856475";
				colorpicker.selector = Instance.new("TextLabel", colorpicker.MainPicker);
				colorpicker.selector.ZIndex = 100;
				colorpicker.selector.Position = UDim2.new(0, 3, 0, 181);
				colorpicker.selector.Size = UDim2.new(0, 173, 0, 10);
				colorpicker.selector.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
				colorpicker.selector.BorderColor3 = window.theme.outlinecolor2;
				colorpicker.selector.Text = "";
				updateevent.Event:Connect(function(theme)
					colorpicker.selector.BorderColor3 = theme.outlinecolor2;
				end);
				colorpicker.gradient = Instance.new("UIGradient", colorpicker.selector);
				colorpicker.gradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.new(1, 0, 0)),ColorSequenceKeypoint.new(0.17, Color3.new(1, 0, 1)),ColorSequenceKeypoint.new(0.33, Color3.new(0, 0, 1)),ColorSequenceKeypoint.new(0.5, Color3.new(0, 1, 1)),ColorSequenceKeypoint.new(0.67, Color3.new(0, 1, 0)),ColorSequenceKeypoint.new(0.83, Color3.new(1, 1, 0)),ColorSequenceKeypoint.new(1, Color3.new(1, 0, 0))});
				colorpicker.pointer = Instance.new("Frame", colorpicker.selector);
				colorpicker.pointer.ZIndex = 101;
				colorpicker.pointer.BackgroundColor3 = Color3.fromRGB(40, 40, 40);
				colorpicker.pointer.Position = UDim2.new(0, 0, 0, 0);
				colorpicker.pointer.Size = UDim2.new(0, 2, 0, 10);
				colorpicker.pointer.BorderColor3 = Color3.fromRGB(255, 255, 255);
				if (colorpicker.flag and (colorpicker.flag ~= "")) then
					library.flags[colorpicker.flag] = colorpicker.default;
				end
				colorpicker.RefreshSelector = function(self)
					local pos = math.clamp((mouse.X - colorpicker.hue.AbsolutePosition.X) / colorpicker.hue.AbsoluteSize.X, 0, 1);
					colorpicker.color = 1 - pos;
					colorpicker.pointer:TweenPosition(UDim2.new(pos, 0, 0, 0), Enum.EasingDirection.In, Enum.EasingStyle.Sine, 0.05);
					colorpicker.hue.BackgroundColor3 = Color3.fromHSV(1 - pos, 1, 1);
				end;
				colorpicker.RefreshHue = function(self)
					local x = (mouse.X - colorpicker.hue.AbsolutePosition.X) / colorpicker.hue.AbsoluteSize.X;
					local y = (mouse.Y - colorpicker.hue.AbsolutePosition.Y) / colorpicker.hue.AbsoluteSize.Y;
					colorpicker.hueselectorpointer:TweenPosition(UDim2.new(math.clamp(x * colorpicker.hue.AbsoluteSize.X, 0.5, 0.952 * colorpicker.hue.AbsoluteSize.X) / colorpicker.hue.AbsoluteSize.X, 0, math.clamp(y * colorpicker.hue.AbsoluteSize.Y, 0.5, 0.885 * colorpicker.hue.AbsoluteSize.Y) / colorpicker.hue.AbsoluteSize.Y, 0), Enum.EasingDirection.In, Enum.EasingStyle.Sine, 0.05);
					colorpicker:Set(Color3.fromHSV(colorpicker.color, math.clamp(x * colorpicker.hue.AbsoluteSize.X, 0.5, 1 * colorpicker.hue.AbsoluteSize.X) / colorpicker.hue.AbsoluteSize.X, 1 - (math.clamp(y * colorpicker.hue.AbsoluteSize.Y, 0.5, 1 * colorpicker.hue.AbsoluteSize.Y) / colorpicker.hue.AbsoluteSize.Y)));
				end;
				colorpicker.Set = function(self, value)
					local color = Color3.new(math.clamp(value.r, 0, 1), math.clamp(value.g, 0, 1), math.clamp(value.b, 0, 1));
					colorpicker.value = color;
					if (colorpicker.flag and (colorpicker.flag ~= "")) then
						library.flags[colorpicker.flag] = color;
					end
					local clr = Color3.new(math.clamp(color.R / 1.7, 0, 1), math.clamp(color.G / 1.7, 0, 1), math.clamp(color.B / 1.7, 0, 1));
					colorpicker.Gradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, color),ColorSequenceKeypoint.new(1, clr)});
					pcall(colorpicker.callback, color);
				end;
				colorpicker.Get = function(self)
					return colorpicker.value;
				end;
				colorpicker:Set(colorpicker.default);
				colorpicker.AddDropdown = function(self, items, default, multichoice, callback, flag)
					local dropdown = {};
					dropdown.defaultitems = items or {};
					dropdown.default = default;
					dropdown.callback = callback or function()
					end;
					dropdown.multichoice = multichoice or false;
					dropdown.values = {};
					dropdown.flag = flag or ((colorpicker.text or "") .. tostring(#(sector.Items:GetChildren())));
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
					dropdown.SelectedLabel.Text = colorpicker.text;
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
					dropdown.BlackOutline.Name = "blackline";
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
					dropdown.BlackOutline2Items.Name = "blackline";
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
					dropdown.OutlineItems.Name = "blackline";
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
					dropdown.BlackOutlineItems.Name = "blackline";
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
						runservice.RenderStepped:Connect(function()
							if ((dropdown.multichoice and dropdown:isSelected(v)) or (dropdown.values[1] == v)) then
								Item.BackgroundColor3 = Color3.fromRGB(64, 64, 64);
								Item.TextColor3 = window.theme.accentcolor;
								Item.Text = " " .. v;
							else
								Item.BackgroundColor3 = Color3.fromRGB(40, 40, 40);
								Item.TextColor3 = Color3.fromRGB(255, 255, 255);
								Item.Text = v;
							end
						end);
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
							dropdown.ItemsFrame.ScrollingEnabled = true;
							sector.Main.Parent.ScrollingEnabled = false;
							tweenservice:Create(dropdown.Nav, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Rotation=-90}):Play();
							dropdown.ItemsFrame.Visible = true;
							dropdown.ItemsFrame.Active = true;
							dropdown.IgnoreBackButtons.Visible = true;
							dropdown.IgnoreBackButtons.Active = true;
							dropdown.OutlineItems.Visible = true;
							dropdown.BlackOutlineItems.Visible = true;
							dropdown.BlackOutline2Items.Visible = true;
						else
							dropdown.ItemsFrame.ScrollingEnabled = false;
							sector.Main.Parent.ScrollingEnabled = true;
							tweenservice:Create(dropdown.Nav, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Rotation=90}):Play();
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
				local dragging_selector = false;
				local dragging_hue = false;
				colorpicker.selector.InputBegan:Connect(function(input)
					if (input.UserInputType == Enum.UserInputType.MouseButton1) then
						dragging_selector = true;
						colorpicker:RefreshSelector();
					end
				end);
				colorpicker.selector.InputEnded:Connect(function(input)
					if (input.UserInputType == Enum.UserInputType.MouseButton1) then
						dragging_selector = false;
						colorpicker:RefreshSelector();
					end
				end);
				colorpicker.hue.InputBegan:Connect(function(input)
					if (input.UserInputType == Enum.UserInputType.MouseButton1) then
						dragging_hue = true;
						colorpicker:RefreshHue();
					end
				end);
				colorpicker.hue.InputEnded:Connect(function(input)
					if (input.UserInputType == Enum.UserInputType.MouseButton1) then
						dragging_hue = false;
						colorpicker:RefreshHue();
					end
				end);
				uis.InputChanged:Connect(function(input)
					if (dragging_selector and (input.UserInputType == Enum.UserInputType.MouseMovement)) then
						colorpicker:RefreshSelector();
					end
					if (dragging_hue and (input.UserInputType == Enum.UserInputType.MouseMovement)) then
						colorpicker:RefreshHue();
					end
				end);
				local inputBegan = function(input)
					if (input.UserInputType == Enum.UserInputType.MouseButton1) then
						for i, v in pairs(window.OpenedColorPickers) do
							if (v and (i ~= colorpicker.MainPicker)) then
								i.Visible = false;
								window.OpenedColorPickers[i] = false;
							end
						end
						colorpicker.MainPicker.Visible = not colorpicker.MainPicker.Visible;
						window.OpenedColorPickers[colorpicker.MainPicker] = colorpicker.MainPicker.Visible;
						if window.OpenedColorPickers[colorpicker.MainPicker] then
							colorpicker.BlackOutline2.BackgroundColor3 = window.theme.accentcolor;
						else
							colorpicker.BlackOutline2.BackgroundColor3 = window.theme.outlinecolor2;
						end
					end
				end;
				colorpicker.Main.InputBegan:Connect(inputBegan);
				colorpicker.Outline.InputBegan:Connect(inputBegan);
				colorpicker.BlackOutline2.InputBegan:Connect(inputBegan);
				sector:FixSize();
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
				dropdown.SelectedLabel.Text = dropdown.text;
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
				dropdown.BlackOutline.Name = "blackline";
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
				dropdown.BlackOutline2Items.Name = "blackline";
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
				dropdown.OutlineItems.Name = "blackline";
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
				dropdown.BlackOutlineItems.Name = "blackline";
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
				dropdown.GetOptions = function(self)
					return dropdown.values;
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
					Item.ZIndex = 56;
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
							dropdown.Nav.Rotation = 90;
							dropdown.ItemsFrame.Visible = false;
							dropdown.ItemsFrame.Active = false;
							dropdown.OutlineItems.Visible = false;
							dropdown.BlackOutlineItems.Visible = false;
							dropdown.BlackOutline2Items.Visible = false;
							dropdown.IgnoreBackButtons.Visible = false;
							dropdown.IgnoreBackButtons.Active = false;
							dropdown.MainBack.ZIndex = 7;
							dropdown.Main.ZIndex = 5;
							sector.Main.Parent.ScrollingEnabled = true;
						end
						dropdown:Set(v);
						return;
					end

					Item.MouseButton1Down:Connect(onSelect);
					Item.MouseButton1Click:Connect(onSelect);
					pcall(function()
						if Item.Activated then
							Item.Activated:Connect(onSelect);
						end
					end);

					runservice.RenderStepped:Connect(function()
						if ((dropdown.multichoice and dropdown:isSelected(v)) or (dropdown.values[1] == v)) then
							Item.BackgroundColor3 = Color3.fromRGB(64, 64, 64);
							Item.TextColor3 = window.theme.accentcolor;
							Item.Text = " " .. v;
						else
							Item.BackgroundColor3 = Color3.fromRGB(40, 40, 40);
							Item.TextColor3 = Color3.fromRGB(255, 255, 255);
							Item.Text = v;
						end
					end);
					table.insert(dropdown.items, v);
					local totalH = (#dropdown.items * 20) + 4;
					dropdown.ItemsFrame.Size = UDim2.fromOffset(dropdown.Main.Size.X.Offset, math.clamp(totalH, 20, 156));
					dropdown.ItemsFrame.CanvasSize = UDim2.fromOffset(0, totalH);
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
						local totalH = (#dropdown.items * 20) + 4;
						dropdown.ItemsFrame.Size = UDim2.fromOffset(dropdown.Main.Size.X.Offset, math.clamp(totalH, 20, 156));
						dropdown.ItemsFrame.CanvasSize = UDim2.fromOffset(0, totalH);
						dropdown.OutlineItems.Size = dropdown.ItemsFrame.Size + UDim2.fromOffset(4, 4);
						dropdown.BlackOutlineItems.Size = dropdown.ItemsFrame.Size + UDim2.fromOffset(2, 2);
						dropdown.BlackOutline2Items.Size = dropdown.ItemsFrame.Size + UDim2.fromOffset(6, 6);
						dropdown.IgnoreBackButtons.Size = dropdown.ItemsFrame.Size;
						item:Remove();
					end
				end;
				dropdown.getList = function(self)
					return dropdown.items;
				end;
				dropdown.Clear = function(self)
					for _, item in pairs(dropdown.ItemsFrame:GetChildren()) do
						if item:IsA("TextButton") then
							item:Destroy()
						end
					end
					dropdown.items = {}
					dropdown.ItemsFrame.Size = UDim2.fromOffset(dropdown.Main.Size.X.Offset, 20)
					dropdown.ItemsFrame.CanvasSize = UDim2.fromOffset(0, 0)
					dropdown.OutlineItems.Size = dropdown.ItemsFrame.Size + UDim2.fromOffset(4, 4);
					dropdown.BlackOutlineItems.Size = dropdown.ItemsFrame.Size + UDim2.fromOffset(2, 2);
					dropdown.BlackOutline2Items.Size = dropdown.ItemsFrame.Size + UDim2.fromOffset(6, 6);
					dropdown.IgnoreBackButtons.Size = dropdown.ItemsFrame.Size;
				end;
				dropdown.Refresh = function(self, newItems)
					local currentVal = (dropdown.values and dropdown.values[1]) or dropdown.default
					dropdown:Clear()
					for _, v in ipairs(newItems or {}) do
						dropdown:Add(v)
					end
					local found = false
					if currentVal and newItems then
						for _, itm in ipairs(newItems) do
							if itm == currentVal then
								found = true
								break
							end
						end
					end
					if found then
						dropdown:Set(currentVal)
					elseif newItems and newItems[1] then
						dropdown:Set(newItems[1])
					end
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
							dropdown.MainBack.ZIndex = 50;
							dropdown.Main.ZIndex = 51;
							dropdown.ItemsFrame.ZIndex = 55;
							dropdown.OutlineItems.ZIndex = 53;
							dropdown.BlackOutlineItems.ZIndex = 53;
							dropdown.BlackOutline2Items.ZIndex = 52;
							dropdown.IgnoreBackButtons.ZIndex = 51;
							dropdown.ItemsFrame.ScrollingEnabled = true;
							sector.Main.Parent.ScrollingEnabled = false;
							dropdown.ItemsFrame.Visible = true;
							dropdown.ItemsFrame.Active = true;
							dropdown.IgnoreBackButtons.Visible = false;
							dropdown.IgnoreBackButtons.Active = false;
							dropdown.OutlineItems.Visible = true;
							dropdown.BlackOutlineItems.Visible = true;
							dropdown.BlackOutline2Items.Visible = true;
							for _, child in pairs(dropdown.ItemsFrame:GetChildren()) do
								if child:IsA("TextButton") then
									child.ZIndex = 56;
								end
							end
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
						dropdown.MainBack.ZIndex = 7;
						dropdown.Main.ZIndex = 5;
						dropdown.ItemsFrame.ZIndex = 8;
						dropdown.OutlineItems.ZIndex = 7;
						dropdown.BlackOutlineItems.ZIndex = 7;
						dropdown.BlackOutline2Items.ZIndex = 7;
						dropdown.IgnoreBackButtons.ZIndex = 7;
						for _, child in pairs(dropdown.ItemsFrame:GetChildren()) do
							if child:IsA("TextButton") then
								child.ZIndex = 9;
							end
						end
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
			makefolder("!SLH_Hub");
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
	GuiStat.Parent = game:GetService("CoreGui");
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

	IconButton_3.MouseButton1Click:Connect(function()
		for i, v in pairs(game:GetService("CoreGui"):GetChildren()) do
			if v:FindFirstChild("main") then
				v.main.Visible = not v.main.Visible;
			end
		end
	end);

	-- FPS & Ping Loop (Không Rainbow, siêu nhẹ)
	local RS = game:GetService("RunService");
	local frames = 0;
	RS.RenderStepped:Connect(function()
		frames = frames + 1;
	end);

	task.spawn(function()
		pcall(function()
			while task.wait(1) do
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
	end);
end
        return library;
    end)();

    local function getGMT7Time(fmt)
        return os.date(fmt or "%H:%M:%S (%d/%m/%Y)", os.time() + (7 * 3600))
    end
    local function Notification(mode, title, text, duration)
        pcall(function()
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = tostring(title or "SuiSuiHUB"),
                Text = tostring(text or ""),
                Duration = tonumber(duration or 5)
            })
        end)
        print(string.format("[%s] %s", tostring(title or "SuiSuiHUB"), tostring(text or "")))
    end
    _G.Notification = Notification
    pcall(function() if getgenv then getgenv().Notification = Notification end end)
    local function GetAvailableMaps()
        local maps = {}
        local seen = {}

        local function addMap(rawName)
            if type(rawName) ~= "string" then return end
            local name = rawName:gsub("^%s+", ""):gsub("%s+$", "")
            if #name == 0 then return end
            local lower = name:lower()

            -- 1. TUYET DOI KHONG LAY RAID CHO MAP SELECTION
            if lower:find("raid") then return end

            -- 2. Loc bo cac UI component / template
            if lower:find("template") 
               or lower:find("frame") 
               or lower:find("scrolling") 
               or lower:find("button") 
               or lower:find("layout") 
               or lower:find("grid") 
               or lower:find("corner") 
               or lower:find("shadow") 
               or lower:find("padding") 
               or lower:find("back") 
               or lower:find("close") 
               or lower:find("textlabel") 
               or lower:find("bossrush") 
               or lower:find("speedraid") then
                return
            end

            -- 3. Chi nhan Dimension hoac Infinite Mode / TimeChallenge
            if lower:find("dimension") or lower == "infinite mode" or lower == "timechallenge" then
                if not seen[name] then
                    seen[name] = true
                    table.insert(maps, name)
                end
            end
        end

        -- Chi quet MapSelectionScrollingFrame khi o sanh thuong (PlaceId ~= 7338881230)
        if game.PlaceId ~= 7338881230 then
            pcall(function()
                local pg = localPlayer:FindFirstChild("PlayerGui")
                local mg = pg and pg:FindFirstChild("MainGui")
                local cf = mg and mg:FindFirstChild("CenterUIFrame")
                local pf = cf and cf:FindFirstChild("PlayFrame")
                local fr = pf and pf:FindFirstChild("Frame")
                local prf = fr and fr:FindFirstChild("PlayRoomFrame")
                local mapFrame = prf and prf:FindFirstChild("MapSelectionScrollingFrame")
                if mapFrame then
                    for _, v in ipairs(mapFrame:GetChildren()) do
                        if v:IsA("ImageButton") or v:IsA("TextButton") then
                            addMap(v.Name)
                        end
                    end
                end
            end)
        end

        -- Danh sach chuan cac Dimension thuong (Titan Dimension dung dau lam mac dinh farm)
        local defaultMaps = {
            "Titan Dimension",
            "Demon Dimension",
            "Dragon Dimension",
            "Hero Dimension",
            "Curse Dimension",
            "Sword Dimension",
            "Ghoul Dimension",
            "Soul Dimension",
            "Bleach Dimension",
            "Slime Dimension",
            "Fate Dimension",
            "Devil Dimension",
            "Pirate Dimension",
            "Hunter Dimension",
            "Shield Dimension",
            "Vampire Dimension",
            "Alien Dimension",
            "Chainsaw Dimension",
            "Shadow Dimension",
            "Halloween Dimension",
            "Summer Dimension",
            "Winter Dimension",
            "Infinite Mode",
            "TimeChallenge"
        }
        for _, def in ipairs(defaultMaps) do
            addMap(def)
        end

        table.sort(maps, function(a, b)
            return a:lower() < b:lower()
        end)

        return maps
    end

    local function GetAvailableRaids()
        local raids = {}
        local seen = {}

        local function addRaid(rawName)
            if type(rawName) ~= "string" then return end
            local name = rawName:gsub("^%s+", ""):gsub("%s+$", "")
            if #name == 0 then return end
            local lower = name:lower()

            -- 1. BAT BUOC LA RAID
            if not lower:find("raid") then return end

            -- 2. Loc bo cac UI component
            if lower:find("template") 
               or lower:find("frame") 
               or lower:find("scrolling") 
               or lower:find("button") 
               or lower:find("layout") 
               or lower:find("grid") 
               or lower:find("corner") 
               or lower:find("shadow") 
               or lower:find("padding") 
               or lower:find("back") 
               or lower:find("close") 
               or lower:find("textlabel") then
                return
            end

            if not seen[name] then
                seen[name] = true
                table.insert(raids, name)
            end
        end

        -- 1. Quet truc tiep tu PlayRoomFrame (uu tien khi o sanh Raid 7338881230)
        pcall(function()
            local pg = localPlayer:FindFirstChild("PlayerGui")
            local mg = pg and pg:FindFirstChild("MainGui")
            local cf = mg and mg:FindFirstChild("CenterUIFrame")
            local pf = cf and cf:FindFirstChild("PlayFrame")
            local fr = pf and pf:FindFirstChild("Frame")
            local prf = fr and fr:FindFirstChild("PlayRoomFrame")
            local mapFrame = prf and prf:FindFirstChild("MapSelectionScrollingFrame")
            if mapFrame then
                for _, v in ipairs(mapFrame:GetChildren()) do
                    if v:IsA("ImageButton") or v:IsA("TextButton") then
                        addRaid(v.Name)
                    end
                end
            end
        end)

        -- 2. Quet cac ScrollingFrame chua Raid trong PlayerGui
        pcall(function()
            local pg = localPlayer:FindFirstChild("PlayerGui")
            if pg then
                for _, d in ipairs(pg:GetDescendants()) do
                    if d:IsA("ScrollingFrame") and d.Name:lower():find("raid") then
                        for _, btn in ipairs(d:GetChildren()) do
                            if btn:IsA("ImageButton") or btn:IsA("TextButton") then
                                addRaid(btn.Name)
                            end
                        end
                    end
                end
            end
        end)

        -- 3. Danh sach day du toan bo Bi Canh Raid chuan Anime Dimensions Simulator (Fallback)
        local defaultRaids = {
            "Goddess Madoki Raid",
            "Chainsaw Raid",
            "Demon King Raid",
            "Shadow Raid",
            "Curse Raid",
            "Titan Raid",
            "Dragon Raid",
            "Fate Raid",
            "Hero Raid",
            "Jujutsu Raid",
            "Bleach Raid",
            "One Piece Raid",
            "Naruto Raid",
            "Slime Raid",
            "Halloween Raid",
            "Summer Raid",
            "Winter Raid",
            "Christmas Raid",
            "Fairy Raid",
            "Shield Raid",
            "Ghoul Raid",
            "Esper Raid",
            "Vampire Raid",
            "Alien Raid",
            "Sword Raid",
            "Hunter Raid",
            "Kaiju Raid",
            "Solo Raid",
            "Red Dragon Raid",
            "Cursed Spirit Raid",
            "Destruction Raid",
            "Slayer Raid",
            "Academy Raid",
            "Cosmic Raid",
            "Reaper Raid"
        }
        for _, def in ipairs(defaultRaids) do
            addRaid(def)
        end

        table.sort(raids, function(a, b)
            return a:lower() < b:lower()
        end)

        return raids
    end

    local function GetAvailableCapsules()
        local capsules = {}
        local seen = {}

        local function addCapsule(rawName)
            if type(rawName) ~= "string" then return end
            local name = rawName:gsub("^%s+", ""):gsub("%s+$", "")
            if #name == 0 then return end
            local lower = name:lower()
            if (lower:find("capsule") or lower:find("egg")) 
               and not lower:find("template") 
               and not lower:find("frame") 
               and not lower:find("holder") 
               and not lower:find("scroll") 
               and not lower:find("shadow") 
               and not lower:find("image") 
               and not lower:find("button") 
               and not lower:find("layout") 
               and not lower:find("corner") 
               and not lower:find("grid") then
                if not seen[name] then
                    seen[name] = true
                    table.insert(capsules, name)
                end
            end
        end

        pcall(function()
            local rep = game:GetService("ReplicatedStorage")
            for _, folder in ipairs(rep:GetChildren()) do
                local fn = folder.Name:lower()
                if fn:find("capsule") or fn:find("pet") or fn:find("egg") or fn:find("shop") or fn:find("item") then
                    for _, item in ipairs(folder:GetChildren()) do
                        addCapsule(item.Name)
                    end
                    addCapsule(folder.Name)
                end
            end
        end)

        pcall(function()
            local ws = game:GetService("Workspace")
            for _, obj in ipairs(ws:GetDescendants()) do
                if obj:IsA("Model") or obj:IsA("Folder") or obj:IsA("Configuration") then
                    if obj.Name:lower():find("capsule") then
                        addCapsule(obj.Name)
                    end
                elseif obj:IsA("TextLabel") and obj.Parent and obj.Parent:IsA("BillboardGui") then
                    if obj.Text:lower():find("capsule") then
                        local firstLine = obj.Text:split("\n")[1] or obj.Text
                        addCapsule(firstLine:gsub("%[.-%]", ""))
                    end
                end
            end
        end)

        pcall(function()
            local pgui = game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui")
            if pgui then
                for _, d in ipairs(pgui:GetDescendants()) do
                    if d.Name:lower():find("capsule") then
                        addCapsule(d.Name)
                    end
                    if (d:IsA("TextLabel") or d:IsA("TextButton")) and d.Text:lower():find("capsule") then
                        local firstLine = d.Text:split("\n")[1] or d.Text
                        addCapsule(firstLine:gsub("%[.-%]", ""))
                    end
                end
            end
        end)

        local defaultCapsules = {
            "Gear 5 Fluffy Capsule",
            "Matsuri Capsule",
            "Chainsaw Capsule",
            "Shadow Capsule",
            "Demon Capsule",
            "Dragon Capsule",
            "Titan Capsule",
            "Cursed Capsule",
            "Alien Capsule",
            "Vampire Capsule",
            "Basic Capsule"
        }
        for _, def in ipairs(defaultCapsules) do
            addCapsule(def)
        end

        table.sort(capsules)
        return capsules
    end
    MapSelection = GetAvailableMaps()
    RaidSelection = GetAvailableRaids()
    PetCapsuleSelection = GetAvailableCapsules()
    _G.SelectedCapsule = PetCapsuleSelection[1] or "Gear 5 Fluffy Capsule"
    _G.RaidSelection = _G.RaidSelection or "Goddess Madoki Raid"
    _G.MapSelection = _G.MapSelection or "Titan Dimension"
    _G.PetSpinDelay = 1.0
    _G.SpinHalloweenDelay = 1.0
    _G.Method = _G.Method or "Behind"
    _G.Distance = _G.Distance or 6
    _G.TWSpeed = _G.TWSpeed or "200"
    _G.Automob = true
    _G.DistanceToSkill = _G.DistanceToSkill or 30
    _G.AutoSkill = true
    _G.AutoAssistSkill = true
    _G.AutoFruit = true
    _G.SelectAttackMethod = _G.SelectAttackMethod or "Remote"
    _G.AutoMelee = true
    _G.SkillDelay = 0.2
    _G.AssistSkillDelay = 0.8
    _G.FruitDelay = 0.8
    _G.MeleeDelay = 0.05
    _G.Replay = true

    local tbSkillDelay1, tbAssistDelay1, tbFruitDelay1
    local tbSkillDelay2, tbAssistDelay2, tbFruitDelay2

    local isSyncingSkill = false
    local function setSyncSkillDelay(w, src)
        local n = tonumber(w) or 0.2
        _G.SkillDelay = n
        if not isSyncingSkill then
            isSyncingSkill = true
            local str = tostring(n)
            if src ~= 1 and tbSkillDelay1 and tbSkillDelay1.Main and tbSkillDelay1.Main.Text ~= str then
                tbSkillDelay1.Main.Text = str
                tbSkillDelay1.value = str
            end
            if src ~= 2 and tbSkillDelay2 and tbSkillDelay2.Main and tbSkillDelay2.Main.Text ~= str then
                tbSkillDelay2.Main.Text = str
                tbSkillDelay2.value = str
            end
            isSyncingSkill = false
        end
    end

    local isSyncingAssist = false
    local function setSyncAssistDelay(w, src)
        local n = tonumber(w) or 0.8
        _G.AssistSkillDelay = n
        if not isSyncingAssist then
            isSyncingAssist = true
            local str = tostring(n)
            if src ~= 1 and tbAssistDelay1 and tbAssistDelay1.Main and tbAssistDelay1.Main.Text ~= str then
                tbAssistDelay1.Main.Text = str
                tbAssistDelay1.value = str
            end
            if src ~= 2 and tbAssistDelay2 and tbAssistDelay2.Main and tbAssistDelay2.Main.Text ~= str then
                tbAssistDelay2.Main.Text = str
                tbAssistDelay2.value = str
            end
            isSyncingAssist = false
        end
    end

    local isSyncingFruit = false
    local function setSyncFruitDelay(w, src)
        local n = tonumber(w) or 0.8
        _G.FruitDelay = n
        if not isSyncingFruit then
            isSyncingFruit = true
            local str = tostring(n)
            if src ~= 1 and tbFruitDelay1 and tbFruitDelay1.Main and tbFruitDelay1.Main.Text ~= str then
                tbFruitDelay1.Main.Text = str
                tbFruitDelay1.value = str
            end
            if src ~= 2 and tbFruitDelay2 and tbFruitDelay2.Main and tbFruitDelay2.Main.Text ~= str then
                tbFruitDelay2.Main.Text = str
                tbFruitDelay2.value = str
            end
            isSyncingFruit = false
        end
    end
    local Window = library:CreateWindow("SuiSuiHUB • CỬU THIÊN VẤN ĐẠO | ".."AnimeDimensions".." |")
    local Tab1 = Window:CreateTab("Tu Tiên")
	local Sector1 = Tab1:CreateSector("Farming", "left")
    local mapDropdown = Sector1:AddDropdown("MapSelection(AutoUpdate!)", MapSelection, _G.MapSelection or "Titan Dimension", false, function(v)
        _G.MapSelection = v
    end)
    Sector1:AddButton("Quét Lại DS Map (Refresh)", function()
        MapSelection = GetAvailableMaps()
        if mapDropdown and mapDropdown.Refresh then
            mapDropdown:Refresh(MapSelection)
        end
        if Notification then
            Notification(1, "SuiSui Tiên Các", "Đã cập nhật " .. tostring(#MapSelection) .. " Phụ Bản Map!", 3)
        end
    end)
    Sector1:AddTextbox("Custom Map (Nhập Tên)", "", function(w)
        if w and #w > 0 then
            _G.MapSelection = w
        end
    end)
    Sector1:AddDropdown("SelectDifficulty",{"Easy" , "Hard" , "Nightmare" }, false ,false , function(v)
        _G.Difficulty = v
    end)
    Sector1:AddTextbox("WaitOnLobbyAfterJoin(OnlyNumber)" , "10" , function(w)
        _G.CooldownOnlobby = w
    end)
    Sector1:AddToggle("AutoPlay", false, function(t)
		_G.AutoPlay = t
	end)
    Sector1:AddToggle("Hardcore", false, function(t)
		_G.Hardcore = t
	end)
    Sector1:AddToggle("AutoReplay", true, function(t)
		_G.Replay = t
	end)
    Sector1:AddToggle("FriendOnly", false, function(t)
		_G.FriendOnly = t
	end)
    Sector1:AddToggle("AutoSelectMap(DetectedLevel)", false, function(t)
		_G.AutoSelectMap = t
	end)
    Sector1:AddToggle("GetAllDimensionCharacter", false, function(t)
		_G.GetAllDimensionCharacter = t
	end)


    local Sector2 = Tab1:CreateSector("InGame", "Right")
    Sector2:AddDropdown("Method",{"Behind" , "Front" , "Over" , "Under" }, "Behind" ,false , function(v)
        _G.Method = v
    end)
    Sector2:AddTextbox("ImportDistance(OnlyNumber)" , "6" , function(w)
        _G.Distance = tonumber(w)
    end)
    Sector2:AddTextbox("TweenSpeed(OnlyNumber)" , "200" , function(w)
        _G.TWSpeed = w
    end)
	Sector2:AddToggle("AutoMob", true, function(t)
		_G.Automob = t
	end)
    Sector2:AddTextbox("DistanceToSkill(OnlyNumber)" , "30" , function(w)
        _G.DistanceToSkill = tonumber(w)
    end)
    tbSkillDelay1 = Sector2:AddTextbox("SkillDelay(Sec)" , tostring(_G.SkillDelay or 0.2) , function(w)
        setSyncSkillDelay(w, 1)
    end)
    tbAssistDelay1 = Sector2:AddTextbox("AssistDelay(Sec)" , tostring(_G.AssistSkillDelay or 0.8) , function(w)
        setSyncAssistDelay(w, 1)
    end)
    tbFruitDelay1 = Sector2:AddTextbox("FruitDelay(Sec)" , tostring(_G.FruitDelay or 0.8) , function(w)
        setSyncFruitDelay(w, 1)
    end)
    Sector2:AddToggle("AutoSkill", true, function(t)
		_G.AutoSkill = t
	end)
    Sector2:AddToggle("AutoAssistSkill", true, function(t)
		_G.AutoAssistSkill = t
	end)
	Sector2:AddToggle("AutoFruit", true, function(t)
		_G.AutoFruit = t
	end)
    Sector2:AddDropdown("SelectAttackMethod",{"Remote" , "Click" }, "Remote" ,false , function(v)
        _G.SelectAttackMethod = v
    end)
    Sector2:AddToggle("AutoMelee", true, function(t)
		_G.AutoMelee = t
	end)
    Sector2:AddTextbox("MeleeDelay(Sec)", "0.05", function(w)
        _G.MeleeDelay = tonumber(w) or 0.05
    end)

    local Tab2 = Window:CreateTab("Phụ Trợ")
    local SectorRaid = Tab2:CreateSector("Phụ Bản Raid (Auto Raid)", "left")
    SectorRaid:AddLabel("Chọn Bí Cảnh Raid", true)
    local raidDropdown = SectorRaid:AddDropdown("Bí Cảnh Raid", RaidSelection, _G.RaidSelection or RaidSelection[1] or "Goddess Madoki Raid", false, function(v)
        _G.RaidSelection = v
    end)
    SectorRaid:AddButton("Quét Lại DS Raid (Refresh)", function()
        RaidSelection = GetAvailableRaids()
        if raidDropdown and raidDropdown.Refresh then
            raidDropdown:Refresh(RaidSelection)
        end
        if Notification then
            Notification(1, "SuiSui Tiên Các", "Đã cập nhật " .. tostring(#RaidSelection) .. " Bí Cảnh Raid!", 3)
        end
    end)
    SectorRaid:AddTextbox("Custom Raid (Nhập Tên)", "", function(w)
        if w and #w > 0 then
            _G.RaidSelection = w
            if Notification then
                Notification(1, "SuiSui Tiên Các", "Đã chọn Custom Raid: " .. tostring(w), 3)
            end
        end
    end)
    SectorRaid:AddTextbox("Cooldown JoinRaid (Giây)", "10", function(w)
        _G.waitonJoinRiad = w
    end)
    SectorRaid:AddToggle("AutoRaid", false, function(t)
		_G.AutoRaid = t
	end)
    SectorRaid:AddToggle("FreeBossRush", false, function(t)
		_G.FreeBossRush = t
	end)
    SectorRaid:AddToggle("BossRush", false, function(t)
		_G.BossRush = t
	end)
    SectorRaid:AddToggle("AutoSpeedRaid(RandomSelect)", false, function(t)
		_G.AutoSpeedRaid = t
	end)
    SectorRaid:AddToggle("AutoTraitTokens(Need LV:20)", false, function(t)
		_G.AutoTraitTokens = t
	end)
    local SectorMadoki = Tab2:CreateSector("Bí Cảnh Madoki (Event Raid)", "left")
    SectorMadoki:AddToggle("MadokiRaid(Need Raid Token)", false, function(t)
		_G.AutoMadokiRaid = t
	end)
    SectorMadoki:AddToggle("JoinMadokiRaid(AutoJoinRaidLobby)", false, function(t)
		_G.AutoJoinMadokiRaid = t
	end)
    local Sector4 = Tab2:CreateSector("MoreFunction", "Right")
    Sector4:AddToggle("AutoDodgeSkill", false, function(t)
		_G.AutoDodgeSkill = t
	end)
    Sector4:AddToggle("BackToLobbyIfGotExploitsDetected", false, function(t)
		_G.BackToLobbyIfGotExploitsDetected = t
	end)
    Sector4:AddToggle("HideName", false, function(t)
        _G.HideName = t
    end)
    Sector4:AddToggle("DashNoCooldown", false, function(t)
        _G.DashNoCooldown = t
    end)
    Sector4:AddToggle("AutoWalk(Only Boss)", false, function(t)
        _G.AutoWalk = t
    end)
    Sector4:AddToggle("AutoClaimQuestAndReward", false, function(t)
		_G.AutoClaimQuestAndReward = t
	end)
    Sector4:AddDropdown("GoLobbyMethod",{"ResetCharacter" , "TeleportToLobby" }, false ,false , function(v)
        _G.GoLobbyMethod = v
    end)
    Sector4:AddToggle("BackToLobbyIfRaidOpen", false, function(t)
		_G.OnRaidOpen = t
	end)
    Sector4:AddToggle("StopReplayIfRaidOpen", false, function(t)
		_G.StopReplay = t
	end)
    Sector4:AddToggle("Disable Noclip", false, function(t)
		_G.DontNoclip = t
	end)
    Sector4:AddToggle("DoNotThingIfHavePlayer", false, function(t)
		_G.DoNotThingIfHavePlayer = t
	end)
    local Config = {}
    function Save_Config()
        pcall(function()
            if writefile then
                writefile("Character_SuiSui.json", game:GetService("HttpService"):JSONEncode(Config))
            end
            for i, v in pairs(Config) do
                if Notification then
                    Notification(1, "SuiSuiHUB", ("ConfigSaved: " .. tostring(i) .. " " .. tostring(v)), 5)
                end
                wait(0.5)
            end
        end)
    end

    pcall(function()
        if isfile and isfile("Character_SuiSui.json") then
            Config = game:GetService("HttpService"):JSONDecode(readfile("Character_SuiSui.json"))
        end
    end)



    local Tab3 = Window:CreateTab("Đạo Thân")
    local Sector1 = Tab3:CreateSector("AutoEquip", "left")
    Sector1:AddToggle("AutoEquip Character", false, function(t)
		_G.AutoEquipCharacter = t
	end)
    Sector1:AddButton("SaveCharacter" , function()
        Config["Character1"] = game:GetService("ReplicatedStorage")[game.Players.LocalPlayer.Name.."StatDisplay"].CharacterName.Value
        Config["Character2"] = game:GetService("ReplicatedStorage")[game.Players.LocalPlayer.Name.."StatDisplay"].AssistCharacterName1.Value
        Config["Character3"] = game:GetService("ReplicatedStorage")[game.Players.LocalPlayer.Name.."StatDisplay"].AssistCharacterName2.Value
        Save_Config()
    end)
	
	Sector1:AddToggle("Auto Change Main Character", false, function(t)
		_G.AutoMainCharacter = t
		
		local function autoMainCharacter()
			if _G.autoMainC == true then return end
			_G.autoMainC = false

			local respawnTimer;
			for i,v in pairs(game:GetService('Players').LocalPlayer.PlayerGui:GetDescendants()) do
				if v.Name == 'RespawnTimerFrame' then 
					respawnTimer = v
				end
			end

			local waitLimit = tick() + 8
			repeat
				for _, v in pairs(game:GetService('Players').LocalPlayer.PlayerGui:GetDescendants()) do
					if v.Name == 'RespawnTimerFrame' then respawnTimer = v break end
				end
				if not respawnTimer then task.wait(0.5) end
			until respawnTimer ~= nil or tick() > waitLimit
			if not respawnTimer then return end

			if _G.AutoMainCharacter == true then
				local resetTime = 0
				local a={['Main']=0,['Assist1']=1,['Assist2']=2};
				local connection;
				
				if _G.MainChar then
					if a[_G.MainChar] >0 then
					
						local function resetChar()
							local s, e = pcall(function() game.Players.LocalPlayer.Character.Humanoid.Health=0; end)
							if not s then print(e) end
							resetTime += 1
						end
						if resetTime ~= a[_G.MainChar] and resetTime < a[_G.MainChar] then
							resetChar()
						end
						
						connection = respawnTimer.Changed:Connect(function()
							if not _G.AutoMainCharacter then connection:Disconnect(); return end
							if respawnTimer.Visible == false then
								if resetTime ~= a[_G.MainChar] and resetTime < a[_G.MainChar] then
									resetChar()
								elseif resetTime == a[_G.MainChar] then
									print('Main Character Success.')
									connection:Disconnect()
								end
							end
						end)
					end
				end
			end

		end
		
		if t then
			if game.PlaceId == 6938803436 or game.PlaceId == 7274690025 or game.PlaceId == 7338881230 then return end
			task.spawn(autoMainCharacter)
		end
	end)
	Sector1:AddDropdown("SelectChar", {"Main", "Assist1", "Assist2"}, "Main", false, function(v)
		_G.MainChar = v
	end)
	


    local Tab9 = Window:CreateTab("Thiết Lập")
    local Sector1 = Tab9:CreateSector("Setting DodgeSkill", "left")
    Sector1:AddTextbox("SizeDodgePart (OnlyNumber)" , "3.5" , function(w)
        _G.SizeDodgePart = w
    end)
    Sector1:AddTextbox("SizeDodgePart Y (OnlyNumber)" , "100" , function(w)
        _G.SizeDodgePartY = w
    end)
    Sector1:AddTextbox("TweenSpeedDodgePart (Sec)" , "0.25" , function(w)
        _G.TweenDodgePart = w
    end)
    Sector1:AddTextbox("DodgePartTransparency (OnlyNumber)" , "0.9" , function(w)
        _G.DodgePartTransparency = w
    end)
    local Sector5 = Tab9:CreateSector("MoreFunction2", "left")
    Sector5:AddToggle("Go AFK (If Raid Not Open)", false, function(t)
		_G.AutoGoAFK = t
	end)
    Sector5:AddTextbox("SelectWaveToReset" , "100" , function(w)
        _G.SelectWaveToEnd = w
    end)
    Sector5:AddToggle("Reset INF Mode (SelectWave)", false, function(t)
		_G.ResetifWave = t
	end)
    local Sector1 = Tab9:CreateSector("Setting AutoSkill", "Right")
    tbSkillDelay2 = Sector1:AddTextbox("SkillDelay(Sec)" , tostring(_G.SkillDelay or 0.2) , function(w)
        setSyncSkillDelay(w, 2)
    end)
    tbAssistDelay2 = Sector1:AddTextbox("AssistDelay(Sec)" , tostring(_G.AssistSkillDelay or 0.8) , function(w)
        setSyncAssistDelay(w, 2)
    end)
    tbFruitDelay2 = Sector1:AddTextbox("FruitDelay(Sec)" , tostring(_G.FruitDelay or 0.8) , function(w)
        setSyncFruitDelay(w, 2)
    end)
    Sector1:AddTextbox("MeleeDelay(Sec)" , "0.05" , function(w)
        _G.MeleeDelay = tonumber(w) or 0.05
    end)
    Sector1:AddDropdown("SkillFirst",{"1","2","3","4","5"},"4",false , function(v)
        _G.skill1 = v
    end)
    Sector1:AddDropdown("SkillSecond",{"1","2","3","4","5"},"3",false , function(v)
        _G.skill2 = v
    end)
    Sector1:AddDropdown("SkillThird",{"1" , "2" , "3", "4","5"},"5",false , function(v)
        _G.skill3 = v
    end)
    Sector1:AddDropdown("SkillFourth",{"1","2","3","4","5"}, "1" ,false , function(v)
        _G.skill4 = v
    end)
    Sector1:AddDropdown("SkillFifth",{"1","2","3","4","5"}, "2" ,false , function(v)
        _G.skill5 = v
    end)
    local Tab10 = Window:CreateTab("Tàng Bảo Các")
	local Sector1 = Tab10:CreateSector("Tàng Bảo Sảnh (Shop & Keys)", "left")
    Sector1:AddDropdown("Loại Tiền Mua Vé",{"(Raid)" , "(Gem)"}, false ,false , function(v)
        _G.methodbuy = v
    end)
    Sector1:AddToggle("Tự Mua Boss Rush Ticket", false, function(t)
		_G.BuyRushTicket = t
	end)
    Sector1:AddToggle("Tự Mua Madoki Raid Key", false, function(t)
		_G.BuyKey = t
	end)

    local SectorPet = Tab10:CreateSector("Linh Thú Các (Pet Gacha)", "left")
    local petDropdown = SectorPet:AddDropdown("Chọn Capsule (AutoUpdate)", PetCapsuleSelection, PetCapsuleSelection[1] or "Gear 5 Fluffy Capsule", false, function(v)
        _G.SelectedCapsule = v
    end)
    SectorPet:AddButton("Quét Lại DS Capsule", function()
        PetCapsuleSelection = GetAvailableCapsules()
        if petDropdown and petDropdown.Refresh then
            petDropdown:Refresh(PetCapsuleSelection)
        end
        if Notification then
            Notification(1, "SuiSui Tiên Các", "Đã cập nhật " .. tostring(#PetCapsuleSelection) .. " Pet Capsules!", 3)
        end
    end)
    SectorPet:AddTextbox("Custom Capsule (Nhập Tên)", "", function(w)
        if w and #w > 0 then
            _G.SelectedCapsule = w
        end
    end)
    SectorPet:AddButton("Mua Pet (x1)", function()
        pcall(function()
            local cap = _G.SelectedCapsule or "Gear 5 Fluffy Capsule"
            game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunctions"):WaitForChild("MainRemoteFunction"):InvokeServer("BuyEgg", cap)
        end)
    end)
    SectorPet:AddButton("Mua Pet (x4)", function()
        pcall(function()
            local cap = _G.SelectedCapsule or "Gear 5 Fluffy Capsule"
            game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunctions"):WaitForChild("MainRemoteFunction"):InvokeServer("Buy4Pets", cap)
        end)
    end)
    SectorPet:AddTextbox("Nhịp Mua Pet (Sec)", "1.0", function(w)
        _G.PetSpinDelay = tonumber(w) or 1.0
    end)
    SectorPet:AddToggle("Tự Động Mua Pet (x1)", false, function(t)
        _G.AutoBuyPet1 = t
    end)
    SectorPet:AddToggle("Tự Động Mua Pet (x4)", false, function(t)
        _G.AutoBuyPet4 = t
    end)

    local SectorFruit = Tab10:CreateSector("Trái Tiên Các (Fruit Gacha)", "Right")
    SectorFruit:AddButton("Quay Fruit (x1)", function()
        pcall(function()
            game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunctions"):WaitForChild("MainRemoteFunction"):InvokeServer("BuyFruit", "BasicFruitGacha")
        end)
    end)
    SectorFruit:AddButton("Quay Fruit (x4)", function()
        pcall(function()
            game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunctions"):WaitForChild("MainRemoteFunction"):InvokeServer("BuyFruitQuad", "BasicFruitGacha")
        end)
    end)
    SectorFruit:AddTextbox("Nhịp Quay Fruit (Sec)", "1.0", function(w)
        _G.SpinFruitDelay = tonumber(w) or 1.0
    end)
    SectorFruit:AddToggle("Tự Động Quay Fruit (x1)", false, function(t)
        _G.AutoSpinFruit1 = t
    end)
    SectorFruit:AddToggle("Tự Động Quay Fruit (x4)", false, function(t)
        _G.AutoSpinFruit4 = t
    end)

    local SectorHalloween = Tab10:CreateSector("Bí Ngô Lễ Hội (Halloween Event)", "Right")
    SectorHalloween:AddButton("Quay Event (x1)", function()
        pcall(function()
            game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunctions"):WaitForChild("MainRemoteFunction"):InvokeServer("SpinEventReward", "HalloweenEventSettings")
        end)
    end)
    SectorHalloween:AddButton("Quay Event (x4)", function()
        pcall(function()
            game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunctions"):WaitForChild("MainRemoteFunction"):InvokeServer("QuadEventSpin", "HalloweenEventSettings")
        end)
    end)
    SectorHalloween:AddTextbox("Nhịp Quay Event (Sec)", "1.0", function(w)
        _G.SpinHalloweenDelay = tonumber(w) or 1.0
    end)
    SectorHalloween:AddToggle("Tự Động Quay Event (x1)", false, function(t)
        _G.AutoSpinHalloween1 = t
    end)
    SectorHalloween:AddToggle("Tự Động Quay Event (x4)", false, function(t)
        _G.AutoSpinHalloween4 = t
    end)

    local function PlayerDetect()
        local Players = game.Players:GetPlayers()
        return tonumber(#Players)
    end
    -- Tu dong theo doi va cap nhat dropdown khi giao dien Map/Raid xuat hien
    task.spawn(function()
        pcall(function()
            local pg = localPlayer:WaitForChild("PlayerGui", 10)
            if not pg then return end

            local function onMapFrameDetected(mf)
                if not mf then return end
                task.wait(0.3)
                if game.PlaceId == 7338881230 then
                    RaidSelection = GetAvailableRaids()
                    if raidDropdown and raidDropdown.Refresh then
                        raidDropdown:Refresh(RaidSelection)
                    end
                else
                    MapSelection = GetAvailableMaps()
                    if mapDropdown and mapDropdown.Refresh then
                        mapDropdown:Refresh(MapSelection)
                    end
                end

                mf.ChildAdded:Connect(function(c)
                    if (c:IsA("ImageButton") or c:IsA("TextButton")) and c.Name ~= "MapSelectionTemplate" then
                        task.wait(0.2)
                        if game.PlaceId == 7338881230 then
                            RaidSelection = GetAvailableRaids()
                            if raidDropdown and raidDropdown.Refresh then
                                raidDropdown:Refresh(RaidSelection)
                            end
                        else
                            MapSelection = GetAvailableMaps()
                            if mapDropdown and mapDropdown.Refresh then
                                mapDropdown:Refresh(MapSelection)
                            end
                        end
                    end
                end)
            end

            local mg = pg:FindFirstChild("MainGui")
            local cf = mg and mg:FindFirstChild("CenterUIFrame")
            local pf = cf and cf:FindFirstChild("PlayFrame")
            local fr = pf and pf:FindFirstChild("Frame")
            local prf = fr and fr:FindFirstChild("PlayRoomFrame")
            local mf = prf and prf:FindFirstChild("MapSelectionScrollingFrame")
            if mf then
                onMapFrameDetected(mf)
            end

            pg.DescendantAdded:Connect(function(desc)
                if desc.Name == "MapSelectionScrollingFrame" and desc:IsA("ScrollingFrame") then
                    onMapFrameDetected(desc)
                end
            end)
        end)
    end)

    spawn(function()
        pcall(function()
            while task.wait() do
                pcall(function()
                    if tonumber(os.date("!*t").min) <= 9 then
                        _G.RaidOpened = true
                    else
                        _G.RaidOpened = false
                    end
                end)
            end
        end)
    end)
    spawn(function()
        pcall(function()
            while wait(1) do
                spawn(function()
                    if _G.BuyRushTicket == true then
                        game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunctions"):WaitForChild("MainRemoteFunction"):InvokeServer({[1] = "BuyBossRushShopItem",[2] = "Boss Rush Ticket ".._G.methodbuy})
                    end
                end)
            end
        end)
    end)
    spawn(function()
        pcall(function()
            while wait(1) do
                spawn(function()
                    if _G.BuyKey == true then
                        game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunctions"):WaitForChild("MainRemoteFunction"):InvokeServer({[1] = "BuyRaidShopItem",[2] = "Madoki Raid Key (2 Per Day)"})
                    end
                end)
            end
        end)
    end)
    spawn(function()
        pcall(function()
            while task.wait(0.2) do
                pcall(function()
                    if _G.AutoSpinFruit1 == true then
                        game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunctions"):WaitForChild("MainRemoteFunction"):InvokeServer("BuyFruit", "BasicFruitGacha")
                        task.wait(tonumber(_G.SpinFruitDelay or 1.0))
                    elseif _G.AutoSpinFruit4 == true then
                        game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunctions"):WaitForChild("MainRemoteFunction"):InvokeServer("BuyFruitQuad", "BasicFruitGacha")
                        task.wait(tonumber(_G.SpinFruitDelay or 1.0))
                    end
                end)
            end
        end)
    end)
    spawn(function()
        pcall(function()
            while task.wait(0.2) do
                pcall(function()
                    if _G.AutoBuyPet1 == true then
                        local cap = _G.SelectedCapsule or "Gear 5 Fluffy Capsule"
                        game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunctions"):WaitForChild("MainRemoteFunction"):InvokeServer("BuyEgg", cap)
                        task.wait(tonumber(_G.PetSpinDelay or 1.0))
                    elseif _G.AutoBuyPet4 == true then
                        local cap = _G.SelectedCapsule or "Gear 5 Fluffy Capsule"
                        game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunctions"):WaitForChild("MainRemoteFunction"):InvokeServer("Buy4Pets", cap)
                        task.wait(tonumber(_G.PetSpinDelay or 1.0))
                    end
                end)
            end
        end)
    end)
    spawn(function()
        pcall(function()
            while task.wait(0.2) do
                pcall(function()
                    if _G.AutoSpinHalloween1 == true then
                        game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunctions"):WaitForChild("MainRemoteFunction"):InvokeServer("SpinEventReward", "HalloweenEventSettings")
                        task.wait(tonumber(_G.SpinHalloweenDelay or 1.0))
                    elseif _G.AutoSpinHalloween4 == true then
                        game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunctions"):WaitForChild("MainRemoteFunction"):InvokeServer("QuadEventSpin", "HalloweenEventSettings")
                        task.wait(tonumber(_G.SpinHalloweenDelay or 1.0))
                    end
                end)
            end
        end)
    end)
    spawn(function()
        pcall(function()
            while task.wait() do
                task.spawn(function()
                    if _G.AutoJoinMadokiRaid == true then
                        for _,v in pairs(game.Players.LocalPlayer.PlayerGui.MainGui.CenterUIFrame.PlayFrame.Frame.PlayRoomFrame.PlayRoomScrollingFrame:GetChildren()) do
                            if v.Name == "Goddess Madoki RaidEasy" and v.Players.Text ~= "Players: 5/5" and v.FriendsOnly.Visible == false then
                                for _,vv in pairs({"MouseButton1Click"}) do
                                    firesignal(v.JoinButton[vv])
                                end
                            end
                        end
                    end
                end)
            end
        end)
    end)
    spawn(function()
        pcall(function()
            while task.wait() do
                pcall(function()
                    if tonumber(#game.Players:GetPlayers()) > 1 then
                        _G.CheckPlayer = true
                    else
                        _G.CheckPlayer = false
                    end
                end)
            end
        end)
    end)
    spawn(function()
        pcall(function()
            while wait(1) do
                pcall(function()
                    if _G.AutoJoinMadokiRaid == true then
                        if game:GetService("Players").LocalPlayer.PlayerGui.BattleGui.CenterUIFrame.RaidDataFrame.Visible == false and game:GetService("Players").LocalPlayer.PlayerGui.BattleGui.CenterUIFrame.BossHealthFrame.Visible == false then
                            if game.PlaceId ~= 7338881230 and game.PlaceId ~= 6990129309 then
                                game:GetService("TeleportService"):Teleport(7338881230)
                                wait(10)
                            end
                        end
                    end
                end)
            end
        end)
    end)

    local function getClosestwalk()
        local dist, thing = math.huge
        for i, v in next, workspace.Folders.Monsters:GetChildren() do
            if v:FindFirstChildOfClass("BillboardGui") then
                local mag = (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - v.HumanoidRootPart.Position).magnitude
                if mag < dist then
                    dist = mag 
                    thing = v
                end
            end
        end
    return thing
    end

    local function getClosestBoss()
        local dist, thing = math.huge
            for i, v in next, workspace.Folders.Monsters:GetChildren() do
                if v:FindFirstChildOfClass("BillboardGui") and v.EnemyHealthBarGui.Enabled == false then
                    local mag = (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - v.HumanoidRootPart.Position).magnitude
                    if mag < dist then
                        dist = mag 
                        thing = v
                    end
                end
            end
        return thing
    end

    local function getClosestMob()
        local dist, thing = math.huge
            for i, v in next, workspace.Folders.Monsters:GetChildren() do
                if v:FindFirstChildOfClass("BillboardGui") then
                    local mag = (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - v.HumanoidRootPart.Position).magnitude
                    if mag < dist then
                        dist = mag 
                        thing = v
                    end
                end
            end
        return thing
    end

    function walk(P)
        if game:GetService("Players").LocalPlayer.PlayerGui.BattleGui.CenterUIFrame.RaidDataFrame.Visible == true and _G.DoNotThingIfHavePlayer == true and _G.CheckPlayer == true then
        else
            game.Players.LocalPlayer.Character.Humanoid.WalkToPoint = (P.HumanoidRootPart.Position)
        end
    end

    function Tween(P)
        if game:GetService("Players").LocalPlayer.PlayerGui.BattleGui.CenterUIFrame.RaidDataFrame.Visible == true and _G.DoNotThingIfHavePlayer == true and _G.CheckPlayer == true then
        else
            game:GetService("TweenService"):Create(game.Players.LocalPlayer.Character.HumanoidRootPart,TweenInfo.new((getClosestMob().HumanoidRootPart.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude/tonumber(_G.TWSpeed), Enum.EasingStyle.Linear),{CFrame = P}):Play()
        end
    end

    local comboIndex = 0
    function melee()
        if _G.AutoMelee ~= true then return end
        local mob = getClosestMob()
        if not mob or not mob:FindFirstChild("HumanoidRootPart") then return end

        if _G.SelectAttackMethod == "Remote" then
            comboIndex = (comboIndex % 4) + 1
            local char = game.Players.LocalPlayer.Character
            local isBow = char and char:FindFirstChild("Bow")
            local targetPos = mob.HumanoidRootPart.Position
            local payload = {
                ["hrpCFrame"] = CFrame.new(targetPos),
                ["attackNumber"] = comboIndex,
                ["combo"] = isBow and 3 or comboIndex
            }
            game:GetService("ReplicatedStorage").RemoteEvents.MainRemoteEvent:FireServer("UseSkill", payload, "BasicAttack")
        elseif _G.SelectAttackMethod == "Click" then
            local vim = game:GetService("VirtualInputManager")
            vim:SendMouseButtonEvent(0, 0, 0, true, game, 1)
            task.wait(0.01)
            vim:SendMouseButtonEvent(0, 0, 0, false, game, 1)
        end
    end

    local lastSkillTime = 0
    local function canUseSkill(skillNum)
        if not skillNum then return false end
        local pgui = game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui")
        if not pgui then return false end
        local uGui = pgui:FindFirstChild("UniversalGui")
        if not uGui then return false end
        local holder = uGui:FindFirstChild("UniversalCenterUIFrame") and uGui.UniversalCenterUIFrame:FindFirstChild("SlotsHolder")
        if not holder then return false end

        local slot = holder:FindFirstChild("Skill" .. tostring(skillNum))
        if not slot or slot.Visible == false then return false end
        local sName = slot:FindFirstChild("SkillName")
        if not sName then return false end

        local cd = tonumber(sName.Text)
        return (cd == nil or cd <= 0)
    end

    function skill()
        if _G.AutoSkill ~= true then return end
        local delay = tonumber(_G.SkillDelay or 0.2)
        if (tick() - lastSkillTime) < delay then return end

        local mob = getClosestMob()
        if not mob or not mob:FindFirstChild("HumanoidRootPart") then return end

        local order = {_G.skill1, _G.skill2, _G.skill3, _G.skill4, _G.skill5}
        for _, s in ipairs(order) do
            if s and canUseSkill(s) then
                game:GetService("ReplicatedStorage").RemoteEvents.MainRemoteEvent:FireServer(
                    "UseSkill",
                    {["hrpCFrame"] = CFrame.new(mob.HumanoidRootPart.Position)},
                    tonumber(s)
                )
                lastSkillTime = tick()
                break
            end
        end
    end

    function skillmelee()
        if _G.AutoSkill == true then
            skill()
        end
        if _G.AutoMelee == true then
            melee()
        end
    end

    spawn(function()
        pcall(function()
            while task.wait(tonumber(_G.MeleeDelay or 0.05)) do
                pcall(function()
                    if game:GetService("Players").LocalPlayer.PlayerGui.BattleGui.CenterUIFrame.RaidDataFrame.Visible == true and _G.DoNotThingIfHavePlayer == true and _G.CheckPlayer == true then
                    else
                        local mob = getClosestMob()
                        if mob and mob:FindFirstChild("HumanoidRootPart") and game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                            Distance = (mob.HumanoidRootPart.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                            if game.PlaceId ~= 6938803436 and game.PlaceId ~= 7274690025 and game.PlaceId ~= 7338881230 and Distance <= tonumber(_G.DistanceToSkill or 30) then
                                if _G.AutoMelee == true and _G.AutoSkill == true then
                                    skillmelee()
                                elseif _G.AutoMelee == true and _G.AutoSkill == false then
                                    melee()
                                elseif _G.AutoMelee == false and _G.AutoSkill == true then
                                    skill()
                                end
                            end
                        end
                    end
                end)
            end
        end)
    end)
    
    spawn(function()
        pcall(function()
            while wait(1) do
                pcall(function()
                    Distance = (getClosestMob().HumanoidRootPart.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                    if game.PlaceId ~= 6938803436 and game.PlaceId ~= 7274690025 and game.PlaceId ~= 7338881230 then
                        if Distance > 500 then
                            if workspace.GameMap:FindFirstChild("Curse Dimension") then
                                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = workspace.GameMap["Curse Dimension"].CurseTeleportDestination.CFrame
                            elseif workspace.GameMap:FindFirstChild("Fate Dimension") then
                                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = workspace.GameMap["Fate Dimension"].CenterTeleportDestination.CFrame
                            elseif workspace.GameMap:FindFirstChild("Pirate Dimension") then
                                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = workspace.GameMap["Pirate Dimension"].Part2TeleportDestination.CFrame
                            end
                        end
                    end
                end)
            end
        end)
    end)
    -- Bo dieu phoi luan phien: Chuyen doi qua lai giua Fruit va AutoAssistSkill
    local lastAltActionTime = 0
    local altTurn = "Fruit" -- Luan phien: Fruit -> Assist -> Fruit -> Assist
    local nextFruitSlot = 1
    local nextAssistSlot = 1

    local function castFruit(fr)
        if not fr then return end
        local events = { "MouseButton1Click", "MouseButton1Down", "Activated" }
        for _, ev in ipairs(events) do
            pcall(function() firesignal(fr[ev]) end)
        end
    end

    local function castAssist(slotNum, mob)
        if not slotNum or not mob or not mob:FindFirstChild("HumanoidRootPart") then return end
        game:GetService("ReplicatedStorage").RemoteEvents.MainRemoteEvent:FireServer(
            "UseAssistSkill",
            {["hrpCFrame"] = CFrame.new(mob.HumanoidRootPart.Position)},
            slotNum
        )
    end

    spawn(function()
        pcall(function()
            while wait(0.08) do
                pcall(function()
                    if game.PlaceId == 6938803436 or game.PlaceId == 7274690025 or game.PlaceId == 7338881230 then return end
                    if _G.AutoFruit ~= true and _G.AutoAssistSkill ~= true then return end

                    local mob = getClosestMob()
                    if not mob or not mob:FindFirstChild("HumanoidRootPart") or not game.Players.LocalPlayer.Character or not game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
                    local dist = (mob.HumanoidRootPart.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                    if dist > tonumber(_G.DistanceToSkill or 30) then return end

                    local plr = game:GetService("Players").LocalPlayer
                    local pg = plr:FindFirstChild("PlayerGui")
                    if not pg then return end

                    -- Kiem tra trang thai Fruit (SkillFruit1, SkillFruit2)
                    local fr1 = pg:FindFirstChild("SkillFruit1", true)
                    local fr2 = pg:FindFirstChild("SkillFruit2", true)
                    local cdF1 = fr1 and fr1:FindFirstChild("SkillName")
                    local cdF2 = fr2 and fr2:FindFirstChild("SkillName")
                    local f1Ready = (fr1 and cdF1 and cdF1.Visible == false)
                    local f2Ready = (fr2 and cdF2 and cdF2.Visible == false)
                    local hasFruitReady = f1Ready or f2Ready

                    -- Kiem tra trang thai Assist (SkillAssist1, SkillAssist2)
                    local uGui = pg:FindFirstChild("UniversalGui")
                    local holder = uGui and uGui:FindFirstChild("UniversalCenterUIFrame") and uGui.UniversalCenterUIFrame:FindFirstChild("SlotsHolder")
                    local cdA1 = holder and holder:FindFirstChild("SkillAssist1") and tonumber(holder.SkillAssist1.SkillName.Text)
                    local cdA2 = holder and holder:FindFirstChild("SkillAssist2") and tonumber(holder.SkillAssist2.SkillName.Text)
                    local a1Ready = (holder and holder:FindFirstChild("SkillAssist1") and (cdA1 == nil or cdA1 <= 0))
                    local a2Ready = (holder and holder:FindFirstChild("SkillAssist2") and (cdA2 == nil or cdA2 <= 0))
                    local hasAssistReady = a1Ready or a2Ready

                    -- Logic chuyen doi qua lai giua Fruit va Assist
                    if altTurn == "Fruit" then
                        if _G.AutoFruit == true and hasFruitReady then
                            local fDelay = tonumber(_G.FruitDelay or 0.8)
                            if (tick() - lastAltActionTime) >= fDelay then
                                if nextFruitSlot == 1 then
                                    if f1Ready then
                                        castFruit(fr1)
                                        nextFruitSlot = 2
                                    elseif f2Ready then
                                        castFruit(fr2)
                                        nextFruitSlot = 1
                                    end
                                else
                                    if f2Ready then
                                        castFruit(fr2)
                                        nextFruitSlot = 1
                                    elseif f1Ready then
                                        castFruit(fr1)
                                        nextFruitSlot = 2
                                    end
                                end
                                lastAltActionTime = tick()
                                -- Da tung Fruit xong -> chuyen doi luot sang Assist
                                altTurn = "Assist"
                            end
                        else
                            -- Neu Fruit chua hoi hoac khong bat, nhuong luot cho Assist neu Assist san sang
                            if _G.AutoAssistSkill == true and hasAssistReady then
                                altTurn = "Assist"
                            end
                        end
                    elseif altTurn == "Assist" then
                        if _G.AutoAssistSkill == true and hasAssistReady then
                            local aDelay = tonumber(_G.AssistSkillDelay or 0.8)
                            if (tick() - lastAltActionTime) >= aDelay then
                                if nextAssistSlot == 1 then
                                    if a1Ready then
                                        castAssist(1, mob)
                                        nextAssistSlot = 2
                                    elseif a2Ready then
                                        castAssist(2, mob)
                                        nextAssistSlot = 1
                                    end
                                else
                                    if a2Ready then
                                        castAssist(2, mob)
                                        nextAssistSlot = 1
                                    elseif a1Ready then
                                        castAssist(1, mob)
                                        nextAssistSlot = 2
                                    end
                                end
                                lastAltActionTime = tick()
                                -- Da tung Assist xong -> chuyen doi luot sang Fruit
                                altTurn = "Fruit"
                            end
                        else
                            -- Neu Assist chua hoi hoac khong bat, nhuong luot cho Fruit neu Fruit san sang
                            if _G.AutoFruit == true and hasFruitReady then
                                altTurn = "Fruit"
                            end
                        end
                    end
                end)
            end
        end)
    end)
    spawn(function()
        pcall(function()
            while wait() do
                pcall(function()
                    if _G.ResetifWave then
                        if tonumber(game:GetService("Players").LocalPlayer.PlayerGui.BattleGui.CenterUIFrame.WaveClearClearText.Text) >= tonumber(_G.SelectWaveToEnd) and game:GetService("Players").LocalPlayer.PlayerGui.BattleGui.CenterUIFrame.BossHealthFrame.Visible == false then
                            game.Players.LocalPlayer.Character.Humanoid.Health = 0
                        end
                    end
                end)
            end
        end)
    end)
    spawn(function()
        pcall(function()
            while wait(1) do
                pcall(function()
                    if _G.DashNoCooldown then
                        game.ReplicatedStorage[game.Players.LocalPlayer.Name .. "StatDisplay"].No_DashCooldown.Value = true
                    end
                end)
            end
        end)
    end)
    spawn(function()
        pcall(function()
            while wait(1) do
                pcall(function()
                    if _G.AutoClaimQuestAndReward then
                        if game.PlaceId == 6938803436 or game.PlaceId == 7274690025 or game.PlaceId == 7338881230 then
                            for i = 1,9 do
                                game:GetService("ReplicatedStorage").RemoteFunctions.MainRemoteFunction:InvokeServer("ClaimWeeklySpeedRaidReward",i)
                            end
                            game:GetService("ReplicatedStorage").RemoteFunctions.MainRemoteFunction:InvokeServer("GiveFreeDailyGemFromShop")
                            game:GetService("ReplicatedStorage").RemoteFunctions.MainRemoteFunction:InvokeServer("CompleteDailyQuest","DailyQuest_Login")
                            game:GetService("ReplicatedStorage").RemoteFunctions.MainRemoteFunction:InvokeServer("CompleteDailyQuest","DailyQuest_DungeonClear")
                            game:GetService("ReplicatedStorage").RemoteFunctions.MainRemoteFunction:InvokeServer("CompleteDailyQuest","DailyQuest_Enemies")
                            game:GetService("ReplicatedStorage").RemoteFunctions.MainRemoteFunction:InvokeServer("CompleteDailyQuest","DailyQuest_TimeChallenge")
                            game:GetService("ReplicatedStorage").RemoteFunctions.MainRemoteFunction:InvokeServer("CompleteDailyQuest","DailyQuest_Raid")
                            game:GetService("ReplicatedStorage").RemoteFunctions.MainRemoteFunction:InvokeServer("CompleteDailyQuest","DailyQuest_BossRush")
                            game:GetService("ReplicatedStorage").RemoteFunctions.MainRemoteFunction:InvokeServer("CompleteDailyQuest","DailyQuest_AllQuestClear")
                            game:GetService("ReplicatedStorage").RemoteFunctions.MainRemoteFunction:InvokeServer("CompleteDailyQuest","WeeklyQuest_Logins")
                            wait(600)
                        end
                    end
                end)
            end
        end)
    end)
    spawn(function()
    pcall(function()
        while task.wait() do
            pcall(function()
                if _G.AutoWalk == true then
                    if game.PlaceId ~= 6938803436 and game.PlaceId ~= 7274690025 and game.PlaceId ~= 7338881230 then
                        walk(getClosestBoss())
                    end
                end
            end)
        end
    end)
    end)

    spawn(function()
    pcall(function()
        while task.wait() do
            pcall(function()
                if _G.Automob then
                    if game.PlaceId ~= 6938803436 and game.PlaceId ~= 7274690025 and game.PlaceId ~= 7338881230 then
                        if _G.Method == "Behind" then
                            MethodFarm = CFrame.new(0,0,_G.Distance) * CFrame.Angles(math.rad(0),0,0)
                        elseif _G.Method == "Front" then
                            MethodFarm = CFrame.new(0,0,-_G.Distance) * CFrame.Angles(math.rad(0),1800,0)
                        elseif _G.Method == "Under" then
                            MethodFarm = CFrame.new(0,-_G.Distance,0) * CFrame.Angles(math.rad(90),0,0)
                        elseif _G.Method == "Over" then
                            MethodFarm = CFrame.new(0,_G.Distance,0)  * CFrame.Angles(math.rad(-90),0,0)
                        else
                            MethodFarm = CFrame.new(0,0,_G.Distance)
                        end
                        local BeenASecond, V3 = false, Vector3.new(0, 0, 0)
                        for _, v in ipairs(game.Players.LocalPlayer.Character:GetDescendants()) do
                            if v.IsA(v, "BasePart") then
                                v.Velocity, v.RotVelocity = V3, V3
                            end
                        end
                        if game:GetService("Players").LocalPlayer.PlayerGui.BattleGui.CenterUIFrame.BossHealthFrame.Visible == true then
                            Tween(getClosestBoss().HumanoidRootPart.CFrame * MethodFarm or CFrame.new(0,0,_G.Distance))
                        elseif game:GetService("Players").LocalPlayer.PlayerGui.BattleGui.CenterUIFrame.BossHealthFrame.Visible == false then
                            Tween(getClosestMob().HumanoidRootPart.CFrame * MethodFarm or CFrame.new(0,0,_G.Distance))
                        end
                    end
                end
            end)
        end
    end)
    end)


    
    spawn(function()
        pcall(function()
            wait(10)
            while wait(1) do
                pcall(function()
                    if game.PlaceId ~= 6938803436 and game.PlaceId ~= 7274690025 and game.PlaceId ~= 7338881230 then
                        if _G.GoLobbyMethod == "ResetCharacter" and _G.OnRaidOpen == true and _G.RaidOpened == true and game:GetService("Players").LocalPlayer.PlayerGui.BattleGui.CenterUIFrame.BossHealthFrame.Visible == false then
                            game.Players.LocalPlayer.Character.Humanoid.Health = 0
                        elseif _G.GoLobbyMethod == "TeleportToLobby" and _G.OnRaidOpen == true and _G.RaidOpened == true and game:GetService("Players").LocalPlayer.PlayerGui.BattleGui.CenterUIFrame.BossHealthFrame.Visible == false then
                            game:GetService("TeleportService"):Teleport(6938803436)
                            wait(60)
                        end
                    end
                end)
            end
        end)
    end)


    spawn(function()
        pcall(function()
            Notification(1, "SuiSuiHUB", "Waiting on join raid", tonumber(_G.waitonJoinRiad))
            wait(tonumber(_G.waitonJoinRiad))
            while wait() do
                pcall(function()
                    if _G.AutoMadokiRaid == true and tonumber(game:GetService("ReplicatedStorage")[game.Players.LocalPlayer.Name.."StatDisplay"]["Madoki Raid Key"].Value) <= 0 then
                        game:GetService("ReplicatedStorage").RemoteFunctions.MainRemoteFunction:InvokeServer("BuyRaidShopItem","Madoki Raid Key (2 Per Day)")
                    elseif game:GetService("ReplicatedStorage")[game.Players.LocalPlayer.Name.."StatDisplay"]:FindFirstChild("Madoki Raid Key") and tonumber(game:GetService("ReplicatedStorage")[game.Players.LocalPlayer.Name.."StatDisplay"]["Madoki Raid Key"].Value) > 0 and _G.AutoMadokiRaid == true then
                        game:GetService("ReplicatedStorage").RemoteFunctions.MainRemoteFunction:InvokeServer("CreateRoom",{["Difficulty"] = "Easy",["FriendsOnly"] = _G.FriendOnly,["MapName"] = "Goddess Madoki Raid",["Hardcore"] = false})
                        wait(1)
                        game:GetService("ReplicatedStorage").RemoteFunctions.MainRemoteFunction:InvokeServer("TeleportPlayers")
                    else
                        if _G.AutoRaid == true and _G.AutoGoAFK == true then
                            if _G.RaidOpened == true then
                                if game.PlaceId == 6938803436 or game.PlaceId == 7274690025 or game.PlaceId == 7338881230 then
                                    game:GetService("ReplicatedStorage").RemoteFunctions.MainRemoteFunction:InvokeServer("CreateRoom",{["Difficulty"] = "Easy",["FriendsOnly"] = _G.FriendOnly,["MapName"] = (_G.RaidSelection and tostring(_G.RaidSelection) ~= "nil" and tostring(_G.RaidSelection) ~= "") and tostring(_G.RaidSelection) or "Goddess Madoki Raid",["Hardcore"] = false})
                                    wait()
                                    game:GetService("ReplicatedStorage").RemoteFunctions.MainRemoteFunction:InvokeServer("TeleportPlayers")
                                elseif game.PlaceId == 6990131029 then
                                    game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunctions"):WaitForChild("MainRemoteFunction"):InvokeServer("TeleportToLobbyAFK",true)
                                end
                            elseif _G.RaidOpened == false and game.PlaceId ~= 6990131029 then
                                Notification(1, "SuiSuiHUB", "Go AFK in 10 Sec", 10)
                                wait(10)
                                game:GetService("ReplicatedStorage").RemoteFunctions.MainRemoteFunction:InvokeServer("TeleportToAFK")
                            end
                        elseif _G.AutoRaid == true and _G.AutoGoAFK == false then
                            game:GetService("ReplicatedStorage").RemoteFunctions.MainRemoteFunction:InvokeServer("CreateRoom",{["Difficulty"] = "Easy",["FriendsOnly"] = _G.FriendOnly,["MapName"] = (_G.RaidSelection and tostring(_G.RaidSelection) ~= "nil" and tostring(_G.RaidSelection) ~= "") and tostring(_G.RaidSelection) or "Goddess Madoki Raid",["Hardcore"] = false})
                            wait(1)
                            game:GetService("ReplicatedStorage").RemoteFunctions.MainRemoteFunction:InvokeServer("TeleportPlayers")
                        end
                    end
                end)
            end
        end)
    end)


    spawn(function()
        pcall(function()
            Notification(1, "SuiSuiHUB", "Waiting CooldownOnlobby", tonumber(_G.CooldownOnlobby))
            wait(tonumber(_G.CooldownOnlobby))
            while wait() do
                pcall(function()
                    if _G.AutoRaid == true then
                        if _G.FreeBossRush == true and game:GetService("Players").LocalPlayer.PlayerGui.MainGui.CenterUIFrame.BossRushFrame.BossRushFreeEntry.Text == "1 Free Entry Left" and _G.RaidOpened == false then
                            game:GetService("ReplicatedStorage").RemoteFunctions.MainRemoteFunction:InvokeServer("TeleportToBossRush")
                        elseif _G.BossRush == true and tonumber(game:GetService("Players").LocalPlayer.PlayerGui.MainGui.CenterUIFrame.BossRushFrame.BossRushEntryPassCount.Text) > 0 and _G.RaidOpened == false then
                            game:GetService("ReplicatedStorage").RemoteFunctions.MainRemoteFunction:InvokeServer("TeleportToBossRush")
                        elseif _G.AutoTraitTokens == true and game:GetService("Players").LocalPlayer.PlayerGui.MainGui.CenterUIFrame.PlayFrame.Frame.PlayRoomFrame.MapSelectionScrollingFrame["Infinite Mode"].PlayerReq.Text == "Trait Tokens Available" and game.Players.LocalPlayer.leaderstats.Level.Value >= 20 and _G.RaidOpened == false then
                            game:GetService("ReplicatedStorage").RemoteFunctions.MainRemoteFunction:InvokeServer("CreateRoom",{["Difficulty"] = "Infinite",["FriendsOnly"] = _G.FriendOnly,["MapName"] = "Infinite Mode",["Hardcore"] = false})
                        elseif _G.AutoSpeedRaid == true and game:GetService("Players").LocalPlayer.PlayerGui.MainGui.CenterUIFrame.PlayButtonsFrame.Frame.SpeedRaidBanner.SpeedRaidBannerOpenText.Text == "Ready to enter" and _G.RaidOpened == false then
                            for i,v in pairs(game:GetService("Players").LocalPlayer.PlayerGui.MainGui.CenterUIFrame.SpeedRaidCharacterSelector.Shade.SpeedRaidCharacterInventoryScrollingFrame:GetChildren()) do
                                if v.ClassName == "ImageButton" then
                                    for ii,vv in pairs(v:GetChildren()) do
                                        if vv.ClassName == "ImageButton" and vv.Name == "CharacterImage" and vv.ImageTransparency == 0 then
                                            if v.Name ~= game:GetService("ReplicatedStorage")[game.Players.LocalPlayer.Name.."StatDisplay"].AssistCharacterName1.Value and v.Name ~= game:GetService("ReplicatedStorage")[game.Players.LocalPlayer.Name.."StatDisplay"].AssistCharacterName2.Value then
                                                game:GetService("ReplicatedStorage").RemoteFunctions.MainRemoteFunction:InvokeServer("TeleportToShadowRaid",v.Name)
                                                wait(60)
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    elseif _G.AutoRaid == false then
                        if _G.FreeBossRush == true and game:GetService("Players").LocalPlayer.PlayerGui.MainGui.CenterUIFrame.BossRushFrame.BossRushFreeEntry.Text == "1 Free Entry Left" then
                            game:GetService("ReplicatedStorage").RemoteFunctions.MainRemoteFunction:InvokeServer("TeleportToBossRush")
                        elseif _G.BossRush == true and tonumber(game:GetService("Players").LocalPlayer.PlayerGui.MainGui.CenterUIFrame.BossRushFrame.BossRushEntryPassCount.Text) > 0 then
                            game:GetService("ReplicatedStorage").RemoteFunctions.MainRemoteFunction:InvokeServer("TeleportToBossRush")
                        elseif _G.AutoTraitTokens == true and game:GetService("Players").LocalPlayer.PlayerGui.MainGui.CenterUIFrame.PlayFrame.Frame.PlayRoomFrame.MapSelectionScrollingFrame["Infinite Mode"].PlayerReq.Text == "Trait Tokens Available" and game.Players.LocalPlayer.leaderstats.Level.Value >= 20 then
                            game:GetService("ReplicatedStorage").RemoteFunctions.MainRemoteFunction:InvokeServer("CreateRoom",{["Difficulty"] = "Infinite",["FriendsOnly"] = _G.FriendOnly,["MapName"] = "Infinite Mode",["Hardcore"] = false})
                        elseif _G.AutoSpeedRaid == true and game:GetService("Players").LocalPlayer.PlayerGui.MainGui.CenterUIFrame.PlayButtonsFrame.Frame.SpeedRaidBanner.SpeedRaidBannerOpenText.Text == "Ready to enter" then
                            for i,v in pairs(game:GetService("Players").LocalPlayer.PlayerGui.MainGui.CenterUIFrame.SpeedRaidCharacterSelector.Shade.SpeedRaidCharacterInventoryScrollingFrame:GetChildren()) do
                                if v.ClassName == "ImageButton" then
                                    for ii,vv in pairs(v:GetChildren()) do
                                        if vv.ClassName == "ImageButton" and vv.Name == "CharacterImage" and vv.ImageTransparency == 0 then
                                            if v.Name ~= game:GetService("ReplicatedStorage")[game.Players.LocalPlayer.Name.."StatDisplay"].AssistCharacterName1.Value and v.Name ~= game:GetService("ReplicatedStorage")[game.Players.LocalPlayer.Name.."StatDisplay"].AssistCharacterName2.Value then
                                                game:GetService("ReplicatedStorage").RemoteFunctions.MainRemoteFunction:InvokeServer("TeleportToShadowRaid",v.Name)
                                                wait(60)
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                    wait(60)
                end)
            end
        end)
    end)

    spawn(function()
        pcall(function()
            wait(tonumber(_G.CooldownOnlobby))
            wait(5)
            while wait() do
                pcall(function()
                    if _G.AutoPlay == true then
                        if _G.GetAllDimensionCharacter == true then
                            if not game:GetService("Players").LocalPlayer.PlayerGui.MainGui.CenterUIFrame.Inventory.Frame.CharacterInventoryFrame.CharacterInventoryScrollingFrame:FindFirstChild("Sakura") then
                                game:GetService("ReplicatedStorage").RemoteFunctions.MainRemoteFunction:InvokeServer("CreateRoom",{["Difficulty"] = "Easy",["FriendsOnly"] = true,["MapName"] = "Titan Dimension",["Hardcore"] = _G.Hardcore})
                            elseif not game:GetService("Players").LocalPlayer.PlayerGui.MainGui.CenterUIFrame.Inventory.Frame.CharacterInventoryFrame.CharacterInventoryScrollingFrame:FindFirstChild("Natsu") then
                                game:GetService("ReplicatedStorage").RemoteFunctions.MainRemoteFunction:InvokeServer("CreateRoom",{["Difficulty"] = "Hard",["FriendsOnly"] = true,["MapName"] = "Titan Dimension",["Hardcore"] = _G.Hardcore})
                            elseif not game:GetService("Players").LocalPlayer.PlayerGui.MainGui.CenterUIFrame.Inventory.Frame.CharacterInventoryFrame.CharacterInventoryScrollingFrame:FindFirstChild("Killua") then
                                game:GetService("ReplicatedStorage").RemoteFunctions.MainRemoteFunction:InvokeServer("CreateRoom",{["Difficulty"] = "Nightmare",["FriendsOnly"] = true,["MapName"] = "Titan Dimension",["Hardcore"] = _G.Hardcore})
                            elseif not game:GetService("Players").LocalPlayer.PlayerGui.MainGui.CenterUIFrame.Inventory.Frame.CharacterInventoryFrame.CharacterInventoryScrollingFrame:FindFirstChild("Asta") then
                                game:GetService("ReplicatedStorage").RemoteFunctions.MainRemoteFunction:InvokeServer("CreateRoom",{["Difficulty"] = "Easy",["FriendsOnly"] = true,["MapName"] = "Demon Dimension",["Hardcore"] = _G.Hardcore})
                            elseif not game:GetService("Players").LocalPlayer.PlayerGui.MainGui.CenterUIFrame.Inventory.Frame.CharacterInventoryFrame.CharacterInventoryScrollingFrame:FindFirstChild("Itadori") then
                                game:GetService("ReplicatedStorage").RemoteFunctions.MainRemoteFunction:InvokeServer("CreateRoom",{["Difficulty"] = "Hard",["FriendsOnly"] = true,["MapName"] = "Demon Dimension",["Hardcore"] = _G.Hardcore})
                            elseif not game:GetService("Players").LocalPlayer.PlayerGui.MainGui.CenterUIFrame.Inventory.Frame.CharacterInventoryFrame.CharacterInventoryScrollingFrame:FindFirstChild("Akaza") then
                                game:GetService("ReplicatedStorage").RemoteFunctions.MainRemoteFunction:InvokeServer("CreateRoom",{["Difficulty"] = "Nightmare",["FriendsOnly"] = true,["MapName"] = "Demon Dimension",["Hardcore"] = _G.Hardcore})
                            elseif not game:GetService("Players").LocalPlayer.PlayerGui.MainGui.CenterUIFrame.Inventory.Frame.CharacterInventoryFrame.CharacterInventoryScrollingFrame:FindFirstChild("Sasuke") then
                                game:GetService("ReplicatedStorage").RemoteFunctions.MainRemoteFunction:InvokeServer("CreateRoom",{["Difficulty"] = "Easy",["FriendsOnly"] = true,["MapName"] = "Curse Dimension",["Hardcore"] = _G.Hardcore})
                            elseif not game:GetService("Players").LocalPlayer.PlayerGui.MainGui.CenterUIFrame.Inventory.Frame.CharacterInventoryFrame.CharacterInventoryScrollingFrame:FindFirstChild("Gray") then
                                game:GetService("ReplicatedStorage").RemoteFunctions.MainRemoteFunction:InvokeServer("CreateRoom",{["Difficulty"] = "Hard",["FriendsOnly"] = true,["MapName"] = "Curse Dimension",["Hardcore"] = _G.Hardcore})
                            elseif not game:GetService("Players").LocalPlayer.PlayerGui.MainGui.CenterUIFrame.Inventory.Frame.CharacterInventoryFrame.CharacterInventoryScrollingFrame:FindFirstChild("Sukuna") then
                                game:GetService("ReplicatedStorage").RemoteFunctions.MainRemoteFunction:InvokeServer("CreateRoom",{["Difficulty"] = "Nightmare",["FriendsOnly"] = true,["MapName"] = "Curse Dimension",["Hardcore"] = _G.Hardcore})
                            elseif not game:GetService("Players").LocalPlayer.PlayerGui.MainGui.CenterUIFrame.Inventory.Frame.CharacterInventoryFrame.CharacterInventoryScrollingFrame:FindFirstChild("Rukia") then
                                game:GetService("ReplicatedStorage").RemoteFunctions.MainRemoteFunction:InvokeServer("CreateRoom",{["Difficulty"] = "Easy",["FriendsOnly"] = true,["MapName"] = "Villain Dimension",["Hardcore"] = _G.Hardcore})
                            elseif not game:GetService("Players").LocalPlayer.PlayerGui.MainGui.CenterUIFrame.Inventory.Frame.CharacterInventoryFrame.CharacterInventoryScrollingFrame:FindFirstChild("Shinra") then
                                game:GetService("ReplicatedStorage").RemoteFunctions.MainRemoteFunction:InvokeServer("CreateRoom",{["Difficulty"] = "Hard",["FriendsOnly"] = true,["MapName"] = "Villain Dimension",["Hardcore"] = _G.Hardcore})
                            elseif not game:GetService("Players").LocalPlayer.PlayerGui.MainGui.CenterUIFrame.Inventory.Frame.CharacterInventoryFrame.CharacterInventoryScrollingFrame:FindFirstChild("All Might") then
                                game:GetService("ReplicatedStorage").RemoteFunctions.MainRemoteFunction:InvokeServer("CreateRoom",{["Difficulty"] = "Nightmare",["FriendsOnly"] = true,["MapName"] = "Villain Dimension",["Hardcore"] = _G.Hardcore})
                            elseif not game:GetService("Players").LocalPlayer.PlayerGui.MainGui.CenterUIFrame.Inventory.Frame.CharacterInventoryFrame.CharacterInventoryScrollingFrame:FindFirstChild("Zoro") then
                                game:GetService("ReplicatedStorage").RemoteFunctions.MainRemoteFunction:InvokeServer("CreateRoom",{["Difficulty"] = "Easy",["FriendsOnly"] = true,["MapName"] = "Sword Dimension",["Hardcore"] = _G.Hardcore})
                            elseif not game:GetService("Players").LocalPlayer.PlayerGui.MainGui.CenterUIFrame.Inventory.Frame.CharacterInventoryFrame.CharacterInventoryScrollingFrame:FindFirstChild("AsunaCharacter") then
                                game:GetService("ReplicatedStorage").RemoteFunctions.MainRemoteFunction:InvokeServer("CreateRoom",{["Difficulty"] = "Nightmare",["FriendsOnly"] = true,["MapName"] = "Sword Dimension",["Hardcore"] = _G.Hardcore})
                            elseif not game:GetService("Players").LocalPlayer.PlayerGui.MainGui.CenterUIFrame.Inventory.Frame.CharacterInventoryFrame.CharacterInventoryScrollingFrame:FindFirstChild("Emiya Archer") then
                                game:GetService("ReplicatedStorage").RemoteFunctions.MainRemoteFunction:InvokeServer("CreateRoom",{["Difficulty"] = "Easy",["FriendsOnly"] = true,["MapName"] = "Ghoul Dimension",["Hardcore"] = _G.Hardcore})
                            elseif not game:GetService("Players").LocalPlayer.PlayerGui.MainGui.CenterUIFrame.Inventory.Frame.CharacterInventoryFrame.CharacterInventoryScrollingFrame:FindFirstChild("KanekiCharacter") then
                                game:GetService("ReplicatedStorage").RemoteFunctions.MainRemoteFunction:InvokeServer("CreateRoom",{["Difficulty"] = "Nightmare",["FriendsOnly"] = true,["MapName"] = "Ghoul Dimension",["Hardcore"] = _G.Hardcore})
                            elseif not game:GetService("Players").LocalPlayer.PlayerGui.MainGui.CenterUIFrame.Inventory.Frame.CharacterInventoryFrame.CharacterInventoryScrollingFrame:FindFirstChild("Lancer") then
                                game:GetService("ReplicatedStorage").RemoteFunctions.MainRemoteFunction:InvokeServer("CreateRoom",{["Difficulty"] = "Easy",["FriendsOnly"] = true,["MapName"] = "Fate Dimension",["Hardcore"] = _G.Hardcore})
                            elseif not game:GetService("Players").LocalPlayer.PlayerGui.MainGui.CenterUIFrame.Inventory.Frame.CharacterInventoryFrame.CharacterInventoryScrollingFrame:FindFirstChild("Saber Alter Character") then
                                game:GetService("ReplicatedStorage").RemoteFunctions.MainRemoteFunction:InvokeServer("CreateRoom",{["Difficulty"] = "Nightmare",["FriendsOnly"] = true,["MapName"] = "Fate Dimension",["Hardcore"] = _G.Hardcore})
                            elseif not game:GetService("Players").LocalPlayer.PlayerGui.MainGui.CenterUIFrame.Inventory.Frame.CharacterInventoryFrame.CharacterInventoryScrollingFrame:FindFirstChild("Diablo") then
                                game:GetService("ReplicatedStorage").RemoteFunctions.MainRemoteFunction:InvokeServer("CreateRoom",{["Difficulty"] = "Easy",["FriendsOnly"] = true,["MapName"] = "Slime Dimension",["Hardcore"] = _G.Hardcore})
                            elseif not game:GetService("Players").LocalPlayer.PlayerGui.MainGui.CenterUIFrame.Inventory.Frame.CharacterInventoryFrame.CharacterInventoryScrollingFrame:FindFirstChild("Rimuru") then
                                game:GetService("ReplicatedStorage").RemoteFunctions.MainRemoteFunction:InvokeServer("CreateRoom",{["Difficulty"] = "Nightmare",["FriendsOnly"] = true,["MapName"] = "Slime Dimension",["Hardcore"] = _G.Hardcore})
                            elseif not game:GetService("Players").LocalPlayer.PlayerGui.MainGui.CenterUIFrame.Inventory.Frame.CharacterInventoryFrame.CharacterInventoryScrollingFrame:FindFirstChild("PowerCharacter") then
                                game:GetService("ReplicatedStorage").RemoteFunctions.MainRemoteFunction:InvokeServer("CreateRoom",{["Difficulty"] = "Nightmare",["FriendsOnly"] = true,["MapName"] = "Devil Dimension",["Hardcore"] = _G.Hardcore})
                            elseif not game:GetService("Players").LocalPlayer.PlayerGui.MainGui.CenterUIFrame.Inventory.Frame.CharacterInventoryFrame.CharacterInventoryScrollingFrame:FindFirstChild("Yamato") then
                                game:GetService("ReplicatedStorage").RemoteFunctions.MainRemoteFunction:InvokeServer("CreateRoom",{["Difficulty"] = "Nightmare",["FriendsOnly"] = true,["MapName"] = "Pirate Dimension",["Hardcore"] = _G.Hardcore})
                            elseif _G.MapSelection == "Infinite Mode" then
                                game:GetService("ReplicatedStorage").RemoteFunctions.MainRemoteFunction:InvokeServer("CreateRoom",{["Difficulty"] = "Infinite",["FriendsOnly"] = _G.FriendOnly,["MapName"] = "Infinite Mode",["Hardcore"] = false})
                            elseif _G.MapSelection == "TimeChallenge" then
                                game:GetService("ReplicatedStorage").RemoteFunctions.MainRemoteFunction:InvokeServer("TeleportToTimeChallenge")
                            elseif _G.MapSelection ~= "Infinite Mode" then
                                game:GetService("ReplicatedStorage").RemoteFunctions.MainRemoteFunction:InvokeServer("CreateRoom",{["Difficulty"] = _G.Difficulty,["FriendsOnly"] = _G.FriendOnly,["MapName"] = _G.MapSelection,["Hardcore"] = _G.Hardcore})
                            end
                        else
                            if _G.MapSelection == "Infinite Mode" then
                                game:GetService("ReplicatedStorage").RemoteFunctions.MainRemoteFunction:InvokeServer("CreateRoom",{["Difficulty"] = "Infinite",["FriendsOnly"] = _G.FriendOnly,["MapName"] = "Infinite Mode",["Hardcore"] = false})
                            elseif _G.MapSelection == "TimeChallenge" then
                                game:GetService("ReplicatedStorage").RemoteFunctions.MainRemoteFunction:InvokeServer("TeleportToTimeChallenge")
                            elseif _G.MapSelection ~= "Infinite Mode" then
                                game:GetService("ReplicatedStorage").RemoteFunctions.MainRemoteFunction:InvokeServer("CreateRoom",{["Difficulty"] = _G.Difficulty,["FriendsOnly"] = _G.FriendOnly,["MapName"] = _G.MapSelection,["Hardcore"] = _G.Hardcore})
                            end
                        end
                        wait(1)
                        game:GetService("ReplicatedStorage").RemoteFunctions.MainRemoteFunction:InvokeServer("TeleportPlayers")
                        wait(60)
                    end
                end)
            end
        end)
    end)

    spawn(function()
        pcall(function()
            while task.wait() do
                pcall(function()
                    if _G.AutoSelectMap == true then
                        Lvl = game.Players.LocalPlayer.leaderstats.Level.Value
                        if Lvl > 0 and Lvl < 6 then
                            _G.Difficulty = "Easy"
                            _G.MapSelection = "Titan Dimension"
                        elseif Lvl > 5 and Lvl < 11 then
                            _G.Difficulty = "Hard"
                             _G.MapSelection = "Titan Dimension"
                        elseif Lvl > 10 and Lvl < 16 then
                            _G.Difficulty = "Nightmare"
                            _G.MapSelection = "Titan Dimension"
                        elseif Lvl > 15 and Lvl < 21 then
                            _G.Difficulty = "Easy"
                            _G.MapSelection = "Demon Dimension"
                        elseif Lvl > 20 and Lvl < 26 then
                            _G.Difficulty = "Hard"
                            _G.MapSelection = "Demon Dimension"
                        elseif Lvl > 25 and Lvl < 31 then
                            _G.Difficulty = "Nightmare"
                            _G.MapSelection = "Demon Dimension"
                        elseif Lvl > 30 and Lvl < 36 then
                            _G.Difficulty = "Easy"
                            _G.MapSelection = "Curse Dimension"
                        elseif Lvl > 35 and Lvl < 41 then
                            _G.Difficulty = "Hard"
                            _G.MapSelection = "Curse Dimension"
                        elseif Lvl > 40 and Lvl < 46 then
                            _G.Difficulty = "Nightmare"
                            _G.MapSelection = "Curse Dimension"
                        elseif Lvl > 45 and Lvl < 51 then
                            _G.Difficulty = "Easy"
                            _G.MapSelection = "Villain Dimension"
                        elseif Lvl > 50 and Lvl < 56 then
                            _G.Difficulty = "Hard"
                            _G.MapSelection = "Villain Dimension"
                        elseif Lvl > 55 and Lvl < 61 then
                            _G.Difficulty = "Nightmare"
                            _G.MapSelection = "Villain Dimension"
                        elseif Lvl > 60 and Lvl < 68 then
                            _G.Difficulty = "Easy"
                            _G.MapSelection = "Sword Dimension"
                        elseif Lvl > 67 and Lvl < 76 then
                            _G.Difficulty = "Nightmare"
                            _G.MapSelection = "Sword Dimension"
                        elseif Lvl > 75 and Lvl < 83 then
                            _G.Difficulty = "Easy"
                            _G.MapSelection = "Ghoul Dimension"
                        elseif Lvl > 82 and Lvl < 91 then
                            _G.Difficulty = "Nightmare"
                            _G.MapSelection = "Ghoul Dimension"
                        elseif Lvl > 90 and Lvl < 98 then
                            _G.Difficulty = "Easy"
                            _G.MapSelection = "Fate Dimension"
                        elseif Lvl > 97 and Lvl < 106 then
                            _G.Difficulty = "Nightmare"
                            _G.MapSelection = "Fate Dimension"
                        elseif Lvl > 105 and Lvl < 113 then
                            _G.Difficulty = "Easy"
                            _G.MapSelection = "Slime Dimension"
                        elseif Lvl > 112 and Lvl < 121 then
                            _G.Difficulty = "Nightmare"
                            _G.MapSelection = "Slime Dimension"
                        elseif Lvl > 120 and Lvl < 131 then
                            _G.Difficulty = "Nightmare"
                            _G.MapSelection = "Devil Dimension"
                        elseif Lvl > 130 then
                            _G.Difficulty = "Nightmare"
                            _G.MapSelection = "Pirate Dimension"
                        end
                    end
                end)
            end
        end)
    end)

    spawn(function()
        pcall(function()
            while wait(1) do
                pcall(function()
                    if _G.AutoEquipCharacter then
                        if isfile("Character_SuiSui.json") then
                            Config = game:GetService("HttpService"):JSONDecode(readfile("Character_SuiSui.json"))
                        end
                        for i,v in pairs(Config) do
                            if tostring(i) == "Character1" then
                                game:GetService("ReplicatedStorage").RemoteFunctions.MainRemoteFunction:InvokeServer("EquipCharacter",tostring(v))
                                print("Character1 : "..tostring(v))
                            elseif tostring(i) == "Character2" then
                                game:GetService("ReplicatedStorage").RemoteFunctions.MainRemoteFunction:InvokeServer("EquipCharacterAssist",tostring(v),1)
                                print("Character2 : "..tostring(v))
                            elseif tostring(i) == "Character3" then
                                game:GetService("ReplicatedStorage").RemoteFunctions.MainRemoteFunction:InvokeServer("EquipCharacterAssist",tostring(v),2)
                                print("Character3 : "..tostring(v))
                            end
                        end
                        wait(6000)
                    end
                end)
            end
        end)
    end)

    local function isGuiActuallyVisible(obj)
        if not obj or not obj:IsA("GuiObject") then return false end
        if not obj.Visible then return false end
        if obj.AbsoluteSize.X <= 5 or obj.AbsoluteSize.Y <= 5 then return false end
        local curr = obj.Parent
        while curr and curr:IsA("GuiObject") do
            if not curr.Visible then return false end
            curr = curr.Parent
        end
        if curr and curr:IsA("LayerCollector") then
            if not curr.Enabled then return false end
        end
        return true
    end

    spawn(function()
        pcall(function()
            local isReplaying = false
            while task.wait(0.5) do
                pcall(function()
                    if _G.Replay == true and not isReplaying then
                        local pgui = game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui")
                        if not pgui then return end

                        -- Dung replay neu dang mo Raid va bat StopReplay
                        if _G.RaidOpened == true and _G.StopReplay == true then
                            return
                        end

                        local uGui = pgui:FindFirstChild("UniversalGui")
                        local cFrame = uGui and uGui:FindFirstChild("UniversalCenterUIFrame")
                        local resUI = cFrame and cFrame:FindFirstChild("ResultUI")
                        local raidResUI = cFrame and cFrame:FindFirstChild("RaidResultUI")

                        -- Chi kich hoat khi ResultUI hoac RaidResultUI thuc su hien tren man hinh
                        local resultVisible = (resUI and resUI.Visible == true) or (raidResUI and raidResUI.Visible == true)
                        
                        -- Kiem tra them cac bang ket qua khac neu co
                        if not resultVisible then
                            for _, gui in ipairs(pgui:GetChildren()) do
                                if gui:IsA("ScreenGui") and gui.Enabled == true then
                                    for _, frame in ipairs(gui:GetChildren()) do
                                        if frame:IsA("GuiObject") and frame.Visible == true then
                                            local n = frame.Name:lower()
                                            if (n:find("result") or n:find("clear") or n:find("finish")) and frame.AbsoluteSize.X > 100 then
                                                resultVisible = true
                                                break
                                            end
                                        end
                                    end
                                end
                                if resultVisible then break end
                            end
                        end

                        if resultVisible then
                            -- Tim nut Retry / Replay
                            local targetBtn = nil
                            
                            -- 1. Uu tien nut goc RetryDungeonButton trong ResultUI
                            if resUI and resUI:FindFirstChild("RetryDungeonButton", true) then
                                local btn = resUI:FindFirstChild("RetryDungeonButton", true)
                                if btn:IsA("GuiButton") and btn.Visible == true then
                                    targetBtn = btn
                                end
                            end

                            -- 2. Quet ben trong frame ket qua
                            if not targetBtn and resUI then
                                for _, d in ipairs(resUI:GetDescendants()) do
                                    if d:IsA("GuiButton") and d.Visible == true then
                                        local n = d.Name:lower()
                                        if n:find("retry") or n:find("replay") or n:find("again") then
                                            targetBtn = d
                                            break
                                        end
                                    end
                                end
                            end

                            -- 3. Quet toan bo PlayerGui tim nut thuc su nhin thay duoc
                            if not targetBtn then
                                for _, d in ipairs(pgui:GetDescendants()) do
                                    if d:IsA("GuiButton") and isGuiActuallyVisible(d) then
                                        local n = d.Name:lower()
                                        if n:find("retry") or n:find("replay") then
                                            targetBtn = d
                                            break
                                        end
                                    end
                                end
                            end

                            -- Kich hoat choi lai
                            isReplaying = true
                            print("[SuiSui AutoReplay] Ket qua xuat hien! Chuan bi replay...")
                            task.wait(1.2) -- Cho animation ket qua mo hoan tat

                            -- A. Goi RemoteEvents cua Game
                            pcall(function()
                                game:GetService("ReplicatedStorage").RemoteEvents.MainRemoteEvent:FireServer("RetryDungeon")
                            end)

                            -- B. Goi RemoteFunctions cua Game
                            pcall(function()
                                game:GetService("ReplicatedStorage").RemoteFunctions.MainRemoteFunction:InvokeServer("RetryDungeon")
                            end)

                            -- C. Neu tim thay nut thi nhan truc tiep
                            if targetBtn then
                                pcall(function()
                                    if getconnections then
                                        for _, ev in ipairs({"MouseButton1Click", "Activated", "MouseButton1Down"}) do
                                            if targetBtn[ev] then
                                                for _, conn in ipairs(getconnections(targetBtn[ev])) do
                                                    conn:Fire()
                                                end
                                            end
                                        end
                                    end
                                end)

                                pcall(function()
                                    for _, ev in ipairs({"MouseButton1Click", "MouseButton1Down", "Activated"}) do
                                        if targetBtn[ev] then firesignal(targetBtn[ev]) end
                                    end
                                end)

                                pcall(function()
                                    local pos = targetBtn.AbsolutePosition + (targetBtn.AbsoluteSize / 2)
                                    local vim = game:GetService("VirtualInputManager")
                                    vim:SendMouseButtonEvent(pos.X, pos.Y, 0, true, game, 1)
                                    task.wait(0.05)
                                    vim:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 1)
                                end)
                            end

                            task.wait(4.0) -- Cho game nhan remote va chuyen man hinh
                            isReplaying = false
                        end
                    end
                end)
            end
        end)
    end)
    spawn(function()
        pcall(function()
            while task.wait() do
                if game:GetService("Players").LocalPlayer.DevCameraOcclusionMode ~= "Invisicam" then
                    game:GetService("Players").LocalPlayer.DevCameraOcclusionMode = "Invisicam"
                end
            end
        end)
    end)
    spawn(function()
        pcall(function()
            while task.wait() do
                pcall(function()
                    if _G.DontNoclip == true then
                        for i,v in pairs(game.Players.LocalPlayer.Character:GetChildren()) do
                            if v:IsA("BasePart") then
                                v.CanCollide = true
                            end
                        end
                    else
                        if _G.DodgeSkill == true and game.PlaceId ~= 6938803436 and game.PlaceId ~= 7274690025 and game.PlaceId ~= 7338881230 then
                            if _G.Automob == false and _G.DodgeSkill == true then
                                for i,v in pairs(game.Players.LocalPlayer.Character:GetChildren()) do
                                    if v:IsA("BasePart") then
                                        v.CanCollide = true
                                    end
                                end
                            elseif workspace.Folders.Debris:FindFirstChild("DodgePart") then
                                for i,v in pairs(game.Players.LocalPlayer.Character:GetChildren()) do
                                    if v:IsA("BasePart") then
                                        v.CanCollide = true
                                    end
                                end
                            elseif not workspace.Folders.Debris:FindFirstChild("DodgePart") then
                                for i,v in pairs(game.Players.LocalPlayer.Character:GetChildren()) do
                                    if v:IsA("BasePart") then
                                        v.CanCollide = false
                                    end
                                end
                            end
                        elseif _G.DodgeSkill == false and game.PlaceId ~= 6938803436 and game.PlaceId ~= 7274690025 and game.PlaceId ~= 7338881230 then
                            for i,v in pairs(game.Players.LocalPlayer.Character:GetChildren()) do
                                if v:IsA("BasePart") then
                                    v.CanCollide = false
                                end
                            end
                        end
                    end
                end)
            end
        end)
    end)
        
    spawn(function()
        pcall(function()
            while task.wait() do
                pcall(function()
                    if _G.BackToLobbyIfGotExploitsDetected then
                        if game.ReplicatedStorage[game.Players.LocalPlayer.Name .. "StatDisplay"].ExploitsDetected.Value == true then
                            game:GetService("TeleportService"):Teleport(6938803436)
                        end
                    end
                end)
            end
        end)
    end)
    spawn(function()
        pcall(function()
            while task.wait() do
                pcall(function()
                    if _G.HideName then
                        for i,v in pairs(game.Players.LocalPlayer.Character.Head:GetChildren()) do
                            if v.ClassName == "BillboardGui" then
                                v:Destroy()
                            end
                        end
                    end
                end)
            end
        end)
    end)

    spawn(function()
        pcall(function()
            workspace.Folders.Debris.ChildAdded:Connect(function(v)
                pcall(function()
                    if table.find({"telegraph"},v.Name:lower()) and v.Material ~= Enum.Material.Neon and _G.AutoDodgeSkill == true then
                        local op = v.Material
                        local a = v:Clone()
                        local side = math.clamp(tonumber(_G.SizeDodgePart),0,10)
                        local Sizeto = v.Size + Vector3.new(side,tonumber(_G.SizeDodgePartY),side)
                        a.Size = Vector3.new(0,0,v.Size.Z)
                        if v.ClassName == "MeshPart" then
                            a.Size = Vector3.new(0,0,100)
                            Sizeto = v.Size + Vector3.new(side,side,100)
                        end
                        game:GetService("TweenService"):Create(a,TweenInfo.new(tonumber(_G.TweenDodgePart)),{Size = Sizeto}):Play()
                        a.CFrame = v.CFrame + Vector3.new(0,0,0)
                        a.Anchored = true
                        a.Transparency = tonumber(_G.DodgePartTransparency)
                        a.CanCollide = true
                        a.Name = "DodgePart"
                        a.Parent = v.Parent
                        repeat wait() until not v.Parent
                        a:Destroy()
                    end
                end)
            end)
        end)
    end)

    spawn(function()
        pcall(function()
            while wait(2) do
                pcall(function()
                    if _G.AutoRedeemAllCode == true then
                        Code = {}
                        for i,v in pairs(workspace.Leaderboards.MilestoneBoard.Center.Surface.ScrollingFrame:GetChildren()) do
                            if v.ClassName == "Frame" then
                                Code = {v.MilestoneCode.Text}
                            end
                        end
                        for i,v in pairs(Code) do
                            game:GetService("ReplicatedStorage").RemoteFunctions.MainRemoteFunction:InvokeServer("RedeemPromoCode",v)
                        end
                        wait(600)
                    end
                end)
            end
        end)
    end)









































    local TabSetting = Window:CreateTab("Tiện Ích")
    local Setting1 = TabSetting:CreateSector("Điều Khiển Giao Diện & Tiện Ích", "left")
    Setting1:AddToggle("Ẩn GUI Khi Khởi Động (Auto Hide)", false, function(o)
        _G.AutoHideGui = o
        _G.CloseGuiAfterExecute = o
    end, "AutoHideGui")
    Setting1:AddButton("Ẩn / Hiện GUI (Toggle)", function()
        pcall(function()
            for _, v in pairs(game:GetService("CoreGui"):GetChildren()) do
                if v:FindFirstChild("main") then
                    v.main.Visible = not v.main.Visible
                end
            end
            local plrGui = game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui")
            if plrGui then
                for _, v in pairs(plrGui:GetChildren()) do
                    if v:FindFirstChild("main") then
                        v.main.Visible = not v.main.Visible
                    end
                end
            end
        end)
    end)
    Setting1:AddTextbox("Speed" , "16" , function(w)
        _G.Speed = w
    end)
    Setting1:AddTextbox("Jump" , "50" , function(w)
        _G.Jump = w
    end)
    Setting1:AddToggle("WalkSpeed", false, function(t)
		_G.WalkSpeed = t
	end)
    Setting1:AddToggle("JumpPower", false, function(t)
		_G.JumpPower = t
	end)
    Setting1:AddToggle("Ctrl+ClickTP", false, function(t)
		_G.CtrlClickTP = t
	end)
	Setting1:AddButton("Rejoin" , function()
	    game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, game:GetService("Players").LocalPlayer)
	end)
	Setting1:AddButton("HopServer" , function()
	    local v0=game.PlaceId;local v1={};local v2="";local v3=os.date("!*t").hour;local v4=false;local v5=pcall(function()v1=game:GetService("HttpService"):JSONDecode(readfile("NotSameServers.json"));end);if  not v5 then table.insert(v1,v3);writefile("NotSameServers.json",game:GetService("HttpService"):JSONEncode(v1));end function TPReturner()local v6;if (v2=="") then v6=game.HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"   .. v0   .. "/servers/Public?sortOrder=Asc&limit=100" ));else v6=game.HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"   .. v0   .. "/servers/Public?sortOrder=Asc&limit=100&cursor="   .. v2 ));end local v7="";if (v6.nextPageCursor and (v6.nextPageCursor~="null") and (v6.nextPageCursor~=nil)) then v2=v6.nextPageCursor;end local v8=0;for v9,v10 in pairs(v6.data) do local v11=true;v7=tostring(v10.id);if (tonumber(v10.maxPlayers)>tonumber(v10.playing)) then for v13,v14 in pairs(v1) do if (v8~=0) then if (v7==tostring(v14)) then v11=false;end elseif (tonumber(v3)~=tonumber(v14)) then local v15=pcall(function()delfile("NotSameServers.json");v1={};table.insert(v1,v3);end);end v8=v8 + 1 ;end if (v11==true) then table.insert(v1,v7);wait();pcall(function()writefile("NotSameServers.json",game:GetService("HttpService"):JSONEncode(v1));wait();game:GetService("TeleportService"):TeleportToPlaceInstance(v0,v7,game.Players.LocalPlayer);end);wait(4);end end end end function Teleport()while wait() do pcall(function()TPReturner();if (v2~="") then TPReturner();end end);end end Teleport();
	end)
	Setting1:AddButton("FireProximityPrompt" , function()
        for i, v in pairs(game:GetService("Workspace"):GetDescendants()) do
            if v:IsA("ProximityPrompt") then
                fireproximityprompt(v)
            end
        end
	end)
	Setting1:AddButton("InstantProximityPrompt" , function()
        game:GetService("ProximityPromptService").PromptButtonHoldBegan:Connect(function(prompt)
            prompt.HoldDuration = 0
        end)
	end)
    spawn(function()
    pcall(function()
        while task.wait() do
            pcall(function()
                if _G.WalkSpeed then
                    pcall(function()
                        game.Players.LocalPlayer.character.Humanoid.WalkSpeed = tonumber(_G.Speed)
                    end)
                end
            end)
        end
    end)
    end)
    spawn(function()
    pcall(function()
        while task.wait() do
            pcall(function()
                if _G.JumpPower then
                    pcall(function()
                        game.Players.LocalPlayer.character.Humanoid.JumpPower = tonumber(_G.Jump)
                    end)
                end
            end)
        end
    end)
    end)
    function ClickTP()
        local UIS = game:GetService("UserInputService")
        local Player = game.Players.LocalPlayer
        local Mouse = Player:GetMouse()
        function GetCharacter()
        return game.Players.LocalPlayer.Character
        end
        function Teleport(pos)
        local Char = GetCharacter()
        if Char then
            Char:MoveTo(pos)
        end
        end
        UIS.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 and UIS:IsKeyDown(Enum.KeyCode.LeftControl) and _G.CtrlClickTP == true then
                Teleport(Mouse.Hit.p)
            end
        end)
    end
	local Setting2 = TabSetting:CreateSector("Section2", "Right")
    Setting2:AddDropdown("StatGuiPosition", {"Center","Left","Right"}, "Right", false, function(h)
        pcall(function()
            game:GetService("CoreGui").StatBySmell.Frame.UIListLayout.HorizontalAlignment = h
        end)
    end)
    Setting2:AddToggle("StatGui", true, function(o)
        pcall(function()
            game:GetService("CoreGui").StatBySmell.Enabled = o
        end)
    end)
	Setting2:AddToggle("RejoinIfGotKick", false, function(o)
    	_G.rejoinKick = o
    end)

    spawn(function()
        getgenv().rejoin = game:GetService("CoreGui").RobloxPromptGui.promptOverlay.ChildAdded:Connect(function(Kick)
            if ((Kick.Name == "ErrorPrompt") and Kick:FindFirstChild("MessageArea") and Kick.MessageArea:FindFirstChild("ErrorFrame")) then
                if _G.rejoinKick == true then
                    game:GetService("TeleportService"):Teleport(6938803436)
                end
            end
        end)
    end)
    Setting2:AddToggle("BootsWhitescreen", false, function(o)
    	_G.BootsWhitescreen = o
    end)
    Setting2:AddButton("Infinite Yield", function()
        pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
        end)
    end)
    Setting2:AddButton("Dark Dex (Soi Thu Muc)", function()
        pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/babyhamsta/RBLX_Scripts/main/Universal/DarkDexV4.lua"))()
        end)
    end)
    Setting2:AddButton("SimpleSpy (Soi Remote)", function()
        pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/SimpleSpyV3/main.lua"))()
        end)
    end)
    Setting2:AddButton("ResetCamera" , function()
        game:GetService("Workspace").CurrentCamera:Destroy()
        wait(.1)
        game:GetService("Workspace").CurrentCamera.CameraSubject = game:GetService("Players").LocalPlayer.Character.Humanoid
        game:GetService("Workspace").CurrentCamera.CameraType = "Custom"
        game:GetService("Players").LocalPlayer.CameraMinZoomDistance = .5
        game:GetService("Players").LocalPlayer.CameraMaxZoomDistance = 100000
        game:GetService("Players").LocalPlayer.CameraMode = "Classic"
    end)

    spawn(function()
    pcall(function()
        while wait() do
            pcall(function()
                if _G.CloseGuiAfterExecute then
                    pcall(function()
                        wait()
                        for i,v in pairs(game:GetService("CoreGui"):GetChildren()) do
                            if v:FindFirstChild("main") then
                                v.main.Visible = not v.main.Visible
                            end
                        end
                        wait(99999999999999999999999)
                    end)
                end
            end)
        end
    end)
    end)
    spawn(function()
    pcall(function()
    	while wait() do
    		if _G.BootsWhitescreen then
    		    wait()
                local v0;local v1=game;local v2=v1.Workspace;local v3=v1.Lighting;local v4=v2.Terrain;v4.WaterWaveSize=0;v4.WaterWaveSpeed=0;v4.WaterReflectance=0;v4.WaterTransparency=0;v3.GlobalShadows=false;v3.FogEnd=8999999488;v3.Brightness=0;settings().Rendering.QualityLevel="Level01";for v18,v19 in pairs(v1:GetDescendants()) do if (v19:IsA("Part") or v19:IsA("Union") or v19:IsA("CornerWedgePart") or v19:IsA("TrussPart")) then v19.Material="Plastic";v19.Reflectance=0;elseif (v19:IsA("Decal") or (v19:IsA("Texture") and v0)) then v19.Transparency=1;elseif (v19:IsA("ParticleEmitter") or v19:IsA("Trail")) then v19.Lifetime=NumberRange.new(0);elseif v19:IsA("Explosion") then v19.BlastPressure=1;v19.BlastRadius=1;elseif (v19:IsA("Fire") or v19:IsA("SpotLight") or v19:IsA("Smoke")) then v19.Enabled=false;elseif v19:IsA("MeshPart") then v19.Material="Plastic";v19.Reflectance=0;v19.TextureID=10385902758728956;end end for v20,v21 in pairs(v3:GetChildren()) do if (v21:IsA("BlurEffect") or v21:IsA("SunRaysEffect") or v21:IsA("ColorCorrectionEffect") or v21:IsA("BloomEffect") or v21:IsA("DepthOfFieldEffect")) then v21.Enabled=false;end end local v13=game:GetService("UserInputService");local v14=game:GetService("RunService");local v15=function()v14:Set3dRenderingEnabled(false);return;end;local v16=function()v14:Set3dRenderingEnabled(true);return;end;local v17=function()v13.WindowFocusReleased:Connect(v15);v13.WindowFocused:Connect(v16);return;end;v17();
    			wait(99999999999999999999999)
    		end
    	end
    end)
    end)
	game:GetService("Players").LocalPlayer.Idled:connect(function()
		game:GetService("VirtualUser"):CaptureController()
		game:GetService("VirtualUser"):ClickButton2(Vector2.new())
	end)
    ClickTP()
	library:ConfigSystem("SuiSuiHUB"):Load()
    task.spawn(function()
        task.wait(1.0)
        if _G.AutoHideGui == true or _G.CloseGuiAfterExecute == true then
            pcall(function()
                for _, v in pairs(game:GetService("CoreGui"):GetChildren()) do
                    if v:FindFirstChild("main") then
                        v.main.Visible = false
                    end
                end
                local plrGui = game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui")
                if plrGui then
                    for _, v in pairs(plrGui:GetChildren()) do
                        if v:FindFirstChild("main") then
                            v.main.Visible = false
                        end
                    end
                end
                if Notification then
                    Notification(1, "SuiSui Tiên Các", "Đã tự động ẩn GUI! Bấm nút Menu trên StatGui để mở lại.", 4)
                end
            end)
        end
    end)
    while wait(1) do
    	pcall(function()
    		library:ConfigSystem("SuiSuiHUB"):Save()
    	end)
	end
end
