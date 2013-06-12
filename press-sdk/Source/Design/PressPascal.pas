(*
  PressObjects, Pascal Parser
  Copyright (C) 2006-2007 Laserpress Ltda.

  http://www.pressobjects.org

  See the file LICENSE.txt, included in this distribution,
  for details about the copyright.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*)

unit PressPascal;

{$I Press.inc}

interface

uses
  Contnrs,
  PressClasses,
  PressParser;

type
  TPressPascalReader = class(TPressParserReader)
  protected
    procedure InternalCheckComment(var AToken: string); override;
    function InternalCreateBigSymbolsArray: TPressStringArray; override;
  public
    function ReadConcatString: string;
  end;

  TPressPascalObjectClass = class of TPressPascalObject;

  TPressPascalObject = class(TPressParserObject)
  private
    FStartPos: TPressTextPos;
  protected
    class function Identifier: string; virtual;
    class function InternalApply(Reader: TPressParserReader): Boolean; override;
    class function InternalApplyIdentifier(Reader: TPressParserReader): Boolean; virtual;
    procedure InternalRead(Reader: TPressParserReader); override;
    function IsFinished(Reader: TPressParserReader): Boolean; virtual;
  public
    property StartPos: TPressTextPos read FStartPos;
  end;

  TPressPascalInterfaceSection = class;
  TPressPascalImplementationSection = class;
  TPressPascalInitializationSection = class;

  TPressPascalUnit = class(TPressPascalObject)
  private
    FInterface: TPressPascalInterfaceSection;
    FImplementation: TPressPascalImplementationSection;
    FInitialization: TPressPascalInitializationSection;
  protected
    procedure InternalRead(Reader: TPressParserReader); override;
  public
    property InterfaceSection: TPressPascalInterfaceSection read FInterface;
    property ImplementationSection: TPressPascalImplementationSection read FImplementation;
    property InitializationSection: TPressPascalInitializationSection read FInitialization;
  end;

  TPressPascalSection = class(TPressPascalObject)
  protected
    procedure InternalRead(Reader: TPressParserReader); override;
    function IsFinished(Reader: TPressParserReader): Boolean; override;
    class function NextSection: TPressPascalObjectClass; virtual; abstract;
  end;

  TPressPascalUsesDeclaration = class;

  TPressPascalDeclarationSection = class(TPressPascalSection)
  private
    FUses: TPressPascalUsesDeclaration;
  protected
    procedure InternalRead(Reader: TPressParserReader); override;
  public
    property UsesDeclaration: TPressPascalUsesDeclaration read FUses;
  end;

  TPressPascalBlockSection = class(TPressPascalSection)
  protected
    procedure InternalRead(Reader: TPressParserReader); override;
  end;

  TPressPascalInterfaceSection = class(TPressPascalDeclarationSection)
  protected
    class function Identifier: string; override;
    class function NextSection: TPressPascalObjectClass; override;
  end;

  TPressPascalImplementationSection = class(TPressPascalDeclarationSection)
  protected
    class function Identifier: string; override;
    class function NextSection: TPressPascalObjectClass; override;
  end;

  TPressPascalInitializationSection = class(TPressPascalBlockSection)
  protected
    class function Identifier: string; override;
    class function NextSection: TPressPascalObjectClass; override;
  end;

  TPressPascalFinalizationSection = class(TPressPascalBlockSection)
  protected
    class function Identifier: string; override;
    class function NextSection: TPressPascalObjectClass; override;
  end;

  TPressPascalDeclaration = class(TPressPascalObject)
  protected
    procedure InternalRead(Reader: TPressParserReader); override;
    function IsFinished(Reader: TPressParserReader): Boolean; override;
  end;

  TPressPascalUsedUnit = class;

  TPressPascalUsesDeclaration = class(TPressPascalDeclaration)
  private
    FUsedUnits: TObjectList;
    function GetUsedUnits: TObjectList;
    function GetUsedUnit(AIndex: Integer): TPressPascalUsedUnit;
  protected
    class function Identifier: string; override;
    procedure InternalRead(Reader: TPressParserReader); override;
    property UsedUnits: TObjectList read GetUsedUnits;
  public
    destructor Destroy; override;
    function UsedUnitCount: Integer;
    property UsedUnit[AIndex: Integer]: TPressPascalUsedUnit read GetUsedUnit;
  end;

  TPressPascalUsedUnit = class(TObject)
  private
    FUnitName: string;
    FUnitPath: string;
  public
    constructor Create(const AUnitName, AUnitPath: string);
    property UnitName: string read FUnitName;
    property UnitPath: string read FUnitPath;
  end;

  TPressPascalConstsDeclaration = class(TPressPascalDeclaration)
  protected
    class function Identifier: string; override;
    procedure InternalRead(Reader: TPressParserReader); override;
  end;

  TPressPascalResStringsDeclaration = class(TPressPascalConstsDeclaration)
  protected
    class function Identifier: string; override;
  end;

  TPressPascalTypesDeclaration = class(TPressPascalDeclaration)
  protected
    class function Identifier: string; override;
    procedure InternalRead(Reader: TPressParserReader); override;
  end;

  TPressPascalVarsDeclaration = class(TPressPascalDeclaration)
  protected
    class function Identifier: string; override;
    procedure InternalRead(Reader: TPressParserReader); override;
  end;

  TPressPascalProcHeader = class;
  TPressPascalProcBody = class;

  TPressPascalProcDeclaration = class(TPressPascalDeclaration)
  private
    FBody: TPressPascalProcBody;
    FHeader: TPressPascalProcHeader;
    function NeedBody: Boolean;
  protected
    class function InternalApply(Reader: TPressParserReader): Boolean; override;
    procedure InternalRead(Reader: TPressParserReader); override;
  public
    property Body: TPressPascalProcBody read FBody;
    property Header: TPressPascalProcHeader read FHeader;
  end;

  TPressPascalProcDirective = (pdVirtual, pdDynamic, pdAbstract, pdOverride,
   pdReintroduce, pdOverload, pdRegister, pdPascal, pdCdecl, pdStdcall,
   pdSafecall, pdForward);

  TPressPascalProcDirectives = set of TPressPascalProcDirective;

  TPressPascalProcHeader = class(TPressPascalObject)
  private
    FDirectives: TPressPascalProcDirectives;
    FName: string;
    function GetClassTypeName: string;
    function GetClassMethodName: string;
    function GetProcName: string;
  protected
    class function InternalApply(Reader: TPressParserReader): Boolean; override;
    class function InternalApplyIdentifier(Reader: TPressParserReader): Boolean; override;
    procedure InternalRead(Reader: TPressParserReader); override;
    procedure ReadDirectives(Reader: TPressParserReader);
  public
    property ClassTypeName: string read GetClassTypeName;
    property ClassMethodName: string read GetClassMethodName;
    property Directives: TPressPascalProcDirectives read FDirectives;
    property ProcName: string read GetProcName;
  end;

  TPressPascalBlockStatement = class;

  TPressPascalProcBody = class(TPressPascalObject)
  private
    FBlock: TPressPascalBlockStatement;
  protected
    class function InternalApply(Reader: TPressParserReader): Boolean; override;
    procedure InternalRead(Reader: TPressParserReader); override;
  public
    property Block: TPressPascalBlockStatement read FBlock;
  end;

  TPressPascalType = class(TPressPascalObject)
  private
    FName: string;
  protected
    class function InternalApply(Reader: TPressParserReader): Boolean; override;
    procedure InternalRead(Reader: TPressParserReader); override;
  public
    property Name: string read FName;
  end;

  TPressPascalClassType = class(TPressPascalType)
  private
    FParentName: string;
  protected
    class function Identifier: string; override;
    class function InternalApply(Reader: TPressParserReader): Boolean; override;
    procedure InternalRead(Reader: TPressParserReader); override;
  public
    property ParentName: string read FParentName;
  end;

  TPressPascalInterfaceType = class(TPressPascalType)
  protected
    class function Identifier: string; override;
    class function InternalApply(Reader: TPressParserReader): Boolean; override;
    procedure InternalRead(Reader: TPressParserReader); override;
  end;

  TPressPascalDispInterfaceType = class(TPressPascalInterfaceType)
  protected
    class function Identifier: string; override;
  end;

  TPressPascalRecordType = class(TPressPascalType)
  protected
    class function Identifier: string; override;
    class function InternalApplyIdentifier(Reader: TPressParserReader): Boolean; override;
    procedure InternalRead(Reader: TPressParserReader); override;
  end;

  TPressPascalProcType = class(TPressPascalType)
  protected
    class function InternalApplyIdentifier(Reader: TPressParserReader): Boolean; override;
    procedure InternalRead(Reader: TPressParserReader); override;
  end;

  TPressPascalUnknownType = class(TPressPascalType)
  protected
    class function InternalApply(Reader: TPressParserReader): Boolean; override;
    procedure InternalRead(Reader: TPressParserReader); override;
  end;

  TPressPascalStatement = class(TPressPascalObject)
  protected
    procedure InternalRead(Reader: TPressParserReader); override;
  end;

  TPressPascalPlainStatement = class(TPressPascalStatement)
  private
    FStatementStr: string;
  protected
    class function InternalApply(Reader: TPressParserReader): Boolean; override;
    procedure InternalRead(Reader: TPressParserReader); override;
  public
    property StatementStr: string read FStatementStr;
  end;

  TPressPascalBlockStatement = class(TPressPascalStatement)
  private
    FBlockType: string;
  protected
    class function Identifier: string; override;
    class function InternalApplyIdentifier(Reader: TPressParserReader): Boolean; override;
    procedure InternalRead(Reader: TPressParserReader); override;
  end;

