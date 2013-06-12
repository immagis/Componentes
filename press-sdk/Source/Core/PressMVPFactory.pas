(*
  PressObjects, MVP-Factory Classes
  Copyright (C) 2006 Laserpress Ltda.

  http://www.pressobjects.org

  See the file LICENSE.txt, included in this distribution,
  for details about the copyright.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*)

unit PressMVPFactory;

{$I Press.inc}

interface

uses
  Contnrs,
  PressClasses,
  PressNotifier,
  PressSubject,
  PressMVP,
  PressMVPModel,
  PressMVPView,
  PressMVPPresenter;

type
  TPressMVPRegisteredForm = class(TObject)
  private
    FFormClass: TClass;
    FFormPresenterTypes: TPressMVPFormPresenterTypes;
    FModelClass: TPressMVPObjectModelClass;
    FObjectClass: TPressObjectClass;
    FPresenterClass: TPressMVPFormPresenterClass;
    function GetObjectClass: TPressObjectClass;
  public
    constructor Create(APresenterClass: TPressMVPFormPresenterClass);
    procedure AssignForm(AFormClass: TClass);
    function HasObjectClass: Boolean;
    property FormClass: TClass read FFormClass;
    property FormPresenterTypes: TPressMVPFormPresenterTypes read FFormPresenterTypes;
    property ModelClass: TPressMVPObjectModelClass read FModelClass;
    property ObjectClass: TPressObjectClass read GetObjectClass;
    property PresenterClass: TPressMVPFormPresenterClass read FPresenterClass;
  end;

  TPressMVPRegisteredFormIterator = class;

  TPressMVPRegisteredFormList = class(TPressList)
  private
    function GetItems(AIndex: Integer): TPressMVPRegisteredForm;
    procedure SetItems(AIndex: Integer; const Value: TPressMVPRegisteredForm);
  protected
    function InternalCreateIterator: TPressCustomIterator; override;
  public
    function Add(AObject: TPressMVPRegisteredForm): Integer;
    function CreateIterator: TPressMVPRegisteredFormIterator;
    function FormOfPresenter(APresenterClass: TPressMVPFormPresenterClass): TPressMVPRegisteredForm;
    function IndexOf(AObject: TPressMVPRegisteredForm): Integer;
    function IndexOfObjectClass(AObjectClass: TPressObjectClass; AFormPresenterType: TPressMVPFormPresenterType; AIncludeDescendants: Boolean = False): Integer;
    function IndexOfPresenterClass(APresenterClass: TPressMVPFormPresenterClass): Integer;
    function IndexOfQueryItemObject(AObjectClass: TPressObjectClass; AFormPresenterType: TPressMVPFormPresenterType): Integer;
    procedure Insert(Index: Integer; AObject: TPressMVPRegisteredForm);
    function Remove(AObject: TPressMVPRegisteredForm): Integer;
    property Items[AIndex: Integer]: TPressMVPRegisteredForm read GetItems write SetItems; default;
  end;

  TPressMVPRegisteredFormIterator = class(TPressIterator)
  private
    function GetCurrentItem: TPressMVPRegisteredForm;
  public
    property CurrentItem: TPressMVPRegisteredForm read GetCurrentItem;
  end;

  TPressMVPFactory = class(TObject)
  { TODO : Refactor }
  private
    FForms: TPressMVPRegisteredFormList;
    FInteractors: TClassList;
    FModels: TClassList;
    FNotifier: TPressNotifier;
    FPresenters: TClassList;
    FViews: TClassList;
    function ChooseConcreteClass(ACandidateClass1, ACandidateClass2: TClass): TClass;
    function ExistSubClasses(AClasses: TClassList; AClass: TClass): Boolean;
    procedure Notify(AEvent: TPressEvent);
    procedure RemoveSuperClasses(AClasses: TClassList; AClass: TClass);
  public
    constructor Create;
    destructor Destroy; override;
    function MVPInteractorFactory(APresenter: TPressMVPPresenter): TPressMVPInteractorClasses;
    function MVPModelFactory(AParent: TPressMVPModel; ASubjectMetadata: TPressSubjectMetadata): TPressMVPModel;
    function MVPPresenterFactory(AParent: TPressMVPFormPresenter; AModel: TPressMVPModel; const AView: IPressMVPView): TPressMVPPresenter;
    function MVPViewFactory(AControl: TObject; AOwnsControl: Boolean = False): IPressMVPView;
    procedure RegisterBO(APresenterClass: TPressMVPFormPresenterClass; AObjectClass: TPressObjectClass; AFormPresenterTypes: TPressMVPFormPresenterTypes; AModelClass: TPressMVPObjectModelClass);
    procedure RegisterInteractor(AInteractorClass: TPressMVPInteractorClass);
    procedure RegisterModel(AModelClass: TPressMVPModelClass);
    procedure RegisterPresenter(APresenterClass: TPressMVPPresenterClass);
    procedure RegisterView(AViewClass: TPressMVPBaseViewClass);
    property Forms: TPressMVPRegisteredFormList read FForms;
  end;

