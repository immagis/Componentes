unit ContactBO;

{$I PhoneBook.inc}

interface

uses
  PressSubject, PressAttributes;

type
{$M+}
  TAddress = class;
  TPhoneParts = class;
{$M-}

  TCustomObject = class(TPressObject)
  end;

  TContact = class(TCustomObject)
    _Name: TPressAnsiString;
    _Address: TPressPart;
    _Phones: TPhoneParts;
  private
    function GetAddress: TAddress;
    function GetName: string;
    procedure SetAddress(Value: TAddress);
    procedure SetName(const Value: string);
  protected
    class function InternalMetadataStr: string; override;
  public
    property Phones: TPhoneParts read _Phones;
  published
    property Name: string read GetName write SetName;
    property Address: TAddress read GetAddress write SetAddress;
  end;

  TPerson = class(TContact)
    _NickName: TPressAnsiString;
  private
    function GetNickName: string;
    procedure SetNickName(const Value: string);
  protected
    class function InternalMetadataStr: string; override;
  published
    property NickName: string read GetNickName write SetNickName;
  end;

  TCompany = class(TContact)
    _Contact: TPressReference;
  private
    function GetContact: TPerson;
    procedure SetContact(Value: TPerson);
  protected
    class function InternalMetadataStr: string; override;
  published
    property Contact: TPerson read GetContact write SetContact;
  end;

  TPhoneType = (ptPhone, ptFax, ptMobile);

  TPhone = class(TCustomObject)
    _PhoneType: TPressEnum;
    _Number: TPressAnsiString;
  private
    function GetNumber: string;
    function GetPhoneType: TPhoneType;
    procedure SetNumber(const Value: string);
    procedure SetPhoneType(Value: TPhoneType);
  protected
    class function InternalMetadataStr: string; override;
  published
    property PhoneType: TPhoneType read GetPhoneType write SetPhoneType;
    property Number: string read GetNumber write SetNumber;
  end;

  TPhoneParts = class(TPressParts)
  private
    function GetObjects(AIndex: Integer): TPhone;
    procedure SetObjects(AIndex: Integer; const Value: TPhone);
  public
    function Add: TPhone;
    class function ValidObjectClass: TPressObjectClass; override;
    property Objects[AIndex: Integer]: TPhone read GetObjects write SetObjects; default;
  end;

  TCity = class;

  TAddress = class(TCustomObject)
    _Street: TPressAnsiString;
    _Zip: TPressAnsiString;
    _City: TPressReference;
  private
    function GetCity: TCity;
    function GetStreet: string;
    function GetZip: string;
    procedure SetCity(Value: TCity);
    procedure SetStreet(const Value: string);
    procedure SetZip(const Value: string);
  protected
    class function InternalMetadataStr: string; override;
  published
    property Street: string read GetStreet write SetStreet;
    property Zip: string read GetZip write SetZip;
    property City: TCity read GetCity write SetCity;
  end;

  TCity = class(TCustomObject)
    _Name: TPressAnsiString;
    _State: TPressAnsiString;
  private
    function GetName: string;
    function GetState: string;
    procedure SetName(const Value: string);
    procedure SetState(const Value: string);
  protected
    class function InternalMetadataStr: string; override;
  published
    property Name: string read GetName write SetName;
    property State: string read GetState write SetState;
  end;

  TMainQuery = class(TPressQuery)
    _Name: TPressAnsiString;
  private
    function GetName: string;
    procedure SetName(const Value: string);
  protected
    class function InternalMetadataStr: string; override;
  published
    property Name: string read GetName write SetName;
  end;

implementation

uses
  PressSession;

{ TContact }

function TContact.GetAddress: TAddress;
begin
  Result := _Address.Value as TAddress;
end;

function TContact.GetName: string;
begin
  Result := _Name.Value;
end;

class function TContact.InternalMetadataStr: string;
begin
  Result := 'TContact IsPersistent (' +
   'Name: AnsiString(40) NotNull;' +
   'Address: Part(TAddress);' +
   'Phones: TPhoneParts;' +
   ')';
end;

procedure TContact.SetAddress(Value: TAddress);
begin
  _Address.Value := Value;
end;

procedure TContact.SetName(const Value: string);
begin
  _Name.Value := Value;
end;

{ TPerson }

function TPerson.GetNickName: string;
begin
  Result := _NickName.Value;
