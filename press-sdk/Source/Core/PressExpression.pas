(*
  PressObjects, Expression Parser Classes
  Copyright (C) 2008 Laserpress Ltda.

  http://www.pressobjects.org

  See the file LICENSE.txt, included in this distribution,
  for details about the copyright.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*)

unit PressExpression;

{$I Press.inc}

interface

uses
{$ifndef d5down}
  Variants,
{$endif}
  Contnrs,
  PressClasses,
  PressParser;

type
  TPressExpressionValue = Variant;
  PPressExpressionValue = ^TPressExpressionValue;
  PPressExpressionValueArray = array of PPressExpressionValue;

  TPressExpressionReader = class(TPressParserReader)
  protected
    function InternalCreateBigSymbolsArray: TPressStringArray; override;
  end;

  TPressExpressionObject = class(TPressParserObject)
  end;

  TPressExpressionVar = class;
  TPressExpressionVarList = class;
  TPressExpressionItem = class;
  TPressExpressionItemClass = class of TPressExpressionItem;
  TPressExpressionOperation = class;

  TPressExpression = class(TPressExpressionObject)
  private
    FCalc: TObjectList;
    FOwnedReader: TPressExpressionReader;
    FRes: PPressExpressionValue;
    FVars: TPressExpressionVarList;
    function GetCalc: TObjectList;
    function GetVars: TPressExpressionVarList;
    function GetVarValue: Variant;
    function ParseFunction(Reader: TPressParserReader): TPressExpressionItem;
    function ParseItem(Reader: TPressParserReader): TPressExpressionItem;
    function ParseRightOperands(Reader: TPressParserReader; var ALeftItem: TPressExpressionItem; ADepth: Integer): PPressExpressionValue;
    function ParseVar(Reader: TPressParserReader): TPressExpressionItem;
  protected
    function InternalParseOperand(Reader: TPressParserReader): TPressExpressionItem; virtual;
    function InternalParseOperation(Reader: TPressParserReader): TPressExpressionOperation; virtual;
    procedure InternalRead(Reader: TPressParserReader); override;
  public
    constructor Create; overload;
    constructor Create(AExpression: string); overload;
    destructor Destroy; override;
    function ParseExpression(Reader: TPressExpressionReader): PPressExpressionValue;
    property Calc: TObjectList read GetCalc;
    property Res: PPressExpressionValue read FRes;
    property Vars: TPressExpressionVarList read GetVars;
    property VarValue: Variant read GetVarValue;
  end;

  TPressExpressionVar = class(TObject)
  private
    FName: string;
    FValue: TPressExpressionValue;
    function GetValuePtr: PPressExpressionValue;
  public
    constructor Create(const AName: string);
    property Name: string read FName;
    property Value: TPressExpressionValue read FValue write FValue;
    property ValuePtr: PPressExpressionValue read GetValuePtr;
  end;

  TPressExpressionVarList = class(TPressList)
  private
    function GetItems(AIndex: Integer): TPressExpressionVar;
    function GetVariable(const AVarName: string): TPressExpressionValue;
    procedure SetItems(AIndex: Integer; Value: TPressExpressionVar);
    procedure SetVariable(const AVarName: string; Value: TPressExpressionValue);
  public
    function IndexOf(const AVarName: string): Integer;
    function FindVar(const AVarName: string): TPressExpressionVar;
    function VarByName(const AVarName: string): TpressExpressionVar;
    property Items[AIndex: Integer]: TPressExpressionVar read GetItems write SetItems;
    property Variable[const AVarName: string]: TPressExpressionValue read GetVariable write SetVariable; default;
  end;

  TPressExpressionItem = class(TPressExpressionObject)
  private
    FNextOperation: TPressExpressionOperation;
    FRes: PPressExpressionValue;
  protected
    procedure InternalRead(Reader: TPressParserReader); override;
  public
    property NextOperation: TPressExpressionOperation read FNextOperation;
    property Res: PPressExpressionValue read FRes write FRes;
  end;

  TPressExpressionBracketItem = class(TPressExpressionItem)
  protected
    class function InternalApply(Reader: TPressParserReader): Boolean; override;
    procedure InternalRead(Reader: TPressParserReader); override;
  end;

  TPressExpressionLiteralItem = class(TPressExpressionItem)
  private
    FLiteral: TPressExpressionValue;
  protected
    class function InternalApply(Reader: TPressParserReader): Boolean; override;
    procedure InternalRead(Reader: TPressParserReader); override;
  end;

  TPressExpressionFunction = class;

  TPressExpressionFunctionItem = class(TPressExpressionItem)
  private
    FFnc: TPressExpressionFunction;
  protected
    procedure InternalRead(Reader: TPressParserReader); override;
  public
    property Fnc: TPressExpressionFunction read FFnc write FFnc;
  end;

  TPressExpressionVarItem = class(TPressExpressionItem)
  private
    FVariable: TPressExpressionVar;
  protected
    procedure InternalRead(Reader: TPressParserReader); override;
  public
    property Variable: TPressExpressionVar read FVariable write FVariable;
  end;

  TPressExpressionCalc = class(TPressExpressionObject)
  public
    procedure VarCalc; virtual; abstract;
  end;

  TPressExpressionOperationClass = class of TPressExpressionOperation;

  TPressExpressionOperation = class(TPressExpressionCalc)
  private
    FRes: TPressExpressionValue;
    FVal1: PPressExpressionValue;
    FVal2: PPressExpressionValue;
    function GetRes: PPressExpressionValue;
  protected
    class function InternalOperatorToken: string; virtual; abstract;
    procedure InternalRead(Reader: TPressParserReader); override;
  public
    function Priority: Byte; virtual; abstract;
    class function Token: string;
    property Res: PPressExpressionValue read GetRes;
    property Val1: PPressExpressionValue read FVal1 write FVal1;
    property Val2: PPressExpressionValue read FVal2 write FVal2;
  end;

  TPressExpressionFunctionClass = class of TPressExpressionFunction;

  TPressExpressionFunction = class(TPressExpressionCalc)
  private
    FParams: PPressExpressionValueArray;
    FRes: TPressExpressionValue;
    function GetRes: PPressExpressionValue;
  protected
    procedure InternalRead(Reader: TPressParserReader); override;
  public
    function MaxParams: Integer; virtual;
    function MinParams: Integer; virtual; abstract;
    class function Name: string; virtual; abstract;
    property Params: PPressExpressionValueArray read FParams write FParams;
    property Res: PPressExpressionValue read GetRes;
  end;

