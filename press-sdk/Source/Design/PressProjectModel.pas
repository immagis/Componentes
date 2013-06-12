(*
  PressObjects, Project Model Classes
  Copyright (C) 2007 Laserpress Ltda.

  http://www.pressobjects.org

  See the file LICENSE.txt, included in this distribution,
  for details about the copyright.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*)

unit PressProjectModel;

{$I Press.inc}

interface

uses
  PressSubject,
  PressAttributes,
  PressIDEIntf;

type
  TPressProjectModule = class;
  TPressProjectItemReferences = class;

  TPressProjectItemClass = class of TPressProjectItem;

  TPressProjectItem = class(TPressObject)
  private
    FName: TPressString;
    FModule: TPressReference;
    FChildItems: TPressProjectItemReferences;
    function GetName: string;
    procedure SetName(const Value: string);
    function GetModule: TPressProjectModule;
    procedure SetModule(Value: TPressProjectModule);
  protected
    function InternalAttributeAddress(const AAttributeName: string): PPressAttribute; override;
    class function InternalMetadataStr: string; override;
  public
    property ChildItems: TPressProjectItemReferences read FChildItems;
  published
    property Name: string read GetName write SetName;
    property Module: TPressProjectModule read GetModule write SetModule;
  end;

  TPressProjectItemIterator = class;

  TPressProjectItemReferences = class(TPressReferences)
  private
    function GetObjects(AIndex: Integer): TPressProjectItem;
    procedure SetObjects(AIndex: Integer; const Value: TPressProjectItem);
  protected
    function InternalCreateIterator: TPressItemsIterator; override;
  public
    function Add(AClass: TPressProjectItemClass = nil): TPressProjectItem; overload;
    function Add(AObject: TPressProjectItem): Integer; overload;
    function CreateIterator: TPressProjectItemIterator;
    function FindItem(const AName: string; AClass: TPressProjectItemClass = nil; ARecursively: Boolean = True): TPressProjectItem;
    function IndexOf(AObject: TPressProjectItem): Integer;
    procedure Insert(AIndex: Integer; AObject: TPressProjectItem);
    function Remove(AObject: TPressProjectItem): Integer;
    class function ValidObjectClass: TPressObjectClass; override;
    property Objects[AIndex: Integer]: TPressProjectItem read GetObjects write SetObjects; default;
  end;

  TPressProjectItemIterator = class(TPressItemsIterator)
  private
    function GetCurrentItem: TPressProjectItem;
  public
    property CurrentItem: TPressProjectItem read GetCurrentItem;
  end;

  TPressProjectClassReferences = class;

  TPressProjectClassClass = class of TPressProjectClass;

  TPressProjectClass = class(TPressProjectItem)
  private
    FObjectClassName: TPressString;
    FParentClass: TPressReference;
    function GetChildItems: TPressProjectClassReferences;
    function GetObjectClassName: string;
    function GetParentClass: TPressProjectClass;
    procedure SetObjectClassName(const Value: string);
    procedure SetParentClass(Value: TPressProjectClass);
  protected
    function InternalAttributeAddress(const AAttributeName: string): PPressAttribute; override;
    class function InternalMetadataStr: string; override;
  public
    property ChildItems: TPressProjectClassReferences read GetChildItems;
  published
    property ObjectClassName: string read GetObjectClassName write SetObjectClassName;
    property ParentClass: TPressProjectClass read GetParentClass write SetParentClass;
  end;

  TPressProjectClassIterator = class;

  TPressProjectClassReferences = class(TPressProjectItemReferences)
  private
    function GetObjects(AIndex: Integer): TPressProjectClass;
    procedure SetObjects(AIndex: Integer; const Value: TPressProjectClass);
  protected
    function InternalCreateIterator: TPressItemsIterator; override;
  public
    function Add(AClass: TPressProjectClassClass = nil): TPressProjectClass; overload;
    function Add(AObject: TPressProjectClass): Integer; overload;
    function CreateIterator: TPressProjectClassIterator;
    function IndexOf(AObject: TPressProjectClass): Integer;
    procedure Insert(AIndex: Integer; AObject: TPressProjectClass);
    function Remove(AObject: TPressProjectClass): Integer;
    class function ValidObjectClass: TPressObjectClass; override;
    property Objects[AIndex: Integer]: TPressProjectClass read GetObjects write SetObjects; default;
  end;

  TPressProjectClassIterator = class(TPressItemsIterator)
  private
    function GetCurrentItem: TPressProjectClass;
  public
    property CurrentItem: TPressProjectClass read GetCurrentItem;
  end;

  TPressAttributeMetadataRegistryParts = class;

  TPressObjectMetadataRegistry = class(TPressProjectClass)
  private
    FRuntimeMetadata: TPressObjectMetadata;
  private
    FMetadataStr: TPressMemo;
    FKeyName: TPressString;
    FIsPersistent: TPressBoolean;
    FPersistentName: TPressString;
    FAttributeList: TPressAttributeMetadataRegistryParts;
    function GetIsPersistent: Boolean;
    function GetKeyName: string;
    function GetMetadataStr: string;
    function GetParentClass: TPressObjectMetadataRegistry;
    function GetPersistentName: string;
    function InsertLineBreak(const AStr: string): string;
    procedure SetIsPersistent(Value: Boolean);
    procedure SetKeyName(const Value: string);
    procedure SetMetadataStr(const Value: string);
    procedure SetParentClass(Value: TPressObjectMetadataRegistry);
    procedure SetPersistentName(const Value: string);
  protected
    function InternalAttributeAddress(const AAttributeName: string): PPressAttribute; override;
    class function InternalMetadataStr: string; override;
  public
    procedure UpdateRuntimeMetadata;
    property AttributeList: TPressAttributeMetadataRegistryParts read FAttributeList;
    property RuntimeMetadata: TPressObjectMetadata read FRuntimeMetadata write FRuntimeMetadata;
  published
    property IsPersistent: Boolean read GetIsPersistent write SetIsPersistent;
    property KeyName: string read GetKeyName write SetKeyName;
    property MetadataStr: string read GetMetadataStr write SetMetadataStr;
    property ParentClass: TPressObjectMetadataRegistry read GetParentClass write SetParentClass;
    property PersistentName: string read GetPersistentName write SetPersistentName;
  end;

  TPressAttributeTypeRegistry = class;

  TPressAttributeMetadataRegistry = class(TPressObject)
  private
    FRuntimeMetadata: TPressAttributeMetadata;
  private
    FName: TPressString;
    FAttributeType: TPressReference;
    FSize: TPressInteger;
    FContainerType: TPressReference;
    FDefaultValue: TPressString;
    FEditMask: TPressString;
    FIsPersistent: TPressBoolean;
    FPersistentName: TPressString;
    FPersLinkName: TPressString;
    FPersLinkIdName: TPressString;
    FPersLinkParentName: TPressString;
    FPersLinkChildName: TPressString;
    FPersLinkPosName: TPressString;
    function GetAttributeType: TPressAttributeTypeRegistry;
    function GetContainerType: TPressObjectMetadataRegistry;
    function GetName: string;
    function GetSize: Integer;
    procedure SetAttributeType(Value: TPressAttributeTypeRegistry);
    procedure SetContainerType(Value: TPressObjectMetadataRegistry);
    procedure SetName(const Value: string);
    procedure SetSize(Value: Integer);
  protected
    function InternalAttributeAddress(const AAttributeName: string): PPressAttribute; override;
    class function InternalMetadataStr: string; override;
  public
    property RuntimeMetadata: TPressAttributeMetadata read FRuntimeMetadata write FRuntimeMetadata;
  published
    property AttributeType: TPressAttributeTypeRegistry read GetAttributeType write SetAttributeType;
    property ContainerType: TPressObjectMetadataRegistry read GetContainerType write SetContainerType;
    property DefaultValue: TPressString read FDefaultValue;
    property EditMask: TPressString read FEditMask;
    property IsPersistent: TPressBoolean read FIsPersistent;
    property Name: string read GetName write SetName;
    property PersistentName: TPressString read FPersistentName;
    property PersLinkChildName: TPressString read FPersLinkChildName;
    property PersLinkIdName: TPressString read FPersLinkIdName;
    property PersLinkName: TPressString read FPersLinkName;
    property PersLinkParentName: TPressString read FPersLinkParentName;
    property PersLinkPosName: TPressString read FPersLinkPosName;
    property Size: Integer read GetSize write SetSize;
  end;

  TPressAttributeMetadataRegistryIterator = class;

  TPressAttributeMetadataRegistryParts = class(TPressParts)
  private
    function GetObjects(AIndex: Integer): TPressAttributeMetadataRegistry;
    procedure SetObjects(AIndex: Integer; Value: TPressAttributeMetadataRegistry);
  protected
    function InternalCreateIterator: TPressItemsIterator; override;
  public
    function Add: TPressAttributeMetadataRegistry; overload;
    function Add(AObject: TPressAttributeMetadataRegistry): Integer; overload;
    function CreateIterator: TPressAttributeMetadataRegistryIterator;
    function IndexOf(AObject: TPressAttributeMetadataRegistry): Integer;
    procedure Insert(AIndex: Integer; AObject: TPressAttributeMetadataRegistry);
    function Remove(AObject: TPressAttributeMetadataRegistry): Integer;
    class function ValidObjectClass: TPressObjectClass; override;
    property Objects[AIndex: Integer]: TPressAttributeMetadataRegistry read GetObjects write SetObjects; default;
  end;

  TPressAttributeMetadataRegistryIterator = class(TPressItemsIterator)
  private
    function GetCurrentItem: TPressAttributeMetadataRegistry;
  public
    property CurrentItem: TPressAttributeMetadataRegistry read GetCurrentItem;
  end;

  TPressAttributeTypeRegistry = class(TPressProjectClass)
  protected
    class function InternalMetadataStr: string; override;
  end;

  TPressEnumerationRegistry = class(TPressProjectItem)
  protected
    class function InternalMetadataStr: string; override;
  end;

  TPressProjectModuleArray = array of TPressProjectModule;

  TPressProjectModule = class(TPressObject)
  private
    FImplUses: TPressProjectModuleArray;
    FIntfUses: TPressProjectModuleArray;
    FModuleIntf: IPressIDEModule;
    procedure SetModuleIntf(const Value: IPressIDEModule);
  private
    FName: TPressString;
    FItems: TPressProjectItemReferences;
    function GetName: string;
    procedure SetName(const Value: string);
  protected
    function InternalAttributeAddress(const AAttributeName: string): PPressAttribute; override;
    class function InternalMetadataStr: string; override;
  public
    function FindClass(const AName: string): TPressProjectClass;
    property ImplUses: TPressProjectModuleArray read FImplUses write FImplUses;
    property IntfUses: TPressProjectModuleArray read FIntfUses write FIntfUses;
    property Items: TPressProjectItemReferences read FItems;
    property ModuleIntf: IPressIDEModule read FModuleIntf write SetModuleIntf;
  published
    property Name: string read GetName write SetName;
  end;

  TPressProjectModuleIterator = class;

  TPressProjectModuleReferences = class(TPressReferences)
  private
    function GetObjects(AIndex: Integer): TPressProjectModule;
    procedure SetObjects(AIndex: Integer; const Value: TPressProjectModule);
  protected
    function InternalCreateIterator: TPressItemsIterator; override;
  public
    function Add: TPressProjectModule; overload;
    function Add(AObject: TPressProjectModule): Integer; overload;
    function CreateIterator: TPressItemsIterator;
    function FindClass(const AName: string): TPressProjectClass;
    function FindModule(AModule: IPressIDEModule): TPressProjectModule;
    function IndexOf(AObject: TPressProjectModule): Integer;
    procedure Insert(AIndex: Integer; AObject: TPressProjectModule);
    function ModuleByIntf(AModule: IPressIDEModule): TPressProjectModule;
    function Remove(AObject: TPressProjectModule): Integer;
    class function ValidObjectClass: TPressObjectClass; override;
    property Objects[AIndex: Integer]: TPressProjectModule read GetObjects write SetObjects; default;
  end;

  TPressProjectModuleIterator = class(TPressItemsIterator)
  private
    function GetCurrentItem: TPressProjectModule;
  public
    property CurrentItem: TPressProjectModule read GetCurrentItem;
  end;

  TPressProject = class(TPressObject)
  private
    FRootBusinessClasses: TPressProjectClass;
    FRootPersistentClasses: TPressObjectMetadataRegistry;
    FRootQueryClasses: TPressObjectMetadataRegistry;
    FRootModels: TPressProjectClass;
    FRootViews: TPressProjectClass;
    FRootPresenters: TPressProjectClass;
    FRootCommands: TPressProjectClass;
    FRootInteractors: TPressProjectClass;
    FRootUserAttributes: TPressAttributeTypeRegistry;
    FRootUserEnumerations: TPressProjectItem;
    FRootUserGenerators: TPressProjectClass;
    FRootForms: TPressProjectClass;
    FRootFrames: TPressProjectClass;
    FRootUnknownClasses: TPressProjectClass;
    procedure CreateRootItems;
    procedure PopulatePressAttributeRegistry;
  private
    FName: TPressString;
    FRootItems: TPressProjectItemReferences;
    FModules: TPressProjectModuleReferences;
    FPressAttributeRegistry: TPressProjectClassReferences;
    function GetName: string;
    procedure SetName(const Value: string);
  protected
    procedure Init; override;
    function InternalAttributeAddress(const AAttributeName: string): PPressAttribute; override;
    class function InternalMetadataStr: string; override;
  public
    procedure ClearItems;
    property RootBusinessClasses: TPressProjectClass read FRootBusinessClasses;
    property RootCommands: TPressProjectClass read FRootCommands;
    property RootForms: TPressProjectClass read FRootForms;
    property RootFrames: TPressProjectClass read FRootFrames;
    property RootInteractors: TPressProjectClass read FRootInteractors;
    property RootModels: TPressProjectClass read FRootModels;
    property RootPersistentClasses: TPressObjectMetadataRegistry read FRootPersistentClasses;
    property RootPresenters: TPressProjectClass read FRootPresenters;
    property RootQueryClasses: TPressObjectMetadataRegistry read FRootQueryClasses;
    property RootUnknownClasses: TPressProjectClass read FRootUnknownClasses;
    property RootUserAttributes: TPressAttributeTypeRegistry read FRootUserAttributes;
    property RootUserEnumerations: TPressProjectItem read FRootUserEnumerations;
    property RootUserGenerators: TPressProjectClass read FRootUserGenerators;
    property RootViews: TPressProjectClass read FRootViews;
  public
    property Modules: TPressProjectModuleReferences read FModules;
    property RootItems: TPressProjectItemReferences read FRootItems;
    property PressAttributeRegistry: TPressProjectClassReferences read FPressAttributeRegistry;
  published
    property Name: string read GetName write SetName;
  end;

