unit mainUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, SynHighlighterXML, SynEdit, Forms, Controls,
  Graphics, Dialogs, ExtCtrls, ComCtrls, ActnList, StdCtrls, Menus,
  XMLRead, DOM, XPath, XMLtoTreeView;

type

  { TMainForm }

  TMainForm = class(TForm)
    edPaceStr: TEdit;
    edXpathQry3: TMemo;
    edXpathQry2: TMemo;
    imglBTNs: TImageList;
    AppMainMenu: TMainMenu;
    edXpathQry1: TMemo;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel5: TPanel;
    pBody1: TPanel;
    pHeader1: TPanel;
    Panel6: TPanel;
    pHeader2: TPanel;
    pHeader3: TPanel;
    prevCommands: TListBox;
    mfExit: TMenuItem;
    mfOpen: TMenuItem;
    mFile: TMenuItem;
    Panel4: TPanel;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    Splitter3: TSplitter;
    StatusBar: TStatusBar;
    stSubset1: TStaticText;
    stXML: TStaticText;
    stXML1: TStaticText;
    stXML2: TStaticText;
    stXML3: TStaticText;
    stSubset2: TStaticText;
    stXML4: TStaticText;
    ToolButton2: TToolButton;
    xmlOD: TOpenDialog;
    pMainHeader: TPanel;
    pColumn1: TPanel;
    SynXMLSyn1: TSynXMLSyn;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    xmlSubSetTree1: TTreeView;
    xmlTreeView: TTreeView;
    xmlSubSetTree2: TTreeView;
    procedure edXpathQryaKeyPress(Sender: TObject; var Key: char);
    procedure exXpathQueryChange(Sender: TObject);
    procedure exXpathQueryClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure mfExitClick(Sender: TObject);
    procedure mFileClick(Sender: TObject);
    procedure mfOpenClick(Sender: TObject);
    procedure pColumn1Click(Sender: TObject);
    procedure prevCommandsDblClick(Sender: TObject);
    procedure ToolButton1Click(Sender: TObject);
    procedure ToolButton2Click(Sender: TObject);
    procedure xmlTreeViewGetSelectedIndex(Sender: TObject; Node: TTreeNode);
    procedure xmlTreeViewSelectionChanged(Sender: TObject);
  private
    Doc: TXMLDocument;
    ResultOne : TXMLDocument;
    ResultTwo : TXMLDocument;
    Conversor: TXMLConvertor; //mainTreeViewConvertor
    //PassNode: TDOMNode;
    //procedure XML2Tree(XMLDoc:TXMLDocument; TreeView:TTreeView);
    procedure executeQuery(Sender: TObject);
    procedure AddToPrevCommands(cmd: String);
    procedure loadPrevCommands;
    procedure savePrevCommands;
    procedure SetStatusBarText(idx: Integer; Txt: String);
    function GetTickCount : QWORD;
    function ConverToPACEFormat(inputStr: String): String;
  public

    procedure openXMLFile(xmlFileName: String);
    procedure openXMLDialog;
  end;

var
  MainForm: TMainForm;

implementation

Uses
  LclIntf, Clipbrd;

{$R *.lfm}

{ TMainForm }


procedure TMainForm.ToolButton1Click(Sender: TObject);
begin
  openXMLDialog();
end;

procedure TMainForm.ToolButton2Click(Sender: TObject);
begin
 openXMLFile('./xmlFiles/Output_some.xml');
 xmlSubSetTree2.Items.Clear;
end;

procedure TMainForm.xmlTreeViewGetSelectedIndex(Sender: TObject; Node: TTreeNode);
begin

end;

procedure TMainForm.xmlTreeViewSelectionChanged(Sender: TObject);
var
  clb : TClipboard;
  Node : TTreeNode;
begin
  clb := TClipboard.Create;
  Node := xmlTreeView.Selected;
  clb.SetTextBuf(PChar(Node.Text));
end;

procedure TMainForm.exXpathQueryClick(Sender: TObject);
begin

end;

procedure TMainForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  self.savePrevCommands;
  //CloseAction:=CloseAction.caFree;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
 Conversor := TXMLConvertor.Create;
 xmlTreeView.ExpandSignType:=tvestPlusMinus;
 xmlSubSetTree2.ExpandSignType:=tvestPlusMinus;
end;

procedure TMainForm.FormShow(Sender: TObject);
begin
 //openXMLFile('C:\temp\Pace\Reports\books.xml');
  openXMLFile('./xmlFiles/books.xml');
  xmlSubSetTree2.Items.Clear;
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

