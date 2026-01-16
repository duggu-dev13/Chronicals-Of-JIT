local ShopMenu = {}

function ShopMenu:new(game)
    local obj = {
        gameState = game,
        isOpen = false,
        cart = {},
        items = {
            { name = "Burger", price = 80, energy = 30 },
            { name = "Pizza", price = 120, energy = 50 },
            { name = "Coffee", price = 40, energy = 15 },
            { name = "Water", price = 20, energy = 5 }
        },
        showConfirmation = false,
        totalCost = 0
    }
    setmetatable(obj, self)
    self.__index = self
    
    -- Preload Fonts
    obj.fonts = {
        header = love.graphics.newFont(24),
        item = love.graphics.newFont(16),
        total = love.graphics.newFont(20)
    }
    
    return obj
end

function ShopMenu:open()
    self.isOpen = true
    self.cart = {}
    self.totalCost = 0
    self.showConfirmation = false
end

function ShopMenu:close()
    self.isOpen = false
    self.showConfirmation = false
end

function ShopMenu:addToCart(item)
    table.insert(self.cart, item)
    self:calculateTotal()
end

function ShopMenu:removeFromCart(index)
    if index >= 1 and index <= #self.cart then
        table.remove(self.cart, index)
        self:calculateTotal()
    end
end

function ShopMenu:calculateTotal()
    self.totalCost = 0
    for _, item in ipairs(self.cart) do
        self.totalCost = self.totalCost + item.price
    end
end

function ShopMenu:checkout()
    if #self.cart == 0 then return end
    self.showConfirmation = true
end

function ShopMenu:confirmPurchase()
    local career = self.gameState.careerManager
    if not career then return end

    if career.money >= self.totalCost then
        if career:spendMoney(self.totalCost, "Canteen Food") then
            -- Apply Effects (Energy Gain)
            local totalEnergy = 0
            for _, item in ipairs(self.cart) do
                totalEnergy = totalEnergy + item.energy
            end
            career:modifyEnergy(totalEnergy)
            self.gameState.hud:addNotification("Yummy! Energy +" .. totalEnergy)
            self:close()
        else
            self.gameState.hud:addNotification("Error processing payment.")
        end
    else
        self.gameState.hud:addNotification("Not enough money!")
        self.showConfirmation = false -- Hide popup to let them remove items
    end
end

