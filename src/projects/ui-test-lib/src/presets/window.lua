local CR = getModule("CreateRecursive")
local window = {}

function window:Create(initialInstance: Instance?, sizeX: number? sizeY: number?)
  local menu = CR.Create({
    {
      ClassName = "ScreenGui",
      Childs = {
        {
          ClassName = "Frame",
          BackgroundColor3 = Color3.fromRGB(5,5,5),
          BorderSizePixel = 0,
          Size = UDim2.new(0,sizeX or 350,0,20),
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
              Size = UDim2.new(1,0,0,sizeY or 250),
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
                }
              }
            }
          }
        }
      }
    }
  }, nil, initialInstance or game:GetService("CoreGui"))

  return menu
end

return window