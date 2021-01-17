local nest = {}

local OUTPUTS = 4
local GATE_ACTION = "{to(5,0),to(0,0.05)}"

local selected_output = 1
local output_modes = {"clock div", "lfo"}
local selected_output_modes = {1, 1, 1, 1}
local selected_divs = {1, 1, 1, 1}
local clock_ids = {}

function nest.init()
  init_crow()
  init_clock()
end

function nest.redraw()
  screen.clear()
  local options = {"out 1", "out 2", "out 3", "out 4"}
  for i = 1, #options do
    screen.level(selected_output == i and 15 or 3)
    
    local y = 12 + 10 * i
    
    screen.move(24, y)
    screen.text_center(output_modes[selected_output_modes[i]])
    
    screen.move(64, y)
    screen.text_center(options[i])
    
    screen.move(104, y)
    screen.text_center(selected_divs[i])
  end
  screen.update()
end

function nest.key(n, z)
  if n == 2 and z == 1 then
    selected_output = selected_output % 4 + 1
  end
  redraw()
end

function nest.enc(n, d)
  if n == 2 then
    selected_output_modes[selected_output] = math.min(#output_modes, (math.max(selected_output_modes[selected_output] + d, 1)))
  elseif n == 3 then
    selected_divs[selected_output] = math.min(32, (math.max(selected_divs[selected_output] + d, 1)))
  end
  update_crow_action()
  clock.cancel(clock_ids[selected_output])
  clock_ids[selected_output] = clock.run(run_clock, selected_output)
  redraw()
end

function update_crow_action()
  if selected_output_modes[selected_output] == 1 then
    crow.output[selected_output].action = GATE_ACTION
  else
    crow.output[selected_output].action = lfo_action()
  end
end

function lfo_action()
  local time = 60 / (clock.get_tempo() * selected_divs[selected_output])
  return "{to(5, " .. time / 2 .. "), to(-5, " .. time / 2 .. ")}"
end

function init_crow() 
  for i = 1, OUTPUTS do
    crow.output[i].action = GATE_ACTION
  end
end

function init_clock()
  for i = 1, OUTPUTS do
    clock_ids[i] = clock.run(run_clock, i)
  end
end

function run_clock(output)
  while true do
    clock.sync(selected_divs[output])
    crow.output[output].execute()
  end
end

return nest