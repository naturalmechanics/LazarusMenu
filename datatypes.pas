unit dataTypes;

{$mode ObjFPC}{$H+}{$modeswitch advancedrecords}

interface

uses
  Classes, SysUtils, Dialogs;

type
    genNodePtr = ^NodeStruct;
    vc         = Array of Integer;
    mt         = Array of vc;


    NodeStruct  = packed record
      ID        : Integer;

      end;
    TNodeArray = Array of NodeStruct;

    { stringNodeStruct }

    strNodePtr = ^stringNodeStruct ;
    stringNodeStruct = packed record
      ID        : Integer;
      name      : String;
      stringVal : String;
      Parent    : strNodePtr;
      Children  : Array of strNodePtr;
      prev      : strNodePtr;
      next      : strNodePtr;
    end;



  { tree_ofStrings }

  tree_ofStrings = class
    // Sections : Array of TRenderObjects.Section;
  public
      root                   : strNodePtr;
      constructor Create();
      procedure AppendNode(var ChildObj : NodeStruct);
      procedure AppendString_asNode(var insertionObject : String; var IDName : String; var ID : Integer);
      procedure AppendString_asSubNode ( var target: mt; var insertionObject : String; var ID : Integer);
      procedure AppendString_asSubNode_byName(var target: String ; var insertionObject: String; var name: String; var ID: Integer);
  end;
implementation



{ tree_ofStrings }

constructor tree_ofStrings.Create;
begin

end;

procedure tree_ofStrings.AppendNode(var ChildObj: NodeStruct);
begin

end;

procedure tree_ofStrings.AppendString_asNode(var insertionObject: String;  var IDName : String;
  var ID: Integer);
var
   newNode                       : ^stringNodeStruct;
   currNode                      : ^stringNodeStruct;

   argStr                        : String;
begin

   newNode               := New(strNodePtr);
   newNode^.stringVal    := insertionObject;
   newNode^.ID           := ID;
   newNode^.name         := IDName;
   newNode^.next         := nil;
   newNode^.prev         := nil;
   newNode^.Children     := nil;
   newNode^.Parent       := nil;

   if root = nil then
   begin
     new(root);
     root     := newNode;
   end
   else
   begin

     currNode    := root;
     while currNode^.next <> nil do
     begin
       currNode  := currNode^.next;
     end;

     newNode^.prev  := currNode;
     currNode^.next := newNode;

   end;
end;

procedure tree_ofStrings.AppendString_asSubNode(var target: mt ;
  var insertionObject: String; var ID: Integer);
var
   newNode                       : ^stringNodeStruct;
   currNode                      : ^stringNodeStruct;

   argStr                        : String;

   ii                            : Integer;
   ii_id                         : Integer;
   ti                            : vc;
   nodeNum                       : Integer;
   branchNum                     : Integer;

   jj                            : Integer;
   jj_id                         : Integer;

begin

   currNode := root;

   for ii   := 0 to length(target) -1 do
   begin
     ti     := target[ii];
     nodeNum:= ti[0];
     branchNum:=ti[1];

     for jj := 1 to nodeNum do
     begin
       currNode := currNode^.next;
     end;

     if (branchNum > -1) then
     begin
       currNode := currNode^.Children[branchNum];
     end;
   end;

   if length(currNode^.Children) = 0 then
   begin
     newNode               := New(strNodePtr);
     newNode^.stringVal    := insertionObject;
     newNode^.ID           := ID;
     newNode^.next         := nil;
     newNode^.prev         := nil;
     newNode^.Children     := nil;
     newNode^.Parent       := nil;
     SetLength(currNode^.Children, length(currNode^.Children)+1);
     currNode^.Children[length(currNode^.Children) - 1] := newNode;
   end
   else
   begin
     newNode               := New(strNodePtr);
     newNode^.stringVal    := insertionObject;
     newNode^.ID           := ID;
     newNode^.next         := nil;
     newNode^.prev         := nil;
     newNode^.Children     := nil;
     newNode^.Parent       := nil;
     newNode^.prev         := currNode^.Children[length(currNode^.Children) - 1] ;
     currNode^.Children[length(currNode^.Children) - 1]^.next := newNode;

     SetLength(currNode^.Children, length(currNode^.Children)+1);
     currNode^.Children[length(currNode^.Children) - 1] := newNode;



   end;


end;


procedure tree_ofStrings.AppendString_asSubNode_byName(var target: String ;
  var insertionObject: String; var name: String; var ID: Integer);
var
   newNode                       : ^stringNodeStruct;
   currNode                      : ^stringNodeStruct;

   argStr                        : String;

   ii                            : Integer;
   ii_id                         : Integer;
   ti                            : vc;
   nodeNum                       : Integer;
   branchNum                     : Integer;

   jj                            : Integer;
   jj_id                         : Integer;

   nameFound     : Boolean;
begin

   currNode := root;

   nameFound:= False;

   while not (currNode^.next = nil) do
   begin
     if (currNode^.name = target) then
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

   if length(currNode^.Children) = 0 then
   begin
     newNode               := New(strNodePtr);
     newNode^.stringVal    := insertionObject;
     newNode^.ID           := ID;
     newNode^.name         := name;
     newNode^.next         := nil;
     newNode^.prev         := nil;
     newNode^.Children     := nil;
     newNode^.Parent       := currNode;
     SetLength(currNode^.Children, length(currNode^.Children)+1);
     currNode^.Children[length(currNode^.Children) - 1] := newNode;
   end
   else
   begin
     newNode               := New(strNodePtr);
     newNode^.stringVal    := insertionObject;
     newNode^.ID           := ID;
     newNode^.name         := name;
     newNode^.next         := nil;
     newNode^.prev         := nil;
     newNode^.Children     := nil;
     newNode^.Parent       := currNode;
     newNode^.prev         := currNode^.Children[length(currNode^.Children) - 1] ;
     currNode^.Children[length(currNode^.Children) - 1]^.next := newNode;

     SetLength(currNode^.Children, length(currNode^.Children)+1);
     currNode^.Children[length(currNode^.Children) - 1] := newNode;



   end;


end;

end.


