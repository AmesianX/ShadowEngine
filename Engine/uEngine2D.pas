unit uEngine2D;

{******************************************************************************
Shadow Object Engine (SO Engine)
By Dmitriy Sorokin.

Some comments in English, some in Russian. And it depends on mood :-) Sorry!)
*******************************************************************************}

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Platform,
  FMX.Objects, Math, System.SyncObjs,
  {$IFDEF VER290} System.Math.Vectors, {$ENDIF}
  uClasses, uEngine2DThread, uEngine2DObject, uEngine2DUnclickableObject,
  uEngine2DSprite, uEngine2DText, uEngine2DClasses, uFormatterList, uSpriteList,
  uEngine2DResources, uEngine2DAnimation, uNamedList, uEngine2DAnimationList,
  uFastFields, uEasyDevice;

type

//  tSpriteArray = TNamedList<TEngine2DClickableObject>;//array of TEngine2DClickableObject;

  tEngine2d = class
  strict private
    fEngineThread: tEngineThread; // ����� � ������� ���������� ���������
    fOptions: TEngine2DOptions; // ��������� ������
    fSprites: tSpriteList; // ������ �������� ��� ���������
    fFastFields: tFastFields; // �������� ������ �� TFastField, ������� ������������ ����� ��������� �������� ������������ ��������
    fSpriteOrder: array of Integer; // ������ ������� ���������. ����� ��� ���������� ���-�� ����������, �������� ����� �������
    fResources: TEngine2DResources;//tResourceArray; // ������ ��������
    fFormatters: TFormatterList; // ������ ����������� ��������
    fAnimationList: TEngine2DAnimationList; // ������ ��������
    fMouseDowned: TIntArray; // ������ �������� ������, ������� ���������� ��� ������ � ������ �������
    fMouseUpped: TIntArray; // ������ �������� ������, ������� ���������� ��� ������ � ������ �������
    fClicked: TIntArray; // ������ �������� ������, ������� ������ ��� ����
    fStatus: byte; // ��������� ������ 0-�����, 1-������
    flX, flY: single; // o_O ��� ��������������� �� ��������� ���-��
    FIsMouseDowned: Boolean; // ������ ��������� ��������� ����
    fImage: tImage; // �����, � ������� ���������� ���������
    fBackGround: tBitmap; // ���������. ������ �������� � Repaint �� ���� fImage
    fCritical: TCriticalSection; // ����������� ������ ������
    fWidth, fHeight: integer; // ������ ���� ������ � ������
    fDebug: Boolean; // �� ����� �����, �� �������� ���������� �� �����, ����� ��������� ����� ���������� ������
    FBackgroundBehavior: TProcedure;
    FInBeginPaintBehavior: TProcedure;
    FInEndPaintBehavior: TProcedure;
    FAddedSprite: Integer; // ������� ������� �������� ��������� �����. ��� ����� ��������

    // �������� �������� ������� ��������. �� ����� ����� ������� TEngine2DObject �� ����� �������� �����������
    {FShadowSprite: tSprite; //
    FShadowText: TEngine2dText; }
    FShadowObject: tEngine2DObject;

    procedure prepareFastFields;
    procedure prepareShadowObject;
    procedure setStatus(newStatus: byte);
    procedure setObject(index: integer; newSprite: tEngine2DObject);
    function getObject(index: integer): tEngine2DObject;
    function getSpriteCount: integer; // ����� ������ fSprites
    procedure setWidth(newWidth: integer); // ��������� ������� ���� ��������� ������
    procedure setHeight(newHeight: integer); // ��������� ������� ���� ��������� ������
    procedure setBackGround(ABmp: tBitmap);

    procedure BackgroundDefaultBehavior;
    procedure InBeginPaintDefaultBehavior;
    procedure InEndPaintDefaultBehavior;

    function GetIfHor: Boolean;
    function GetHeight: integer;
    function GetWidth: integer;
    procedure SetBackgroundBehavior(const Value: TProcedure);
  public
    // �������� �������� ������
    property EngineThread: TEngineThread read fEngineThread;
    property Image: TImage read FImage write FImage;
    property BackgroundBehavior: TProcedure read FBackgroundBehavior write SetBackgroundBehavior;
    property InBeginPaintBehavior: TProcedure read FInBeginPaintBehavior write FInBeginPaintBehavior;
    property InEndPaintBehavior: TProcedure read FInBeginPaintBehavior write FInBeginPaintBehavior;
    // �������� ������ ������
    property Resources: TEngine2DResources read FResources;
    property AnimationList: TEngine2DAnimationList read fAnimationList;
    property FormatterList: TFormatterList read fFormatters;
    property SpriteList: TSpriteList read FSprites;
    property FastFields: tFastFields read FFastFields; // ������� ����� ��� ������������

    property IsMouseDowned: Boolean read FIsMouseDowned;
    property Status: byte read fStatus write setStatus;
    property Width: integer read GetWidth{ fWidth} write setWidth;
    property Height: integer read GetHeight{fHeight} write setHeight;

    property Clicked: tIntArray read fClicked;
    property Downed: TIntArray read fMouseDowned;
    property Upped: TIntArray read fMouseUpped;
    property Critical: TCriticalSection read FCritical;

    property SpriteCount: integer read getSpriteCount;
    property Sprites[index: integer]: tEngine2DObject read getObject write setObject;

    property Background: tBitmap read fBackGround write setBackGround;

    property IfHor: Boolean read GetIfHor; // �������� True, ���� Width > Height

   procedure SpriteToBack(const n: integer); // ����������� � ������� ��������� ������
    procedure SpriteToFront(const n: integer);// ����������� � ������� ��������� ������

    procedure DoTheFullWindowResize;
    procedure ApplyFormatters;
    procedure Clear; // ������� ��� ������� � ����� ����� ������� ��� �������

    procedure MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; x, y: single); virtual;
