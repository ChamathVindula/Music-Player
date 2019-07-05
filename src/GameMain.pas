program GameMain;
uses SwinGame, sgImages, sysutils, sgTypes, sgText;

Type
	track = record
		trackName : String;
		trackLocation : String;
	end;

	album = record
		name : String;
		artist : String;
		albumArtThumb : String;
		albumArtBig : String;
		numberOfTracks : Integer;
		trackList : array of track; 	
	end;

	NowPlaying = record
		currentAlbum : String;
		currentTrack : String;
		currentTrackLocation : String;
	end;	

	albumArray = Array of album;

	playlist = Array [0..14] of string;

//Reads individual album details and returns records back to the ReadAlbums function	

function ReadAlbum(var albumFile : textFile):album;
var 
	trackAmount : String;
	trackCount : Integer;
begin
	ReadLn(albumFile,result.name);
	ReadLn(albumFile,result.artist);
	ReadLn(albumFile,result.albumArtThumb);
	ReadLn(albumFile,result.albumArtBig);
	ReadLn(albumFile,trackAmount);
	result.numberOfTracks := StrToInt(trackAmount);
	SetLength(result.trackList,result.numberOfTracks);
	for trackCount := 0 to (result.numberOfTracks-1) do
	begin
		ReadLn(albumFile,result.trackList[trackCount].trackName);
		ReadLn(albumFile,result.trackList[trackCount].trackLocation);
	end;

end;

//Reads all the album data from a text file on program start

function ReadAlbums(): albumArray;
var
	fileName, noOfAlbums : String;
	albumFile : textFile;
	count : Integer;
begin
	AssignFile(albumFile,'Resources/albums.dat');
	Reset(albumFile);
	ReadLn(albumFile, noOfAlbums);
	SetLength(result, StrToInt(noOfAlbums));
	for count := 0 to High(result) do
		result[count] := ReadAlbum(albumFile);
	Close(albumFile);	
end;

//Draws the background of any screen object upon procedure call with specified width, height, x and y coordinates

procedure DrawBackground(x,y,width,height : Integer);
begin
	FillRectangle(ColorCrimson,x,y,width,height);
end;

Procedure DrawNowPlayingAlbum(name : String);
begin
	DrawBackground(130,0,600,300);
	DrawBitmap(name,307,50);
	DrawText('Now Playing',ColorWhite,LoadFont('maven_pro_regular.ttf',30),350,10);
end;

Procedure DrawControlButtons();
begin
	DrawBackground(130,340,600,110);
	DrawBitmap('images/play.png',380,345);
	DrawBitmap('images/leftCopy.png',273,357);
	DrawBitmap('images/rightCopy.png',505,357);
	RefreshScreen();
end;	

Procedure DrawPlay();
begin
	DrawBitmap('images/play.png',380,345);	
end;

procedure DrawPause();
begin
	DrawBitmap('images/pause.png',380,345);
end;	

procedure DrawArrows();
begin
	DrawBitmap('images/left.jpg',10,490);
	DrawBitmap('images/right.jpg',799,490);
end;	

//Draws a single album cover art at a given location on screen

Procedure DrawAlbum(name : String; x, y : Integer);
begin
	DrawBitmap(name,x,y);
end;

Procedure DrawMenu();
begin
	DrawBackground(730,0,130,120);
	DrawBitmap('images/menu.png',750,30);
end;	

//Draw sets of of albums upon main window open and page change

Procedure DrawAlbumSetHorizontal(tempArray : albumArray; page : Integer);
var 
	spacing : Integer = 65;
	count : Integer;
begin
	case page of
		1 : count := 0;
		2 : count := 4;
		3 : count := 8;
	end;
	DrawBackground(0,450,860,300);	
	While (spacing <= 620) do
	begin
		DrawAlbum(tempArray[count].albumArtThumb,spacing,455);
		spacing += 185;
		count+= 1;
	end;
	DrawArrows();
	RefreshScreen();
end;

Procedure DrawVolume(y : Integer);
begin
	DrawBackground(730,120,130,330);
	DrawBitmap('images/volume.png',773,360);
	DrawBitmap('images/volumebar.png',780,170);
	DrawBitmap('images/volumeknob.png',790,y);
	DrawBitmap('images/updown.jpg',785,314);
end;	

//Draw sets of of albums upon second screen open and album page change

Procedure DrawShuffleOn();
begin
	DrawBackground(0,0,130,450);
	DrawBitmap('images/shuffleon.png',30,360);
end;	

Procedure DrawShuffleOff();
begin
	DrawBackground(0,0,130,450);
	DrawBitmap('images/shuffleoff.png',30,360);
end;

Procedure DrawNowPlayingName(currentMusic : NowPlaying);
var 
	rect : Rectangle;	
begin
	rect.x := 130;
	rect.y := 310;
	rect.width := 600;
	rect.height := 40; 
	DrawBackground(130,300,600,40);
	DrawText(currentMusic.currentTrack,ColorWhite,ColorCrimson,LoadFont('maven_pro_regular.ttf',25),TextAlignmentFrom('c'),rect);
	ReleaseAllFonts();
	RefreshScreen();
end;

Procedure DrawStartScreen(mainAlbumArray : albumArray; currentMusic : NowPlaying);
begin
	DrawAlbumSetHorizontal(mainAlbumArray,1);
	DrawControlButtons();
	DrawVolume(180);
	DrawNowPlayingAlbum(mainAlbumArray[0].albumArtBig);
	DrawMenu();
	DrawShuffleOn();
	DrawNowPlayingName(currentMusic);
end;

Procedure InitializeCurrentMusic(mainAlbumArray : albumArray; var currentMusic : NowPlaying);
begin
	currentMusic.currentAlbum := mainAlbumArray[0].name;
	currentMusic.currentTrack := mainAlbumArray[0].trackList[0].trackName;
	currentMusic.currentTrackLocation := mainAlbumArray[0].trackList[0].trackLocation; 
end;

function AreaClicked(areaXPosition, areaYPosition: Single; areaWidth, areaHeight: Integer): Boolean;
var
	mouseXPosition, mouseYPosition, areaXLimit, areaYLimit : Single;
begin
	mouseXPosition := MouseX();
	mouseYPosition := MouseY();
	areaXLimit := areaXPosition + areaWidth;
	areaYLimit := areaYPosition + areaHeight;
	result := false;			
	if MouseClicked(leftButton) then
	begin
		if (mouseXPosition >= areaXPosition) and (mouseXPosition <= areaXLimit) then
		begin
			if (mouseYPosition >= areaYPosition) and (mouseYPosition <= areaYLimit) then
			begin
				result := true;
			end;
		end;
	end;				
