(*
  PressObjects, SQL Builder Classes
  Copyright (C) 2007-2008 Laserpress Ltda.

  http://www.pressobjects.org

  See the file LICENSE.txt, included in this distribution,
  for details about the copyright.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*)

unit PressOPFSQLBuilder;

{$I Press.inc}

interface

uses
  Classes,
  PressSubject,
  PressAttributes,
  PressSession,
  PressOPFClasses,
  PressOPFStorage;

type
  TPressOPFSQLBuilder = class(TObject)
  protected
    procedure ConcatStatements(const AStatementStr, AConnectorToken: string; var ABuffer: string);
  end;

  TPressOPFDDLBuilderClass = class of TPressOPFDDLBuilder;

  TPressOPFDDLBuilder = class(TPressOPFSQLBuilder)
  protected
    function BuildFieldType(AFieldMetadata: TPressOPFFieldMetadata): string;
    function BuildStringList(AList: TStrings): string;
    function InternalFieldTypeStr(AFieldType: TPressOPFFieldType): string; virtual;
    function InternalImplicitIndexCreation: Boolean; virtual;
    function InternalMaxIdentLength: Integer; virtual;
  public
    function AttributeTypeToFieldType(AAttributeBaseType: TPressAttributeBaseType): TPressOPFFieldType;
    function CreateClearDatabaseStatement(AModel: TPressOPFStorageModel): string; virtual;
    function CreateDatabaseStatement(AModel: TPressOPFStorageModel): string; virtual;
    function CreateFieldStatement(AFieldMetadata: TPressOPFFieldMetadata): string; virtual;
    function CreateFieldStatementList(ATableMetadata: TPressOPFTableMetadata): string; virtual;
    function CreateForeignKeyIndexStatement(ATableMetadata: TPressOPFTableMetadata; AForeignKeyMetadata: TPressOPFForeignKeyMetadata): string; virtual;
    function CreateForeignKeyStatement(ATableMetadata: TPressOPFTableMetadata; AForeignKeyMetadata: TPressOPFForeignKeyMetadata): string; virtual;
    function CreateGeneratorStatement(const AName: string): string; virtual;
    function CreateHints(AModel: TPressOPFStorageModel): string; virtual;
    function CreateIndexStatement(ATableMetadata: TPressOPFTableMetadata; AIndexMetadata: TPressOPFIndexMetadata): string; virtual;
    function CreatePrimaryKeyStatement(ATableMetadata: TPressOPFTableMetadata): string; virtual;
    function CreateTableStatement(ATableMetadata: TPressOPFTableMetadata): string; virtual;
    function DropConstraintStatement(ATableMetadata: TPressOPFTableMetadata; AMetadata: TPressOPFMetadata): string; virtual;
    function DropTableStatement(ATableMetadata: TPressOPFTableMetadata): string; virtual;
    // Map/metadata independent DMLs
    function SelectGeneratorStatement: string; virtual;
  end;

  TPressOPFFieldListType = (ftSimple, ftParams);
  TPressOPFHelperField = (hfOID, hfClassId, hfUpdateCount);
  TPressOPFHelperFields = set of TPressOPFHelperField;

  TPressOPFDMLBuilderClass = class of TPressOPFDMLBuilder;

  TPressOPFDMLBuilder = class(TPressOPFSQLBuilder)
  private
    FMap: TPressOPFStorageMap;
    FMaps: TPressOPFStorageMapList;
    FMetadata: TPressObjectMetadata;
  protected
    function BuildFieldList(AFieldListType: TPressOPFFieldListType; AHelperFields: TPressOPFHelperFields; AMaps: TPressOPFStorageMapArray = nil; AAttributes: TPressSessionAttributes = nil): string;
    function BuildKeyName(AMaps: TPressOPFStorageMapArray): string;
    function BuildLinkList(const APrefix: string; AMetadata: TPressAttributeMetadata): string;
    function BuildMapArray(ABaseClass: TPressObjectClass): TPressOPFStorageMapArray;
    function BuildTableAlias(AIndex: Integer): string;
    function BuildTableList(AMaps: TPressOPFStorageMapArray): string;
    function CreateAssignParamToFieldList(AObject: TPressObject): string;
    function CreateIdParamList(ACount: Integer): string;
    property Map: TPressOPFStorageMap read FMap;
    property Maps: TPressOPFStorageMapList read FMaps;
    property Metadata: TPressObjectMetadata read FMetadata;
  public
    constructor Create(AMaps: TPressOPFStorageMapList);
    function DeleteLinkItemsStatement(AItems: TPressItems): string; virtual;
    function DeleteLinkStatement(AMetadata: TPressAttributeMetadata): string; virtual;
    function DeleteStatement: string; virtual;
    function InsertLinkStatement(AMetadata: TPressAttributeMetadata): string; virtual;
    function InsertStatement: string; virtual;
    function SelectAttributeStatement(AAttribute: TPressAttributeMetadata): string;
    function SelectGroupStatement(AIdCount: Integer; ABaseClass: TPressObjectClass = nil; AAttributes: TPressSessionAttributes = nil): string; virtual;
    function SelectLinkStatement(AMetadata: TPressAttributeMetadata): string; virtual;
    function SelectStatement(ABaseClass: TPressObjectClass = nil; AAttributes: TPressSessionAttributes = nil): string; virtual;
    function UpdateStatement(AObject: TPressObject): string; virtual;
  end;