//    procedure mouseDown(const x, y: single); virtual;
    procedure MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; x, y: single); virtual;

    procedure DeleteObject(const AObject: tEngine2DObject); overload; // ������� ������ �� ���������
    procedure AddObject(const AObject: tEngine2DObject); overload;// ��������� ������ �� ���������
    procedure AddObject(const AName: String; const AObject: tEngine2DObject); overload;// ��������� ������ �� ���������

    procedure AssignShadowObject(ASpr: tEngine2DObject); // �������� ������ � ShadowObject
    property ShadowObject: tEngine2DObject read FShadowObject;  // ��������� �� ������� ������.

    procedure ClearSprites; // ������� ������ ��������, �.�. �������� ����������� � ������ �����������
//    procedure clearResources; // ������� ������ ��������, �.�. �������� ����������� � ����������
    procedure ClearTemp; // ������� ������� ������ � �.�. ������ ������ ���� �������� �����.

    procedure Init(newImage: tImage); // ������������� ������, ����� ������� �� �����, �� �������� ������������ fImage
    procedure Repaint; virtual;
    procedure ShowGroup(AGroup: String);

    procedure Start; virtual; // �������� ������
    procedure Stop; virtual;// ��������� ������

    constructor Create; virtual;
    destructor Destroy; override;

    const
      CGameStarted = 1;
      CGameStopped = 255;
  end;

const
  pi180 = 0.0174532925; // (1/180)*pi ��� ���������� ���������� ����������

implementation

{ tEngine2d }

procedure tEngine2d.addObject(const AObject: tEngine2DObject);
var
  l: integer;
begin
  l := spriteCount;
  Inc(FAddedSprite);
  addObject('genname'+IntToStr(FAddedSprite)+'x'+IntToStr(Random(65536)), AObject);
end;

procedure tEngine2d.addObject(const AName: String;
  const AObject: tEngine2DObject);
var
  l: integer;