end;

procedure Play(var initial: Boolean; mainAlbumArray: albumArray; musicPlayingNow: Boolean);
var
	count : Integer;
begin
	if (initial) then
	begin
		if ((AreaClicked(380,345,100,100)) or (KeyTyped(SpaceKey))) then
		begin
			initial := false;
			musicPlayingNow := true;
			for count := 0 to mainAlbumArray[0].numberOfTracks-1 do
			begin
		 		LoadMusic(mainAlbumArray[0].trackList[count].trackLocation);
		 	end;	
			PlayMusic(mainAlbumArray[0].trackList[0].trackLocation,0);
			DrawBitmap('images/pause.png',380,345);
			RefreshScreen();
		end;
	end;
end;	

Procedure PausePlay(var musicPlayingNow: Boolean; initial:Boolean);
begin
	if (not initial) then
	begin
		if ((AreaClicked(380,345,100,100)) or (KeyTyped(SpaceKey))) then
		begin  
			if (musicPlayingNow) then
			begin	
				PauseMusic();
				DrawPlay();
				musicPlayingNow := false;	
			end
			else
			begin
				ResumeMusic();
				DrawPause();
				musicPlayingNow := true;
			end;
		end;	
		RefreshScreen();
	end;		
end;	

function findAlbumArtBig(mainAlbumArray: albumArray; currentMusic: NowPlaying): String;
var
	condition : Boolean = true;
	count1 : Integer = 0;
begin
	result := '';
	while (condition) do
	begin
		if (mainAlbumArray[count1].name = currentMusic.currentAlbum) then
		begin	
			condition := false;
			result := mainAlbumArray[count1].albumArtBig;
		end	
		else
			count1 += 1;
	end;
end;

function findAlbumArtThumb(mainAlbumArray: albumArray; currentMusic: NowPlaying): String;
var
	condition : Boolean = true;
	count1 : Integer = 0;
begin
	result := '';
	while (condition) do
	begin
		if (mainAlbumArray[count1].name = currentMusic.currentAlbum) then
		begin	
			condition := false;
			result := mainAlbumArray[count1].albumArtThumb;
		end	
		else
			count1 += 1;
	end;
end;

Procedure NextTrack(var currentMusic: NowPlaying;  mainAlbumArray: albumArray; initial: Boolean; var AlbumPage: Integer; musicPlayingNow: Boolean);
var 
	condition : Boolean = true;
	count1 : Integer = 0;
	count2 : Integer = 0;
begin
	if (not initial) then
	begin
		if ((AreaClicked(505,357,80,80)) or (KeyTyped(RightKey))) then
		begin
			if (musicPlayingNow) then
			begin
				while (condition) do
				begin
					if (mainAlbumArray[count1].name = currentMusic.currentAlbum) then
						condition := false
					else
						count1 += 1;
				end;
				condition := true;
				While (condition) do
				begin
					if (mainAlbumArray[count1].trackList[count2].trackName = currentMusic.currentTrack) then
						condition := false
					else
						count2 += 1;
				end;			
				if (not ((count1 = 11) and (count2 = 11))) then
				begin
					if (not (count2 = 11)) then
					begin
						PlayMusic(mainAlbumArray[count1].trackList[count2+1].trackLocation,0);
						currentMusic.currentAlbum := mainAlbumArray[count1].name;
						currentMusic.currentTrack := mainAlbumArray[count1].trackList[count2+1].trackName;
						currentMusic.currentTrackLocation := mainAlbumArray[count1].trackList[count2+1].trackLocation;
						DrawNowPlayingName(currentMusic);
					end
					else
					begin
						PlayMusic(mainAlbumArray[count1+1].trackList[0].trackLocation,0);
						currentMusic.currentAlbum := mainAlbumArray[count1+1].name;
						currentMusic.currentTrack := mainAlbumArray[count1+1].trackList[0].trackName;
						currentMusic.currentTrackLocation := mainAlbumArray[count1+1].trackList[0].trackLocation;
						DrawNowPlayingName(currentMusic);
						DrawNowPlayingAlbum(findAlbumArtBig(mainAlbumArray,currentMusic));
						if (count1 = 3) then
						begin
							AlbumPage := 2;
							DrawAlbumSetHorizontal(mainAlbumArray,AlbumPage);
						end
						else if (count1 = 7) then
						begin
							AlbumPage := 3;
							DrawAlbumSetHorizontal(mainAlbumArray,AlbumPage);
						end;
					end;	
				end;
			end;		
		end;
	end;	
end;

Procedure PreviousTrack(var currentMusic: NowPlaying;  mainAlbumArray: albumArray; var AlbumPage: Integer; initial: Boolean; musicPlayingNow: Boolean);
var 
	condition : Boolean = true;
	count1 : Integer = 0;
	count2 : Integer = 0;
begin
	if (not initial) then
	begin
		if ((AreaClicked(273,357,80,80)) or (KeyTyped(LeftKey))) then
		begin
			if (musicPlayingNow) then
			begin
				while (condition) do
				begin
					if (mainAlbumArray[count1].name = currentMusic.currentAlbum) then
						condition := false
					else
						count1 += 1;
				end;
				condition := true;
				While (condition) do
				begin
					if (mainAlbumArray[count1].trackList[count2].trackName = currentMusic.currentTrack) then
						condition := false
					else
						count2 += 1;
				end;
				if (not ((count1 = 0) and (count2 = 0))) then
				begin
					if (not (count2 = 0)) then
					begin			
						PlayMusic(mainAlbumArray[count1].trackList[count2-1].trackLocation,0);
						currentMusic.currentAlbum := mainAlbumArray[count1].name;
						currentMusic.currentTrack := mainAlbumArray[count1].trackList[count2-1].trackName;
						currentMusic.currentTrackLocation := mainAlbumArray[count1].trackList[count2-1].trackLocation;
						DrawNowPlayingName(currentMusic);
					end
					else
					begin
						PlayMusic(mainAlbumArray[count1-1].trackList[11].trackLocation,0);
						currentMusic.currentAlbum := mainAlbumArray[count1-1].name;
						currentMusic.currentTrack := mainAlbumArray[count1-1].trackList[11].trackName;
						currentMusic.currentTrackLocation := mainAlbumArray[count1-1].trackList[11].trackLocation;
						DrawNowPlayingName(currentMusic);
						DrawNowPlayingAlbum(findAlbumArtBig(mainAlbumArray,currentMusic));
						if (count1 = 8) then
						begin
							AlbumPage := 2;
							DrawAlbumSetHorizontal(mainAlbumArray,AlbumPage);
						end
						else if (count1 = 4) then
						begin
							AlbumPage := 1;
							DrawAlbumSetHorizontal(mainAlbumArray,AlbumPage);
						end;
					end;		
				end;
			end;	
		end;
	end;	
