library id3reader;

{ Important note about DLL memory management: ShareMem must be the
  first unit in your library's USES clause AND your project's (select
  Project-View Source) USES clause if your DLL exports any procedures or
  functions that pass strings as parameters or function results. This
  applies to all strings passed to and from your DLL--even those that
  are nested in records and classes. ShareMem is the interface unit to
  the BORLNDMM.DLL shared memory manager, which must be deployed along
  with your DLL. To avoid using BORLNDMM.DLL, pass string information
  using PChar or ShortString parameters. }

{$DEFINE INSIDEDLL}

uses
  System.Types,
  Vcl.Graphics,
  Vcl.Imaging.jpeg,
  JvID3v2Base,
  JvId3v1,
  JvId3v2,
  JvGIF,
  id3reader.Shared in 'id3reader.Shared.pas';

var

  ID3v1: TJvID3v1;
  ID3v2: TJvID3v2;

{$R *.res}

procedure CreateID3Components;
begin
  if not Assigned(ID3v1) then
    ID3v1 := TJvID3v1.Create(nil);

  if not Assigned(ID3v2) then
    ID3v2 := TJvID3v2.Create(nil);
end;

procedure FreeID3Components;
begin
  if Assigned(ID3v1) then begin
    if ID3v1.Active then ID3v1.Active := False;
    ID3v1.Free;
    ID3v1 := nil;
  end;

  if Assigned(ID3v2) then begin
    if ID3v2.Active then ID3v2.Active := False;
    ID3v2.Free;
    ID3v2 := nil;
  end;
end;

function Min(const A, B: Integer): Integer;
begin
  if A < B then
    Result := A
  else
    Result := B;
end;

function ReadID3(pInfo: PID3Info): Boolean; export;
var
  Artist, Album, Title, FileName: String;
  Cover: TPicture;
  cdcCanvas: TCanvas;
  I: Integer;
  len: Integer;
begin
  Result := False;

  if pInfo = nil then exit;
  if pInfo^.sFileName = nil then exit;

  CreateID3Components;
  cdcCanvas := TCanvas.Create;
  try
    try
      FileName := pInfo^.sFileName;

      ID3v2.FileName := FileName;
      ID3v2.ProcessPictures := pInfo^.bReadCover;
      ID3v2.Active := True;

      //get infos

      Title := ID3v2.Texts.Title;

      Album := ID3v2.Texts.Album;

      for I := 0 to ID3v2.Texts.LeadArtist.Count - 1 do begin
        if I > 0 then Artist := Artist + ', ';
        Artist := Artist + ID3v2.Texts.LeadArtist.Strings[I];
      end;

      if Artist = '' then begin
        for I := 0 to ID3v2.Texts.Composer.Count - 1 do begin
          if I > 0 then Artist := Artist + ', ';
          Artist := Artist + ID3v2.Texts.Composer.Strings[I];
        end;
      end;

      Cover := ID3v2.Images.Pictures.CoverFront;

      if (Title = '') or (Album = '') or (Artist = '') then begin
        ID3v1.FileName := pInfo^.sFileName;
        ID3v1.Active := True;

        if Title = '' then
          Title := String(ID3v1.SongName);
        if Artist = '' then
          Artist := String(ID3v1.Artist);
        if Album = '' then
          Album := String(ID3v1.Album);
      end;

      //set

      if pInfo^.sTitle <> nil then begin
        len := Min(Length(Title) * SizeOf(Char), pInfo^.iTitleSize);
        pInfo^.iTitleSize := len;
        Move(Title[1], pInfo^.sTitle^, len);
      end;

      if pInfo^.sAlbum <> nil then begin
        len := Min(Length(Album) * SizeOf(Char), pInfo^.iAlbumSize);
        pInfo^.iAlbumSize := len;
        Move(Album[1], pInfo^.sAlbum^, len);
      end;

      if pInfo^.sArtist <> nil then begin
        len := Min(Length(Artist) * SizeOf(Char), pInfo^.iArtistSize);
        pInfo^.iArtistSize := len;
        Move(Artist[1], pInfo^.sArtist^, len);
      end;

      pInfo^.bHasCover := (Cover.Graphic <> nil);

      if (pInfo^.bHasCover) and (pInfo^.bReadCover) and (pInfo^.hCoverDC <> 0)
      and (pInfo^.iCoverWidth > 0) and (pInfo^.iCoverHeight > 0)  then begin
        cdcCanvas.Handle := pInfo^.hCoverDC;
        cdcCanvas.Lock;
        cdcCanvas.StretchDraw(Rect(0, 0, pInfo^.iCoverWidth, pInfo^.iCoverHeight), Cover.Graphic);
        cdcCanvas.Unlock;
        cdcCanvas.Handle := 0;
      end;

      Result := True;
    except
      Result := False;
    end;
  finally
    if Assigned(cdcCanvas) then
      cdcCanvas.Free;

    FreeID3Components;
  end;
end;

exports

  ReadID3;

begin
end.
