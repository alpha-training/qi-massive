/ 1 import libraries
.qi.import`ipc
conf:.qi.parseconf`:defaults.conf; /placeholder

/--- 2. Connection Setup --- /Maybe all sestting??within file
$[conf.mode~"live";l:"socket";l:"delayed"]
url:":wss://",l,".massive.com:443";
header:"GET /stocks HTTP/1.1\r\nHost: ",l".massive.com\r\n\r\n"; // delayed or live stream shoul be optional
API_KEY:"rSQLz8C1muscWBydEkoAWpW4RH9CW_wq"; //WILL NEED TO BE EDITABLE potentially within funciton or in conf??
DATA:conf.data
TICKERS:"AM.*";
TICKER:conf.tickers

/ massive.run function
.massive.start:{[tp_n]
    .m.tp::tp_n;
    .z.ws:{[msg;]
        packets:.j.k msg;
        / Massive sends a list of dicts
        {
            / If it's a data packet (AM)
            if[x[`ev]~"AM";
                neg[.ipc.conn y](`.u.upd;`$x`ev;(
                12h$1970.01.01D+1000000*7h$x`s; / Start Time (s) 
                `$x`sym;                        / Symbolcd ..
                9h$x`o;                           / Open
                9h$x`h;                           / High
                9h$x`l;                           / Low
                9h$x`c;                           / Close
                9h$x`vw;                          / VWAP (vw)
                7h$x`v                            / Volume (v)
            ));
            -1 "qi.ingest: Captured ",x[`sym], " at ",string[x`c];
            ];
            / If it's a status packet, handle the handshake/auth
            if[x[`ev]~"status";
                if[x[`status]~"connected";neg[.z.w] .j.j`action`params!("auth";API_KEY)];
                if[x[`status]~"auth_success";neg[.z.w] .j.j`action`params!("subscribe";TICKERS)];
                -1 "qi.status: ",x`message;
            ];
        }[;.m.tp]each packets;
    };
    /launch pipe
    w:hsym[`$url]header;
    -1 "qi-massive v0.1: Connection sequence initiated...";
    }



