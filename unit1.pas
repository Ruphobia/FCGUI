unit Unit1;

{$mode objfpc}{$H+}

interface

uses
{$ifdef unix}
  cthreads,
  cmem,
{$endif}
{$ifdef windows}
  windows,
{$endif}
   Interfaces, Classes, LCLType, StdCtrls, Controls, Forms, Dialogs, sysutils, gtk2proc;

type
  Tv7Form = class(TForm)
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormResize(Sender: TObject);
    procedure FormOnClick(Sender: TObject);
  protected
  public
  public
  end;

    TApplicationCallback = class(TComponent)
  private
  public
  end;

  //call back containers
  TOnCloseEvent = procedure;
  TOnResizeEvent = procedure(iwidth : integer; iheight : integer);

function InitDialog(x,y, sizex, sizey : integer; windowname : pchar; mode : integer):hwnd;cdecl;
function GetFormWidth:integer;cdecl;
function GetFormHeight:integer;cdecl;
function RegisterFormCloseEvent(OnCloseEvent : pointer): boolean;cdecl;
function RegisterFormOnResizeEvent(OnResizeEvent : pointer):boolean;cdecl;
procedure PrintControlCount;cdecl;


implementation

var
  DialogForm : Tv7Form;
  ApplicationCallback : TApplicationCallback;
  MainFormHandle : hwnd;
  fOnCloseEvent : TOnCloseEvent;
  fOnResizeEvent : TOnResizeEvent;

procedure TV7Form.FormOnClick(Sender:TObject);
begin
  writeln(inttostr(DialogForm.ControlCount));
end;

//when the form closes, this is triggered
procedure Tv7Form.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  //check to see if we have a callback to fire
  if (assigned(fOnCloseEvent)) then
    fOnCloseEvent; //fire on close event callback
end;

//when the form is resized, this is triggered
procedure Tv7Form.FormResize(Sender: TObject);
var
  iwidth, iheight : integer;
begin
  //if we are in maximized or full screen state, the form will report
  //whatever the last screen size was, so we need to override and
  //send the screen demensions (cause or form is set to full screen :P)
  if ((DialogForm.WindowState = wsMaximized) or
      (DialogForm.WindowState = wsFullScreen )) then
    begin
      iwidth := screen.width;
      iheight := screen.height;
    end
  else  //or just get the current form demensions
    begin
      iwidth := DialogForm.Width;
      iheight := DialogForm.Height;
    end;

  //if there is an event callback, trigger the event
  if (assigned(fOnResizeEvent)) then
    fOnResizeEvent(iwidth,iheight);
end;

//this must be the first function you call, set the initial screen position and
//size.  Mode will determine things like maximized, fullscreen, etc...
function InitDialog(x,y, sizex, sizey : integer; windowname : pchar; mode : integer):hwnd;cdecl;
var
  FormLabel : string;
begin
  try
    //create application callback for message pump
    ApplicationCallback := TApplicationCallback.Create(nil);
    //create the form and link to message pump
    DialogForm := Tv7Form.Createnew(ApplicationCallback);

    //setup events
    DialogForm.OnClose := @DialogForm.FormClose;
    DialogForm.OnResize := @DialogForm.FormResize;
    DialogForm.OnClick := @DialogForm.FormOnClick;

    //set form size and location
    DialogForm.Left :=x;
    DialogForm.Top := y;
    DialogForm.Width := sizex;
    DialogForm.Height := sizey;

    case mode of
      //normal, mode, sizeable with minimize, maximize and close
      0: DialogForm.WindowState := wsNormal;
      //window is maximized, not sizeable, has minimize, maximize and close
      1: DialogForm.WindowState := wsMaximized;
      //window is full screen, no visible border or buttons
      2: DialogForm.WindowState := wsFullScreen;
    end;

    //set form caption, convert to string and test for length
    if (assigned(windowname)) then
    begin
      //convert the char * text into a pascal string and save it
      FormLabel := strpas(windowname);
      //display the text on the title bar of the form
      DialogForm.Caption := FormLabel;
    end;

    //now that everthing is setup, we can show the form to the user
    DialogForm.Show;

    //TODO:This needs to be in an ifdef, this only works on linux.
    //Linux: translate the X11 handle struct into a window number that
    //CEF can use to draw on
    MainFormHandle := FormToX11Window(DialogForm);

    //return the window handle
    result := MainFormHandle;
  except
    result := 0;//oops, an error occured, send a null window handle
  end;
end;

//returns the current form width
function GetFormWidth:integer;cdecl;
begin
  //if we are maximized or full screen, we need to send screen size
  if ((DialogForm.WindowState = wsMaximized) or (DialogForm.WindowState = wsFullScreen)) then
    result := screen.Width
  else //or just send actual form size
    result := DialogForm.Width;
end;

//returns the current form height
function GetFormHeight:integer;cdecl;
begin
  //if we are maximized or full screen, we need to send screen size
  if ((DialogForm.WindowState = wsMaximized) or (DialogForm.WindowState = wsFullScreen)) then
    result := screen.Height
  else //or just send actual form size
    result := DialogForm.Height;
end;

//registers the form on close event callback
function RegisterFormCloseEvent(OnCloseEvent : pointer):boolean;cdecl;
begin
  result := true;
  try
    //if we receive a valid callback pointer, go ahead and save it
    if (assigned(OnCloseEvent)) then
      fOnCloseEvent := TOnCloseEvent(OnCloseEvent);//save function pointer
  except
      result := false;
  end;
end;

//registers on form resize event callback
function RegisterFormOnResizeEvent(OnResizeEvent : pointer):boolean;cdecl;
begin
  result := true;
  try
    //if we receive a valid callback pointer, go ahead and save it
    if (assigned(OnResizeEvent)) then
      fOnResizeEvent := TOnResizeEvent(OnResizeEvent);//save function pointer
  except
    result := false;
  end;
end;

//test, remove later, attempting to figure out a way to auto resize the
//CEF frame
procedure printcontrolcount;cdecl;
begin
  writeln(inttostr(DialogForm.ControlCount));
end;

end.

