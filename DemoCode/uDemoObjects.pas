unit uDemoObjects;

interface

uses
  FMX.Types, System.UITypes, System.Classes, System.Types, System.SysUtils, System.Math,
  System.Generics.Collections,
  uEngine2DSprite, uEngine2DText, uEngine2DAnimation, uEngine2DStandardAnimations, uEngine2DClasses,
  uEngine2DManager, uEngine2DObject, uIntersectorClasses, uClasses;

type
  TShipFire = class(TSprite)
  private
    FTip: Byte;
  public
    property Tip: Byte read FTip write FTip; // ��� ����
    procedure Repaint; override;
    constructor Create; override;
  end;

  TShipLight = class(TSprite)
  public
    procedure Repaint; override;
  end;

  TMovingUnit = class(TSprite)
  protected
    FDx, FDy, FDA: Double; // ������
    FMaxDx, FMaxDy, FMaxDa: Single;
    FMonitorScale: Single;
    FSpeedModScale: Single;
  public
    property DX: Double read FDx write FDx;
    property DY: Double read FDy write FDy;
    property DA: Double read FDa write FDa;
    procedure SetMonitorScale(const AValue: Single);
    procedure SetSpeedModScale(const AValue: Single);
  end;

  TShip = class(TMovingUnit)
  private
    FManager: TEngine2DManager;
    FParts: TList<TSprite>;
    FLeftFire: TShipFire;
    FRightFire: TShipFire;
    FLeftFireCenter: TShipFire;
    FRightFireCenter: TShipFire;
    FShipLight: TShipLight;
    FDestination: TPosition;
    FDestinations: TList<TPosition>;
    FIsPaint: Boolean;
    procedure MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
  protected
    procedure SetScale(AValue: single); override;
    procedure SetOpacity(const Value: single); override;
  public
    property Parts: TList<TSprite> read FParts;

    property Destination: TPosition read FDestination write FDestination;
    property IsPaint: Boolean read FIsPaint write FIsPaint;
    procedure Repaint; override;
    procedure Hide;
    procedure Show;
    procedure AddDestination(const APos: TPosition);
    constructor Create(ACreator: TEngine2DManager); reintroduce;
    destructor Destroy; override;
  end;

  TAsteroid = class(TMovingUnit)
  private
//    FNotChange: Integer; // ���-�� �����, ������� �� ����� ���������� ����������� ��� ����������
    FManager: TEngine2DManager;
    FScaleMod: Single;
    FSize: Byte;
    FSpeed: Byte;
    FCollidedWith: TDictionary<TMovingUnit, Integer>; // ���-�� ����� ������������ � ���������
    procedure SetScaleMod(const Value: Single); // ����������� �������
  protected
    property DX;
    property DY;
    property DA;
    procedure SetScale(AValue: single); override;
  public
    procedure DefineProperty(const ASize, ASpeed: Byte);
    procedure Repaint; override;
    property Speed: Byte read FSpeed; // prSmall = 1; prMedium = 2; prBig = 3;
    property Size: Byte read FSize; // prSmall = 1; prMedium = 2; prBig = 3;
    property ScaleMod: Single read FScaleMod write SetScaleMod;
    function Collide(const AObject: TMovingUnit): Boolean;
    constructor Create(ACreator: TEngine2DManager); reintroduce;
  end;

  TLittleAsteroid = class(TMovingUnit)
  private
    FManager: TEngine2DManager;
    FTip: Byte;
  public
    property Tip: Byte read FTip write FTip; // ��� ���������
    procedure Repaint; override;
    constructor Create(AManager: TEngine2DManager); reintroduce;
  end;

  TExplosion = class(TSprite)
  end;

  TStar = class(TSprite)
  public
    procedure Repaint; override;
  end;

implementation

uses
  mainUnit,
  uEngine2D, uDemoGameLoader, uIntersectorMethods;

{ TShip }

