unit uEngine2DAnimation;

interface

uses
  FMX.Graphics, System.Classes,
  uNamedList, uEngine2DClasses, uClasses, uIntersectorClasses, uEngine2DStatus;

type
  // ����� ������������ ������ DelayedCreate, �� �� ���������� �� �������
  // DelayedAnimation. DelayedCreate ��� �������� �������� ��� ������������
  // ����������� ��������� �������, �.�. ��� Setup'�. ��� ������������ �����
  // �������� ������ ��������� ���� ��������� ��������� ����� ������
  // ������������, �.�. �������� ���� ������ �������� ������� ��� Next,
  // �.�. ��������� �� �����-�� ���������.

  TAnimation = class
  strict private
    FSubject: Pointer; // ��������� �� ������ ��������
    FOnDeleteSubject: TNotifyEvent;
    FStatus: TEngine2DStatus;
    FNextAnimation: TAnimation;
    FSetupped: Boolean;
    FStopped: Boolean;
    FFinalized: Boolean;
    FStartPos: TPosition;
    FTimeTotal: Integer;
    FTimePassed: Double;
    FOnSetup: TProcedure;
    FOnDestroy: TProcedure;
    FOnFinalize: TProcedure;
    procedure SetSubject(const Value: Pointer);
   public
//    property Parent: Pointer read FParent write FParent;
    property OnDeleteSubject: TNotifyEvent read FOnDeleteSubject write FOnDeleteSubject;
    property Status: TEngine2DStatus read FStatus write FStatus;
//    property EngineFPS: TReturnSingleFunction read FEngineFPS write FEngineFPS;
    property Stopped: Boolean read FStopped write FStopped; // ���� �������� �����������, ��� ������ �� ������, ��� �������
    property Finalized: Boolean read FFinalized; // �������������� �� ��������
    property Subject: Pointer read FSubject write SetSubject;//GetSubject write
    property NextAnimation: TAnimation read FNextAnimation write FNextAnimation; // ��������, ������� ���������� ����� ����� ������
    property Setupped: Boolean read FSetupped;// write FSetupped; // ��� ���������� �������������
    property StartPosition: TPosition read FStartPos write FStartPos;
    property TimeTotal: Integer read FTimeTotal write FTimeTotal; // ����� � ��, ������� �������� ����� �������
    property TimePassed: Double read FTimePassed write FTimePassed; // ����� � ��, ������� �������� ��� ������
    property OnDestroy: TProcedure read FOnDestroy write FOnDestroy; // ��������� �� ����������� ��������
    property OnSetup: TProcedure read FOnSetup write FOnSetup; // ��������� �� ����� ��������
    property OnFinalize: TProcedure read FOnFinalize write FOnFinalize; // ��������� �� ����� ��������
    procedure RecoverStart; virtual; // ������ ����� ���������� ��� ������ ������ ClearForSubject � TAnimationList. �� ������ ��������� ��������� ������� � ����������.
    procedure Finalize; virtual; // ��� ������, ��� �������� ��������� ���� �������� ����� ��-�� ������� ���. ��� ���, ��� ��� ����, ����� ��������� �������� ����������
    function Animate: Byte; virtual; // ������� ������� �������. ����� True, �� ������ �������� ������� ���������

    function AddNextAnimation(AAnimation: TAnimation): Integer; // ��������� ��������� ��������, � ���� ��������� �������� ��� ����, �� ��������� ��������� �������� ��������� �������� � �.�. ������ ��������� ����� ��������� ��������
    procedure Setup; virtual;// ����� ��� ����������� ������. �� ���� ����� �������� ���������� ��������� ���������, �������� ��������� ���������
    procedure DeleteSubject;
    procedure HideSubject;
    constructor Create; virtual;
    destructor Destroy; override;
  const
    CDefaultTotalTime = 500; // ����� �� ��������, �� ���������. ���� ������ ������� �����������, �������� ��������������� � ���������� ����� Animate
    CAnimationEnd = 0; // ����� �������� ���������, ��� ��������� �� ������ ��������
    CAnimationInProcess = 1;  // ���� �������� �� �����������
    CNextAnimationInProcess = 2;  // ���� �������� �� �����������
  end;

implementation

uses
  uEngine2D, uEngine2DObject;

{ tEngine2DAnimation }

function TAnimation.AddNextAnimation(AAnimation: TAnimation): Integer;
begin
  Result := 0;
  if FNextAnimation = nil then
  begin
    FNextAnimation := AAnimation;
    Result := 1;
  end
  else
    Result := Result + FNextAnimation.AddNextAnimation(AAnimation);
end;

function tAnimation.Animate: Byte;
begin
  if FSetupped = False then
    Setup;

  Result := CAnimationInProcess;
  if TimePassed < TimeTotal then
  begin
    TimePassed := TimePassed + (1000 / FStatus.EngineFPS {vEngine.EngineThread.FPS});
    if TimePassed > TimeTotal then
      Result := CAnimationEnd;
  end else
  begin
    if FNextAnimation <> Nil then
    begin
      if not FFinalized then
        Finalize;
      Result := FNextAnimation.Animate;
      if Result <> CAnimationEnd then
        Result := CNextAnimationInProcess;
    end
    else begin
      if not FFinalized then
        Finalize;
      Result := CAnimationEnd;
    end;
  end;

end;

constructor tAnimation.Create;
begin
  FSetupped := False;
  FStopped := True; // �������� ��������� �������������, � ��������� ���� ������������� ������ ����� ���������� �������
  FFinalized := False;
  FTimeTotal := CDefaultTotalTime;
  FTimePassed := 0;
end;

{constructor tAnimation.DelayedCreate;
begin
  FSetupped := False;
  FStopped := True; // �������� ��������� �������������, � ��������� ���� ������������� ������ ����� ���������� �������
  FTimeTotal := CDefaultTotalTime;
  FTimePassed := 0;
end;   }

procedure TAnimation.DeleteSubject;
var
  vObj: tEngine2DObject;
begin
  vObj := FSubject;
  FOnDeleteSubject(vObj);
  vObj.Free;
end;

destructor tAnimation.Destroy;
begin
  if FNextAnimation <> Nil then
    FNextAnimation.Free;
  if Assigned(FOnDestroy) then
    FOnDestroy;
  inherited;
end;

procedure TAnimation.Finalize;
begin
  FFinalized := True;
  if Assigned(FOnFinalize) then
    FOnFinalize;
end;

procedure TAnimation.HideSubject;
begin
  TEngine2DObject(FSubject).Visible := False;
end;

procedure tAnimation.RecoverStart;
begin
  TEngine2DObject(FSubject).Position := FStartPos;
end;

procedure TAnimation.SetSubject(const Value: Pointer);
begin
  FSubject := Value;
  FStopped := False; //��������! ����� ������� ��������, �������� ��������� ���� �������������
//  FStartPos := tEngine2DObject(Value).Position;
end;

procedure tAnimation.Setup;
begin
  if Not Assigned(FSubject) then
    Exit;
  if Assigned(FOnSetup) then
    FOnSetup;
  FStartPos := TEngine2DObject(FSubject).Position;
  FSetupped := True;
end;

end.