implementation

uses
  SysUtils,
  TypInfo,
  PressConsts;

{ TPressOPFSQLBuilder }

procedure TPressOPFSQLBuilder.ConcatStatements(
  const AStatementStr, AConnectorToken: string; var ABuffer: string);
begin
  { TODO : Merge with TPressQuery.ConcatStatements }
  if ABuffer = '' then
    ABuffer := AStatementStr
  else if AStatementStr <> '' then
    ABuffer := ABuffer + AConnectorToken + AStatementStr;
end;

{ TPressOPFDDLBuilder }

function TPressOPFDDLBuilder.AttributeTypeToFieldType(
  AAttributeBaseType: TPressAttributeBaseType): TPressOPFFieldType;
const
  CFieldType: array[TPressAttributeBaseType] of TPressOPFFieldType = (
   oftUnknown,    // attUnknown
   oftPlainString,  // attPlainString
   oftAnsiString,  // attAnsiString
   oftInt32,      // attInteger
   oftInt64,      // attInt64
   oftDouble,     // attDouble
   oftCurrency,   // attCurrency
   oftInt16,      // attEnum
   oftBoolean,    // attBoolean
   oftDate,       // attDate
   oftTime,       // attTime
   oftDateTime,   // attDateTime
   oftUnknown,    // attVariant
   oftMemo,       // attMemo
   oftBinary,     // attBinary
   oftBinary,     // attPicture
   oftUnknown,    // attPart
   oftUnknown,    // attReference
   oftUnknown,    // attParts
   oftUnknown);   // attReferences
begin
  Result := CFieldType[AAttributeBaseType];
  if Result = oftUnknown then
    raise EPressOPFError.CreateFmt(SUnsupportedAttributeType, [
     GetEnumName(TypeInfo(TPressAttributeBaseType), Ord(AAttributeBaseType))]);
end;

function TPressOPFDDLBuilder.BuildFieldType(
  AFieldMetadata: TPressOPFFieldMetadata): string;
begin
  Result :=
   InternalFieldTypeStr(AttributeTypeToFieldType(AFieldMetadata.DataType));
  if AFieldMetadata.DataType in [attPlainString, attAnsiString] then
    Result := Result + Format('(%d)', [AFieldMetadata.Size]);
end;

function TPressOPFDDLBuilder.BuildStringList(AList: TStrings): string;
var
  I: Integer;
begin
  Result := '';
  for I := 0 to Pred(AList.Count) do
    ConcatStatements(AList[I], ', ', Result);
end;

function TPressOPFDDLBuilder.CreateClearDatabaseStatement(
  AModel: TPressOPFStorageModel): string;
var
  VTable: TPressOPFTableMetadata;
  I, J: Integer;
begin
  Result := '/*' + SPressLineBreak +
   'The following statement(s) can be used' + SPressLineBreak +
   'to drop all tables from the database' + SPressLineBreak + SPressLineBreak;
  for I := 0 to Pred(AModel.TableMetadatas.Count) do
  begin
    VTable := AModel.TableMetadatas[I];
    for J := 0 to Pred(VTable.ForeignKeyCount) do
      Result := Result + '  ' +
       DropConstraintStatement(VTable, VTable.ForeignKeys[J]);
  end;
  for I := 0 to Pred(AModel.TableMetadatas.Count) do
    Result := Result + '  ' +
     DropTableStatement(AModel.TableMetadatas[I]);
  Result := Result + '*/' + SPressLineBreak + SPressLineBreak;