implementation

uses
  SysUtils,
  PressConsts,
  PressPicture,
  PressParser,
  PressDesignClasses,
  PressDesignConsts;

{ TPressProjectItem }

function TPressProjectItem.GetModule: TPressProjectModule;
begin
  Result := FModule.Value as TPressProjectModule;
end;

function TPressProjectItem.GetName: string;
begin
  Result := FName.Value;
end;

function TPressProjectItem.InternalAttributeAddress(
  const AAttributeName: string): PPressAttribute;
begin
  if SameText(AAttributeName, 'Name') then
    Result := Addr(FName)
  else if SameText(AAttributeName, 'Module') then
    Result := Addr(FModule)
  else if SameText(AAttributeName, 'ChildItems') then
    Result := Addr(FChildItems)
  else
    Result := inherited InternalAttributeAddress(AAttributeName);
end;

class function TPressProjectItem.InternalMetadataStr: string;
begin
  Result := 'TPressProjectItem (' +
   'Name: String;' +
   'Module: Reference(TPressProjectModule) WeakReference;' +
   'ChildItems: TPressProjectItemReferences)';
end;

procedure TPressProjectItem.SetModule(Value: TPressProjectModule);
begin
  FModule.Value := Value;
end;

procedure TPressProjectItem.SetName(const Value: string);
begin
  FName.Value := Value;
