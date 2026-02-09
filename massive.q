.qi.import`ipc;
.qi.import`log;
.qi.frompkg[`massive;`norm]

\d .massive

H:0Ni

/2. Connection Setup
$[.conf.mode~"live";l:"socket";l:"delayed"];
url:`$":wss://",l,".massive.com:443";
header:"GET /stocks HTTP/1.1\r\nHost: ",l,".massive.com\r\n\r\n"; // delayed or live stream should be optional
API_KEY:.conf.apikey; //WILL NEED TO BE EDITABLE potentially within funciton or in conf??
TICKERS:$[.conf.tickers~"*";.conf.data,".*";","sv (.conf.data,"."),/:","vs .conf.tickers]

.z.ws:{[msg]
    / Massive sends a list of dicts
    {[x]
        / If it's a data packet, normalise and send to tp
        if[(ev:x`ev)in`AM`AS;
            :neg[H](`.u.upd;ev;norm.A x)];
        / If it's a status packet, handle the handshake/auth
        if[ev=`status;
            if[(status:`$x`status)=`connected;neg[.z.w] .j.j`action`params!("auth";API_KEY)];
            if[status=`auth_success;neg[.z.w] .j.j`action`params!("subscribe";TICKERS)]];
        }each .j.k msg;
    };

pc:{[h] if[h=H;.log.fatal"Lost connection to target. Exiting"]}

start:{[target]
    /launch websocket connection
    if[null H::.ipc.conn .qi.tosym target;
        if[null H::first c:.ipc.tryconnect target;
            .log.fatal"Could not connect to ",.qi.tostr[target]," '",last[c],"'. Exiting"]];
    w:url header;
    .log.info "qi-massive: Connection sequence initiated...";
    .log.info $[first w>0;"Connection Success with handle: ",first w 0;"Connection Failed"];
    }

.event.addhandler[`.z.pc;`.massive.pc]

/ 
start 1234