unit WhonixInstaller_Main;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, StdCtrls,
  Arrow, ExtCtrls, Types, StrUtils, FileUtil, IniFiles, LCLIntf, WhonixUtils;

type

  { TInstallerForm }

  TInstallerForm = class(TForm)
    ButtonBack: TButton;
    ButtonNext: TButton;
    ButtonCancel: TButton;
    CheckBoxLicense: TCheckBox;
    CheckBoxOutput: TCheckBox;
    ImageBanner: TImage;
    LabelHyperVSelectOption: TLabel;
    LabelRecommendReboot: TLabel;
    LabelConfigHyperV: TLabel;
    LabelConfigHyperVAlternatives: TLabel;
    LabelConfigHyperVAltKicksecureUSB: TLabel;
    LabelConfigHyperVAltLinuxHost: TLabel;
    LabelConfigHyperVAltWhonixHost: TLabel;
    LabelConfigHyperVDesc: TLabel;
    LabelConfigHyperVLinkGreenTurtle: TLabel;
    LabelConfigHyperVLinkHostOS: TLabel;
    LabelConfigHyperVLinkKicksecure: TLabel;
    LabelConfigHyperVLinkUSBInstall: TLabel;
    LabelConfigHyperVLinkWhonixHost: TLabel;
    LabelConfigHyperVNotes: TLabel;
    LabelConfigHyperVNotesNotRoot: TLabel;
    LabelConfigHyperVNotesRoot: TLabel;
    LabelConfigHyperVNotesSecurity: TLabel;
    LabelConfigHyperVNotesUsability: TLabel;
    LabelConfigNoneDesc: TLabel;
    LabelComplete: TLabel;
    LabelCompleteDesc: TLabel;
    LabelConfigFullDesc: TLabel;
    LabelConfigMinimalDesc: TLabel;
    LabelConfiguration: TLabel;
    LabelConfigurationDesc: TLabel;
    LabelHyperVDisableDesc: TLabel;
    LabelHyperVDoNothingDesc: TLabel;
    LabelHyperVReEnableDesc: TLabel;
    LabelInstallation: TLabel;
    LabelInstallationDesc: TLabel;
    LabelLicense: TLabel;
    LabelLicenseDesc: TLabel;
    MemoLicense: TMemo;
    MemoOutput: TMemo;
    PageControl: TPageControl;
    PanelControl: TPanel;
    PanelStatus: TPanel;
    ProgressBar: TProgressBar;
    RadioButtonConfigFull: TRadioButton;
    RadioButtonConfigNone: TRadioButton;
    RadioButtonConfigMinimal: TRadioButton;
    RadioButtonHyperVDisable: TRadioButton;
    RadioButtonHyperVKeepCurrent: TRadioButton;
    RadioButtonHyperVReEnable: TRadioButton;
    HyperVScrollBox: TScrollBox;
    SelectDirectoryDialog: TSelectDirectoryDialog;
    TabSheetComplete: TTabSheet;
    TabSheetConfiguration: TTabSheet;
    TabSheetHyperV: TTabSheet;
    TabSheetInstallation: TTabSheet;
    TabSheetLicense: TTabSheet;
    procedure ButtonBackClick(Sender: TObject);
    procedure ButtonCancelClick(Sender: TObject);
    procedure ButtonNextClick(Sender: TObject);
    procedure CheckBoxLicenseChange(Sender: TObject);
    procedure CheckBoxOutputChange(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure LabelConfigHyperVLinkGreenTurtleClick(Sender: TObject);
    procedure LabelConfigHyperVLinkHostOSClick(Sender: TObject);
    procedure LabelConfigHyperVLinkKicksecureClick(Sender: TObject);
    procedure LabelConfigHyperVLinkUSBInstallClick(Sender: TObject);
    procedure LabelConfigHyperVLinkWhonixHostClick(Sender: TObject);
    procedure PageControlChange(Sender: TObject);
    procedure RadioButtonHyperVDisableChange(Sender: TObject);
    procedure RadioButtonHyperVKeepCurrentChange(Sender: TObject);
    procedure RadioButtonHyperVReEnableChange(Sender: TObject);
  private
    DebugMode: boolean;
    UnpackPath: string;

    function InstallationBuildInVBox: boolean;
    function InstallationBuildInStarter: boolean;
    function InstallationBuildInHyperV: boolean;
    procedure InstallationBuildIn;
    procedure InstallationScript(Script: TStrings);
    procedure Installation;
    procedure SetNextStatus(Step: integer; Status: string; Output: TStrings = Nil);
    procedure ResourceToFile(ResourceName, FileName: string; Output: TStrings);
  end;

const
  COMMANDLINE_OPTION_DEBUG = 'debug';

var
  InstallerForm: TInstallerForm;

implementation

{$R *.lfm}

{ TInstallerForm }

procedure TInstallerForm.CheckBoxOutputChange(Sender: TObject);
begin
  if CheckBoxOutput.Checked then
  begin
    MemoOutput.Show;
  end
  else
  begin
    MemoOutput.Hide;
  end;
end;

procedure TInstallerForm.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  if PageControl.ActivePage = TabSheetComplete then
  begin
    CanClose := True;
    Exit;
  end;

  if not ButtonCancel.Enabled then
  begin
    CanClose := False;
    Exit;
  end;

  if MessageDlg('Exit Installer',
    'Are you sure you want to cancel the Whonix installation?',
    mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    CanClose := True;
  end
  else
  begin
    CanClose := False;
  end;
end;

procedure TInstallerForm.ButtonNextClick(Sender: TObject);
begin
  ButtonBack.Enabled := False;
  ButtonNext.Enabled := False;
  ButtonCancel.Enabled := False;
  PageControl.ActivePageIndex := PageControl.ActivePageIndex + 1;
  PageControlChange(PageControl);
end;

procedure TInstallerForm.CheckBoxLicenseChange(Sender: TObject);
begin
  ButtonNext.Enabled := CheckBoxLicense.Checked;
end;

procedure TInstallerForm.RadioButtonHyperVKeepCurrentChange(Sender: TObject);
begin
  if RadioButtonHyperVKeepCurrent.Checked then ButtonNext.Enabled := True;
end;

procedure TInstallerForm.RadioButtonHyperVDisableChange(Sender: TObject);
begin
  if RadioButtonHyperVDisable.Checked then ButtonNext.Enabled := True;
end;

procedure TInstallerForm.RadioButtonHyperVReEnableChange(Sender: TObject);
begin
  if RadioButtonHyperVReEnable.Checked then ButtonNext.Enabled := True;
end;

procedure TInstallerForm.ButtonBackClick(Sender: TObject);
begin
  ButtonBack.Enabled := False;
  ButtonNext.Enabled := False;
  ButtonCancel.Enabled := False;
  PageControl.ActivePageIndex := PageControl.ActivePageIndex - 1;
  PageControlChange(PageControl);
end;

procedure TInstallerForm.ButtonCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TInstallerForm.FormCreate(Sender: TObject);
var
  ResourceStream: TResourceStream = Nil;
begin
  DebugMode := Application.HasOption(COMMANDLINE_OPTION_DEBUG);
  if DebugMode then
  begin
    InstallerForm.Caption := InstallerForm.Caption + ' [DEBUG MODE]';
    MemoOutput.Lines.Append('Info: installer is running in debug mode.');
  end
  else
  begin
    MemoOutput.Lines.Append('Info: installer is running in normal mode.');
    MemoOutput.Lines.Append('Info: append "--debug" to start in debug mode.');
  end;

  PageControl.ShowTabs := False;
  PageControl.ActivePageIndex := 0;

  InstallerForm.Icon.LoadFromResourceName(Hinstance, 'MAINICON');

  {$IFDEF WINDOWS}
  ImageBanner.Picture.LoadFromResourceName(Hinstance, 'BANNERWINDOWS');
  {$ELSE}
  ImageBanner.Picture.LoadFromResourceName(Hinstance, 'BANNERLINUX');
  TabSheetHyperV.TabVisible := False;
  {$ENDIF}

  ResourceStream := TResourceStream.Create(HInstance, 'LICENSE', RT_RCDATA);
  MemoLicense.Lines.LoadFromStream(ResourceStream);
  FreeAndNil(ResourceStream);

  MemoOutput.Hide;

  UnpackPath := GetAppConfigDir(False);
  if not ForceDirectories(UnpackPath) then
  begin
    ShowMessage('Error : directory for unpacking could not be created');
    Halt;
  end;

  while AppDiskGetFreeSpace(UnpackPath) < 4 * 1024 * 1024 * 1024 do
  begin
    if MessageDlg('no free disk space for temp data! ( 4GB needed )',
      'do you wish to select directory?', mtConfirmation, [mbYes, mbClose], 0) =
      mrYes then
    begin
      if SelectDirectoryDialog.Execute then
      begin
        UnpackPath := IncludeTrailingPathDelimiter(
          IncludeTrailingPathDelimiter(SelectDirectoryDialog.FileName) +
          ApplicationName);
        if not ForceDirectories(UnpackPath) then
        begin
          ShowMessage('Error : directory for unpacking could not be created');
          Halt;
        end;
      end;
    end
    else
    begin
      Halt;
    end;
  end;

  // cleanup temp install directory befor installation starts
  DeleteDirectory(UnpackPath, True);
end;

procedure TInstallerForm.FormDestroy(Sender: TObject);
begin
  if not DebugMode then
  begin
    DeleteDirectory(UnpackPath, False);
  end;
end;

procedure TInstallerForm.LabelConfigHyperVLinkGreenTurtleClick(Sender: TObject);
begin
  OpenURL(LabelConfigHyperVLinkGreenTurtle.Caption);
end;

procedure TInstallerForm.LabelConfigHyperVLinkHostOSClick(Sender: TObject);
begin
   OpenURL(LabelConfigHyperVLinkHostOS.Caption);
end;

procedure TInstallerForm.LabelConfigHyperVLinkKicksecureClick(Sender: TObject);
begin
  OpenURL(LabelConfigHyperVLinkKicksecure.Caption);
end;

procedure TInstallerForm.LabelConfigHyperVLinkUSBInstallClick(Sender: TObject);
begin
  OpenURL(LabelConfigHyperVLinkUSBInstall.Caption);
end;

procedure TInstallerForm.LabelConfigHyperVLinkWhonixHostClick(Sender: TObject);
begin
  OpenURL(LabelConfigHyperVLinkWhonixHost.Caption);
end;

procedure TInstallerForm.PageControlChange(Sender: TObject);
begin
  if PageControl.ActivePage = TabSheetLicense then
  begin
    ButtonNext.Caption := 'Next >';
    ButtonNext.Enabled := CheckBoxLicense.Checked;
    ButtonCancel.Enabled := True;
  end
  else if PageControl.ActivePage = TabSheetConfiguration then
  begin
    ButtonBack.Enabled := True;
    ButtonNext.Caption := 'Next >';
    ButtonNext.Enabled := True;
    ButtonCancel.Enabled := True;
  end
  else if PageControl.ActivePage = TabSheetHyperV then
  begin
    ButtonBack.Enabled := True;
    ButtonNext.Caption := 'Execute';
    ButtonNext.Enabled := RadioButtonHyperVKeepCurrent.Checked
      or RadioButtonHyperVDisable.Checked
      or RadioButtonHyperVReEnable.Checked;
    ButtonCancel.Enabled := True;
  end
  else if PageControl.ActivePage = TabSheetInstallation then
  begin
    ButtonNext.Caption := 'Execute';
    Installation;
  end
  else if PageControl.ActivePage = TabSheetComplete then
  begin
    ButtonBack.Visible := False;
    ButtonNext.Visible := False;
    ButtonCancel.Caption := 'Finish';
    ButtonCancel.Enabled := True;

    if DebugMode then
    begin
      MemoOutput.Parent := TabSheetComplete;
      MemoOutput.Show;
    end;
  end;
end;

function TInstallerForm.InstallationBuildInVBox: boolean;
const
  {$IFDEF WINDOWS}
  defaultVBoxManagePath = 'C:\Program Files\Oracle\VirtualBox\VBoxManage.exe';
  {$ELSE}
  defaultVBoxManagePath = '/usr/bin/VBoxManage';
  {$ENDIF}
var
  CurrentVBoxManagePath: string = '';
  Output: TStringList = Nil;
  ResourceStream: TResourceStream = Nil;
  ExeFileStream: TFileStream = Nil;
  IniFile: TIniFile = Nil;
  ExecuteSuccess: boolean = False;
  EndResult: boolean = True;
begin
  try
    if (not RadioButtonConfigFull.Checked)
      and (not RadioButtonConfigMinimal.Checked) then Exit(True);

    SetNextStatus(1, 'Checking if VirtualBox is already installed...');
    if not EnsureExePath(CurrentVBoxManagePath, defaultVBoxManagePath) then
    begin
      {$IFDEF WINDOWS}
      SetNextStatus(2, 'Unpacking VC++ Redistributable installer...');
      try
        ResourceToFile('VCREDIST', UnpackPath + 'vcredist.exe',
          InstallerForm.MemoOutput.Lines);
      except
        on E : Exception do
        begin
          SetNextStatus(-1,
            'VC++ Redistributable installer could not be unpacked.');
          MemoOutput.Append(E.Message);
          EndResult := False;
          Exit(False);
        end;
      end;

      SetNextStatus(3, 'Installing VC++ Redistributable...');
      try
        ExecuteSuccess := Execute('cmd.exe /c ""' + UnpackPath
          + 'vcredist.exe"" /install /quiet /norestart',
          InstallerForm.MemoOutput.Lines);
        if ExecuteSuccess = False then
        begin
          SetNextStatus(-1, 'VC++ Redistributable installation failed.');
          EndResult := False;
          Exit(False);
        end;
      except
        on E : Exception do
        begin
          SetNextStatus(-1,
            'A critical error occurred while installing the '
            + 'VC++ Redistributable.');
          MemoOutput.Append(E.Message);
          EndResult := False;
          Exit(False);
        end;
      end;

      SetNextStatus(4, 'Unpacking VirtualBox installer...');
      try
        ResourceToFile('VBOX', UnpackPath + 'vbox.exe',
          InstallerForm.MemoOutput.Lines);
      except
        on E : Exception do
        begin
          SetNextStatus(-1, 'VirtualBox installer could not be unpacked.');
          MemoOutput.Append(E.Message);
          EndResult := False;
          Exit(False);
        end;
      end;

      SetNextStatus(5, 'Installing VirtualBox...');
      try
        ExecuteSuccess := Execute('cmd.exe /c ""' + UnpackPath
          + 'vbox.exe"" --silent --ignore-reboot',
          InstallerForm.MemoOutput.Lines);
        if ExecuteSuccess = False then
        begin
          SetNextStatus(-1, 'VirtualBox installation failed.');
          EndResult := False;
          Exit(False);
        end;
      except
        on E : Exception do
        begin
          SetNextStatus(-1,
            'A critical error occurred while installing VirtualBox.');
          MemoOutput.Append(E.Message);
          EndResult := False;
          Exit(False);
        end;
      end;
      {$ENDIF}

      if not EnsureExePath(CurrentVBoxManagePath, defaultVBoxManagePath) then
      begin
        SetNextStatus(-1, 'VirtualBox could not be installed.');
        EndResult := False;
        Exit(False);
      end;
    end;

    SetNextStatus(6, 'Detecting already existing Whonix VMs.');
    Output := TStringList.Create;
    try
      Execute(CurrentVBoxManagePath + ' list vms', Output);
    except
      on E : Exception do
      begin
        SetNextStatus(-1,
          'A critical error occurred while getting a list of VMs '
          + 'from VirtualBox.');
        MemoOutput.Append(E.Message);
        EndResult := False;
        Exit(False);
      end;
    end;
    InstallerForm.MemoOutput.Lines.AddStrings(Output);

    // TODO: install/repair if only one of both VMs is missing?
    if not ContainsStr(Output.Text, 'Whonix-Gateway-Xfce') and not
      ContainsStr(Output.Text, 'Whonix-Workstation-Xfce') then
    begin
      SetNextStatus(7, 'Unpacking Whonix ova...');
      ExeFileStream := TFileStream.Create(Application.ExeName, fmOpenRead);
      ResourceStream := TResourceStream.Create(HInstance, 'OVAINFO',
        RT_RCDATA);
      IniFile := TIniFile.Create(ResourceStream);
      ExeFileStream.Position := ExeFileStream.Size
        - IniFile.ReadInt64('general', 'size', 0);
      FreeAndNil(IniFile);
      try
        StreamSaveToFile(ExeFileStream, UnpackPath + 'whonix.ova',
          InstallerForm.MemoOutput.Lines);
      except
        on E : Exception do
        begin
          SetNextStatus(-1, 'Failed to unpack Whonix ova.');
          MemoOutput.Append(E.Message);
          EndResult := False;
          Exit(False);
        end;
      end;
      FreeAndNil(ResourceStream);
      FreeAndNil(ExeFileStream);

      SetNextStatus(8, 'Installing Whonix-Gateway and Whonix-Workstation.');
      try
        ExecuteSuccess := Execute(CurrentVBoxManagePath + ' import "'
          + UnpackPath + 'whonix.ova'
          + '" --vsys 0 --eula accept --vsys 1 --eula accept',
          InstallerForm.MemoOutput.Lines);
        if ExecuteSuccess = False then
        begin
          SetNextStatus(-1, 'Whonix virtual machine installation failed.');
          EndResult := False;
          Exit(False);
        end;
      except
        on E : Exception do
        begin
          SetNextStatus(-1,
            'A critical error occurred while installing Whonix '
            + 'virtual machines.');
          MemoOutput.Append(E.Message);
          EndResult := False;
          Exit(False);
        end;
      end;
    end;

    Exit(True);
  finally
    if EndResult = False then ButtonCancel.Enabled := True;
    if Output <> Nil then FreeAndNil(Output);
    if ResourceStream <> Nil then FreeAndNil(ResourceStream);
    if ExeFileStream <> Nil then FreeAndNil(ExeFileStream);
    if IniFile <> Nil then FreeAndNil(IniFile);
  end;
end;

function TInstallerForm.InstallationBuildInStarter: boolean;
const
  {$IFDEF WINDOWS}
  defaultWhonixStarterPath = 'C:\Program Files\WhonixStarter\WhonixStarter.exe';
  {$ELSE}
  defaultWhonixStarterPath = '/usr/bin/WhonixStarter';
  {$ENDIF}
var
  CurrentWhonixStarterPath: string = '';
  ExecuteSuccess: boolean = False;
  EndResult: boolean = True;
begin
  try
    if not RadioButtonConfigFull.Checked then
    begin
      Exit(True);
    end;

    SetNextStatus(9, 'Checking if Whonix-Starter is already installed...');
    if not EnsureExePath(CurrentWhonixStarterPath,
      defaultWhonixStarterPath) then
    begin
      {$IFDEF WINDOWS}
      SetNextStatus(10, 'Unpacking Whonix-Starter installer...');
      try
        ResourceToFile('STARTER', UnpackPath + 'WhonixStarter.msi',
          InstallerForm.MemoOutput.Lines);
      except
        on E : Exception do
        begin
          SetNextStatus(-1, 'Whonix-Starter installer could not be unpacked.');
          MemoOutput.Append(E.Message);
          EndResult := False;
          Exit(False);
        end;
      end;

      SetNextStatus(11, 'Installing Whonix-Starter...');
      try
        ExecuteSuccess := Execute('msiexec /i "' + UnpackPath + 'WhonixStarter.msi"',
          InstallerForm.MemoOutput.Lines);
        if ExecuteSuccess = False then
        begin
          SetNextStatus(-1, 'Whonix-Starter installation failed.');
          EndResult := False;
          Exit(False);
        end;
      except
        on E : Exception do
        begin
          SetNextStatus(-1, 'A critical error occurred while installing '
            + 'Whonix-Starter.');
          MemoOutput.Append(E.Message);
          EndResult := False;
          Exit(False);
        end;
      end;
      {$ENDIF}

      if not EnsureExePath(CurrentWhonixStarterPath, defaultWhonixStarterPath) then
      begin
        SetNextStatus(-1, 'Whonix-Starter could not be installed.');
        EndResult := False;
        Exit(False);
      end;
    end;

    exit(True);
  finally
    if EndResult = False then ButtonCancel.Enabled := True;
  end;
end;

function TInstallerForm.InstallationBuildInHyperV: boolean;
var
  ScriptResource: string = '';
  ScriptFile: string = '';
  ScriptType: string = '';
  ExecuteSuccess: boolean = False;
  EndResult: boolean = True;
begin
  try
    if RadioButtonHyperVKeepCurrent.Checked then
    begin
      exit(True);
    end;

    if RadioButtonHyperVDisable.Checked then
    begin
      ScriptResource := 'DISABLEHYPERV';
      ScriptFile := 'DisableHyperV.bat';
      ScriptType := 'Hyper-V disable';
    end
    else
    begin
      ScriptResource := 'UNDODISABLEHYPERV';
      ScriptFile := 'UndoDisableHyperV.bat';
      ScriptType := 'Hyper-V undo-disable';
    end;

    SetNextStatus(12, 'Unpacking ' + ScriptType + ' script.');

    try
      ResourceToFile(ScriptResource, UnpackPath + ScriptFile, InstallerForm.MemoOutput.Lines);
    except
      on E : Exception do
      begin
        SetNextStatus(-1, '''' + ScriptFile + ''' could not be unpacked.');
        MemoOutput.Append(E.Message);
        EndResult := False;
        Exit(False);
      end;
    end;

    SetNextStatus(13, 'Running ' + ScriptType + ' script.');
    try
      ExecuteSuccess := Execute('cmd.exe /c ""' + UnpackPath + ScriptFile
        + '"" /q', InstallerForm.MemoOutput.Lines);
      if ExecuteSuccess = False then
      begin
        SetNextStatus(-1, 'The ' + ScriptType + ' script failed.');
        EndResult := False;
        Exit(False);
      end;
    except
      on E : Exception do
      begin
        SetNextStatus(-1, 'A critical error occurred while running the '
          + ScriptType + '.');
        MemoOutput.Append(E.Message);
        EndResult := False;
        Exit(False);
      end;
    end;

    exit(True);
  finally
    if EndResult = False then ButtonCancel.Enabled := True;
  end;
end;

procedure TInstallerForm.InstallationBuildIn;
begin
  if not InstallationBuildInVBox then Exit;
  if not InstallationBuildInStarter then Exit;
  if not InstallationBuildInHyperV then Exit;
  SetNextStatus(14, 'Installation completed!');
  if RadioButtonHyperVKeepCurrent.Checked then
  begin
    LabelRecommendReboot.Visible := False;
  end;
  ButtonNextClick(ButtonNext);
end;

procedure TInstallerForm.InstallationScript(Script: TStrings);
begin
  SetNextStatus(1, 'Saving install script to unpack path...');
  Script.SaveToFile(UnpackPath + 'whonix-xfce-installer-cli');

  {$IFNDEF WINDOWS}
  Execute('chmod +x ' + UnpackPath + 'whonix-xfce-installer-cli',
    InstallerForm.MemoOutput.Lines);

  SetNextStatus(2, 'Execute install script...');

  Execute(UnpackPath + 'whonix-xfce-installer-cli -d -n',
    InstallerForm.MemoOutput.Lines);
  {$ENDIF}

  SetNextStatus(-1, 'Test error.');
  ButtonCancel.Enabled := True;
  //ButtonNextClick(ButtonNext);
end;

procedure TInstallerForm.Installation;
{$IFNDEF WINDOWS}
var
  ResourceStream: TResourceStream;
  Script: TStringList;
{$ENDIF}
begin
  {$IFNDEF WINDOWS}
  ResourceStream := TResourceStream.Create(HInstance, 'SCRIPT', RT_RCDATA);
  Script := TStringList.Create;
  Script.LoadFromStream(ResourceStream);

  if (Script.Count > 0) and (Script.Strings[0] = '#!/bin/bash') then
  begin
    InstallationScript(Script);
  end
  else
  begin
    InstallationBuildIn;
  end;

  Script.Free;
  ResourceStream.Free;
  {$ELSE}
  InstallationBuildIn;
  {$ENDIF}
end;

procedure TInstallerForm.SetNextStatus(Step: integer; Status: string;
  Output: TStrings = Nil);
const
  MAX_STEPS = 14;
var
  i: integer;
begin
  if (Step >= 0) and (Step <= MAX_STEPS) then
  begin
    ProgressBar.Position := Step;
    PanelStatus.Caption := 'Step ' + IntToStr(Step) + ' / ' +
      IntToStr(MAX_STEPS) + ' : ' + Status;
  end
  else
  begin
    PanelStatus.Caption := 'Error : ' + Status;
  end;

  MemoOutput.Append(PanelStatus.Caption);

  if Output <> Nil then
  begin
    for i := 0 to Output.Count - 1 do
    begin
      MemoOutput.Append(Output.Strings[i]);
    end;
  end;

  //MemoOutput.Lines.SaveToFile(GetAppConfigDir(False) + 'Whonix.log');

  // wait 2 seconds to make status reading possible
  for i := 1 to 20 do
  begin
    Sleep(100);
    Application.ProcessMessages;
  end;
end;

procedure TInstallerForm.ResourceToFile(ResourceName, FileName: string;
  Output: TStrings);
var
  ResourceStream: TResourceStream;
begin
  if FindResource(HInstance, ResourceName, RT_RCDATA) = 0 then
  begin
    Output.Append('Error: could not find resource ' + ResourceName);
    raise EPathNotFoundException.Create ('Resource not found');
  end;

  ResourceStream := TResourceStream.Create(HInstance, ResourceName, RT_RCDATA);
  StreamSaveToFile(ResourceStream, FileName, Output);
  ResourceStream.Free;
end;

end.
