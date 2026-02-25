\e 1
.qi.requireconfs`MASSIVE_KEY

.qi.import`ipc;
.qi.frompkg[`massive;`norm]

\d .massive

H:0Ni
UN:upper .qi.getconf[`MASSIVE_UNIVERSE;"*"]
ASSET:lower .qi.getconf[`MASSIVE_ASSET;"stocks"]
DATA:upper .qi.getconf[`MASSIVE_DATA;"AM"]

l:$[.qi.getconf[`MASSIVE_MODE;"delayed"]~"live";"socket";"delayed"];
url:`$":wss://",l,".massive.com:443";
header:"GET /",ASSET," HTTP/1.1\r\nHost: ",l,".massive.com\r\n\r\n"; // delayed or live stream should be optional
TICKERS:$[UN~"*";","sv(","vs DATA),\:".*";","sv cross[(","vs DATA),\:".";","vs UN]]

sendtotp:{
        if["AM"~f:x`ev;:neg[H](`.u.upd;`MassiveBar1m;norm.A x)];
        if[f~enlist"A";:neg[H](`.u.upd;`MassiveBar1s;norm.A x)];
 }

insertlocal:{
    if["AM"~f:x`ev;(t:`MassiveBar1m)insert norm.A x];
    if[f~enlist"A";(t:`MassiveBar1s)insert norm.A x];
    if[not`g=attr get[t]`sym;update `g#sym from t]
 }

.z.ws:{
    {if[(f:`$x`ev)in`AM`A;:$[.qi.isproc;sendtotp;insertlocal]x];
    if[f=`status;
        if[`connected=status:`$x`status;neg[.z.w] .j.j`action`params!("auth";.conf.MASSIVE_KEY)];
        if[`auth_failed=status;:.qi.fatal"Ensure MASSIVE_KEY is Entered Correctly In .conf"]
        if[`auth_success=status;neg[.z.w] .j.j`action`params!("subscribe";TICKERS)]];
        }each .j.k x;
    };

start::{
    if[.qi.isproc;
        if[null H::.ipc.conn target:.proc.self`depends_on;
            if[null H::first c:.ipc.tryconnect .ipc.conns[`tp1]`port;
            .qi.fatal"Could not connect to ",.qi.tostr[first target]," '",last[c],"'. Exiting"]];] 
    .qi.info "Connection sequence initiated...";
    if[not h:first c:.qi.try[url;header;0Ni];
        .qi.error err:c 2;
        if[err like"*Protocol*";
            if[.z.o in`l64`m64;
                .qi.fatal"Try setting the env variable:\nexport SSL_VERIFY_SERVER=NO"]]];
    if[h;.qi.info"Connection success"];
 }

\d .