implementation

uses
  SysUtils,
  TypInfo,
  PressConsts,
  PressDesignConsts;

{ TPressPascalReader }

procedure TPressPascalReader.InternalCheckComment(var AToken: string);
begin
  inherited;
  if AToken = '(*' then
  begin
    repeat
      while ReadChar <> '*' do ;
    until NextChar = ')';
    ReadChar;
  end else if AToken = '{' then
    while ReadChar <> '}' do
  else if AToken = '//' then
    while ReadChar <> #10 do
  else
    Exit;
  AToken := ReadToken;
end;

function TPressPascalReader.InternalCreateBigSymbolsArray: TPressStringArray;
begin
  SetLength(Result, 7);
  Result[0] := ':=';
  Result[1] := '<=';
  Result[2] := '>=';
  Result[3] := '<>';
  Result[4] := '(*';
  Result[5] := '*)';
  Result[6] := '//';
end;

function TPressPascalReader.ReadConcatString: string;

  function ReadStrings(ASeparator: Char): string;
  begin
    Result := ReadUnquotedString;
    SkipSpaces;
    while ReadChar = ASeparator do
    begin
      Result := Result + ReadUnquotedString;
      SkipSpaces;
    end;
    UnreadChar;
  end;

var
  NextToken: string;
begin
  NextToken := ReadNextToken;
  if SameText(NextToken, 'concat') then
  begin
    ReadToken;
    ReadMatch('(');
    Result := ReadStrings(',');
    ReadMatch(')');
  end else if (Length(NextToken) > 0) and IsStringDelimiter(NextToken[1]) then
  begin
    Result := ReadStrings('+');
  end else
    ErrorExpected(SPressStringConstMsg, NextToken);