function PressDefaultMVPFactory: TPressMVPFactory;

implementation

uses
  PressConsts,
  PressMVPWidget;

var
  _MVPFactory: TPressMVPFactory;

function PressDefaultMVPFactory: TPressMVPFactory;
begin
  if not Assigned(_MVPFactory) then
    _MVPFactory := TPressMVPFactory.Create;
  Result := _MVPFactory;
end;

{ TPressMVPRegisteredForm }

procedure TPressMVPRegisteredForm.AssignForm(AFormClass: TClass);
begin
  FFormClass := AFormClass;
end;

constructor TPressMVPRegisteredForm.Create(
  APresenterClass: TPressMVPFormPresenterClass);
begin
  inherited Create;
  FPresenterClass := APresenterClass;
end;

function TPressMVPRegisteredForm.GetObjectClass: TPressObjectClass;
begin
  if not Assigned(FObjectClass) then
    raise EPressMVPError.CreateFmt(
     SUnassignedPresenterBO, [FPresenterClass.ClassName]);
  Result := FObjectClass;
end;

function TPressMVPRegisteredForm.HasObjectClass: Boolean;
begin
  Result := Assigned(FObjectClass);
end;

{ TPressMVPRegisteredFormList }

function TPressMVPRegisteredFormList.Add(
  AObject: TPressMVPRegisteredForm): Integer;
begin
  Result := inherited Add(AObject);
end;

function TPressMVPRegisteredFormList.CreateIterator: TPressMVPRegisteredFormIterator;
begin
  Result := TPressMVPRegisteredFormIterator.Create(Self);
end;

function TPressMVPRegisteredFormList.FormOfPresenter(
  APresenterClass: TPressMVPFormPresenterClass): TPressMVPRegisteredForm;
var
  VIndex: Integer;
begin
  VIndex := IndexOfPresenterClass(APresenterClass);
  if VIndex >= 0 then
    Result := Items[VIndex]
  else
  begin
    Result := TPressMVPRegisteredForm.Create(APresenterClass);
    Add(Result);
  end;
end;

function TPressMVPRegisteredFormList.GetItems(
  AIndex: Integer): TPressMVPRegisteredForm;
begin
  Result := inherited Items[AIndex] as TPressMVPRegisteredForm;
end;

function TPressMVPRegisteredFormList.IndexOf(
  AObject: TPressMVPRegisteredForm): Integer;
begin
  Result := inherited IndexOf(AObject);
end;

function TPressMVPRegisteredFormList.IndexOfObjectClass(
  AObjectClass: TPressObjectClass;
  AFormPresenterType: TPressMVPFormPresenterType;
  AIncludeDescendants: Boolean): Integer;
var
  VForm: TPressMVPRegisteredForm;
begin
  for Result := 0 to Pred(Count) do
  begin
    VForm := Items[Result];
    if VForm.HasObjectClass and
     (AFormPresenterType in VForm.FormPresenterTypes) and
     ((not AIncludeDescendants and (VForm.ObjectClass = AObjectClass)) or
     (AIncludeDescendants and VForm.ObjectClass.InheritsFrom(AObjectClass))) then
      Exit;
  end;
  { TODO : Notify ambiguous presenter class }
  Result := -1;
end;

function TPressMVPRegisteredFormList.IndexOfPresenterClass(
  APresenterClass: TPressMVPFormPresenterClass): Integer;
begin
  for Result := 0 to Pred(Count) do
    if Items[Result].PresenterClass = APresenterClass then
      Exit;
  Result := -1;
end;

function TPressMVPRegisteredFormList.IndexOfQueryItemObject(
  AObjectClass: TPressObjectClass;
  AFormPresenterType: TPressMVPFormPresenterType): Integer;

  function Match(ARegForm: TPressMVPRegisteredForm): Boolean;
  begin
    Result := ARegForm.HasObjectClass and
     (AFormPresenterType in ARegForm.FormPresenterTypes) and
     (ARegForm.ObjectClass.InheritsFrom(TPressQuery)) and
     (TPressQueryClass(ARegForm.ObjectClass).ClassMetadata.ItemObjectClass =
      AObjectClass);
  end;