begin
  if FSprites.IsHere(AObject) then
    raise Exception.Create('You are trying to add Object to Engine that already Exist')
  else
  begin
    fCritical.Enter;
    l := spriteCount;
    fSprites.Add(AName, AObject);
    setLength(fSpriteOrder, l + 1);
    fSprites[l].Image := fImage;
    fSpriteOrder[l] := l;
    fCritical.Leave;
  end;
end;

procedure tEngine2d.applyFormatters;
begin
end;

procedure tEngine2d.AssignShadowObject(ASpr: tEngine2DObject);
begin

  //  � ������ ��������� ������� �������� ����������� TEngine2DObject, �.�. ����� ��������� �����
  FShadowObject.Position := ASpr.Position;
{  FShadowObject.ScaleX := ASpr.ScaleX;
  FShadowObject.ScaleY := ASpr.ScaleY;  }
  tSprite(FShadowObject).Resources := tSprite(ASpr).Resources;


end;

procedure tEngine2d.BackGroundDefaultBehavior;
begin
  with Self.Image do
    Bitmap.Canvas.DrawBitmap(
      fBackGround,
      RectF(0, 0, fBackGround.width, fBackGround.height),
      RectF(0, 0, bitmap.width, bitmap.height),
      1,
      true);
end;

procedure tEngine2d.clear;
begin
  clearSprites;
//  clearResources;
end;


procedure tEngine2d.clearSprites;
var
  i, l: integer;
begin
  l := spriteCount - 1;

  for i := 0 to l do
  begin
    fSprites[i].free;
  end;

//  fSprites.Count := 0;
//  setLength(fSprites, 0);
  setLength(fSpriteOrder, 0);
end;

procedure tEngine2d.clearTemp;
begin
  setLength(self.fClicked, 0);
end;

constructor tEngine2d.Create; // (createSuspended: boolean);
begin
  fEngineThread := tEngineThread.Create;
  fResources := TEngine2DResources.Create;
  fResources.Parent := Self;
  fAnimationList := TEngine2DAnimationList.Create;
  fAnimationList.Parent := Self;
  fFormatters := TFormatterList.Create;
  fFormatters.Parent := Self;
  fSprites := TSpriteList.Create;
  fSprites.Parent := Self;
  fOptions.ToAnimateForever := True;
  fOptions.ToClickOnlyTop := False;
  fCritical := TCriticalSection.Create;
  FBackgroundBehavior := BackgroundDefaultBehavior;
  FInBeginPaintBehavior := InBeginPaintDefaultBehavior;
  FInEndPaintBehavior := InEndPaintDefaultBehavior;
  FAddedSprite := 0;
  fDebug := False;
  prepareFastFields;
  clearSprites;
  prepareShadowObject;

  fBackGround := tBitmap.Create;
end;

procedure tEngine2d.deleteObject(const AObject: tEngine2DObject);
var
  i, vN, vNum, vPos: integer;
begin
  fCritical.Enter;
  vNum := fSprites.IndexOfItem(AObject, FromEnd);
  if vNum > -1 then
  begin
    vN := fSprites.Count - 1;
    fAnimationList.ClearForSubject(AObject);
    fFormatters.ClearForSubject(AObject);
    fSprites.Delete(vNum{AObject});
   // AObject.Free;

    vPos := vN + 1;
    // ������� ������� �������
    for i := vN downto 0 do
      if fSpriteOrder[i] = vNum then
      begin
        vPos := i;
        Break;
      end;

    // �� ���� ������� �������� ������� ���������
    vN := vN - 1;
    for i := vPos to vN do
      fSpriteOrder[i] := fSpriteOrder[i+1];

    // ��� ������� ��������, ������� ������ vNum ���� ��������� �� 1
    for i := 0 to vN do
      if fSpriteOrder[i] >= vNum then
        fSpriteOrder[i] := fSpriteOrder[i] - 1;

    // ��������� ����� �������
    SetLength(fSpriteOrder, vN + 1);
  end;
  fCritical.Leave;
  fDebug := True;