end;

{ TPressPascalObject }

class function TPressPascalObject.Identifier: string;
begin
  Result := '';
end;

class function TPressPascalObject.InternalApply(
  Reader: TPressParserReader): Boolean;
begin
  Result := InternalApplyIdentifier(Reader);
end;

class function TPressPascalObject.InternalApplyIdentifier(
  Reader: TPressParserReader): Boolean;
begin
  Result := (Identifier <> '') and SameText(Reader.ReadToken, Identifier);
end;

procedure TPressPascalObject.InternalRead(Reader: TPressParserReader);
begin
  inherited;
  FStartPos := Reader.Position;
end;

function TPressPascalObject.IsFinished(Reader: TPressParserReader): Boolean;
begin
  Result := False;
end;

{ TPressPascalUnit }

procedure TPressPascalUnit.InternalRead(Reader: TPressParserReader);
begin
  inherited;
  Reader.ReadMatchText('unit');
  Reader.ReadIdentifier;
  Reader.ReadMatch(';');
  FInterface := TPressPascalInterfaceSection(Parse(Reader, [
   TPressPascalInterfaceSection],
   Self, True, TPressPascalInterfaceSection.Identifier));
  FImplementation := TPressPascalImplementationSection(Parse(Reader, [
   TPressPascalImplementationSection],
   Self, True, TPressPascalImplementationSection.Identifier));
  FInitialization := TPressPascalInitializationSection(Parse(Reader, [
   TPressPascalInitializationSection]));
  Parse(Reader, [TPressPascalFinalizationSection]);
  Reader.ReadMatchText('end');
  Reader.ReadMatch('.');
  Reader.ReadMatchEof;
