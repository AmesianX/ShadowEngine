#TXplatIniFile �N���X

���̃N���X�́A�v���b�g�t�H�[�����C�ɂ����� IniFile ���g�p������@��񋟂��܂��B  
���̃N���X���g���č���� IniFile �͉��L�̂悤�Ƀv���b�g�t�H�[���l�C�e�B�u�Ȍ`���ɂȂ�܂��B  

|Platform|Format          |
|--------|----------------|
|Windows |IniFile         |
|OS X    |plist           |
|iOS     |plist           |
|Android |SharedPreference|

##�t�@�C��

�ȉ��̃t�@�C����S�ă_�E�����[�h���܂��B

    FMX.IniFile.pas          �v���b�g�t�H�[���t���[�� IniFile �N���X
    FMX.IniFile.Apple.pas    OS X / iOS �p�� IniFile �N���X
    FMX.IniFile.Android.pas  Android �p�� IniFile �N���X

##�g�p���@

���L�̂悤�ɁA�ʏ�� TIniFile �Ɠ����悤�Ɏg���܂��B

```pascal
uses
  FMX.IniFile;

var
  IniFile: TXplatIniFile;
begin
  IniFile := CreateIniFile('��Ж�'); // ��Ж��� Windows �ł͕K�{�ł������v���b�g�t�H�[���ł͋󕶎��ō\���܂���
  IniFile.WriteString('�Z�N�V����', '�L�[��', '�������ޒl');
  IniFile.ReadString('�Z�N�V����', '�L�[��', '�f�t�H���g�l');
end;
```

##���m�̃o�O
OS X �� ReadSections ���g���� IniFile �̃Z�N�V�����ȊO�ɃV�X�e���̃p�����[�^���擾����܂��B

##���쌠
FMX.IniFile.Apple.pas �̓G���o�J�f���E�e�N�m���W�[�Y���񋟂��� Apple.IniFile.pas �����ɍ���Ă��܂��B  
���̂��߁AFMX.IniFile.Apple.pas �̒��쌠���܂��G���o�J�f���E�e�N�m���W�[�Y���ۗL���܂��B  
���̌��ʁAFMX.IniFile �� OS X / iOS �Ŏg�p���邽�߂ɂ́A������ Delphi/C++Builder/RAD Studio/AppMethod �̎g�p�҂Ŗ�����΂Ȃ�܂���B  
����ȊO�̃t�@�C���ɂ��ẮA���p�E�񏤗p�Ɋւ�炸���R�Ɏg�p���č\���܂���B  

�܂�ADelphi/C++Builder/RAD Studio/AppMethod �̎g�p�҂ł���Ε��ʂɎg���܂��B  

�Ȃ��A���쌠�͕������Ă��܂���B  
