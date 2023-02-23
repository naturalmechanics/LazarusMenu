unit Unit1;

{$mode objfpc}{$H+}

interface



uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, Menus,
  StdCtrls, BCLabel, BCPanel, TAdvancedMenu, Themes, ColorBox;

type

  { TForm1 }

  TForm1 = class(TForm)
    BCLabel1: TBCLabel;
    BCLabel2: TBCLabel;
    BCLabel3: TBCLabel;
    BCPanel1: TBCPanel;
    CheckBox1: TCheckBox;
    ColorBox1: TColorBox;
    Image1: TImage;
    Label1: TLabel;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    Panel1: TPanel;
    Panel2: TPanel;
    StaticText1: TStaticText;
    procedure ColorBox1Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Label1Click(Sender: TObject);
    procedure MenuItem1Click(Sender: TObject);
    procedure Panel1Click(Sender: TObject);
    procedure FileClick(Sender: TObject);
    procedure Panel1GetDockCaption(Sender: TObject; AControl: TControl;
      var ACaption: String);
  private

  public

  end;

var
  Form1         : TForm1;
  MainMenu      : TAdvancedMenu.TAdvancedMainMenu;
  // mLabel        : TLabel;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
var
  MainMenuItems : Array of String;
  MainMenuNames : Array of String;

  mForm         : TForm;
  mPanel        : TPanel;
  ta            : TAdvancedMenu.TProc;
  ids           : Integer;

  FileMenuItems : Array of String;
  FileMenuItemNames:Array of String;

  EditMenuItems : Array of String;
  EditMenuItemNames:Array of String;

  NewMenuItems  : Array of String;
  NewMenuItemNames:Array of String;

  OpenMenuItems : Array of String;

begin
  MainMenuItems := ['File', 'Edit', 'View', '[Select Mode]', 'Tools', 'Help'];
  MainMenuNames := ['fileMenu', 'editMenu', 'viewMenu', 'selectMenu', 'toolMenu', 'helpMenu'];
  MainMenu      := TAdvancedMenu.TAdvancedMainMenu.Create();
  MainMenu.create_mainMenu(MainMenuItems, MainMenuNames);


  FileMenuItems := ['New', 'Open', 'Save', 'Import', 'Export', 'Print', 'Send', 'Close', 'Quit'];
  FileMenuItemNames:=['newMenu', 'openMenu', 'saveMenu', 'importMenu', 'exportMenu', 'printMenu', 'sendMenu', 'closeMenu', 'quitMenu' ];

  EditMenuItems := ['Cut', 'Copy', 'Paste', 'undo', 'redo'];
  EditMenuItemNames:=['cutMenu', 'copyMenu', 'pasteMenu', 'undoMenu', 'redoMenu'];

  MainMenu.add_mainMenuSubMenu_byName('fileMenu', FileMenuItems, FileMenuItemNames);  // SUBMENU ADDED BUT WILL NOT RENDER
  MainMenu.add_mainMenuSubMenu_byName('editMenu', EditMenuItems, EditMenuItemNames);  // SUBMENU ADDED BUT WILL NOT RENDER

  // MainMenu.add_subMenuCheckBox('newMenu', True);

  // MainMenu.add_subMenuPicture('newMenu', 'new.png');
  // MainMenu.add_subMenuPicture('newMenu', 'open.png');



  NewMenuItems  := ['Blank Document', 'From Templates'];
  NewMenuItemNames:=['blankDocumentMenu', 'fromTemplateMenu'];

  OpenMenuItems := ['Open Recents', 'Open Existing Document'];


  mForm         := Form1;
  mPanel        := Panel2;
  MainMenu.render(mPanel);


  {
  ta            := @FileClick;
  ids           := 1;

  MainMenu.add_mainMenuClickAction(ids, ta);
  }

  // MainMenu.add_mainMenuClickAction_byName('File', ta);
  //
  // MainMenu.set_mainMenuItemClickAction_fromTemplate('fileMenu', 'show_subMenu');                              // ONCLICK SHOW SUBMENU, NO OTHER ACTION
  // MainMenu.set_mainMenuItemClickAction_fromTemplate('viewMenu', 'show_subMenu');                              // ONCLICK SHOW SUBMENU, NO OTHER ACTION
  // MainMenu.add_subMenuSubMenu_byName('newMenu', NewMenuItems);

end;

procedure TForm1.Label1Click(Sender: TObject);
var
  c       : TColor;
begin
  c := ColorToRGB(clMenuHighlight);
  Label1.Caption := Format('R%d G%d B%d', [Red(c), Green(c), Blue(c)]);
end;

procedure TForm1.ColorBox1Change(Sender: TObject);
var
  c: TColor;
begin
  c := ColorToRGB(ColorBox1.Selected);
  Label1.Caption := Format('R%d G%d B%d', [Red(c), Green(c), Blue(c)]);
end;

procedure TForm1.MenuItem1Click(Sender: TObject);
begin

end;

procedure TForm1.Panel1Click(Sender: TObject);
begin

end;

procedure TForm1.FileClick(Sender: TObject);
begin
  showMessage('file clicked');
end;

procedure TForm1.Panel1GetDockCaption(Sender: TObject; AControl: TControl;
  var ACaption: String);
begin

end;

end.

