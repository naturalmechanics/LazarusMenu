unit TAdvancedMenu;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Menus, StdCtrls, ExtCtrls, dataTypes,BCLabel, bgraControls,BCTypes, BCPanel;
type

  TProcType      = procedure(const AParm: Integer) of object; //------------------// Method type
  TProcArray     = array of TProcType; //-----------------------------------------// Dynamic array
  TProc          = procedure(AParm: TObject) of object; //------------------------// also a procedure, but NOT a const param

  TNodePtr       = ^dataTypes.stringNodeStruct; //--------------------------------// Pointer to a menu struct

  { TAdvancedMainMenu }

  TAdvancedMainMenu = Class

  public

    MenuTree    : dataTypes.tree_ofStrings; //------------------------------------// Object tree

    MenuItemIDs : Array of Integer; //--------------------------------------------// IDs
    mainMenuRenderItems : Array of TBCPanel; //-----------------------------------// Panels used to render main Menu
    subMenuRenderItems  : Array of TBCPanel; //-----------------------------------// Panels used to render submenu of the main Menu
    subsubMenuRenderItems:Array of TBCPanel; //-----------------------------------// Panels used to render sub Menu of any further level(s)


    currentID   : Integer; //-----------------------------------------------------// the ID of the menu item currently being dealt with
    widthPadding: Integer;
    heightPadding : Integer;

    constructor Create();
    procedure create_mainMenu (var mainMenuItems : Array of String; var mainMenuNames : Array of String); // supply the Main Menu item labels and names
    procedure update_mainMenu_renderItemList(ii: Integer);
    procedure update_mainMenu_actionList(ii: Integer);

    procedure mainMenuItem_mouseEnter (Sender: TObject);
    procedure restoreBGColor(Sender: TObject);
    procedure toggleSubMenu (Sender: TObject);

    procedure set_BGColor(nm: String; cl : TColor);
    procedure set_FGColor(nm: String; cl : TColor);


    procedure render(parent: TPanel);

    procedure add_mainMenuSubMenu_byName(targetName: String; var items: array of String; var itemNames: array of String);
    procedure update_subMenu_renderItemList(nm: String);

    function get_uniqueID() : Integer;
    function check_existingMainMenu() : Integer;
    procedure update_IDArray(ii_id : Integer);
    function locate_menuNode_byID(ii_id: Integer): TNodePtr;
    function locate_renderItemPanel_byName(nm : String) : TBCPanel;
    function locate_menuNode_byName(nm: String): TNodePtr;

  end;
  function locate_integerItem(needle: Integer; haystack : Array of Integer ) : Integer;

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
  MenuTree      := dataTypes.tree_ofStrings.Create();                             // Create a new Menu Tree.

  SetLength(MenuItemIds,0);                                                       // PROBABLY unnecessary.
  SetLength(mainMenuRenderItems, 0);                                              // PROBABLY unnecessary.
  SetLength(subMenuRenderItems, 0);                                               // PROBABLY unnecessary.
  SetLength(subsubMenuRenderItems, 0);                                            // PROBABLY unnecessary.


  //----------------------------   INITIALIZE DRAWING PARAMS ---------------------//

  heightPadding := 8;                                                             // These values are used.
  widthPadding  := 8;
end; //###########################################################################// End of Function




procedure TAdvancedMainMenu.create_mainMenu(var mainMenuItems: array of String; var mainMenuNames: array of String);
var
  i             : Integer;                                                        // Here we have some dummy variables.
  ii            : Integer;
  ii_id         : Integer;
