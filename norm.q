/ Normalisation functions

norm.A:norm.AM:{
  dbg;
  (12h$1970.01.01D+1000000*7h$x`s;  / end time of aggregate window
    `$x`sym;                         / sym 
    9h$x`o;                          / tick_open
    9h$x`c;                          / tick_close
    9h$x`h;                          / tick_high
    9h$x`l;                          / tick_low
    7h$x`v;                          / volume
    7h$x`av;                         / accumulated_volume
    9h$x`vw;                         / tick_vwap
    9h$x`a;                          / daily_vwap
    7h$x`z;
    .z.p;
    0Np)
 }