end;

{ TPressPascalSection }

procedure TPressPascalSection.InternalRead(Reader: TPressParserReader);
begin
  inherited;
  Reader.ReadMatchText(Identifier);
end;

function TPressPascalSection.IsFinished(Reader: TPressParserReader): Boolean;
var
  Token: string;
begin
  Token := Reader.ReadNextToken;
  Result := SameText(Token, 'end') or
   ((NextSection <> nil) and SameText(Token, NextSection.Identifier));
end;

{ TPressPascalDeclarationSection }

procedure TPressPascalDeclarationSection.InternalRead(
  Reader: TPressParserReader);
begin
  inherited;
  FUses := TPressPascalUsesDeclaration(Parse(Reader, [
   TPressPascalUsesDeclaration]));
  while not IsFinished(Reader) do
    Parse(Reader, [TPressPascalConstsDeclaration,
     TPressPascalResStringsDeclaration, TPressPascalTypesDeclaration,
     TPressPascalVarsDeclaration, TPressPascalProcDeclaration],
     Self, True, NextSection.Identifier);
end;

{ TPressPascalBlockSection }

procedure TPressPascalBlockSection.InternalRead(
  Reader: TPressParserReader);
begin
  inherited;
  repeat
  until Parse(Reader, [
   TPressPascalBlockStatement, TPressPascalPlainStatement]) = nil;
end;

{ TPressPascalInterfaceSection }

class function TPressPascalInterfaceSection.Identifier: string;
begin
  Result := 'interface';
end;

class function TPressPascalInterfaceSection.NextSection: TPressPascalObjectClass;
begin
  Result := TPressPascalImplementationSection;
end;

{ TPressPascalImplementationSection }

class function TPressPascalImplementationSection.Identifier: string;
begin
  Result := 'implementation';
end;

class function TPressPascalImplementationSection.NextSection: TPressPascalObjectClass;
begin
  Result := TPressPascalInitializationSection;
end;

{ TPressPascalInitializationSection }

class function TPressPascalInitializationSection.Identifier: string;
begin
  Result := 'initialization';
end;

class function TPressPascalInitializationSection.NextSection: TPressPascalObjectClass;
begin
  Result := TPressPascalFinalizationSection;
end;

{ TPressPascalFinalizationSection }

class function TPressPascalFinalizationSection.Identifier: string;
begin
  Result := 'finalization';
end;

class function TPressPascalFinalizationSection.NextSection: TPressPascalObjectClass;
begin
  Result := nil;
end;

{ TPressPascalDeclaration }

procedure TPressPascalDeclaration.InternalRead(Reader: TPressParserReader);
begin
  inherited;
  Reader.ReadMatchText(Identifier);
end;

function TPressPascalDeclaration.IsFinished(
  Reader: TPressParserReader): Boolean;

  function IsNewArea: Boolean;
  var
    Token: string;
  begin
    Token := Reader.ReadNextToken;

    { TODO : Improve }
    Result := SameText(Token, 'const') or SameText(Token, 'type') or
     SameText(Token, 'var') or SameText(Token, 'resourcestring') or
     SameText(Token, 'implementation') or SameText(Token, 'initialization') or
     SameText(Token, 'begin');

  end;

begin
  Result := TPressPascalUsesDeclaration.Apply(Reader) or
   TPressPascalProcDeclaration.Apply(Reader) or IsNewArea;
end;

{ TPressPascalUsesDeclaration }

destructor TPressPascalUsesDeclaration.Destroy;
begin
  FUsedUnits.Free;
  inherited;
end;