end;

{ TPressProjectItemReferences }

function TPressProjectItemReferences.Add(
  AClass: TPressProjectItemClass): TPressProjectItem;
begin
  Result := inherited Add(AClass) as TPressProjectItem;
end;

function TPressProjectItemReferences.Add(AObject: TPressProjectItem): Integer;
begin
  Result := inherited Add(AObject);
end;

function TPressProjectItemReferences.CreateIterator: TPressProjectItemIterator;
begin
  Result := TPressProjectItemIterator.Create(ProxyList);
end;

function TPressProjectItemReferences.FindItem(
  const AName: string; AClass: TPressProjectItemClass;
  ARecursively: Boolean): TPressProjectItem;
var
  I: Integer;
begin
  if AName <> '' then
    for I := 0 to Pred(Count) do
    begin
      Result := Objects[I];
      if ((not Assigned(AClass)) or (Result is AClass)) and
       SameText(Result.Name, AName) then
        Exit;
      if ARecursively then
      begin
        Result := Result.ChildItems.FindItem(AName, AClass);
        if Assigned(Result) then
          Exit;
      end;
    end;
  Result := nil;
end;

function TPressProjectItemReferences.GetObjects(
  AIndex: Integer): TPressProjectItem;
begin
  Result := inherited Objects[AIndex] as TPressProjectItem;
