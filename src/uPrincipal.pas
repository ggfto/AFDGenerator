unit uPrincipal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, Vcl.StdCtrls, Vcl.Mask,
  Vcl.ComCtrls, Vcl.ExtCtrls, Vcl.Grids, Vcl.DBGrids, Datasnap.DBClient,
  Vcl.Buttons, Vcl.DBCtrls, MidasLib, Vcl.Samples.Spin, System.DateUtils;

type
  TfrmPrincipal = class(TForm)
    pgcPages: TPageControl;
    tsGrid: TTabSheet;
    tsGenerator: TTabSheet;
    dsAFD: TClientDataSet;
    dsoAFD: TDataSource;
    dsAFDNSR: TIntegerField;
    dsAFDTipRegistro: TIntegerField;
    pnlFooterGrid: TPanel;
    dsAFDDataBatida: TDateField;
    dsAFDHora: TIntegerField;
    pnlFGLeft: TPanel;
    btnVisualizar: TBitBtn;
    pnlFGNav: TPanel;
    dbnNav: TDBNavigator;
    pnlGenTop: TPanel;
    pnlGen: TPanel;
    dbgCargaHoraria: TDBGrid;
    pnlGenNav: TPanel;
    dbnNavCGH: TDBNavigator;
    dsoCargaHor: TDataSource;
    dsCargaHor: TClientDataSet;
    dsCargaHorENT1: TIntegerField;
    dsCargaHorSAI1: TIntegerField;
    dsCargaHorENT2: TIntegerField;
    dsCargaHorSAI2: TIntegerField;
    dsCargaHorENT3: TIntegerField;
    dsCargaHorSAI3: TIntegerField;
    dsCargaHorENT4: TIntegerField;
    dsCargaHorENT5: TIntegerField;
    dsCargaHorSAI5: TIntegerField;
    dsCargaHorENT6: TIntegerField;
    dsCargaHorSAI6: TIntegerField;
    dsCargaHorENT7: TIntegerField;
    dsCargaHorSAI7: TIntegerField;
    dsCargaHorSAI4: TIntegerField;
    dsCargaHorENT8: TIntegerField;
    dsCargaHorSAI8: TIntegerField;
    dlgSave: TSaveDialog;
    tsSobre: TTabSheet;
    lblAuthor: TLabel;
    lblEmail: TLabel;
    lblAbout: TLabel;
    pnlGenTLeft: TPanel;
    grpPeriodo: TGroupBox;
    lblInicio: TLabel;
    lblFim: TLabel;
    dtpInicio: TDateTimePicker;
    dtpFim: TDateTimePicker;
    grpGeral: TGroupBox;
    lblNSR: TLabel;
    lblPIS: TLabel;
    chkAutoNSR: TCheckBox;
    chkAutoPIS: TCheckBox;
    medPIS: TMaskEdit;
    medNSR: TMaskEdit;
    pnlGenTMid: TPanel;
    grpSemanal: TGroupBox;
    chkPontoSabado: TCheckBox;
    chkPontoDomingo: TCheckBox;
    pnlVisualizar: TPanel;
    pnlMemo: TPanel;
    mmoMemo: TMemo;
    pnlGrid: TPanel;
    dbgGrid: TDBGrid;
    btnSalvar: TBitBtn;
    grpBatidas: TGroupBox;
    chkVariarMinutos: TCheckBox;
    chkVariarDezenas: TCheckBox;
    pnlGenTRight: TPanel;
    grpEscalonado: TGroupBox;
    lblDiasTrab: TLabel;
    lblDiasFolga: TLabel;
    chkEscalonar: TCheckBox;
    seDiasTrab: TSpinEdit;
    seDiasFolga: TSpinEdit;
    rgPrimeiroDia: TRadioGroup;
    dsAFDPIS: TStringField;
    procedure dtpInicioCloseUp(Sender: TObject);
    procedure chkAutoNSRClick(Sender: TObject);
    procedure chkAutoPISClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnVisualizarClick(Sender: TObject);
    procedure dsCargaHorBeforeInsert(DataSet: TDataSet);
    procedure btnSalvarClick(Sender: TObject);
    procedure dsAFDBeforeInsert(DataSet: TDataSet);
    procedure dbgCargaHorariaKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure dsAFDAfterPost(DataSet: TDataSet);
    procedure chkEscalonarClick(Sender: TObject);
    procedure pgcPagesChange(Sender: TObject);
    procedure medPISExit(Sender: TObject);
  private
    { Private declarations }
    procedure CreatedsAFD;
    function FirstDayOfMonth(datDate: TDateTime): TDateTime;
  public
    { Public declarations }
    procedure GerarAFD(datIni, datFim: TDateTime; intTipo, NSR: Integer; PIS: String);
    procedure GerarTexto;
  end;

var
  frmPrincipal: TfrmPrincipal;

implementation

{$R *.dfm}

procedure TfrmPrincipal.btnSalvarClick(Sender: TObject);
begin
  if dlgSave.Execute then
    mmoMemo.Lines.SaveToFile(dlgSave.FileName);
