unit TAdvancedMenu;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Menus, StdCtrls, ExtCtrls, dataTypes;
type

  TProcType = procedure(const AParm: Integer) of object; // Method type
  TProcArray = array of TProcType; // Dynamic array
  TProc           = procedure(AParm: TObject) of object;
  // tadvancedmenu.pas(281,24) Error: Incompatible types: got "Variant" expected "<;Register>"

  { TAdvancedMainMenu }

  TAdvancedMainMenu = Class

  public

    MenuItemIds   :  Array of Integer;
    MenuItemColors:  Array of TColor;
    MenuItemFonts :  Array of TFont;
    MenuBorderColors:Array of Tcolor;
    MenuBorderThicknesses:Array of Integer;
    MenuBorderRadii: Array of Integer;
    MenuBGColors  :  Array of TColor;
    MenuFGColors  :  Array of TColor;
    MenuFontSizes :  Array of Integer;
    MenuFontWeigths: Array of Integer;

    MenuItemSpacing: Integer;
    MainMenuTop   :  Integer;
    MainMenuLeft  :  Integer;

    MenuTree      :  dataTypes.tree_ofStrings;

    MenuAutoDraw  :  Array of Boolean;

    currentID     : Integer;

    widthPadding  : Integer;
    heightPadding : Integer;

    mLabels       : Array of TLabel;

    constructor Create();

    procedure create_mainMenu (var mainMenuItems : Array of String; var mainMenuNames : Array of String);
    procedure render({var} parent : TForm);
    procedure render_onPanel({var} parent: TPanel);
    procedure add_mainMenuActions(var actions : TProcArray);
    procedure add_mainMenuClickAction(var i: Integer; var action: TProc);
    procedure add_mainMenuSubMenu_byName(targetName : String; var items : Array of String; var itemNames : Array of String);
    procedure showSubMenu(Sender: TObject);

  end;
  function generateRandomNumber() : Integer  ;

implementation

{ TAdvancedMainMenu }

constructor TAdvancedMainMenu.Create;
begin
  randomize;                                                                      // Call the randomize  function to generate random numbers
  currentID     := 0;
  heightPadding := 8;
  widthPadding  := 8;
end;

procedure TAdvancedMainMenu.create_mainMenu(var mainMenuItems: array of String;
  var mainMenuNames: array of String);
var
  i               : Integer;
  ii              : Integer;
  ii_id           : Integer;
begin
  MenuTree      := dataTypes.tree_ofStrings.Create();                             // Create a Menu Tree.
  for ii := 0 to length(mainMenuItems) -1 do
  begin
    ii_id       := currentID + 1;
    menuTree.AppendString_asNode(mainMenuItems[ii], mainMenuNames[ii], ii_id);    // Inserts a Menu Item in the main double linked list with an Unique ID

    // Append to Item ID
    SetLength(MenuItemIDs, length(MenuItemIds)+1);
    MenuItemIDs[length(MenuItemIds) - 1] := ii_id;

    // Append to color
    SetLength(MenuItemColors, length(MenuItemColors) + 1);
    MenuItemColors[length(MenuItemColors) - 1] := clWindowText ;                  // We add a default color.

    // Append to Fonts
    SetLength(MenuItemFonts, length(MenuItemFonts) + 1);
    MenuItemFonts[length(MenuItemFonts) -1]    := Screen.SystemFont;              // Added the SystemFont

    // Append to Borders
    SetLength(MenuBorderColors, length(MenuBorderColors) + 1);
    MenuBorderColors[length(MenuBorderColors) -1] := clWindowText;                // Added the Window Text color, picks the color as specified by the theme

    // Append to Border Thickness
    SetLength(MenuBorderThicknesses, length(MenuBorderThicknesses) + 1);
    MenuBorderThicknesses[length(MenuBorderThicknesses) -1]:= 0;                  // Added the Border Thickness

    // Append to Border Radius
    SetLength(MenuBorderRadii, length(MenuBorderRadii) + 1);
    MenuBorderRadii[length(MenuBorderRadii) -1]:= 0;                              // Added the border radius

    // Append to BG Colors
    SetLength(MenuBGColors, length(MenuBGColors) + 1);
    MenuBGColors[length(MenuBGColors) -1]:= clForm;                               // Added the Form Background color (will also pick up the default)

    // Append to Font Sizes
    SetLength(MenuFontSizes, length(MenuFontSizes) + 1);
    MenuFontSizes[length(MenuFontSizes) -1]:= 10;                                 // Added the SystemFont Size

    // Append to Font Weight
    SetLength(MenuFontWeigths, length(MenuFontWeigths) + 1);
    MenuFontWeigths[length(MenuFontWeigths) -1]:= 0;                              // Added the SystemFont Weight ->
                                                                                  // 0 = normal,
                                                                                  // 1 = Bold,                   2^0
                                                                                  // 2 = Italic,                 2^1
                                                                                  // 3 = Bold Italic,
                                                                                  // 4 = UnderLine               2^2
                                                                                  // 5 = Bold UnderLine
                                                                                  // 6 = Italic Underline
                                                                                  // 7 = Bold Italic UnderLine
                                                                                  // 8 = Thin                    2^3
                                                                                  // ETC

    // append to autodraw
    SetLength(MenuAutoDraw, length(MenuAutoDraw) + 1);
    MenuAutoDraw[length(MenuAutoDraw) -1]:= True;                                 // Draw it Anyways - because its the main menu

    currentID   := currentID + 1
  end;