end;

function TPressOPFDDLBuilder.CreateDatabaseStatement(
  AModel: TPressOPFStorageModel): string;
var
  VTable: TPressOPFTableMetadata;
  I, J: Integer;
begin
  Result := '';
  for I := 0 to Pred(AModel.TableMetadatas.GeneratorList.Count) do
    Result := Result +
     CreateGeneratorStatement(AModel.TableMetadatas.GeneratorList[I]) + ';' +
     SPressLineBreak + SPressLineBreak;
  for I := 0 to Pred(AModel.TableMetadatas.Count) do
  begin
    VTable := AModel.TableMetadatas[I];
    Result := Result +
     CreateTableStatement(VTable) +
     CreatePrimaryKeyStatement(VTable);
    for J := 0 to Pred(VTable.IndexCount) do
      Result := Result + CreateIndexStatement(VTable, VTable.Indexes[J]);
    if not InternalImplicitIndexCreation then
      for J := 0 to Pred(VTable.ForeignKeyCount) do
        Result := Result +
         CreateForeignKeyIndexStatement(VTable, VTable.ForeignKeys[J]);
  end;
  for I := 0 to Pred(AModel.TableMetadatas.Count) do
  begin
    VTable := AModel.TableMetadatas[I];
    for J := 0 to Pred(VTable.ForeignKeyCount) do
      Result := Result +
       CreateForeignKeyStatement(VTable, VTable.ForeignKeys[J]);
  end;
end;

function TPressOPFDDLBuilder.CreateFieldStatement(
  AFieldMetadata: TPressOPFFieldMetadata): string;
begin
  Result := Format('%s %s', [
   AFieldMetadata.Name,
   BuildFieldType(AFieldMetadata)]);
  if foNotNull in AFieldMetadata.Options then
    Result := Result + ' not null';
end;

function TPressOPFDDLBuilder.CreateFieldStatementList(
  ATableMetadata: TPressOPFTableMetadata): string;
var
  I: Integer;
begin
  Result := '';
  for I := 0 to Pred(ATableMetadata.FieldCount) do
    ConcatStatements(
     CreateFieldStatement(
      ATableMetadata.Fields[I]), ',' + SPressLineBreak + '  ', Result);
end;

function TPressOPFDDLBuilder.CreateForeignKeyIndexStatement(
  ATableMetadata: TPressOPFTableMetadata;
  AForeignKeyMetadata: TPressOPFForeignKeyMetadata): string;
begin
  Result := Format(
   'create index %s' + SPressLineBreak +
   '  on %s (%s);' + SPressLineBreak + SPressLineBreak, [
   AForeignKeyMetadata.Name,
   ATableMetadata.Name,
   BuildStringList(AForeignKeyMetadata.KeyFieldNames)]);
end;

function TPressOPFDDLBuilder.CreateForeignKeyStatement(
  ATableMetadata: TPressOPFTableMetadata;
  AForeignKeyMetadata: TPressOPFForeignKeyMetadata): string;
const
  CReferentialAction: array[TPressOPFReferentialAction] of string = (
   'no action', 'cascade', 'set null', 'set default');
begin
  Result := Format(
   'alter table %s add constraint %s' + SPressLineBreak +
   '  foreign key (%s)' + SPressLineBreak +
   '  references %s (%s)' + SPressLineBreak +
   '  on delete %s' + SPressLineBreak +
   '  on update %s;' + SPressLineBreak + SPressLineBreak, [
   ATableMetadata.Name,
   AForeignKeyMetadata.Name,
   BuildStringList(AForeignKeyMetadata.KeyFieldNames),
   AForeignKeyMetadata.ReferencedTableName,
   BuildStringList(AForeignKeyMetadata.ReferencedFieldNames),
   CReferentialAction[AForeignKeyMetadata.OnDeleteAction],
   CReferentialAction[AForeignKeyMetadata.OnUpdateAction]]);
end;