end;

function TPressProjectItemReferences.IndexOf(
  AObject: TPressProjectItem): Integer;
begin
  Result := inherited IndexOf(AObject);
end;

procedure TPressProjectItemReferences.Insert(AIndex: Integer;
  AObject: TPressProjectItem);
begin
  inherited Insert(AIndex, AObject);
end;

function TPressProjectItemReferences.InternalCreateIterator: TPressItemsIterator;
begin
  Result := CreateIterator;
end;

function TPressProjectItemReferences.Remove(
  AObject: TPressProjectItem): Integer;
begin
  Result := inherited Remove(AObject);
end;

procedure TPressProjectItemReferences.SetObjects(AIndex: Integer;
  const Value: TPressProjectItem);
begin
  inherited Objects[AIndex] := Value;
end;

class function TPressProjectItemReferences.ValidObjectClass: TPressObjectClass;
begin
  Result := TPressProjectItem;
end;

{ TPressProjectItemIterator }

function TPressProjectItemIterator.GetCurrentItem: TPressProjectItem;
begin
  Result := inherited CurrentItem as TPressProjectItem;
end;

{ TPressProjectClass }

function TPressProjectClass.GetChildItems: TPressProjectClassReferences;
begin
  Result := inherited ChildItems as TPressProjectClassReferences;
end;

function TPressProjectClass.GetObjectClassName: string;
begin
  Result := FObjectClassName.Value;
end;

function TPressProjectClass.GetParentClass: TPressProjectClass;
begin
  Result := FParentClass.Value as TPressProjectClass;
end;

function TPressProjectClass.InternalAttributeAddress(
  const AAttributeName: string): PPressAttribute;
begin
  if SameText(AAttributeName, 'ObjectClassName') then
    Result := Addr(FObjectClassName)
  else if SameText(AAttributeName, 'ParentClass') then
    Result := Addr(FParentClass)
  else
    Result := inherited InternalAttributeAddress(AAttributeName);
end;

class function TPressProjectClass.InternalMetadataStr: string;
begin
  Result := 'TPressProjectClass (' +
   'ChildItems: TPressProjectClassReferences;' +
   'ObjectClassName: String;' +
   'ParentClass: Reference(TPressProjectClass) WeakReference)';
end;

procedure TPressProjectClass.SetObjectClassName(const Value: string);
begin
  FObjectClassName.Value := Value;
  if Name = '' then
    Name := Value;
end;

procedure TPressProjectClass.SetParentClass(Value: TPressProjectClass);
begin
  FParentClass.Value := Value;
end;

{ TPressProjectClassReferences }

function TPressProjectClassReferences.Add(
  AObject: TPressProjectClass): Integer;
begin
  Result := inherited Add(AObject);
end;

function TPressProjectClassReferences.Add(
  AClass: TPressProjectClassClass): TPressProjectClass;
begin
  Result := inherited Add(AClass) as TPressProjectClass;
end;

function TPressProjectClassReferences.CreateIterator: TPressProjectClassIterator;
begin
  Result := TPressProjectClassIterator.Create(ProxyList);
end;

function TPressProjectClassReferences.GetObjects(
  AIndex: Integer): TPressProjectClass;