begin

  //-----------------------    If main menu exists, then exit       --------------// To create a new main menu, overwrite the existing or add items one by one

  if ( check_existingMainMenu() = 1 ) then
  begin
    Exit;
  end;


  //------    Otherwise Loop over everything that is being inserted       --------//

  for ii := 0 to length(mainMenuItems) -1 do  // ---------------------------------// Loop over everything that is being inserted.
  begin
    ii_id       :=      get_uniqueID();  //---------------------------------------// Get new unique ID
                                                                                  // This automatically updates all the necessary the ID flags



    //-- Each string packed in a record, and appended to the doubly linked list --//

    menuTree.AppendString_asNode(mainMenuItems[ii], mainMenuNames[ii], ii_id);    // Inserts a Menu Item in the main double linked list with an Unique ID



    //---------------------    Main ID list populated       ----------------------//

    update_IDArray(ii_id) ; //----------------------------------------------------// Append to Item ID



    //-----------------    Render Item list populated       ----------------------// Create the Label/Panel etc, but DONT render

    update_mainMenu_renderItemList(ii_id);



    //-----------------    Action Item list populated       ----------------------// Insert Default Actions

    update_mainMenu_actionList(ii_id);

  end;
end; //###########################################################################// End of Function

procedure TAdvancedMainMenu.update_mainMenu_renderItemList(ii: Integer);
var
  currNode      : TNodePtr;

  mPanel        : TBCPanel;
  mLabel        : TBCLabel;
  c             : TBitMap;
begin

  //-------------------    get the Node, given the ID        ---------------------// TBCPanel

  currNode      := locate_menuNode_byID(ii);

  //-------------------    Create menuItem container Panel   ---------------------// TBCPanel

  mPanel        := TBCPanel.Create(nil); //---------------------------------------// The main Panel (so that we can also add checkboxes and radios)
                                                                                  // ALTHOUGH the main menu should not contain any of that
  mPanel.Parent := nil;
  mPanel.Top    := heightPadding  ; //--------------------------------------------// Constant padding on the top. this is not user controllable
  mPanel.Border.Style:=bboNone;
  mPanel.BevelOuter:=bvNone; //---------------------------------------------------// Otherwise, a border will be drawn
  mPanel.Name   := currNode^.name + 'panel'; //-----------------------------------// The name
  mPanel.Caption:= ''; //---------------------------------------------------------// Otherwise this will render the internal name on top of the text label


  if ( length(mainMenuRenderItems) = 0) then //-----------------------------------// If no other main Menu items so far
  begin
    mPanel.Left := 0; //----------------------------------------------------------// Left = 0
  end
  else
  begin
    mPanel.Left := mainMenuRenderItems[length(mainMenuRenderItems) - 1].Left + mainMenuRenderItems[length(mainMenuRenderItems) - 1].Width + 0; // left = right of the last containing panel
  end;



  //-------------------    Create menuItem Display Label     ---------------------// TBCLabel

  mLabel        := TBCLabel.Create(mPanel); //------------------------------------// The label to contain the text of the menu item
  mLabel.Parent := mPanel;
  mLabel.Caption:= '  ' + currNode^.stringVal + '  '; //--------------------------// Caption
  mLabel.Name   := currNode^.name ; //--------------------------------------------// The name of the label remains as the internal identifier

  mLabel.FontEx.Name := Screen.SystemFont.Name; //--------------------------------// Font is related to the label
  mLabel.Height := mLabel.Font.GetTextHeight('AyTg') + 4; //----------------------// Label height
  mPanel.Height := mLabel.Height; //----------------------------------------------// Panel height same as label height
  mLabel.Rounding.RoundX:=5; //---------------------------------------------------// Rounding...
  mLabel.Rounding.RoundY:=5;
  mLabel.FontEx.Color:= clWindowText; //------------------------------------------// Font color
  mLabel.Background.Color  := clMenuBar;
  mPanel.Color  := clMenuBar;
  mLabel.Top    := (mPanel.Height - mLabel.Height) div 2; ;

  c := TBitmap.Create;
  c.Canvas.Font.Assign(Screen.SystemFont);
  mLabel.Width  := c.Canvas.TextWidth(mLabel.Caption) + 4; //---------------------// Label width
  mPanel.Width  := mLabel.Width; //-----------------------------------------------// panel width set to be the same
  c.Free;

  //-------------------    Insert menuItem container Panel   ---------------------// Insert to Array

  SetLength(MainMenuRenderItems, length(MainMenuRenderItems) +1);
  MainMenuRenderItems[length(MainMenuRenderItems) - 1] := mPanel;

