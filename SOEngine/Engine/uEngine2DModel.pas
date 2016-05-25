unit uEngine2DModel;

interface

uses
  System.Generics.Collections, System.SyncObjs,
  uEngine2DClasses, uSpriteList, uFastFields, uEngine2DAnimationList,
  uFormatterList, uEngine2DResources, uEngine2DObject;

type

TEngine2DModel = class
private
  FCritical: TCriticalSection;
  FObjects: TObjectsList; // ������ �������� ��� ���������
  FFastFields: TFastFields; // �������� ������ �� TFastField, ������� ������������ ����� ��������� �������� ������������ ��������
  FObjectOrder: TIntArray; // ������ ������� ���������. ����� ��� ���������� ���-�� ����������, �������� ����� �������
  FResources: TEngine2DResources; //tResourceArray; // ������ ��������
  FFormatters: TFormatterList; // ������ ����������� ��������
  FAnimationList: TEngine2DAnimationList; // ������ ��������
  procedure setObject(AIndex: integer; ASprite: tEngine2DObject);
  function getObject(AIndex: integer): tEngine2DObject;
public
  property Resources: TEngine2DResources read FResources;
  property AnimationList: TEngine2DAnimationList read FAnimationList;
  property FormatterList: TFormatterList read FFormatters;
  property ObjectList: TObjectsList read FObjects;
  property ObjectOrder: TIntArray read FObjectOrder;
  property FastFields: tFastFields read FFastFields; // ������� ����� ��� ������������
  property Objects[index: integer]: tEngine2DObject read getObject write setObject;
  constructor Create(const ACritical: TCriticalSection);
end;

implementation

{ TEngine2DModel }

constructor TEngine2DModel.Create(const ACritical: TCriticalSection);
begin
  FCritical := ACritical;
  FObjectOrder := TIntArray.Create(0);
  FResources := TEngine2DResources.Create(FCritical);
  FAnimationList := TEngine2DAnimationList.Create(FCritical);
  FFormatters := TFormatterList.Create(FCritical, Self);
  FObjects := TObjectsList.Create(FCritical);
end;

function TEngine2DModel.getObject(AIndex: integer): tEngine2DObject;
begin
  FCritical.Enter;
  result := FObjects[AIndex];
  FCritical.Leave;
end;

procedure TEngine2DModel.setObject(AIndex: integer; ASprite: tEngine2DObject);
begin
  FCritical.Enter;
  FObjects[AIndex] := ASprite;
  FCritical.Leave;
end;

end.