procedure TShip.AddDestination(const APos: TPosition);
begin
  FDestinations.Add(APos);
end;

constructor TShip.Create(ACreator: TEngine2DManager);
begin
  FManager := ACreator;
  inherited Create;

  FLeftFire := TShipFire.Create;
  FLeftFire.Group := 'ship';
  FLeftFire.Justify := BottomCenter;
  FLeftFire.ScaleX := Self.ScaleX;
  FLeftFire.ScaleY := Self.ScaleY;
  FLeftFire.Opacity := 0.5;
  FManager.Add(FLeftFire);

  FRightFire := TShipFire.Create;
  FRightFire.Group := 'ship';
  FRightFire.Justify := BottomCenter;
  FRightFire.ScaleX := -Self.ScaleX;
  FRightFire.ScaleY := Self.ScaleY;
  FRightFire.Opacity := 0.5;
  FManager.Add(FRightFire);

  FLeftFireCenter := TShipFire.Create;
  FLeftFireCenter.Group := 'ship';
  FLeftFireCenter.Justify := BottomCenter;
  FLeftFireCenter.ScaleX := Self.ScaleX;
  FLeftFireCenter.ScaleY := Self.ScaleY;
  FLeftFireCenter.Opacity := 0.5;
  FManager.Add(FLeftFireCenter);

  FRightFireCenter := TShipFire.Create;
  FRightFireCenter.ScaleX := -Self.ScaleX;
  FRightFireCenter.Group := 'ship';
  FRightFireCenter.Justify := BottomCenter;
  FRightFireCenter.ScaleY := Self.ScaleY;
  FRightFireCenter.Opacity := 0.5;
  FManager.Add(FRightFireCenter);

  FShipLight := TShipLight.Create;
  FShipLight.Group := 'ship';
  FShipLight.ScaleX := Self.ScaleX;
  FShipLight.ScaleY := Self.ScaleY;
  FManager.Add(FShipLight);

  Self.OnMouseDown := Self.MouseDown;

  FParts := TList<TSprite>.Create;
  FParts.Add(Self);
  FParts.Add(FLeftFire);
  FParts.Add(FRightFire);
  FParts.Add(FLeftFireCenter);
  FParts.Add(FRightFireCenter);
  FParts.Add(FShipLight);

  DA := 16;
  Dx := 20;
  Dy := 20;

  FMaxDx := 20;
  FMaxDy := 20;

  FIsPaint := True;

  FDestinations := TList<TPosition>.Create;
end;

destructor TShip.Destroy;
var
  i: Integer;
begin
  // ������� ������ ��� ��� �������
  for i := 1 to FParts.Count - 1 do
    FParts[i].Free;

  FParts.Free;

  FDestinations.Free;

  inherited;
end;

procedure TShip.Hide;
var
  i: Integer;
begin
  for i := 0 to FParts.Count - 1 do
    FParts[i].Visible := False;
end;

procedure TShip.MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
var
  vPos: TPosition;
  vFi, vEX, vEY, vDist: Double; // ����������
  vAni: TAnimation;
begin
  vEX := Self.x - X;
  vEY := Self.y - y;

  vDist := Sqrt(Sqr(vEX) + Sqr(vEY));
  vFi := ArcTan2(-vEY, -vEX);
  if vDist > 25 then
    vPos.Rotate := (Self.Rotate + ((vFi / Pi) * 180+270)) / 2
  else
    vPos.rotate := Self.Rotate;
  vPos.x := self.x + vEX * vDist * 0.05;
  vPos.y := self.y + vEY * vDist * 0.05;

  vPos.ScaleX := Self.ScaleX;
  vPos.ScaleY := Self.ScaleY;
  Self.Opacity := 1;

  mainForm.caption := FloatToStr(vEX) + '~~' + FloatToStr(vEY) + '~~' + FloatToStr(vPos.Rotate);

  vAni := TLoader.ShipFlyAnimation(Self, vPos);

  FManager.Add(vAni);
