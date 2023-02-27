unit Unit1;

{$mode objfpc}{$H+}

interface



uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, Menus,
  StdCtrls, BCLabel, BCPanel, TAdvancedMenu, Themes, ColorBox, ActnList, LCLProc;

type

  { TForm1 }

  TForm1 = class(TForm)
    Action1: TAction;
    ActionList1: TActionList;
    BCLabel1: TBCLabel;
    BCLabel2: TBCLabel;
    BCLabel3: TBCLabel;
    BCPanel1: TBCPanel;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
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
    procedure Action1Execute(Sender: TObject);
    procedure BCPanel1Click(Sender: TObject);
    procedure ColorBox1Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Label1Click(Sender: TObject);
    procedure MenuItem1Click(Sender: TObject);
    procedure Panel1Click(Sender: TObject);
    procedure FileClick(Sender: TObject);
    procedure Panel1GetDockCaption(Sender: TObject; AControl: TControl; var ACaption: String);
    procedure quitApplication(Sender: TObject);
    procedure printData(Sender: TObject);
    procedure sendData(Sender: TObject);
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
  qa            : TAdvancedMenu.TProc;
  pa            : TAdvancedMenu.TProc;
  sa            : TAdvancedMenu.TProc;

  ids           : Integer;

  FileMenuItems : Array of String;
  FileMenuItemNames:Array of String;

  EditMenuItems : Array of String;
  EditMenuItemNames:Array of String;

  NewMenuItems  : Array of String;
  NewMenuItemNames:Array of String;

  OpenMenuItems : Array of String;
  OpenMenuItemNames:Array of String;

  recentMenuItems : Array of String;
  recentMenuItemNames:Array of String;

  closeMenuShortCut : String;
  quitMenuShortCut  : String;
  importMenuShortCut: String;

  blankDocumentMenuShortCut   :  String;
  fromTemplateMenuShortCut    :  String;

begin
  MainMenuItems := ['File', 'Edit', 'View', '[Select Mode]', 'Tools', 'Help'];
  MainMenuNames := ['fileMenu', 'editMenu', 'viewMenu', 'selectMenu', 'toolMenu', 'helpMenu'];
  MainMenu      := TAdvancedMenu.TAdvancedMainMenu.Create();
  MainMenu.create_mainMenu(MainMenuItems, MainMenuNames);


  FileMenuItems := ['New', 'Open', 'Save', 'Import', 'Export', 'Print', 'Send', 'Close', 'Quit'];
  FileMenuItemNames:=['newMenu', 'openMenu', 'saveMenu', 'importMenu', 'exportMenu', 'printMenu', 'sendMenu', 'closeMenu', 'quitMenu' ];

  EditMenuItems := ['Undo', 'Redo', '-', 'Cut', 'Copy', 'Paste'];
  EditMenuItemNames:=['undoMenu', 'redoMenu','divider1' ,'cutMenu', 'copyMenu', 'pasteMenu'];

  MainMenu.set_BGColor('viewMenu', TColor($662244));
  MainMenu.set_FGColor('helpMenu', TColor($88DDBB));

  mForm         := Form1;

  MainMenu.add_mainMenuSubMenu_byName('fileMenu', FileMenuItems, FileMenuItemNames);  // SUBMENU ADDED BUT WILL NOT RENDER
  MainMenu.add_mainMenuSubMenu_byName('editMenu', EditMenuItems, EditMenuItemNames);  // SUBMENU ADDED BUT WILL NOT RENDER


  MainMenu.add_subMenuCheckBox('newMenu', True);
  MainMenu.add_subMenuCheckBox('exportMenu', False);

  MainMenu.add_subMenuPicture('newMenu', 'new.png');
  MainMenu.add_subMenuPicture('openMenu', 'open.png');

  // MainMenu.set_FGColor('closeMenu', TColor($88DDBB));


  NewMenuItems  := ['Blank Document', 'From Templates'];
  NewMenuItemNames:=['blankDocumentMenu', 'fromTemplateMenu'];

  OpenMenuItems := ['Open Recents', 'Open Existing Document', 'Open Remote'];
  OpenMenuItemNames:=['recentItemsMenu', 'existingItemMenu', 'RemoteItemMenu'];

  recentMenuItems := ['File A', 'File B', 'File C', 'File D'];
  recentMenuItemNames:=['fileA', 'fileB', 'fileC', 'fileD'];

  closeMenuShortCut := 'Strg + W';
  quitMenuShortCut  := ShortCutToText(Action1.ShortCut);
  importMenuShortCut:= 'Strg + Umschalt + I';

  fromTemplateMenuShortCut := 'Strg + Umschalt + N';
  blankDocumentMenuShortCut:= 'Strg + N' ;

  MainMenu.assign_subMenuShortCut('closeMenu', closeMenuShortCut);
  MainMenu.assign_subMenuShortCut('quitMenu', quitMenuShortCut);
  MainMenu.assign_subMenuShortCut('importMenu', importMenuShortCut);

  MainMenu.add_subMenuSubMenu_byName('newMenu', NewMenuItems, NewMenuItemNames);
  MainMenu.add_subMenuSubMenu_byName('openMenu', openMenuItems, openMenuItemNames);

  MainMenu.add_subMenuSubMenu_byName('recentItemsMenu', recentMenuItems, recentMenuItemNames);

  MainMenu.assign_subMenuShortCut('blankDocumentMenu', blankDocumentMenuShortCut); 
  MainMenu.assign_subMenuShortCut('fromTemplateMenu' , fromTemplateMenuShortCut);


  mPanel        := Panel2;
  MainMenu.render(mPanel);


  qa            := @quitApplication;
  MainMenu.add_clickAction_byName('quitMenu', qa);
  Action1.OnExecute:=@quitApplication;
  MainMenu.add_clickAction_byName('printMenu', @printData);
  MainMenu.add_clickAction_byName('sendMenu', @sendData);

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

procedure TForm1.BCPanel1Click(Sender: TObject);
begin
  BCPanel1.Canvas.Pen.Color := clWhite;
  BCPanel1.Canvas.Pen.Width:=2;
  BCPanel1.Canvas.Line(0, BCPanel1.Height div 2, BCPanel1.Width, BCPanel1.Height div 2);
end;

procedure TForm1.Action1Execute(Sender: TObject);
begin

end;

procedure TForm1.MenuItem1Click(Sender: TObject);
begin

end;

procedure TForm1.Panel1Click(Sender: TObject);
begin
  Panel1.Canvas.Pen.Color := clWhite;
  Panel1.Canvas.Line(0, Panel1.Height div 2, Panel1.Width, Panel1.Height div 2);
end;

procedure TForm1.FileClick(Sender: TObject);
begin
  showMessage('file clicked');
end;

procedure TForm1.Panel1GetDockCaption(Sender: TObject; AControl: TControl;
  var ACaption: String);
begin

end;

procedure TForm1.quitApplication(Sender: TObject);
begin
  Form1.Close;
end;

procedure TForm1.printData(Sender: TObject);
begin
  showMessage('print clicked');
end;

procedure TForm1.sendData(Sender: TObject);
begin
  showMessage('Sending data');
end;

end.

