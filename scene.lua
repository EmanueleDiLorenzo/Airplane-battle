
function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)	-- function for collision
  return x1 < x2+w2 and
  x2 < x1+w1 and
  y1 < y2+h2 and
  y2 < y1+h1

end



debug = true
Scene = {}
require("gamestate")
function Scene:new(o)
  newObj = o or {}

  self.__index = self
  return setmetatable(newObj, self)
end


Menu = Scene:new()
function Menu:load()

end
function Menu:draw()

  love.graphics.print("Press 'P' to play" , love.graphics:getWidth()/1.8-100, love.graphics:getHeight()/2-20)
  love.graphics.print("Press 'Q' to quit" , love.graphics:getWidth()/1.8-100, love.graphics:getHeight()/2-3)

end

function Menu:update()
  if love.keyboard.isDown('escape') then		--for all
    love.event.push('quit')

  end
  if love.keyboard.isDown('p') then
    Gamestate.current_scene = Game:new()
    Gamestate.current_scene:load()
  end
  if love.keyboard.isDown('q') then
    love.event.push('quit')
  end
end

Game = Scene:new({
score = 0,
  life=1,
  enemies = {},
  powers = {},
  bullets = {},
  canShoot = true,
  canShootTimerMax = 0.6,
  canShootTimer = 0,
  lvl = 0,
  bulletImg = nil,
  enemyImg = nil,
  createEnemyTimerMax = 1,
  createPowerTimerMax= 25,
  isAlive = true,
  enemySpeedIndicator = 200,
  createEnemyTimer = 0,
  createPowerTimer =0,
  randomNumber = 0,
  attack = 0

})
function Game:init()
  -- GAME
  canShootTimer = canShootTimerMax
  createEnemyTimer = createEnemyTimerMax
  createPowerTimer = createPowerTimerMax

end

function Game:load(arg)
  table.remove(self.enemies)
  table.remove(self.powers)
  table.remove(self.bullets)
  sound = love.audio.newSource("assets/Iattaque.mp3", "static")
  music:stop()
  music:setLooping(true)
  music:play()

  Gamestate.score = self.score
  self.player = {x =200, y = 610, speed = 400, img=nil}
  self.bulletImg = love.graphics.newImage('assets/bullets.png')
  self.player.img = love.graphics.newImage('assets/plane2.png')
  self.enemyImg = love.graphics.newImage('assets/enemy.png')
  self.powerImg = love.graphics.newImage('assets/power.png')

end
function Game:draw(dt)
  for i = 0, love.graphics.getWidth() / background:getWidth() do
      for j = 0, love.graphics.getHeight() / background:getHeight() do
           love.graphics.draw(background, i * background:getWidth(), j * background:getHeight())
       end
  end
  love.graphics.draw(self.player.img, self.player.x,self.player.y)
  love.graphics.print("SCORE:",love.graphics:getWidth()/2-230, love.graphics:getHeight()/2-370)
  love.graphics.print(Gamestate.score , love.graphics:getWidth()/2-150, love.graphics:getHeight()/2-370)
  love.graphics.print("LIFES:",love.graphics:getWidth()/2-230, love.graphics:getHeight()/2-350)
  love.graphics.print(self.life , love.graphics:getWidth()/2-150, love.graphics:getHeight()/2-350)

  if not self.isAlive then
    table.remove(self.enemies)
    table.remove(self.powers)
    self.enemySpeedIndicator=200
  end

  for i, bullet in ipairs(self.bullets) do
    love.graphics.draw(bullet.img, bullet.x, bullet.y)
  end
  for i, enemy in ipairs(self.enemies) do
    love.graphics.draw(enemy.img, enemy.x, enemy.y)
  end
  for i, power in ipairs(self.powers) do
    love.graphics.draw(power.img, power.x, power.y)
  end
end

