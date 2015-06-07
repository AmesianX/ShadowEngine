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
    FCenter: TPointF;
    FModificators: TList<TShapeModificator>;
    procedure SetPositionChange(const Value: TPosition);
    function GetCalced: TPointF;
    function GetPoints: TArray<TPointF>;
    function GetSize: Single; virtual; abstract;
    procedure SetSize(const Value: Single); virtual; abstract;
  protected
    FPoints: TArray<TPointF>;
    FOriginalPoints: TArray<TPointF>;
  public
    // �� ������, ���� ���-�� ����� ��������� ����� �����
    property X: Single read FCenter.X write FCenter.X; // ����� ������, �� �������� ��������� ������
    property Y: Single read FCenter.Y write FCenter.Y; // ����� ������, �� �������� ��������� ������
    property Size: Single read GetSize write SetSize;
    property Center: TPointF read FCenter write FCenter; // �������� �����. ����������� �������� �� ����
    property Modificators: TList<TShapeModificator> read FModificators write FModificators;
    property Points: TArray<TPointF> read GetPoints; // ������������� �����
    property OriginalPoints: TArray<TPointF> read FOriginalPoints write FOriginalPoints; // ������������� �������� �����
    property Calced: TPointF read GetCalced; // ����������� �����
    property IntersectionComparer: Pointer read FIntersectionComparer write FIntersectionComparer;
    property PositionChange: TPosition read FPositionChange write SetPositionChange; // ����� ������
    function FigureRect: TRectF; virtual; abstract;
    procedure Compute; virtual; abstract;
    function IntersectWith(const AFigure: TFigure): Boolean; virtual; abstract;
    function BelongPoint(const AX, AY: Double): Boolean; virtual; abstract;

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

function TFigure.GetPoints: TArray<TPointF>;
begin
  Compute;
  Result := FPoints;
end;

procedure TFigure.SetPositionChange(const Value: TPosition);
begin
  FPositionChange := Value;
end;

end.
