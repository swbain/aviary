# nest

utility library for monome [norns](https://monome.org/docs/norns/) + [crow](https://monome.org/docs/crow/).

utilize crow's four cv outputs for clock or modulation. each output can either send out a clock division or an lfo.
* key 2: select crow output
* page 1
    - enc 2: select output type
    - enc 3: select clock division
* page 2, lfo on selected output
    - enc 2: select lfo param (min voltage, max voltage -5V min 10V max)
    - enc 3: set voltage

example of how to add to an existing norns project at the [nest-demo](https://github.com/swbain/nest-demo) repo
