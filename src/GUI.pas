// Introduction to Programming
// Task 6.3: GUI Music player
// ---------------------------
// This file contains the pascal source code which builds
// a Graphic User Interface (GUI) Music Player.
// The program allows users to play music and create their
// wanted playlist.
// The code uses Swingame library to a large extent.
// ---------------------------

program GUI;
uses crt, SysUtils, swinGame, sgAudio, sgTypes;

type
	Mode = (NORMAL, PLAYLIST_ON);

type
	Genre = (POP, BALLAD, COUNTRY, ROCK);
type
	Track = record
		name: String[255];
		location: String[255];
	end;

type
	Image = Record
		bmp: bitmap;
		pX: single;
		pY: single;
	end;

type
	Album = record
		name: String[255];
		artist: String[255];
		img: Image;
		kind: Genre;
		nTracks: Integer;
		t: array[0..14] of Track;
	end;

type
	Playlist = record
		nTracks: Integer;
		t: array[0..100] of Track;
		i: Integer;
	end;

type
	TrackPtr = ^Track;

type
	AlbumPtr = ^Album;

type
	PlaylistPtr = ^Playlist;

type
	AppData = record
		nAlbs: 				Integer;
		alb: 					array[0..100] of Album;
		nPls:					Integer;
		pl: 		array[0..100] of Playlist;
		currentAlb: 	^Album;
		currentTrack: ^Track;
		currentPl: ^Playlist;
		m: MODE;
	end;

procedure LoadApp(var dat: AppData);
var
  f: file of AppData;
  i, j: Integer;
begin
  assign(f, 'appData.dat');
	reset(f);
  read(f, dat);
	for i:=0 to dat.nAlbs - 1 do
	begin
		LoadBitmapNamed(dat.alb[i].name, dat.alb[i].name+'.png');
		for j:=0 to dat.alb[i].nTracks - 1 do
			LoadMusicNamed(dat.alb[i].t[j].name, dat.alb[i].t[j].name+'.wav');
	end;
	dat.m:=NORMAL;
	close(f);
end;

function IsOpened(const Ptr: Pointer): Boolean;
begin
	result:=False;
	if Ptr <> nil then
		result:=True;
end;

function ButtonClicked(btnX, btnY: Single; bthWidth, btnHeight : Integer): Boolean;
var
  x, y: Single;
  rightMost, downMost: Single;
begin
  x := MouseX();
  y := MouseY();
  rightMost := btnX + bthWidth;
  downMost := btnY + btnHeight;
  result := false;
  if MouseClicked(LeftButton)
    then if (x >= btnX) and (x <= rightMost) and (y >= btnY) and (y <= downMost)
        then result := true;
end;

procedure DrawImages(var a: array of Album; n: Integer);
var
	i: Integer;
begin
	For i:=0 to n - 1 do
	begin
		a[i].img.pX:= 10;
		a[i].img.pY:= 50 + 210*i;
		DrawBitmap(a[i].name, a[i].img.pX, a[i].img.pY);
	end;

end;

procedure DrawPlaylist(const n: Integer);
var
	i: Integer;
begin
	for i:=1 to n do
	begin
		FillRectangle(ColorGreen, 380, 95 + 30*i, 100, 25);
		DrawText('Playlist ' + IntToStr(i), ColorWhite, 'arial.ttf', 12, 400, 100 + 30*i);
	end;
end;

procedure DrawPanel(const a: Track);
begin
	If @a <> nil then
	begin
		FillRectangle(ColorRed, 300, 600, 680, 80);
		DrawText('Now Playing:', ColorWhite, 320, 620);
		DrawText(a.name, ColorWhite, 'arial.ttf', 15, 320, 640);
	end;
end;

procedure DrawTracks(const currentTrack: TrackPtr; const currentAlb: AlbumPtr; const currentPl: PlaylistPtr);
var
	i: Integer;
begin
	if IsOpened(currentAlb) then
	begin
		DrawText(currentAlb^.name, ColorWhite, 'arial.ttf', 12, 620, 50);
		for i:=0 to currentAlb^.NTracks - 1 do
		begin
			if (currentTrack = @(currentAlb^.t[i]))
				then FillRectangle(ColorRed, 600, 100 + 30*i, 300, 25)
				else FillRectangle(ColorBlue, 600, 100 + 30*i, 300, 25);
			DrawText(currentAlb^.t[i].name, ColorWhite, 620, 110 + 30*i);
			end;
	end
	else if IsOpened(currentPl) then
	begin
		DrawText('Playlist', ColorWhite, 'arial.ttf', 12, 620, 50);
		for i:=0 to currentPl^.Ntracks - 1 do
		begin
			if (currentTrack = @(currentPl^.t[i])) then FillRectangle(ColorRed, 600, 100 + 30*i, 300, 25)
			else FillRectangle(ColorBlue, 600, 100 + 30*i, 300, 25);
			DrawText(currentPl^.t[i].name, ColorWhite, 620, 110 + 30*i);
		end;
	end;
end;

