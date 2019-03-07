unit Test.UI.FrmMain;

interface

uses
  id3reader.Shared,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Edit1: TEdit;
    PaintBox1: TPaintBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    procedure Button1Click(Sender: TObject);
  private
    Info: TID3Info;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
var
  PInfo: PID3Info;
  fileName, stitle, salbum, sartist: String;
  title, album, artist: TBytes;
begin
  PInfo := @Info;
  ZeroMemory(PInfo, SizeOf(Info));

  SetLength(title, 255);
  SetLength(artist, 255);
  SetLength(album, 255);

  fileName := Edit1.Text;

  PInfo^.sFileName := @fileName[1];
  PInfo^.sTitle := @title[0];
  PInfo^.sArtist := @artist[0];
  PInfo^.sAlbum := @album[0];
  PInfo^.iTitleSize := 255;
  PInfo^.iArtistSize := 255;
  PInfo^.iAlbumSize := 255;
  PInfo^.bReadCover := True;
  PInfo^.hCoverDC := PaintBox1.Canvas.Handle;
  PInfo^.iCoverWidth := PaintBox1.Width;
  PInfo^.iCoverHeight := PaintBox1.Height;

  if not id3reader.Shared.ReadID3(PInfo) then
    ShowMessage('Falha');

  SetLength(stitle, Info.iTitleSize div SizeOf(Char));
  SetLength(sartist, Info.iArtistSize div SizeOf(Char));
  SetLength(salbum, Info.iAlbumSize div SizeOf(Char));

  Move(title[0], stitle[1], Info.iTitleSize);
  Move(artist[0], sartist[1], Info.iArtistSize);
  Move(album[0], salbum[1], Info.iAlbumSize);

  Label1.Caption := stitle;
  Label2.Caption := sartist;
  Label3.Caption := salbum;
end;

end.