end;

procedure TfrmPrincipal.btnVisualizarClick(Sender: TObject);
begin
  if not dsAFD.IsEmpty then
    if Application.MessageBox('Ao prosseguir, os dados existentes ser�o substitu�dos. Confirma?','Confirme',MB_ICONWARNING or MB_YESNO or MB_DEFBUTTON2) = IdYes then
      begin
        Screen.Cursor := crHourGlass;
        dsAFD.First;
        dsAFD.DisableControls;
        while not dsAFD.Eof do
          dsAFD.Delete;
        dsAFD.EnableControls;
        Screen.Cursor := crDefault;
      end;
  GerarAFD(dtpInicio.DateTime, dtpFim.DateTime, 3, StrToInt(medNSR.Text), medPIS.Text);
  GerarTexto;
end;

procedure TfrmPrincipal.chkAutoNSRClick(Sender: TObject);
begin
  medNSR.Enabled := not TCheckBox(Sender).Checked;
  if medNSR.Enabled then
    begin
      medNSR.Color := clWindow;
      medNSR.SetFocus;
    end
  else
    begin
      medNSR.Color := clBtnFace;
      medNSR.Text := Format('%.*d',[9, Abs(Random(4096))]);
    end;
end;

procedure TfrmPrincipal.chkAutoPISClick(Sender: TObject);
begin
  medPIS.Enabled := not TCheckBox(Sender).Checked;
  if medPIS.Enabled then
    begin
      medPIS.Color := clWindow;
      medPIS.SetFocus;
    end
  else
    begin
      medPIS.Color := clBtnFace;
      medPIS.Text := Format('%.*d',[12, Abs(Random(999999999999))]);
    end;
end;

procedure TfrmPrincipal.chkEscalonarClick(Sender: TObject);
begin
  seDiasTrab.Enabled := TCheckBox(Sender).Checked;
  seDiasFolga.Enabled := TCheckBox(Sender).Checked;
  rgPrimeiroDia.Enabled := TCheckBox(Sender).Checked;
  chkPontoSabado.Enabled := not TCheckBox(Sender).Checked;
  chkPontoDomingo.Enabled := not TCheckBox(Sender).Checked;
end;

procedure TfrmPrincipal.CreatedsAFD;
begin
  with dsAFD do
    begin
      with FieldDefs.AddFieldDef do
        begin
          DataType := ftInteger;
          Name := 'NSR';
        end;
      with FieldDefs.AddFieldDef do
        begin
          DataType := ftInteger;
          Name := 'TipRegistro';
        end;
      with FieldDefs.AddFieldDef do
        begin
          DataType := ftDate;
          Name := 'DataBatida';
        end;
      with FieldDefs.AddFieldDef do
        begin
          DataType := ftInteger;
          Name := 'Hora';
        end;
      with FieldDefs.AddFieldDef do
        begin
          DataType := ftString;
          Name := 'PIS';
        end;
    end;
end;

procedure TfrmPrincipal.dbgCargaHorariaKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_RETURN) and (dsCargaHor.State in[dsInsert,dsEdit]) then
    begin
      dsCargaHor.Post;
      TDBGrid(Sender).SelectedField := TDBGrid(Sender).Fields[TDBGrid(Sender).SelectedField.FieldNo];
    end;
end;

procedure TfrmPrincipal.dsAFDAfterPost(DataSet: TDataSet);
begin
  GerarTexto;
end;

procedure TfrmPrincipal.dsAFDBeforeInsert(DataSet: TDataSet);
begin
  DataSet.Cancel;
end;

procedure TfrmPrincipal.dsCargaHorBeforeInsert(DataSet: TDataSet);
begin
  if DataSet.RecordCount = 1 then
    raise Exception.Create('Limite de cadastro de Carga Hor�ria atingido!');
end;

procedure TfrmPrincipal.dtpInicioCloseUp(Sender: TObject);
begin
  dtpFim.DateTime := TDateTimePicker(Sender).DateTime + 29;
end;

function TfrmPrincipal.FirstDayOfMonth(datDate: TDateTime): TDateTime;
var
  Year, Month, Day: Word;
begin
  DecodeDate(Date, Year, Month, Day);
  Result := EncodeDate(Year, Month, 1);
end;

procedure TfrmPrincipal.FormCreate(Sender: TObject);
begin
  medNSR.Text := IntToStr(Abs(Random(4096)));
  medPIS.Text := IntToStr(Abs(Random(999999999999)));
  CreatedsAFD;
  dsAFD.CreateDataSet;
  dsCargaHor.CreateDataSet;
  pgcPages.ActivePageIndex := 0;
  dtpInicio.DateTime := FirstDayofMonth(Now);
  dtpFim.DateTime := EndOfAMonth(YearOf(Now),MonthOfTheYear(Now));
end;