end; //###########################################################################// End of Function

procedure TAdvancedMainMenu.update_mainMenu_actionList(ii: Integer);
var
  procMEnter    : TProc;
  procMExit     : TProc;
  procMClick    : TProc;
  mPanel        : TBCPanel;
  mLabel        : TBCLabel;
begin

  mPanel        := MainMenuRenderItems[ii]; //------------------------------------// The current main menu item
  mLabel        := mPanel.Controls[0] as TBCLabel; //-----------------------------// The current main menu item text label

  procMEnter    := @mainMenuItem_mouseEnter ; //----------------------------------// ON MOUSE ENTER
  mLabel.OnMouseEnter:= procMEnter; //--------------------------------------------// do this

  procMExit     := @restoreBGColor; //--------------------------------------------// ON MOUSE LEAVE
  mLabel.OnMouseLeave:= procMExit ; //--------------------------------------------// do this

  procMClick    := @toggleSubMenu; //---------------------------------------------// ON MOUSE CLICK
  mLabel.OnClick:= procMClick; //-------------------------------------------------// do this

end; //###########################################################################// End of Function


procedure TAdvancedMainMenu.mainMenuItem_mouseEnter(Sender: TObject);
var
  mPanel        : TBCPanel;
  currNode      : TNodePtr;
begin

  mPanel        := locate_renderItemPanel_byName((Sender as TBCLabel).Name);
  currNode      := locate_menuNode_byName((Sender as TBCLabel).Name);

  currNode^.BGColorCp := (mPanel.Controls[0] as TBCLabel).Background.Color; //----// Copy the old color
  currNode^.BGColorCopied:= True;  //---------------------------------------------// this tells us that we need to use the copied color,
                                                                                  // not the default color

  (Sender as TBCLabel).Background.Color := clActiveCaption; //--------------------// Set the highlight color
  (Sender as TBCLabel).Background.Style := bbsColor;



end;

procedure TAdvancedMainMenu.restoreBGColor(Sender: TObject);
var
  mPanel        : TBCPanel;
  currNode      : TNodePtr;
begin

  mPanel        := locate_renderItemPanel_byName((Sender as TBCLabel).Name);
  currNode      := locate_menuNode_byName((Sender as TBCLabel).Name);

  (Sender as TBCLabel).Background.Color := currNode^.BGColorCp;
  (Sender as TBCLabel).Background.Style := bbsColor;

end;

procedure TAdvancedMainMenu.toggleSubMenu(Sender: TObject);
var
  currNode      : TNodePtr;
  nm            : String;
begin

  currNode      := locate_menuNode_byName((Sender as TBCLabel).Name); //----------// After clicking on a display label to render a menu
                                                                                  // Get the corresponding node, using the name of the label
                                                                                  // label used to display a menu always has the same name
                                                                                  // as the menu node

  if (currNode^.subMenuContainer <> nil) then //----------------------------------// If there IS a submenu container (the initial valu of which
                                                                                  // is nil, to be overwritten in when a submenu is added)
  begin
    if ( ( currNode^.subMenuContainer as TBCPanel).Visible = false) then //-------// If not visible
    begin
      ( currNode^.subMenuContainer as TBCPanel).Parent  := (Sender as TBCLabel).Parent.Parent.Parent;  // REPARENT. doing it once is sufficient
      ( currNode^.subMenuContainer as TBCPanel).Visible := True; //---------------// make it visible
      ( currNode^.subMenuContainer as TBCPanel).isSubMenuDrawn := True; //--------// Set the flag
    end
    else //-----------------------------------------------------------------------// Otherwise if already visible :
    begin
      ( currNode^.subMenuContainer as TBCPanel).Visible := False; //--------------// TURN OFF
      ( currNode^.subMenuContainer as TBCPanel).isSubMenuDrawn := False; //-------// Remove the flag
      //----- TODO : IF CONSTANT REPARENTING CAUSED A PROBLEM, UNPARENT HERE -----//
    end;
  end;