function TPressPascalUsesDeclaration.GetUsedUnit(
  AIndex: Integer): TPressPascalUsedUnit;
begin
  Result := UsedUnits[AIndex] as TPressPascalUsedUnit;
end;

function TPressPascalUsesDeclaration.GetUsedUnits: TObjectList;
begin
  if not Assigned(FUsedUnits) then
    FUsedUnits := TObjectList.Create(True);
  Result := FUsedUnits;
end;

class function TPressPascalUsesDeclaration.Identifier: string;
begin
  Result := 'uses';
end;

procedure TPressPascalUsesDeclaration.InternalRead(
  Reader: TPressParserReader);
var
  VUnitName, VUnitPath: string;
begin
  inherited;
  while True do
  begin
    VUnitName := Reader.ReadIdentifier;
    if not SameText(Reader.ReadToken, 'in') then
    begin
      VUnitPath := '';
      Reader.UnreadToken;
    end else
      VUnitPath := Reader.ReadUnquotedString;
    UsedUnits.Add(TPressPascalUsedUnit.Create(VUnitName, VUnitPath));
    if Reader.ReadNextToken <> ',' then
    begin
      Reader.ReadMatch(';');
      Exit;
    end else
      Reader.ReadToken;
  end;
end;

function TPressPascalUsesDeclaration.UsedUnitCount: Integer;
begin
  if Assigned(FUsedUnits) then
    Result := FUsedUnits.Count
  else
    Result := 0;
end;

{ TPressPascalUsedUnit }

constructor TPressPascalUsedUnit.Create(const AUnitName,
  AUnitPath: string);
begin
  inherited Create;
  FUnitName := AUnitName;
  FUnitPath := AUnitPath;
end;

{ TPressPascalConstsDeclaration }

class function TPressPascalConstsDeclaration.Identifier: string;
begin
  Result := 'const';
end;

procedure TPressPascalConstsDeclaration.InternalRead(
  Reader: TPressParserReader);
begin
  inherited;
  while not IsFinished(Reader) do
    Reader.ReadNext(';', True);
end;

{ TPressPascalResStringsDeclaration }

class function TPressPascalResStringsDeclaration.Identifier: string;
begin
  Result := 'resourcestring';
end;

{ TPressPascalTypesDeclaration }

class function TPressPascalTypesDeclaration.Identifier: string;
begin
  Result := 'type';
end;

procedure TPressPascalTypesDeclaration.InternalRead(
  Reader: TPressParserReader);
begin
  inherited;
  while not IsFinished(Reader) do
    Parse(Reader, [TPressPascalClassType, TPressPascalInterfaceType,
     TPressPascalDispInterfaceType, TPressPascalRecordType,
     TPressPascalProcType, TPressPascalUnknownType],
     Self, True, SPressDataTypeDeclarationMsg);
end;

{ TPressPascalVarsDeclaration }

class function TPressPascalVarsDeclaration.Identifier: string;
begin
  Result := 'var';
end;

procedure TPressPascalVarsDeclaration.InternalRead(
  Reader: TPressParserReader);
begin
  inherited;
  while not IsFinished(Reader) do
    Reader.ReadNext(';', True);
end;

{ TPressPascalProcDeclaration }

class function TPressPascalProcDeclaration.InternalApply(
  Reader: TPressParserReader): Boolean;
begin
  Result := TPressPascalProcHeader.InternalApply(Reader);
end;

procedure TPressPascalProcDeclaration.InternalRead(
  Reader: TPressParserReader);
begin
  FHeader := TPressPascalProcHeader(Parse(Reader, [
   TPressPascalProcHeader], Self, True, SPressProcMethodDeclMsg));
  if NeedBody then
    FBody := TPressPascalProcBody(Parse(Reader, [
     TPressPascalProcBody], Self, True, 'begin'));
end;

function TPressPascalProcDeclaration.NeedBody: Boolean;
begin
  Result := ((Owner is TPressPascalImplementationSection) or
   not (Owner is TPressPascalSection)) and
   Assigned(FHeader) and not (pdForward in FHeader.Directives);
end;

{ TPressPascalProcHeader }

function TPressPascalProcHeader.GetClassTypeName: string;
var
  VPos: Integer;