end;

procedure TShip.Repaint;
var
  vAngle: Single;
  vDir: Single;
  vKoef, vLeftKoef, vRightKoef: Single;
  vNewX, vNewY: Single;
begin
  curRes := 0;

  inherited;

  vLeftKoef := 1;
  vRightKoef := 1;

  vKoef := Distance(Self.Center, FDestination.XY) / Self.w;
  if vKoef > 1 then
    vKoef := 1;

  if vKoef < 0.225 * SpeedModScale then
  begin
    vKoef := 0.225 * SpeedModScale;
  end;

  if vKoef > 0.3 * (SpeedModScale) then
  begin
    vAngle := Self.Rotate;
    NormalizeAngle(vAngle);
    Self.Rotate := vAngle;

    vAngle := ArcTan2(FDestination.Y - Self.Y, FDestination.X - Self.x) / pi180;
    vDir := (vAngle - Self.Rotate);

    NormalizeAngle(vDir);

    if (vDir < -90) or (vDir > 90) then
    begin

      Self.Rotate := Self.Rotate - DA * vKoef * FManager.EngineSpeed * FSpeedModScale;
      vLeftKoef := 1;
      vRightKoef := 0.4;
    end
    else begin
      Self.Rotate := Self.Rotate + DA * vKoef * FManager.EngineSpeed * FSpeedModScale;
      vLeftKoef := 0.4;
      vRightKoef := 1;
    end;

    if ((Abs(vDir) > 165) and (Abs(vDir) < 180))  then
    begin
      vLeftKoef := 1;
      vRightKoef := 1;
    end;

    if ((Abs(vDir) > 0) and (Abs(vDir) < 15)) then
    begin
      vLeftKoef := 1;
      vRightKoef := 1;
    end;

    vNewX := Self.x - (DX * Cos((Self.Rotate + 90) * pi180)) * vKoef * FManager.EngineSpeed * FSpeedModScale;

    if Distance(FDestination.XY, PointF(vNewX, Self.y)) <
       Distance(FDestination.XY, Self.Center)
     then
       Self.x := Self.x - (DX * Cos((Self.Rotate + 90) * pi180)) * vKoef * FManager.EngineSpeed * FSpeedModScale;

    vNewY := Self.Y - (DY * Sin((Self.Rotate + 90) * pi180)) * vKoef * FManager.EngineSpeed * FSpeedModScale;
    if Distance(FDestination.XY, PointF(Self.x, vNewY)) <
       Distance(FDestination.XY, Self.Center)
    then
      Self.Y := Self.Y - (DY * Sin((Self.Rotate + 90) * pi180)) * vKoef * FManager.EngineSpeed * FSpeedModScale;
  end else
  begin
    Self.X := Self.X - (DX * Cos((Self.Rotate + 90) * pi180)) * 0.3 * vKoef * FManager.EngineSpeed * FSpeedModScale;
    Self.Y := Self.Y - (DY * Sin((Self.Rotate + 90) * pi180)) * 0.3 * vKoef * FManager.EngineSpeed * FSpeedModScale;

  if Self.x >= FManager.EngineWidth + Self.scW then
    Self.x := -Self.scW
  else
    if Self.x < 0 - Self.scW then
      Self.x := FManager.EngineWidth + Self.scW;

  if Self.y >= FManager.EngineHeight + Self.scH then
    Self.y := -Self.scH
  else
    if Self.y < 0 - Self.scH then
     Self.y := FManager.EngineHeight + Self.scH;

    FDestination.XY(Self.Center);

  end;

  if not FIsPaint then
    Exit;

  FLeftFire.Rotate := Self.Rotate;
  FLeftFire.ScalePoint := Self.ScalePoint * 2 * vKoef * vLeftKoef;
  FLeftFire.x := Self.x + (scW*0.15 - 0) * cos((Self.Rotate / 180) * pi) - (scH*0.4 - 0) * sin((Self.Rotate / 180) * pi);
  FLeftFire.y :=  Self.y + (scW*0.15 - 0) * sin((Self.Rotate / 180) * pi)+ (scH*0.4 - 0) * cos((Self.Rotate / 180) * pi);

  FRightFire.Rotate := Self.Rotate;
  FRightFire.ScalePoint := Self.ScalePoint * PointF(-2, 2) * vKoef * vRightKoef;
  FRightFire.x := Self.x + (-scW*0.15 - 0) * cos((Self.Rotate / 180) * pi) - (scH*0.4 - 0) * sin((Self.Rotate / 180) * pi);
  FRightFire.y :=  Self.y + (-scW*0.15 - 0) * sin((Self.Rotate / 180) * pi) + (scH*0.4 - 0) * cos((Self.Rotate / 180) * pi);

  FLeftFireCenter.Rotate := Self.Rotate;
  FLeftFireCenter.ScalePoint := Self.ScalePoint * 2 * vKoef;
  FLeftFireCenter.x := Self.x + (scW*0.0 - 0) * cos((Self.Rotate / 180) * pi) - (scH*0.3 - 0) * sin((Self.Rotate / 180) * pi);
  FLeftFireCenter.y :=  Self.y + (scW*0.0 - 0) * sin((Self.Rotate / 180) * pi) + (scH*0.3 - 0) * cos((Self.Rotate / 180) * pi);

  FRightFireCenter.Rotate := Self.Rotate;
  FRightFireCenter.ScalePoint := Self.ScalePoint * PointF(-2, 2) * vKoef;
  FRightFireCenter.x := Self.x + (-scW*0.0 - 0) * cos((Self.Rotate / 180) * pi) - (scH*0.3 - 0) * sin((Self.Rotate / 180) * pi);
  FRightFireCenter.y :=  Self.y + (-scW*0.0 - 0) * sin((Self.Rotate / 180) * pi) + (scH*0.3 - 0) * cos((Self.Rotate / 180) * pi);

  FShipLight.ScalePoint := Self.ScalePoint;
  FShipLight.Rotate := Self.Rotate;
  FShipLight.x := Self.x + (-scW*0.0 - 0) * cos((Self.Rotate / 180) * pi) - (scH * 0.4) * sin((Self.Rotate / 180) * pi);
  FShipLight.y :=  Self.y + (-scW*0.0 - 0) * sin((Self.Rotate / 180) * pi) + (scH * 0.4) * cos((Self.Rotate / 180) * pi);
  FShipLight.SendToFront;
 end;

