local CR = getModule("CreateRecursive")
local autoc = {}

function autoc.Init()
  local TextService = game:GetService("TextService")
  local menu = CR.Create({
    {
      ClassName = "ScreenGui",
      Childs = {
        {
          ClassName = "Frame",
          BackgroundColor3 = Color3.fromRGB(5,5,5),
          BorderSizePixel = 0,
          Size = UDim2.new(0,350,0,20),
          Position = UDim2.fromScale(0.5,0.5),
          AnchorPoint = Vector2.new(0.5,0.5),
          Name = "Drag",
          Childs = {
            {
              ClassName = "UICorner"
            },
            {
              ClassName = "Frame",
              BackgroundColor3 = Color3.fromRGB(5,5,5),
              BorderSizePixel = 0,
              Size = UDim2.new(1,0,0,7),
              Position = UDim2.fromScale(0.5,1),
              AnchorPoint = Vector2.new(0.5,1),
            },
            {
              ClassName = "UIDragDetector"
            },
            {
              ClassName = "Frame",
              BackgroundColor3 = Color3.fromRGB(10,10,10),
              BorderSizePixel = 0,
              Size = UDim2.new(1,0,0,250),
              Position = UDim2.fromScale(0.5,1),
              AnchorPoint = Vector2.new(0.5,0),
              Name = "Content",
              Childs = {
                {
                  ClassName = "UICorner"
                },
                {
                  ClassName = "Frame",
                  BackgroundColor3 = Color3.fromRGB(10,10,10),
                  BorderSizePixel = 0,
                  Size = UDim2.new(1,0,0,7),
                  Position = UDim2.fromScale(0.5,0),
                  AnchorPoint = Vector2.new(0.5,0)
                },
                {
                  ClassName = "TextBox",
                  ClearTextOnFocus = false,
                  BorderSizePixel = 0,
                  Size = UDim2.new(1,0,1,0),
                  MultiLine = true,
                  BackgroundTransparency = 1,
                  
                  TextColor3 = Color3.fromRGB(255,255,255),
                  Font = Enum.Font.Code,
                  PlaceholderText = "-- Code here",
                  Text = "",
                  TextSize = 10,
                  TextXAlignment = Enum.TextXAlignment.Left,
                  TextYAlignment = Enum.TextYAlignment.Top,
                  
                  Name = "Text",
                  
                  Childs = {
                    {
                      ClassName = "UIPadding",
                      PaddingLeft = UDim.new(0,3),
                      PaddingTop = UDim.new(0,3),
                      PaddingRight = UDim.new(0,3),
                      PaddingBottom = UDim.new(0,3)
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }, nil, game:GetService("CoreGui"))

  
  local text = menu.Drag.Content.Text
  local rect = CR.Create({
    {
      ClassName = "Frame",
      BackgroundColor3 = Color3.fromRGB(50,50,50),
      BorderSizePixel = 0,
      Size = UDim2.new(0,150,0,15),
      AnchorPoint = Vector2.new(0,0),
      Name = "AutoCBox",
      Visible = false
    }
  }, nil, text)

  local curLine = 0
  local curLineSize = 0

  local function calcLine()
  	local cur = text.CursorPosition
  	local fullText = text.Text
  	
  	local currentPosition = 1
  	local lineIndex = 1
  	
  	for line in fullText:gmatch("([^\n]*)\n?") do
  		local lineLength = #line
  		local nextPosition = currentPosition + lineLength + 1
  	  
  		if cur >= currentPosition and cur <= (currentPosition + lineLength) then
  			curLine = lineIndex
  			curLineSize = lineLength
  			break
  		end
  		
  		currentPosition = nextPosition
  		lineIndex = lineIndex + 1
  		
  		if currentPosition > #fullText + 1 then
  			break
  		end
  	end
  end

  text:GetPropertyChangedSignal("CursorPosition"):Connect(function()
  	if text.CursorPosition == -1 then rect.Visible = false else rect.Visible = true end
  	calcLine()
  	
  	local fullText = text.Text
  	local lines = fullText:split("\n")
  	local currentLineText = lines[curLine] or ""
  	
  	local cursorIndexInLine = curLineSize - (#currentLineText - (text.CursorPosition - 1))
  	cursorIndexInLine = math.clamp(cursorIndexInLine, 0, #currentLineText)
  	
  	local textBeforeCursor = currentLineText:sub(1, cursorIndexInLine)
  	
  	local textBounds = TextService:GetTextSize(
  		textBeforeCursor,
  		text.TextSize,
  		text.Font,
  		Vector2.new(math.huge, math.huge)
  	)
  	
  	local lineHeight = text.TextSize * text.LineHeight
  	local posY = lineHeight --* (curLine - 1)
  	
  	rect.Position = UDim2.fromOffset(textBounds.X-7, posY)
  end)
  
  
  -- task.wait(15)
  -- menu:Destroy()
end

return autoc