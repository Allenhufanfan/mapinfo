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
  NCF_VIRTUAL = $01; //  ˵������Ǹ�����������
  NCF_SOFTWARE_ENUMERATED = $02; //  ˵�������һ�����ģ���������
  NCF_PHYSICAL = $04; //  ˵�������һ������������
  NCF_HIDDEN = $08;  //˵���������ʾ�û��ӿ�
  NCF_NO_SERVICE = $10; //  ˵�����û����صķ���(�豸��������)
  NCF_NOT_USER_REMOVABLE = $20;  // ˵�����ܱ��û�ɾ��(���磬ͨ�����������豸������)
  NCF_MULTIPORT_INSTANCED_ADAPTER = $40; //  ˵������ж���˿ڣ�ÿ���� ����Ϊ�������豸��װ��
                                          //  ÿ�� �˿����Լ���hw_id(���ID) ���ɱ�������װ��
                                          //  ��ֻ�ʺ��� EISA������
  NCF_HAS_UI = $80; // ˵�����֧���û��ӿ�(���磬Advanced Page��Customer  Properties Sheet)
  NCF_FILTER = $400; //  ˵�������һ��������

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
        // ������������VMWare��ֱ�Ӻ���
        if Pos('VMWare', sTmp) > 0 then
          Continue;

        // ������������adapter��ֱ�Ӻ���
        //if Pos(' ADAPTER',UpperCase(sTmp)) > 0 then
        //  Continue;

        // ���õ�ID��ַ������������
        if Work.AddressLength = 0 then
          Continue;

        // ������MAC��ַת���ַ���
        sLastMAC := '';
        for I := 0 to Work.AddressLength - 1 do
        begin
          sLastMAC := sLastMAC + Format('%.2x', [Work.Address[I]]);
        end;

        if sFirstMAC = '' then
          sFirstMAC := sLastMAC;

        // ������������������
        if not IsPhysicalAdapter(sGUID) then
          Continue;

        Result := sLastMAC;

        //�ҵ���һ�������������˳�
        Break;
      finally
        Work := Work.Next;
      end;
    end;
    // �Ҳ�����������MAC�����ص�һ������
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