procedure TShip.SetOpacity(const Value: single);
var
  i: Integer;
begin
  inherited;
//  Self.Opacity := Value;
  if FParts <> nil then
    for i := 1 to FParts.Count - 1 do
      FParts[i].Opacity := Value;
end;

procedure TShip.SetScale(AValue: single);
var
  i: Integer;
begin
  inherited;
  for i := 1 to FParts.Count - 1 do
    FParts[i].Scale := AValue;
end;

procedure TShip.Show;
begin
//Self.SetOpacity(1);
  Opacity := 1;
  Self.x := FManager.EngineWidth * 0.5;
  Self.y := FManager.EngineHeight * 0.5;
  FIsPaint := True;
  FManager.ShowGroup('ship');

end;

{ TAsteroid }

function TAsteroid.Collide(const AObject: TMovingUnit): Boolean;
var
  vArcTan: Extended;
  vLoader: TLoader;
  vAng: Double;
  vAni: TAnimation;
  vExp: TExplosion;
  Theta1, Theta2, Phi: Double;
  V1, V2: Double;
  V1NewX, V1NewY: Double;
  V2NewX, V2NewY: Double;
  M1, M2: Double;
  XC, YC: Double; // ����� ���������������
begin

  if  FCollidedWith.ContainsKey(AObject) then
  begin
    FCollidedWith[AObject] := 2;
    Exit(False);
  end;

  vArcTan := ArcTan2(AObject.y - Self.y, AObject.x - Self.x);

  XC := Self.x + (Self.Shape.MaxRadius * 1) * Cos(vArcTan);
  YC := Self.y + (Self.Shape.MaxRadius * 1) * Sin(vArcTan);

  Phi := vArcTan;
  Theta1 := ArcTan2(YC - Self.y, XC - Self.x);
  Theta2 := ArcTan2(YC - AObject.y, XC - AObject.x);
  M1 := Self.ScaleX;
  M2 := AObject.ScaleX;

  V1 := Sqrt((FDx * FDx) + (FDy * FDy));
  V2 := Sqrt((AObject.DX * AObject.DX) + (AObject.DY * AObject.DY));

  if (AObject is TShip) then
  begin
    M2 := M1;
    V2 := V1;
  end;

  V1NewX := ((V1 * Cos(Theta1 - Phi)*(M1-M2) + 2*M2*V2*Cos(Theta2 - Phi)) /
            (M1 + M2)) * Cos(Phi) + V1 * Sin(Theta1 - Phi)*Cos(Phi + Pi * 0.5);
  V1NewY := ((V1 * Cos(Theta1 - Phi)*(M1-M2) + 2*M2*V2*Cos(Theta2 - Phi)) /
            (M1 + M2)) * Sin(Phi) + V1 * Sin(Theta1 - Phi)*Sin(Phi + Pi * 0.5);

  V2NewX := ((V2 * Cos(Theta2 - Phi)*(M2-M1) + 2*M1*V1*Cos(Theta1 - Phi)) /
            (M1 + M2)) * Cos(Phi) + V2 * Sin(Theta2 - Phi)*Cos(Phi + Pi * 0.5);
  V2NewY := ((V2 * Cos(Theta2 - Phi)*(M2-M1) + 2*M1*V1*Cos(Theta1 - Phi)) /
            (M1 + M2)) * Sin(Phi) + V2 * Sin(Theta2 - Phi)*Sin(Phi + Pi * 0.5);

  FDX := V1NewX;
  FDY := V1NewY;

  if not (AObject is TShip) then
  begin
    AObject.DX := V2NewX;
    AObject.DY := V2NewY;
  end;

 // FDx := - FDx;
 // FDy := - FDy;

  AObject.x := AObject.x - FDx * FManager.EngineSpeed * 2 * FSpeedModScale;
  AObject.y := AObject.y - FDy * FManager.EngineSpeed * 2 * FSpeedModScale;

  vLoader := TLoader.Create(FManager, Nil);
  vAng := vArcTan / pi180;

  vExp := vLoader.Explosion(
    Self.x + (Self.Shape.MaxRadius * 1) * Cos(vArcTan),
    Self.y + (Self.Shape.MaxRadius * 1) * Sin(vArcTan),
    vAng);

  vAni := vLoader.ExplosionAnimation(vExp);

  AObject.Rotate := AObject.Rotate + (vArcTan / pi180) * 0.02;
  FCollidedWith.Add(AObject, 3);

  FManager.Add(vAni);
  Result := True;
  vLoader.Free;
