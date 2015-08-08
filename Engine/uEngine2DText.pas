unit uEngine2DText;

interface

uses
  System.Types, System.UITypes, FMX.Graphics, FMX.Objects, FMX.Types,
  System.Math, System.SysUtils,
  uEngine2DClasses, uEngine2DResources,
  uEngine2DObject;

type
  TEngine2DText = class(tEngine2DObject)
  strict private
    fText: string; // �����. ���� ����, �� ���������
    fFont: tFont; // ����� �������
    fColor: TAlphaColor; // ���� ������
    FFillTextFlags: TFillTextFlags; // �������� ������
    FVerAlign, FHorAlign: TTextAlign; // ������������ ������
    FTextRect: TRectF;
  private
    FFontSizeRatio: Single;
    FAutoSize: Boolean;
    FWordWrap: Boolean;
    procedure SetFont(const Value: tFont);
    procedure SetText(const Value: string);
//    procedure RenewRec;
    procedure SetTextRect(const Value: TRectF);
    procedure SetWordWrap(const Value: Boolean);
  protected
    function GetW: single; override;
    function GetH: single; override;
    procedure SetScale(AValue: single); override;
    procedure SetX(AValue: single); override;
    procedure SetY(AValue: single); override;
  public
    property Font: tFont read fFont write SetFont;
    property Text: string read fText write SetText;
    property TextRec: TRectF read FTextRect write SetTextRect;
    property Color: TAlphaColor read FColor write FColor;
    property AutoSizeFont: Boolean read FAutoSize write FAutoSize;
    property FontSizeRation: Single read FFontSizeRatio write FFontSizeRatio;
    property WordWrap: Boolean read FWordWrap write SetWordWrap;
    procedure AutoResizeFont(const ARatio: Single = 0); // ������������� ��������� ������ ������

 //   procedure copy(var AText: TEngine2DText); // ������ ����� �������
    function UnderTheMouse(const Mousex, MouseY: Double): boolean; override;
    procedure Repaint; override;
    constructor Create(AParent: pointer); override;
    destructor Destroy; override;
  end;

implementation

{ TEngine2DText }

procedure TEngine2DText.AutoResizeFont(const ARatio: Single);
var
  vRect: TRectF;
  vRatio: Single;
begin
  if FText <> '' then
   fFont.Size := fFont.Size * Self.ScaleX;
  {if FText <> '' then

   with Image do
   begin
      vRect := FTextRect;
      Bitmap.Canvas.MeasureText(vRect, fText, FWordWrap, [], TTextAlign.Leading, TTextAlign.Leading);
      vRatio := Min(FTextRect.Height / vRect.Height, FTextRect.Width / vRect.Width);

   end;}
end;

constructor TEngine2DText.Create(AParent: pointer);
begin
  inherited;
  fFont := tFont.Create; // ����� �������
  fFont.Family := 'Arial';
  fFont.Size := 12;
  fColor := TAlphaColorRec.Black; // ���� ������
  FFontSizeRatio := 0.8;
  FAutoSize := True;
  FWordWrap := False;
  FTextRect := RectF(-50, -25, 50, 25);
  {$IFDEF VER290}
    FFillTextFlags := [TFillTextFlag.RightToLeft]; // �������� ������
    FVerAlign := TTextAlign.Center;
    FHorAlign := TTextAlign.Center;
  {$ENDIF}
  {$IFDEF VER260}
    FFillTextFlags := [TFillTextFlag.ftRightToLeft]; // �������� ������
    FVerAlign := TTextAlign.taCenter;
    FHorAlign := TTextAlign.taCenter;
  {$ENDIF}
end;

destructor TEngine2DText.Destroy;
begin

  inherited;
end;

function TEngine2DText.getH: single;
begin
  Result := FTextRect.Height; //Image.Bitmap.Canvas.TextHeight(FText);
end;

function TEngine2DText.getW: single;
begin
  Result := FTextRect.Width;// Image.Bitmap.Canvas.TextWidth(FText);
end;

{procedure TEngine2DText.RenewRec;
begin
  FTextRect := RectF(
    X - W * ScaleX / 2, Y - H * ScaleY / 2,
    X + W * ScaleX / 2, Y + H * ScaleY / 2);
end; }

procedure TEngine2DText.Repaint;
var
  vTmp: TFont;
begin
  inherited;

  with Image do
  begin
  {$IFDEF VER290}
    Bitmap.Canvas.Stroke.Kind := TBrushKind.Solid;
  {$ENDIF}
  {$IFDEF VER260}
    Bitmap.Canvas.Stroke.Kind := TBrushKind.bkSolid;
  {$ENDIF}
    Bitmap.Canvas.StrokeThickness := 1;
    Bitmap.Canvas.Fill.Color := FColor;

    vTmp := TFont.Create;
    vTmp.Assign( Bitmap.Canvas.Font);
    Bitmap.Canvas.Font.Assign(FFont);

//    Bitmap.Canvas.FillRect(FTextRect, 0, 0, [], 0.5);
    Bitmap.Canvas.FillText( FTextRect, FText, FWordWrap, Opacity, FFillTextFlags,
    FHorAlign, FVerAlign);
    Bitmap.Canvas.Font.Assign(vTmp);
    vTmp.Free;
  end;
end;

procedure TEngine2DText.SetFont(const Value: tFont);
begin
  fFont := Value;
end;

procedure TEngine2DText.SetScale(AValue: single);
begin
  inherited;
  fTextRect.TopLeft := fTextRect.TopLeft * AValue;
  fTextRect.BottomRight := FTextRect.BottomRight * AValue;
  if FAutoSize then
    AutoResizeFont(FFontSizeRatio);
end;

procedure TEngine2DText.SetText(const Value: string);
begin
  fText := Value;
  if FAutoSize then
    AutoResizeFont(FFontSizeRatio);
end;

procedure TEngine2DText.SetTextRect(const Value: TRectF);
begin
  FTextRect := Value;
  if FAutoSize then
    AutoResizeFont(FFontSizeRatio);
end;

procedure TEngine2DText.SetWordWrap(const Value: Boolean);
begin
  FWordWrap := Value;
  if FAutoSize then
    AutoResizeFont(FFontSizeRatio);
end;

procedure TEngine2DText.setX(AValue: single);
begin
  inherited;
  FTextRect.Location := TPointF.Create(AValue - FTextRect.Width * 0.5, Self.y - FTextRect.Height * 0.5);//.AValue;
end;

procedure TEngine2DText.setY(AValue: single);
begin
  inherited;
  FTextRect.Location := TPointF.Create(Self.x - FTextRect.Width * 0.5, AValue - FTextRect.Height * 0.5);//.AValue;
end;

function TEngine2DText.underTheMouse(const MouseX, MouseY: Double): boolean;
begin
  Result := Inherited;
end;

end.



