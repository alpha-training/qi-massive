/ Normalisation functions

\d .massive

norm.A:{[x]
  (12h$1970.01.01D+1000000*7h$x`s; / Start Time 
                `$x`sym; / Sym
                9h$x`o;  / Open
                9h$x`h;  / High
                9h$x`l; / Low
                9h$x`c; / Close
                9h$x`vw; / VWAP
                7h$x`v)  / Volume
  }