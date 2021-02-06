local aviary = {}

local formatters = require('formatters')

local OUTPUTS = 4
local PAGES = 2
local GATE_ACTION = "{to(5,0),to(0,0.05)}"
local CLOCK_DIV = "clock div"
local CLOCK_MULT = "clock mult"
local LFO = "lfo"
local MIN_VOLTAGE = "min voltage"
local MAX_VOLTAGE = "max voltage"
local OUTPUT_MODES = {CLOCK_DIV, CLOCK_MULT, LFO}
local LFO_PARAMS = {MIN_VOLTAGE, MAX_VOLTAGE}

local selected_output = 1
local clock_ids = {}
local selected_lfo_params = {1, 1, 1, 1}
local selected_page = 1

function aviary.init()
  init_params()
  init_crow()
  init_clock()
end

function init_params()
  for i = 1, 4 do
    params:add_group("crow out " .. i, 4)
    params:add_option("type_" .. i, "type", OUTPUT_MODES)
    params:set_action("type_" .. i, function () refresh_crow(i) end)
    params:add_number("rate_" .. i, "rate", 1, 32, 1)
    params:set_action("rate_" .. i, function () refresh_crow(i) end)
    params:add_control("min_volts_" .. i, "lfo min voltage", controlspec.new(-5.00, 10.00, "lin", 0.01, -5.00, "V", 0.01 / 15))
    params:set_action("min_volts_" .. i, function () refresh_crow(i) end)
    params:add_control("max_volts_" .. i, "lfo max voltage", controlspec.new(-5.00, 10.00, "lin", 0.01, 5.00, "V", 0.01 / 15))
    params:set_action("max_volts_" .. i, function () refresh_crow(i) end)
  end
end

function aviary.redraw()
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
      screen.text_center(params:get("rate_" .. i))
    elseif OUTPUT_MODES[params:get("type_" .. i)] == LFO then
      if LFO_PARAMS[selected_lfo_params[i]] == MIN_VOLTAGE then
        screen.text_center(params:get("min_volts_" .. i) .. "V")
      else
        screen.text_center(params:get("max_volts_" .. i) .. "V")
      end
    else
      screen.text_center("-")
    end
  end
  screen.update()
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
      params:delta("rate_" .. selected_output, d)
    elseif OUTPUT_MODES[params:get("type_" .. selected_output)] == LFO then
      if LFO_PARAMS[selected_lfo_params[selected_output]] == MIN_VOLTAGE then
        params:delta("min_volts_" .. selected_output, d)
      else
        params:delta("max_volts_" .. selected_output, d)
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
  else
    crow.output[output].action = lfo_action(output)
  end
end

function lfo_action(output)
  local time = 60 / (clock.get_tempo() / params:get("rate_" .. output))
  return "{to(" .. params:get("max_volts_" .. output) .. ", " .. time / 2 .. "), to(" .. params:get("min_volts_" .. output) .. ", " .. time / 2 .. ")}"
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
