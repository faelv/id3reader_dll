unit id3reader.Shared;

interface

type

  TID3Info = record
    sFileName: PChar;
    sTitle: Pointer;
    sArtist: Pointer;
    sAlbum: Pointer;
    iTitleSize: Integer;
    iArtistSize: Integer;
    iAlbumSize: Integer;
    bReadCover: Boolean;
    hCoverDC: THandle;
    iCoverWidth: Integer;
    iCoverHeight: Integer;
    bHasCover: Boolean;
  end;
  PID3Info = ^TID3Info;

  {$IFNDEF INSIDEDLL}
  function ReadID3(pInfo: PID3Info): Boolean; external 'id3reader.dll';
  {$ENDIF}

implementation

end.
