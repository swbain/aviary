local aviary = {}

local formatters = require('formatters')

local OUTPUTS = 4
local PAGES = 2
local GATE_ACTION = "{to(5,0),to(0,0.05)}"
local CLOCK_DIV = "clock div"
local CLOCK_MULT = "clock mult"
local LFO = "lfo"
local STATIC = "static v"
local LFO_LEVEL = "lfo level"
local LFO_SHAPE = "lfo shape"
local OUTPUT_MODES = {CLOCK_DIV, CLOCK_MULT, LFO, STATIC}
local LFO_PARAMS = {LFO_LEVEL, LFO_SHAPE}
local LFO_SHAPES = {"linear", "sine", "logarithmic", "exponential"}

local selected_output = 1
local clock_ids = {}
local selected_lfo_params = {1, 1, 1, 1}
local selected_page = 1

function aviary.init()
  if (crow.connected()) then
    init_params()
    init_crow()
    init_clock()
  end
end

function init_params()
  for i = 1, 4 do
    params:add_group("crow out " .. i, 5)
    params:add_option("type_" .. i, "type", OUTPUT_MODES)
    params:set_action("type_" .. i, function () refresh_crow(i) end)
    params:add_number("rate_" .. i, "rate", 1, 32, 1)
    params:set_action("rate_" .. i, function () refresh_crow(i) end)
    params:add_control("lfo_level_" ..i, "lfo level", controlspec.new(0.01, 5, "lin", 0.01, 5, "V+-", 0.01 / 10))
    params:set_action("lfo_level_" .. i, function () refresh_crow(i) end)
    params:add_option("lfo_shape_" .. i, "lfo shape", LFO_SHAPES)
    params:set_action("lfo_shape_" .. i, function () refresh_crow(i) end)
    params:add_control("static_v_" .. i, "static volts", controlspec.new(-5, 10, "lin", 0.01, 5, "V", 0.01 / 15))
    params:set_action("static_v_" .. i, function () refresh_crow(i) end)
  end
end

function aviary.redraw()
  if (crow.connected()) then
    redraw_connected()
  else
    redraw_disconnected()
  end
  screen.update()
end

function redraw_connected()
  local options = {"out 1", "out 2", "out 3", "out 4"}
  for i = 1, #options do
    screen.level(selected_output == i and 15 or 3)

    local y = 12 + 10 * i

    screen.move(24, y)
    if selected_page == 1 then
      screen.text_center(OUTPUT_MODES[params:get("type_" .. i)])
    elseif OUTPUT_MODES[params:get("type_" .. i)] == LFO then
      screen.text_center(LFO_PARAMS[selected_lfo_params[i]])
    else
      screen.text_center("-")
    end

    screen.move(64, y)
    screen.text_center(options[i])

    screen.move(104, y)
    if selected_page == 1 then
      if OUTPUT_MODES[params:get("type_" ..i)] == STATIC then
        screen.text_center(params:get("static_v_" .. i) .. "V")
      else
        screen.text_center(params:get("rate_" .. i))
      end
    elseif OUTPUT_MODES[params:get("type_" .. i)] == LFO then
      if LFO_PARAMS[selected_lfo_params[i]] == LFO_LEVEL then
        screen.text_center("+-" .. params:get("lfo_level_" .. i) .. "V")
      else
        screen.text_center(LFO_SHAPES[params:get("lfo_shape_" .. i)])
      end
    else
      screen.text_center("-")
    end
  end
end

function redraw_disconnected()
  screen.move(64, 32)
  screen.text_center("no crow connected")
end

function aviary.key(n, z)
  if n == 2 and z == 1 then
    selected_output = selected_output % OUTPUTS + 1
  elseif n == 3 and z == 1 then
    selected_page = selected_page % PAGES + 1
  end
  redraw()
end

function aviary.enc(n, d)
  local restart_crow_action = true
  if n == 2 then
    if selected_page == 1 then
      params:delta("type_" .. selected_output, d)
    else
      if OUTPUT_MODES[params:get("type_" .. selected_output)] == LFO then
        selected_lfo_params[selected_output] = math.min(#LFO_PARAMS, (math.max(selected_lfo_params[selected_output] + d, 1)))
      end
    end
  elseif n == 3 then
    if selected_page == 1 then
      if OUTPUT_MODES[params:get("type_" .. selected_output)] == STATIC then
        params:delta("static_v_" .. selected_output, d)
      else
        params:delta("rate_" .. selected_output, d)
      end
    elseif OUTPUT_MODES[params:get("type_" .. selected_output)] == LFO then
      if LFO_PARAMS[selected_lfo_params[selected_output]] == LFO_LEVEL then
        params:delta("lfo_level_" .. selected_output, d)
      else
        params:delta("lfo_shape_" .. selected_output, d)
      end
    end
  end

  redraw()
end

function refresh_crow(output)
  update_crow_action(output)
  clock.cancel(clock_ids[output])
  clock_ids[output] = clock.run(run_clock, output)
end

function update_crow_action(output)
  if params:get("type_" .. output) == 1 or params:get("type_" .. output) == 2 then
    crow.output[output].action = GATE_ACTION
  elseif params:get("type_" .. output) == 3 then
    crow.output[output].action = lfo_action(output)
  else
    crow.output[output].volts = params:get("static_v_" .. output)
  end
end

function lfo_action(output)
  local time = 60 / (clock.get_tempo() / params:get("rate_" .. output))
  return "{to(" .. params:get("lfo_level_" .. output) .. ", " .. time / 2 .. ", " .. params:get("lfo_shape_" .. output) .."), to(" .. -params:get("lfo_level_" .. output) .. ", " .. time / 2 .. ", " .. params:get("lfo_shape_" .. output) ..")}"
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
    if params:get("type_" .. output) == 2 then
      clock.sync(1 / params:get("rate_" .. output))
    else
      clock.sync(params:get("rate_" .. output))
    end
    crow.output[output].execute()
  end
end

return aviary
