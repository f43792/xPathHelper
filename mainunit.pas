unit mainUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, SynHighlighterXML, SynEdit, Forms, Controls,
  Graphics, Dialogs, ExtCtrls, ComCtrls, ActnList, StdCtrls, Menus,
  XMLRead, DOM, XPath;

type

  { TMainForm }

  TMainForm = class(TForm)
    edXpathQry: TEdit;
    edPaceStr: TEdit;
    imglBTNs: TImageList;
    AppMainMenu: TMainMenu;
    prevCommands: TListBox;
    mfExit: TMenuItem;
    mfOpen: TMenuItem;
    mFile: TMenuItem;
    Panel4: TPanel;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    StaticText1: TStaticText;
    StaticText2: TStaticText;
    xmlOD: TOpenDialog;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    xmlEditor: TSynEdit;
    SynXMLSyn1: TSynXMLSyn;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    xmlTreeView: TTreeView;
    xmlSubSetTree: TTreeView;
    procedure edXpathQryKeyPress(Sender: TObject; var Key: char);
    procedure exXpathQueryChange(Sender: TObject);
    procedure exXpathQueryClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure mfExitClick(Sender: TObject);
    procedure mFileClick(Sender: TObject);
    procedure mfOpenClick(Sender: TObject);
    procedure prevCommandsDblClick(Sender: TObject);
    procedure prevCommandsSelectionChange(Sender: TObject; User: boolean);
    procedure ToolButton1Click(Sender: TObject);
  private
    Doc: TXMLDocument;
    //PassNode: TDOMNode;
    procedure XML2Tree(XMLDoc:TXMLDocument; TreeView:TTreeView);
    procedure executeQuery;
    procedure AddToPrevCommands(cmd: String);
    function GetNodeAttributesAsString(pNode: TDOMNode):string;
    procedure ParseXML(Node:TDOMNode; TreeNode: TTreeNode; tv: TtreeView);
    procedure loadPrevCommands;
    procedure savePrevCommands;
  public
    procedure openXMLFile(xmlFileName: String);
    procedure openXMLDialog;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.lfm}

{ TMainForm }


procedure TMainForm.ToolButton1Click(Sender: TObject);
begin
  openXMLDialog();
end;

procedure TMainForm.exXpathQueryClick(Sender: TObject);
begin

end;

procedure TMainForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  self.savePrevCommands;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
 xmlTreeView.ExpandSignType:=tvestPlusMinus;
 xmlSubSetTree.ExpandSignType:=tvestPlusMinus;
end;

procedure TMainForm.FormShow(Sender: TObject);
begin
 //openXMLFile('C:\temp\Pace\Reports\books.xml');
  openXMLFile('./xmlFiles/books.xml');
  self.loadPrevCommands;
end;

procedure TMainForm.mfExitClick(Sender: TObject);
begin
  Self.Close;
end;

procedure TMainForm.mFileClick(Sender: TObject);
begin

end;

procedure TMainForm.mfOpenClick(Sender: TObject);
begin
  openXMLDialog;
end;

procedure TMainForm.prevCommandsDblClick(Sender: TObject);
var
  selStr : String;
begin
  selStr := prevCommands.GetSelectedText;
  edXpathQry.Text:=selStr;
  executeQuery;
end;

procedure TMainForm.prevCommandsSelectionChange(Sender: TObject; User: boolean);
begin

end;


procedure TMainForm.exXpathQueryChange(Sender: TObject);
begin

end;

procedure TMainForm.edXpathQryKeyPress(Sender: TObject; var Key: char);
begin
  if Key = Chr(13) then
  begin
   executeQuery;
  end;
end;



procedure TMainForm.openXMLFile(xmlFileName: String);
begin
 ReadXMLFile(Self.Doc, xmlFileName);
 XML2Tree(Self.Doc, xmlTreeView);
 //xmlEditor.Lines.LoadFromFile(xmlFileName);
end;

procedure TMainForm.openXMLDialog;
var
  filename: string;
begin
  if xmlOD.Execute then
  begin
    filename := xmlOD.FileName;
    self.openXMLFile(filename);
  end;
end;

procedure TMainForm.XML2Tree(XMLDoc:TXMLDocument; TreeView:TTreeView);
begin
 // Recursive function to process a node and all its child nodes
  TreeView.Items.Clear;
  ParseXML(XMLDoc.DocumentElement,nil, TreeView);
  TreeView.FullExpand
end;

procedure TMainForm.executeQuery;
var
  XPathResult : TXPathVariable;
  XPathQry: String;
  //newXMLDoc : TXMLDocument;
  Node : TDOMNode;
  //sValue: String;
  //sName: String;
  i: Integer;
begin
  try
    xmlEditor.Lines.Clear;
    XPathQry:=edXpathQry.Text;
    xPathresult := EvaluateXPathExpression(XPathQry, Self.Doc);
    if (XPathResult <> nil) then
    begin
      xmlSubSetTree.Items.Clear;
      AddToPrevCommands(XPathQry);
      edPaceStr.Text:='{xpath:@' + XPathQry + '}';
    //http://stackoverflow.com/questions/5383919/xpath-and-txmldocument
      for i := 0 to XPathResult.AsNodeSet.Count - 1 do
        begin
          Node := TDOMNode(XPathResult.AsNodeSet[i]);
          if Node.FirstChild <> nil then
          begin
            //sValue := UTF8Encode(Node.FirstChild.NodeValue);
            //sName  := UTF8Encode(Node.NodeName);
            //xmlEditor.Lines.Add(sName + ' : ' + sValue);
            xmlEditor.Lines.Add(Node.TextContent);
            ParseXML(Node, nil, xmlSubSetTree);
          end;
        end;
      xmlSubSetTree.FullExpand;
    end else
    begin
      xmlEditor.lines.Add('NONE');
    end;
  except
    ShowMessage('Error');
  end;
end;

procedure TMainForm.AddToPrevCommands(cmd: String);
begin
  if(Pos(cmd, self.prevCommands.Items.Text) = 0) then
  begin
   self.prevCommands.Items.Add(cmd);
  end;
end;

function TMainForm.GetNodeAttributesAsString(pNode: TDOMNode): string;
var i: integer;
begin
  Result:='';
  if pNode.HasAttributes then
    for i := 0 to pNode.Attributes.Length -1 do
      with pNode.Attributes[i] do
        Result := Result + format(' %s="%s"', [NodeName, NodeValue]);

  // Remove leading and trailing spaces
  Result:=Trim(Result);
end;

procedure TMainForm.ParseXML(Node: TDOMNode; TreeNode: TTreeNode; tv: TtreeView);
begin
  // Exit procedure if no more nodes to process
  if Node = nil then Exit;

  // Add node to TreeView
  TreeNode := tv.Items.AddChild(TreeNode,
                                Trim(Node.NodeName+' '+
                                self.GetNodeAttributesAsString(Node)+
                                Node.NodeValue)
                                );

  // Process all child nodes
  Node := Node.FirstChild;
  while Node <> Nil do
  begin
    ParseXML(Node, TreeNode, tv);
    Node := Node.NextSibling;
  end;
end;

procedure TMainForm.loadPrevCommands;
begin
  try
   prevCommands.Items.LoadFromFile('./prevCommands.txt');
  except
  end;
end;

procedure TMainForm.savePrevCommands;
begin
  try
  prevCommands.Items.SaveToFile('./prevCommands.txt');
  except
  end;
end;



end.

