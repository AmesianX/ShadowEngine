unit uEngine2DExpression;

interface
uses
  uExpressionParser;

{type
  TEngine2DExpression = class(TExpression)
  protected
    procedure ParseOuterBrackets; virtual; // ������� ��� ������ ������
  public
  end;  }

implementation

end.