begin
  for Result := 0 to Pred(Count) do
    if Match(Items[Result]) then
      Exit;
  Result := -1;
end;

procedure TPressMVPRegisteredFormList.Insert(Index: Integer;
  AObject: TPressMVPRegisteredForm);
begin
  inherited Insert(Index, AObject);
end;

function TPressMVPRegisteredFormList.InternalCreateIterator: TPressCustomIterator;
begin
  Result := CreateIterator;
end;

function TPressMVPRegisteredFormList.Remove(
  AObject: TPressMVPRegisteredForm): Integer;
begin
  Result := inherited Remove(AObject);
end;

procedure TPressMVPRegisteredFormList.SetItems(AIndex: Integer;
  const Value: TPressMVPRegisteredForm);
begin
  inherited Items[AIndex] := Value;
end;

{ TPressMVPRegisteredFormIterator }

function TPressMVPRegisteredFormIterator.GetCurrentItem: TPressMVPRegisteredForm;
begin
  Result := inherited CurrentItem as TPressMVPRegisteredForm;
end;

{ TPressMVPFactory }

function TPressMVPFactory.ChooseConcreteClass(
  ACandidateClass1, ACandidateClass2: TClass): TClass;
begin
  if not Assigned(ACandidateClass1) then
    Result := ACandidateClass2
  else if not Assigned(ACandidateClass2) then
    Result := ACandidateClass1
  else if ACandidateClass1.InheritsFrom(ACandidateClass2) then
    Result := ACandidateClass1
  else if ACandidateClass2.InheritsFrom(ACandidateClass1) then
    Result := ACandidateClass2
  else
    raise EPressMVPError.CreateFmt(SAmbiguousClass,
     [ACandidateClass1.ClassName, ACandidateClass2.ClassName]);
end;

constructor TPressMVPFactory.Create;
begin
  inherited Create;
  FForms := TPressMVPRegisteredFormList.Create(True);
  FInteractors := TClassList.Create;
  FModels := TClassList.Create;
  FPresenters := TClassList.Create;
  FViews := TClassList.Create;
  FNotifier := TPressNotifier.Create({$IFDEF FPC}@{$ENDIF}Notify);
  FNotifier.AddNotificationItem(nil, [TPressMVPModelFindFormEvent]);
end;

destructor TPressMVPFactory.Destroy;
begin
  FNotifier.Free;
  FInteractors.Free;
  FModels.Free;
  FPresenters.Free;
  FViews.Free;
  FForms.Free;
  inherited;
end;

function TPressMVPFactory.ExistSubClasses(
  AClasses: TClassList; AClass: TClass): Boolean;
var
  I: Integer;
begin
  for I := 0 to Pred(AClasses.Count) do
  begin
    Result := AClasses[I].InheritsFrom(AClass);
    if Result then
      Exit;
  end;
  Result := False;
end;

function TPressMVPFactory.MVPInteractorFactory(
  APresenter: TPressMVPPresenter): TPressMVPInteractorClasses;
var
  VInteractorClass: TPressMVPInteractorClass;
  VClasses: TClassList;
  I: Integer;
begin
  VClasses := TClassList.Create;
  try
    for I := 0 to Pred(FInteractors.Count) do
    begin
      VInteractorClass := TPressMVPInteractorClass(FInteractors[I]);
      if VInteractorClass.Apply(APresenter) and not
       ExistSubClasses(VClasses, VInteractorClass) then
      begin
        RemoveSuperClasses(VClasses, VInteractorClass);
        VClasses.Add(VInteractorClass);
      end;
    end;
    SetLength(Result, VClasses.Count);
    for I := 0 to Pred(VClasses.Count) do
      Result[I] := TPressMVPInteractorClass(VClasses[I]);
  finally
    VClasses.Free;
  end;
end;

function TPressMVPFactory.MVPModelFactory(AParent: TPressMVPModel;
  ASubjectMetadata: TPressSubjectMetadata): TPressMVPModel;
var
  VModelClass, VCandidateClass: TPressMVPModelClass;
  VClassName: string;
  I: Integer;
