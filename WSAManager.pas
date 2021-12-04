unit WSAManager;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  madExceptVcl,
  UWP.Form, Vcl.ExtCtrls, Vcl.Menus, Vcl.WinXPanels, Vcl.StdCtrls,
  Vcl.WinXCtrls, Vcl.ControlList, UWP.ListButton, Vcl.Buttons, Vcl.VirtualImage,
  DzDirSeek, System.ImageList, Vcl.ImgList, SVGIconImageListBase,
  SVGIconImageList,
  System.Types, System.UITypes,
  // TrayIcon
  DosCommand, Net.HTTPClient, Winapi.IpHlpApi, Vcl.Imaging.pngimage,
  Vcl.BaseImageCollection, Vcl.ImageCollection, Data.DB, Datasnap.DBClient,
  Vcl.ComCtrls, DragDrop, DropTarget, DragDropFile, System.Notification,
  adb, RegChangeThread, TaskbarPinner, wsa;

const  // hard coded paths, for now located in the same directory where this application runs
  INIFILE = 'settings.ini';

  // Up to date download link for Windows is located here
  ADB_URL = 'https://dl.google.com/android/repository/platform-tools-latest-windows.zip';

type
  TSettings = record
    ADBPath: string;
    DownloadsPath: string;

  end;

  TAPKInfo = record
    AndroidPackageName: string;
    AndroidVersionCode: string;
    DisplayIcon: string;
    DisplayName: string;
    DisplayVersion: string;
    EstimatedSize: Integer;
    InstallDate: string;
    ModifyPath: string;
    NoRepair: Integer;
    Publisher: string;
    QuietUninstallString: string;
    UninstalString: string;
  end;

  TWSAStruct = record
    InstallPath: string;
    AppUserModelID: string;
    Version: string;
    DisplayName: string;
    WsaSettings: string;
    WsaClient: string;
    PublisherDisplayName: string;
    LogoPath: string; // replace .png with .scale-100.png .scale-125.png .scale-150.png .scale-200.png or .scale-400.png
    MinWinVersion: string;
  end;

  TDownloadEvent = procedure(Sender: TObject; DownloadCode: Integer) of Object;

  TDownloader = class
  private
    FValue: Byte;

    FClient: THTTPClient;
    FGlobalStart: Cardinal;
    FGlobalStep: Cardinal;
    FAsyncResult: IAsyncResult;
    FDownloaderStream: TStream;
    FSize: Int64;
    FURL: string;
    FUA: string;
    FHeader: string;
    FSavePath: string;

    FOnDownloaded: TDownloadEvent;

    FDownloading: Boolean;
    FAbortNow: Boolean;
    FAborted: Boolean;
    procedure SetValue(const Value: byte);
  protected
    procedure DoReceiveDataEvent(const Sender: TObject; AContentLength: Int64;
      AReadCount: Int64; var Abort: Boolean);
    procedure DoEndDownload(const AsyncResult: IAsyncResult);
  public
    constructor Create;
    destructor Destroy; override;
    procedure DoStartDownload;
    procedure AbortDownload;

    property Value: byte read FValue write SetValue;

    property OnDownloaded: TDownloadEvent read FOnDownloaded write FOnDownloaded;
    property IsDownloading: Boolean read FDownloading;

    property URL: string read FURL write FURL;
    property Header: string read FHeader write FHeader;
    property UserAgent: string read FUA write FUA;
    property SavePath: string read FSavePath write FSavePath;
  end;