end;

procedure PreviousAlbumSet(var AlbumPage : Integer; mainAlbumArray: albumArray);
begin
	if(AreaClicked(10,490,51,101)) then
	begin
		case AlbumPage of
			2 : AlbumPage -= 1;
			3 : AlbumPage -= 1;
		end;
		DrawAlbumSetHorizontal(mainAlbumArray,AlbumPage);	
	end;

end;

procedure NextAlbumSet(var AlbumPage : Integer; mainAlbumArray: albumArray);
begin
	if(AreaClicked(799,490,51,101)) then
	begin
		case AlbumPage of
			1 : AlbumPage += 1;
			2 : AlbumPage += 1;
		end;
		DrawAlbumSetHorizontal(mainAlbumArray,AlbumPage);	
	end;	
end;

Procedure playAlbum(mainAlbumArray: albumArray; var currentMusic: NowPlaying; tempValue: Integer; var musicPlayingNow: Boolean);
begin
	if (musicPlayingNow) then
	begin
		currentMusic.currentAlbum := mainAlbumArray[tempValue].name;
		currentMusic.currentTrack := mainAlbumArray[tempValue].trackList[0].trackName;		
		currentMusic.currentTrackLocation := mainAlbumArray[tempValue].trackList[0].trackLocation;
		PlayMusic(currentMusic.currentTrackLocation,0);
		DrawNowPlayingName(currentMusic);
		DrawNowPlayingAlbum(mainAlbumArray[tempValue].albumArtBig);
		RefreshScreen();
	end
	else
		currentMusic.currentAlbum := mainAlbumArray[tempValue].name;
		currentMusic.currentTrack := mainAlbumArray[tempValue].trackList[0].trackName;
		currentMusic.currentTrackLocation := mainAlbumArray[tempValue].trackList[0].trackLocation;
		PlayMusic(currentMusic.currentTrackLocation,0);
		DrawNowPlayingName(currentMusic);
		DrawNowPlayingAlbum(mainAlbumArray[tempValue].albumArtBig);
		DrawPause();
		RefreshScreen();
		musicPlayingNow := true;		
end;	

Procedure playAlbum1(mainAlbumArray: albumArray; var currentMusic: NowPlaying; AlbumPage: Integer; var musicPlayingNow: Boolean);
begin
	if (AlbumPage = 1) then
	begin
		playAlbum(mainAlbumArray,currentMusic,0,musicPlayingNow);
	end
	else if (AlbumPage =2) then
	begin
		playAlbum(mainAlbumArray,currentMusic,4,musicPlayingNow);
	end
	else if (AlbumPage = 3) then
	begin
		playAlbum(mainAlbumArray,currentMusic,8,musicPlayingNow);
	end;
end;

Procedure playAlbum2(mainAlbumArray: albumArray; var currentMusic: NowPlaying; AlbumPage: Integer; var musicPlayingNow: Boolean);
begin
	if (AlbumPage = 1) then
	begin
		playAlbum(mainAlbumArray,currentMusic,1,musicPlayingNow);
	end
	else if (AlbumPage =2) then
	begin
		playAlbum(mainAlbumArray,currentMusic,5,musicPlayingNow);
	end
	else if (AlbumPage = 3) then
	begin
		playAlbum(mainAlbumArray,currentMusic,9,musicPlayingNow);
	end;

end;

Procedure playAlbum3(mainAlbumArray: albumArray; var currentMusic: NowPlaying; AlbumPage: Integer; var musicPlayingNow: Boolean);
begin
	if (AlbumPage = 1) then
	begin
		playAlbum(mainAlbumArray,currentMusic,2,musicPlayingNow);
	end
	else if (AlbumPage =2) then
	begin
		playAlbum(mainAlbumArray,currentMusic,6,musicPlayingNow);
	end
	else if (AlbumPage = 3) then
	begin
		playAlbum(mainAlbumArray,currentMusic,10,musicPlayingNow);
	end;
end;

Procedure playAlbum4(mainAlbumArray: albumArray; var currentMusic: NowPlaying; AlbumPage: Integer; var musicPlayingNow: Boolean);
begin
	if (AlbumPage = 1) then
	begin
		playAlbum(mainAlbumArray,currentMusic,3,musicPlayingNow);
	end
	else if (AlbumPage =2) then
	begin
		playAlbum(mainAlbumArray,currentMusic,7,musicPlayingNow);
	end
	else if (AlbumPage = 3) then
	begin
		playAlbum(mainAlbumArray,currentMusic,11,musicPlayingNow);
	end;					
end;

Procedure PlayRelativeAlbum(albumNumber: Integer; mainAlbumArray: albumArray; var currentMusic: NowPlaying; AlbumPage: Integer; var musicPlayingNow: Boolean);
begin
	case albumNumber of
		1 : playAlbum1(mainAlbumArray,currentMusic,AlbumPage,musicPlayingNow);  
		2 : playAlbum2(mainAlbumArray,currentMusic,AlbumPage,musicPlayingNow);
		3 :	playAlbum3(mainAlbumArray,currentMusic,AlbumPage,musicPlayingNow);
		4 :	playAlbum4(mainAlbumArray,currentMusic,AlbumPage,musicPlayingNow);
	end;	
end;

procedure MainWindowAlbumSelect(mainAlbumArray: albumArray; var currentMusic: NowPlaying; AlbumPage: Integer; initial: Boolean; var musicPlayingNow: Boolean);
var
	albumNumber : Integer; 	
begin
	if (not initial) then
	begin
		if (AreaClicked(65,450,175,175)) then
		begin
			albumNumber := 1;
		end;
		if (AreaClicked(250,450,175,175)) then
		begin
			albumNumber := 2;
		end;
		if (AreaClicked(435,450,175,175)) then
		begin
			albumNumber := 3;
		end;
		if (AreaClicked(620,450,175,175)) then
		begin
			albumNumber := 4;
		end;
		PlayRelativeAlbum(albumNumber,mainAlbumArray,currentMusic,AlbumPage,musicPlayingNow);
	end;	
end;	

