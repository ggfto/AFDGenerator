program AFDGen;

uses
  Vcl.Forms,
  uPrincipal in 'uPrincipal.pas' {frmPrincipal},
  Vcl.Themes,
  Vcl.Styles;

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'Gerador AFD';
  Application.CreateForm(TfrmPrincipal, frmPrincipal);
  Application.Run;
end.