end; //###########################################################################// End of Function



procedure TAdvancedMainMenu.set_BGColor(nm: String; cl: TColor); //---------------// Overwrite default BG Color of main menu
var
  mPanel        : TBCPanel;
begin
  mPanel        := locate_renderItemPanel_byName(nm);
  mPanel.Background.Color:= cl;
  (mPanel.Controls[0] as TBCLabel).Background.Color:=cl;
end;

procedure TAdvancedMainMenu.set_FGColor(nm: String; cl: TColor); //---------------// Overwrite default FG Color of main menu
var
  mPanel        : TBCPanel;
begin
  mPanel        := locate_renderItemPanel_byName(nm);
  (mPanel.Controls[0] as TBCLabel).FontEx.Color:=cl;
end;





procedure TAdvancedMainMenu.render(parent: TPanel);
var
  mPanel        : TBCPanel;
  i             : Integer;
  j             : Integer;
  nm            : String;
  currNode      : TNodePtr;

  chldNode      : TNodePtr;
begin

  for i := 0 to length(MainMenuRenderItems) -1 do
  begin

    mPanel      := MainMenuRenderItems[i];  //------------------------------------// The current main menu item

    nm          :=  (mPanel.Controls[0] as TBCLabel).Name; //---------------------// Get the unique name that is associated with the label
    currNode    :=  locate_menuNode_byName(nm);

    if (currNode^.Parent <> nil) then //------------------------------------------// If it has a parent, it can't be main menu
    begin
      continue; //----------------------------------------------------------------// Thus continue with the next one
    end;


    mPanel.Parent := parent; //---------------------------------------------------// Set the parent where it will be drawn

  end;





end; //###########################################################################// End of Function





procedure TAdvancedMainMenu.add_mainMenuSubMenu_byName(targetName: String;
  var items: array of String; var itemNames: array of String);
var
  ii            : Integer;
  currNode      : ^dataTypes.stringNodeStruct;
  ii_id         : Integer;

begin

  //--------------------   Locate the Menu Item by name       --------------------//

  currNode      := locate_menuNode_byName(targetName); //-------------------------// We can use the function we wrote


  if currNode = nil then Exit; //-------------------------------------------------// Did not Find it

  for ii := 0 to length(items) -1 do
  begin
    ii_id       := get_uniqueID(); //---------------------------------------------// Again, use a functionin stead

    menuTree.AppendString_asSubNode_byName(targetName, items[ii], itemNames[ii], ii_id);



    //---------------------    Main ID list populated       ----------------------//

    update_IDArray(ii_id) ; //----------------------------------------------------// Append to Item ID


    //-----------------    Action Item list populated       ----------------------// Insert Default Actions

    // update_RenderItemActionList(ii_id);


  end;

  //-----------------    Render Item list populated       ------------------------// Do it once for ALL The submenus

    update_subMenu_renderItemList(targetName);

end; //###########################################################################// End of Function

procedure TAdvancedMainMenu.update_subMenu_renderItemList(nm: String);
var
  currNode      : TNodePtr;
  chldNode      : TNodePtr;
  ii_id         : Integer;
  i             : Integer;

  mPanel        : TBCPanel;
  cPanel        : TBCPanel;
  cPanels       : Array of TBCPanel;

  mLabel        : TBCLabel;
  cLabel        : TBCLabel;

  cImage        : TImage;
  cText         : TStaticText;
  cCheckBox     : TCheckBox;

  c             : TBitMap;
  cl            : TColor;


  ii            : Integer;
  tHeight       : Integer;
  lHeight       : Integer;
  padding       : Integer;
  maxWidth      : Integer;