end;

constructor TAsteroid.Create(ACreator: TEngine2DManager);
begin
  inherited Create;
  FManager := ACreator;

  FMaxDx := 10;
  FMaxDy := 10;
  FMaxDa := 6;
  FScaleMod := 1;

  FSpeed := 1;
  FSize := 1;

  FDx := 3 * Random;
  FDy := 3 * Random;
  FDA := 10 * Random - 5;

  FCollidedWith := TDictionary<TMovingUnit, Integer>.Create;
end;

procedure TAsteroid.DefineProperty(const ASize, ASpeed: Byte);
var
  vSpeed, vAng: Double;
begin
  FSpeed := ASpeed;
  FSize := ASize;
  ScaleMod := ASize * 0.3 + 0.4;
  vSpeed := ASpeed * 1.5 + 3;

  vAng := Random(360) + random;

  FDX := vSpeed * Cos(vAng * pi180);
  FDY := vSpeed * Sin(vAng * pi180);
end;

procedure TAsteroid.Repaint;
var
  vItem: TMovingUnit;
begin
  inherited;

  Self.x := Self.x + FDx * FManager.EngineSpeed * FSpeedModScale;
  Self.y := Self.y + FDy * FManager.EngineSpeed * FSpeedModScale;
  Self.Rotate := Self.Rotate + FDa * FManager.EngineSpeed * FSpeedModScale;

  if Self.Rotate >= 360 then
    Self.Rotate := 0;

  if Self.x >= FManager.EngineWidth + Self.scW then
    Self.x := -Self.scW
  else
    if Self.x < 0 - Self.scW then
      Self.x := FManager.EngineWidth + Self.scW;

  if Self.y >= FManager.EngineHeight + Self.scH then
    Self.y := -Self.scH
  else
    if Self.y < 0 - Self.scH then
     Self.y := FManager.EngineHeight + Self.scH;

  for vItem in FCollidedWith.Keys do
  begin
    FCollidedWith[vItem] := FCollidedWith[vItem] - 1;
    if FCollidedWith[vItem] <= 0 then
      FCollidedWith.Remove(vItem);
  end;
