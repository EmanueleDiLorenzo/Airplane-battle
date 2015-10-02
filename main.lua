debug = true

require("scene")
function love.load(arg)
  background = love.graphics.newImage("assets/stars.gif")
  music = love.audio.newSource("assets/Soundtrack.mp3")
  Gamestate.current_scene = Menu:new()
  Gamestate.current_scene:load(arg)

end

function love.update(dt)
  Gamestate.current_scene:update(dt)
end

function love.draw(dt)
  
  Gamestate.current_scene:draw(dt)
end
