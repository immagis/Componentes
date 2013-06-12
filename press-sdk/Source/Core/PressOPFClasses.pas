(*
  PressObjects, OPF Support Classes
  Copyright (C) 2007 Laserpress Ltda.

  http://www.pressobjects.org

  See the file LICENSE.txt, included in this distribution,
  for details about the copyright.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*)

unit PressOPFClasses;

{$I Press.inc}

interface

uses
  {$IFNDEF D5Down}Variants,{$ENDIF}
  PressClasses,
  PressSubject;

type
  EPressOPFError = class(EPressError);

  TPressOPFFieldType = (oftUnknown, oftPlainString, oftAnsiString,
   oftInt16, oftInt32, oftInt64, oftDouble, oftCurrency,
   oftBoolean, oftDate, oftTime, oftDateTime,
   oftMemo, oftBinary);

  TPressOPFParam = class(TObject)
  private
    FDataType: TPressOPFFieldType;
    FIsAssigned: Boolean;
    FIsNull: Boolean;
    FName: string;
    FValue: Variant;
    function GetAsBoolean: Boolean;
    function GetAsCurrency: Currency;
    function GetAsDate: TDateTime;
    function GetAsDateTime: TDateTime;
    function GetAsDouble: Double;
    function GetAsInt16: Smallint;
    function GetAsInt32: Integer;
    function GetAsInt64: Int64;
    function GetAsString: string;
    function GetAsTime: TDateTime;
    procedure SetAsBinary(const AValue: string);
    procedure SetAsBoolean(AValue: Boolean);
    procedure SetAsCurrency(AValue: Currency);
    procedure SetAsDate(AValue: TDateTime);
    procedure SetAsDateTime(AValue: TDateTime);
    procedure SetAsDouble(AValue: Double);
    procedure SetAsInt16(AValue: Smallint);
    procedure SetAsInt32(AValue: Integer);
    procedure SetAsInt64(AValue: Int64);
    procedure SetAsMemo(const AValue: string);
    procedure SetAsString(const AValue: string);
    procedure SetAsTime(AValue: TDateTime);
    procedure SetAsVariant(AValue: Variant);
    procedure ValueAssigned;
  public
    constructor Create(const AName: string);
    procedure Clear(ADataType: TPressOPFFieldType);
    procedure Empty;
    property AsBinary: string read GetAsString write SetAsBinary;
    property AsBoolean: Boolean read GetAsBoolean write SetAsBoolean;
    property AsCurrency: Currency read GetAsCurrency write SetAsCurrency;
    property AsDate: TDateTime read GetAsDate write SetAsDate;
    property AsDateTime: TDateTime read GetAsDateTime write SetAsDateTime;
    property AsDouble: Double read GetAsDouble write SetAsDouble;
    property AsInt16: Smallint read GetAsInt16 write SetAsInt16;
    property AsInt32: Integer read GetAsInt32 write SetAsInt32;
    property AsInt64: Int64 read GetAsInt64 write SetAsInt64;
    property AsMemo: string read GetAsString write SetAsMemo;
    property AsString: string read GetAsString write SetAsString;
    property AsTime: TDateTime read GetAsTime write SetAsTime;
    property AsVariant: Variant read FValue write SetAsVariant;
    property DataType: TPressOPFFieldType read FDataType;
    property IsAssigned: Boolean read FIsAssigned;
    property IsNull: Boolean read FIsNull;
    property Name: string read FName;
  end;

  TPressOPFParamIterator = class;

  TPressOPFParamList = class(TPressList)
  private
    procedure AssignParam(AParam: TPressParam);
    function GetItems(AIndex: Integer): TPressOPFParam;
    procedure SetItems(AIndex: Integer; const Value: TPressOPFParam);
  protected
    function InternalCreateIterator: TPressCustomIterator; override;
  public
    function Add(const AName: string): TPressOPFParam; overload;
    function Add(AObject: TPressOPFParam): Integer; overload;
    procedure AssignParams(AParams: TPressParamList);
    function CreateIterator: TPressOPFParamIterator;
    function Extract(AObject: TPressOPFParam): TPressOPFParam;
    function FindParam(const AName: string): TPressOPFParam;
    function First: TPressOPFParam;
    function IndexOf(AObject: TPressOPFParam): Integer;
    procedure Insert(AIndex: Integer; AObject: TPressOPFParam);
    function Last: TPressOPFParam;
    function ParamByName(const AName: string): TPressOPFParam;
    function Remove(AObject: TPressOPFParam): Integer;
    property Items[AIndex: Integer]: TPressOPFParam read GetItems write SetItems; default;
  end;

  TPressOPFParamIterator = class(TPressIterator)
  private
    function GetCurrentItem: TPressOPFParam;
  public
    property CurrentItem: TPressOPFParam read GetCurrentItem;
  end;

implementation

uses
  SysUtils,
  TypInfo,
{$ifdef d5down}
  ActiveX,
  PressUtils,
{$endif}
  PressConsts;

