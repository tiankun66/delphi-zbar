program ZBar01;

uses
  Forms,
  fMain in 'fMain.pas' {FormZBar},
  ZBar in '..\lib\ZBar.pas',
  magick_wand in '..\lib\ImageMagick\wand\magick_wand.pas',
  ImageMagick in '..\lib\ImageMagick\magick\ImageMagick.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormZBar, FormZBar);
  Application.Run;
end.
