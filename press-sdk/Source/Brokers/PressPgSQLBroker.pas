(*
  PressObjects, PostgreSQL database Broker
  Copyright (C) 2008 Laserpress Ltda.

  http://www.pressobjects.org

  See the file LICENSE.txt, included in this distribution,
  for details about the copyright.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*)

unit PressPgSQLBroker;

{$I Press.inc}

interface

uses
  PressOPFClasses,
  PressOPFSQLBuilder;

type
  TPressPgSQLDDLBuilder = class(TPressOPFDDLBuilder)
  protected
    function InternalFieldTypeStr(AFieldType: TPressOPFFieldType): string; override;
    function InternalImplicitIndexCreation: Boolean; override;
    function InternalMaxIdentLength: Integer; override;
  public
    function CreateGeneratorStatement(const AName: string): string; override;
    function SelectGeneratorStatement: string; override;
  end;

implementation

uses
  SysUtils;

{ TPressPgSQLDDLBuilder }

function TPressPgSQLDDLBuilder.CreateGeneratorStatement(const AName: string): string;
begin
  Result := Format('create sequence %s', [AName]);
end;

function TPressPgSQLDDLBuilder.InternalFieldTypeStr(
  AFieldType: TPressOPFFieldType): string;
const
  CFieldTypeStr: array[TPressOPFFieldType] of string = (
   '',                  //  oftUnknown
   'varchar',           //  oftPlainString
   'varchar',           //  oftAnsiString
   'smallint',          //  oftInt16
   'integer',           //  oftInt32
   'bigint',            //  oftInt64
   'double precision',  //  oftDouble
   'money',             //  oftCurrency
   'boolean',           //  oftBoolean
   'date',              //  oftDate
   'time',              //  oftTime
   'timestamp',         //  oftDateTime
   'text',              //  oftMemo
   'bytea');            //  oftBinary
begin
  Result := CFieldTypeStr[AFieldType];
end;

function TPressPgSQLDDLBuilder.InternalImplicitIndexCreation: Boolean;
begin
  Result := True;
end;

function TPressPgSQLDDLBuilder.InternalMaxIdentLength: Integer;
begin
  Result := 63;
end;

function TPressPgSQLDDLBuilder.SelectGeneratorStatement: string;
begin
  Result := 'select nextval(''%s'')';
end;

end.