procedure DrawGrid(mainAlbumArray: albumArray; currentMusic: NowPlaying);
var
	condition : Boolean = true; 
	count1 : Integer = 0;
	count2 : Integer = 0;
	x : Integer = 205;
begin
	DrawBackground(0,0,400,650);
	DrawBitmap(findAlbumArtThumb(mainAlbumArray,currentMusic),20,20);
	DrawBitmap('images/up.jpg',200,50);
	DrawBitmap('images/down.jpg',202,112);
	while (condition) do
	begin
		if (mainAlbumArray[count1].name = currentMusic.currentAlbum) then
			condition := false
		else
			count1 += 1;
	end;		
	while (count2 < mainAlbumArray[count1].numberOfTracks) do
	begin
		if (mainAlbumArray[count1].trackList[count2].trackName = currentMusic.currentTrack) then
		begin
			DrawText(mainAlbumArray[count1].trackList[count2].trackName,ColorBlack,LoadFont('maven_pro_regular.ttf',22),20,x);
			count2 += 1;
			x+= 35;
		end
		else
		begin
			DrawText(mainAlbumArray[count1].trackList[count2].trackName,ColorWhite,LoadFont('maven_pro_regular.ttf',22),20,x);
			count2 += 1;
			x += 35;
		end;	
	end;	
	RefreshScreen();
end;

Procedure PlayNextTrack(mainAlbumArray: albumArray; var currentMusic: NowPlaying; initial: Boolean; mainWindow: Boolean);
var
	condition: Boolean = true;
	count1 : Integer = 0;
	count2 : Integer = 0;	
begin
	If (not initial) then
	begin
		if (not MusicPlaying()) then
		begin
			While (condition) do
			begin
				if (mainAlbumArray[count1].name = currentMusic.currentAlbum) then
					condition := false
				else
					count1 += 1;
			end;
			condition := true;
			while (condition) do 
			begin
				if (mainAlbumArray[count1].trackList[count2].trackName = currentMusic.currentTrack) then
				begin
					condition := false;
					PlayMusic(mainAlbumArray[count1].trackList[count2+1].trackLocation,0);
					currentMusic.currentAlbum := mainAlbumArray[count1].name;
					currentMusic.currentTrack := mainAlbumArray[count1].trackList[count2+1].trackName;
					currentMusic.currentTrackLocation := mainAlbumArray[count1].trackList[count2+1].trackLocation;
					if (mainWindow) then
						DrawNowPlayingName(currentMusic)
					else 
					begin
						DrawGrid(mainAlbumArray,currentMusic);
						RefreshScreen();
					end;		
				end
				else
					count2 += 1;
			end;
		end;
	end;
end;

Procedure ChangeVolume(var volumeLimit: Integer; var volumeLevel: Single);
var
	MouseYPosition, MouseXPosition : Single;
	ButtonYLimit, difference : Single;
	button1UpperLimit :Integer = 317;
	button1LowerLimit :Integer = 332;
	button2UpperLimit :Integer = 333;
	button2LowerLimit :Integer = 348;
begin
	MouseXPosition := MouseX();
	MouseYPosition := MouseY();
	volumeLevel := MusicVolume();
	if ((MouseDown(leftButton) and (MouseYPosition > button1UpperLimit) and (MouseYPosition < button1LowerLimit) and (MouseXPosition > 785) and (MouseXPosition < 815)) or KeyDown(UpKey)) then
	begin
		if (not (volumeLevel = 1)) then
		begin
			volumeLevel += 0.05;
			SetMusicVolume(volumeLevel);
		end;	
		if (volumeLimit > 180) then
		begin
			volumeLimit -= 5;
			DrawVolume(volumeLimit);
			RefreshScreen();
		end;	
	end;
	if ((MouseDown(leftButton) and (MouseYPosition > button2UpperLimit) and (MouseYPosition < button2LowerLimit) and (MouseXPosition > 785) and (MouseXPosition < 815)) or KeyDown(DownKey)) then
	begin
		if (not (volumeLevel = 0)) then
		begin
			volumeLevel -= 0.05;
			SetMusicVolume(volumeLevel);
		end;	
		if (volumeLimit < 280) then
		begin
			volumeLimit += 5;
			DrawVolume(volumeLimit);
			RefreshScreen();
		end;	
	end;
end;

procedure checkMenuClick(var mainWindow: Boolean);
begin
	if (AreaClicked(750,30,100,66) or KeyTyped(MKey)) then
		mainWindow := false;
end;

Procedure ShuffleMusic(mainAlbumArray: albumArray; var currentMusic: NowPlaying; initial: Boolean; musicPlayingNow: Boolean; var AlbumPage: Integer);
var
	X, Y : Integer;
begin
	if ((AreaClicked(30,360,70,70)) or (KeyTyped(SKey)))then
	begin
		if (not initial) then
		begin
			if (musicPlayingNow) then
			begin
				StopMusic();
				DrawShuffleOff();
				X := Random(12);
				Y := Random(12);
				if (not MusicPlaying()) then
				begin
					currentMusic.currentAlbum := mainAlbumArray[X].name;
					currentMusic.currentTrack := mainAlbumArray[X].trackList[Y].trackName;		
					currentMusic.currentTrackLocation := mainAlbumArray[X].trackList[Y].trackLocation;
					PlayMusic(currentMusic.currentTrackLocation,0);
					DrawNowPlayingName(currentMusic);
					DrawNowPlayingAlbum(mainAlbumArray[X].albumArtBig);
					DrawShuffleOn();
					RefreshScreen();
					if ((X = 0) or (X = 1) or (X = 2) or (X = 3)) then
					begin
						AlbumPage := 1;
						DrawAlbumSetHorizontal(mainAlbumArray,AlbumPage);
					end;
					if ((X = 4) or (X = 5) or (X = 6) or (X = 7)) then
					begin
						AlbumPage := 2;
						DrawAlbumSetHorizontal(mainAlbumArray,AlbumPage);
					end;
					if ((X = 8) or (X = 9) or (X = 10) or (X = 11)) then
					begin
						AlbumPage := 3;
						DrawAlbumSetHorizontal(mainAlbumArray,AlbumPage);
					end;
					RefreshScreen();	
				end;		
			end;
		end;
	end;	
end;

procedure PlaylistNextTrack(newPlaylist: playlist; newPlaylistNames: playlist; newPlaylistAlbums: playlist; var currentMusic: NowPlaying; musicPlayingNow: Boolean; mainAlbumArray: albumArray);
var 
	val : Integer = 0;
	condition : Boolean = true;
