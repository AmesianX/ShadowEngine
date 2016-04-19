unit uEngine2DManager;

interface

uses
  System.Types, System.UITypes, FMX.Graphics, System.SysUtils, System.SyncObjs,
  System.RegularExpressions, FMX.Objects, System.Classes,
  uEngine2DClasses, uEngine2DObject, uEngineFormatter, uEngine2DAnimation,
  uEngine2DText, uEngine2DShape, uEngine2DResources, uEngine2DAnimationList,
  uFormatterList, uEngine2DSprite, uFastFields, uEngine2DThread,
  uSpriteList, uEngine2DStatus, uClasses;

type
  TEngine2DManager = class
  private
    FStatus: TEngine2DStatus;
    FImage: TImage;
    FResize: TProcedure;
    FCritical: TCriticalSection;
    FObjects: TObjectsList; // ������ �������� ��� ���������
    FResources: TEngine2DResources;//tResourceArray; // ������ ��������
    FFormatters: TFormatterList; // ������ ����������� ��������
    FAnimationList: TEngine2DAnimationList; // ������ ��������
    FObjectOrder: PIntArray;
    FEngineThread: TEngineThread;
    FFastFields: TFastFields;
    FAddedObjects: Integer; // Quantity of Added sprites ������� ������� �������� ��������� �����. ��� ����� ��������
    function GetEngineHeight: Integer;
    function GetEngineWidth: Integer;
    function GetEngineSpeed: Single;
    function GetItem(AIndex: Integer): tEngine2DObject;
    function GetItemS(AName: string): tEngine2DObject;
    procedure DeleteHandler(ASender: TObject);
    procedure BringToBackHandler(ASender: TObject);
    procedure SendToFrontHandler(ASender: TObject);
    procedure DelObject(const AObject: tEngine2DObject); // ������� ������ �� ���������
    procedure AddObject(const AObject: tEngine2DObject; const AName: String = ''); // ��������� ������ �� ���������
    procedure SpriteToBack(const n: integer); // ����������� � ������� ��������� ������
    procedure SpriteToFront(const n: integer);// ����������� � ������� ��������� ������
  public
    constructor Create(
      const AStatus: TEngine2DStatus;
      const AImage: TImage;
      const ACritical: TCriticalSection;
      const AResourcesList: TEngine2DResources;
      const AObjectsList: TObjectsList;
      const AObjectOrder: PIntArray;
      const AAnimationsList: TEngine2DAnimationList;
      const AFormattersList: TFormatterList;
      const AFastFields: TFastFields;
      const AEngineThread: TEngineThread;
      const AResize: TProcedure
      );
    destructor Destroy; override;
    function Formatter(const ASubject: tEngine2DObject; const AText: String; const AIndex: Integer = -1): TEngineFormatter; overload;
    function Formatter(const ASubject: tEngine2DObject; const AName: String; const AParam: array of const; const AIndex: Integer = -1): TEngineFormatter; overload;

    function Add(const ASprite: TSprite; const AName: string = ''): TSprite; overload;
    function Add(const AShape: TEngine2DShape; const AName: string = ''): TEngine2DShape; overload;
    function Add(const AText: TEngine2DText; const AName: string = ''): TEngine2DText; overload;
    function Add(const AAnimation: TAnimation): TAnimation; overload;

    function Sprite(const AName: string = ''): TSprite;
    function Text(const AName: string = ''): TEngine2DText;
    function FillEllipse(const AName: string = ''): TFillEllipse;
    function FillRect(const AName: string = ''): TFillRect;

    procedure AniClearAndRecover(const ASubject: tEngine2DObject);
    procedure AniClear(const ASubject: tEngine2DObject);

    property Items[AIndex: Integer]: tEngine2DObject read GetItem; default;
    property Items[AName: string]: tEngine2DObject read GetItemS; default;
    function ResourceIndex(const AName: string): Integer;
    function AutoSprite(const AResource: string; const AName: string; const AParam: array of const; const AGroup: string = ''; const AJustify: TObjectJustify = Center): TSprite; overload;
    property EngineWidth: Integer read GetEngineWidth;
    property EngineHeight: Integer read GetEngineHeight;
    property EngineSpeed: Single read GetEngineSpeed;

    // ������ ��� ���������� ������
    procedure ShowGroup(const AGroup: String);
    procedure HideGroup(const AGroup: String);
    procedure SendToFrontGroup(const AGroup: String); // ������ ������ �� �������� ����
    procedure BringToBackGroup(const AGroup: String); // ���������� ������ �� ������ ����

    procedure Resize;
    procedure RemoveObject(AObject: tEngine2DObject);
  end;