{ TPressOPFParam }

procedure TPressOPFParam.Clear(ADataType: TPressOPFFieldType);
begin
  FIsAssigned := True;
  FIsNull := True;
  FValue := Null;
  FDataType := ADataType;
end;

constructor TPressOPFParam.Create(const AName: string);
begin
  inherited Create;
  FName := AName;
  Empty;
end;

procedure TPressOPFParam.Empty;
begin
  FIsAssigned := False;
  FIsNull := True;
  FValue := Null;
  FDataType := oftUnknown;
end;

function TPressOPFParam.GetAsBoolean: Boolean;
begin
  if not IsNull then
    Result := FValue
  else
    Result := False;
end;

function TPressOPFParam.GetAsCurrency: Currency;
begin
  if not IsNull then
    Result := FValue
  else
    Result := 0;
end;

function TPressOPFParam.GetAsDate: TDateTime;
begin
  if not IsNull then
    Result := FValue
  else
    Result := 0;
end;

function TPressOPFParam.GetAsDateTime: TDateTime;
begin
  if not IsNull then
    Result := FValue
  else
    Result := 0;
end;

function TPressOPFParam.GetAsDouble: Double;
begin
  if not IsNull then
    Result := FValue
  else
    Result := 0;
end;

function TPressOPFParam.GetAsInt16: Smallint;
begin
  if not IsNull then
    Result := FValue
  else
    Result := 0;
end;

function TPressOPFParam.GetAsInt32: Integer;
begin
  if not IsNull then
    Result := FValue
  else
    Result := 0;
end;

function TPressOPFParam.GetAsInt64: Int64;
begin
  if not IsNull then
    Result := {$ifdef d5down}PressD5VariantToInt64(FValue){$else}FValue{$endif}
  else
    Result := 0;
end;

function TPressOPFParam.GetAsString: string;
begin
  if not IsNull then
    Result := FValue
  else
    Result := '';
end;

function TPressOPFParam.GetAsTime: TDateTime;
begin
  if not IsNull then
    Result := FValue
  else
    Result := 0;
end;

procedure TPressOPFParam.SetAsBinary(const AValue: string);
begin
  FValue := AValue;
  FDataType := oftBinary;
  ValueAssigned;
end;

procedure TPressOPFParam.SetAsBoolean(AValue: Boolean);
begin
  FValue := AValue;
  FDataType := oftBoolean;
  ValueAssigned;
end;

procedure TPressOPFParam.SetAsCurrency(AValue: Currency);
begin
  FValue := AValue;
  FDataType := oftCurrency;
  ValueAssigned;
end;

procedure TPressOPFParam.SetAsDate(AValue: TDateTime);
begin
  FValue := AValue;
  FDataType := oftDate;
  ValueAssigned;
end;

procedure TPressOPFParam.SetAsDateTime(AValue: TDateTime);
begin
  FValue := AValue;
  FDataType := oftDateTime;
  ValueAssigned;
end;

procedure TPressOPFParam.SetAsDouble(AValue: Double);
begin
  FValue := AValue;
  FDataType := oftDouble;
  ValueAssigned;
end;

procedure TPressOPFParam.SetAsInt16(AValue: Smallint);
begin
  FValue := AValue;
  FDataType := oftInt16;
  ValueAssigned;
end;

procedure TPressOPFParam.SetAsInt32(AValue: Integer);
begin
  FValue := AValue;
  FDataType := oftInt32;
  ValueAssigned;
end;

procedure TPressOPFParam.SetAsInt64(AValue: Int64);
begin
  FValue := {$ifdef d5down}PressD5Int64ToVariant(AValue){$else}AValue{$endif};
  FDataType := oftInt64;
  ValueAssigned;
end;

procedure TPressOPFParam.SetAsMemo(const AValue: string);
begin
  FValue := AValue;
  FDataType := oftMemo;
  ValueAssigned;
end;

procedure TPressOPFParam.SetAsString(const AValue: string);
begin
  FValue := AValue;
  FDataType := oftAnsiString;
  ValueAssigned;
end;

procedure TPressOPFParam.SetAsTime(AValue: TDateTime);
begin
  FValue := AValue;
  FDataType := oftTime;
  ValueAssigned;
end;

procedure TPressOPFParam.SetAsVariant(AValue: Variant);
begin
  case VarType(AValue) of
    {$ifndef d5down}varShortInt, {$endif}varByte, varSmallInt:
      FDataType := oftInt16;
    varInteger:
      FDataType := oftInt32;
{$ifdef d5down}
    VT_DECIMAL:
{$else}
    varInt64:
{$endif}
      FDataType := oftInt64;
    varSingle, varDouble:
      FDataType := oftDouble;
    varCurrency:
      FDataType := oftCurrency;
    varDate:
      FDataType := oftDateTime;
    varBoolean:
      FDataType := oftBoolean;
    varStrArg, varString:
      FDataType := oftAnsiString;
{$ifndef d5down}
    varWord:
      FDataType := oftInt16;  { TODO : unsigned }
    varLongWord:
      FDataType := oftInt32;  { TODO : unsigned }
{$endif}
{$ifdef fpc}
    varQWord:
      FDataType := oftInt64;  { TODO : unsigned }
{$endif}
    else
      FDataType := oftUnknown;
  end;
  FIsAssigned := not VarIsEmpty(AValue);
  FIsNull := VarIsEmpty(AValue) or VarIsNull(AValue);
  if IsAssigned then
    FValue := AValue
  else
    FValue := Null;
