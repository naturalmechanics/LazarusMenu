unit TAdvancedMenu;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Menus, StdCtrls, ExtCtrls, dataTypes;
type

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

    procedure create_mainMenu (var mainMenuItems : Array of String);
    procedure render(var parent : TForm);
    procedure render_onPanel(var parent: TPanel);


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

procedure TAdvancedMainMenu.create_mainMenu(var mainMenuItems: array of String);
var
  i               : Integer;
  ii              : Integer;
  ii_id           : Integer;
begin
  MenuTree      := dataTypes.tree_ofStrings.Create();                             // Create a Menu Tree.
  for ii := 0 to length(mainMenuItems) -1 do
  begin
    ii_id       := currentID + 1;
    menuTree.AppendString_asNode(mainMenuItems[ii],ii_id);                        // Inserts a Menu Item in the main double linked list with an Unique ID

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

procedure TAdvancedMainMenu.render(var parent: TForm);                            // Only draw the main menu. so do not consider children of any node of the menu tree
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

procedure TAdvancedMainMenu.render_onPanel(var parent: TPanel);                   // Only draw the main menu. so do not consider children of any node of the menu tree
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

function generateRandomNumber() : Integer   ;
begin
  Result        := 0;
end;

end.



