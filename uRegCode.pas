unit uRegCode;

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes, ActiveX, ComObj, System.Variants,
  System.StrUtils, Registry, Winapi.IpTypes, Winapi.IpHlpApi,
  IdHashMessageDigest, IdGlobal;

function GetRegCode(): string;

function GetGUID(): string;

function GetMacAddress(): string;

    { Public declarations }
function strToMD5(S: string): string;

implementation

const
  NCF_VIRTUAL = $01; //  说明组件是个虚拟适配器
  NCF_SOFTWARE_ENUMERATED = $02; //  说明组件是一个软件模拟的适配器
  NCF_PHYSICAL = $04; //  说明组件是一个物理适配器
  NCF_HIDDEN = $08;  //说明组件不显示用户接口
  NCF_NO_SERVICE = $10; //  说明组件没有相关的服务(设备驱动程序)
  NCF_NOT_USER_REMOVABLE = $20;  // 说明不能被用户删除(例如，通过控制面板或设备管理器)
  NCF_MULTIPORT_INSTANCED_ADAPTER = $40; //  说明组件有多个端口，每个端 口作为单独的设备安装。
                                          //  每个 端口有自己的hw_id(组件ID) 并可被单独安装，
                                          //  这只适合于 EISA适配器
  NCF_HAS_UI = $80; // 说明组件支持用户接口(例如，Advanced Page或Customer  Properties Sheet)
  NCF_FILTER = $400; //  说明组件是一个过滤器

function IsPhysicalAdapter(sAdapterGUID: string; bOnlyPCI: Boolean = False): Boolean;
const
  NET_CARD_KEY_PATH = 'SYSTEM\CurrentControlSet\Control\Class\{4d36e972-e325-11ce-bfc1-08002be10318}';
var
  Reg: TRegistry;
  sList: TStrings;
  vCharacteristics: DWORD;
  I: Integer;
begin
  Result := False;
  sList := TStringList.Create;
  Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    if not Reg.OpenKey(NET_CARD_KEY_PATH, False) then
      Exit;
    Reg.GetKeyNames(sList);
    Reg.CloseKey;
    if sList.Count > 0 then
      for I := 0 to Pred(sList.Count) do
        if Reg.OpenKey(NET_CARD_KEY_PATH + '\' + sList.Strings[I], False) then
        begin
          try
            if (Trim(UpperCase(sAdapterGUID)) = Trim(UpperCase(Reg.ReadString('NetCfgInstanceId')))) then
            begin
              vCharacteristics := DWORD(Reg.ReadInteger('Characteristics'));
              Result := (NCF_PHYSICAL and vCharacteristics) = NCF_PHYSICAL;
              Break;
            end;
          finally
            Reg.CloseKey;
          end;
        end;
  finally
    Reg.Free;
    sList.Free;
  end;
end;

function GetMacAddress(): string;
var
  dwRet: DWORD;
  AI, Work: PIpAdapterInfo;
  sGUID, sTmp, sLastMAC, sFirstMAC: string;
  I: Integer;
  uSize: ULONG;
begin
  Result := '';
  sLastMAC := '';
  sFirstMAC := '';
  uSize := SizeOf(TIpAdapterInfo);
  GetMem(AI, uSize);
  dwRet := GetAdaptersInfo(AI, uSize);
  if (dwRet = ERROR_BUFFER_OVERFLOW) then
  begin
    FreeMem(AI);
    GetMem(AI, uSize);
    dwRet := GetAdaptersInfo(AI, uSize);
  end;
  try
    if (dwRet <> ERROR_SUCCESS) then
      Exit;
    Work := AI;
    while Work <> nil do
    begin
      try
        sGUID := string(AnsiString(Work.AdapterName));
        sTmp := string(AnsiString(Work.Description));
        // 名称描述出现VMWare，直接忽略
        if Pos('VMWare', sTmp) > 0 then
          Continue;

        // 名称描述出现adapter，直接忽略
        //if Pos(' ADAPTER',UpperCase(sTmp)) > 0 then
        //  Continue;

        // 配置的ID地址不正常，忽略
        if Work.AddressLength = 0 then
          Continue;

        // 将网卡MAC地址转成字符串
        sLastMAC := '';
        for I := 0 to Work.AddressLength - 1 do
        begin
          sLastMAC := sLastMAC + Format('%.2x', [Work.Address[I]]);
        end;

        if sFirstMAC = '' then
          sFirstMAC := sLastMAC;

        // 不是物理网卡，忽略
        if not IsPhysicalAdapter(sGUID) then
          Continue;

        Result := sLastMAC;

        //找到第一个物理网卡后退出
        Break;
      finally
        Work := Work.Next;
      end;
    end;
    // 找不到物理网卡MAC，返回第一个即可
    if Result = '' then
      Result := sFirstMAC;
  finally
    FreeMem(AI);
  end;
end;

function GetRegCode(): string;
var
  sMac_Addr:string;
begin
  sMac_Addr := GetMacAddress;
  //Result := GetGUID + GetMacAddress;
  Result := strToMD5(sMac_Addr);
end;

function GetGUID(): string;
var
  LTep: TGUID;
  sGUID: string;
begin
  CreateGUID(LTep);
  sGUID := GUIDToString(LTep);
  sGUID := StringReplace(sGUID, '-', '', [rfReplaceAll]);
  sGUID := Copy(sGUID, 2, Length(sGUID) - 2);
  Result := sGUID;
end;

function strToMD5(S: string): string;
var
  Md5Encode: TIdHashMessageDigest5;
begin
  Md5Encode := TIdHashMessageDigest5.Create;
  result := Md5Encode.HashStringAsHex(S);
  Md5Encode.Free;
end;

end.