type
  TfrmWinDroid = class(TUWPForm)
    MadExceptionHandler1: TMadExceptionHandler;
    TrayIcon1: TTrayIcon;
    PopupMenu1: TPopupMenu;
    Exit1: TMenuItem;
    N1: TMenuItem;
    About1: TMenuItem;
    RunatStartup1: TMenuItem;
    crdContainer: TCardPanel;
    crdApps: TCard;
    crdInstaller: TCard;
    crdMisc: TCard;
    crdSettings: TCard;
    ControlList1: Vcl.ControlList.TControlList;
    btnListApps: TButton;
    SearchBox1: TSearchBox;
    GridPanel1: TGridPanel;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    SpeedButton4: TSpeedButton;
    lbListPackageName: TLabel;
    listAPKImage: TVirtualImage;
    lbListAPKTitle: TLabel;
    ControlListButton1: TControlListButton;
    ControlListButton2: TControlListButton;
    DzDirSeek1: TDzDirSeek;
    pnlWSAState: TPanel;
    Image1: TImage;
    lbWSAInfo: TLabel;
    lbWSAVersion: TLabel;
    lbWSAMUI: TLabel;
    lbWSAMinWinVer: TLabel;
    lbWSAPublisher: TLabel;
    lbWSAForeground: TLabel;
    lbWSAStatus: TLabel;
    ImageCollection1: TImageCollection;
    ClientDataSet1: TClientDataSet;
    ActivityIndicator1: TActivityIndicator;
    PopupMenu2: TPopupMenu;
    LaunchWSASettings1: TMenuItem;
    OpenWSAInstallationFolder1: TMenuItem;
    N2: TMenuItem;
    RunAPK1: TMenuItem;
    GetAPKInfo1: TMenuItem;
    UninstallAPK1: TMenuItem;
    N3: TMenuItem;
    About2: TMenuItem;
    Exit2: TMenuItem;
    ImageList1: TImageList;
    leADBPath: TLabeledEdit;
    btnSearchADBPath: TButton;
    btnDownloadADB: TButton;
    ProgressBar1: TProgressBar;
    leDownloadsPath: TLabeledEdit;
    Button1: TButton;
    cbAutostart: TCheckBox;
    cbFullScreenF11: TCheckBox;
    cbAPKShellRegister: TCheckBox;
    WSAIncludedPackages1: TMenuItem;
    Files1: TMenuItem;
    DebuggingOptions1: TMenuItem;
    Gallery1: TMenuItem;
    Contacts1: TMenuItem;
    ManageAPK1: TMenuItem;
    SearchInstallAPKs1: TMenuItem;
    SearchUpdates1: TMenuItem;
    pnlDrop: TPanel;
    DropFileTarget1: TDropFileTarget;
    lbDropMsg: TLabel;
    PageControl1: TPageControl;
    tsADB: TTabSheet;
    tsMisc: TTabSheet;
    GroupBox1: TGroupBox;
    gbADBinfo: TGroupBox;
    lblADBVersion: TLabel;
    lblPublisher: TLabel;
    lblADBStatus: TLabel;
    lblADBPort: TLabel;
    HotKey1: THotKey;
    cbHKShow: TCheckBox;
    gbWSAUtils: TGroupBox;
    gbAppSettings: TGroupBox;
    NotificationCenter1: TNotificationCenter;
    tsNotifications: TTabSheet;
    cbNotifyADB: TCheckBox;
    cbNotifyAPKInstalled: TCheckBox;
    cbNotifyWSAStatus: TCheckBox;
    lbNotify: TLabel;
    ExploreAPK1: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    btnAdbStatus: TButton;
    OpenDialog1: TOpenDialog;
    edADBPort: TEdit;
    edADBSocketCommand: TEdit;
    btnShellCommand: TButton;
    PintoTaskbar1: TMenuItem;
    CheckNewWSAversion1: TMenuItem;
    procedure Exit1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure TrayIcon1Click(Sender: TObject);
    procedure btnListAppsClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ControlList1BeforeDrawItem(AIndex: Integer; ACanvas: TCanvas;
      ARect: TRect; AState: TOwnerDrawState);
    procedure SearchBox1Change(Sender: TObject);
    procedure ControlList1ContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure SpeedButton2Click(Sender: TObject);
    procedure ControlList1Click(Sender: TObject);
    procedure btnDownloadADBClick(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
    procedure SpeedButton4Click(Sender: TObject);
    procedure GetAPKInfo1Click(Sender: TObject);
    procedure UninstallAPK1Click(Sender: TObject);
    procedure ControlList1DblClick(Sender: TObject);
    procedure Files1Click(Sender: TObject);
    procedure DebuggingOptions1Click(Sender: TObject);
    procedure Gallery1Click(Sender: TObject);
    procedure Contacts1Click(Sender: TObject);
    procedure ManageAPK1Click(Sender: TObject);
    procedure RunAPK1Click(Sender: TObject);
    procedure SearchInstallAPKs1Click(Sender: TObject);
    procedure SearchUpdates1Click(Sender: TObject);
    procedure DropFileTarget1Drop(Sender: TObject; ShiftState: TShiftState;
      APoint: TPoint; var Effect: Integer);
    procedure FormPaint(Sender: TObject);
    procedure LaunchWSASettings1Click(Sender: TObject);
    procedure OpenWSAInstallationFolder1Click(Sender: TObject);
    procedure Exit2Click(Sender: TObject);
    procedure ExploreAPK1Click(Sender: TObject);
    procedure btnAdbStatusClick(Sender: TObject);
    procedure btnSearchADBPathClick(Sender: TObject);
    procedure pnlWSAStateMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure btnShellCommandClick(Sender: TObject);
    procedure PintoTaskbar1Click(Sender: TObject);
    procedure CheckNewWSAversion1Click(Sender: TObject);
  protected
    // TaskbarLocation
    function GetMainTaskbarPosition: Integer;

    function GetWSAInstallationPath(amui: string): string;

    function ReplaceAmazonAppstore: Boolean;
    { TODO : In Progress, Shell:AppsFolder items can resolve to lnk files at Shell:Programs directory, we need to do that }
    function IsWsaClientLnkTarget(value: string): Boolean;
    function IsWsaClientRunning:Boolean;
    procedure CheckWsaClientStatus;
    procedure GetApkInfo(var Apk: TAPKInfo; const PackageName: string);
    function GetCurrentWSAVersionFromStore: string;

    procedure CreateParams(var Params: TCreateParams); override;
    procedure NoBorder(var Msg: TWMNCActivate); message WM_NCACTIVATE;

    procedure CreateBlurBackground;
    procedure DestroyBlurBackground;
    procedure UpdateBlurBackground;

    procedure SaveINI;
    procedure LoadINI;
  private
    { Private declarations }
    FBlurBackground: HWND;
    WSA: TWSAStruct;
    WSAM: TWSA;
    ControlListIndex: Integer;
    ControlListFiltered: Boolean;
    AppList: TStringList;
    AppListSearchFilter: TStringList;

    // Handle WSA apps un/pinning on Taskbar
    FPinMonitor: TRegMon;
    FPinnedLnkList: TStringList;
    FPinner: TTaskbarPinner;
    procedure MonitorPinRegistry(Sender: TObject);
  public
    { Public declarations }
    ApkInfo: TAPKInfo;
    ADB: TADB;
    procedure APKLaunch(const PackageName: string; specialUri: string = '/launch wsa://');

    procedure PinMonitor(var Msg: TMessage); message WM_REGKEYCHANGE;
  end;

var
  frmWinDroid: TfrmWinDroid;
  Hook: NativeUInt;
  prevRect: TRect;
  AppsClasses: TStringList;
  AppsClassesSearchFilter: TStringList;
  WsaClientPath: string;
  WndProcHook: THandle;
  IsForegroundWSA: Boolean = False;
  ForegroundWSA: THandle;


implementation

uses
  Vcl.Themes, frmApkInstaller, frmApkViewer,
  Winapi.PsAPI, Winapi.DwmApi, Winapi.MultiMon,
  Winapi.ShellAPI, System.Win.Registry, Winapi.msxml, System.IOUtils,
  Winapi.KnownFolders, Winapi.ShlObj, Winapi.ActiveX, System.Win.ComObj,
  Winapi.PropKey, Winapi.oleacc, System.Threading, frmBrowser,
  UWP.ColorManager, helperFuncs, Winapi.GDIPAPI, System.IniFiles,
  Net.Mime, System.RegularExpressions;

const
  WM_TOGGLEFULLSCREEN = WM_USER + 9;


  function StartHook:BOOL; stdcall; external 'F11Hook.dll' name 'STARTHOOK';
  procedure StopHook; stdcall; external 'F11Hook.dll' name 'STOPHOOK';

{$R *.dfm}

function Icon2Bitmap(hIcon: HICON; ABmp: TBitmap): Boolean;
var
  LIcon: TIcon;
  LBmp: TBitmap;
  LStream: TMemoryStream;
begin
  Result := False;
  LIcon := TIcon.Create;
  LBmp := TBitmap.Create;
  LStream := TMemoryStream.Create;
  try
    LIcon.Handle := hIcon;
    LBmp.SetSize(LIcon.Width, LIcon.Height);
    LBmp.PixelFormat := pf32bit;
    if DrawIcon(LBmp.Canvas.Handle, 0, 0, LIcon.Handle) then
    begin
      ABmp.SetSize(LBmp.Width, LBmp.Height);
      LBmp.SaveToStream(LStream);
      LStream.Position := 0;
      ABmp.LoadFromStream(LStream);
    end;
  finally
    LStream.Free;
    LBmp.Free;
    LIcon.Free;
  end;
end;

procedure WinEventProc(hWinEventHook: NativeUInt; dwEvent: DWORD; handle: HWND;
  idObject, idChild: LONG; dwEventThread, dwmsEventTime: DWORD);
var
  LHWindow: HWND;
  LHFullScreen: BOOL;
  vRect: TRect;
  ParentHandle: HWND;
  clsName: array[0..255] of Char;
  pid: DWORD;
  path: array [0..4095] of Char;
begin
  if (dwEvent = EVENT_OBJECT_LOCATIONCHANGE)
  or (dwEvent = EVENT_SYSTEM_FOREGROUND) then
  begin
    LHWindow := GetForegroundWindow;
    if LHWindow <> 0 then
    begin
      GetWindowRect(LHWindow, vRect);
      if prevRect <> vRect then
      begin
        prevRect := vRect;
        // process current 64bit foreground window to find out if it is a WsaClient.exe instance
        // and what WindowState is currently applied, in order to toggle its size with the keyhook dll
        GetClassName(LHWindow, clsName, 255);
        if Trim(clsName) <> '' then
        begin
          frmWinDroid.lbWSAForeground.Caption := '';
          // check if this class name is one of our listed applications
          if AppsClasses.IndexOfName(clsName) <> -1 then
          begin
            GetWindowThreadProcessId(LHWindow, pid);
            var proc := OpenProcess(PROCESS_QUERY_INFORMATION or PROCESS_VM_READ, False, pid);
            if proc <> 0 then
            begin
              try
                GetModuleFileNameEx(proc, 0, @path[0], Length(path));
                // check if is our wsaclient, and not other executable named the same
                if Trim(path) = Trim(WsaClientPath) then
                begin
                  frmWinDroid.lbWSAForeground.Caption := 'WSA App: ' + clsName;
//                  WinDroidHwnd.lbWSAVersion.Text := path;
                  IsForegroundWSA := True;
                  ForegroundWSA := LHWindow;
                end
                else
                begin
                  IsForegroundWSA := False;
                  ForegroundWSA := 0;
                end;
              finally
                CloseHandle(proc);
              end;
            end;
          end;
        end;
      end;
    end;
  end;
  // check wsaclient.exe status using shell events
  if (dwEvent = EVENT_OBJECT_CREATE) or
  (dwEvent = EVENT_OBJECT_DESTROY)
  then
  begin
    if (idObject = OBJID_WINDOW) //or (idChild = INDEXID_CONTAINER)
    then
    begin
      frmWinDroid.CheckWsaClientStatus;
    end;
  end;
end;

function WndProc(nCode: Integer; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
var
  msg: TCWPRetStruct;
  LMonitor: HMONITOR;
  MonInfo: MONITORINFO;
  IsFull: Boolean;
begin
  if (nCode >= HC_ACTION) {and (lParam > 0)} then
  begin
    msg := PCWPRetStruct(lParam)^;

    // v 1.7.32815.0, v 1.8.32822.0 seems includes Fullscreen mode
    if (msg.message = WM_TOGGLEFULLSCREEN) then
    begin
//      OutputDebugString('F11 EVENT');
//      WinDroidHwnd.lbWSAVersion.Text := 'F11 ' + inttoStr(Random(100));
      // if current foreground window is an Android app, let's toogle its size to mimix windowed fullscreen
      if IsForegroundWSA
      and (GetForegroundWindow = ForegroundWSA)
      and IsWindow(ForegroundWSA)
      then
      begin
        var style := GetWindowLong(ForegroundWSA, GWL_STYLE);
        if (style and WS_CAPTION = WS_CAPTION)
        and (style and WS_THICKFRAME = WS_THICKFRAME)
        and (style and WS_MAXIMIZE <> WS_MAXIMIZE)
        then
        begin
          style := style and not WS_CAPTION;
          style := style and not WS_THICKFRAME;
          IsFull := False; //current fullscreen state
        end
        else
        begin
          style := style or WS_CAPTION;
          style := style or WS_THICKFRAME;
          IsFull := True;
        end;

        SetWindowLong(ForegroundWSA, GWL_STYLE, style);

        LMonitor := Winapi.MultiMon.MonitorFromWindow(ForegroundWSA, MONITOR_DEFAULTTOPRIMARY);
        MonInfo.cbSize := SizeOf(MONITORINFO);
        GetMonitorInfo(LMonitor, @MonInfo);

//        if IsFull then
//        SetWindowPos(ForegroundWSA, 0,
//          MonInfo.rcWork.Left,
//          MonInfo.rcWork.Top,
//          MonInfo.rcWork.Width,
//          MonInfo.rcWork.Height,
//          {SWP_NOSIZE or} SWP_NOMOVE or SWP_FRAMECHANGED or SWP_NOACTIVATE)
//        else
//        SetWindowPos(ForegroundWSA, 0,
//          MonInfo.rcMonitor.Left,
//          MonInfo.rcMonitor.Top,
//          MonInfo.rcMonitor.Width,
//          MonInfo.rcMonitor.Height,
//          SWP_NOMOVE or SWP_FRAMECHANGED or SWP_NOACTIVATE);
//        Sleep(1);
        if IsFull then
          SendMessage(ForegroundWSA, WM_SYSCOMMAND, SC_RESTORE, 0)
        else
          SendMessage(ForegroundWSA, WM_SYSCOMMAND, SC_MAXIMIZE, 0);
      end;
    end;
  end;

  Result := CallNextHookEx(WndProcHook, nCode, wParam, lParam);
end;

procedure TfrmWinDroid.APKLaunch(const PackageName: string; specialUri: string = '/launch wsa://');
begin
  ShellExecute(0, 'OPEN', PChar(WSA.InstallPath + WSA.WsaClient), PChar(specialUri+PackageName), nil, SW_SHOWNORMAL);
end;

procedure TfrmWinDroid.btnAdbStatusClick(Sender: TObject);
begin
  if not FileExists(ADB.Path) then
  begin
    gbADBinfo.Caption := 'ADB not found!';
  end
  else
  begin
    gbADBinfo.Caption := 'ADB Found :)';
    lblADBVersion.Caption := 'Version:  ' + FileVersionGet(ADB.Path);
    lblPublisher.Caption := 'Publisher: ' + GetExeCertCompanyName(ADB.Path);
    if ADB.ConnectSocket(StrToInt(edADBPort.Text)) then
    begin
      lblADBStatus.Caption := 'ADB Server Status: Connected';
    end
    else
      lblADBStatus.Caption := 'ADB Server Status: Not connected!';
  end;
end;

procedure TfrmWinDroid.btnDownloadADBClick(Sender: TObject);
var
  pv: IShellItem;
  pv13: Int64;
begin
  SHCreateItemFromParsingName('', nil, IID_IShellItem, pv);
  CoCreateInstance(CLSID_StartMenuPin, nil, 1, IID_IStartMenuPinnedList, pv13);
end;

procedure TfrmWinDroid.btnListAppsClick(Sender: TObject);
//var
//  LStyleName: string;
//begin
//  frmInstaller.Show;
//  Exit;
//  LStyleName := TStyleManager.ActiveStyle.Name;
//
//  if ShowVCLThemeSelector(LStyleName,
//      False,
//      4,
//      4) then
//  begin
//    try
//      TStyleManager.SetStyle(LStyleName);
//    except
//
//    end;
//
//  end;
var
  io: IKnownFolderManager;
  count: Cardinal;
//  vie: array [0..65534] of TGUID;
  a: PGUIDList;
  knownfoldernative: IKnownFolder;
  hr: HRESULT;
  oguid: TGUID;
  si: IShellItem2;
  sfgao: Cardinal;
  isFileSystem: Boolean;
  fd: TKnownFolderDefinition;
  Item: TStrings;
  fPath: array[0..1024] of Char;
begin
  if ActivityIndicator1.Animate then Exit;

  ActivityIndicator1.Visible := True;
  ActivityIndicator1.Animate := True;
  ActivityIndicator1.StartAnimation;
  SearchBox1.Enabled := False;
  SearchBox1.Text := '';

  ControlList1.ItemCount := 0;

  TTask.Run(
    procedure
    begin
      CoInitialize(nil);

      //FOLDERID_AppsFolder 1e87508d-89c2-42f0-8a7e-645a0f50ca58
      CoCreateInstance(CLSID_KnownFolderManager, nil, CLSCTX_ALL, IKnownFolderManager, io);
      if Assigned(io) then
      begin
        //SHGetKnownFolderIDList(FOLDERID_NetworkFolder)
    //    io.GetFolderIds(vie, count);
        hr := io.GetFolder(FOLDERID_AppsFolder, knownfoldernative);
        if hr = S_OK then
        begin
          //kf := get
          hr := knownfoldernative.GetShellItem(0, IID_IShellItem2, si);
          if Succeeded(hr) then
          begin
            if si <> nil then
            begin
              si.GetAttributes(SFGAO_FILESYSTEM, sfgao);
    //          sfgao and
              isFileSystem := (sfgao and SFGAO_FILESYSTEM) <> 0;
            end;
            // not file system
            if not isFileSystem then
            begin
              knownfoldernative.GetShellItem(0, IID_IShellItem2, si); //nativeShellItem should go instead of si
              knownfoldernative.GetFolderDefinition(fd);
              var pidControl: PItemIDList;
              var psfDesktop, dt: IShellFolder;
              var psfControl: IShellFolder;
              var pc: IShellFolder2;
              var pEnumList: IEnumIDList;
              var pidChild: PItemIDList;
              var pidAbsolute: PItemIDList;
              var celtFetched: ULONG;
              var FileInfo: SHFILEINFOW;

              OleCheck(SHGetDesktopFolder(psfDesktop));
              OleCheck(SHGetDesktopFolder(dt));
              olecheck(knownfoldernative.GetIDList(KF_FLAG_DEFAULT, pidControl));
              OleCheck(psfDesktop.BindToObject(pidControl, nil, IID_IShellFolder, psfControl));
              OleCheck(psfControl.EnumObjects(0, SHCONTF_NONFOLDERS or SHCONTF_INCLUDEHIDDEN, pEnumList));

              AppList.BeginUpdate;
              AppList.Clear;
              AppsClasses.BeginUpdate;
              ImageCollection1.Images.Clear;
              AppsClasses.Clear;

              while pEnumList.Next(1, pidChild, celtFetched) = 0 do
              begin
                pidAbsolute := ILCombine(pidControl, pidChild);
                OleCheck(dt.BindToObject(pidControl, nil, IID_IShellFolder2, Pointer(pc)));
                var sa,lnk, flnk: OleVariant;
    //            var cs: SHCOLUMNID;
    //            cs.fmtid := StringToGUID('{9F4C2855-9F79-4B39-A8D0-E1D42DE1D5F3}');
    //            cs.pid := 5;
                OleCheck((pc.GetDetailsEx(pidChild, SHCOLUMNID(PKEY_AppUserModel_ID), @sa)));
                var re:HRESULT;
                try
                  re := (pc.GetDetailsEx(pidChild, SHCOLUMNID(PKEY_Link_Arguments), @flnk));
                  re := (pc.GetDetailsEx(pidChild, SHCOLUMNID(PKEY_Link_TargetParsingPath), @lnk));
                  SHGetPathFromIDList(pidAbsolute, fPath);
                except
                  lnk := '';
                end;
    { TODO : If ADB connection is established, better list using adb shell cmd package list packages -3 }
                if IsValidAppPackageName(sa)
                or (Pos('!Setti', sa) > 0)
                then
                begin
    //            SHILCreateFromPath(LPCTSTR(pidAbsolute), pidAbsolute, nil);
                  SHGetFileInfo(LPCTSTR(pidAbsolute), 0, FileInfo, SizeOf(FileInfo),
                  SHGFI_PIDL or SHGFI_DISPLAYNAME or SHGFI_ICON or SHGFI_SYSICONINDEX {or SHGFI_SHELLICONSIZE} or SHGFI_LARGEICON);
    //              pc.GetUIObjectOf(0, )
    //              var c:uint32;
    //              pc.GetAttributesOf(1,pidChild,c);
                  CoTaskMemFree(pidAbsolute);

                  var icon := TIcon.Create;
                      icon.Handle := FileInfo.hIcon;

                  if (Pos('!Sett', sa) > 0) then
                  begin
                    lbWSAInfo.Caption := FileInfo.szDisplayName;
                    lbWSAMUI.Caption := sa;
    //                Icon2Bitmap(icon.Handle, imgWSA.Bitmap);
                  end
                  else if (LowerCase(lnk).Contains('wsaclient.exe')) then//if IsWsaClientLnkTarget(sa) then
                  begin
                    Item := TStrings.Create;
                    try
                      AppList.NameValueSeparator := '|';
                      AppList.AddPair(FileInfo.szDisplayName,lnk);
                    ///////////////Icon2Bitmap(icon.Handle, Item.Bitmap);
                      var ims := TMemoryStream.Create;
                      var bmp := TBitmap.Create;
                      try
                        // prefer PNG files in localstate
                        var png: TPngImage;
                        var iconpath: string;
                        var localpath: string;
                        localpath := GetEnvironmentVariable('localappdata');//'%LOCALAPPDATA%');
                        iconpath := localpath+'\Packages\MicrosoftCorporationII.WindowsSubsystemForAndroid_8wekyb3d8bbwe\LocalState\'+sa+'.png';
                        if WSA.AppUserModelID <> '' then
                        begin
                          var amui := Copy(WSA.AppUserModelID, 1, Pos('!', WSA.AppUserModelID)-1);
                          iconpath := localpath+'\Packages\'+amui+'\LocalState\'+sa+'.png';
                        end;

                        if FileExists(iconpath) then
                        begin
                          png := TPngImage.Create;
                          try
                            png.LoadFromFile(iconpath);
                            bmp.Assign(png);
                            bmp.SaveToStream(ims);
                            ims.Position := 0;
                            ImageCollection1.Add(sa, ims);
                          finally
                            png.Free;
                          end;
                        end
                        else
                        begin
                          bmp.SetSize(icon.Width, icon.Height);
                          bmp.PixelFormat := pf32bit;
                          if DrawIcon(bmp.Canvas.Handle, 0, 0, icon.Handle) then
                          begin
                            bmp.SaveToStream(ims);
                            ims.Position := 0;
                            ImageCollection1.Add(sa, ims);
                          end;
                        end;
                      finally
                        bmp.Free;
                        ims.Free;
                      end;

                      AppsClasses.AddPair(sa, string(flnk));
                    finally
                      Item.Free;
                    end;
                  end;

                  icon.Free;
                end;

                CoTaskMemFree(pidChild);
              end;

              AppsClasses.EndUpdate;
              AppList.EndUpdate;
              ControlList1.ItemCount := AppList.Count;

              CoTaskMemFree(pidControl);
            end;
          end
          else
            OleCheck(hr);
        end;
      end;

      CoUninitialize;
      TThread.Synchronize(nil,
      procedure
      begin
        ActivityIndicator1.StopAnimation;
        ActivityIndicator1.Visible := False;
        ActivityIndicator1.Animate := False;
        SearchBox1.Enabled := True;
        GetWSAInstallationPath(lbWSAMUI.Caption); // this makes sure it is correct and updates WSA record info
        lbWSAVersion.Caption := 'Version: ' + WSA.Version;
        lbWSAMinWinVer.Caption := 'Minimum Windows Build: ' + WSA.MinWinVersion;
        lbWSAPublisher.Caption := 'Publisher: ' + WSA.PublisherDisplayName;
      end
      );
    end
  );
end;

procedure TfrmWinDroid.btnSearchADBPathClick(Sender: TObject);
begin
  OpenDialog1.Filter := 'adb executable|adb.exe|All files|*.*';
  if OpenDialog1.Execute then
  begin
    leADBPath.Text := OpenDialog1.FileName;
    ADB.Path := OpenDialog1.FileName;

    SaveINI;
  end;

end;

procedure TfrmWinDroid.btnShellCommandClick(Sender: TObject);
begin
// encode message
  var hex := inttohex(WORD(Length(edADBSocketCommand.Text)));
  ADB.ConnectSocket() ;
  ShowMessage( ADB.RunScript(PChar(Format('%4s%s',[hex,edADBSocketCommand.Text]))));
//  ShellExecute(0, 'OPEN', PChar(ADB.Path), PChar('connect 127.0.0.1:58526'), nil, SW_SHOWNORMAL);
//  ShellExecute(0, 'OPEN', PChar(ADB.Path), PChar(edADBSocketCommand.Text), nil, SW_SHOWNORMAL);
end;

procedure TfrmWinDroid.CheckNewWSAversion1Click(Sender: TObject);
begin
  GetCurrentWSAVersionFromStore;
end;

procedure TfrmWinDroid.CheckWsaClientStatus;
var
  state: Boolean;
begin
  state := IsWsaClientRunning;
  if state then
    lbWSAStatus.Caption := 'Running'
  else
  begin
    lbWSAStatus.Caption := 'Not running';
  end;
  {TODO: MonochromeEffect1.Enabled :=  not state;}
end;

procedure TfrmWinDroid.Contacts1Click(Sender: TObject);
begin
  APKLaunch('com.android.contacts');
end;

procedure TfrmWinDroid.ControlList1BeforeDrawItem(AIndex: Integer;
  ACanvas: TCanvas; ARect: TRect; AState: TOwnerDrawState);
begin
  if ControlListFiltered and (AppListSearchFilter.Count > 0)
  and (AppsClassesSearchFilter.Count > 0)
  then
  begin
    lbListAPKTitle.Caption := AppListSearchFilter.Names[AIndex];
    lbListPackageName.Caption := AppsClassesSearchFilter.Names[AIndex];
    listAPKImage.ImageName := AppsClassesSearchFilter.Names[AIndex];
  end
  else
  begin
    lbListAPKTitle.Caption := AppList.Names[AIndex];
    lbListPackageName.Caption := AppsClasses.Names[AIndex];
    listAPKImage.ImageName := AppsClasses.Names[AIndex];
  end;
end;

procedure TfrmWinDroid.ControlList1Click(Sender: TObject);
begin
//

end;

procedure TfrmWinDroid.ControlList1ContextPopup(Sender: TObject;
  MousePos: TPoint; var Handled: Boolean);
begin
  ControlListIndex := ControlList1.HotItemIndex;
  if not ControlListFiltered then
  begin
    if ControlList1.HotItemIndex >= 0 then
    begin
      ImageList1.BeginUpdate;
      ImageList1.Clear;
      ImageList1.Add(ImageCollection1.GetBitmap(AppsClasses.Names[ControlList1.HotItemIndex], 24, 24),nil);
      ImageList1.EndUpdate;
      RunAPK1.Caption := 'Launch ' + AppList.Names[ControlList1.HotItemIndex];
      RunAPK1.ImageIndex := 0;
    end;
  end
  else
  begin
    if ControlList1.HotItemIndex >= 0 then
    begin
      ImageList1.BeginUpdate;
      ImageList1.Clear;
      ImageList1.Add(ImageCollection1.GetBitmap(AppsClassesSearchFilter.Names[ControlList1.HotItemIndex], 16, 16),nil);
      ImageList1.EndUpdate;
      RunAPK1.Caption := 'Launch ' + AppListSearchFilter.Names[ControlList1.HotItemIndex];
      RunAPK1.ImageIndex := 0;
    end;
  end;
end;

procedure TfrmWinDroid.ControlList1DblClick(Sender: TObject);
begin
  if (ControlList1.HotItemIndex >= 0) and (ControlList1.ItemCount > 0)
  then
  begin
    if ControlListFiltered then
      APKLaunch(AppsClassesSearchFilter.Names[ControlList1.HotItemIndex])
    else
    begin
      APKLaunch(AppsClasses.Names[ControlList1.HotItemIndex]);
    end;

  end;
end;

procedure TfrmWinDroid.CreateBlurBackground;
var
  d:Integer;
begin
  if FBlurBackground = 0 then
  try
    FBlurBackground := CreateWindowEx(WS_EX_LAYERED + WS_EX_TOOLWINDOW, 'WSABLUR',
//      'BlurBackground', WS_POPUP, -100, -100, 10, 10, 0, 0, HInstance, nil);
      'BlurBackground', WS_POPUP, Left, Top, Width, Height, 0, 0, HInstance, nil);
    //exclude from peek
    DwmSetWindowAttribute(FBlurBackground, DWMWA_EXCLUDED_FROM_PEEK, @d, SizeOf(d));
    d := DWMFLIP3D_EXCLUDEBELOW;
    DwmSetWindowAttribute(FBlurBackground, DWMWA_FLIP3D_POLICY, @d, SizeOf(d));

    SetWindowLongPtr(Handle, GWL_HWNDPARENT, FBlurBackground); // attach main window
//    SetWindowPos(FBlurBackground, Handle, 0, 0, 0, 0, SWP_NOSIZE or SWP_NOMOVE or SWP_NOACTIVATE or SWP_NOOWNERZORDER or SWP_NOSENDCHANGING or SWP_ASYNCWINDOWPOS);
    SetWindowPos(FBlurBackground, Handle, Left, Top, Width, Height, SWP_NOACTIVATE or SWP_NOOWNERZORDER or SWP_NOSENDCHANGING or SWP_ASYNCWINDOWPOS);
  except
    on E: Exception do raise Exception.Create('Error Message' + sLineBreak + E.Message);
  end;

end;

procedure TfrmWinDroid.CreateParams(var Params: TCreateParams);
begin
  inherited;

  Params.WinClassName := 'FMTWinDroidHwnd';
end;

procedure TfrmWinDroid.DebuggingOptions1Click(Sender: TObject);
begin
  APKLaunch('developer-settings', '/deeplink wsa-client://');
end;

procedure TfrmWinDroid.DestroyBlurBackground;
begin
  try
    SetWindowLongPtr(Handle, GWL_HWNDPARENT, 0); // detach main window
    if IsWindow(FBlurBackground) then
      DestroyWindow(FBlurBackground);
    FBlurBackground := 0;
  except
    on E: Exception do raise Exception.Create('Error Message' + sLineBreak + e.Message);
  end;
end;

procedure TfrmWinDroid.DropFileTarget1Drop(Sender: TObject;
  ShiftState: TShiftState; APoint: TPoint; var Effect: Integer);
begin
  lbDropMsg.Caption := '';
  if DropFileTarget1.Files.Count > 1 then
  begin
    lbDropMsg.Caption := 'Currently, only one file at a time.'#13#10'Please drop only one file.';
  end
  else
  begin
    var ext := LowerCase(ExtractFileExt(DropFileTarget1.Files[0]));
    if (ext = '.apk') or (ext = '.xapk') then
    begin
      frmInstaller.FApkFile := DropFileTarget1.Files[0];
      frmInstaller.Show;
      frmInstaller.FApkInfo.DisplayName := '';
      frmInstaller.FApkInfo.DisplayVersion := '';
      frmInstaller.FApkInfo.PackageName := '';
      frmInstaller.FApkInfo.Icon := '';

      frmInstaller.FApkPermissions.Clear;
      if ext = '.xapk' then
        frmInstaller.GetXAPKInfo
      else
        frmInstaller.GetAPKInfoWithAndroidAssetPackagingTool;
    end
    else
      lbDropMsg.Caption := 'Only .apk and .xapk file type accepted!';
  end;

  // If we do not reject a move, the source will assume that it is safe to
  // delete the source data. (rare cases)
  if (Effect = DROPEFFECT_MOVE) then
    Effect := DROPEFFECT_NONE;
end;

procedure TfrmWinDroid.Exit1Click(Sender: TObject);
begin
  Close;
end;

procedure TfrmWinDroid.Exit2Click(Sender: TObject);
begin
  Close;
end;

procedure TfrmWinDroid.ExploreAPK1Click(Sender: TObject);
begin
  frmApkViewerWnd.Show;
end;

procedure TfrmWinDroid.Files1Click(Sender: TObject);
begin
  APKLaunch('com.android.documentsui');
end;

procedure TfrmWinDroid.FormCreate(Sender: TObject);
begin
//  SetWindowLong(Handle, GWL_EXSTYLE, GetWindowLong(Handle, GWL_EXSTYLE) and not WS_EX_APPWINDOW);
//  AnimateWindow(Handle, 250, AW_CENTER);
//  Lang1.Lang := 'es';
  ColorizationManager.ColorizationType :=  TUWPColorizationType.ctLight;

  AppsClasses := TStringList.Create;
  AppsClassesSearchFilter := TStringList.Create;
//  AppsClasses.Sorted := True;

  AppList := TStringList.Create;
  AppListSearchFilter := TStringList.Create;


  btnListAppsClick(Sender); // this gets WSA Settings app AppUserModelID

//  GetWSAInstallationPath(lbWSAMUI.Caption); // this makes sure it is correct and updates WSA record info
//  lbWSAVersion.Caption := 'Version: ' + WSA.Version;
//  lbWSAMinWinVer.Caption := 'Minimum Windows Build: ' + WSA.MinWinVersion;
//  lbWSAPublisher.Caption := 'Publisher: ' + WSA.PublisherDisplayName;

//  FHookWndHandle := AllocateHWnd(WndMethod);

  ControlListFiltered := False;

  // detect window change foreground
  Hook := SetWinEventHook(EVENT_MIN, EVENT_MAX, 0, @WinEventProc, 0, 0, WINEVENT_OUTOFCONTEXT or WINEVENT_SKIPOWNPROCESS);
  if Hook = 0 then
    raise Exception.Create('Couldn''t create event hook!');
//  RunHook(Handle);
  if not StartHook then
    raise Exception.Create('Couldn''t set global hook to intercept F11');

//  CreateBlurBackground;

  ADB := TADB.Create;
  ADB.Path := leADBPath.Text;
  if not FileExists(ADB.Path) then
    gbADBinfo.Caption := 'ADB not found!';

  LoadINI;

  FPinner := TTaskbarPinner.Create;
  FPinnedLnkList := TStringList.Create;
  FPinMonitor := TRegMon.Create(Self);
  FPinMonitor.MonitoredKey := 'Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband';
  FPinMonitor.WatchSubKeys := False;
  FPinMonitor.OnChange := MonitorPinRegistry;
  FPinMonitor.Activate;

  FPinner.Items;

  WSAM := TWSA.Create;


end;

procedure TfrmWinDroid.FormDestroy(Sender: TObject);
begin
  WSAM.Free;

  FPinMonitor.Deactivate;
  FPinMonitor.Free;
  FPinnedLnkList.Free;
  FPinner.Free;

  ADB.Free;
//  DestroyBlurBackground;
  StopHook;
//  KillHook;
  UnhookWinEvent(Hook);

//  DeallocateHWnd(FHookWndHandle);

  AppList.Free;
  AppListSearchFilter.Free;
  AppsClasses.Free;
  AppsClassesSearchFilter.Free;
end;

procedure TfrmWinDroid.FormPaint(Sender: TObject);
begin
//  UpdateBlurBackground;
end;

procedure TfrmWinDroid.FormShow(Sender: TObject);
begin
  ShowWindow(Application.Handle, SW_HIDE);
end;

procedure TfrmWinDroid.Gallery1Click(Sender: TObject);
begin
  APKLaunch('com.android.gallery3d');
end;

procedure TfrmWinDroid.GetApkInfo(var Apk: TAPKInfo; const PackageName: string);
var
  reg: TRegistry;
begin
  reg := TRegistry.Create;
  try
    reg.RootKey := HKEY_CURRENT_USER;
    if reg.OpenKeyReadOnly('Software\Microsoft\Windows\CurrentVersion\Uninstall\'+PackageName) then
    begin
      ApkInfo.AndroidPackageName := reg.ReadString('AndroidPackageName');
      ApkInfo.AndroidVersionCode := reg.ReadString('AndroidVersionCode');
      ApkInfo.DisplayIcon := reg.ReadString('DisplayIcon');
      ApkInfo.DisplayName := reg.ReadString('DisplayName');
      ApkInfo.DisplayVersion := reg.ReadString('DisplayVersion');
      ApkInfo.EstimatedSize := reg.ReadInteger('EstimatedSize');
      ApkInfo.InstallDate := reg.ReadString('InstallDate');
      ApkInfo.Publisher := reg.ReadString('Publisher');
      
      reg.CloseKey;
    end;

  finally
    reg.Free;
  end;
end;

procedure TfrmWinDroid.GetAPKInfo1Click(Sender: TObject);
begin
  if (ControlList1.ItemCount > 0) and (ControlListIndex >= 0) then
  begin
    if ControlListFiltered then
      GetApkInfo(ApkInfo, AppsClassesSearchFilter.Names[ControlListIndex])
    else
      GetApkInfo(ApkInfo, AppsClasses.Names[ControlListIndex]);
    with frmInstaller do
    begin
      lbAPKDisplayName.Caption := ApkInfo.DisplayName;
      lbPublisher.Caption := 'Publisher: ' + ApkInfo.Publisher;
      lbVersion.Caption := 'Version: ' + ApkInfo.DisplayVersion;  
      lbCapabilities.Caption := 'Details: ';
      apkInstallerMemo.Lines.Clear;
      apkInstallerMemo.Lines.Add('Install Date: ' + ApkInfo.InstallDate);
      apkInstallerMemo.Lines.Add('Estimated Size: ' + FormatFileSize(ApkInfo.EstimatedSize*1024));
      var logoPath := StringReplace(ApkInfo.DisplayIcon, '.ico', '.png', [rfReplaceAll]); 
      if FileExists(logoPath) then
        eApkImage.Picture.LoadFromFile(logoPath);
      btnReUnInstall.Caption := 'Uninstall';
    end;
    frmInstaller.Show;
  end;
end;

function TfrmWinDroid.GetCurrentWSAVersionFromStore: string;
var
  net: THTTPClient;
  vResp: IHTTPResponse;
  vResponse: TStringStream;
  vParams: TMultipartFormData;
begin
  TTask.Run(
    procedure
    begin
      net := nil;
      try
        net := THTTPClient.Create;
        vResponse := TStringStream.Create;
        vParams := TMultipartFormData.Create();
        try
          net.SetUserAgent('Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:92.0) Gecko/20100101 Firefox/92.0');
          net.ConnectionTimeout := 3000; //ms
          vParams.AddField('type','ProductId');
          vParams.AddField('url','9p3395vx91nr');
          vParams.AddField('ring','WIS');
          vParams.AddField('lang', 'en-US');
          vResp := net.Post('https://store.rg-adguard.net/api/GetFiles', vParams, vResponse);
          TThread.Synchronize(nil,
            procedure
            var
              sname: string;
            begin
              try
                if vResp.StatusCode = 200 then
                begin
                  vResponse.Position := 0;
                  var cad := TStringList.Create;
                  try
                    cad.Text := vResponse.DataString;
                    var I: Integer;
                    for I := 0 to cad.Count - 1 do
                    begin
                      if cad[I].Contains('.msixbundle') then
                      begin
                        //(?<=href=")[^"]* get url
                        //(?<=noreferrer">)[^<\/]* get name
                        //(?<=_)[0-9]+.[0-9]+.[0-9]+.[0-9]+[^_]* get version
                        sname := TRegEx.Match(cad[I], '(?<=noreferrer">)[^<\/]*').Value;
                        var fversion := TRegEx.Match(sname, '(?<=_)[0-9]+.[0-9]+.[0-9]+.[0-9]+[^_]*').Value;
                        ShowMessage('Version found: ' +fVersion);
                      end;
                    end;

                  finally
                    cad.Free;
                  end;
                end;

              finally
                vResp := nil;
              end;
            end
          );

        except

        end;
      finally
        vParams.Free;
        vResponse.Free;
        FreeAndNil(net);
      end;
    end
  );

end;

function TfrmWinDroid.GetMainTaskbarPosition: Integer;
const ABNONE = -1;
var
  AMonitor: HMonitor;
  MonInfo: MONITORINFO;
  TaskbarHandle: THandle;
  ABData: TAppBarData;
  Res: HRESULT;
  TaskbarRect: TRect;
begin
  Result := ABNONE;
  ABData.cbSize := SizeOf(TAppbarData);
  Res := SHAppBarMessage(ABM_GETTASKBARPOS, ABData);
  if BOOL(Res) then
  begin
    // return ABE_LEFT=0, ABE_TOP, ABE_RIGHT or ABE_BOTTOM values
    Result := ABData.uEdge;
  end
  else // this might fail if explorer process is hung or is not set as shell (rare)
  begin
    TaskbarHandle := Winapi.Windows.FindWindow('Shell_TrayWnd', nil);
    if TaskbarHandle <> 0 then
    begin
      AMonitor := Winapi.MultiMon.MonitorFromWindow(TaskbarHandle, MONITOR_DEFAULTTOPRIMARY);
      MonInfo.cbSize := SizeOf(MONITORINFO);
      GetMonitorInfo(AMonitor, @MonInfo);
      if (MonInfo.rcMonitor.Left = TaskbarRect.Left) and (MonInfo.rcMonitor.Top = TaskbarRect.Top)
      and (MonInfo.rcMonitor.Width = TaskbarRect.Width)
      then
        Result := ABE_TOP
      else if (MonInfo.rcMonitor.Left + MonInfo.rcMonitor.Width = TaskbarRect.Right)
      and (MonInfo.rcMonitor.Width <> TaskbarRect.Width)
      then
        Result := ABE_RIGHT
      else if (MonInfo.rcMonitor.Left = TaskbarRect.Left) and (MonInfo.rcMonitor.Top + MonInfo.rcMonitor.Height = TaskbarRect.Bottom)
      and (MonInfo.rcMonitor.Width = TaskbarRect.Width)
      then
        Result := ABE_BOTTOM
      else
        Result := ABE_LEFT;
    end;
    // no explorer with taskbar running here, maybe
  end;

end;

{ TODO : If for some weird reason there is more than one WSA installed (maybe a variant), we must make sure it picks the correct on :-/ }
function TfrmWinDroid.GetWSAInstallationPath(amui: string): string;
var
  reg: TRegistry;
  list: TStringList;
  I, J, K: Integer;
  xmlstr: string;
  xml: IXMLDOMDocument2;
  node: IXMLDOMNode;
  nodes_row, nodes_se: IXMLDOMNodeList;
  name, vers, arqt, appid: string;
  appUserModelID: string;
  installPath: string;
begin
  Result := '';
  reg := TRegistry.Create;
  list := TStringList.Create;
  try
    reg.RootKey := HKEY_CURRENT_USER;
    reg.OpenKeyReadOnly('Software\Classes\ActivatableClasses\Package');
    reg.GetKeyNames(list);
    for I := 0 to list.Count - 1 do
    begin
      installPath := GetEnvironmentVariable('PROGRAMW6432')+'\WindowsApps\'+list[I];
      if list[I].Contains('MicrosoftCorporationII.WindowsSubsystemForAndroid')
      and FileExists(installPath+'\AppxManifest.xml') then
      begin
        Result := installPath;
        xmlstr := TFile.ReadAllText(installPath+'\AppxManifest.xml');
        xml := CreateOleObject('Microsoft.XMLDOM') as IXMLDOMDocument2;
        xml.async := False;

        xml.loadXML(xmlstr);
        if xml.parseError.errorCode <> 0 then
          raise Exception.Create('XML Load Error: ' + xml.parseError.reason);

        nodes_row := xml.selectNodes('/Package');

        for J := 0 to nodes_row.length - 1 do
        begin
          node := nodes_row.item[J];
          name := node.selectSingleNode('Identity').attributes.getNamedItem('Name').text;
          vers := node.selectSingleNode('Identity').attributes.getNamedItem('Version').text;
          try
            arqt := node.selectSingleNode('Identity').attributes.getNamedItem('ProcessorArchitecture').text;
          except
            arqt := 'Unknown'; //applies for extension for old edge, I guess we don't need it.
          end;

          try
            WSA.PublisherDisplayName := node.selectSingleNode('Properties').selectSingleNode('PublisherDisplayName').text;
            WSA.LogoPath := node.selectSingleNode('Properties').selectSingleNode('Logo').text;
            WSA.MinWinVersion := node.selectSingleNode('Dependencies').selectSingleNode('TargetDeviceFamily').attributes.getNamedItem('MinVersion').text;
          except

          end;

          nodes_se := node.selectNodes('Applications');
          for K := 0 to nodes_se.length - 1 do
          begin
            node := nodes_se.item[K];
            appid := node.selectSingleNode('Application').attributes.getNamedItem('Id').text;
            // let's forge the Settings app AMUI listed which we passed to make sure it belong to our app
            appUserModelID := name + Copy(list[I], StrLen(PChar(name + '_' + vers + '_' + arqt + '_'))+1,
              StrLen(PChar(name + '_' + vers + '_' + arqt + '_'))) + '!Settings' + appid;

            if appUserModelID <> amui then
              Result := '';
          end;
        end;
      end;
      // let's just use the first occurrence
      if Result <> '' then
      begin
        // we found it, let's update our WSA info
        WSA.InstallPath := installPath;
        WSA.Version := vers;
        WSA.AppUserModelID := appUserModelID;
        WSA.DisplayName := name;
        WSA.WsaSettings := '';
        if FileExists(installPath + '\WsaSettings.exe') then
          WSA.WsaSettings := '\WsaSettings.exe';
        WSA.WsaClient := '';
        if FileExists(installPath + '\WsaClient\WsaClient.exe') then
        begin
          WSA.WsaClient := '\WsaClient\WsaClient.exe';
          WsaClientPath := Trim(installPath + '\WsaClient\WsaClient.exe');
        end;
        Break;
      end;
    end;
  finally
    list.Free;
    reg.Free;
  end;
end;

// Verify that lnk located at
function TfrmWinDroid.IsWsaClientLnkTarget(value: string): Boolean;
var
  lnk: IShellLink;
  storage: IPersistFile;
  widePath: WideString;
  buf: array[0..4096] of Char;
  fileData: TWin32FindData;
  realPath: LPCWSTR;
begin
  Result := False;
  OleCheck(CoCreateInstance(CLSID_ShellLink, nil, CLSCTX_INPROC_SERVER, IShellLink, lnk));
  OleCheck(lnk.QueryInterface(IPersistFile, storage));

  if Succeeded(SHGetKnownFolderPath(FOLDERID_AppsFolder, KF_FLAG_DEFAULT, 0, realPath)) then
  begin
//    widePath := 'shell:::{4234d49b-0245-4df3-b780-3893943456e1}\'+value;
    widePath := {utf16toutf8}realPath + '\' + value;
    if Succeeded(storage.Load(@widePath[1], STGM_READ)) then
      if Succeeded(lnk.Resolve(GetActiveWindow, SLR_NOUPDATE)) then
        if Succeeded( lnk.GetPath(buf, SizeOf(buf), fileData, SLGP_UNCPRIORITY) )
        then
        begin
          Result := LowerCase(buf).Contains('\wsaclient.exe');
        end;
    CoTaskMemFree(realPath);
  end;
  storage := nil;
  lnk := nil;
end;

function TfrmWinDroid.IsWsaClientRunning: Boolean;
const
  WSA_CLIENT_MUTEX = '{42CEB0DF-325A-4FBE-BBB6-C259A6C3F0BB}';
var
  Mutex: NativeUInt;
begin
  Result := False;
  Mutex := OpenMutex(MUTEX_ALL_ACCESS, False, WSA_CLIENT_MUTEX);
  if Mutex <> 0 then
  begin
    Result := True;
  end;

  CloseHandle(Mutex);

end;

procedure TfrmWinDroid.LaunchWSASettings1Click(Sender: TObject);
begin
  ShellExecute(0, 'OPEN', 'explorer.exe', PChar('shell:::{4234d49b-0245-4df3-b780-3893943456e1}\'+WSA.AppUserModelID), nil, SW_SHOWNORMAL);
end;

procedure TfrmWinDroid.LoadINI;
var
  ini: TIniFile;
begin
  ini := TIniFile.Create(ExtractFilePath(ParamStr(0))+INIFILE);
  try
    ADB.Path := ini.ReadString('ADB', 'Path', '');
    if FileExists(ADB.Path) then
      leADBPath.Text := ADB.Path;
    leDownloadsPath.Text := ini.ReadString('Settings', 'DownloadsPath', '');
  finally
    ini.Free;
  end;
end;

procedure TfrmWinDroid.ManageAPK1Click(Sender: TObject);
begin
  if (ControlListIndex >= 0) and (ControlList1.ItemCount > 0)
  then
  begin
    if ControlListFiltered then
      APKLaunch(AppsClassesSearchFilter.Names[ControlListIndex], '/modify ')
    else
    begin
      APKLaunch(AppsClasses.Names[ControlListIndex], '/modify ');
    end;

  end;
end;

procedure TfrmWinDroid.MonitorPinRegistry(Sender: TObject);
begin
  FPinner.Items;
end;

procedure TfrmWinDroid.NoBorder(var Msg: TWMNCActivate);
begin
  Msg.Active := False;
  inherited;
end;

procedure TfrmWinDroid.OpenWSAInstallationFolder1Click(Sender: TObject);
begin
  ShellExecute(0, 'OPEN', 'explorer.exe', PChar(GetWSAInstallationPath(WSA.AppUserModelID)), nil, SW_SHOWNORMAL);
end;

procedure TfrmWinDroid.PinMonitor(var Msg: TMessage);
begin

end;

procedure TfrmWinDroid.PintoTaskbar1Click(Sender: TObject);
begin
  if (ControlListIndex >= 0) and (ControlList1.ItemCount > 0)
  then
  begin
    if ControlListFiltered then
      ShowMessage(AppsClasses.Names[ControlListIndex])
    else
    begin
      ShowMessage(AppsClasses.ValueFromIndex[ControlListIndex])
    end;

  end;
end;

procedure TfrmWinDroid.pnlWSAStateMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  ReleaseCapture;
  Perform(WM_SYSCOMMAND, $F012, 0);
end;

function TfrmWinDroid.ReplaceAmazonAppstore: Boolean;
begin
//https://amazonadsi-a.akamaihd.net/public/ix/stable/default/us/Amazon_App.apk
end;

procedure TfrmWinDroid.RunAPK1Click(Sender: TObject);
begin
  ControlList1DblClick(Sender);
end;

procedure TfrmWinDroid.SaveINI;
var
  ini: TIniFile;
begin
  ini := TIniFile.Create(ExtractFilePath(ParamStr(0)) + INIFILE);
  try
    if DirectoryExists(leDownloadsPath.Text) then
      ini.WriteString('Settings', 'DownloadsPath', leDownloadsPath.Text);
    if FileExists(ADB.Path) then
      ini.WriteString('ADB', 'Path', ADB.Path);
  finally
    ini.Free;
  end;
end;

procedure TfrmWinDroid.SearchBox1Change(Sender: TObject);
var
  I: Integer;
  filter, text: string;
begin
  if Trim(SearchBox1.Text) <> '' then
  begin
    ControlListFiltered := True;
    AppsClassesSearchFilter.BeginUpdate;
    AppsClassesSearchFilter.Clear;
    AppListSearchFilter.BeginUpdate;
    AppListSearchFilter.Clear;
    for I := 0 to AppList.Count - 1 do
    begin
      filter := LowerCase(Trim(SearchBox1.Text));
      text := LowerCase(Trim(AppList.Names[I]));
      if text.Contains(filter) then
      begin
        AppListSearchFilter.AddPair(AppList.Names[I], AppList.ValueFromIndex[I]);
        AppsClassesSearchFilter.AddPair(AppsClasses.Names[I], AppsClasses.Names[I]);
      end;
    end;
    AppListSearchFilter.EndUpdate;
    AppsClassesSearchFilter.EndUpdate;
    ControlList1.ItemCount := AppListSearchFilter.Count;
    ControlList1.Refresh;
  end
  else
  begin
    ControlListFiltered := False;
    ControlList1.ItemCount := AppList.Count;
  end;
end;

procedure TfrmWinDroid.SearchInstallAPKs1Click(Sender: TObject);
begin
  frmWeb.WebBrowser1.Navigate('about:blank');
  frmWeb.Show;
  frmWeb.WebBrowser1.Navigate('https://apkpure.com');
  frmWeb.PageControl1.ActivePage := frmWeb.TabSheet1;
//  frmWeb.EmbeddedWB1.Navigate('https://apkpure.com');
end;

procedure TfrmWinDroid.SearchUpdates1Click(Sender: TObject);
var
  LPackageName: string;
begin
  if (ControlList1.ItemCount > 0) and (ControlListIndex >= 0) then
  begin
    if ControlListFiltered then
      LPackageName := AppsClassesSearchFilter.Names[ControlListIndex]
    else
      LPackageName := AppsClasses.Names[ControlListIndex];
    frmWeb.WebBrowser1.Navigate('about:blank');
    frmWeb.Show;
    GetApkInfo(ApkInfo, LPackageName);
    frmWeb.Caption := Format('Search update for: %s - Installed version: %s', [ApkInfo.DisplayName, ApkInfo.DisplayVersion]);
    frmWeb.WebBrowser1.Navigate('https://apkpure.com/en/'+LPackageName);
    frmWeb.PageControl1.ActivePage := frmWeb.TabSheet1;
  end;

end;

procedure TfrmWinDroid.SpeedButton1Click(Sender: TObject);
begin
  crdContainer.ActiveCard := crdApps;
end;

procedure TfrmWinDroid.SpeedButton2Click(Sender: TObject);
begin
  crdContainer.ActiveCard := crdInstaller;
end;

procedure TfrmWinDroid.SpeedButton3Click(Sender: TObject);
begin
  crdContainer.ActiveCard := crdMisc;
end;

procedure TfrmWinDroid.SpeedButton4Click(Sender: TObject);
begin
  crdContainer.ActiveCard := crdSettings;
end;

procedure TfrmWinDroid.TrayIcon1Click(Sender: TObject);
begin
  Visible := not Visible;
end;

procedure TfrmWinDroid.UninstallAPK1Click(Sender: TObject);
var
  LPackageName: string;
begin
  if (ControlListIndex >= 0) and (ControlList1.ItemCount > 0) then
  begin
    if ControlListFiltered then
      LPackageName := AppsClassesSearchFilter.Names[ControlListIndex]
    else
    begin
      LPackageName := AppsClasses.Names[ControlListIndex];
    end;
    if MessageDlg('This will uninstall ' + LPackageName +#13#10'This procedure is irreversible. Are you sure to continue?', mtWarning, mbYesNo, 0) = mrYes then
    begin
      APKLaunch(LPackageName, '/uninstall ');
      btnListAppsClick(Sender);
    end;
  end;
end;

procedure TfrmWinDroid.UpdateBlurBackground;
begin
  try
    if IsWindow(FBlurBackground) and IsWindowVisible(FBlurBackground) then
    begin
//      SetWindowPos(FBlurBackground, 0, 0, 0, 0, 0, SWP_NOZORDER or SWP_SHOWWINDOW or SWP_NOSIZE or SWP_NOMOVE or SWP_NOACTIVATE or SWP_NOOWNERZORDER or SWP_NOSENDCHANGING or SWP_ASYNCWINDOWPOS);
//      EnableBlurBehindWindow(FBlurBackground);
    end;

  finally

  end;
end;

{ TDownloader }

procedure TDownloader.AbortDownload;
begin
  if FDownloading then
    FAbortNow := True;
end;


constructor TDownloader.Create;
begin
  inherited;
  FDownloading := False;
  FAbortNow := False;
  FAborted := False;

  FClient := THTTPClient.Create;
  FClient.OnReceiveData := DoReceiveDataEvent;

  FValue := 0;

end;

destructor TDownloader.Destroy;
begin
  FClient.Free;
  FDownloaderStream.Free;

  inherited;
end;

procedure TDownloader.DoEndDownload(const AsyncResult: IAsyncResult);
var
  LResponse: IHTTPResponse;
begin
  try
    LResponse := THTTPClient.EndAsyncHTTP(AsyncResult);
    TThread.Synchronize(nil,
      procedure
      begin
        if LResponse.StatusCode = 200 then
        begin
          if FAborted then
          begin
            FAborted := False;
            FOnDownloaded(Self, 209) // Let's consider 209 as aborted successfully
          end
          else
            FOnDownloaded(Self, 200);
        end
        else
        begin
          // some other error has occurred
          FOnDownloaded(Self, LResponse.StatusCode);
        end;
        FDownloading := False;
      end
    );
  finally
    LResponse := nil;
    FreeAndNil(FDownloaderStream);
    // Show success or something
  end;
end;

procedure TDownloader.DoReceiveDataEvent(const Sender: TObject; AContentLength,
  AReadCount: Int64; var Abort: Boolean);
var
  LTime: Cardinal;
  LSpeed: Integer;
begin
  if FAbortNow then
  begin
    Abort := True;
    FAbortNow := False;
    FAborted := True;
  end;
  LTime := TThread.GetTickCount - FGlobalStart;
  LSpeed := (AReadCount * 1000) div LTime;
  TThread.Queue(nil,
    procedure
    begin
      FValue := Round(100 / FSize * AReadCount);
//      FStatus := Format('%d KB/s', [LSpeed div 1024]);
    end
  );
end;

procedure TDownloader.DoStartDownload;
var
  LResponse: IHTTPResponse;
begin
  if FDownloading then
  begin
    raise Exception.Create('Already downloading, stop first!');
    Exit;
  end;
  try
    LResponse := FClient.Head(FURL);
    FSize := LResponse.ContentLength;
    LResponse := nil;
    FValue := 0;
    FDownloaderStream := TFileStream.Create(FSavePath, fmCreate);
    FDownloaderStream.Position := 0;

    FGlobalStart := TThread.GetTickCount;

    FDownloading := True;
    FClient.CustomHeaders['Connection'] := 'close'; // to close connection afterwards
    FAsyncResult := FClient.BeginGet(DoEndDownload, FURL, FDownloaderStream);
  finally
    FAsyncResult := nil;
  end;
end;



procedure TDownloader.SetValue(const Value: byte);
begin
  if Value <> FValue then
    if Value <= 100 then
    begin
      FValue := Value;
      //
    end;
end;

initialization
  CoInitialize(nil);
  WndProcHook := 0;
  WndProcHook := SetWindowsHookEx(WH_CALLWNDPROCRET, @WndProc, 0, GetCurrentThreadId);
  if WndProcHook = 0 then
    raise Exception.Create('Couldn''t create secondary Window Proc');
finalization
  UnhookWindowsHookEx(WndProcHook);
  CoUninitialize;


end.
