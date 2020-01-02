library fcgui;

{$mode objfpc}{$H+}

uses
{$ifdef unix}
  cthreads,
  cmem,
{$endif}
{$ifdef windows}
  windows,
{$endif}
  Interfaces, Classes, LCLType, StdCtrls, Controls, Forms, Dialogs, Unit1;

exports
InitDialog,
GetFormWidth,
GetFormHeight,
RegisterFormCloseEvent,
RegisterFormOnResizeEvent,
PrintControlCount;

begin
  Application.Initialize;
end.

