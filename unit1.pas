unit Unit1;

{$mode objfpc}{$H+}

interface



uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, Menus,
  BCLabel, TAdvancedMenu;

type

  { TForm1 }

  TForm1 = class(TForm)
    BCLabel1: TBCLabel;
    Panel1: TPanel;
    procedure FormCreate(Sender: TObject);
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

  NewMenuItems  : Array of String;
  NewMenuItemNames:Array of String;

  OpenMenuItems : Array of String;

begin
  MainMenuItems := ['File', 'Edit', 'View', '[Select Mode]', 'Tools', 'Help'];
  MainMenuNames := ['fileMenu', 'editMenu', 'viewMenu', 'selectMenu', 'toolMenu', 'helpMenu'];
  MainMenu      := TAdvancedMenu.TAdvancedMainMenu.Create();
  MainMenu.create_mainMenu(MainMenuItems, MainMenuNames);

  mForm         := Form1;
  MainMenu.render(Form1);

  mPanel        := Panel1;
  MainMenu.render_onPanel(Panel1);

  FileMenuItems := ['New', 'Open', 'Save', 'Import', 'Export', 'Print', 'Send', 'Close', 'Quit'];
  FileMenuItemNames:=['newMenu', 'openMenu', 'saveMenu', 'importMenu', 'exportMenu', 'printMenu', 'sendMenu', 'closeMenu', 'quitMenu' ];

  NewMenuItems  := ['Blank Document', 'From Templates'];
  NewMenuItemNames:=['blankDocumentMenu', 'fromTemplateMenu'];

  OpenMenuItems := ['Open Recents', 'Open Existing Document'];


  {
  ta            := @FileClick;
  ids           := 1;

  MainMenu.add_mainMenuClickAction(ids, ta);
  }

  // MainMenu.add_mainMenuClickAction_byName('File', ta);
  MainMenu.add_mainMenuSubMenu_byName('fileMenu', FileMenuItems, FileMenuItemNames);                          // SUBMENU ADDED BUT WILL NOT RENDER
  MainMenu.set_mainMenuItemClickAction_fromTemplate('fileMenu', 'show_subMenu');                              // ONCLICK SHOW SUBMENU, NO OTHER ACTION
  MainMenu.set_mainMenuItemClickAction_fromTemplate('viewMenu', 'show_subMenu');                              // ONCLICK SHOW SUBMENU, NO OTHER ACTION
  // MainMenu.add_subMenuSubMenu_byName('newMenu', NewMenuItems);

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

