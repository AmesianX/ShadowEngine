// It's base class for views of objects. It's may be Sprite, Figure, Text and etc.
// It's only for rendering. It doesnt't know anything except Image where paint and object position

unit uE2DRendition;

interface

uses
  uSoTypes, uSoObject, uEngine2DClasses, uSoBasePart, uSoContainerTypes;

type
  TSoObjectFriend = class(TSoObject);

  TEngine2DRendition = class abstract(TSoBasePart)
  strict private
    FBringToBack, FSendToFront: TNotifyEvent;
    FOnDestroy: TNotifyEvent;
    procedure SetOpacity(const Value: Single);
  private
    procedure SetMargin(const Value: TPointF);
  protected
    FImage: TAnonImage;
    FOpacity: Single;
    FJustify: TObjectJustify;
    FMargin: TPointF;
    FFlip: Boolean;
    procedure SetJustify(const Value: TObjectJustify); virtual;
    function GetHeight: Single; virtual; abstract;
    function GetWidth: Single; virtual; abstract;
    procedure OnSubjectDestroy(ASender: TObject); override;
    procedure OnChangeScale(ASender: TObject);
  public
    property Justify: TObjectJustify read FJustify write SetJustify;
    property Opacity: Single read FOpacity write SetOpacity;
    property Margin: TPointF read FMargin write SetMargin;
    property OnBringToBack: TNotifyEvent read FBringToBack write FBringToBack;
    property OnSendToFront: TNotifyEvent read FSendToFront write FSendToFront;
    property Width: Single read GetWidth;
    property Height: Single read GetHeight;
    procedure BringToBack; // ������ ������ ������ � ������ ���������. �.�. ��������� �����
    procedure SendToFront; // ������ ������ ��������� � ������ ���������. �.�. ��������� ������
    procedure Repaint; virtual; abstract; // ��������� ��������� �������, �������������� �������� ��� ������� � �.�.

    constructor Create(const ASubject: TSoObject; const AImage: TAnonImage);
    destructor Destroy; override;
  end;

implementation

{ TEngine2DRendition }

procedure TEngine2DRendition.BringToBack;
begin
  FBringToBack(Self);
end;

constructor TEngine2DRendition.Create(const ASubject: TSoObject; const AImage: TAnonImage);
begin
  inherited Create(ASubject);
  FImage := AImage;
  FSubject.AddChangeScaleHandler(OnChangeScale);

  FMargin := TPointF.Zero;
end;

destructor TEngine2DRendition.Destroy;
begin
  if Assigned(FOnDestroy) then
    FOnDestroy(Self);

  FSubject.RemoveChangeScaleHandler(OnChangeScale);

  FImage := nil;
  FBringToBack := nil;
  FSendToFront := nil;
  inherited;
end;

procedure TEngine2DRendition.OnChangeScale(ASender: TObject);
begin

end;

procedure TEngine2DRendition.OnSubjectDestroy(ASender: TObject);
begin
  inherited;
  TSoObjectFriend(FSubject).FProperties.Remove('Width');//.AsDouble := Width;
  TSoObjectFriend(FSubject).FProperties.Remove('Height');//.AsDouble := Height;
end;

procedure TEngine2DRendition.SendToFront;
begin
  FSendToFront(Self);
end;

procedure TEngine2DRendition.SetJustify(const Value: TObjectJustify);
begin
  FJustify := Value;
end;

procedure TEngine2DRendition.SetMargin(const Value: TPointF);
begin
  FMargin := Value;
end;

procedure TEngine2DRendition.SetOpacity(const Value: Single);
begin
  FOpacity := Value;
end;

end.