begin

  //-----------    Get the name of the origin and the origin itself      ---------//


  currNode      :=  locate_menuNode_byName(nm);

  ii_id         := -1;

  for ii := 0 to Length(MainMenuRenderItems) - 1 do
  begin
     if (MainMenuRenderItems[ii].NAME = currNode^.name+'panel' ) then
     begin
       ii_id    := ii;
       break;
     end;
  end;

  if (ii_id = -1 ) then
  begin
    Exit;
  end;


  if ( length(currNode^.Children) = 0) then
  begin
    Exit;
  end;

  mPanel        := TBCPanel.create(Application.MainForm);
  mPanel.Parent := nil;
  mPanel.Name   := currNode^.name + 'submenuPanel';

  mPanel.Left   := MainMenuRenderItems[ii_id].Left;  //--- -----------------------// Set the left to be at the same place as the origin
  mPanel.Top    := MainMenuRenderItems[ii_id].Top + MainMenuRenderItems[ii_id].Height;   // Same logic

  tHeight       := 0; //----------------------------------------------------------// Currently no height
  mPanel.Height :=  tHeight; //---------------------------------------------------// pretend no height
  lHeight       := 0; //----------------------------------------------------------// Last height : Has there been anything rendered before?
  padding       := 2; //----------------------------------------------------------// Constant Padding
  maxWidth      := 150; //--------------------------------------------------------// minimum value of maximum width
  mPanel.Width  := maxWidth; //---------------------------------------------------// set initial Width of container panel

  cl            := clBackground; //-----------------------------------------------// get initial color

  cPanels       := [];

  //--------------------    Cycle through the Children      ----------------------//

  for i := 0 to length(currNode^.Children) - 1 do
  begin

    chldNode    := currNode^.Children[i]; //--------------------------------------// Find the next child

    ii_id       := locate_integerItem(chldNode^.ID, MenuItemIds); //--------------// Find the suitable ID


    //------------------    Create the Container panel      ----------------------//

    cPanel      := TBCPanel.Create(mPanel); //------------------------------------// initialize panel
    cPanel.Parent:= mPanel; //----------------------------------------------------// we set the parent to be the new container panel

    cPanel.Left := 0 + padding; //------------------------------------------------// set left
    cPanel.Top  := lHeight + padding; //------------------------------------------// top = height of all previous children + padding
    cPanel.Height:= 25; //--------------------------------------------------------// set current child height
    cPanel.Background.Color:= cl; //----------------------------------------------// Set color

    cPanel.Border.Width:=0;
    cPanel.BevelOuter:=bvNone;
    cPanel.BevelWidth:=0;
    cPanel.Border.LightWidth:=0;
    cPanel.Border.Style:=bboNone;


    //-----------------------    Render a Checkbox      --------------------------//

    if (chldNode^.hasCheckBox) then //--------------------------------------------// If there was a checkbox
    begin

      cCheckBox := TCheckBox.Create(cPanel); //-----------------------------------// create check box
      cCheckBox.Parent := cPanel; //----------------------------------------------// Set parent (these checkboxes themselves aren't saved, but their state will be)
      cCheckBox.Left:=padding; //-------------------------------------------------// Same idea as with cPanel
      cCheckBox.Width:=25;
      cCheckBox.Height:=25;
      cCheckBox.Top:= (cPanel.Height - cCheckBox.Height) div 2;
      cCheckBox.Color:=cl;

      // ###############      TODO NEED TO ADD a onstatechange function

      if (chldNode^.checkBoxStatus) then //---------------------------------------// Looking at the saved state
      begin
        cCheckBox.State:=TCheckBoxState.cbChecked; //-----------------------------// And setting the state
      end
      else
      begin
        cCheckBox.State:=TCheckBoxState.cbUnchecked;
      end;

    end;



    //----------------------    Render a ImageIcon      --------------------------//

    if (chldNode^.hasPicture) then
    begin

      cImage    := TImage.Create(cPanel);  //-------------------------------------// Create Image. The image is just for show. No function added.
      cImage.Parent:= cPanel; //--------------------------------------------------// Same stuff as cCheckBox
      cImage.Picture.LoadFromFile(chldNode^.picturePath);
      cImage.Height:=20;
      cImage.Width:=20;
      cImage.Stretch:=true;
      cImage.Center:=true;
      cImage.Left:=26;
      cImage.Top:= (cPanel.Height - cImage.Height) div 2;

    end;


    //------------------    Render the menu Text Label      ----------------------//

    cLabel      := TBCLabel.Create(cPanel);
    cLabel.Parent := cPanel;
    cLabel.Caption:= '  ' + chldNode^.stringVal + '  ';
    cLabel.Name := chldNode^.name;
    cLabel.Top  := (cPanel.Height - cLabel.Height) div 2;
    cLabel.Left := 50;
    cLabel.FontEx.Name := Screen.SystemFont.Name;
    cLabel.Height := cLabel.Font.GetTextHeight('AyTg') + 4;
    cLabel.Width  := cLabel.Font.GetTextWidth(cLabel.Caption) + 4;
    cLabel.Rounding.RoundX:=5;
    cLabel.Rounding.RoundY:=5;
    cLabel.FontEx.Color:=clWindowText;

    cLabel.OnMouseEnter:= nil; //-------------------------------------------------// When these were initially created, these were set to be the same as main menu
    cLabel.OnMouseLeave:= nil;

    c           := TBitmap.Create;
    c.Canvas.Font.Assign(Screen.SystemFont);
    cLabel.Width:= c.Canvas.TextWidth(cLabel.Caption) + 4; //---------------------// Label width
    cPanel.Width:= cLabel.Width; //-----------------------------------------------// panel width set to be the same
    c.Free;

    cLabel.Background.Color:= cl;

    //############# REFACTOR THIS PART #########################################


    ///// correct the colors

    //cPanel.OnMouseEnter:=@changePanel;
    //cPanel.OnMouseLeave:=@restorePanel;

    //cLabel.OnMouseEnter:=@changeLabelParentPanel; //------------------------------// These will have to change.
    //cLabel.OnMouseLeave:=@restoreLabelParentPanel;

    // ###############      TODO NEED TO UPDATE SUBMENU MouseIN MouseOUT functions

    // ###############      TODO NEED TO IMPLEMENT these parts

    //cImage.OnMouseEnter:=@changeParentPanel;    //------------------------------// These will have to be implemented
    //cImage.OnMouseLeave:=@restoreParentPanel;

    //cCheckBox.OnMouseEnter:=@changeParentPanel;
    //cCheckBox.OnMouseLeave:=@restoreParentPanel;

    //############# END REFACTOR THIS PART #####################################




    //--------------    Update the variables with the loop     -------------------//

    lHeight     := cPanel.Top + cPanel.Height; //---------------------------------// Last Submenu item height

    tHeight     := tHeight + cPanel.Height + padding; //--------------------------// Total container height
    mPanel.Height:=tHeight ;  //--------------------------------------------------// update container height itself

    if ( (cPanel.Width +2 * padding) > maxWidth) then //--------------------------// If needed, update the width
    begin
      maxWidth  := cPanel.Width +2 * padding;
      mPanel.Width:= maxWidth;
    end;

    SetLength(cPanels, length(cPanels) + 1); //-----------------------------------// ADD to the list of submenus
    cPanels[length(cPanels) - 1] := cPanel;

  end;


  // ###############      TODO NEED TO ADD A Panel for keyboard  shortcuts

  //-------------    Draw the full submenu container correctly      --------------//

  mPanel.Height:=mPanel.Height + padding; //--------------------------------------// Increase height to add a bottom Margin
  mPanel.Border.Color :=clGrayText; //--------------------------------------------// the submenu container has a border, using a system color
  mPanel.Border.Width:=1;
  mPanel.BevelOuter:=bvNone;
  mPanel.BevelWidth:=0;
  mPanel.Border.LightWidth:=0;
  mPanel.Border.Style:=bboSolid;
  mPanel.BorderBCStyle:=bpsBorder; //---------------------------------------------// Border and bevel is set correctly
  mPanel.Background.Color  := clBackground; //------------------------------------// Background color has set
  mPanel.Rounding.RoundX:=5; //---------------------------------------------------// Constant rounding
  mPanel.Rounding.RoundY:=5;

  for i := 0 to length(cPanels) - 1 do
  begin
    cPanels[i].Width:=mPanel.Width - 2*padding; //--------------------------------// Outer contain of all submenu items has got the proper width
                                                                                  // which is adjusted to the largest of submenu label
                                                                                  // but all other submenu items need to be adjusted 7
                                                                                  // to have uniform width

  end;

  {
  mPanel.Height:= 40;
  mpanel.Top   := 100;

  mPanel.Caption:= 'rhrh';
  mPanel.Background.Color  := clRed;

  showMessage(inttostr(mPanel.left));
  showMessage(inttostr(mPanel.top));
  showMessage(inttostr(mPanel.height));
  showMessage(inttostr(mPanel.width));
  }

  mPanel.Visible:= False;
  currNode^.isSubMenuDrawn:= False;
  currNode^.subMenuContainer:=mPanel; //------------------------------------------// Registered the open submenu container

  showMessage ('adding submenu panel ' + currNode^.name + '; ' + mPanel.Name);