end;

destructor tEngine2d.Destroy;
begin
  inherited;
  clearSprites;
//  clearResources;
  fImage.free;
  fAnimationList.Free;
  fFormatters.Free;
  fFastFields.Free;
  fBackGround.free;
end;

procedure tEngine2d.doTheFullWindowResize;
var
  size: tPointF;
  iA, lA: Integer;
begin
  size := getDisplaySizeInPx;


{  fFormatters.InitAll(size.X, size.Y);
  fFormatters.ApplyAll;  }

  self.width := round(size.x);
  self.height := round(size.y);

  // �������������
  lA := fFormatters.Count - 1;
  for iA := 0 to lA do
  begin
    fFormatters[iA].Format;// then
  end;

end;

function tEngine2d.GetHeight: integer;
begin
  Result := Round(Self.fImage.Height);
end;

function tEngine2d.GetIfHor: Boolean;
begin
  Result := fWidth > fHeight;
end;

procedure tEngine2d.repaint;
var
  i, l: integer;
  iA, lA: Integer; // �������� �������� � ��������������
  m: tMatrix;
  vAnimation: tAnimation;
begin

  // ��������
  fCritical.Enter;
  lA := fAnimationList.Count - 1;
  for iA := lA downto 0 do
  begin
    if fAnimationList[iA].Animate = TAnimation.CAnimationEnd then
    begin
      vAnimation := fAnimationList[iA];
      fAnimationList.Delete(iA);
      vAnimation.Free;
    end;
  end;
  fCritical.Leave;

  if fDebug then
   fDebug := False;

  fCritical.Enter;
  if (lA > 0) or (FOptions.ToAnimateForever)  then
    with fImage do
    begin
      if bitmap.Canvas.BeginScene() then
      try
        FInBeginPaintBehavior;
        FBackgroundBehavior;

        l := (fSprites.Count - 1);
        for i := 1 to l do
          if fSpriteOrder[i] <= l then
            if fSprites[fSpriteOrder[i]] <> Nil then
          
          if fSprites[fSpriteOrder[i]].visible then
          begin
            m :=
              TMatrix.CreateTranslation(-fSprites[fSpriteOrder[i]].x, -fSprites[fSpriteOrder[i]].y) *
              TMatrix.CreateScaling(fSprites[fSpriteOrder[i]].ScaleX, fSprites[fSpriteOrder[i]].ScaleY) *
              TMatrix.CreateRotation(fSprites[fSpriteOrder[i]].rotate * pi180) *
              TMatrix.CreateTranslation(fSprites[fSpriteOrder[i]].x, fSprites[fSpriteOrder[i]].y);
            Bitmap.Canvas.SetMatrix(m);

            fSprites[fSpriteOrder[i]].Repaint;
          end;
      finally
        FInEndPaintBehavior;

        bitmap.Canvas.endScene();
      end;
  end;

  fCritical.Leave;
end;

{function tEngine2d.ResToSF(const AId: Integer): TSpriteFrame;
var
  vTmp: TSpriteFrame;
begin
  vTmp.num := AId;
  vTmp.w := fResources[AId].bmp.Width;
  vTmp.h := fResources[AId].bmp.Height;

  Result := vTmp;
end;}

{function tEngine2d.getBitmap(index: integer): tBitmap;
var
  temp: tBitmap;
begin
  temp := tBitmap.Create;
  temp.Assign(fResources[index].bmp);
  result := temp;
end; }

function tEngine2d.getObject(index: integer): tEngine2DObject;
begin
  fCritical.Enter;
  result := fSprites[index];
  fCritical.Leave;
end;

function tEngine2d.getSpriteCount: integer;
begin
  result := fSprites.Count;//length(fSprites)
end;

function tEngine2d.GetWidth: integer;
begin
  Result := Round(Self.fImage.Width);
end;

procedure tEngine2d.InBeginPaintDefaultBehavior;
begin