function TPressOPFDDLBuilder.CreateGeneratorStatement(const AName: string): string;
begin
  Result := '';
end;

function TPressOPFDDLBuilder.CreateHints(
  AModel: TPressOPFStorageModel): string;

  procedure CheckIdentLength(
    const AIdentName: string; AMaxSize: Integer; var ABuffer: string);
  begin
    if Length(AIdentName) > AMaxSize then
    begin
      if ABuffer = '' then
        ABuffer := '/*' + SPressLineBreak +
         SDatabaseIdentifierTooLong + SPressLineBreak + SPressLineBreak;
      ABuffer := ABuffer + '  ' + AIdentName + SPressLineBreak;
    end;
  end;

var
  VTable: TPressOPFTableMetadata;
  VMaxIdentLength: Integer;
  I, J: Integer;
begin
  VMaxIdentLength := InternalMaxIdentLength;
  Result := '';
  if VMaxIdentLength > 0 then
  begin
    for I := 0 to Pred(AModel.TableMetadatas.Count) do
    begin
      VTable := AModel.TableMetadatas[I];
      CheckIdentLength(VTable.Name, VMaxIdentLength, Result);
      for J := 0 to Pred(VTable.FieldCount) do
        CheckIdentLength(VTable.Fields[J].Name, VMaxIdentLength, Result);
      CheckIdentLength(VTable.PrimaryKey.Name, VMaxIdentLength, Result);
      for J := 0 to Pred(VTable.IndexCount) do
        CheckIdentLength(VTable.Indexes[J].Name, VMaxIdentLength, Result);
    end;
    for I := 0 to Pred(AModel.TableMetadatas.Count) do
    begin
      VTable := AModel.TableMetadatas[I];
      for J := 0 to Pred(VTable.ForeignKeyCount) do
        CheckIdentLength(VTable.ForeignKeys[J].Name, VMaxIdentLength, Result);
    end;
    if Result <> '' then
      Result := Result + '*/' + SPressLineBreak + SPressLineBreak;
  end;
end;

function TPressOPFDDLBuilder.CreateIndexStatement(
  ATableMetadata: TPressOPFTableMetadata; AIndexMetadata: TPressOPFIndexMetadata): string;
const
  CUnique: array[Boolean] of string = ('', 'unique ');
  CDescending: array[Boolean] of string = ('', 'descending ');
begin
  Result := Format(
   'create %s%sindex %s' + SPressLineBreak +
   '  on %s (%s);' + SPressLineBreak + SPressLineBreak, [
   CUnique[ioUnique in AIndexMetadata.Options],
   CDescending[ioDescending in AIndexMetadata.Options],
   AIndexMetadata.Name,
   ATableMetadata.Name,
   BuildStringList(AIndexMetadata.FieldNames)]);
end;

function TPressOPFDDLBuilder.CreatePrimaryKeyStatement(
  ATableMetadata: TPressOPFTableMetadata): string;
begin
  if Assigned(ATableMetadata.PrimaryKey) then
    Result := Format(
     'alter table %s add constraint %s' + SPressLineBreak +
     '  primary key (%s);' + SPressLineBreak + SPressLineBreak, [
     ATableMetadata.Name,
     ATableMetadata.PrimaryKey.Name,
     BuildStringList(ATableMetadata.PrimaryKey.FieldNames)])
  else
    Result := '';
end;

function TPressOPFDDLBuilder.CreateTableStatement(
  ATableMetadata: TPressOPFTableMetadata): string;
begin
  Result := Format(
   'create table %s (' + SPressLineBreak +
   '  %s);' + SPressLineBreak + SPressLineBreak, [
   ATableMetadata.Name,
   CreateFieldStatementList(ATableMetadata)]);
end;

function TPressOPFDDLBuilder.DropConstraintStatement(
  ATableMetadata: TPressOPFTableMetadata;
  AMetadata: TPressOPFMetadata): string;
begin
  Result := Format('alter table %s drop constraint %s;' + SPressLineBreak, [
   ATableMetadata.Name,
   AMetadata.Name]);
end;

function TPressOPFDDLBuilder.DropTableStatement(
  ATableMetadata: TPressOPFTableMetadata): string;
begin
  Result := Format('drop table %s;' + SPressLineBreak, [
   ATableMetadata.Name]);
end;

