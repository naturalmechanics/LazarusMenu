unit TAdvancedMenu;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Menus, StdCtrls, ExtCtrls, dataTypes,BCLabel, bgraControls,BCTypes;
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
    MenuItemFonts :  Array of TFont;                                              // Item Fonts

    MenuBorderThicknesses:Array of Integer;
    MenuBorderRadii: Array of Integer;                                            // Border rounding
    MenuBGColors  :  Array of TColor;                                             // Background color for BCL Label
    MenuFGColors  :  Array of TColor;                                             // Foreground color for BCL Label
    MenuFontSizes :  Array of Integer;
    MenuFontWeigths: Array of Integer;

    MenuTree      :  dataTypes.tree_ofStrings;

    MenuAutoDraw  :  Array of Boolean;

    currentID     : Integer;

    widthPadding  : Integer;
    heightPadding : Integer;

    mLabels       : Array of TBCLabel;

    constructor Create();

    procedure create_mainMenu (var mainMenuItems : Array of String; var mainMenuNames : Array of String);
    procedure render({var} parent : TForm);
    procedure render_onPanel({var} parent: TPanel);
    procedure add_mainMenuActions(var actions : TProcArray);
    procedure add_mainMenuClickAction(var i: Integer; var action: TProc);
    procedure add_mainMenuSubMenu_byName(targetName : String; var items : Array of String; var itemNames : Array of String);
    procedure set_mainMenuItemClickAction_fromTemplate(menuName : String; actionName : String);
    procedure showSubMenu(Sender: TObject);
    procedure changeBGColor(Sender:TObject);
    procedure restoreBGColor(Sender:TObject);
    procedure render_subMenu_ofMainMenu(Sender : TObject);
    function extractMenuID(name : String): Integer;

  end;
  function generateRandomNumber() : Integer  ;
  function locateItem(needle: Integer; haystack : Array of Integer ) : Integer;

implementation

{ TAdvancedMainMenu }

constructor TAdvancedMainMenu.Create;
begin
  //----------------------------   INITIALIZE VALUES    --------------------------//
  currentID     := 0;                                                             // SET ID COUNTER to ZERO.
                                                                                  // EVERY time a menu item (regardless main menu or submenu)
                                                                                  // the counter will be incremented,guaranteeing an unique ID.
                                                                                  // This id will be inserted to the newly created menu Object.
                                                                                  // The Menu Object is also created with an unique name
                                                                                  // (the programmer ensures that the name is unique),
                                                                                  // So when referring to the Menu Object by name, we can
                                                                                  // look up the unique ID.


  //----------------------------   INITIALIZE CONTAINERS  ------------------------//

  MenuTree      := Nil;                                                           // PROBABLY unnecessary.

  SetLength(MenuItemIds,0);                                                       // PROBABLY unnecessary.

  SetLength(MenuBGColors,0);                                                      // PROBABLY unnecessary.
  SetLength(MenuFGColors,0);                                                      // PROBABLY unnecessary.
  SetLength(MenuItemFonts,0);                                                     // PROBABLY unnecessary.
  SetLength(MenuBorderRadii,0);                                                   // PROBABLY unnecessary.
  SetLength(MenuBorderThicknesses,0);                                             // PROBABLY unnecessary.
  SetLength(MenuFontSizes,0);                                                     // PROBABLY unnecessary.
  SetLength(MenuFontWeigths,0);                                                   // PROBABLY unnecessary.

  SetLength(MenuAutoDraw,0);                                                      // PROBABLY unnecessary.


  //----------------------------   INITIALIZE DRAWING PARAMS ---------------------//

  heightPadding := 8;                                                             // These values are used.
  widthPadding  := 8;
end;

procedure TAdvancedMainMenu.create_mainMenu(var mainMenuItems: array of String; var mainMenuNames: array of String);
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
    MenuBorderRadii[length(MenuBorderRadii) -1]:= 5;                              // Added the border radius

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

procedure TAdvancedMainMenu.render({var} parent: TForm);                          // Only draw the main menu. so do not consider children of any node of the menu tree
var
  mLabel        : TBCLabel;
  i             : Integer;
  ii            : Integer;
  ii_id         : Integer;
  mPanel        : TPanel;
  c             : TBitMap;
  currNode      : ^dataTypes.stringNodeStruct;

  procA         : TProc;
  procB         : TProc;

  j             : Integer;
  j_idx         : Integer;
