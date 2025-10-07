(*
 * Whonix Starter ( whonixutils.pas )
 *
 * Copyright: 2012 - 2025 ENCRYPTED SUPPORT LLC <adrelanos@riseup.net>
 * Author: einsiedler90@protonmail.com
 * License: See the file COPYING for copying conditions.
 *)

unit WhonixUtils;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Process, Math;

function AppDiskGetFreeSpace(const fn: string): int64;
function EnsureExePath(var TargetPath: string; DefaultPath: string): boolean;
procedure Execute(CommandLine: string; Output: TStrings);
procedure StreamSaveToFile(Stream: TStream; FileName: string; Output: TStrings);
//procedure CopyUnblocked(FromStream, ToStream: TStream);

implementation

function AppDiskGetFreeSpace(const fn: string): int64;
begin
  {$ifdef linux}
  //this crashes on FreeBSD 12 x64
  Exit(SysUtils.DiskFree(SysUtils.AddDisk(ExtractFileDir(fn))));
  {$endif}

  {$ifdef windows}
  Exit(SysUtils.DiskFree(SysUtils.GetDriveIDFromLetter(ExtractFileDrive(fn))));
  {$endif}

  //cannot detect
  Exit(-1);
end;

function EnsureExePath(var TargetPath: string; DefaultPath: string): boolean;
var
  Filename: string;
  sl: TStringList;
begin
  if FileExists(TargetPath) then
  begin
    Exit(True);
  end;

  if (TargetPath <> DefaultPath) and FileExists(DefaultPath) then
  begin
    TargetPath := DefaultPath;
    Exit(True);
  end;

  Filename := ExtractFileName(DefaultPath);
  TargetPath := FindDefaultExecutablePath(Filename);
  if FileExists(TargetPath) then
  begin
    Exit(True);
  end;

  sl := TStringList.Create;
  try
    {$IFDEF WINDOWS}
    Execute('where /r C:\ ' + Filename, sl);
    {$ELSE}
    Execute('which ' + Filename, sl);
    {$ENDIF}

    if (sl.Count > 0) and FileExists(sl.Strings[0]) then
    begin
      TargetPath := sl.Strings[0];
      Exit(True);
    end;

    TargetPath := '';
    Exit(False);
  finally
    sl.Free;
  end;
end;

procedure Execute(CommandLine: string; Output: TStrings);
const
  BUFSIZE = 2048;
var
  Process: TProcess;
  StrStream: TStringStream;
  BytesRead: longint;
  Running: boolean;
  Buffer: array[1..BUFSIZE] of byte;
begin
  Process := TProcess.Create(nil);
  Process.CommandLine := CommandLine;
  Process.Options := Process.Options + [poNoConsole];

  if Output <> nil then
  begin
    Process.Options := Process.Options + [poUsePipes, poStderrToOutPut];
    Output.Append('Execute: ' + Process.CommandLine);
  end;

  Process.Execute;

  StrStream := TStringStream.Create;

  try
    repeat
      Sleep(100);
      Application.ProcessMessages;

      Running := Process.Running;
      BytesRead := Min(BUFSIZE, Process.Output.NumBytesAvailable);
      if BytesRead > 0 then
      begin
        BytesRead := Process.Output.Read(Buffer, BytesRead);
        StrStream.Write(Buffer, BytesRead);
      end;
    until (BytesRead = 0) and not Running;
  except
    on E: Exception do
      if Output <> nil then
      begin
        Output.Append('Exception: ' + E.Message);
      end;
  end;

  if Output <> nil then
  begin
    Output.Append('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>');
    if StrStream.Size > 0 then
    begin
      Output.Append(StrStream.DataString);
    end;
    Output.Append('<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<');
  end;

  StrStream.Free;
  Process.Free;
end;

procedure StreamSaveToFile(Stream: TStream; FileName: string; Output: TStrings);

  procedure CopyUnblocked(FromStream, ToStream: TStream);
  const
    BYTE_COUNT = 1024 * 1024;
  begin
    while FromStream.Position + BYTE_COUNT < FromStream.Size do
    begin
      ToStream.CopyFrom(FromStream, BYTE_COUNT);
      Application.ProcessMessages;
    end;
    ToStream.CopyFrom(FromStream, FromStream.Size - FromStream.Position);
  end;

var
  FileStream: TFileStream;
begin
  try
    FileStream := TFileStream.Create(FileName, fmCreate);
    try
      CopyUnblocked(Stream, FileStream);
    finally
      FileStream.Free;
    end;

    Output.Append('Info: stream saved to ' + FileName);
  except
    Output.Append('Error: could not save stream to ' + FileName);
  end;
end;

end.