procedure TMainForm.pColumn1Click(Sender: TObject);
begin

end;

procedure TMainForm.prevCommandsDblClick(Sender: TObject);
var
  selStr : String;
begin
  selStr := prevCommands.GetSelectedText;
  edXpathQry1.Text:=selStr;
  executeQuery(Sender);
end;


procedure TMainForm.exXpathQueryChange(Sender: TObject);
begin

end;

procedure TMainForm.edXpathQryaKeyPress(Sender: TObject; var Key: char);
begin
  if Key = Chr(13) then
  begin
   executeQuery(Sender);
   Key := Chr(0);
  end;
end;



procedure TMainForm.openXMLFile(xmlFileName: String);
begin
 ReadXMLFile(Self.Doc, xmlFileName);
 //XML2Tree(Self.Doc, xmlTreeView);
 Conversor.populateTreeView(Self.Doc.DocumentElement, xmlTreeView);
 stXML.Caption:='XML [ ' + IntToStr(Self.Doc.DocumentElement.ChildNodes.Count) + ' ]';
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


procedure TMainForm.executeQuery(Sender: TObject);
var
  XPathResult : TXPathVariable;
  XPathQry: String;
  st, ft : LongInt;
  xPathQryMemo : TMemo;
  level : Integer = 1;
begin
  try
    st := GetTickCount;
    xPathQryMemo := (Sender as TMemo);
    XPathQry:= Trim(xPathQryMemo.Lines.Text);

    if xPathQryMemo.Name      = 'edXpathQry1' then level := 1
    else if xPathQryMemo.Name = 'edXpathQry2' then level := 2
    else if xPathQryMemo.Name = 'edXpathQry3' then level := 3;

    //xPathresult := EvaluateXPathExpression(WideString(XPathQry), Self.Doc);

      Case level of
       1: begin
           xPathresult := EvaluateXPathExpression(WideString(XPathQry), Self.Doc);
           if (XPathResult <> nil) then
           begin
             Self.ResultOne := Conversor.XPathResultToXMLDocument(XPathResult);
             Conversor.populateTreeView(Self.ResultOne.DocumentElement, xmlSubSetTree1);
             stSubset1.Caption:= 'Result: [ ' + intTostr(Self.ResultOne.DocumentElement.ChildNodes.Count) + ' ] ';
           end;
          end;

       2: begin
          xPathresult := EvaluateXPathExpression(WideString(XPathQry), Self.ResultOne);
          if (XPathResult <> nil) then
          begin
             Self.ResultTwo := Conversor.XPathResultToXMLDocument(XPathResult);
             Conversor.populateTreeView(Self.ResultTwo.DocumentElement, xmlSubSetTree2);
             stSubset2.Caption:= 'Result: [ ' + intTostr(Self.ResultTwo.DocumentElement.ChildNodes.Count) + ' ] ';
           end;
          end;

      end;

  ft := GetTickCount;
  SetStatusBarText(0, format('Query performed in %d ms.', [ft-st]) );
  SetStatusBarText(2, '');
  except
    on E: Exception do
    begin
     SetStatusBarText(2, format('Error: %s', [E.Message]) );
    end;
  end;


end;

procedure TMainForm.AddToPrevCommands(cmd: String);
begin
  if(Pos(cmd, self.prevCommands.Items.Text) = 0) then
  begin
   self.prevCommands.Items.Add(cmd);
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

procedure TMainForm.SetStatusBarText(idx: Integer; Txt: String);
var
  tmpStatusBarPanel : TStatusPanel;
begin
  tmpStatusBarPanel:= Self.StatusBar.Panels[idx];
  tmpStatusBarPanel.Text:= ' ' + Txt;
end;

function TMainForm.GetTickCount: QWORD;
 {On Windows, this is number of milliseconds since Windows was
   started. On non-Windows platforms, LCL returns number of
   milliseconds since Dec. 30, 1899, wrapped by size of DWORD.
   This value can overflow LongInt variable when checks turned on,
   so "wrap" value here so it fits within LongInt.
  Also, since same thing could happen with Windows that has been
   running for at least approx. 25 days, override it too.}
begin
  Result := 0;
  Result := GetTickCount64;
end;

function TMainForm.ConverToPACEFormat(inputStr: String): String;
Const
  DSlash = '//';
begin
 if Pos(DSlash, inputStr) <> 0 then
 begin
  Delete(inputStr,Pos(DSlash, inputStr),Length(DSlash));
 end;
 Result := '{xpath:@' + inputStr + '}';
end;



end.

