program TestApp;

{$mode objfpc}{$H+}

uses
{$ifdef unix}
  cthreads,
  cmem,
{$endif}
{$ifdef windows}
  windows,
{$endif}
  Interfaces, // this includes the LCL widgetset
  Forms, testunit1
  { you can add units after this };

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.

