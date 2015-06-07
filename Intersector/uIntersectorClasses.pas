unit uIntersectorClasses;

interface

uses
  System.Types;

type
  TPosition = record // ����� ��� ���������� ��������
    X, Y: Single;
    Rotate: Single;
    ScaleX, ScaleY: single;
  end;

  TCircle = record
    X, Y: Single;
    Radius: Single;
  end;

  TLine = record
    A, B: TPointF;
  end;

implementation

end.