begin
	if ((AreaClicked(505,357,80,80))) then
	begin
		if (musicPlayingNow) then
		begin	
			while (condition) do
			begin
				if (currentMusic.currentTrackLocation = newPlaylist[val]) then
					condition := false
				else
					val += 1;
			end;		
			if (not (val = 14)) then
			begin	
				PlayMusic(newPlaylist[val+1]);
				currentMusic.currentAlbum := newPlaylistAlbums[val+1];
				currentMusic.currentTrack := newPlaylistNames[val+1];
				currentMusic.currentTrackLocation := newPlaylist[val+1];
				DrawNowPlayingName(currentMusic);
				DrawNowPlayingAlbum(findAlbumArtBig(mainAlbumArray,currentMusic));	
			end;
		end;
	end;		 
end;	

procedure PlaylistPreviousTrack(newPlaylist: playlist; newPlaylistNames: playlist; newPlaylistAlbums: playlist; var currentMusic: NowPlaying; musicPlayingNow: Boolean; mainAlbumArray: albumArray);
var 
	val : Integer = 0;
	condition : Boolean = true;
begin
	if ((AreaClicked(273,357,80,80))) then
	begin
		if (musicPlayingNow) then
		begin	
			while (condition) do
			begin
				if (currentMusic.currentTrackLocation = newPlaylist[val]) then
					condition := false
				else
					val += 1;
			end;		
			if (not (val = 0)) then
			begin	
				PlayMusic(newPlaylist[val-1]);
				currentMusic.currentAlbum := newPlaylistAlbums[val-1];
				currentMusic.currentTrack := newPlaylistNames[val-1];
				currentMusic.currentTrackLocation := newPlaylist[val-1];
				DrawNowPlayingName(currentMusic);
				DrawNowPlayingAlbum(findAlbumArtBig(mainAlbumArray,currentMusic));	
			end;
		end;
	end;		 
end;

procedure CheckForMainWindowClicks(var mainWindow: Boolean; var initial: Boolean; var currentMusic: NowPlaying; mainAlbumArray: albumArray; var musicPlayingNow: Boolean; var AlbumPage: Integer; var volumeLimit: Integer; var volumeLevel: Single; playlistPlaying: Boolean; newPlaylist: playlist; newPlaylistNames: playlist; newPlaylistAlbums: playlist);
begin
	while (playlistPlaying and (mainWindow)) do
	begin
		ProcessEvents();
		ChangeVolume(volumeLimit,volumeLevel);
		checkMenuClick(mainWindow);
		NextAlbumSet(AlbumPage,mainAlbumArray);
		PreviousAlbumSet(AlbumPage,mainAlbumArray);
		PausePlay(musicPlayingNow,initial);
		PlaylistNextTrack(newPlaylist,newPlaylistNames,newPlaylistAlbums,currentMusic,musicPlayingNow,mainAlbumArray);
		PlaylistPreviousTrack(newPlaylist,newPlaylistNames,newPlaylistAlbums,currentMusic,musicPlayingNow,mainAlbumArray);
	end;
	While (mainWindow and (not playlistPlaying)) do
	begin
		ProcessEvents();	
		Play(initial, mainAlbumArray, musicPlayingNow);
		PausePlay(musicPlayingNow,initial);
		NextTrack(currentMusic,mainAlbumArray,initial,AlbumPage,musicPlayingNow);
		PreviousTrack(currentMusic,mainAlbumArray,AlbumPage,initial,musicPlayingNow);
		NextAlbumSet(AlbumPage,mainAlbumArray);
		PreviousAlbumSet(AlbumPage,mainAlbumArray);
		PlayNextTrack(mainAlbumArray,currentMusic,initial,mainWindow);
		MainWindowAlbumSelect(mainAlbumArray,currentMusic,AlbumPage,initial,musicPlayingNow);
		ChangeVolume(volumeLimit,volumeLevel);
		checkMenuClick(mainWindow);
		ShuffleMusic(mainAlbumArray,currentMusic,initial,musicPlayingNow,AlbumPage);
	end;
end;

procedure RefreshMainScreen(mainAlbumArray: albumArray; currentMusic: NowPlaying; musicPlayingNow: Boolean; AlbumPage: Integer; volumeLimit: Integer);
begin
	if (musicPlayingNow) then
	begin
		DrawControlButtons();
		DrawPause();
	end
	else 
		DrawControlButtons();
	DrawShuffleOn();
	DrawArrows();
	DrawVolume(volumeLimit);
	DrawMenu();
	DrawNowPlayingAlbum(findAlbumArtBig(mainAlbumArray,currentMusic));
	DrawNowPlayingName(currentMusic);
	DrawAlbumSetHorizontal(mainAlbumArray,AlbumPage);	
end;

procedure DrawAlbumUp(mainAlbumArray: albumArray; var currAlbum: Integer; currentMusic: NowPlaying);
var 
	count : Integer = 0;
	x : Integer = 205;
begin
	if (not(currAlbum = 0)) then
	begin
		currAlbum -= 1;
		DrawBackground(0,0,400,650);
		DrawBitmap('images/up.jpg',200,50);
		DrawBitmap('images/down.jpg',202,112);
		DrawBitmap(mainAlbumArray[currAlbum].albumArtThumb,20,20);
		while (count < mainAlbumArray[currAlbum].numberOfTracks) do
		begin
			if (mainAlbumArray[currAlbum].trackList[count].trackName = currentMusic.currentTrack) then
			begin
				DrawText(mainAlbumArray[currAlbum].trackList[count].trackName,ColorBlack,LoadFont('maven_pro_regular.ttf',22),20,x);
				count += 1;
				x += 35;
			end
			else
			begin
				DrawText(mainAlbumArray[currAlbum].trackList[count].trackName,ColorWhite,LoadFont('maven_pro_regular.ttf',22),20,x);
				count += 1;
				x += 35;
			end;	
		end;	
	end;
	RefreshScreen();
end;

procedure DrawAlbumDown(mainAlbumArray: albumArray; var currAlbum: Integer; currentMusic: NowPlaying);
var 
	count : Integer = 0;
	x : Integer = 205;