end;

procedure TAdvancedMainMenu.render({var} parent: TForm);                            // Only draw the main menu. so do not consider children of any node of the menu tree
var
  mLabel        : TLabel;
  i             : Integer;
  ii            : Integer;
  ii_id         : Integer;
  mPanel        : TPanel;
  c             : TBitMap;
  currNode      : ^dataTypes.stringNodeStruct;
begin
  ii            := 0;
  // first one
  mLabel        := TLabel.Create(parent);
  mLabel.Parent := parent;
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

  while not (currNode^.next = nil) do
  begin
    ii_id         := ii;

    currNode      := currNode^.next;
    mLabel        := TLabel.Create(parent);
    mLabel.Parent := parent;
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


    SetLength(mLabels, length(mLabels) +1);
    mLabels[length(mLabels) - 1] := mLabel;
  end;
end;

procedure TAdvancedMainMenu.render_onPanel({var} parent: TPanel);                   // Only draw the main menu. so do not consider children of any node of the menu tree
var
  mLabel        : TLabel;
  i             : Integer;
  ii            : Integer;
  ii_id         : Integer;
  mPanel        : TPanel;
  c             : TBitMap;
  currNode      : ^dataTypes.stringNodeStruct;
begin
  ii            := 0;
  // first one
  mLabel        := TLabel.Create(parent);
  mLabel.Parent := parent;
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

  while not (currNode^.next = nil) do
  begin
    ii_id         := ii;

    currNode      := currNode^.next;
    mLabel        := TLabel.Create(parent);
    mLabel.Parent := parent;
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


    SetLength(mLabels, length(mLabels) +1);
    mLabels[length(mLabels) - 1] := mLabel;
  end;
end;

procedure TAdvancedMainMenu.add_mainMenuActions(var actions: TProcArray);
begin

end;

procedure TAdvancedMainMenu.add_mainMenuClickAction(var i: Integer; var action: TProc);
var
  ii            : Integer;
  idx           : Integer;
  currNode      : ^dataTypes.stringNodeStruct;
begin
  currNode := menuTree.root;


  while not (currNode^.next = nil) do
  begin
    if (currNode^.ID = i) then
    begin
      Break;
    end
    else
    begin
      currNode := currNode^.next;
    end;
  end;


  for idx := 0 to length(MenuItemIds)-1 do
  begin
    if MenuItemIds[idx] = currNode^.ID then
    begin
      ii := idx;
      Break;
    end;

  end;

  mLabels[ii].OnClick:=action;
end;

procedure TAdvancedMainMenu.add_mainMenuSubMenu_byName(targetName: String;
  var items: array of String; var itemNames: array of String);
var
  ii            : Integer;
  idx           : Integer;
  currNode      : ^dataTypes.stringNodeStruct;
  nameFound     : Boolean;
  ii_id         : Integer;
  ta            : TProc;
begin

  currNode := menuTree.root;

  nameFound:= False;

  while not (currNode^.next = nil) do
  begin
    // showMessage(currNode^.name + ' --> ' + targetName);
    if (currNode^.name = targetName) then
    begin
      nameFound:= True;
      Break;
    end
    else
    begin
      currNode := currNode^.next;
    end;
  end;



  if not nameFound then Exit;

  for ii := 0 to length(items) -1 do
  begin
    ii_id       := currentID + 1;
    menuTree.AppendString_asSubNode_byName(targetName, items[ii], itemNames[ii], ii_id);

  end;

  currentID     := currentID + 1   ;

  // ONCE THIS IS DONE
  // ADD A RENDER MENU ACTION to CURRNODE

  // showMessage(currNode^.name);

  ii_id         := currNode^.ID;
  for ii:= 0 to length (MenuItemIds) do
  begin
    if MenuItemIds[ii] = ii_id then break;
  end;

  ta            := @showSubMenu;
  mLabels[ii].OnMouseEnter:= ta ;

end;

procedure TAdvancedMainMenu.showSubMenu(Sender: TObject);
var
  panel1        : TPanel;
  panel2        : TPanel;
  panel3        : TPanel;

begin

  // showMessage('1');

  panel1        := TPanel.Create(application.MainForm);
  panel1.Parent := application.MainForm;
  panel1.Top    := 40;
  panel1.Left   := 40;

  panel1.Caption:= 'SUBMENU ';
  panel1        := TPanel.Create(application.MainForm);
  panel1.Parent := application.MainForm;
  panel1.Top    := 80;
  panel1.Left   := 40;

  panel1.Caption:= 'ITEM ';

  panel1        := TPanel.Create(application.MainForm);
  panel1.Parent := application.MainForm;
  panel1.Top    := 120;
  panel1.Left   := 40;

  panel1.Caption:= 'MORE ';

  // showMessage('2');

end;

function generateRandomNumber() : Integer   ;
begin
  Result        := 0;
end;

end.