function Game:update(dt)

  if love.keyboard.isDown('escape') then --implementation esc button
    love.event.push('quit')
  end
  if love.keyboard.isDown('left','a') and self.player.x>0 then --implementation player's movement
    self.player.x = self.player.x - (self.player.speed*dt)
  elseif love.keyboard.isDown('right', 'd') and self.player.x<370 then
    self.player.x = self.player.x + (self.player.speed*dt)
  end

  self.canShootTimer =self.canShootTimer - (1 * dt)	-- bullets timer
  if self.canShootTimer < 0 then
     self.canShoot = true
  end

  if love.keyboard.isDown(' ', 'rctrl', 'lctrl', 'ctrl') and self.canShoot and self.isAlive	then    --creation bullets

    sound:rewind()
    sound:play()

    self.newBullet = { x = self.player.x + (self.player.img:getWidth()/2 -6), y = self.player.y, img = self.bulletImg }
    table.insert(self.bullets, self.newBullet)
    self.canShoot = false
    self.canShootTimer = self.canShootTimerMax
  end
  for i, bullet in ipairs(self.bullets) do	 -- update the positions of bullets
    bullet.y = bullet.y - (250 * dt)
    if bullet.y < 0 then			 -- remove bullets when they pass off the screen
      table.remove(self.bullets, i)
    end
  end
  if self.isAlive then
    -- Time out enemy creation
    self.createEnemyTimer = self.createEnemyTimer - (1 * dt)
    if self.createEnemyTimer < 0 then
      self.createEnemyTimer = self.createEnemyTimerMax

      -- Create an enemy

      self.randomNumber = math.random(10, love.graphics.getWidth() - 10)
      if self.randomNumber> 370 then
        self.randomNumber = 370
      end
      self.newEnemy = { x = self.randomNumber, y = -10, img = self.enemyImg }
      table.insert(self.enemies, self.newEnemy)


    end
    -- update the positions of enemies
    for i, enemy in ipairs(self.enemies) do
      enemy.y = enemy.y + (self.enemySpeedIndicator * dt)--200

      if enemy.y > 850 then -- remove enemies when they pass off the screen
        table.remove(self.enemies, i)
      end

  end
  end
  if self.isAlive then
    -- Time out power creation
    self.createPowerTimer = self.createPowerTimer - (1 * dt)
    if self.createPowerTimer < 0 then
      self.createPowerTimer = self.createPowerTimerMax

      -- Create a power

      self.randomNumber = math.random(10, love.graphics.getWidth() - 10)
      if self.randomNumber> 370 then
      self.randomNumber = 370
      end
      self.newPower = { x = self.randomNumber, y = -10, img = self.powerImg }
      table.insert(self.powers, self.newPower)



    end
    -- update the positions of Power
    for i, power in ipairs(self.powers) do
      power.y = power.y + (200 * dt)


      if power.y > 850 then -- remove power when they pass off the screen
        table.remove(self.powers, i)
      end
    end
  end
  for i, enemy in ipairs(self.enemies) do    --score and lvl increment
    for j, bullet in ipairs(self.bullets)do
      if CheckCollision(enemy.x, enemy.y, enemy.img:getWidth(), enemy.img:getHeight(), bullet.x, bullet.y, bullet.img:getWidth(), bullet.img:getHeight()) then
        table.remove(self.bullets, j)
        table.remove(self.enemies, i)
        Gamestate.score = Gamestate.score + 1
        self.attack = self.attack+1
        if self.attack == 20 then
          self.canShootTimerMax = self.canShootTimerMax - self.canShootTimerMax/20
        end
        self.lvl = self.lvl +1


      end
    end
    if CheckCollision(enemy.x, enemy.y, enemy.img:getWidth(), enemy.img:getHeight(), self.player.x, self.player.y, self.player.img:getWidth(), self.player.img:getHeight())
    and self.isAlive then  -- collision player\enemies
      table.remove(self.enemies, i)
      self.life = self.life -1
    end
  end
  for k, power in ipairs(self.powers)do --collision player\power
    if CheckCollision(power.x, power.y, power.img:getWidth(), power.img:getHeight(), self.player.x, self.player.y, self.player.img:getWidth(), self.player.img:getHeight())
    and self.isAlive then
      table.remove(self.powers, k)
      self.life = self.life +1
    end
  end
  if self.lvl>9 then -- increment difficulty
    self.enemySpeedIndicator= self.enemySpeedIndicator+(self.enemySpeedIndicator/4)
    self.lvl=0
  end

  if self.life<1 then -- player die
    for i, bullet in ipairs(self.bullets) do
      table.remove(self.bullets, i)

    end

    for i, enemy in ipairs(self.enemies) do
      table.remove(self.enemies, i)
    end

    for i, power in ipairs(self.powers) do
      table.remove(self.powers, i)
    end


    Gamestate.current_scene = Gameover:new()

  end

end

Gameover = Scene:new()

function Gameover:load(arg)

end

function Gameover:update(dt)

  if love.keyboard.isDown('escape') then		--for all
    love.event.push('quit')

  end
  if love.keyboard.isDown('r') then

    Gamestate.current_scene = Game:new()
    Gamestate.current_scene:load()
  end
  if love.keyboard.isDown('m') then

    Gamestate.current_scene = Menu:new()
    Gamestate.current_scene:load()
  end
end
function Gameover:draw(dt)
  love.graphics.print("GAME OVER", love.graphics:getWidth()/2-100 , love.graphics:getHeight()/2-10)
  love.graphics.print("Press 'R' to restart" , love.graphics:getWidth()/2-100, love.graphics:getHeight()/2-100)
  love.graphics.print("Press 'M' to return menu" , love.graphics:getWidth()/2-100, love.graphics:getHeight()/2+50)
  love.graphics.print("SCORE:",love.graphics:getWidth()/2-100, love.graphics:getHeight()/2-50)
  love.graphics.print(Gamestate.score, love.graphics:getWidth()/2-50, love.graphics:getHeight()/2-50)
end