begin
	if (not(currAlbum = 11)) then
	begin
		currAlbum += 1;
		DrawBackground(0,0,400,650);
		DrawBitmap('images/up.jpg',200,50);
		DrawBitmap('images/down.jpg',202,112);
		DrawBitmap(mainAlbumArray[currAlbum].albumArtThumb,20,20);
		while (count < mainAlbumArray[currAlbum].numberOfTracks) do
		begin
			if (mainAlbumArray[currAlbum].trackList[count].trackName = currentMusic.currentTrack) then
			begin
				DrawText(mainAlbumArray[currAlbum].trackList[count].trackName,ColorBlack,LoadFont('maven_pro_regular.ttf',22),20,x);
				count += 1;
				x += 35;
			end
			else
			begin
				DrawText(mainAlbumArray[currAlbum].trackList[count].trackName,ColorWhite,LoadFont('maven_pro_regular.ttf',22),20,x);
				count += 1;
				x += 35;
			end;	
		end;	
	end;
	RefreshScreen();
end;

procedure DrawButton();
begin
	FillRectangle(ColorWhite,485,30,175,40);
	DrawText('Create Playlist',ColorCrimson,LoadFont('maven_pro_regular.ttf',25),490,35);
	FillRectangle(ColorWhite,485,90,172,40);
	DrawText('Erase Playlist',ColorCrimson,LoadFont('maven_pro_regular.ttf',25),495,95);
end;

procedure DrawPlaylistGrid();
var
	height : Integer = 145;
	count : Integer;
begin
	DrawBackground(398,145,352,650);
	for count := 1 to 15 do
	begin
		DrawRectangle(ColorWhite,400,height,350,32);
		height += 32;
	end;
	RefreshScreen();
end;

procedure EraseGrid(var playlistCreated: Boolean; var playlistPlaying: Boolean);
begin
	DrawBackground(398,145,352,650);
	DrawBackground(760,580,88,45);
	playlistCreated := false;
	playlistPlaying := false;
	RefreshScreen();
end;

procedure WriteTrackName(trackName: string; height: Integer);
begin
	DrawText(trackName,ColorWhite,LoadFont('maven_pro_regular.ttf',22),405,height);
	RefreshScreen();
end;	

procedure SelectTracks(mainAlbumArray: albumArray; var newPlaylist: playlist; var newPlaylistNames: playlist; var currAlbum: Integer; var playlistCreated: Boolean; var newPlaylistAlbums: playlist; var playlistPlaying: Boolean; currentMusic: NowPlaying);
var 
	count : Integer = 0;
	height : Integer = 154;
begin
	While (count < 15) do
	begin
		ProcessEvents();
		if AreaClicked(200,50,100,51) then
				DrawAlbumUp(mainAlbumArray,currAlbum,currentMusic);
		if AreaClicked(202,112,100,51) then
			DrawAlbumDown(mainAlbumArray,currAlbum,currentMusic);
		if AreaClicked(10,200,200,35) then
		begin
			newPlaylist[count] := mainAlbumArray[currAlbum].trackList[0].trackLocation;
			newPlaylistNames[count] := mainAlbumArray[currAlbum].trackList[0].trackName;
			newPlaylistAlbums[count] := mainAlbumArray[currAlbum].name;
			count += 1;
			WriteTrackName(mainAlbumArray[currAlbum].trackList[0].trackName,height);
			height += 32; 
		end;
		if AreaClicked(10,235,200,35) then
		begin
			newPlaylist[count] := mainAlbumArray[currAlbum].trackList[1].trackLocation;
			newPlaylistNames[count] := mainAlbumArray[currAlbum].trackList[1].trackName;
			newPlaylistAlbums[count] := mainAlbumArray[currAlbum].name;
			count += 1;
			WriteTrackName(mainAlbumArray[currAlbum].trackList[1].trackName,height); 
			height += 32;
		end;
		if AreaClicked(10,270,200,35) then
		begin
			newPlaylist[count] := mainAlbumArray[currAlbum].trackList[2].trackLocation;
			newPlaylistNames[count] := mainAlbumArray[currAlbum].trackList[2].trackName;
			newPlaylistAlbums[count] := mainAlbumArray[currAlbum].name;
			count += 1;
			WriteTrackName(mainAlbumArray[currAlbum].trackList[2].trackName,height); 
			height += 32;
		end;
		if AreaClicked(10,305,200,35) then
		begin
			newPlaylist[count] := mainAlbumArray[currAlbum].trackList[3].trackLocation;
			newPlaylistNames[count] := mainAlbumArray[currAlbum].trackList[3].trackName;
			newPlaylistAlbums[count] := mainAlbumArray[currAlbum].name;
			count += 1;
			WriteTrackName(mainAlbumArray[currAlbum].trackList[3].trackName,height);
			height += 32; 
		end;
		if AreaClicked(10,340,200,35) then
		begin
			newPlaylist[count] := mainAlbumArray[currAlbum].trackList[4].trackLocation;
			newPlaylistNames[count] := mainAlbumArray[currAlbum].trackList[4].trackName;
			newPlaylistAlbums[count] := mainAlbumArray[currAlbum].name;
			count += 1; 
			WriteTrackName(mainAlbumArray[currAlbum].trackList[4].trackName,height);
			height += 32;
		end;
		if AreaClicked(10,375,200,35) then
		begin
			newPlaylist[count] := mainAlbumArray[currAlbum].trackList[5].trackLocation;
			newPlaylistNames[count] := mainAlbumArray[currAlbum].trackList[5].trackName;
			newPlaylistAlbums[count] := mainAlbumArray[currAlbum].name;
			count += 1; 
			WriteTrackName(mainAlbumArray[currAlbum].trackList[5].trackName,height);
			height += 32;
		end;
		if AreaClicked(10,410,200,35) then
		begin
			newPlaylist[count] := mainAlbumArray[currAlbum].trackList[6].trackLocation;
			newPlaylistNames[count] := mainAlbumArray[currAlbum].trackList[6].trackName;
			newPlaylistAlbums[count] := mainAlbumArray[currAlbum].name;
			count += 1; 
			WriteTrackName(mainAlbumArray[currAlbum].trackList[6].trackName,height);
			height += 32;
		end;
		if AreaClicked(10,445,200,35) then
		begin
			newPlaylist[count] := mainAlbumArray[currAlbum].trackList[7].trackLocation;
			newPlaylistNames[count] := mainAlbumArray[currAlbum].trackList[7].trackName;
			newPlaylistAlbums[count] := mainAlbumArray[currAlbum].name;
			count += 1; 
			WriteTrackName(mainAlbumArray[currAlbum].trackList[7].trackName,height);
			height += 32;
		end;	
		if AreaClicked(10,480,200,35) then
		begin
			newPlaylist[count] := mainAlbumArray[currAlbum].trackList[8].trackLocation;
			newPlaylistNames[count] := mainAlbumArray[currAlbum].trackList[8].trackName;
			newPlaylistAlbums[count] := mainAlbumArray[currAlbum].name;
			count += 1;
			WriteTrackName(mainAlbumArray[currAlbum].trackList[8].trackName,height); 
			height += 32;
		end;
		if AreaClicked(10,515,200,35) then
		begin
			newPlaylist[count] := mainAlbumArray[currAlbum].trackList[9].trackLocation;
			newPlaylistNames[count] := mainAlbumArray[currAlbum].trackList[9].trackName;
			newPlaylistAlbums[count] := mainAlbumArray[currAlbum].name;
			count += 1; 
			WriteTrackName(mainAlbumArray[currAlbum].trackList[9].trackName,height);
			height += 32;
		end;
		if AreaClicked(10,550,200,35) then
		begin
			newPlaylist[count] := mainAlbumArray[currAlbum].trackList[10].trackLocation;
			newPlaylistNames[count] := mainAlbumArray[currAlbum].trackList[10].trackName;
			newPlaylistAlbums[count] := mainAlbumArray[currAlbum].name;
			count += 1;
			WriteTrackName(mainAlbumArray[currAlbum].trackList[10].trackName,height);
			height += 32; 
		end;
		if AreaClicked(10,585,200,35) then
		begin
			newPlaylist[count] := mainAlbumArray[currAlbum].trackList[11].trackLocation;
			newPlaylistNames[count] := mainAlbumArray[currAlbum].trackList[11].trackName;
			newPlaylistAlbums[count] := mainAlbumArray[currAlbum].name;
			count += 1; 
			WriteTrackName(mainAlbumArray[currAlbum].trackList[11].trackName,height);
			height += 32;
		end;		
		if AreaClicked(485,90,172,40) then
		begin
			EraseGrid(playlistCreated,playlistPlaying);
			count := 20;
		end;
		if (count = 14) then
		begin
			FillRectangle(ColorWhite,760,580,88,45);
			DrawText('Play',ColorCrimson,LoadFont('maven_pro_regular.ttf',30),775,588);
			playlistCreated := true;
		end;	
	end;
