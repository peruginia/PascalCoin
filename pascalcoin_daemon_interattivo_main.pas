unit pascalcoin_daemon_interattivo_main;

{$mode objfpc}{$H+}

interface

uses
   Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
   ExtCtrls, upcdaemon, ULog;

type

   { TForm1 }

   TForm1 = class(TForm)
      Button1: TButton;
      Memo1: TMemo;
      Panel1: TPanel;
      procedure Button1Click(Sender: TObject);
   private
      FThread : TPCDaemonThread;
      Procedure ThreadStopped (Sender : TObject);
      procedure OnPascalCoinInThreadLog(logtype : TLogType; Time : TDateTime; AThreadID : Cardinal; Const sender, logtext : AnsiString);
   public

   end;

var
   Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.ThreadStopped(Sender: TObject);
begin
  FreeAndNil(FThread);
end;

procedure TForm1.OnPascalCoinInThreadLog(logtype: TLogType; Time: TDateTime; AThreadID: Cardinal; const sender, logtext: AnsiString);
  Var s : AnsiString;
begin
  try
  If logtype in [lterror,ltinfo] then begin

    if  pos('NINI', logtext)=0 then exit;

    if AThreadID=MainThreadID then s := ' MAIN:' else s:=' TID:';
    Memo1.Lines.Add(formatDateTime('dd/mm/yyyy hh:nn:ss.zzz',Time)+s+IntToHex(AThreadID,8)+' ['+CT_LogType[Logtype]+'] <'+sender+'> '+logtext);
    //WriteLn(formatDateTime('dd/mm/yyyy hh:nn:ss.zzz',Time)+s+IntToHex(AThreadID,8)+' ['+CT_LogType[Logtype]+'] <'+sender+'> '+logtext);
  end;

  except
  end;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  if Button1.caption='Avvia' then begin
     Button1.Caption:='Arresta';
     _FLog := TLog.Create(Nil);
     _FLog.OnInThreadNewLog:=@OnPascalCoinInThreadLog;

     FThread:=TPCDaemonThread.Create;
     FThread.OnTerminate:=@ThreadStopped;
     FThread.FreeOnTerminate:=False;
     FThread.Resume;
  end else begin
     FThread.Terminate;
     FThread.WaitFor;
     Button1.Caption:='Avvia';
  end;

end;

end.