end;

procedure tEngine2d.InEndPaintDefaultBehavior;
begin
  with FImage do
  begin
  // bitmap.Canvas.Blending:=true;
        bitmap.Canvas.SetMatrix(tMatrix.Identity);
        bitmap.Canvas.Fill.Color := TAlphaColorRec.Brown;
        {$IFDEF VER290}
        bitmap.Canvas.FillText(
          RectF(15, 15, 165, 125),
          'FPS=' + floattostr(fEngineThread.fps),
          false, 1, [],
          TTextAlign.Leading
        );

        if length(self.fClicked) >= 1 then
        begin
          bitmap.Canvas.FillText(RectF(15, 45, 165, 145),
            'sel=' + inttostr(self.fClicked[0]), false, 1, [],
            TTextAlign.Leading);
        end;
        bitmap.Canvas.FillText(
          RectF(25, 65, 200, 200),
          floattostr(flX) + ' ' + floattostr(flY),
          false, 1, [],
          TTextAlign.Leading
        );
        {$ENDIF}
        {$IFDEF VER260}
        bitmap.Canvas.FillText(
          RectF(15, 15, 165, 125),
          'FPS=' + floattostr(fEngineThread.fps),
          false, 1, [],
          TTextAlign.taLeading
        );

        if length(self.fClicked) >= 1 then
        begin
          bitmap.Canvas.FillText(RectF(15, 45, 165, 145),
            'sel=' + inttostr(self.fClicked[0]), false, 1, [],
            TTextAlign.taLeading);
        end;
        bitmap.Canvas.FillText(
          RectF(25, 65, 200, 200),
          floattostr(flX) + ' ' + floattostr(flY),
          false, 1, [],
          TTextAlign.taLeading
        );
        {$ENDIF}
  end;
end;

procedure tEngine2d.init(newImage: tImage);
var
  size: tPointF;
begin
  fImage := newImage;
  // ���������� �������� ������� �����-�� ��������� �� ����
  // fImage.OnMouseDown := someFunction
  size := getDisplaySizeInPx;
  self.width := round(size.x);
  self.height := round(size.y);
end;

procedure tEngine2d.mouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; x, y: single);
var
  i, l: integer;
begin
  fIsMouseDowned := True;

  flX := x * getScreenScale;
  flY := y * getScreenScale;
  l := fSprites.Count - 1;//length(fSprites) - 1;

  setLength(fClicked, 0);
  setLength(fMouseDowned, 0);

  // mainForm.Caption:=floattostr(x)+' '+floattostr(y);

  for i := l downto 1 do
  begin
    if fSprites[fSpriteOrder[i]].visible then
      if fSprites[fSpriteOrder[i]].underTheMouse(flX, flY) then
      begin
        setLength(fMouseDowned, length(fMouseDowned) + 1);
        fMouseDowned[high(fMouseDowned)] := fSpriteOrder[i];

      //�������� w � h � TEngine2DObject � ������� ����������� ��������� ����� � �������

      end;
  end;

 // Self.DeleteObject(FSprites[Random(fSprites.Count)]);
end;

procedure tEngine2d.mouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; x, y: single);
var
  i, l: integer;
begin
  fIsMouseDowned := False;

  flX := x * getScreenScale;
  flY := y * getScreenScale;
  l := fSprites.Count - 1;//length(fSprites) - 1;

  setLength(fClicked, 0);
  setLength(fMouseUpped, 0);

  for i := l downto 1 do
  begin
    if fSprites[fSpriteOrder[i]].visible then
      if fSprites[fSpriteOrder[i]].underTheMouse(flX, flY) then
      begin
        setLength(fMouseUpped, length(fMouseUpped) + 1);
        fMouseUpped[high(fMouseUpped)] := fSpriteOrder[i];
      end;
    end;

{  for i := 0 to l - 1 do
    fSprite[fMouseDown[i]].UnMouseDown;    }

  fClicked := IntArrInIntArr(fMouseDowned, fMouseUpped);