procedure TfrmPrincipal.GerarAFD(datIni, datFim: TDateTime; intTipo, NSR: Integer; PIS: String);
var
  datAux, datAnt: TDateTime;
  i,intNSR,
  intMinuto, intDezena,
  intTrabalho, intFolga: Integer;
  strAux: string;
  timAux, timAuxAnt: TTime;
  H,M,S,MS: Word;
  booInterdata: boolean;
begin
  booInterdata := False;
  dsAFD.AfterPost := nil;
  intNSR := NSR;
  intFolga := 0;
  intTrabalho := 0;
  if rgPrimeiroDia.ItemIndex = 1 then
    intTrabalho := seDiasTrab.Value;
  if chkEscalonar.Checked then
    datAux := datIni
  else
    datAux := datIni - 1;
  Screen.Cursor := crHourGlass;
  dsAFD.BeforeInsert := nil;
  while datAux <= datFim do
    begin
      if not chkEscalonar.Checked then
        begin
          datAux := datAux + 1;
          if ((not chkPontoSabado.Checked) and (DayOfWeek(datAux) = 7) or
              ((not chkPontoDomingo.Checked) and (DayOfWeek(datAux) = 1))) then
            begin
              timAuxAnt := -1;
              Continue;
            end;
        end
      else
        begin
          if intTrabalho = seDiasTrab.Value then
            begin
              if intFolga < seDiasFolga.Value then
                begin
                  if not booInterdata then
                    begin
                      datAux := datAux + 1;
                      booInterdata := False;
                    end;
                  Inc(intFolga);
                  if intFolga = seDiasFolga.Value then
                    begin
                      intTrabalho := 0;
                      intFolga := 0;
                    end;
                  Continue;
                end;
            end
          else
            Inc(intTrabalho);
        end;
      for I := 0 to 15 do
        begin
          if not dbgCargaHoraria.Fields[i].IsNull then
            begin
              datAnt := datAux;
              timAux := StrToTime(Format('%.*d',[2,dbgCargaHoraria.Fields[i].AsInteger div 100]) + ':' +
                                  Format('%.*d',[2,dbgCargaHoraria.Fields[i].AsInteger mod 100]));
              DecodeTime(timAux,H,M,S,MS);
              intDezena := M div 10;
              intMinuto := M mod 10;
              if chkVariarDezenas.Checked then
                intDezena := Abs(Random(5));
              if chkVariarMinutos.Checked then
                intMinuto := Abs(Random(9));
              M := intDezena * 10 + intMinuto;
              timAux := EncodeTime(H,M,S,MS);
              strAux := FormatDateTime('hhmm', timAux);
              dsAFD.Append;
              dsAFDNSR.AsInteger := intNSR;
              dsAFDTIPREGISTRO.AsInteger := 3;
              if (timAuxAnt <> -1) and (timAux < timAuxAnt) then
                begin
                  datAux := datAux + 1;
                  booInterdata := True;
                end;
              dsAFDDATABATIDA.AsDateTime := datAux;
              dsAFDHORA.AsInteger := StrToInt(strAux);
              dsAFDPIS.AsString := PIS;
              dsAFD.Post;
              timAuxAnt := timAux;
              intNSR := intNSR + 1;
            end;
        end;
      timAuxAnt := -1;
    end;
  Screen.Cursor := crDefault;
  dsAFD.BeforeInsert := dsAFDBeforeInsert;
  dsAFD.AfterPost := dsAFDAfterPost;
end;

procedure TfrmPrincipal.GerarTexto;
begin
  with dsAFD do
    begin
      DisableControls;
      First;
      if mmoMemo.Lines.Count > 0 then
        mmoMemo.Lines.Clear;
      while not Eof do
        begin
          mmoMemo.Lines.Add(Format('%.*d',[9,dsAFDNSR.AsInteger]) +
                            dsAFDTipRegistro.AsString +
                            FormatDateTime('ddmmyyyy',dsAFDDataBatida.AsDateTime) +
                            Format('%.*d',[4,dsAFDHora.AsInteger]) +
                            Format('%.*s',[12,dsAFDPIS.AsString]));
          Next;
        end;
      First;
      EnableControls;
    end;
  if mmoMemo.Lines.Count > 0 then
    btnSalvar.Enabled := True
  else
    btnSalvar.Enabled := False;
end;

procedure TfrmPrincipal.medPISExit(Sender: TObject);
begin
  TMaskEdit(Sender).Text := StringReplace(TMaskEdit(Sender).Text,'.','',[rfReplaceAll,rfIgnoreCase]);
  TMaskEdit(Sender).Text := StringReplace(TMaskEdit(Sender).Text,'-','',[rfReplaceAll,rfIgnoreCase]);
  if Length(TMaskEdit(Sender).Text) > 11 then
    raise Exception.Create('O PIS cont�m apenas 11 n�meros!');
end;

procedure TfrmPrincipal.pgcPagesChange(Sender: TObject);
begin
  if (TPageControl(Sender).ActivePageIndex = 1) and (dsAFD.RecordCount = 0) then
    btnVisualizar.Click;
end;

end.