function TPressOPFDDLBuilder.InternalFieldTypeStr(
  AFieldType: TPressOPFFieldType): string;
begin
  raise EPressOPFError.CreateFmt(SUnsupportedFeature, ['field type str']);
end;

function TPressOPFDDLBuilder.InternalImplicitIndexCreation: Boolean;
begin
  Result := False;
end;

function TPressOPFDDLBuilder.InternalMaxIdentLength: Integer;
begin
  Result := 0;
end;

function TPressOPFDDLBuilder.SelectGeneratorStatement: string;
begin
  Result := '';
end;

{ TPressOPFDMLBuilder }

function TPressOPFDMLBuilder.BuildFieldList(
  AFieldListType: TPressOPFFieldListType;
  AHelperFields: TPressOPFHelperFields;
  AMaps: TPressOPFStorageMapArray;
  AAttributes: TPressSessionAttributes): string;

  function IncludeAttribute(AAttribute: TPressAttributeMetadata): Boolean;
  begin
    Result := not AAttribute.AttributeClass.InheritsFrom(TPressItems);
    if Result then
      if Assigned(AAttributes) then
        Result := AAttributes.Include(AAttribute)
      else
        Result := not AAttribute.LazyLoad;
  end;

  procedure AddStatement(const AStatement: string; var ABuffer: string);
  begin
    if (AStatement <> '') and (AStatement[Length(AStatement)] <> '.') then
      case AFieldListType of
        ftSimple:
          ConcatStatements(AStatement, ', ', ABuffer);
        ftParams:
          ConcatStatements(':' + AStatement, ', ', ABuffer);
      end;
  end;

  procedure BuildRootMap(
    AMap: TPressOPFStorageMap; var ABuffer: string; ANeedTableAlias: Boolean);
  var
    VAttribute: TPressAttributeMetadata;
    VPartsAttribute: TPressAttributeMetadata;
    VFieldPrefix: string;
    I: Integer;
  begin
    if ANeedTableAlias then
      VFieldPrefix := BuildTableAlias(0) + '.'
    else
      VFieldPrefix := '';
    if AMap.Count > 0 then
    begin
      if hfOID in AHelperFields then
        AddStatement(VFieldPrefix + AMap[0].PersistentName, ABuffer);
      if hfClassId in AHelperFields then
        AddStatement(VFieldPrefix + AMap.Metadata.ClassIdName, ABuffer);
      if hfUpdateCount in AHelperFields then
        AddStatement(VFieldPrefix + AMap.Metadata.UpdateCountName, ABuffer);
    end;
    VPartsAttribute := Map.Metadata.OwnerPartsMetadata;
    if Assigned(VPartsAttribute) then
    begin
      AddStatement(VFieldPrefix + VPartsAttribute.PersLinkParentName, ABuffer);
      AddStatement(VFieldPrefix + VPartsAttribute.PersLinkPosName, ABuffer);
    end;
    for I := 1 to Pred(AMap.Count) do  // skips ID
    begin
      VAttribute := AMap[I];
      if IncludeAttribute(VAttribute) then
        AddStatement(VFieldPrefix + VAttribute.PersistentName, ABuffer);
    end;
  end;

  procedure BuildMap(
    AMap: TPressOPFStorageMap; AIndex: Integer; var ABuffer: string);
  var
    VAttribute: TPressAttributeMetadata;
    I: Integer;
  begin
    for I := 1 to Pred(AMap.Count) do  // skips ID
    begin
      VAttribute := AMap[I];
      if IncludeAttribute(VAttribute) then
        AddStatement(
         BuildTableAlias(AIndex) + '.' + VAttribute.PersistentName, ABuffer);
    end;
  end;

var
  I: Integer;
begin
  Result := '';
  if Length(AMaps) > 0 then
  begin
    BuildRootMap(AMaps[0], Result, Length(AMaps) > 1);
    for I := 1 to Pred(Length(AMaps)) do
      BuildMap(AMaps[I], I, Result);
  end else
    BuildRootMap(Map, Result, False);
end;

function TPressOPFDMLBuilder.BuildKeyName(
  AMaps: TPressOPFStorageMapArray): string;
begin
  if Length(AMaps) > 1 then
    Result := BuildTableAlias(0) + '.' + Metadata.KeyName
  else
    Result := Metadata.KeyName;
end;