implementation

uses
  SysUtils,
  PressConsts,
  PressExpressionLib;

{ TPressExpressionReader }

function TPressExpressionReader.InternalCreateBigSymbolsArray: TPressStringArray;
begin
  SetLength(Result, 3);
  Result[0] := '<=';
  Result[1] := '>=';
  Result[2] := '<>';
end;

{ TPressExpression }

destructor TPressExpression.Destroy;
begin
  FVars.Free;
  FCalc.Free;
  FOwnedReader.Free;
  inherited;
end;

function TPressExpression.GetCalc: TObjectList;
begin
  if not Assigned(FCalc) then
    FCalc := TObjectList.Create(False);
  Result := FCalc;
end;

function TPressExpression.GetVars: TPressExpressionVarList;
begin
  if not Assigned(FVars) then
    FVars := TPressExpressionVarList.Create(True);
  Result := FVars;
end;

function TPressExpression.GetVarValue: Variant;
var
  I: Integer;
begin
  if not Assigned(FRes) and Assigned(FOwnedReader) then
    ParseExpression(FOwnedReader);
  if Assigned(FRes) then
  begin
    if Assigned(FCalc) then
      for I := 0 to Pred(FCalc.Count) do
        TPressExpressionCalc(FCalc[I]).VarCalc;
    Result := FRes^;
  end else
    Result := varEmpty;
end;

function TPressExpression.InternalParseOperand(
  Reader: TPressParserReader): TPressExpressionItem;
begin
  Result := TPressExpressionItem(Parse(Reader, [
   TPressExpressionBracketItem, TPressExpressionLiteralItem]));
  if not Assigned(Result) then
  begin
    Result := ParseFunction(Reader);
    if not Assigned(Result) then
      Result := ParseVar(Reader);
  end;
end;

function TPressExpression.InternalParseOperation(
  Reader: TPressParserReader): TPressExpressionOperation;
var
  VOperationClass: TPressExpressionOperationClass;
begin
  VOperationClass :=
   PressExpressionLibrary.FindOperationClass(Reader.ReadNextToken);
  if Assigned(VOperationClass) then
    Result := TPressExpressionOperation(Parse(Reader, [VOperationClass]))
  else
    Result := nil;
end;

procedure TPressExpression.InternalRead(Reader: TPressParserReader);
begin
  inherited;
  ParseExpression(Reader as TPressExpressionReader);
  Reader.ReadMatchEof;
end;

constructor TPressExpression.Create;
begin
  inherited Create(nil);
end;

constructor TPressExpression.Create(AExpression: string);
begin
  inherited Create(nil);
  FOwnedReader := TPressExpressionReader.Create(AExpression);
end;