end;























{{{{{ HELPER FUNCTIONS }}}}}

function TAdvancedMainMenu.get_uniqueID: Integer;
begin
  currentID    := currentID + 1; //-----------------------------------------------// increment current ID
  Result       := currentID - 1; //-----------------------------------------------// new id is one more than the current ID
                                                                                  // We have to increment the current ID first, because
                                                                                  // the last line of the function should contain
                                                                                  // the special variable Result
                                                                                  // -1. because we want to return the value that was
                                                                                  // previously in it

end; //###########################################################################// End of Function




procedure TAdvancedMainMenu.update_IDArray(ii_id: Integer); //--------------------// Just insert in the ID array
begin
  SetLength(MenuItemIDs, length(MenuItemIds)+1); //-------------------------------// Increase the container length by 1 : this creates one empty space at the end
  MenuItemIDs[length(MenuItemIds) - 1] := ii_id; //-------------------------------// Insewrt new item at the end, in the newly created space.
end; //###########################################################################// End of Function




function TAdvancedMainMenu.check_existingMainMenu: Integer;
var
  res           : Integer; //-----------------------------------------------------// Track whether found
begin
  res           := 0; //----------------------------------------------------------// Is not found
  if ( MenuTree.root <> nil) then //----------------------------------------------// if root is not nil, then
  begin
    res         := 1; //----------------------------------------------------------// the menu tree must have created already
  end;
  Result        := res; //--------------------------------------------------------// return via result keyword
