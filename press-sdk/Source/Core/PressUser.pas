(*
  PressObjects, User Control Classes
  Copyright (C) 2006-2007 Laserpress Ltda.

  http://www.pressobjects.org

  See the file LICENSE.txt, included in this distribution,
  for details about the copyright.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*)

unit PressUser;

{$I Press.inc}

interface

uses
  PressClasses,
  PressApplication,
  PressNotifier,
  PressSubject,
  PressSession;

const
  CPressUserDataService = CPressUserServicesBase + $0001;

type
  EPressUserError = class(EPressError);

  TPressUserEvent = class(TPressEvent)
  end;

  TPressUserLogonEvent = class(TPressUserEvent)
  end;

  TPressUserLogoffEvent = class(TPressUserEvent)
  end;

  TPressAccessMode = (amInvisible, amVisible, amWritable);

  TPressUserClass = class of TPressCustomUser;

  TPressCustomUser = class(TPressObject)
  protected
    procedure AfterLogon; virtual;
    procedure BeforeLogoff; virtual;
    function InternalAccessMode(AResourceId: Integer): TPressAccessMode; virtual;
  public
    function AccessMode(AResourceId: Integer): TPressAccessMode;
  end;

  TPressCustomUserData = class(TPressService)
  private
    FCurrentUser: TPressCustomUser;
    FSession: TPressSession;
    function GetCurrentUser: TPressCustomUser;
    function GetHasUser: Boolean;
    function GetSession: TPressSession;
    procedure SetSession(Value: TPressSession);
  protected
    procedure DoneService; override;
    procedure Finit; override;
    function InternalHash(const AEntry: string): string; virtual;
    function InternalQueryUser(const AUserId, APassword: string): TPressCustomUser; virtual;
    class function InternalServiceType: TPressServiceType; override;
  public
    procedure Logoff;
    function Hash(const AEntry: string): string;
    function Logon(const AUserId: string = ''; const APassword: string = ''): Boolean;
    function QueryUser(const AUserId, APassword: string): TPressCustomUser;
    property CurrentUser: TPressCustomUser read GetCurrentUser;
    property HasUser: Boolean read GetHasUser;
    property Session: TPressSession read GetSession write SetSession;
    property User: TPressCustomUser read FCurrentUser;
  end;

function PressUserData: TPressCustomUserData;

implementation

uses
  SysUtils,
  PressConsts;

function PressUserData: TPressCustomUserData;
begin
  Result := TPressCustomUserData(PressApp.Services.DefaultServiceByBaseClass(TPressCustomUserData));
end;

{ TPressCustomUser }

function TPressCustomUser.AccessMode(AResourceId: Integer): TPressAccessMode;
begin
  if AResourceId >= 0 then
    Result := InternalAccessMode(AResourceId)
  else
    Result := amWritable;
end;

procedure TPressCustomUser.AfterLogon;
begin
end;

procedure TPressCustomUser.BeforeLogoff;
begin
end;

function TPressCustomUser.InternalAccessMode(AResourceId: Integer): TPressAccessMode;
begin
  Result := amWritable;
end;

{ TPressCustomUserData }

procedure TPressCustomUserData.DoneService;
begin
  inherited;
  Logoff;
end;

procedure TPressCustomUserData.Finit;
begin
  FCurrentUser.Free;
  inherited;
end;

function TPressCustomUserData.GetCurrentUser: TPressCustomUser;
begin
  if not Assigned(FCurrentUser) then
    raise EPressError.Create(SNoLoggedUser);
  Result := FCurrentUser;
end;

function TPressCustomUserData.GetHasUser: Boolean;
begin
  Result := Assigned(FCurrentUser);
end;

function TPressCustomUserData.GetSession: TPressSession;
begin
  if not Assigned(FSession) then
    FSession := PressDefaultSession;
  Result := FSession;
end;

function TPressCustomUserData.Hash(const AEntry: string): string;
begin
  Result := InternalHash(AEntry);
end;

function TPressCustomUserData.InternalHash(const AEntry: string): string;
begin
  { TODO : Implement Hash and Cypher service }
  raise EPressError.Create('Hash was not implemented');
end;

function TPressCustomUserData.InternalQueryUser(
  const AUserId, APassword: string): TPressCustomUser;
begin
  Result := TPressCustomUser.Create;
end;

class function TPressCustomUserData.InternalServiceType: TPressServiceType;
begin
  Result := CPressUserDataService;
end;

procedure TPressCustomUserData.Logoff;
begin
  if Assigned(FCurrentUser) then
  begin
    FCurrentUser.BeforeLogoff;  // friend class
    TPressUserLogoffEvent.Create(Self).Notify;
    FreeAndNil(FCurrentUser);
  end;
end;

function TPressCustomUserData.Logon(const AUserId, APassword: string): Boolean;
var
  VNewUser: TPressCustomUser;
begin
  VNewUser := InternalQueryUser(AUserId, APassword);
  Result := Assigned(VNewUser);
  if Result then
    try
      Logoff;
      FCurrentUser := VNewUser;
      TPressUserLogonEvent.Create(Self).Notify;
      FCurrentUser.AfterLogon;  // friend class
    except
      FCurrentUser := nil;
      VNewUser.Free;
      raise;
    end;
end;

function TPressCustomUserData.QueryUser(const AUserId,
  APassword: string): TPressCustomUser;
begin
  Result := InternalQueryUser(AUserId, APassword);
end;

procedure TPressCustomUserData.SetSession(Value: TPressSession);
begin
  FSession := Value;
end;

initialization
  PressApp.Registry[CPressUserDataService].ServiceTypeName := SPressUserServiceName;
  TPressCustomUser.RegisterClass;

finalization
  TPressCustomUser.UnregisterClass;
  TPressCustomUserData.UnregisterService;

end.