begin
  ii            := 0;


  // first one
  
  mLabel        := TBCLabel.Create(parent);
  mLabel.Parent := parent;
  mLabel.Caption:= '  ' + menuTree.root^.stringVal + '  ';
  mLabel.Name   := menuTree.root^.name;

  // Extract the menu Item via a DFS search
  j             := extractMenuID(mLabel.Name);

  // find where in the master menu id list j matches an element
  j             := locateItem(j, MenuItemIds);

  // use that index to
  // extract the drawing params

  mLabel.Top    := widthPadding;
  mLabel.Left   := heightPadding;
  mLabel.Font   := MenuItemFonts[j];
  mLabel.Height := mLabel.Font.GetTextHeight('AyTg') + 4;
  mLabel.Width  := mLabel.Font.GetTextWidth(mLabel.Caption) + 4;
  mLabel.Rounding.RoundX:=MenuBorderRadii[j];
  mLabel.Rounding.RoundY:=MenuBorderRadii[j];
  mLabel.FontEx.Color:=MenuItemColors[j];




  c := TBitmap.Create;
  c.Canvas.Font.Assign(Screen.SystemFont);
  mLabel.Width  := c.Canvas.TextWidth(mLabel.Caption) + 4;
  c.Free;

  procA          := @changeBGColor;
  mLabel.OnMouseEnter:= procA ;

  procB          := @restoreBGColor;
  mLabel.OnMouseLeave:= procB ;

  SetLength(mLabels, length(mLabels) +1);
  mLabels[length(mLabels) - 1] := mLabel;

  currNode := menuTree.root;

  while not (currNode^.next = nil) do
  begin
    ii_id         := ii;

    // Extract the menu Item via a DFS search
    j             := extractMenuID(mLabel.Name);

    // find where in the master menu id list j matches an element
    j             := locateItem(j, MenuItemIds);

    currNode      := currNode^.next;
    mLabel        := TBCLabel.Create(parent);
    mLabel.Parent := parent;
    mLabel.Caption:= '  ' + currNode^.stringVal + '  ';
    mLabel.Name   := currNode^.name;
    mLabel.Top    := heightPadding  ;
    mLabel.Left   := mLabels[length(mLabels) - 1].Left + mLabels[length(mLabels) - 1].Width + 0;
    mLabel.Font   := MenuItemFonts[j];
    mLabel.Height := mLabel.Font.GetTextHeight('AyTg') + 4;
    mLabel.Width  := mLabel.Font.GetTextWidth(mLabel.Caption) + 4;
    mLabel.Rounding.RoundX:=MenuBorderRadii[j];
    mLabel.Rounding.RoundY:=MenuBorderRadii[j];
    mLabel.FontEx.Color:=MenuItemColors[j];


    c := TBitmap.Create;
    c.Canvas.Font.Assign(Screen.SystemFont);
    mLabel.Width  := c.Canvas.TextWidth(mLabel.Caption) + 4;
    c.Free;

    procA         := @changeBGColor;
    mLabel.OnMouseEnter:= procA ;

    procB         := @restoreBGColor;
    mLabel.OnMouseLeave:= procB ;

    SetLength(mLabels, length(mLabels) +1);
    mLabels[length(mLabels) - 1] := mLabel;
  end;

  // render every submenu



  // ### TODO ###
  // add font size
  // ADD font color

end;

procedure TAdvancedMainMenu.render_onPanel({var} parent: TPanel);                 // Only draw the main menu. so do not consider children of any node of the menu tree
var
  mLabel        : TBCLabel;
  i             : Integer;
  ii            : Integer;
  ii_id         : Integer;
  mPanel        : TPanel;
  c             : TBitMap;
  currNode      : ^dataTypes.stringNodeStruct;

  procA         : TProc;
  procB         : TProc;