begin
  Result := inherited Objects[AIndex] as TPressProjectClass;
end;

function TPressProjectClassReferences.IndexOf(
  AObject: TPressProjectClass): Integer;
begin
  Result := inherited IndexOf(AObject);
end;

procedure TPressProjectClassReferences.Insert(
  AIndex: Integer; AObject: TPressProjectClass);
begin
  inherited Insert(AIndex, AObject);
end;

function TPressProjectClassReferences.InternalCreateIterator: TPressItemsIterator;
begin
  Result := CreateIterator;
end;

function TPressProjectClassReferences.Remove(
  AObject: TPressProjectClass): Integer;
begin
  Result := inherited Remove(AObject);
end;

procedure TPressProjectClassReferences.SetObjects(
  AIndex: Integer; const Value: TPressProjectClass);
begin
  inherited Objects[AIndex] := Value;
end;

class function TPressProjectClassReferences.ValidObjectClass: TPressObjectClass;
begin
  Result := TPressProjectClass;
end;

{ TPressProjectClassIterator }

function TPressProjectClassIterator.GetCurrentItem: TPressProjectClass;
begin
  Result := inherited CurrentItem as TPressProjectClass;
end;

{ TPressObjectMetadataRegistry }

function TPressObjectMetadataRegistry.GetIsPersistent: Boolean;
begin
  Result := FIsPersistent.Value;
end;

function TPressObjectMetadataRegistry.GetKeyName: string;
begin
  Result := FKeyName.Value;
end;

function TPressObjectMetadataRegistry.GetMetadataStr: string;
begin
  Result := FMetadataStr.Value;
  if Result = '' then
  begin
    Result := ObjectClassName;
    FMetadataStr.Value := Result;
  end;
end;

function TPressObjectMetadataRegistry.GetParentClass: TPressObjectMetadataRegistry;
begin
  Result := inherited ParentClass as TPressObjectMetadataRegistry;
end;

function TPressObjectMetadataRegistry.GetPersistentName: string;
begin
  Result := FPersistentName.Value;
end;

function TPressObjectMetadataRegistry.InsertLineBreak(const AStr: string): string;
var
  VReader: TPressParserReader;
  VDelta, VPos: Integer;
begin
  VReader := TPressParserReader.Create(AStr);
  try
    while not VReader.Eof and (VReader.ReadToken <> '(') do
      ;
    VDelta := 0;
    Result := AStr;
    while not VReader.Eof do
    begin
      VPos := VReader.Position.Position + VDelta;
      if Copy(Result, VPos, Length(SPressLineBreak)) <> SPressLineBreak then
      begin
        Insert(SPressLineBreak, Result, VPos);
        Inc(VDelta, Length(SPressLineBreak));
      end;
      while not VReader.Eof and (VReader.ReadToken <> ';') do
        ;
    end;
  finally
    VReader.Free;
  end;
end;

function TPressObjectMetadataRegistry.InternalAttributeAddress(
  const AAttributeName: string): PPressAttribute;
begin
  if SameText(AAttributeName, 'MetadataStr') then
    Result := Addr(FMetadataStr)
  else if SameText(AAttributeName, 'KeyName') then
    Result := Addr(FKeyName)
  else if SameText(AAttributeName, 'IsPersistent') then
    Result := Addr(FIsPersistent)
  else if SameText(AAttributeName, 'PersistentName') then
    Result := Addr(FPersistentName)
  else if SameText(AAttributeName, 'AttributeList') then
    Result := Addr(FAttributeList)
  else
    Result := inherited InternalAttributeAddress(AAttributeName);
end;

class function TPressObjectMetadataRegistry.InternalMetadataStr: string;
begin
  Result := 'TPressObjectMetadataRegistry (' +
   'ChildItems: TPressProjectClassReferences(TPressObjectMetadataRegistry);' +
   'ParentClass: Reference(TPressObjectMetadataRegistry) WeakReference;' +
   'MetadataStr: Memo;' +
   'KeyName: String;' +
   'IsPersistent: Boolean;' +
   'PersistentName: String;' +
   'AttributeList: TPressAttributeMetadataRegistryParts)';
end;

procedure TPressObjectMetadataRegistry.SetIsPersistent(Value: Boolean);
begin
  FIsPersistent.Value := Value;
end;

procedure TPressObjectMetadataRegistry.SetKeyName(const Value: string);
begin
  FKeyName.Value := Value;
end;

procedure TPressObjectMetadataRegistry.SetMetadataStr(const Value: string);
begin
  FMetadataStr.Value := InsertLineBreak(Value);
end;

procedure TPressObjectMetadataRegistry.SetParentClass(
  Value: TPressObjectMetadataRegistry);
begin
  inherited ParentClass := Value;
end;

procedure TPressObjectMetadataRegistry.SetPersistentName(const Value: string);
begin
  FPersistentName.Value := Value;
end;

procedure TPressObjectMetadataRegistry.UpdateRuntimeMetadata;
begin
  { TODO : Implement }
  MetadataStr := InsertLineBreak(MetadataStr);
end;

{ TPressAttributeMetadataRegistry }

function TPressAttributeMetadataRegistry.GetAttributeType: TPressAttributeTypeRegistry;
begin
  Result := FAttributeType.Value as TPressAttributeTypeRegistry;
