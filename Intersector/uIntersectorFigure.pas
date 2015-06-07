unit uIntersectorFigure;

interface

uses
  System.Types, System.Generics.Collections,
  uIntersectorClasses, uIntersectorShapeModificator;

type
  TFigure = class abstract
  private
    FPositionChange: TPosition;
    FIntersectionComparer: Pointer;
  //  FModificators: TList<TShapeModificator>;
    procedure SetPositionChange(const Value: TPosition);
    function GetCalced: TPointF;
    function GetSize: Single; virtual; abstract;
    procedure SetSize(const Value: Single); virtual; abstract;
  protected
    FCenter: TPointF;
  public
    // �� ������, ���� ���-�� ����� ��������� ����� �����
    property X: Single read FCenter.X;// write FCenter.X; // ����� ������, �� �������� ��������� ������
    property Y: Single read FCenter.Y;// write FCenter.Y; // ����� ������, �� �������� ��������� ������
    property Size: Single read GetSize write SetSize;
    property Center: TPointF read FCenter;// write FCenter; // �������� �����. ����������� �������� �� ����

    procedure Rotate(const AValue: Single); virtual; abstract;
    procedure Scale(const AValue: TPointF); virtual; abstract;
    procedure Translate(const AValue: TPointF); virtual; abstract;

    function FigureRect: TRectF; virtual; abstract;

    constructor Create; virtual;
  end;

implementation

{ TFigure }

constructor TFigure.Create;
begin
  FPositionChange.X := 0;
  FPositionChange.Y := 0;
  FPositionChange.ScaleX := 1;
  FPositionChange.ScaleY := 1;
  FPositionChange.Rotate := 0;
end;

function TFigure.GetCalced: TPointF;
begin

end;

{function TFigure.GetPoints: TArray<TPointF>;
begin
//  Compute;
  Result := FPoints;
end;  }

procedure TFigure.SetPositionChange(const Value: TPosition);
begin
  FPositionChange := Value;
end;

end.

{    function IntersectWith(const AFigure: TFigure): Boolean; virtual; abstract;
    function BelongPoint(const AX, AY: Double): Boolean; virtual; abstract;  }