end;

procedure TPressOPFParam.ValueAssigned;
begin
  FIsAssigned := True;
  FIsNull := False;
end;

{ TPressOPFParamList }

function TPressOPFParamList.Add(const AName: string): TPressOPFParam;
begin
  Result := TPressOPFParam.Create(AName);
  Add(Result);
end;

function TPressOPFParamList.Add(AObject: TPressOPFParam): Integer;
begin
  Result := inherited Add(AObject);
end;

procedure TPressOPFParamList.AssignParam(AParam: TPressParam);
var
  VParam: TPressOPFParam;
begin
  VParam := Add(AParam.Name);
  case AParam.ParamType of
    attPlainString, attAnsiString:
      VParam.AsString := AParam.Value;
    attInteger:
      VParam.AsInt32 := AParam.Value;
    attInt64:
      VParam.AsInt64 := {$ifdef d5down}PressD5VariantToInt64(AParam.Value){$else}AParam.Value{$endif};
    attDouble:
      VParam.AsDouble := AParam.Value;
    attCurrency:
      VParam.AsCurrency := AParam.Value;
    attEnum:
      VParam.AsInt16 := AParam.Value;
    attBoolean:
      VParam.AsBoolean := AParam.Value;
    attDate:
      VParam.AsDate := AParam.Value;
    attTime:
      VParam.AsTime := AParam.Value;
    attDateTime:
      VParam.AsDateTime := AParam.Value;
    attVariant:
      VParam.AsVariant := AParam.Value;
    attMemo:
      VParam.AsMemo := AParam.Value;
    attBinary, attPicture:
      VParam.AsBinary := AParam.Value;
    else
      raise EPressOPFError.CreateFmt(SUnsupportedAttributeType, [
       GetEnumName(TypeInfo(TPressAttributeBaseType), Ord(AParam.ParamType))]);
  end;
end;

procedure TPressOPFParamList.AssignParams(AParams: TPressParamList);
var
  I: Integer;
begin
  if Assigned(AParams) then
    for I := 0 to Pred(AParams.Count) do
      AssignParam(AParams[I]);
end;

function TPressOPFParamList.CreateIterator: TPressOPFParamIterator;
begin
  Result := TPressOPFParamIterator.Create(Self);
end;

function TPressOPFParamList.Extract(
  AObject: TPressOPFParam): TPressOPFParam;
begin
  Result := inherited Extract(AObject) as TPressOPFParam;
end;

function TPressOPFParamList.FindParam(const AName: string): TPressOPFParam;
var
  I: Integer;
begin
  for I := 0 to Pred(Count) do
  begin
    Result := Items[I];
    if SameText(Result.Name, AName) then
      Exit;
  end;
  Result := nil;
end;

function TPressOPFParamList.First: TPressOPFParam;
begin
  Result := inherited First as TPressOPFParam;
end;

function TPressOPFParamList.GetItems(AIndex: Integer): TPressOPFParam;
begin
  Result := inherited Items[AIndex] as TPressOPFParam;
end;

function TPressOPFParamList.IndexOf(AObject: TPressOPFParam): Integer;
begin
  Result := inherited IndexOf(AObject);
end;

procedure TPressOPFParamList.Insert(AIndex: Integer;
  AObject: TPressOPFParam);
begin
  inherited Insert(AIndex, AObject);
end;

function TPressOPFParamList.InternalCreateIterator: TPressCustomIterator;
begin
  Result := CreateIterator;
end;

function TPressOPFParamList.Last: TPressOPFParam;
begin
  Result := inherited Last as TPressOPFParam;
end;

function TPressOPFParamList.ParamByName(const AName: string): TPressOPFParam;
begin
  Result := FindParam(AName);
  if not Assigned(Result) then
  begin
    Result := TPressOPFParam.Create(AName);
    Add(Result);
  end;
end;

function TPressOPFParamList.Remove(AObject: TPressOPFParam): Integer;
begin
  Result := inherited Remove(AObject);
end;

procedure TPressOPFParamList.SetItems(AIndex: Integer;
  const Value: TPressOPFParam);
begin
  inherited Items[AIndex] := Value;
end;

{ TPressOPFParamIterator }

function TPressOPFParamIterator.GetCurrentItem: TPressOPFParam;
begin
  Result := inherited CurrentItem as TPressOPFParam;
end;

end.