end;

function TPressAttributeMetadataRegistry.GetContainerType: TPressObjectMetadataRegistry;
begin
  Result := FContainerType.Value as TPressObjectMetadataRegistry;
end;

function TPressAttributeMetadataRegistry.GetName: string;
begin
  Result := FName.Value;
end;

function TPressAttributeMetadataRegistry.GetSize: Integer;
begin
  Result := FSize.Value;
end;

function TPressAttributeMetadataRegistry.InternalAttributeAddress(
  const AAttributeName: string): PPressAttribute;
begin
  if SameText(AAttributeName, 'Name') then
    Result := Addr(FName)
  else if SameText(AAttributeName, 'AttributeType') then
    Result := Addr(FAttributeType)
  else if SameText(AAttributeName, 'Size') then
    Result := Addr(FSize)
  else if SameText(AAttributeName, 'ContainerType') then
    Result := Addr(FContainerType)
  else if SameText(AAttributeName, 'DefaultValue') then
    Result := Addr(FDefaultValue)
  else if SameText(AAttributeName, 'EditMask') then
    Result := Addr(FEditMask)
  else if SameText(AAttributeName, 'IsPersistent') then
    Result := Addr(FIsPersistent)
  else if SameText(AAttributeName, 'PersistentName') then
    Result := Addr(FPersistentName)
  else if SameText(AAttributeName, 'PersLinkName') then
    Result := Addr(FPersLinkName)
  else if SameText(AAttributeName, 'PersLinkIdName') then
    Result := Addr(FPersLinkIdName)
  else if SameText(AAttributeName, 'PersLinkParentName') then
    Result := Addr(FPersLinkParentName)
  else if SameText(AAttributeName, 'PersLinkChildName') then
    Result := Addr(FPersLinkChildName)
  else if SameText(AAttributeName, 'PersLinkPosName') then
    Result := Addr(FPersLinkPosName)
  else
    Result := inherited InternalAttributeAddress(AAttributeName);
end;

class function TPressAttributeMetadataRegistry.InternalMetadataStr: string;
begin
  Result := 'TPressAttributeMetadataRegistry (' +
   'Name: String;' +
   'AttributeType: Reference(TPressAttributeTypeRegistry);' +
   'Size: Integer;' +
   'ContainerType: Reference(TPressObjectMetadataRegistry);' +
   'DefaultValue: String;' +
   'EditMask: String;' +
   'IsPersistent: Boolean;' +
   'PersistentName: String;' +
   'PersLinkName: String;' +
   'PersLinkIdName: String;' +
   'PersLinkParentName: String;' +
   'PersLinkChildName: String;' +
   'PersLinkPosName: String)';
end;

procedure TPressAttributeMetadataRegistry.SetAttributeType(
  Value: TPressAttributeTypeRegistry);
begin
  FAttributeType.Value := Value;
end;

procedure TPressAttributeMetadataRegistry.SetContainerType(
  Value: TPressObjectMetadataRegistry);
begin
  FContainerType.Value := Value;
end;

procedure TPressAttributeMetadataRegistry.SetName(const Value: string);
begin
  FName.Value := Value;
end;

procedure TPressAttributeMetadataRegistry.SetSize(Value: Integer);
begin
  FSize.Value := Value;
end;

{ TPressAttributeMetadataRegistryParts }

function TPressAttributeMetadataRegistryParts.Add: TPressAttributeMetadataRegistry;
begin
  Result := inherited Add as TPressAttributeMetadataRegistry;
end;

function TPressAttributeMetadataRegistryParts.Add(
  AObject: TPressAttributeMetadataRegistry): Integer;
begin
  Result := inherited Add(AObject);
end;

function TPressAttributeMetadataRegistryParts.CreateIterator: TPressAttributeMetadataRegistryIterator;
begin
  Result := TPressAttributeMetadataRegistryIterator.Create(ProxyList);
end;

function TPressAttributeMetadataRegistryParts.GetObjects(
  AIndex: Integer): TPressAttributeMetadataRegistry;
begin
  Result := inherited Objects[AIndex] as TPressAttributeMetadataRegistry;
end;

function TPressAttributeMetadataRegistryParts.IndexOf(
  AObject: TPressAttributeMetadataRegistry): Integer;
begin
  Result := inherited IndexOf(AObject);
end;

procedure TPressAttributeMetadataRegistryParts.Insert(AIndex: Integer;
  AObject: TPressAttributeMetadataRegistry);
begin
  inherited Insert(AIndex, AObject);
end;

function TPressAttributeMetadataRegistryParts.InternalCreateIterator: TPressItemsIterator;
begin
  Result := CreateIterator;
end;

function TPressAttributeMetadataRegistryParts.Remove(
  AObject: TPressAttributeMetadataRegistry): Integer;
begin
  Result := inherited Remove(AObject);
end;

procedure TPressAttributeMetadataRegistryParts.SetObjects(
  AIndex: Integer; Value: TPressAttributeMetadataRegistry);
begin
  inherited Objects[AIndex] := Value;
end;

class function TPressAttributeMetadataRegistryParts.ValidObjectClass: TPressObjectClass;
begin
  Result := TPressAttributeMetadataRegistry;
end;

{ TPressAttributeMetadataRegistryIterator }

