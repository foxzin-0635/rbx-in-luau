local CR = getModule("CreateRecursive")
local autoc = {}

function autoc.Init()
  local s = game:GetService("TextService")
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
      Name = "AutoCBox"
    }
  }, nil, text)

  local curLine = 0
  local curLineSize = 0

  local function calcLine(endI, i)
    local cur = text.CursorPosition
    
    local startIdx, endIdx = text.Text:find("[^\n]*", endI)
    
    if startIdx then
      if cur >= startIdx and cur <= endIdx then
        curLine = i
        curLineSize = endIdx-startIdx
      else
        print(#text.Text, endIdx, endI, i)
        if #text.Text == endIdx then return end
        i += 1
        calcLine(endIdx+1, i)
      end
    else
      return
    end
  end

  text:GetPropertyChangedSignal("Text"):Connect(function()
    local t = text.Text
    local lh = text.TextSize * text.LineHeight
    local tbp = Instance.new("GetTextBoundsParams")
    tbp.Size = text.TextSize
    tbp.Text = t
    tbp.Font = text.FontFace
    local tbs = s:GetTextBoundsAsync(tbp)
    calcLine(0,0)
    
    rect.Position = UDim2.fromOffset(
      tbs.X * curLineSize,
      lh * curLine
    )
  end)
  
  
  -- task.wait(15)
  -- menu:Destroy()
end

return autoc