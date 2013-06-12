(*
  PressObjects, Dialogs and Messages Classes
  Copyright (C) 2006-2007 Laserpress Ltda.

  http://www.pressobjects.org

  See the file LICENSE.txt, included in this distribution,
  for details about the copyright.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*)

unit PressDialogs;

{$I Press.inc}

interface

uses
  PressApplication;

const
  CPressDialogService = CPressDialogServicesBase + $0002;

type
  TPressMessageType = (msgConfirm, msgInform);
  TPressOpenDlgType = (odtPicture);

  TPressDialogs = class(TPressService)
  protected
    function InternalCancelChanges: Boolean; virtual;
    function InternalConfirmDlg(const AMsg: string): Boolean; virtual;
    function InternalConfirmRemove(ACount: Integer): Boolean; virtual;
    procedure InternalDefaultDlg(const AMsg: string); virtual;
    function InternalOpenPictureDialog(out AFileName: string): Boolean;
    function InternalSaveChanges: Boolean; virtual;
    class function InternalServiceType: TPressServiceType; override;
  public
    function CancelChanges: Boolean;
    function ConfirmDlg(const AMsg: string): Boolean;
    function ConfirmRemove(ACount: Integer): Boolean;
    procedure DefaultDlg(const AMsg: string);
    function OpenPicture(out AFileName: string): Boolean;
    function SaveChanges: Boolean;
  end;

function PressDialog: TPressDialogs;

implementation

uses
  SysUtils,
  PressConsts,
  PressMVPWidget;

function PressDialog: TPressDialogs;
begin
  Result := TPressDialogs(PressApp.Services.DefaultServiceByBaseClass(TPressDialogs));
end;

{ TPressDialogs }

function TPressDialogs.CancelChanges: Boolean;
begin
  Result := InternalCancelChanges;
end;

function TPressDialogs.ConfirmDlg(const AMsg: string): Boolean;
begin
  Result := InternalConfirmDlg(AMsg);
end;

function TPressDialogs.ConfirmRemove(ACount: Integer): Boolean;
begin
  Result := InternalConfirmRemove(ACount);
end;

procedure TPressDialogs.DefaultDlg(const AMsg: string);
begin
  InternalDefaultDlg(AMsg);
end;

function TPressDialogs.InternalCancelChanges: Boolean;
begin
  Result := ConfirmDlg(SPressCancelChangesDialog);
end;

function TPressDialogs.InternalConfirmDlg(const AMsg: string): Boolean;
begin
  Result := PressWidget.MessageDlg(msgConfirm, AMsg) = 0;
end;

function TPressDialogs.InternalConfirmRemove(ACount: Integer): Boolean;
begin
  if ACount = 1 then
    Result := ConfirmDlg(SPressConfirmRemoveOneItemDialog)
  else
    Result := ConfirmDlg(Format(
     SPressConfirmRemoveItemsDialog, [ACount]));
end;

procedure TPressDialogs.InternalDefaultDlg(const AMsg: string);
begin
  PressWidget.MessageDlg(msgInform, AMsg);
end;

function TPressDialogs.InternalOpenPictureDialog(out AFileName: string): Boolean;
begin
  AFileName := '';
  Result := PressWidget.OpenDlg(odtPicture, AFileName);
end;

function TPressDialogs.InternalSaveChanges: Boolean;
begin
  Result := ConfirmDlg(SPressSaveChangesDialog);
end;

class function TPressDialogs.InternalServiceType: TPressServiceType;
begin
  Result := CPressDialogService;
end;

function TPressDialogs.OpenPicture(out AFileName: string): Boolean;
begin
  Result := InternalOpenPictureDialog(AFileName);
end;

function TPressDialogs.SaveChanges: Boolean;
begin
  Result := InternalSaveChanges;
end;

end.