end;

class function TPerson.InternalMetadataStr: string;
begin
  Result := 'TPerson IsPersistent (' +
   'NickName: AnsiString(20) NotNull;' +
   ')';
end;

procedure TPerson.SetNickName(const Value: string);
begin
  _NickName.Value := Value;
end;

{ TCompany }

function TCompany.GetContact: TPerson;
begin
  Result := _Contact.Value as TPerson;
end;

class function TCompany.InternalMetadataStr: string;
begin
  Result := 'TCompany IsPersistent (' +
   'Contact: Reference(TPerson);' +
   ')';
end;

procedure TCompany.SetContact(Value: TPerson);
begin
  _Contact.Value := Value;
end;

{ TPhone }

function TPhone.GetNumber: string;
begin
  Result := _Number.Value;
end;

function TPhone.GetPhoneType: TPhoneType;
begin
  Result := TPhoneType(_PhoneType.Value);
end;

class function TPhone.InternalMetadataStr: string;
begin
  Result := 'TPhone IsPersistent OwnerClass=TContact (' +
   'PhoneType: Enum(TPhoneType);' +
   'Number: AnsiString(15) PersistentName="PhoneNumber" NotNull;' +
   ')';
end;

procedure TPhone.SetNumber(const Value: string);
begin
  _Number.Value := Value;
end;

procedure TPhone.SetPhoneType(Value: TPhoneType);
begin
  _PhoneType.Value := Ord(Value);
end;

{ TPhoneParts }

function TPhoneParts.Add: TPhone;
begin
  Result := inherited Add as TPhone;
end;

function TPhoneParts.GetObjects(AIndex: Integer): TPhone;
begin
  Result := inherited Objects[AIndex] as TPhone;
end;

procedure TPhoneParts.SetObjects(AIndex: Integer; const Value: TPhone);
begin
  inherited Objects[AIndex] := Value;
end;

class function TPhoneParts.ValidObjectClass: TPressObjectClass;
begin
  Result := TPhone;
end;

{ TAddress }

function TAddress.GetCity: TCity;
begin
  Result := _City.Value as TCity;
end;

function TAddress.GetStreet: string;
begin
  Result := _Street.Value;
end;

function TAddress.GetZip: string;
begin
  Result := _Zip.Value;
end;

class function TAddress.InternalMetadataStr: string;
begin
  Result := 'TAddress IsPersistent (' +
   'Street: AnsiString(40);' +
   'Zip: AnsiString(10);' +
   'City: Reference(TCity);' +
   ')';
end;

procedure TAddress.SetCity(Value: TCity);
begin
  _City.Value := Value;
end;

procedure TAddress.SetStreet(const Value: string);
begin
  _Street.Value := Value;
end;

procedure TAddress.SetZip(const Value: string);
begin
  _Zip.Value := Value;
end;

{ TCity }

function TCity.GetName: string;
begin
  Result := _Name.Value;
end;

function TCity.GetState: string;
begin
  Result := _State.Value;
end;

class function TCity.InternalMetadataStr: string;
begin
  Result := 'TCity IsPersistent (' +
   'Name: AnsiString(30) NotNull;' +
   'State: AnsiString(5) NotNull;' +
   ')';
end;

procedure TCity.SetName(const Value: string);
begin
  _Name.Value := Value;
end;

procedure TCity.SetState(const Value: string);
begin
  _State.Value := Value;
end;

{ TMainQuery }

function TMainQuery.GetName: string;
begin
  Result := _Name.Value;
end;

class function TMainQuery.InternalMetadataStr: string;
begin
  Result := 'TMainQuery(TContact) Any Order=Name (' +
   'Name: AnsiString(40) MatchType=mtContains;' +
   ')';
end;

procedure TMainQuery.SetName(const Value: string);
begin
  _Name.Value := Value;
end;

initialization
  PressModel.RegisterEnumMetadata(TypeInfo(TPhoneType), 'TPhoneType');
  PressModel.ClassIdStorageName := 'ClassStore';
  TCustomObject.RegisterClass;
  TContact.RegisterClass;
  TPerson.RegisterClass;
  TCompany.RegisterClass;
  TPhone.RegisterClass;
  TAddress.RegisterClass;
  TCity.RegisterClass;
  TMainQuery.RegisterClass;
  TPhoneParts.RegisterAttribute;

end.
