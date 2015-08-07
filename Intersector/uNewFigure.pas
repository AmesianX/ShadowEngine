unit uNewFigure;

interface

uses
  System.Generics.Collections, System.Types, System.Classes,
  {$IFDEF VER290} System.Math.Vectors, {$ENDIF} System.Math,
  uIntersectorClasses, uIntersectorMethods, FMX.Objects, System.UITypes;

type
  TNewFigure = class
  private
    FKind: Byte;
    FData: TPolygon; // ������������ ������. �������� ����� SetData
    FTemp: TPolygon; // �������� ����������. �������� ����� Temp ������
    FTempMaxRadius: Single;
    FTempCenter: TPointF;
    procedure RecalcMaxRadius;
    function GetCircle: uIntersectorClasses.TCircle;
    function GetPoly: TPolygon; // ���������� � SetData
  public
    property Kind: Byte read FKind; // ���. ���� ��� ������� ���� ���
    property Temp: TPolygon read FTemp write FTemp;
    property TempMaxRadius: Single read FTempMaxRadius; // ��������� ������. �.�. � ������ ��������
    property AsCircle: uIntersectorClasses.TCircle read GetCircle;
    property AsPoly: TPolygon read GetPoly;
    property TempCenter: TPointF read FTempCenter write FTempCenter;

    procedure Reset; // ���������� �������� ��������� �� ���������.
//    procedure SetData(const vData: TArray<TPointF>); overload;// �������� ������ � ����������� �� ������ ����
    procedure SetData(const AData: TPolygon); overload;// �������� ������ � ����������� �� ������ ����
    procedure SetData(const AData: TRectF); overload;// ������� ������� ���������
    procedure SetData(const AData: uIntersectorClasses.TCircle); overload;// �������� ������ � ����������� �� ������ ����
    procedure AddPoint(const APoint: TPointF); // ��������� ����� ������ � ������������� �

    procedure TempTranslate(const APoint: TPointF);
    procedure TempRotate(const AAngle: Single);
    procedure TempScale(const APoint: TPointF);

    function IsIntersectWith(const AFigure: TNewFigure): Boolean;
    function FastIntersectWith(const AFigure: TNewFigure): Boolean; experimental; // APoint ��� ������ ����� ��� ���������. �����, �.�. � ��������� ��� ������
    function BelongPointLocal(const APoint: TPointF): Boolean;
    procedure Draw(AImage: TImage);

    constructor Create(const AKind: Byte);
    constructor CreatePoly;
    constructor CreateCircle;
  const
    cfCircle = 1;
    cfPoly = 2;
  end;



implementation

{ TNewFigure }

procedure TNewFigure.AddPoint(const APoint: TPointF);
begin
  SetLength(FData, Length(FData) + 1);
  FData[High(FData)] := APoint;
  Reset;
end;

function TNewFigure.BelongPointLocal(const APoint: TPointF): Boolean;
begin
  Reset;
  case FKind of
    cfCircle: Exit(uIntersectorMethods.IsPointInCircle(APoint, AsCircle));
    cfPoly: Exit(uIntersectorMethods.IsPointInPolygon(APoint, AsPoly));
  end;
end;

constructor TNewFigure.Create(const AKind: Byte);
begin
  FKind := AKind;
  SetLength(FData, 0);
  FTemp := Copy(FData);
end;

constructor TNewFigure.CreateCircle;
begin
  Self.Create(cfCircle);
end;

constructor TNewFigure.CreatePoly;
begin
  Self.Create(cfPoly);
end;

procedure TNewFigure.Draw(AImage: TImage);
begin
   case FKind of
    cfCircle:
    begin
      AImage.Bitmap.Canvas.Fill.Color := TAlphaColorRec.Aqua;
      AImage.Bitmap.Canvas.FillEllipse(
        RectF(
        FTemp[0].X - FTemp[1].X,
        FTemp[0].Y - FTemp[1].X,
        FTemp[0].X + FTemp[1].X,
        FTemp[0].Y + FTemp[1].X),
        0.75
      );
    end;
    cfPoly:
    begin
      AImage.Bitmap.Canvas.Fill.Color := TAlphaColorRec.Blue;
      AImage.Bitmap.Canvas.FillPolygon(AsPoly, 0.75);
    end;
  end;

  AImage.Bitmap.Canvas.Fill.Color := TAlphaColorRec.Yellow;
  AImage.Bitmap.Canvas.FillEllipse(
    RectF(
    FTempCenter.X - FTempMaxRadius,
    FTempCenter.Y - FTempMaxRadius,
    FTempCenter.X + FTempMaxRadius,
    FTempCenter.Y + FTempMaxRadius),
    0.1
  );

     AImage.Bitmap.Canvas.Fill.Color := TAlphaColorRec.Green;
     AImage.Bitmap.Canvas.FillEllipse(
        RectF(
        FTempCenter.X - 5,
        FTempCenter.Y - 5,
        FTempCenter.X + 5,
        FTempCenter.Y + 5),
        1
      );
end;