end;		

procedure RewriteTrackNames(newPlaylistNames: playlist; mainAlbumArray: albumArray);
var
	count : Integer;
	height : Integer = 154;
begin
	DrawPlaylistGrid();
	for count := 0 to 14 do
	begin
		WriteTrackName(newPlaylistNames[count],height);
		height += 32;
	end;
	RefreshScreen();
end;	

procedure changeTrack(mainAlbumArray: albumArray; var currentMusic: NowPlaying; currAlbum: Integer; initial: Boolean; musicPlayingNow: Boolean; playlistPlaying: Boolean);
begin
	if (not playlistPlaying) then
	begin
		if (not initial) then
		begin
			if (musicPlayingNow) then
			begin
				if AreaClicked(10,200,200,35) then
				begin
					currentMusic.currentAlbum :=	mainAlbumArray[currAlbum].name;
					currentMusic.currentTrack := mainAlbumArray[currAlbum].trackList[0].trackName;
					currentMusic.currentTrackLocation := mainAlbumArray[currAlbum].trackList[0].trackLocation;
					PlayMusic(currentMusic.currentTrackLocation,0);
					DrawGrid(mainAlbumArray,currentMusic);
					RefreshScreen();
				end;
				if AreaClicked(10,235,200,35) then
				begin
					currentMusic.currentAlbum :=	mainAlbumArray[currAlbum].name;
					currentMusic.currentTrack := mainAlbumArray[currAlbum].trackList[1].trackName;
					currentMusic.currentTrackLocation := mainAlbumArray[currAlbum].trackList[1].trackLocation;
					PlayMusic(currentMusic.currentTrackLocation,0);
					DrawGrid(mainAlbumArray,currentMusic);
					RefreshScreen();
				end;
				if AreaClicked(10,270,200,35) then
				begin
					currentMusic.currentAlbum :=	mainAlbumArray[currAlbum].name;
					currentMusic.currentTrack := mainAlbumArray[currAlbum].trackList[2].trackName;
					currentMusic.currentTrackLocation := mainAlbumArray[currAlbum].trackList[2].trackLocation;
					PlayMusic(currentMusic.currentTrackLocation,0);
					DrawGrid(mainAlbumArray,currentMusic);
					RefreshScreen();
				end;
				if AreaClicked(10,305,200,35) then
				begin
					currentMusic.currentAlbum :=	mainAlbumArray[currAlbum].name;
					currentMusic.currentTrack := mainAlbumArray[currAlbum].trackList[3].trackName;
					currentMusic.currentTrackLocation := mainAlbumArray[currAlbum].trackList[3].trackLocation;
					PlayMusic(currentMusic.currentTrackLocation,0);
					DrawGrid(mainAlbumArray,currentMusic);
					RefreshScreen();
				end;
				if AreaClicked(10,340,200,35) then
				begin
					currentMusic.currentAlbum :=	mainAlbumArray[currAlbum].name;
					currentMusic.currentTrack := mainAlbumArray[currAlbum].trackList[4].trackName;
					currentMusic.currentTrackLocation := mainAlbumArray[currAlbum].trackList[4].trackLocation;
					PlayMusic(currentMusic.currentTrackLocation,0);
					DrawGrid(mainAlbumArray,currentMusic);
					RefreshScreen();
				end;
				if AreaClicked(10,375,200,35) then
				begin
					currentMusic.currentAlbum :=	mainAlbumArray[currAlbum].name;
					currentMusic.currentTrack := mainAlbumArray[currAlbum].trackList[5].trackName;
					currentMusic.currentTrackLocation := mainAlbumArray[currAlbum].trackList[5].trackLocation;
					PlayMusic(currentMusic.currentTrackLocation,0);
					DrawGrid(mainAlbumArray,currentMusic);
					RefreshScreen();
				end;
				if AreaClicked(10,410,200,35) then
				begin
					currentMusic.currentAlbum :=	mainAlbumArray[currAlbum].name;
					currentMusic.currentTrack := mainAlbumArray[currAlbum].trackList[6].trackName;
					currentMusic.currentTrackLocation := mainAlbumArray[currAlbum].trackList[6].trackLocation;
					PlayMusic(currentMusic.currentTrackLocation,0);
					DrawGrid(mainAlbumArray,currentMusic);
					RefreshScreen();
				end;
				if AreaClicked(10,445,200,35) then
				begin
					currentMusic.currentAlbum :=	mainAlbumArray[currAlbum].name;
					currentMusic.currentTrack := mainAlbumArray[currAlbum].trackList[7].trackName;
					currentMusic.currentTrackLocation := mainAlbumArray[currAlbum].trackList[7].trackLocation;
					PlayMusic(currentMusic.currentTrackLocation,0);
					DrawGrid(mainAlbumArray,currentMusic);
					RefreshScreen();
				end;	
				if AreaClicked(10,480,200,35) then
				begin
					currentMusic.currentAlbum :=	mainAlbumArray[currAlbum].name;
					currentMusic.currentTrack := mainAlbumArray[currAlbum].trackList[8].trackName;
					currentMusic.currentTrackLocation := mainAlbumArray[currAlbum].trackList[8].trackLocation;
					PlayMusic(currentMusic.currentTrackLocation,0);
					DrawGrid(mainAlbumArray,currentMusic);
					RefreshScreen();
				end;
				if AreaClicked(10,515,200,35) then
				begin
					currentMusic.currentAlbum :=	mainAlbumArray[currAlbum].name;
					currentMusic.currentTrack := mainAlbumArray[currAlbum].trackList[9].trackName;
					currentMusic.currentTrackLocation := mainAlbumArray[currAlbum].trackList[9].trackLocation;
					PlayMusic(currentMusic.currentTrackLocation,0);
					DrawGrid(mainAlbumArray,currentMusic);
					RefreshScreen(); 
				end;
				if AreaClicked(10,550,200,35) then
				begin
					currentMusic.currentAlbum :=	mainAlbumArray[currAlbum].name;
					currentMusic.currentTrack := mainAlbumArray[currAlbum].trackList[10].trackName;
					currentMusic.currentTrackLocation := mainAlbumArray[currAlbum].trackList[10].trackLocation;
					PlayMusic(currentMusic.currentTrackLocation,0);
					DrawGrid(mainAlbumArray,currentMusic);
					RefreshScreen();
				end;
				if AreaClicked(10,585,200,35) then
				begin
					currentMusic.currentAlbum :=	mainAlbumArray[currAlbum].name;
					currentMusic.currentTrack := mainAlbumArray[currAlbum].trackList[11].trackName;
					currentMusic.currentTrackLocation := mainAlbumArray[currAlbum].trackList[11].trackLocation;
					PlayMusic(currentMusic.currentTrackLocation,0);
					DrawGrid(mainAlbumArray,currentMusic);
					RefreshScreen();
				end;
			end;	
		end;
	end;				
