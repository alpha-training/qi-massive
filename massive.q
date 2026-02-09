.qi.import`ipc;
.qi.import`log;
.qi.frompkg[`massive;`norm]

\d .massive

H:0Ni
UN:.conf.MASSIVE_UNIVERSE
DATA:.conf.MASSIVE_DATA

l:$[.conf.MASSIVE_MODE~"live";"socket";"delayed"];
url:`$":wss://",l,".massive.com:443";
header:"GET /stocks HTTP/1.1\r\nHost: ",l,".massive.com\r\n\r\n"; // delayed or live stream should be optional
TICKERS:$["*"~UN;DATA,".*";","sv(DATA,"."),/:","vs UN]

.z.ws:{[msg]
    {[x]
        if[(ev:`$x`ev)in`AM`AS;
            :neg[H](`.u.upd;ev;norm.A x)];
        if[ev=`status;
            if[(status:`$x`status)=`connected;neg[.z.w] .j.j`action`params!("auth";.conf.MASSIVE_KEY)];
            if[status=`auth_success;neg[.z.w] .j.j`action`params!("subscribe";TICKERS)]];
        }each .j.k msg;
    };

pc:{[h] if[h=H;.log.fatal"Lost connection to target. Exiting"]}

start:{[target]
    if[null H::.ipc.conn .qi.tosym target;
        if[null H::first c:.ipc.tryconnect target;
            .log.fatal"Could not connect to ",.qi.tostr[target]," '",last[c],"'. Exiting"]];
    .log.info "Connection sequence initiated...";
    if[not h:first c:.qi.try[url;header;0Ni];
        .log.error err:c 2;
        if[err like"*Protocol*";
            if[.z.o in`l64`m64;
                .log.info"Try setting the env variable:\nexport SSL_VERIFY_SERVER=NO"]]];
    if[h;.log.info"Connection success"];
    }

.event.addhandler[`.z.pc;`.massive.pc]

/ .massive.start 5010
/ .massive.start `tp1