program SimpleOPF;

uses
  Forms,
  PressVCLBroker,
  PressApplication,
  MainFrm in '..\..\Units\MainFrm.pas' {MainForm},
  PersonBO in '..\..\Units\PersonBO.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  PressApp.Run;
end.
