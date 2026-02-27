\e 1
.qi.requireconfs`MASSIVE_KEY
.qi.import`ipc;
.qi.frompkg[`proc;`feed]
.qi.frompkg[`massive;`norm]

H:0Ni
UN:upper .qi.getconf[`MASSIVE_UNIVERSE;"*"]
ASSET:lower .qi.getconf[`MASSIVE_ASSET;"stocks"]
DATA:upper .qi.getconf[`MASSIVE_DATA;"AM"]
STREAM:.qi.getconf[`MASSIVE_STREAM;"delayed"]
url:`$":wss://",STREAM,".massive.com:443";
header:"GET /",ASSET," HTTP/1.1\r\nHost: ",STREAM,".massive.com\r\n\r\n";
TICKERS:$[UN~"*";","sv(","vs DATA),\:".*";","sv cross[(","vs DATA),\:".";","vs UN]]

TD:`A`AM!`MassiveBar1s`MassiveBar1m

/ TODO - Ian - we should vectorise the norm, not one line at a time

.z.ws:{
    a:update `$ev from .j.k x;
    if[count st:select from a where ev=`status;msg.status each `$st`status];
    {[x;k] msg.data[k;delete ev from select from x where ev=k]}[a]each exec distinct ev from a where ev in key TD;
    };

msg.status:{[status]
    if[`connected=status;:neg[.z.w] .j.j`action`params!("auth";.conf.MASSIVE_KEY)];
    if[`auth_failed=status;.qi.fatal"Ensure MASSIVE_KEY is Entered Correctly in .conf"];
    if[`auth_success=status;neg[.z.w] .j.j`action`params!("subscribe";TICKERS)];
    }

msg.data:{[ev;x] .feed.upd[TD ev;norm[ev]x]}

\d .

start:{.feed.start[header;url]}