implementation

uses
  uEngine2D, uEngine2DStandardAnimations;

{ TEngine2DObjectCreator }

function TEngine2DManager.Add(const ASprite: TSprite;
  const AName: string): TSprite;
begin
  Result := ASprite;
  ASprite.Resources := fResources;
  AddObject(Result, AName);
end;

function TEngine2DManager.Add(const AShape: TEngine2DShape;
  const AName: string): TEngine2DShape;
begin
  Result := AShape;
  AddObject(Result, AName);
end;

function TEngine2DManager.Add(const AText: TEngine2DText;
  const AName: string): TEngine2DText;
begin
  Result := AText;
  AddObject(Result, AName);
end;

procedure TEngine2DManager.AniClear(const ASubject: tEngine2DObject);
begin
  fAnimationList.ClearForSubject(ASubject);
end;

procedure TEngine2DManager.AniClearAndRecover(
  const ASubject: tEngine2DObject);
begin
  fAnimationList.ClearAndRecoverForSubject(ASubject);
end;

function TEngine2DManager.Add(
  const AAnimation: TAnimation): TAnimation;
begin
  AAnimation.OnDeleteSubject := DeleteHandler;
  AAnimation.Status := FStatus;

  FAnimationList.Add(AAnimation);
  Result := AAnimation;
end;

procedure TEngine2DManager.AddObject(const AObject: tEngine2DObject;
  const AName: String);
var
  l: integer;
  vName: string;
begin
  Inc(FAddedObjects);
  if AName = '' then
    vName := 'genname'+IntToStr(FAddedObjects)+'x'+IntToStr(Random(65536))
  else
    vName := AName;

  if FObjects.IsHere(AObject) then
    raise Exception.Create('You are trying to add Object to Engine that already Exist')
  else
  begin
    FCritical.Enter;
    l := FObjects.Count;
    FObjects.Add(vName, AObject);
    setLength(FObjectOrder^, l + 1);
    FObjects[l].Image := FImage;
    AObject.OnBringToBack := BringToBackHandler;
    AObject.OnSendToFront := SendToFrontHandler;
    FObjectOrder^[l] := l;
    FCritical.Leave;
  end;
end;

//procedure TEngine2DManager.AddObject(const AObject: tEngine2DObject;
//  const AName: String);
//var
//  l: integer;
//  vName: string;
//begin
//  // It's bad analog of generating GUID
//  Inc(FAddedObjects);
//  if AName = '' then
//    vName := 'genname'+IntToStr(FAddedObjects)+'x'+IntToStr(Random(65536))
//  else
//    vName := AName;
//
//  if FObjects.IsHere(AObject) then
//    raise Exception.Create('You are trying to add Object to Engine that already Exist')
//  else
//  begin
//    FCritical.Enter;
//    l := FObjects.Count;
//    FObjects.Add(vName, AObject);
//    setLength(FObjectOrder, l + 1);
//    FObjects[l].Image := FImage;
//    AObject.OnBringToBack := BringToBackHandler;
//    AObject.OnSendToFront := SendToFrontHandler;
//    FObjectOrder[l] := l;
//    FCritical.Leave;
//  end;
//end;

function TEngine2DManager.AutoSprite(const AResource, AName: string;
  const AParam: array of const; const AGroup: string;
  const AJustify: TObjectJustify): TSprite;
begin
  Result := Sprite(AName).Config(AResource, AGroup, AJustify);
  Formatter(Result, AName, []);
end;

procedure TEngine2DManager.BringToBackGroup(const AGroup: String);
var
  i, iObject, iG: Integer;
  vReg: TRegEx;
  vStrs: TArray<string>;
  vN: Integer;
begin
  vReg := TRegEx.Create(',');
  vStrs := vReg.Split(AGroup);
  vN := FObjects.Count - 1;
  for iG := 0 to Length(vStrs) - 1 do
  begin
    i := vN;
    iObject := vN;
    vStrs[iG] := Trim(vStrs[iG]);
    while iObject > 1 do
    begin
      if FObjects[FObjectOrder^[i]].Group = vStrs[iG] then
      begin
        FObjects[FObjectOrder^[i]].BringToBack;
        Inc(i);
      end;
      Dec(i);
      Dec(iObject);
    end;
  end;
