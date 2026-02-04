/ 1 import libraries
.qi.import`ipc

/--- 2. Connection Setup --- /Maybe all sestting??within file
url:":wss://delayed.massive.com:443";
header:"GET /stocks HTTP/1.1\r\nHost: delayed.massive.com\r\n\r\n";
API_KEY:"rSQLz8C1muscWBydEkoAWpW4RH9CW_wq"; //WILL NEED TO BE EDITABLE potentially within funciton or in conf??
TICKERS:"AM.*";

/ massive.run function
.massive.start:{[tpport]
    .z.ws:{[msg]
        packets:.j.k msg
        / Massive sends a list of dicts
        {
            / If it's a data packet (AM)
            if[x[`ev]~"AM";
                neg[.ipc.conn tpport](`.u.upd;`$x`ev;(
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
        }each packets;
    };
    /launch pipe
    w:hsym[`$url]header;
    -1 "qi-massive v0.1: Connection sequence initiated...";
    }