function ShopMenu:draw()
    if not self.isOpen then return end
    
    local w, h = love.graphics.getDimensions()
    
    -- Dim Background
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 0, 0, w, h)
    
    -- Main Window
    local panelW, panelH = 600, 400
    local px, py = (w - panelW)/2, (h - panelH)/2
    
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("fill", px, py, panelW, panelH, 10, 10)
    
    -- Header
    love.graphics.setColor(0.2, 0.2, 0.2, 1)
    love.graphics.setFont(self.fonts.header)
    love.graphics.printf("Canteen Counter", px, py + 20, panelW, "center")
    
    -- Item List (Left Side)
    love.graphics.setFont(self.fonts.item)
    local startY = py + 80
    for i, item in ipairs(self.items) do
         local y = startY + (i-1)*50
         
         love.graphics.setColor(0.9, 0.9, 0.9, 1)
         love.graphics.rectangle("fill", px + 40, y, 240, 40, 5, 5)
         
         love.graphics.setColor(0, 0, 0, 1)
         love.graphics.print(item.name .. " (Rs." .. item.price .. ")", px + 50, y + 10)
         
         -- Add Button
         love.graphics.setColor(0.2, 0.6, 0.2, 1)
         love.graphics.rectangle("fill", px + 240, y + 5, 30, 30, 5, 5)
         love.graphics.setColor(1, 1, 1, 1)
         love.graphics.print("+", px + 250, y + 8)
         
         -- Mouse Detection for Add Button
         -- We do logic in mousepressed, but coordinates here for reference:
         -- X: px+240, Y: y+5, W:30, H:30
    end
    
    -- Cart (Right Side)
    love.graphics.setColor(0.95, 0.95, 0.95, 1)
    love.graphics.rectangle("fill", px + 320, py + 80, 240, 200, 5, 5)
    
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.print("Tray:", px + 330, py + 85)
    
    local cartY = py + 110
    if #self.cart > 0 then
        for i, item in ipairs(self.cart) do
            if i > 8 then break end -- Limit display
            love.graphics.setColor(0, 0, 0, 1)
            love.graphics.print("- " .. item.name, px + 330, cartY)
            
            -- Remove Button (X)
            love.graphics.setColor(0.8, 0.2, 0.2, 1)
            love.graphics.rectangle("fill", px + 530, cartY, 20, 20, 3, 3)
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.print("x", px + 536, cartY)
            
            cartY = cartY + 25 -- Increased spacing
        end
    else
        love.graphics.setColor(0.5, 0.5, 0.5, 1)
        love.graphics.print("Empty", px + 330, cartY)
    end
    
    -- Total & Checkout
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.setFont(self.fonts.total)
    love.graphics.print("Total: Rs." .. self.totalCost, px + 320, py + 300)
    
    -- Buy Button
    love.graphics.setColor(0.2, 0.5, 0.8, 1)
    love.graphics.rectangle("fill", px + 320, py + 330, 240, 50, 5, 5)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf("Purchase", px + 320, py + 345, 240, "center")
    
    -- Close Button
    love.graphics.setColor(0.8, 0.2, 0.2, 1)
    love.graphics.rectangle("fill", px + panelW - 40, py + 10, 30, 30, 5, 5)
    love.graphics.setFont(self.fonts.item)
    love.graphics.printf("X", px + panelW - 40, py + 15, 30, "center")
    
    -- Confirmation Popup
    if self.showConfirmation then
        love.graphics.setColor(0, 0, 0, 0.8)
        love.graphics.rectangle("fill", 0, 0, w, h)
        
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.rectangle("fill", px + 100, py + 100, 400, 200, 10, 10)
        
        love.graphics.setColor(0, 0, 0, 1)
        love.graphics.printf("Confirm Purchase?", px + 100, py + 140, 400, "center")
        love.graphics.printf("Total: Rs." .. self.totalCost, px + 100, py + 170, 400, "center")
        
        -- Yes
        love.graphics.setColor(0.2, 0.6, 0.2, 1)
        love.graphics.rectangle("fill", px + 150, py + 220, 100, 40, 5, 5)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf("Yes", px + 150, py + 230, 100, "center")
        
        -- No
        love.graphics.setColor(0.8, 0.2, 0.2, 1)
        love.graphics.rectangle("fill", px + 350, py + 220, 100, 40, 5, 5)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf("No", px + 350, py + 230, 100, "center")
    end
end

function ShopMenu:mousepressed(x, y, button)
    if not self.isOpen then return false end
    
    local w, h = love.graphics.getDimensions()
    local panelW, panelH = 600, 400
    local px, py = (w - panelW)/2, (h - panelH)/2
    
    -- Popup Interaction
    if self.showConfirmation then
        -- Yes: px + 150, py + 220, 100x40
        if x >= px+150 and x <= px+250 and y >= py+220 and y <= py+260 then
            self:confirmPurchase()
            return true
        end
        
        -- No: px + 350, py + 220, 100x40
         if x >= px+350 and x <= px+450 and y >= py+220 and y <= py+260 then
            self.showConfirmation = false
            return true
        end
        return true -- Block other input
    end
    
    -- Close Button
    if x >= px + panelW - 40 and x <= px + panelW - 10 and y >= py + 10 and y <= py + 40 then
        self:close()
        return true
    end
    
    -- Item Add Buttons
    local startY = py + 80
    for i, item in ipairs(self.items) do
         local iy = startY + (i-1)*50
         -- Button: px + 240, iy + 5, 30x30
         if x >= px + 240 and x <= px + 270 and y >= iy + 5 and y <= iy + 35 then
             self:addToCart(item)
             return true
         end
    end
    
    -- Buy Button: px + 320, py + 330, 240x50
    if x >= px + 320 and x <= px + 560 and y >= py + 330 and y <= py + 380 then
        self:checkout()
        return true
    end
    
    -- Cart Remove Buttons
    local cartY = py + 110
    for i, item in ipairs(self.cart) do
        if i > 8 then break end
        -- Button: px + 530, cartY, 20x20
        if x >= px + 530 and x <= px + 550 and y >= cartY and y <= cartY + 20 then
            self:removeFromCart(i)
            return true
        end
        cartY = cartY + 25
    end
    
    return true -- Consume click if inside overlay? Or allow click-out to close?
    -- For now, modal behavior.
end

return ShopMenu
