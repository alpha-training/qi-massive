\e 1
/ 1. import libraries
.qi.import`ipc;
/.qi.frompkg[`massive;`norm]     / load norm.q

\d .massive

/2. Connection Setup
$[.conf.mode~"live";l:"socket";l:"delayed"];
url:":wss://",l,".massive.com:443";
header:"GET /stocks HTTP/1.1\r\nHost: ",l,".massive.com\r\n\r\n"; // delayed or live stream shoul be optional
API_KEY:.conf.apikey; //WILL NEED TO BE EDITABLE potentially within funciton or in conf??
TICKERS:$[.conf.tickers~"*";.conf.data,".*";","sv (.conf.data,"."),/:","vs .conf.tickers]

start:{[tp]
    .m.tp::tp;
    .z.ws:{[msg]
        packets:.j.k msg;
        / Massive sends a list of dicts
        {
            / If it's a data packet (AM)
            if[x[`ev]~"AM";
                neg[.ipc.conn y](`.u.upd;`$x`ev;(
                12h$1970.01.01D+1000000*7h$x`s; / Start Time 
                `$x`sym; / Sym
                9h$x`o;  / Open
                9h$x`h;  / High
                9h$x`l; / Low
                9h$x`c; / Close
                9h$x`vw; / VWAP
                7h$x`v  / Volume
            ));
            -1 "qi.ingest: Captured ",x[`sym]," at ",string[x`c];
            ];
            / If it's a status packet, handle the handshake/auth
            if[x[`ev]~"status";
                if[x[`status]~"connected";neg[.z.w] .j.j`action`params!("auth";API_KEY)];
                if[x[`status]~"auth_success";neg[.z.w] .j.j`action`params!("subscribe";TICKERS)];
                -1 "qi.status: ",x`message;
            ];
        }[;.m.tp]each packets;
    };
    /launch websocket connection
    w:hsym[`$url]header;
    -1 "qi-massive v0.1: Connection sequence initiated...";
    $[first w>0;-1 "AlphaKDB: Connection Success with . Handle: ",first string w 0;-1 "AlphaKDB: Connection Failed"];
    }

\d .