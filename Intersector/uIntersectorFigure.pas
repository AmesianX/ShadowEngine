unit uIntersectorFigure;

interface

uses
  System.Types,
  uIntersectorClasses;

type
  TFigure = class
  private
    FPosition: TPosition;
    FIntersectionComparer: Pointer;
  public
    // �� ������, ���� ���-�� ����� ��������� ����� �����
    property IntersectionComparer: Pointer read FIntersectionComparer write FIntersectionComparer;
    property Position: TPosition read FPosition write FPosition;
    function FigureRect: TRectF; virtual; abstract;
    function IntersectWith(const AFigure: TFigure): Boolean; virtual; abstract;
    function BelongPoint(const AX, AY: Integer): Boolean; virtual; abstract;

    constructor Create;
  end;

implementation

{ TFigure }

constructor TFigure.Create;
begin

end;

end.