end;

procedure TEngine2DManager.BringToBackHandler(ASender: TObject);
begin
 SpriteToBack(
    FObjects.IndexOfItem(TEngine2DObject(ASender), FromBeginning)
  );
end;

constructor TEngine2DManager.Create(
      const AStatus: TEngine2DStatus;
      const AImage: TImage;
      const ACritical: TCriticalSection;
      const AResourcesList: TEngine2DResources;
      const AObjectsList: TObjectsList;
      const AObjectOrder: PIntArray;
      const AAnimationsList: TEngine2DAnimationList;
      const AFormattersList: TFormatterList;
      const AFastFields: TFastFields;
      const AEngineThread: TEngineThread;
      const AResize: TProcedure);
begin
  FStatus := AStatus;
  FImage := AImage;
  FCritical := ACritical;
  FAddedObjects := 0;
  FObjects := AObjectsList;
  FResources := AResourcesList;
  FObjectOrder := AObjectOrder;
  FAnimationList := AAnimationsList;
  FFormatters := AFormattersList;
  FFastFields := AFastFields;
  FEngineThread := AEngineThread;
  FResize := AResize;
end;

procedure TEngine2DManager.DeleteHandler(ASender: TObject);
begin
  DelObject(TEngine2DObject(ASender));
end;

procedure TEngine2DManager.DelObject(const AObject: tEngine2DObject);
var
  i, vN, vNum, vPos: integer;
begin
  FCritical.Enter;
  vNum := FObjects.IndexOfItem(AObject, FromEnd);
  if vNum > -1 then
  begin
    vN := FObjects.Count - 1;
    FAnimationList.ClearForSubject(AObject);
    FFormatters.ClearForSubject(AObject);
    FFastFields.ClearForSubject(AObject);
    FObjects.Delete(vNum{AObject});

   // AObject.Free;

    vPos := vN + 1;
    // ������� ������� �������
    for i := vN downto 0 do
      if FObjectOrder^[i] = vNum then
      begin
        vPos := i;
        Break;
      end;

    // �� ���� ������� �������� ������� ���������
    vN := vN - 1;
    for i := vPos to vN do
      FObjectOrder^[i] := FObjectOrder^[i+1];

    // ��� ������� ��������, ������� ������ vNum ���� ��������� �� 1
    for i := 0 to vN do
      if FObjectOrder^[i] >= vNum then
        FObjectOrder^[i] := FObjectOrder^[i] - 1;

    // ��������� ����� �������
    SetLength(FObjectOrder^, vN + 1);
  end;
  FCritical.Leave;
//  FDebug := True;
end;

destructor TEngine2DManager.Destroy;
begin
  FStatus := nil;
  FImage := nil;
  FCritical := nil;
  FObjects :=  nil;
  FResources :=  nil;
  FObjectOrder := nil;
  FAnimationList := nil;
  FFormatters := nil;
  FFastFields := nil;
  FEngineThread := nil;
  FResize := nil;
  inherited;
end;

function TEngine2DManager.Formatter(const ASubject: tEngine2DObject;
  const AText: String; const AIndex: Integer): TEngineFormatter;
begin
  Result := TEngineFormatter.Create(ASubject, fObjects, FFastFields);
  Result.Text := AText;
  if AIndex = -1 then
    fFormatters.Add(Result)
  else
    fFormatters.Insert(AIndex, Result);
end;

function TEngine2DManager.FillEllipse(const AName: string): TFillEllipse;
begin
  Result := TFillEllipse.Create;
  AddObject(Result, AName);
end;

function TEngine2DManager.FillRect(const AName: string): TFillRect;
begin
  Result := TFillRect.Create;
  AddObject(Result, AName);
end;

function TEngine2DManager.Formatter(const ASubject: tEngine2DObject;
  const AName: String; const AParam: array of const; const AIndex: Integer): TEngineFormatter;
var
  vS: string;
begin
  vS := Format(fFormatters.StyleByName[AName], AParam);
  Result := Formatter(ASubject, vS, AIndex);
end;

function TEngine2DManager.GetEngineHeight: Integer;
begin
  Result := FStatus.Height; //TEngine2d(FEngine).Height;
end;

function TEngine2DManager.GetEngineSpeed: Single;
begin
  Result := FEngineThread.Speed;
end;

