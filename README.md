# nest

utility library for monome [norns](https://monome.org/docs/norns/) + [crow](https://monome.org/docs/crow/).

utilize crow's four cv outputs for clock or modulation. each output can either send out a clock division or an lfo. `nest.init()` initializes the library and adds items to the parameters menu for crow control. optionally, library consumers can add a simple ui by utilizing `nest.redraw()`, `nest.key(n, z)`, and `nest.enc(n, d)` where appropriate. this should be a relatively easy addition to scripts utilizing a page based UI, but is totally optional -- all functionality can be accessed inside of the parameters menu. controls for the ui are listed below.

* key 2: select crow output
* page 1
    - enc 2: select output type
    - enc 3: select clock division
* page 2, lfo on selected output
    - enc 2: select lfo param (min voltage, max voltage -5V min 10V max)
    - enc 3: set voltage

example of how to add to an existing norns project at the [nest-demo](https://github.com/swbain/nest-demo) repo