begin
  VPos := Pos('.', FName);
  if VPos > 0 then
    Result := Copy(FName, 1, VPos - 1)
  else
    Result := '';
end;

function TPressPascalProcHeader.GetClassMethodName: string;
var
  VPos: Integer;
begin
  VPos := Pos('.', FName);
  if VPos > 0 then
    Result := Copy(FName, VPos + 1, Length(FName) - VPos)
  else
    Result := '';
end;

function TPressPascalProcHeader.GetProcName: string;
begin
  if Pos('.', FName) = 0 then
    Result := FName
  else
    Result := '';
end;

class function TPressPascalProcHeader.InternalApply(
  Reader: TPressParserReader): Boolean;
begin
  if SameText(Reader.ReadNextToken, 'class') then
    Reader.ReadToken;
  Result := inherited InternalApply(Reader);
end;

class function TPressPascalProcHeader.InternalApplyIdentifier(
  Reader: TPressParserReader): Boolean;
var
  Token: string;
begin
  Token := Reader.ReadToken;
  Result := SameText(Token, 'procedure') or SameText(Token, 'function') or
   SameText(Token, 'constructor') or SameText(Token, 'destructor');
end;

procedure TPressPascalProcHeader.InternalRead(Reader: TPressParserReader);
begin
  inherited;
  if SameText(Reader.ReadToken, 'class') then
    Reader.ReadToken;
  FName := Reader.ReadIdentifier;
  if Reader.NextChar = '.' then
  begin
    Reader.ReadChar;
    FName := FName + '.' + Reader.ReadIdentifier;
  end;
  Reader.SkipSpaces;
  if Reader.NextChar = '(' then
    Reader.ReadNext(')', True);
  Reader.ReadNext(';', True);
  ReadDirectives(Reader);
end;

procedure TPressPascalProcHeader.ReadDirectives(Reader: TPressParserReader);
const
  CPrefix = 'pd';
var
  Token: string;
  VIndex: Integer;
begin
  repeat
    Token := LowerCase(Reader.ReadNextToken);
    if Token = '' then
      Exit;
    Token[1] := UpCase(Token[1]);
    Token := CPrefix + Token;
    VIndex := GetEnumValue(TypeInfo(TPressPascalProcDirective), Token);
    if VIndex >= 0 then
    begin
      FDirectives := FDirectives + [TPressPascalProcDirective(VIndex)];
      Reader.ReadToken;
      Reader.ReadMatch(';');
    end;
  until VIndex = -1;
end;

{ TPressPascalProcBody }

class function TPressPascalProcBody.InternalApply(
  Reader: TPressParserReader): Boolean;
begin
  Result := True;
end;

procedure TPressPascalProcBody.InternalRead(Reader: TPressParserReader);
begin
  inherited;
  repeat
  until Parse(Reader, [
   TPressPascalConstsDeclaration, TPressPascalResStringsDeclaration,
   TPressPascalTypesDeclaration, TPressPascalVarsDeclaration,
   TPressPascalProcDeclaration]) = nil;
  FBlock := TPressPascalBlockStatement(Parse(Reader, [
   TPressPascalBlockStatement], Self, True, 'begin'));
end;

{ TPressPascalType }

class function TPressPascalType.InternalApply(
  Reader: TPressParserReader): Boolean;
begin
  Result := IsValidIdent(Reader.ReadToken) and
   (Reader.ReadToken = '=') and InternalApplyIdentifier(Reader);
end;

procedure TPressPascalType.InternalRead(Reader: TPressParserReader);
begin
  inherited;
  FName := Reader.ReadIdentifier;
  Reader.ReadMatch('=');
end;

{ TPressPascalClassType }

class function TPressPascalClassType.Identifier: string;
begin
  Result := 'class';
end;

class function TPressPascalClassType.InternalApply(
  Reader: TPressParserReader): Boolean;
var
  Token: string;
begin
  Result := inherited InternalApply(Reader);
  if Result then
  begin
    Token := Reader.ReadToken;
    Result := (Token <> ';') and not SameText(Token, 'of');
  end;
end;