function TPressExpression.ParseExpression(
  Reader: TPressExpressionReader): PPressExpressionValue;
var
  VItem: TPressExpressionItem;
begin
  VItem := ParseItem(Reader);
  FRes := ParseRightOperands(Reader, VItem, 0);
  Result := FRes;
end;

function TPressExpression.ParseFunction(
  Reader: TPressParserReader): TPressExpressionItem;
var
  VFunctionParser: TPressExpressionFunctionItem;
  VFunctionClass: TPressExpressionFunctionClass;
  VFunction: TPressExpressionFunction;
  VPosition: TPressTextPos;
  VIsFunction: Boolean;
  Token: string;
begin
  Result := nil;
  VPosition := Reader.Position;
  Token := Reader.ReadToken;
  VIsFunction :=
   IsValidIdent(Token) and not Reader.Eof and (Reader.ReadChar = '(');
  Reader.Position := VPosition;
  if VIsFunction then
  begin
    VFunctionClass := PressExpressionLibrary.FindFunctionClass(Token);
    if not Assigned(VFunctionClass) then
      Exit;
    VFunctionParser := TPressExpressionFunctionItem.Create(Self);
    VFunction := VFunctionClass.Create(Self);
    VFunctionParser.Fnc := VFunction;
    VFunctionParser.Read(Reader);
    Calc.Add(VFunction);
    Result := VFunctionParser;
  end;
end;

function TPressExpression.ParseItem(
  Reader: TPressParserReader): TPressExpressionItem;
begin
  Result := InternalParseOperand(Reader);
  if not Assigned(Result) then
    Reader.ErrorExpected(SPressIdentifierMsg, Reader.ReadToken);
  Result.FNextOperation := InternalParseOperation(Reader);
end;

function TPressExpression.ParseRightOperands(Reader: TPressParserReader;
  var ALeftItem: TPressExpressionItem; ADepth: Integer): PPressExpressionValue;
var
  VRightItem: TPressExpressionItem;
  VCurrentOp, VNextOp: TPressExpressionOperation;
  VLeftOperand: PPressExpressionValue;
begin
  VLeftOperand := ALeftItem.Res;
  VCurrentOp := ALeftItem.NextOperation;
  while Assigned(VCurrentOp) do
  begin
    VRightItem := ParseItem(Reader);
    VNextOp := VRightItem.NextOperation;
    VCurrentOp.Val1 := VLeftOperand;
    if Assigned(VNextOp) and (VCurrentOp.Priority < VNextOp.Priority) then
      VCurrentOp.Val2 := ParseRightOperands(Reader, VRightItem, Succ(ADepth))
    else
      VCurrentOp.Val2 := VRightItem.Res;
    VLeftOperand := VCurrentOp.Res;
    Calc.Add(VCurrentOp);
    ALeftItem := VRightItem;
    if (ADepth = 0) or (Assigned(ALeftItem.NextOperation) and
     (VCurrentOp.Priority = ALeftItem.NextOperation.Priority)) then
      VCurrentOp := ALeftItem.NextOperation
    else
      VCurrentOp := nil;
  end;
  Result := VLeftOperand;
end;

function TPressExpression.ParseVar(
  Reader: TPressParserReader): TPressExpressionItem;
var
  VVar: TPressExpressionVar;
  VVarParser: TPressExpressionVarItem;
begin
  Result := nil;
  VVar := Vars.FindVar(Reader.ReadNextToken);
  if not Assigned(VVar) then
    Exit;
  VVarParser := TPressExpressionVarItem.Create(Self);
  VVarParser.Variable := VVar;
  VVarParser.Read(Reader);
  Result := VVarParser;
end;

{ TPressExpressionVar }

constructor TPressExpressionVar.Create(const AName: string);
begin
  if not IsValidIdent(AName) then
    raise EPressError.CreateFmt(SInvalidIdentifier, [AName]);
  inherited Create;
  FName := AName;
end;

function TPressExpressionVar.GetValuePtr: PPressExpressionValue;
begin
  Result := @FValue;
end;

{ TPressExpressionVarList }

function TPressExpressionVarList.FindVar(
  const AVarName: string): TPressExpressionVar;
var
  VIndex: Integer;
begin
  VIndex := IndexOf(AVarName);
  if VIndex >= 0 then
    Result := Items[VIndex]
  else
    Result := nil;
end;

function TPressExpressionVarList.GetItems(AIndex: Integer): TPressExpressionVar;
begin
  Result := inherited Items[AIndex] as TPressExpressionVar;
end;

function TPressExpressionVarList.GetVariable(
  const AVarName: string): TPressExpressionValue;
begin
  Result := VarByName(AVarName).Value;
end;