function TPressOPFDMLBuilder.BuildLinkList(
  const APrefix: string; AMetadata: TPressAttributeMetadata): string;

  procedure AddStatement(const AStatement: string);
  begin
    if AStatement <> '' then
      ConcatStatements(APrefix + AStatement, ', ', Result);
  end;

begin
  Result := '';
  AddStatement(AMetadata.PersLinkIdName);
  AddStatement(AMetadata.PersLinkParentName);
  AddStatement(AMetadata.PersLinkChildName);
  AddStatement(AMetadata.PersLinkPosName);
end;

function TPressOPFDMLBuilder.BuildMapArray(
  ABaseClass: TPressObjectClass): TPressOPFStorageMapArray;
var
  I, J: Integer;
begin
  SetLength(Result, Maps.Count);
  J := 0;
  for I := Pred(Maps.Count) downto 0 do
  begin
    Result[J] := Maps[I];
    if Result[J].ObjectClass = ABaseClass then
    begin
      SetLength(Result, J);
      Exit;
    end;
    Inc(J);
  end;
end;

function TPressOPFDMLBuilder.BuildTableAlias(AIndex: Integer): string;
begin
  Result := SPressTableAliasPrefix + IntToStr(AIndex);
end;

function TPressOPFDMLBuilder.BuildTableList(
  AMaps: TPressOPFStorageMapArray): string;
var
  I: Integer;
begin
  if Length(AMaps) > 0 then
  begin
    Result := AMaps[0].Metadata.PersistentName;
    if Length(AMaps) > 1 then
      Result := Result + ' ' + BuildTableAlias(0);
    for I := 1 to Pred(Length(AMaps)) do
      Result := Format('%s inner join %3:s %2:s on %1:s.%4:s = %2:s.%5:s', [
       Result,
       BuildTableAlias(0),
       BuildTableAlias(I),
       AMaps[I].Metadata.PersistentName,
       AMaps[0].Metadata.IdMetadata.PersistentName,
       AMaps[I].Metadata.IdMetadata.PersistentName]);
  end else
    Result := '';
end;

constructor TPressOPFDMLBuilder.Create(AMaps: TPressOPFStorageMapList);
begin
  inherited Create;
  FMaps := AMaps;
  FMap := FMaps.Last;
  FMetadata := FMap.Metadata;
end;

function TPressOPFDMLBuilder.CreateAssignParamToFieldList(
  AObject: TPressObject): string;

  procedure AddRelativeChange(AAttribute: TPressNumeric);
  begin
    { TODO : Relative changes might break obj x db synchronization }
    ConcatStatements(Format('%s = %0:s + :%0:s', [
     AAttribute.PersistentName]), ', ', Result);
  end;

  procedure AddParam(const AParamName: string);
  begin
    if AParamName <> '' then
      ConcatStatements(Format('%s = :%0:s', [AParamName]), ', ', Result);
  end;

var
  VAttribute: TPressAttribute;
  VOwnerParts: TPressAttributeMetadata;
  I: Integer;
begin
  Result := '';
  VOwnerParts := Metadata.OwnerPartsMetadata;
  if Assigned(VOwnerParts) then
  begin
    AddParam(VOwnerParts.PersLinkParentName);
    AddParam(VOwnerParts.PersLinkPosName);
  end;
  for I := 0 to Pred(Map.Count) do
  begin
    VAttribute := AObject.AttributeByName(Map[I].Name);
    if not (VAttribute is TPressItems) then
    begin
      if VAttribute.IsChanged and (VAttribute.PersistentName <> '') then
      begin
        if (VAttribute is TPressNumeric) and
         TPressNumeric(VAttribute).IsRelativelyChanged then
          AddRelativeChange(TPressNumeric(VAttribute))
        else
          AddParam(VAttribute.PersistentName);
      end;
    end;
  end;
  if Metadata = AObject.Metadata then
    AddParam(Metadata.UpdateCountName);
end;

function TPressOPFDMLBuilder.CreateIdParamList(ACount: Integer): string;
var
  I: Integer;
begin
  Result := '';
  for I := 0 to Pred(ACount) do
    ConcatStatements(':' + SPressIdString + InttoStr(I), ', ', Result);
end;

function TPressOPFDMLBuilder.DeleteLinkItemsStatement(
  AItems: TPressItems): string;