end; //###########################################################################// End of Function





function TAdvancedMainMenu.locate_menuNode_byID(ii_id: Integer): TNodePtr; //-----// given an ID, do a DFS.
var
  currNode      : ^dataTypes.stringNodeStruct; //---------------------------------// Node under test
  resNode       : ^dataTypes.stringNodeStruct; //---------------------------------// Node to return
begin

  currNode      :=  menuTree.root; //---------------------------------------------// Start at root
  resNode       :=  nil; //-------------------------------------------------------// Return value = Null

  while (True) do //--------------------------------------------------------------// Search indefinitely, unless break command
  begin

    if (currNode^.ID = ii_id) then //---------------------------------------------// id match
    begin
      resNode   := currNode; //---------------------------------------------------// Set Return value
      break; //-------------------------------------------------------------------// break while loop
    end;


    //----------------------------------------------------------------------------// if at this point, then did not find a match

    if ( length(currNode^.Children) <> 0) then //---------------------------------// if there is a child, DFS: CAN GO DEEPER
    begin
      currNode  := currNode^.Children[0]; //--------------------------------------// DFS: GO DEEPER, take the child
      continue; //----------------------------------------------------------------// and loop back
    end;



    //----------------------------------------------------------------------------// if at this point, then no child.
                                                                                  // DFS can't go deeper here
                                                                                  // Must take the horizontal nextnode

    if (currNode^.next <> nil) then //--------------------------------------------// if can take the next, DFS: Plan B: CAN MOVE HORIZONTALLY
    begin
      currNode  := currNode^.next; //---------------------------------------------// Move Horizontally, take the next
      continue; //----------------------------------------------------------------// Loop back
    end;


    //----------------------------------------------------------------------------// if at this point, then no next either
                                                                                  // DFS Can neighter go deeper, nor horizontal
                                                                                  // DFS Can try to move back one level, and then
                                                                                  // move horizontal.
                                                                                  // All options of siblings and parent have been expended;
                                                                                  // thus, try next sibling of parent.

    if (currNode^.Parent <> nil) then //------------------------------------------// If has a parent
    begin
      currNode  := currNode^.Parent; //-------------------------------------------// Take the parent
      if (currNode^.next <> nil) then //------------------------------------------// If the taken node (=parent of previously taken node)
                                                                                  // has a sibling
      begin
        currNode:= currNode^.next; //---------------------------------------------// Take the sibling
        continue; //--------------------------------------------------------------// Loop back
      end;
    end;



    //----------------------------------------------------------------------------// if at this point, then nothing worked

    break; //---------------------------------------------------------------------// Break Loop

  end;


  Result        := resNode; //----------------------------------------------------// If loop search was successful,
                                                                                  // resNode will contain the correct value
                                                                                  // Otherwise, nil.

