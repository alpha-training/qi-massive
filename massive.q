.qi.import`ipc;
.qi.import`log;
.qi.frompkg[`massive;`norm]
.qi.loadschemas`massive

\d .massive

H:0Ni
UN:.conf.MASSIVE_UNIVERSE
ASSET:lower .conf.MASSIVE_ASSET
DATA:.conf.MASSIVE_DATA

l:$[.conf.MASSIVE_MODE~"live";"socket";"delayed"];
url:`$":wss://",l,".massive.com:443";
header:"GET /",ASSET," HTTP/1.1\r\nHost: ",l,".massive.com\r\n\r\n"; // delayed or live stream should be optional
TICKERS:$["*"~UN;DATA,".*";","sv(DATA,"."),/:","vs UN]

sendtotp:{
        if["AM"~f:x`ev;:neg[H](`.u.upd;`MassiveBar1m;norm.A x)];
        if["A"~f;:neg[H](`.u.upd;`MassiveBar1s;norm.A x)];
 }

insertlocal:{
    if["AM"~f:x`ev;(t:`MassiveBar1m)insert norm.A x];
    if["A"~f;(t:`MassiveBar1s)insert norm.A x];
    if[not`g=attr get[t]`sym;update `g#sym from t]
 }

.z.ws:{
    {if[(f:`$x`ev)in`AM`A;:$[.qi.isproc;sendtotp;insertlocal]x];
    if[f=`status;
        if[`connected=status:`$x`status;neg[.z.w] .j.j`action`params!("auth";.conf.MASSIVE_KEY)];
        if[status=`auth_success;neg[.z.w] .j.j`action`params!("subscribe";TICKERS)]];
        }each .j.k x;
    };

start:{[target]
    if[.qi.isproc;
        if[null H::.ipc.conn .qi.tosym target;
            if[null H::first c:.ipc.tryconnect target;
            .log.fatal"Could not connect to ",.qi.tostr[target]," '",last[c],"'. Exiting"]];] 
    .log.info "Connection sequence initiated...";
    if[not h:first c:.qi.try[url;header;0Ni];
        .log.error err:c 2;
        if[err like"*Protocol*";
            if[.z.o in`l64`m64;
                .log.info"Try setting the env variable:\nexport SSL_VERIFY_SERVER=NO"]]];
    if[h;.log.info"Connection success"];
 }