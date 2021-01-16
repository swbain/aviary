-- nest
-- @swbain
--
-- utilities for norns + crow
-- each crow output can be either a clock division/multiplication or a lfo
-- lfos can be free or clock synced

selected_output = 1

function redraw()
  local options = {"out 1","out 2","out 3","out 4"}
  for i = 1,4 do
    screen.level(selected_output == i and 15 or 3)
    screen.move(64,12 + (10*i))
    screen.text_center(options[i])
  end
  screen.update()
end

function key(n,z)
  if n == 2 and z == 1 then
    selected_output = (selected_output % 4) + 1
    redraw()
  end
end