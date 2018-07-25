uses crt, TerminalUserInput, sysutils, sgTypes;

type
	Mode = (NORMAL, PLAYLIST_ON);

type
	Genre = (Pop, Ballad, Country, Rock);
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

//*** Pointer ***

type
	Playlist = record
		nTracks: Integer;
		t: array[0..100] of Track;
	end;

type
	AppData = record
		nAlbs: 				Integer;
		alb: 					array[0..1000] of Album;
		nPls:					Integer;
		pl: 		array[0..1000] of Playlist;
		currentAlb: 	^Album;
		currentTrack: ^Track;
		currentPl: ^Playlist;
		m: MODE;
	end;


procedure CreateData(var dat: AppData);
var
	i, j, k: Integer;
	f: file of AppData;
begin
	dat.nAlbs:=ReadInteger('Please enter the number of albums:');
	for i:=0 to dat.nAlbs - 1 do
	begin
		WriteLn('Album number ', i+1);
		dat.alb[i].name					:=ReadString('Enter its name > ');
		dat.alb[i].artist				:=ReadString('Enter its artist > ');
		for j:=0 to Integer(High(Genre)) do
			WriteLn(j+1, '. ', Genre(j));
			k												:=ReadIntegerRange('Choose a number for its genre', 1, Integer(High(Genre))+1) - 1;
			dat.alb[i].kind					:=Genre(k);
			dat.alb[i].nTracks			:=ReadInteger('Enter the number of tracks within this album');

		WriteLn('Now its the time to enter the name of the tracks inside the album ', dat.alb[i].name);
		For j:=0 to (dat.alb[i].nTracks - 1) do
		begin
			dat.alb[i].t[j].name:=ReadString('Enter its name ');
			dat.alb[i].t[j].location:=ReadString('Enter its location ');
		for j:=0 to 1000 do
			dat.pl[j].nTracks:=0;
		end;
	end;
	dat.m:=NORMAL;
	dat.nPls:=0;
  dat.currentAlb:=nil;
	dat.currentTrack:=nil;
	dat.currentPl:=nil;
	WriteLn('Albums created');
	Assign(f, 'appData.dat');
	ReWrite(f);
	Write(f, dat);
	Close(f);
end;


procedure Main();
var
	dat: AppData;
begin
	CreateData(dat);
end;

begin
	Main();
end.