end;

procedure tEngine2d.prepareFastFields;
var
  vTmp: TFastField;
begin
  fFastFields := TFastFields.Create{(Self)};
  fFastFields.Parent := Self;
  vTmp := TFastEngineWidth.Create(Self);
  fFastFields.Add('engine.width', vTmp);
  vTmp := TFastEngineHeight.Create(Self);
  fFastFields.Add('engine.height', vTmp);
end;

procedure tEngine2d.prepareShadowObject;
begin
  FShadowObject := tSprite.Create(Self);
  FShadowObject.Parent := Self;
  Self.AddObject('shadow', FShadowObject);
end;

procedure tEngine2d.setBackGround(ABmp: tBitmap);
begin
//  wbmp := fBmp.width;
//  hbmp := fBmp.height;

  if width > height then
  begin
    fBackGround.Assign(ABmp);
    fBackGround.rotate(90);
    // fBackGround.Width:=fBMP.Width;
    // fBackGround.Height:=fBMP.Width;
    { fBackGround.Canvas.BeginScene();
      fBackGround.Canvas.DrawBitmap(fBMP,rect(0,0,wBMP,hBMP),); }

  end
  else
    fBackGround.Assign(ABmp);
end;

procedure tEngine2d.SetBackgroundBehavior(const Value: TProcedure);
begin
  FBackgroundBehavior := Value;
end;

{procedure tEngine2d.setBitmap(index: integer; newBitmap: tBitmap);
begin
  fResources[index].bmp.Assign(newBitmap);
  fResources[index].rect := RectF(0, 0, newBitmap.width, newBitmap.height);
end; }

procedure tEngine2d.setHeight(newHeight: integer);
begin
  fHeight := newHeight;
end;

procedure tEngine2d.setObject(index: integer; newSprite: tEngine2DObject);
begin
  fCritical.Enter;
  fSprites[index] := NewSprite;
  fCritical.Leave;
//  newSprite.copy(fSprites[index]);
end;

procedure tEngine2d.setStatus(newStatus: byte);
begin
  fStatus := newStatus;
end;

procedure tEngine2d.setWidth(newWidth: integer);
begin
  fWidth := newWidth;
end;

procedure tEngine2d.showGroup(AGroup: String);
var
  i, l: Integer;
begin
  l := fSprites.Count - 1;//Length(FSprites) - 1;

  for i := 0 to l do
    if FSprites[i].group = AGroup
    then
      FSprites[i].visible := True
    else
      FSprites[i].visible := False;
end;

procedure tEngine2d.spriteToBack(const n: integer);
var
  i, l, oldOrder: integer;
begin
  l := length(fSpriteOrder);

  oldOrder := fSpriteOrder[n]; // ����� ������� ��������� ������� ����� n

  for i := 0 to l - 1 do
    if fSpriteOrder[i] < oldOrder then
      fSpriteOrder[i] := fSpriteOrder[i] + 1;

  fSpriteOrder[n] := 0;
end;

procedure tEngine2d.spriteToFront(const n: integer);
var
  i, l, oldOrder: integer;
begin

  l := length(fSpriteOrder);
  oldOrder := l - 1;
  // oldOrder:=fSpriteOrder[n]; // ����� ������� ��������� ������� ����� n

  for i := 0 to l - 1 do
    if fSpriteOrder[i] = n then
    begin
      oldOrder := i;
      break;
    end; // fSpriteOrder[i]:=fSpriteOrder[i]-1; }

  // oldorder:=n;

  for i := oldOrder to l - 2 do
  begin
    fSpriteOrder[i] := fSpriteOrder[i + 1];
  end;

  fSpriteOrder[l - 1] := n;

end;

procedure tEngine2d.start;
begin
  status := CGameStarted;
end;

procedure tEngine2d.stop;
begin
  status := CGameStopped;
end;

end.

