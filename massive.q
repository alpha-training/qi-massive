\e 1
.qi.requireconfs`MASSIVE_KEY
.qi.import`ipc;
.qi.frompkg[`proc;`feed]
.qi.frompkg[`massive;`norm]

\d .massive

H:0Ni
UN:upper .qi.getconf[`MASSIVE_UNIVERSE;"*"]
ASSET:lower .qi.getconf[`MASSIVE_ASSET;"stocks"]
DATA:upper .qi.getconf[`MASSIVE_DATA;"AM"]
STREAM:.qi.getconf[`MASSIVE_STREAM;"delayed"]
url:`$":wss://",STREAM,".massive.com:443";
header:"GET /",ASSET," HTTP/1.1\r\nHost: ",STREAM,".massive.com\r\n\r\n";
TICKERS:$[UN~"*";","sv(","vs DATA),\:".*";","sv cross[(","vs DATA),\:".";","vs UN]]

TD:`A`AM!`MassiveBar1s`MassiveBar1m

.z.ws:{
    {
        if[not null t:TD ev:`$x`ev;dbg;:.feed.upd[t;norm[ev]x]];
        if[f=`status;
            if[`connected=status:`$x`status;neg[.z.w] .j.j`action`params!("auth";.conf.MASSIVE_KEY)];
            if[`auth_failed=status;:.qi.fatal"Ensure MASSIVE_KEY is Entered Correctly in .conf"]
            if[`auth_success=status;neg[.z.w] .j.j`action`params!("subscribe";TICKERS)]];
        }each .j.k x;
    };

\d .

start:{.feed.start . .massive`header`url}