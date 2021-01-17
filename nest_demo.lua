-- nest
-- @pavlovsfrog
--
-- utilities for norns + crow
-- use crow outputs for
-- clock div and lfos
-- 
-- btn 2: select crow output
-- enc 2: select output type
-- enc 3: select rate

nest = include 'lib/nest'

function init()
  nest.init()
end

function redraw()
  nest.redraw()
end

function key(n, z)
  nest.key(n, z)
end

function enc(n, d)
  nest.enc(n, d)
end