begin
  ii            := 0;
  // first one
  mLabel        := TBCLabel.Create(parent);
  mLabel.Parent := parent;
  mLabel.Caption:= '  ' + menuTree.root^.stringVal + '  ';
  mLabel.Top    := heightPadding;
  mLabel.Left   := widthPadding;
  mLabel.Font   := Screen.SystemFont;
  mLabel.Height := mLabel.Font.GetTextHeight('AyTg') + 4;
  mLabel.Width  := mLabel.Font.GetTextWidth(mLabel.Caption) + 4;
  mLabel.Rounding.RoundX:=5;
  mLabel.Rounding.RoundY:=5;
  mLabel.FontEx.Color:=clWindowText;
  c := TBitmap.Create;
  c.Canvas.Font.Assign(Screen.SystemFont);
  mLabel.Width  := c.Canvas.TextWidth(mLabel.Caption) + 4;
  c.Free;


  procA          := @changeBGColor;
  mLabel.OnMouseEnter:= procA ;

  procB          := @restoreBGColor;
  mLabel.OnMouseLeave:= procB ;


  SetLength(mLabels, length(mLabels) +1);
  mLabels[length(mLabels) - 1] := mLabel;

  currNode := menuTree.root;

  while not (currNode^.next = nil) do
  begin
    ii_id         := ii;

    currNode      := currNode^.next;
    mLabel        := TBCLabel.Create(parent);
    mLabel.Parent := parent;
    mLabel.Caption:= '  ' + currNode^.stringVal + '  ';
    mLabel.Top    := heightPadding  ;
    mLabel.Left   := mLabels[length(mLabels) - 1].Left + mLabels[length(mLabels) - 1].Width + 0;
    mLabel.Font   := Screen.SystemFont;
    mLabel.Height := mLabel.Font.GetTextHeight('AyTg') + 4;
    mLabel.Width  := mLabel.Font.GetTextWidth(mLabel.Caption) + 4;
    mLabel.Rounding.RoundX:=5;
    mLabel.Rounding.RoundY:=5;
    mLabel.FontEx.Color:=clWindowText;
    c := TBitmap.Create;
    c.Canvas.Font.Assign(Screen.SystemFont);
    mLabel.Width  := c.Canvas.TextWidth(mLabel.Caption) + 4;
    c.Free;

    procA          := @changeBGColor;
    mLabel.OnMouseEnter:= procA ;

    procB          := @restoreBGColor;
    mLabel.OnMouseLeave:= procB ;


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
    // Append to Item ID
    SetLength(MenuItemIDs, length(MenuItemIds)+1);
    MenuItemIDs[length(MenuItemIds) - 1] := ii_id;

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



end;

procedure TAdvancedMainMenu.set_mainMenuItemClickAction_fromTemplate(menuName: String; actionName: String);
var
  j                             : Integer;
begin
  case actionName of
       'show_subMenu':
         begin
           j      := extractMenuID(menuName);

           // find where in the master menu id list j matches an element
           j      := locateItem(j, MenuItemIds);
           mLabels[j].OnClick:=@render_subMenu_ofMainMenu;
           mLabels[j].Name   :=menuName;

           // Extract the menu ID

           // extract the

         end;
  end;
end;

procedure TAdvancedMainMenu.showSubMenu(Sender: TObject);
var
  panel1        : TPanel;
  panel2        : TPanel;
  panel3        : TPanel;

  currlbl       : TBCLabel;
  pTop          : Integer;
  pLeft         : Integer;

  pTopPad       : Integer;
  pLeftPad      : Integer;

  currNode      : ^dataTypes.stringNodeStruct;
  currName      : String;
  nameFound     : Boolean;
  ii            : Integer;
  ii_id         : Integer;
  mLabel        : TBCLabel;  
  c             : TBitMap;

  maxW          : Integer;
  totH          : Integer;