function TEngine2DManager.GetEngineWidth: Integer;
begin
  Result := FStatus.Width;//TEngine2d(FEngine).Width;
end;

function TEngine2DManager.GetItem(AIndex: Integer): tEngine2DObject;
begin
  Result := FObjects[AIndex];
end;

function TEngine2DManager.GetItemS(AName: string): tEngine2DObject;
begin
  Result := FObjects[AName];
end;

procedure TEngine2DManager.HideGroup(const AGroup: String);
var
  i, iG: Integer;
  vReg: TRegEx;
  vStrs: TArray<string>;
begin
  vReg := TRegEx.Create(',');
  vStrs := vReg.Split(AGroup);
  for iG := 0 to Length(vStrs) - 1 do
  begin
    vStrs[iG] := Trim(vStrs[iG]);
    for i := 0 to FObjects.Count - 1 do
      if FObjects[i].group = vStrs[iG] then
        FObjects[i].visible := False;
  end;
end;

procedure TEngine2DManager.RemoveObject(AObject: tEngine2DObject);
begin
  DelObject(AObject);
end;


procedure TEngine2DManager.Resize;
begin
  FResize;
end;

function TEngine2DManager.ResourceIndex(const AName: string): Integer;
begin
  Result := fResources.IndexOf(AName);
end;

procedure TEngine2DManager.SendToFrontGroup(const AGroup: String);
var
  i, iObject, iG: Integer;
  vReg: TRegEx;
  vStrs: TArray<string>;
  vN: Integer;
begin
  vReg := TRegEx.Create(',');
  vStrs := vReg.Split(AGroup);
  vN := FObjects.Count - 1;
  for iG := 0 to Length(vStrs) - 1 do
  begin
    i := 1;
    iObject := 1;
    vStrs[iG] := Trim(vStrs[iG]);
    while iObject < vN do
    begin
      if FObjects[FObjectOrder^[i]].Group = vStrs[iG] then
      begin
        FObjects[FObjectOrder^[i]].SendToFront;
        Dec(i);
      end;
      Inc(i);
      Inc(iObject);
    end;
  end;
end;

procedure TEngine2DManager.SendToFrontHandler(ASender: TObject);
begin
 SpriteToFront(
    FObjects.IndexOfItem(TEngine2DObject(ASender), FromBeginning)
  );
end;

{procedure TEngine2DManager.SendToFrontHandler(ASender: TObject);
begin
  SpriteToFront(
    FObjects.IndexOfItem(TEngine2DObject(ASender), FromBeginning)
  );
end;   }

procedure TEngine2DManager.ShowGroup(const AGroup: String);
var
  i, iG: Integer;
  vReg: TRegEx;
  vStrs: TArray<string>;
begin
  vReg := TRegEx.Create(',');
  vStrs := vReg.Split(AGroup);
  for iG := 0 to Length(vStrs) - 1 do
  begin
    vStrs[iG] := Trim(vStrs[iG]);
    for i := 0 to FObjects.Count - 1 do
      if FObjects[i].group = vStrs[iG] then
        FObjects[i].visible := True;
  end;
end;

function TEngine2DManager.Sprite(const AName: string): TSprite;
begin
  Result := TSprite.Create;
  Result.Resources := fResources;
  AddObject(Result, AName);
end;

procedure TEngine2DManager.SpriteToBack(const n: integer);
var
  i, l, oldOrder: integer;
begin
  l := length(FObjectOrder^);

  oldOrder := FObjectOrder^[n]; // ����� ������� ��������� ������� ����� n

  for i := 1 to l - 1 do
    if FObjectOrder^[i] < oldOrder then
      FObjectOrder^[i] := FObjectOrder^[i] + 1;

  FObjectOrder^[n] := 1;

end;

procedure TEngine2DManager.SpriteToFront(const n: integer);
var
  i, l, oldOrder: integer;
begin
  l := length(FObjectOrder^);
  oldOrder := l - 1;

  for i := 1 to l - 1 do
    if FObjectOrder^[i] = n then
    begin
      oldOrder := i;
      break;
    end;

  for i := oldOrder to l - 2 do
  begin
    FObjectOrder^[i] := FObjectOrder^[i + 1];
  end;

  FObjectOrder^[l - 1] := n;
end;

function TEngine2DManager.Text(const AName: string): TEngine2DText;
begin
  Result := TEngine2DText.Create;
  AddObject(Result, AName);
end;

end.