end; //###########################################################################// End of Function

function TAdvancedMainMenu.locate_renderItemPanel_byName(nm: String): TBCPanel;
var
  mPanel        : TBCPanel;
  i             : Integer;
  currName      : String;
begin
  mPanel        := nil;

  for i:= 0 to length(MainMenuRenderItems) - 1 do
  begin
    currName    := MainMenuRenderItems[i].Name;
    if ( currName = nm + 'panel') then
    begin
      mPanel    := MainMenuRenderItems[i];
      break;
    end;
  end;

  Result        := mPanel;
end; //###########################################################################// End of Function




function TAdvancedMainMenu.locate_menuNode_byName(nm: String): TNodePtr;
var
  i             : Integer;
  currNode      : ^dataTypes.stringNodeStruct;
  resNode       : ^dataTypes.stringNodeStruct;
begin
  i             := -1;

  currNode      :=  menuTree.root;
  resNode       :=  nil;

  while (True) do
  begin

    if (currNode^.name = nm) then
    begin
      resNode   := currNode;                                                    // name found
      break;                                                                      // break while loop
    end;
                                                                                  // if at this point, then did not find a match

    if ( length(currNode^.Children) <> 0) then                                    // if there is a child
    begin
      currNode  := currNode^.Children[0];                                       // take the child and loop back
      continue;
    end;
                                                                                  // if at this point, then no child

    if (currNode^.next <> nil) then                                               // if can take the next, take the next
    begin
      currNode  := currNode^.next;
      continue;
    end;
                                                                                  // if at this point, then no next either

    if (currNode^.Parent <> nil) then
    begin
      currNode  := currNode^.Parent;
      if (currNode^.next <> nil) then
      begin
        currNode:= currNode^.next;
        continue;
      end;
    end;

    break;

  end;


  Result        := resNode;

end;




function locate_integerItem(needle: Integer; haystack : Array of Integer ) : Integer;
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
