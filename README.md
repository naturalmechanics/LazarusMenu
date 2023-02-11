# LazarusMenu

What is going on : A new Lazarus Menu Widget to overcome limitations of the default Menu.

## Status
WIP - Do *NOT* use in production.

## Howto 

Include the files `datatypes.pas` and `TAdvancedMenu.pas` in your project.

Then, in your `mainForm.FormCreate`:

```
procedure TForm1.FormCreate(Sender: TObject);
var
  MainMenuItems : Array of String;
  mForm         : TForm;
  mPanel        : TPanel;
begin
  MainMenuItems := ['File', 'Edit', 'View', '[Select Mode]', 'Tools', 'Help'];
  MainMenu      := TAdvancedMenu.TAdvancedMainMenu.Create();
  MainMenu.create_mainMenu(MainMenuItems);
  mForm         := Form1;
  MainMenu.render(mForm);

  mPanel        := Panel1;
  MainMenu.render_onPanel(mPanel);

end;      


```

## Next Step :

- [` `] Add Submenu of Arbitrary Depth
- [*] Add Actions
- [` `] Add Radio / Check / Images etc

Legends:

- * -> Working on it now
- x -> Finished
- ` ` -> planned