function TNewFigure.FastIntersectWith(const AFigure: TNewFigure): Boolean;
begin
  Result :=
    (
      Sqr(FTempCenter.X - AFigure.TempCenter.Y) +
      Sqr(FTempCenter.Y - AFigure.TempCenter.X)
    )
      <
    Sqr(AFigure.TempMaxRadius) + Sqr(Self.TempMaxRadius);
end;

function TNewFigure.GetCircle: uIntersectorClasses.TCircle;
begin
  Result.X := FTemp[0].X;
  Result.Y := FTemp[0].Y;
  Result.Radius := FTemp[1].X;
end;

function TNewFigure.GetPoly: TPolygon;
begin
  Result := Copy(FTemp);
end;

function TNewFigure.IsIntersectWith(const AFigure: TNewFigure): Boolean;
begin
  case FKind of
    cfCircle:
      case AFigure.Kind of
        cfCircle: Exit(CircleCircleCollide(Self.AsCircle, AFigure.AsCircle));
        cfPoly: Exit(CirclePolyCollide(AFigure.AsPoly, Self.AsCircle));
      end;
    cfPoly:
      case AFigure.Kind of
        cfCircle: Exit(CirclePolyCollide(Self.AsPoly, AFigure.AsCircle));
        cfPoly: Exit(PolyPolyCollide(Self.AsPoly, AFigure.AsPoly));
      end;
  end;
  Result := False;
end;

procedure TNewFigure.RecalcMaxRadius;
var
  i, vN: Integer;
begin
  case FKind of
    cfCircle: FTempMaxRadius := Distance(FTempCenter) + FTemp[1].X;
    cfPoly:
    begin
      vN := Length(FData) - 1;
      FTempMaxRadius := Distance(FTempCenter, FTemp[0]);
      for i := 1 to vN do
        FTempMaxRadius := Max(Distance(FTempCenter, FTemp[i]), FTempMaxRadius)
    end;
  end;
end;

procedure TNewFigure.Reset;
begin
  case FKind of
    cfCircle: FTempCenter := FData[0];
    cfPoly: FTempCenter := PointF(0, 0);
  end;

  FTemp := Copy(FData);
  RecalcMaxRadius;
end;

procedure TNewFigure.SetData(const AData: TRectF);
var
  vData: TPolygon;
begin
  SetLength(vData, 4);
  vData[0] := AData.TopLeft;
  vData[1] := PointF(AData.Right, AData.Top);
  vData[2] := AData.BottomRight;
  vData[3] := PointF(AData.Left, AData.Bottom);
  FData := vData;
  Reset;
end;

{procedure TNewFigure.SetData(const vData: TPolygon);
var
  i, vN: Integer;
begin
  vN := Length(vData);
  SetLength(FData, vN);
  for i := 0 to vN - 1 do
    FData[i] := vData[i];

  FTemp := FData;
  Reset;
end; }

procedure TNewFigure.SetData(const AData: uIntersectorClasses.TCircle);
begin
  if Length(FData) < 2 then
    SetLength(FData, 2);
  FData[0] := PointF(AData.X, AData.Y);
  FData[1] := PointF(AData.Radius, AData.Radius);
  FTemp := Copy(FData);
  Reset;
end;

procedure TNewFigure.SetData(const AData: TPolygon);
begin
  FData := Copy(AData);
  Reset;
end;

procedure TNewFigure.TempRotate(const AAngle: Single);
var
  i, vN: Integer;
  vTemp: Single;
begin
  vN := 0;
  case FKind of
    cfCircle: vN := 0;
    cfPoly: vN := Length(FTemp) - 1;
  end;

  for i := 0 to vN do
  begin
    vTemp := FTemp[i].X;
    FTemp[i].X := (FTemp[i].X) * Cos(AAngle * pi180) - (FTemp[i].Y) * Sin(AAngle * pi180);
    FTemp[i].Y := (vTemp) * Sin(AAngle * pi180) + (FTemp[i].Y) * Cos(AAngle * pi180);
  end;

  vTemp := FTempCenter.X;
  FTempCenter.X := (FTempCenter.X) * Cos(AAngle * pi180) - (FTempCenter.Y) * Sin(AAngle * pi180);
  FTempCenter.Y := (vTemp) * Sin(AAngle * pi180) + (FTempCenter.Y) * Cos(AAngle * pi180);
end;

procedure TNewFigure.TempScale(const APoint: TPointF);
var
  i, vN: Integer;
begin
  vN := Length(FTemp) - 1;
  for i := 0 to vN do
    FTemp[i] := FTemp[i] * APoint;
  FTempCenter := FTempCenter * APoint;
  RecalcMaxRadius;
end;

procedure TNewFigure.TempTranslate(const APoint: TPointF);
var
  i, vN: Integer;
begin
  case FKind of
    cfCircle: FTemp[0] := FTemp[0] + APoint;
    cfPoly:
    begin
      vN := Length(FTemp) - 1;
      for i := 0 to vN do
        FTemp[i] := FTemp[i] + APoint;
    end;
  end;
  FTempCenter := FTempCenter + APoint;

end;

end.