begin
  Result := Format('delete from %s where %s in (%s)', [
   AItems.Metadata.PersLinkName,
   AItems.Metadata.PersLinkChildName,
   CreateIdParamList(AItems.RemovedProxies.Count)]);
end;

function TPressOPFDMLBuilder.DeleteLinkStatement(
  AMetadata: TPressAttributeMetadata): string;
begin
  Result := Format('delete from %s where %s = %s', [
   AMetadata.PersLinkName,
   AMetadata.PersLinkParentName,
   ':' + SPressPersistentIdParamString]);
end;

function TPressOPFDMLBuilder.DeleteStatement: string;
begin
  Result := Format('delete from %s where %s = %s', [
   Metadata.PersistentName,
   Metadata.KeyName,
   ':' + SPressPersistentIdParamString]);
end;

function TPressOPFDMLBuilder.InsertLinkStatement(
  AMetadata: TPressAttributeMetadata): string;
begin
  Result := Format('insert into %s (%s) values (%s)', [
   AMetadata.PersLinkName,
   BuildLinkList('', AMetadata),
   BuildLinkList(':', AMetadata)]);
end;

function TPressOPFDMLBuilder.InsertStatement: string;
begin
  Result := Format('insert into %s (%s) values (%s)', [
   Metadata.PersistentName,
   BuildFieldList(ftSimple, [hfOID, hfClassId, hfUpdateCount]),
   BuildFieldList(ftParams, [hfOID, hfClassId, hfUpdateCount])]);
end;

function TPressOPFDMLBuilder.SelectAttributeStatement(
  AAttribute: TPressAttributeMetadata): string;
begin
  Result := Format('select %s from %s where %s = %s', [
   AAttribute.PersistentName,
   Metadata.PersistentName,
   Metadata.KeyName,
   ':' + SPressPersistentIdParamString]);
end;

function TPressOPFDMLBuilder.SelectGroupStatement(
  AIdCount: Integer; ABaseClass: TPressObjectClass;
  AAttributes: TPressSessionAttributes): string;
var
  VMaps: TPressOPFStorageMapArray;
begin
  VMaps := BuildMapArray(ABaseClass);
  Result := Format('select %s from %s where %s in (%s)', [
   BuildFieldList(ftSimple, [hfOID, hfClassId, hfUpdateCount], VMaps, AAttributes),
   BuildTableList(VMaps),
   BuildKeyName(VMaps),
   CreateIdParamList(AIdCount)]);
end;

function TPressOPFDMLBuilder.SelectLinkStatement(
  AMetadata: TPressAttributeMetadata): string;
begin
  Result := Format('select %s from %s where %s = %s', [
   AMetadata.PersLinkChildName,
   AMetadata.PersLinkName,
   AMetadata.PersLinkParentName,
   ':' + SPressPersistentIdParamString]);
  if AMetadata.PersLinkPosName <> '' then
    Result := Result + ' order by ' + AMetadata.PersLinkPosName;
end;

function TPressOPFDMLBuilder.SelectStatement(
  ABaseClass: TPressObjectClass; AAttributes: TPressSessionAttributes): string;
var
  VMaps: TPressOPFStorageMapArray;
begin
  VMaps := BuildMapArray(ABaseClass);
  Result := Format('select %s from %s where %s = %s', [
   BuildFieldList(ftSimple, [hfClassId, hfUpdateCount], VMaps, AAttributes),
   BuildTableList(VMaps),
   BuildKeyName(VMaps),
   ':' + SPressPersistentIdParamString]);
end;

function TPressOPFDMLBuilder.UpdateStatement(
  AObject: TPressObject): string;
var
  VAssignParamList: string;
begin
  VAssignParamList := CreateAssignParamToFieldList(AObject);
  if VAssignParamList <> '' then
  begin
    Result := Format('update %s set %s where (%s = %s)', [
     Metadata.PersistentName,
     VAssignParamList,
     Metadata.KeyName,
     ':' + SPressPersistentIdParamString]);
    if (Metadata = AObject.Metadata) and
     (Metadata.UpdateCountName <> '') then
      Result := Format('%s and (%s = %d)', [
       Result,
       Metadata.UpdateCountName,
       AObject.PersUpdateCount]);
  end else
    Result := '';
end;

end.
