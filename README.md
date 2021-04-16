# aviary

[![GPLv3 License](https://img.shields.io/github/license/swbain/aviary)](https://opensource.org/licenses/)

utility library for monome [norns](https://monome.org/docs/norns/) + [crow](https://monome.org/docs/crow/). a miniature pamela's new workout?

utilize crow's four cv outputs for clock or modulation. each output can either send out a clock division or an lfo. `aviary.init()` initializes the library and adds items to the parameters menu for crow control. optionally, library consumers can add a simple ui by utilizing `aviary.redraw()`, `aviary.key(n, z)`, and `aviary.enc(n, d)` where appropriate. this should be a relatively easy addition to scripts utilizing a page based UI, but is totally optional -- all functionality can be accessed inside of the parameters menu. controls for the ui are listed below.

* key 2: select crow output
* page 1
    - enc 2: select output type
    - enc 3: select clock division
* page 2, lfo on selected output
    - enc 2: select lfo param (lfo level up to +-5V, lfo shape)
    - enc 3: set voltage

example of how to add to an existing norns project at the [aviary-demo](https://github.com/swbain/aviary-demo) repo