begin

                                                                                  // showMessage('1');

                                                                                  // showMessage( (Sender as TLabel).Name);
                                                                                  // showMessage( IntToStr((Sender as TLabel).Top));
                                                                                  // showMessage( IntToStr((Sender as TLabel).Left));

  currlbl       := Sender as TBCLabel;
  pTop          := currlbl.Top + currlbl.Height;
  pLeft         := currlbl.Left;

  pTopPad       := 4;
  pLeftPad      := 4;

  panel1        := TPanel.Create(application.MainForm);
  panel1.Parent := application.MainForm;
  panel1.Top    := pTop;
  panel1.Left   := PLeft;
  panel1.BevelColor:= clBtnText;
  panel1.BevelOuter:= bvSpace;



  currNode      := menuTree.root;
  currName      := currlbl.Name;

  nameFound     := False;

  while not (currNode^.next = nil) do
  begin
                                                                                  // showMessage(currNode^.name + ' --> ' + targetName);
    if (currNode^.name = currName) then
    begin
      nameFound := True;
      Break;
    end
    else
    begin
      currNode  := currNode^.next;
    end;
  end;

  if not nameFound then Exit;

  if length(currNode^.Children) < 1 then Exit;

  currNode      := currNode^.Children[0];

  maxW          := 0;

  mLabel        := TBCLabel.Create(panel1);
  mLabel.Parent := panel1;
  mLabel.Caption:= currNode^.stringVal;
  mLabel.Name   := currNode^.name;
  mLabel.Top    := widthPadding;
  mLabel.Left   := heightPadding;
  mLabel.Font   := Screen.SystemFont;
  mLabel.Height := mLabel.Font.GetTextHeight('AyTg') + 4;
  mLabel.Width  := mLabel.Font.GetTextWidth(mLabel.Caption) + 4;
  c := TBitmap.Create;
  c.Canvas.Font.Assign(Screen.SystemFont);
  mLabel.Width  := c.Canvas.TextWidth(mLabel.Caption) + 4;
  c.Free;

  if mLabel.Width > maxW then maxW := mLabel.Width;
  totH          := mLabel.Top + mLabel.Height;


  SetLength(mLabels, length(mLabels) +1);
  mLabels[length(mLabels) - 1] := mLabel;

  while not (currNode^.next = nil) do
  begin
    ii_id         := ii;

    currNode      := currNode^.next;
    mLabel        := TBCLabel.Create(panel1);
    mLabel.Parent := panel1;
    mLabel.Caption:= currNode^.stringVal;
    mLabel.Name   := currNode^.name;
    mLabel.Top    := heightPadding + mLabels[length(mLabels) - 1].Top + mLabels[length(mLabels) - 1].Height + 5  ;
    mLabel.Left   := widthPadding ;
    mLabel.Font   := Screen.SystemFont;
    mLabel.Height := mLabel.Font.GetTextHeight('AyTg') + 4;
    mLabel.Width  := mLabel.Font.GetTextWidth(mLabel.Caption) + 4;
    c := TBitmap.Create;
    c.Canvas.Font.Assign(Screen.SystemFont);
    mLabel.Width  := c.Canvas.TextWidth(mLabel.Caption) + 4;
    c.Free;

    if mLabel.Width > maxW then maxW := mLabel.Width;
    totH          := mLabel.Top + mLabel.Height;

    SetLength(mLabels, length(mLabels) +1);
    mLabels[length(mLabels) - 1] := mLabel;
  end;

                                                                                 // showMessage('2');


  panel1.Height   := totH + 5;
  panel1.Width    := maxW + 15;
end;

procedure TAdvancedMainMenu.changeBGColor(Sender: TObject);
begin

  (Sender as TBCLabel).Background.Color := clActiveCaption;
  (Sender as TBCLabel).Background.Style := bbsColor;
end;

procedure TAdvancedMainMenu.restoreBGColor(Sender: TObject);
begin
  (Sender as TBCLabel).Background.Color := clBackground;
  (Sender as TBCLabel).Background.Style := bbsColor;
end;

procedure TAdvancedMainMenu.render_subMenu_ofMainMenu(Sender: TObject);
var
  j                             : Integer;
  menuName                      : String;
  currNode                      : ^dataTypes.stringNodeStruct;
begin

  menuName        := (Sender as TBCLabel).name;                                   // Searching for a
  // currNode        := dataTypes.get_treeNode_byName(menuName);

  // subMenus        := currNode^.Children[0];
  // renderSubmenus(submenus)

  // showMessage((Sender as TBCLabel).name);
  // showMessage('default onclick action');


  //j               := extractMenuID(menuName);
  // find where in the master menu id list j matches an element
  // j               := locateItem(j, MenuItemIds);
end;

function TAdvancedMainMenu.extractMenuID(name: String): Integer;
var
  i               : Integer;
  currNode        : ^dataTypes.stringNodeStruct;
begin
  i               := -1;

  currNode        :=  menuTree.root;

  while (True) do
  begin

    // showMessage('checking item : ' + currNode^.name + ' vs ' + name);
    if (currNode^.name = name) then
    begin
      i           := currNode^.ID;                                                // name found
      break;                                                                      // break while loop
    end;
                                                                                  // if at this point, then did not find a match

    if ( length(currNode^.Children) <> 0) then                                    // if there is a child
    begin
      currNode    := currNode^.Children[0];                                       // take the child and loop back
      continue;
    end;
                                                                                  // if at this point, then no child

    if (currNode^.next <> nil) then                                               // if can take the next, take the next
    begin
      currNode    := currNode^.next;
      continue;
    end;
                                                                                  // if at this point, then no next either

    if (currNode^.Parent <> nil) then
    begin
      currNode    := currNode^.Parent;
      if (currNode^.next <> nil) then
      begin
        currNode  := currNode^.next;
        continue;
      end;
    end;

    break;

  end;


  Result          := i;
end;

function generateRandomNumber() : Integer   ;
begin
  Result        := 0;
end;

function locateItem(needle: Integer; haystack : Array of Integer ) : Integer;
var
  i                     :  Integer;
  j                     :  Integer;
begin
  j                     := -1;
  for i := 0 to length(haystack) -1 do
  begin
    if ( haystack[i] = needle) then
    begin
      j                 := i;
      break;
    end;

  end;
  Result                := j;
end;

end.



