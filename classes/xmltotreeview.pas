unit XMLtoTreeView;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, ComCtrls, DOM, XPath;


type

  { TXMLConvertor }

  TXMLConvertor = class(TObject)
     constructor Create;
     function GetNodeAttributesAsString(pNode: TDOMNode): string;
     procedure ParseXML(Node:TDOMNode; TreeNode: TTreeNode; tv: TTreeView);
    private
    public
     procedure populateTreeView(DomElements: TDOMElement; tv: TTreeView);
     function XPathResultToXMLDocument(xpResult: TXPathVariable): TXMLDocument;
  end;

implementation

{ TXMLConvertor }

Uses
  Dialogs;

constructor TXMLConvertor.Create;
begin

end;

function TXMLConvertor.GetNodeAttributesAsString(pNode: TDOMNode): string;
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

procedure TXMLConvertor.ParseXML(Node: TDOMNode; TreeNode: TTreeNode; tv: TTreeView);
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

procedure TXMLConvertor.populateTreeView(DomElements: TDOMElement; tv: TTreeView);
begin
  tv.Items.Clear;
  self.ParseXML(DomElements, nil, tv);
  tv.FullExpand;

end;

function TXMLConvertor.XPathResultToXMLDocument(xpResult: TXPathVariable): TXMLDocument;
var
  xDoc : TXMLDocument;
  rootNode : TDOMNode;
  Node : TDOMNode;
  i    : Integer;
begin
  xDoc := TXMLDocument.Create;
  rootNode := xDoc.CreateElement('result');
  xDoc.AppendChild(rootNode);

  rootNode := xDoc.DocumentElement;

  for i := 0 to xpResult.AsNodeSet.Count - 1 do
    begin
    Node := TDOMNode(xpResult.AsNodeSet[i]);
    if Node.FirstChild <> nil then
      begin
       rootNode.AppendChild(Node.CloneNode(True,xDoc));
      end;
    end;


  result := xDoc;
end;

end.

