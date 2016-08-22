unit uBaseContainer;

interface

uses
  uGeometryClasses, System.Types;

type
  TBaseUnitContainer = class
  protected
    FPosition: TPosition;
    function GetCenter: TPointF;
    function GetScalePoint: TPointF;
    procedure SetCenter(const Value: TPointF);
    procedure SetPosition(const Value: TPosition);
    procedure SetRotate(const Value: Single);
    procedure SetScale(const Value: Single);
    procedure SetScalePoint(const Value: TPointF);
    procedure SetScaleX(const Value: Single);
    procedure SetScaleY(const Value: Single);
    procedure SetX(const Value: Single);
    procedure SetY(const Value: Single);
  public
    // Geometrical properties �������������� ��������
    property Position: TPosition read FPosition write SetPosition; // ������� ��������� ���� ������ � ������� �������
    property X: Single read FPosition.x write SetX; // ���������� X �� ������� �������
    property Y: Single read FPosition.y write SetY; // ���������� Y �� ������� �������
    property Center: TPointF read GetCenter write SetCenter;
    property ScalePoint: TPointF read GetScalePoint write SetScalePoint;
    property Rotate: Single read FPosition.Rotate write SetRotate; // ���� �������� ������������ ������
    property ScaleX: Single read FPosition.ScaleX write SetScaleX;  // ������� ������� �� ����� ���������
    property ScaleY: Single read FPosition.ScaleY write SetScaleY;  // ������� ������� �� ����� ���������
    property Scale: Single write SetScale;  // ������� ������� �� ����� ���������
  end;

implementation

{ TBaseUnitContainer }

function TBaseUnitContainer.GetCenter: TPointF;
begin
  Result := FPosition.XY;
end;

function TBaseUnitContainer.GetScalePoint: TPointF;
begin
  Result := FPosition.Scale;
end;

procedure TBaseUnitContainer.SetCenter(const Value: TPointF);
begin
  FPosition.X := Value.X;
  FPosition.Y := Value.Y;
end;

procedure TBaseUnitContainer.SetPosition(const Value: TPosition);
begin
  FPosition := Value;
end;

procedure TBaseUnitContainer.SetRotate(const Value: Single);
begin
  FPosition.Rotate := Value;
end;

procedure TBaseUnitContainer.SetScale(const Value: Single);
var
  vSoot: Single;
begin
  if (FPosition.ScaleX) <> 0 then
  begin
    vSoot := FPosition.ScaleY / FPosition.scaleX;
  end
  else begin
    vSoot := 1;
  end;

  FPosition.scaleX := Value;
  FPosition.scaleY := vSoot * Value;
end;

procedure TBaseUnitContainer.SetScalePoint(const Value: TPointF);
begin
  FPosition.ScaleX := Value.X;
  FPosition.ScaleY := Value.Y
end;

procedure TBaseUnitContainer.SetScaleX(const Value: Single);
begin
  FPosition.ScaleX := Value;
end;

procedure TBaseUnitContainer.SetScaleY(const Value: Single);
begin
  FPosition.ScaleY := Value;
end;

procedure TBaseUnitContainer.SetX(const Value: Single);
begin
  FPosition.X := Value;
end;

procedure TBaseUnitContainer.SetY(const Value: Single);
begin
  FPosition.Y := Value;
end;

end.
