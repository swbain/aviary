-- nest
-- @swbain
--
-- utilities for norns + crow
-- each crow output can be either a clock division/multiplication or a lfo
-- lfos can be free or clock synced

function init()
  screen.level(15)
end

function redraw()
  screen.move(10, 40)
  screen.text("hello world")
  screen.update()
end
