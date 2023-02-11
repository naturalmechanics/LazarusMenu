unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Menus, StdCtrls, dataTypes;

type

  { TForm1 }

  TForm1 = class(TForm)
    Label1: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure MenuItem1Click(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.MenuItem1Click(Sender: TObject);
begin

end;

procedure TForm1.FormCreate(Sender: TObject);
var
  mainMenuItems                     : TStringArray;
  FileMenuItems                     : TStringArray;
  OpenmenuItems                     : TStringArray;
  menuTree                          : dataTypes.tree_ofStrings;
  ii                                : Integer;
  ii_id                             : Integer;
  idx                               : dataTypes.mt;

  mLabels                           : Array of TLabel;
  mLabel                            : TLabel;
  widthPadding                      : Integer;
  heightPadding                     : Integer;
  currNode                          : ^dataTypes.stringNodeStruct;

  c                                 : TBitMap;

begin

  {MENUS}

  menuTree := dataTypes.tree_ofStrings.Create();

  mainMenuItems := ['File','Edit','View','[Select Mode]', 'Tools', 'Window', 'Help'];
  FileMenuItems := ['New', 'Open', 'Save', 'Clear', 'Quit Program'];
  OpenMenuItems := ['Open from Template', 'Open from File', 'Open Recent'];

  for ii := 0 to length(mainMenuItems) -1 do
  begin
    ii_id       := ii;
    menuTree.AppendString_asNode(mainMenuItems[ii],ii_id);
  end;

  for ii := 0 to length(FileMenuItems) - 1 do
  begin
    ii_id       := ii;
    idx         := [[0,-1]];
    menuTree.AppendString_asSubNode(idx,FileMenuItems[ii],ii_id);
  end;

  for ii := 0 to length(OpenMenuItems) - 1 do
  begin
    ii_id       := ii;
    idx         := [[0,1],[0,-1]];
    menuTree.AppendString_asSubNode(idx,FileMenuItems[ii],ii_id);
  end;


  {RENDER}

  widthPadding  := 8;
  heightPadding := 8;

  ii            := 0;
  // first one
  mLabel        := TLabel.Create(self);
  mLabel.Parent := self;
  mLabel.Caption:= menuTree.root^.stringVal;
  mLabel.Top    := widthPadding;
  mLabel.Left   := heightPadding;
  mLabel.Font   := Screen.SystemFont;
  mLabel.Height := mLabel.Font.GetTextHeight('AyTg') + 4;
  mLabel.Width  := mLabel.Font.GetTextWidth(mLabel.Caption) + 4;
  c := TBitmap.Create;
  c.Canvas.Font.Assign(Screen.SystemFont);
  mLabel.Width  := c.Canvas.TextWidth(mLabel.Caption) + 4;
  c.Free;


  SetLength(mLabels, length(mLabels) +1);
  mLabels[length(mLabels) - 1] := mLabel;

  currNode := menuTree.root;

  for ii := 1 to length(mainMenuItems) -1 do
  begin
    ii_id         := ii;

    currNode      := currNode^.next;
    mLabel        := TLabel.Create(self);
    mLabel.Parent := self;
    mLabel.Caption:= currNode^.stringVal;
    mLabel.Top    := heightPadding  ;
    mLabel.Left   := widthPadding + mLabels[length(mLabels) - 1].Left + mLabels[length(mLabels) - 1].Width + 5;
    mLabel.Font   := Screen.SystemFont;
    mLabel.Height := mLabel.Font.GetTextHeight('AyTg') + 4;
    mLabel.Width  := mLabel.Font.GetTextWidth(mLabel.Caption) + 4;
    c := TBitmap.Create;
    c.Canvas.Font.Assign(Screen.SystemFont);
    mLabel.Width  := c.Canvas.TextWidth(mLabel.Caption) + 4;
    c.Free;
    // mLabel.Color  := RGBToColor(200, 200 * (ii mod 2), 200);
    // showMessage(mLabel.Caption + ': ' +  IntToStr(mLabel.Width));

    SetLength(mLabels, length(mLabels) +1);
    mLabels[length(mLabels) - 1] := mLabel;
  end;

end;
end.