function TPressExpressionVarList.IndexOf(const AVarName: string): Integer;
begin
  for Result := 0 to Pred(Count) do
    if SameText(AVarName, Items[Result].Name) then
      Exit;
  Result := -1;
end;

procedure TPressExpressionVarList.SetItems(
  AIndex: Integer; Value: TPressExpressionVar);
begin
  inherited Items[AIndex] := Value;
end;

procedure TPressExpressionVarList.SetVariable(
  const AVarName: string; Value: TPressExpressionValue);
begin
  VarByName(AVarName).Value := Value;
end;

function TPressExpressionVarList.VarByName(
  const AVarName: string): TpressExpressionVar;
begin
  Result := FindVar(AVarName);
  if not Assigned(Result) then
    Result := Items[inherited Add(TPressExpressionVar.Create(AVarName))];
end;

{ TPressExpressionItem }

procedure TPressExpressionItem.InternalRead(Reader: TPressParserReader);
begin
  inherited;
end;

{ TPressExpressionBracketItem }

class function TPressExpressionBracketItem.InternalApply(
  Reader: TPressParserReader): Boolean;
begin
  Result := Reader.ReadToken = '(';
end;

procedure TPressExpressionBracketItem.InternalRead(
  Reader: TPressParserReader);
begin
  inherited;
  Reader.ReadMatch('(');
  Res := (Owner as TPressExpression).ParseExpression(Reader as TPressExpressionReader);
  Reader.ReadMatch(')');
end;

{ TPressExpressionLiteralItem }

class function TPressExpressionLiteralItem.InternalApply(
  Reader: TPressParserReader): Boolean;
var
  Token: string;
begin
  Token := Reader.ReadToken;
  Result := (Token <> '') and (Token[1] in ['''', '"', '+', '-', '0'..'9']);
end;

procedure TPressExpressionLiteralItem.InternalRead(
  Reader: TPressParserReader);

  function AsFloat(const AStr: string): Double;
  var
    VErr: Integer;
  begin
    Val(AStr, Result, VErr);
    if VErr <> 0 then
      Reader.ErrorExpected(SPressNumberValueMsg, AStr);
  end;

var
  Token: string;
begin
  inherited;
  Token := Reader.ReadNextToken;
  if (Token <> '') and (Token[1] in ['''', '"']) then
    FLiteral := Reader.ReadUnquotedString
  else if Pos('.', Token) > 0 then
    FLiteral := AsFloat(Reader.ReadNumber)
  else
    FLiteral := Reader.ReadInteger;
  Res := @FLiteral;
end;

{ TPressExpressionFunctionItem }

procedure TPressExpressionFunctionItem.InternalRead(
  Reader: TPressParserReader);
const
  CDelta = 4;
var
  VParams: PPressExpressionValueArray;
  VMin, VMax, I: Integer;
begin
  inherited;
  Reader.ReadMatchText(Fnc.Name);
  Reader.ReadMatch('(');
  VMin := Fnc.MinParams;
  VMax := Fnc.MaxParams;
  I := 0;
  SetLength(VParams, CDelta);
  while (I <> VMax) and ((I < VMin) or (Reader.ReadNextToken <> ')')) do
  begin
    if I > 0 then
      Reader.ReadMatch(',');
    if Length(VParams) = I then
      SetLength(VParams, I + CDelta);
    VParams[I] := (Owner as TPressExpression).ParseExpression(
     Reader as TPressExpressionReader);
    Inc(I);
  end;
  Reader.ReadMatch(')');
  SetLength(VParams, I);
  Fnc.Params := VParams;
  Res := Fnc.Res;
end;

{ TPressExpressionVarItem }

procedure TPressExpressionVarItem.InternalRead(Reader: TPressParserReader);
begin
  inherited;
  Reader.ReadMatchText(Variable.Name);
  Res := Variable.ValuePtr;
end;

{ TPressExpressionOperation }

function TPressExpressionOperation.GetRes: PPressExpressionValue;
begin
  Result := @FRes;
end;

procedure TPressExpressionOperation.InternalRead(Reader: TPressParserReader);
begin
  inherited;
  Reader.ReadMatchText(InternalOperatorToken);
end;

class function TPressExpressionOperation.Token: string;
begin
  Result := InternalOperatorToken;
end;

{ TPressExpressionFunction }

function TPressExpressionFunction.GetRes: PPressExpressionValue;
begin
  Result := @FRes;
end;

procedure TPressExpressionFunction.InternalRead(
  Reader: TPressParserReader);
begin
  inherited;
end;

function TPressExpressionFunction.MaxParams: Integer;
begin
  Result := -1;
end;

end.