procedure TPressPascalClassType.InternalRead(Reader: TPressParserReader);
begin
  inherited;
  Reader.ReadToken;
  if Reader.ReadToken = '(' then
  begin
    FParentName := Reader.ReadIdentifier;
    Reader.ReadNext(')', True);
  end else
    Reader.UnreadToken;
  if Reader.ReadToken <> ';' then
  begin
    Reader.UnreadToken;
    Reader.ReadNext('end', True);
    Reader.ReadMatch(';');
  end;
end;

{ TPressPascalInterfaceType }

class function TPressPascalInterfaceType.Identifier: string;
begin
  Result := 'interface';
end;

class function TPressPascalInterfaceType.InternalApply(
  Reader: TPressParserReader): Boolean;
begin
  Result := inherited InternalApply(Reader) and (Reader.ReadToken <> ';');
end;

procedure TPressPascalInterfaceType.InternalRead(
  Reader: TPressParserReader);
begin
  inherited;
  Reader.ReadNext('end', True);
  Reader.ReadMatch(';');
end;

{ TPressPascalDispInterfaceType }

class function TPressPascalDispInterfaceType.Identifier: string;
begin
  Result := 'dispinterface';
end;

{ TPressPascalRecordType }

class function TPressPascalRecordType.Identifier: string;
begin
  Result := 'record';
end;

class function TPressPascalRecordType.InternalApplyIdentifier(
  Reader: TPressParserReader): Boolean;
begin
  if SameText(Reader.ReadNextToken, 'packed') then
    Reader.ReadToken;
  Result := inherited InternalApplyIdentifier(Reader);
end;

procedure TPressPascalRecordType.InternalRead(Reader: TPressParserReader);
begin
  inherited;
  Reader.ReadNext('end', True);
  Reader.ReadMatch(';');
end;

{ TPressPascalProcType }

class function TPressPascalProcType.InternalApplyIdentifier(
  Reader: TPressParserReader): Boolean;
var
  Token: string;
begin
  Token := Reader.ReadToken;
  Result := SameText(Token, 'procedure') or SameText(Token, 'function');
end;

procedure TPressPascalProcType.InternalRead(Reader: TPressParserReader);
begin
  inherited;
  Reader.ReadToken;
  if Reader.ReadToken = '(' then
    Reader.ReadNext(')', True);
  Reader.ReadNext(';', True);
end;

{ TPressPascalUnknownType }

class function TPressPascalUnknownType.InternalApply(
  Reader: TPressParserReader): Boolean;
begin
  Result := True;
end;

procedure TPressPascalUnknownType.InternalRead(Reader: TPressParserReader);
begin
  inherited;
  Reader.ReadNext(';', True);
end;

{ TPressPascalStatement }

procedure TPressPascalStatement.InternalRead(Reader: TPressParserReader);
begin
  inherited;
end;

{ TPressPascalPlainStatement }

class function TPressPascalPlainStatement.InternalApply(
  Reader: TPressParserReader): Boolean;
begin
  Result := not SameText(Reader.ReadToken, 'end') and
   not SameText(Reader.ReadToken, 'finalization'); 
end;

procedure TPressPascalPlainStatement.InternalRead(
  Reader: TPressParserReader);
begin
  inherited;
  FStatementStr := Reader.ReadNext([
   'begin', 'case', 'try', 'asm', 'end', ';'], False);
  while Reader.ReadToken = ';' do ;
  Reader.UnreadToken;
end;

{ TPressPascalBlockStatement }

class function TPressPascalBlockStatement.Identifier: string;
begin
  Result := 'begin';
end;

class function TPressPascalBlockStatement.InternalApplyIdentifier(
  Reader: TPressParserReader): Boolean;
var
  Token: string;
begin
  Token := Reader.ReadToken;
  Result := SameText(Token, 'begin') or SameText(Token, 'case') or
   SameText(Token, 'try') or SameText(Token, 'asm');
end;

procedure TPressPascalBlockStatement.InternalRead(
  Reader: TPressParserReader);
begin
  inherited;
  FBlockType := LowerCase(Reader.ReadIdentifier);
  repeat
  until Parse(Reader, [
   TPressPascalBlockStatement, TPressPascalPlainStatement]) = nil;
  Reader.ReadMatchText('end');
  if Reader.ReadToken <> ';' then
    Reader.UnreadToken;
end;

end.