end;	

procedure CheckForSecondWindowClicks(var mainWindow: Boolean; mainAlbumArray: albumArray; var currentMusic: NowPlaying; musicPlayingNow: Boolean; AlbumPage: Integer; volumeLimit: Integer; initial: Boolean; var newPlaylist: playlist; var playlistCreated: Boolean; var newPlaylistNames: playlist; var playlistPlaying: Boolean; var newPlaylistAlbums: Playlist);
var
	currAlbum : Integer = 0;
	count : Integer = 0;
	condition : Boolean = true;
begin
	ClearScreen(ColorCrimson);
	DrawMenu();
	DrawGrid(mainAlbumArray,currentMusic);
	DrawButton();
	RefreshScreen;
	if playlistCreated then
	begin
		RewriteTrackNames(newPlaylistNames,mainAlbumArray);
		FillRectangle(ColorWhite,760,580,88,45);
		DrawText('Play',ColorCrimson,LoadFont('maven_pro_regular.ttf',30),775,588);
		RefreshScreen();
	end;
	while (condition) do
	begin
		if (mainAlbumArray[count].name = currentMusic.currentAlbum) then
		begin
			condition := false;
			currAlbum := count; 
		end
		else
			count += 1;
	end;
	While (not mainWindow) do
	begin
		ProcessEvents();
		PlayNextTrack(mainAlbumArray,currentMusic,initial,mainWindow);
		if (AreaClicked(750,30,100,66)  or KeyTyped(MKey)) then
		begin
			RefreshMainScreen(mainAlbumArray,currentMusic,musicPlayingNow,AlbumPage,volumeLimit);
			mainWindow := true;
		end;
		changeTrack(mainAlbumArray,currentMusic,currAlbum,initial,musicPlayingNow,playlistPlaying);
		if AreaClicked(200,50,100,51) then
			DrawAlbumUp(mainAlbumArray,currAlbum,currentMusic);
		if AreaClicked(202,112,100,51) then
			DrawAlbumDown(mainAlbumArray,currAlbum,currentMusic);
		if AreaClicked(485,30,175,40) then
		begin
			DrawPlaylistGrid();
			SelectTracks(mainAlbumArray,newPlaylist,newPlaylistNames,currAlbum,playlistCreated,newPlaylistAlbums,playlistPlaying,currentMusic);
		end;	
		if AreaClicked(485,90,172,40) then
		begin
			EraseGrid(playlistCreated,playlistPlaying);
		end;
		if (AreaClicked(760,580,88,45)) then
		begin
			if (playlistCreated) then
			begin
				currentMusic.currentAlbum := newPlaylistAlbums[0];
				currentMusic.currentTrackLocation := newPlaylist[0];
				currentMusic.currentTrack := newPlaylistNames[0];
				PlayMusic(currentMusic.currentTrackLocation);
				playlistPlaying := true;
			end;
		end;			
	end;
end;	

procedure Main();
var
	mainAlbumArray : albumArray;
	currentMusic : NowPlaying;
	mainWindow : Boolean = true;
	initial: Boolean = true;
	musicPlayingNow : Boolean = false;
	AlbumPage : Integer = 1;
	volumeLimit : Integer = 180;
	volumeLevel : Single = 0;
	newPlaylist,newPlaylistNames, newPlaylistAlbums : playlist;
	playlistCreated : Boolean = false;
	playlistPlaying : Boolean = false;
begin
	mainAlbumArray := ReadAlbums();
	InitializeCurrentMusic(mainAlbumArray,currentMusic);
	OpenGraphicsWindow('Music Player',860,650);
	DrawStartScreen(mainAlbumArray,currentMusic);
	RefreshScreen();
	repeat
		CheckForMainWindowClicks(mainWindow,initial,currentMusic,mainAlbumArray,musicPlayingNow,AlbumPage,volumeLimit,volumeLevel,playlistPlaying,newPlaylist,newPlaylistNames,newPlaylistAlbums);
		CheckForSecondWindowClicks(mainWindow,mainAlbumArray,currentMusic,musicPlayingNow,AlbumPage,volumeLimit,initial,newPlaylist,playlistCreated,newPlaylistNames,playlistPlaying,newPlaylistAlbums);	
	until WindowCloseRequested();
end;	

begin
  Main();
end.