end;

procedure TAsteroid.SetScale(AValue: single);
var
  vValue: Single;
begin
  vValue := AValue * FScaleMod;
  inherited SetScale(vValue);
end;

procedure TAsteroid.SetScaleMod(const Value: Single);
var
  vOldMod: Single;
begin
  vOldMod := FScaleMod;
  FScaleMod := Value;
  Self.Scale := (Self.ScaleX / vOldMod) * FScaleMod;
end;

{ TLittleAsteroid }

constructor TLittleAsteroid.Create(AManager: TEngine2DManager);
begin
  FManager := AManager;
//  FParent := AParent;
  inherited Create;
  FTip := Random(6);
  if FTip > 3 then
    FTip := 3; // ����� ����� �������� ����

  FMaxDx := 20;
  FMaxDy := 20;
  FMaxDa := 10;

  FDX := Random * 12;
  FDY := Random * 12 ;
  FDA := 60 * Random - 30;
end;

procedure TLittleAsteroid.Repaint;
begin
  inherited;

  Self.Rotate := Self.Rotate + FDa * FManager.EngineSpeed * FSpeedModScale;

  if Self.Rotate >= 360 then
    Self.Rotate := 0;

  Self.x := Self.x + FDx * FManager.EngineSpeed * FSpeedModScale;
  Self.y := Self.y + FDy * FManager.EngineSpeed * FSpeedModScale;

  if Self.x > FManager.EngineWidth then
    Self.x := -1;

  if Self.y > FManager.EngineHeight then
    Self.y := -1;
end;

{ TStar }

procedure TStar.Repaint;
begin
  inherited;

end;

{ TShipFire }

constructor TShipFire.Create;
begin
  inherited;
  FTip := Random(3);
end;

procedure TShipFire.Repaint;
begin
  inherited;
  FTip := Random(3);
  curRes := FTip + 2;
end;

{ TShipLight }

procedure TShipLight.Repaint;
begin
  if Opacity > 0.1 then
    Opacity := 0.8 + Random * 0.2;
  CurRes := 13 + Random(2);
  inherited;
end;

{ TMovingUnit }

procedure TMovingUnit.SetMonitorScale(const AValue: Single);
begin
  FMonitorScale := AValue;
end;

procedure TMovingUnit.SetSpeedModScale(const AValue: Single);
begin
  FSpeedModScale := AValue;
end;

end.