function TPressAttributeMetadataRegistryIterator.GetCurrentItem: TPressAttributeMetadataRegistry;
begin
  Result := inherited CurrentItem as TPressAttributeMetadataRegistry;
end;

{ TPressAttributeTypeRegistry }

class function TPressAttributeTypeRegistry.InternalMetadataStr: string;
begin
  Result := 'TPressAttributeTypeRegistry (' +
   'ChildItems: TPressProjectClassReferences(TPressAttributeTypeRegistry))';
end;

{ TPressEnumerationRegistry }

class function TPressEnumerationRegistry.InternalMetadataStr: string;
begin
  Result := 'TPressEnumerationRegistry (' +
   'ChildItems: TPressProjectItemReferences(TPressEnumerationRegistry);' +
   ')';
end;

{ TPressProjectModule }

function TPressProjectModule.FindClass(
  const AName: string): TPressProjectClass;
begin
  Result :=
   Items.FindItem(AName, TPressProjectClass, False) as TPressProjectClass;
end;

function TPressProjectModule.GetName: string;
begin
  Result := FName.Value;
end;

function TPressProjectModule.InternalAttributeAddress(
  const AAttributeName: string): PPressAttribute;
begin
  if SameText(AAttributeName, 'Name') then
    Result := Addr(FName)
  else if SameText(AAttributeName, 'Items') then
    Result := Addr(FItems)
  else
    Result := inherited InternalAttributeAddress(AAttributeName);
end;

class function TPressProjectModule.InternalMetadataStr: string;
begin
  Result := 'TPressProjectModule (' +
   'Name: String;' +
   'Items: TPressProjectItemReferences)';
end;

procedure TPressProjectModule.SetModuleIntf(const Value: IPressIDEModule);
begin
  FModuleIntf := Value;
  if Name = '' then
    Name := ModuleIntf.Name;
end;

procedure TPressProjectModule.SetName(const Value: string);
begin
  FName.Value := Value;
end;

{ TPressProjectModuleReferences }

function TPressProjectModuleReferences.Add: TPressProjectModule;
begin
  Result := inherited Add as TPressProjectModule;
end;

function TPressProjectModuleReferences.Add(AObject: TPressProjectModule): Integer;
begin
  Result := inherited Add(AObject);
end;

function TPressProjectModuleReferences.CreateIterator: TPressItemsIterator;
begin
  Result := TPressProjectModuleIterator.Create(ProxyList);
end;

function TPressProjectModuleReferences.FindClass(
  const AName: string): TPressProjectClass;
var
  VModule: TPressProjectModule;
  I: Integer;
begin
  for I := 0 to Pred(Count) do
  begin
    VModule := Objects[I];
    Result := VModule.FindClass(AName);
    if Assigned(Result) then
      Exit;
  end;
  Result := nil;
end;

function TPressProjectModuleReferences.FindModule(
  AModule: IPressIDEModule): TPressProjectModule;
var
  I: Integer;
begin
  for I := 0 to Pred(Count) do
  begin
    Result := Objects[I];
    if Result.ModuleIntf = AModule then
      Exit;
  end;
  Result := nil;
end;

function TPressProjectModuleReferences.GetObjects(AIndex: Integer): TPressProjectModule;
begin
  Result := inherited Objects[AIndex] as TPressProjectModule;
end;

function TPressProjectModuleReferences.IndexOf(AObject: TPressProjectModule): Integer;
begin
  Result := IndexOf(AObject);
end;

procedure TPressProjectModuleReferences.Insert(
  AIndex: Integer; AObject: TPressProjectModule);
begin
  inherited Insert(AIndex, AObject);
end;

function TPressProjectModuleReferences.InternalCreateIterator: TPressItemsIterator;
begin
  Result := CreateIterator;
end;

function TPressProjectModuleReferences.ModuleByIntf(
  AModule: IPressIDEModule): TPressProjectModule;
begin
  Result := FindModule(AModule);
  if not Assigned(Result) then
    raise EPressDesignError.CreateFmt(SModuleNotFound, [AModule.Name]);
end;

function TPressProjectModuleReferences.Remove(AObject: TPressProjectModule): Integer;
begin
  Result := inherited Remove(AObject);
end;

procedure TPressProjectModuleReferences.SetObjects(
  AIndex: Integer; const Value: TPressProjectModule);
begin
  inherited Objects[AIndex] := Value;
end;

class function TPressProjectModuleReferences.ValidObjectClass: TPressObjectClass;
begin
  Result := TPressProjectModule;
end;

{ TPressProjectModuleIterator }

function TPressProjectModuleIterator.GetCurrentItem: TPressProjectModule;
begin
  Result := inherited CurrentItem as TPressProjectModule;
end;

{ TPressProject }

procedure TPressProject.ClearItems;
begin
  RootItems.Clear;
  PressAttributeRegistry.Clear;
  Modules.Clear;
  CreateRootItems;
end;

