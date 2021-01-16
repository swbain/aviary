-- nest
-- @pavlovsfrog
--
-- utilities for norns + crow
-- each crow output can be either a clock division/multiplication or a lfo
-- lfos can be free or clock synced

selected_output = 1

output_modes = {"lfo", "clock div"}

selected_output_modes = {1, 1, 1, 1}

function redraw()
  screen.clear()
  local options = {"out 1", "out 2", "out 3", "out 4"}
  for i = 1,#options do
    screen.level(selected_output == i and 15 or 3)
    
    local y = 12 + 10 * i
    
    screen.move (28 ,y)
    screen.text_center(output_modes[selected_output_modes[i]])
    
    screen.move(64, y)
    screen.text_center(options[i])
  end
  screen.update()
end

function key(n, z)
  if n == 2 and z == 1 then
    selected_output = selected_output % 4 + 1
    redraw()
  end
end

function enc(n, d)
  if n == 2 then
    selected_output_modes[selected_output] = math.min(2, (math.max(selected_output_modes[selected_output] + d, 1)))
    redraw()
  end
end