begin
  VCandidateClass := nil;
  for I := 0 to Pred(FModels.Count) do
  begin
    VModelClass := TPressMVPModelClass(FModels[I]);
    if VModelClass.Apply(ASubjectMetadata) then
      VCandidateClass := TPressMVPModelClass(
       ChooseConcreteClass(VCandidateClass, VModelClass));
  end;
  if not Assigned(VCandidateClass) then
  begin
    if Assigned(ASubjectMetadata) then
      VClassName := ASubjectMetadata.SubjectName
    else
      VClassName := SPressNilString;
    raise EPressMVPError.CreateFmt(SUnsupportedObject,
     [TPressMVPModel.ClassName, VClassName]);
  end;
  Result := VCandidateClass.Create(AParent, ASubjectMetadata);
end;

function TPressMVPFactory.MVPPresenterFactory(
  AParent: TPressMVPFormPresenter;
  AModel: TPressMVPModel; const AView: IPressMVPView): TPressMVPPresenter;
var
  VPresenterClass, VCandidateClass: TPressMVPPresenterClass;
  I: Integer;
begin
  VCandidateClass := nil;
  for I := 0 to Pred(FPresenters.Count) do
  begin
    VPresenterClass := TPressMVPPresenterClass(FPresenters[I]);
    if VPresenterClass.Apply(AModel, AView) then
      VCandidateClass := TPressMVPPresenterClass(
       ChooseConcreteClass(VCandidateClass, VPresenterClass));
  end;
  if not Assigned(VCandidateClass) then
    raise EPressMVPError.CreateFmt(SUnsupportedObject,
     [TPressMVPPresenter.ClassName, AModel.ClassName]);
  Result := VCandidateClass.Create(AParent, AModel, AView);
end;

function TPressMVPFactory.MVPViewFactory(AControl: TObject;
  AOwnsControl: Boolean): IPressMVPView;
var
  VViewClass, VCandidateClass: TPressMVPBaseViewClass;
  I: Integer;
begin
  VCandidateClass := nil;
  for I := 0 to Pred(FViews.Count) do
  begin
    VViewClass := TPressMVPBaseViewClass(FViews[I]);
    if VViewClass.Apply(AControl) then
      VCandidateClass := TPressMVPBaseViewClass(
       ChooseConcreteClass(VCandidateClass, VViewClass));
  end;
  if not Assigned(VCandidateClass) then
    raise EPressMVPError.CreateFmt(SUnsupportedControl,
     [AControl.ClassName, PressWidget.ControlName(AControl)]);
  Result := VCandidateClass.Create(AControl, AOwnsControl) as IPressMVPView;
  Result._Release;
end;

procedure TPressMVPFactory.Notify(AEvent: TPressEvent);
const
  CFormType: array[Boolean] of TPressMVPFormPresenterType = (
   fpExisting, fpNew);
var
  VEvent: TPressMVPModelFindFormEvent;
begin
  if AEvent is TPressMVPModelFindFormEvent then
  begin
    VEvent := TPressMVPModelFindFormEvent(AEvent);
    if not VEvent.HasForm then
      VEvent.HasForm := Forms.IndexOfObjectClass(VEvent.ObjectClass,
       CFormType[VEvent.NewObjectForm], VEvent.IncludeDescendants) >= 0;
  end;
end;

procedure TPressMVPFactory.RegisterBO(
  APresenterClass: TPressMVPFormPresenterClass;
  AObjectClass: TPressObjectClass;
  AFormPresenterTypes: TPressMVPFormPresenterTypes;
  AModelClass: TPressMVPObjectModelClass);
var
  VForm: TPressMVPRegisteredForm;
begin
  VForm := Forms.FormOfPresenter(APresenterClass);
  VForm.FObjectClass := AObjectClass;
  VForm.FFormPresenterTypes := AFormPresenterTypes;
  VForm.FModelClass := AModelClass;
end;

procedure TPressMVPFactory.RegisterInteractor(
  AInteractorClass: TPressMVPInteractorClass);
begin
  FInteractors.Add(AInteractorClass);
end;

procedure TPressMVPFactory.RegisterModel(AModelClass: TPressMVPModelClass);
begin
  FModels.Add(AModelClass);
end;

procedure TPressMVPFactory.RegisterPresenter(
  APresenterClass: TPressMVPPresenterClass);
begin
  FPresenters.Add(APresenterClass);
end;

procedure TPressMVPFactory.RegisterView(AViewClass: TPressMVPBaseViewClass);
begin
  FViews.Add(AViewClass);
end;

procedure TPressMVPFactory.RemoveSuperClasses(
  AClasses: TClassList; AClass: TClass);
var
  I: Integer;
begin
  for I := Pred(AClasses.Count) downto 0 do
    if AClass.InheritsFrom(AClasses[I]) then
      AClasses.Delete(I);
end;

initialization

finalization
  _MVPFactory.Free;

end.