Procedure DrawButton(const m: MODE);
begin
if m = NORMAL
then begin
	FillRectangle(ColorWhite, 900,0,50,50);
	DrawText('Create Playlist', ColorBlack, 'arial.ttf', 10, 905, 5);
end;
if m = PLAYLIST_ON
then begin
	FillRectangle(ColorGreen, 900,0,50,50);
	DrawText('Finished', ColorWhite, 'arial.ttf', 10, 905, 5);
end;
end;

procedure DrawApp(var dat: AppData);
var
	i: Integer;
begin
	ClearScreen(ColorBlack);
	DrawText('WELCOME TO THE GUI MUSIC PLAYER', ColorWhite, 'arial.ttf', 20, 0, 10);
	DrawButton(dat.m);
	DrawImages(dat.alb, dat.nAlbs);
	DrawTracks(dat.currentTrack, dat.currentAlb, dat.currentPl);
	DrawPanel(dat.currentTrack^);
	DrawPlaylist(dat.nPls);
	refreshScreen(60);
end;

procedure UpdateCurrentAlb(var currentAlb: AlbumPtr; const alb: array of Album; const n: Integer);
var
	i: Integer;
begin
for i:=0 to n - 1 do
	if ButtonClicked(alb[i].img.pX, alb[i].img.pY, BitmapWidth(BitmapNamed(alb[i].name)), BitmapHeight(BitmapNamed(alb[i].name)))
	then begin
		currentAlb:=@alb[i];
		break;
	end;
end;

procedure UpdateCurrentPlaylist(var currentPl: PlaylistPtr; const pl: array of Playlist; const n: Integer);
var
	i: Integer;
begin
	for i:=1 to n do
		if ButtonClicked(380, 95 + 30*i, 100, 25) then
		begin
			currentPl:=@pl[i];
			StopMusic();
			break;
		end;
end;

procedure UpdateCurrentTrack(var dat: AppData);
var
	i: Integer;
begin
	if IsOpened(dat.currentAlb) then
		for i:=0 to dat.currentAlb^.nTracks - 1 do
			if ButtonClicked(600, 100 + 30*i, 200, 25) then
			begin
				dat.currentTrack:=@dat.currentAlb^.t[i];
				StopMusic();
			end;
	if IsOpened(dat.currentPl) then
		for i:=0 to dat.currentPl^.nTracks - 1 do
			if ButtonClicked(600, 100 + 30*i, 200, 25) then
			begin
				dat.currentTrack:=@dat.currentPl^.t[i];
				StopMusic();
			end;

	if IsOpened(dat.currentPl) then
	begin
		if not MusicPlaying() then
		begin
			StopMusic();
			if dat.currentPl^.i < dat.currentPl^.nTracks - 1 then dat.currentPl^.i+=1
			else dat.currentPl^.i:=0;
		end;
		dat.currentTrack:=@dat.currentPl^.t[dat.currentPl^.i];
	end;

end;

procedure CreatePlaylist(var dat: AppData);
var
	i: Integer;
begin
	for i:=0 to dat.currentAlb^.nTracks - 1 do
		if ButtonClicked(600, 100 + 30*i, 200, 25) then
		begin
			dat.pl[dat.nPls].t[dat.pl[dat.nPls].nTracks]:=dat.currentAlb^.t[i];
			dat.pl[dat.nPls].nTracks+=1;
		end;
end;

procedure UpdateApp(var dat: AppData);
begin
	ProcessEvents();
	UpdateCurrentAlb(dat.currentAlb, dat.alb, dat.nAlbs);
	if IsOpened(dat.currentAlb) then dat.currentPl:= nil;

	UpdateCurrentPlaylist(dat.currentPl, dat.pl, dat.nPls);
	if IsOpened(dat.currentPl) then dat.currentAlb:= nil;

	if dat.m = NORMAL then UpdateCurrentTrack(dat);

	if ButtonClicked(900,0,50,50)  and (dat.m = NORMAL) then
	begin
		dat.m := PLAYLIST_ON;
		dat.nPls+=1;
	end

	else if (ButtonClicked(900,0,50,50)) and (dat.m = PLAYLIST_ON) then
		dat.m := NORMAL;

	if (dat.m = PLAYLIST_ON) then
	begin
		if not IsOpened(dat.currentAlb) and not IsOpened(dat.currentAlb) then
			dat.currentAlb:=@(dat.alb[0]);
		CreatePlaylist(dat);
	end;
end;

procedure PlaySound(const a: Track);
begin
	if (not MusicPlaying()) and (@a <> nil) then
		PlayMusic(musicNamed(a.name), 1);
end;

procedure Main();
var
  dat: AppData; //data
begin
	OpenAudio();
  OpenGraphicsWindow('GUI Music Player', 1000, 700);
  LoadApp(dat);
  repeat
    UpdateApp(dat);
		PlaySound(dat.currentTrack^);
    DrawApp(dat);
  until WindowCloseRequested();
	CloseAudio();
	ReleaseAllResources();
end;

begin
  Main();
end.