procedure TPressProject.CreateRootItems;
begin
  PopulatePressAttributeRegistry;
  RootItems.Add(TPressProjectClass).Name := SPressProjectBusinessClasses;
  FRootBusinessClasses := RootItems[0] as TPressProjectClass;
  with FRootBusinessClasses.ChildItems as TPressProjectClassReferences do
  begin
    Add(TPressObjectMetadataRegistry).Name := SPressProjectPersistentClasses;
    Add(TPressObjectMetadataRegistry).Name := SPressProjectQueryClasses;
    FRootPersistentClasses := Objects[0] as TPressObjectMetadataRegistry;
    FRootPersistentClasses.ObjectClassName := TPressObject.ClassName;
    FRootQueryClasses := Objects[1] as TPressObjectMetadataRegistry;
    FRootQueryClasses.ObjectClassName := TPressQuery.ClassName;
  end;
  RootItems.Add(TPressProjectClass).Name := SPressProjectMVPClasses;
  with RootItems[1].ChildItems as TPressProjectClassReferences do
  begin
    Add.Name := SPressProjectModels;
    Add.Name := SPressProjectViews;
    Add.Name := SPressProjectPresenters;
    Add.Name := SPressProjectCommands;
    Add.Name := SPressProjectInteractors;
    FRootModels := Objects[0];
    FRootViews := Objects[1];
    FRootPresenters := Objects[2];
    FRootCommands := Objects[3];
    FRootInteractors := Objects[4];
  end;
  RootItems.Add(TPressProjectClass).Name := SPressProjectRegisteredClasses;
  with RootItems[2].ChildItems as TPressProjectClassReferences do
  begin
    Add(TPressAttributeTypeRegistry).Name := SPressProjectUserAttributes;
    Add.Name := SPressProjectUserOIDGenerators;
    FRootUserAttributes := Objects[0] as TPressAttributeTypeRegistry;
    FRootUserGenerators := Objects[1];
    FRootUserGenerators.ObjectClassName := SPressOIDGeneratorClassNameStr;
  end;
  RootItems.Add(TPressProjectItem).Name := SPressProjectRegisteredItems;
  with RootItems[3].ChildItems do
  begin
    Add.Name := SPressProjectUserEnumerations;
    FRootUserEnumerations := Objects[0];
  end;
  RootItems.Add(TPressProjectClass).Name := SPressProjectOtherClasses;
  with RootItems[4].ChildItems as TPressProjectClassReferences do
  begin
    Add.Name := SPressProjectForms;
    Add.Name := SPressProjectFrames;
    Add.Name := SPressProjectUnknown;
    FRootForms := Objects[0];
    FRootForms.ObjectClassName := SPressFormClassNameStr;
    FRootFrames := Objects[1];
    FRootFrames.ObjectClassName := SPressFrameClassNameStr;
    FRootUnknownClasses := Objects[2];
  end;
end;

function TPressProject.GetName: string;
begin
  Result := FName.Value;
end;

procedure TPressProject.Init;
begin
  inherited;
  CreateRootItems;
end;

function TPressProject.InternalAttributeAddress(
  const AAttributeName: string): PPressAttribute;
begin
  if SameText(AAttributeName, 'Name') then
    Result := Addr(FName)
  else if SameText(AAttributeName, 'RootItems') then
    Result := Addr(FRootItems)
  else if SameText(AAttributeName, 'Modules') then
    Result := Addr(FModules)
  else if SameText(AAttributeName, 'PressAttributeRegistry') then
    Result := Addr(FPressAttributeRegistry)
  else
    Result := inherited InternalAttributeAddress(AAttributeName);
end;

class function TPressProject.InternalMetadataStr: string;
begin
  Result := 'TPressProject (' +
   'Name: String;' +
   'RootItems: TPressProjectItemReferences;' +
   'Modules: TPressProjectModuleReferences;' +
   'PressAttributeRegistry: TPressProjectClassReferences(TPressAttributeTypeRegistry))';
end;

procedure TPressProject.PopulatePressAttributeRegistry;

  procedure IncludeAttributeClasses(
    AAttributes: array of TPressAttributeClass);
  var
    VItem: TPressProjectClass;
    I: Integer;
  begin
    for I := 0 to Pred(Length(AAttributes)) do
    begin
      VItem := PressAttributeRegistry.Add;
      VItem.Name := AAttributes[I].AttributeName;
      VItem.ObjectClassName := AAttributes[I].ClassName;
    end;
  end;

begin
  IncludeAttributeClasses([TPressString, TPressInteger, TPressFloat,
   TPressCurrency, TPressEnum, TPressBoolean,
   TPressDate, TPressTime, TPressDateTime,
   TPressVariant, TPressMemo, TPressBinary, TPressPicture,
   TPressPart, TPressReference, TPressParts, TPressReferences]);
end;

procedure TPressProject.SetName(const Value: string);
begin
  FName.Value := Value;
end;

initialization
  TPressProject.RegisterClass;
  TPressProjectItem.RegisterClass;
  TPressProjectClass.RegisterClass;
  TPressObjectMetadataRegistry.RegisterClass;
  TPressAttributeMetadataRegistry.RegisterClass;
  TPressAttributeTypeRegistry.RegisterClass;
  TPressEnumerationRegistry.RegisterClass;
  TPressProjectModule.RegisterClass;
  TPressProjectItemReferences.RegisterAttribute;
  TPressProjectClassReferences.RegisterAttribute;
  TPressAttributeMetadataRegistryParts.RegisterAttribute;
  TPressProjectModuleReferences.RegisterAttribute;

end.
