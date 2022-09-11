package states;

import flixel.util.FlxTimer;
import states.SongInfoSubstate.SongInfo;
#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import Options;
import flixel.FlxObject;
import flixel.input.mouse.FlxMouseEventManager;
import flash.events.MouseEvent;
import flixel.FlxState;
import EngineData.WeekData;
import EngineData.SongData;
import haxe.Json;
import openfl.utils.Assets as OpenFlAssets;
#if sys
import sys.io.File;
#end
import openfl.media.Sound;
import ui.*;
#if cpp
import Sys;
import sys.FileSystem;
#end


using StringTools;

typedef InfoPak = {
	var normal:SongInfo;
	@:optional var asshole:SongInfo;
}
typedef ExternalSongMetadata = {
	@:optional var displayName:String;
	@:optional var freeplayIcon:String;
	@:optional var inFreeplay:Bool;

}

class FreeplayState extends MusicBeatState
{
	var songs:Array<SongData> = [];

	var selector:FlxText;
	public static var curSelected:Int = 0;
	var selectableDiffs:Array<Int>=[0,1,2];
	var difficulties:Array<Array<Int>> = [];
	public static var curDifficulty:Int = 2;
	public var infos:Map<String, InfoPak> = [];
	
	var bg:FlxSprite;

	var hasSU:Bool = false;
	
	var scoreText:FlxText;
	var diffText:FlxText;
	var lerpScore:Int = 0;
	var curDifficultyIdx:Int = 0;
	var intendedScore:Int = 0;

	var songNames:Array<String>=[];

	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var curPlaying:Bool = false;

	private var iconArray:Array<HealthIcon> = [];
	private var infoButts:Map<Int, FlxSprite> = [];
	
	private var afterpartyButton:FlxSprite;
	private var afterpartyText:FlxText;

	function onMouseDown(object:FlxObject){
		if (subState != null)return;
		for(idx in 0...grpSongs.members.length){
			var obj = grpSongs.members[idx];
			var icon = iconArray[idx];
			if(obj==object || icon==object){
				if(idx!=curSelected){
					changeSelection(idx,false);
				}else{
					selectSong();
				}
			}
		}
	}

	function onMouseUp(object:FlxObject){

	}

	function onMouseOver(object:FlxObject){

	}

	function onMouseOut(object:FlxObject){

	}

	function scroll(event:MouseEvent){
		if(subState==null)
			#if web
			changeSelection(-Math.floor(event.delta/100));
			#else
			changeSelection(-event.delta);
			#end
	}

	override function create()
	{
		super.create();
		FlxG.mouse.visible=true;
		var initSonglist = CoolUtil.coolTextFile(Paths.txt('freeplaySonglist'));


			if (FlxG.sound.music != null)
			{
				if (!FlxG.sound.music.playing)
					FlxG.sound.playMusic(Paths.music('freakyMenu'));
			}


		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		var isDebug:Bool = false;

		#if debug
		isDebug = true;
		#end

		FlxG.stage.addEventListener(MouseEvent.MOUSE_WHEEL,scroll);

		/*
		for (i in 0...initSonglist.length)
		{
			var data = initSonglist[i].split(" ");
			var icon = data.splice(0,1)[0];
			songs.push(new SongMetadata(data.join(" "), 1, icon));
		}
		if (StoryMenuState.weekUnlocked[2] || isDebug)
			addWeek(['Bopeebo', 'Fresh', 'Dadbattle'], 1, ['dad']);

		if (StoryMenuState.weekUnlocked[2] || isDebug)
			addWeek(['Spookeez', 'South', 'Monster'], 2, ['spooky','spooky','monster']);

		if (StoryMenuState.weekUnlocked[3] || isDebug)
			addWeek(['Pico', 'Philly-Nice', 'Blammed'], 3, ['pico']);

		if (StoryMenuState.weekUnlocked[4] || isDebug)
			addWeek(['Satin-Panties', 'High', 'Milf'], 4, ['mom']);

		if (StoryMenuState.weekUnlocked[5] || isDebug)
			addWeek(['Cocoa', 'Eggnog', 'Winter-Horrorland'], 5, ['parents-christmas', 'parents-christmas', 'monster-christmas']);

		if (StoryMenuState.weekUnlocked[6] || isDebug)
			addWeek(['Senpai', 'Roses', 'Thorns'], 6, ['senpai', 'senpai', 'spirit'])
		*/

		var weekUnlocked = [true, false, false, false];
		if (FlxG.save.data.weeksBeaten == null)
			FlxG.save.data.weeksBeaten = [false, false, false, false];

		var beaten = FlxG.save.data.weeksBeaten;
		#if !html5 
		hasSU = beaten[0] == true;
		if (hasSU)
			weekUnlocked = [true, true, true, false];

		#end

		for(week in EngineData.weekData){
			if (weekUnlocked[week.weekNum])
				addWeekData(week);
		}

		
		#if sys
		var otherSongs = Paths.getDirs("songs","assets");
		for(song in otherSongs){
			var songFolder = 'assets/songs/${song.toLowerCase()}';
			if (FileSystem.exists(songFolder))
			{
				if(FileSystem.exists('$songFolder/desc.json')){
					var info:InfoPak = Json.parse(File.getContent('$songFolder/desc.json'));
					infos.set(song, info);
				}
				if(!songNames.contains(song.toLowerCase())){
					var hasCharts:Bool = false;
					var icon:String = 'dad';
					var add:Bool = true;
					var display:Null<String>=null;
					
					var hasMetadata= FileSystem.exists('$songFolder/metadata.json');
					var metadata:Null<ExternalSongMetadata> = null;
					if(hasMetadata){
						trace('GOT METADATA FOR ${song}');
						metadata = Json.parse(File.getContent('$songFolder/metadata.json'));

						add = metadata.inFreeplay==null?true:metadata.inFreeplay;
						icon = metadata.freeplayIcon==null?'dad':metadata.freeplayIcon;
						display = metadata.displayName;
						hasCharts=true;
					}else{
						if(FileSystem.exists(Paths.chart(song,song))){
							var song = Song.loadFromJson(song,song);
							icon = song==null?'dad':Character.getIcon(song.player2);
							if(icon==null)icon='dad';
							add=true;
							hasCharts=true;
						}
					}

					if(FileSystem.exists(Paths.chart(song,song)) && !hasCharts){
						hasCharts=true;
					}

					//if(add && hasCharts)
					//	addSong(display==null?song.replace("-"," "):display,0,icon,song);

				}

			}
		}
		#else
		for(song in songNames){
			var songFolder = 'assets/songs/${song.toLowerCase()}';
			if (OpenFlAssets.exists('$songFolder/desc.json', TEXT))
			{
				var info:InfoPak = Json.parse(OpenFlAssets.getText('$songFolder/desc.json'));
				infos.set(song, info);
			}

		}
		#end


		// LOAD MUSIC

		// LOAD CHARACTERS

		bg = new FlxSprite().loadGraphic(Paths.image('freeplayBG'));
		add(bg);

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(0, (720 * i) + 320, songs[i].displayName, true, false);
			songText.isMenuItem = true;
			songText.targetY = i - curSelected;
			songText.movementType = 'freeplayList';
			songText.wantedX = FlxG.width/2 - (songText.width+150)/2;
			songText.gotoTargetPosition();
			FlxMouseEventManager.add(songText,onMouseDown,onMouseUp,onMouseOver,onMouseOut);
			grpSongs.add(songText);

			var icon:HealthIcon = new HealthIcon(songs[i].freeplayIcon);
			icon.sprTracker = songText;

			// using a FlxGroup is too much fuss!
			iconArray.push(icon);
			add(icon);
			FlxMouseEventManager.add(icon,onMouseDown,onMouseUp,onMouseOver,onMouseOut);

			// songText.x += 40;
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
			// songText.screenCenter(X);

			if (infos.exists(songs[i].chartName.toLowerCase()))
			{
				var infoBut = new CockSprite().loadGraphic(Paths.image("info"));
				infoBut.antialiasing = true;
				infoBut.screenCenter(XY);
				infoBut.sprTracker = songText;
				add(infoBut);
				infoButts.set(i, infoBut);
			}
		}

		afterpartyButton = new FlxSprite(30, 30).loadGraphic(Paths.image("afterparty"));
		afterpartyButton.antialiasing = true;
		afterpartyButton.visible = hasSU;
		add(afterpartyButton);
		afterpartyText = new FlxText(30 + afterpartyButton.width, 30, 0, "Afterparty / Extras", 24);
		afterpartyText.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.PURPLE);
		afterpartyText.visible=false;
		afterpartyText.antialiasing = true;
		afterpartyText.y += afterpartyButton.height / 2 - afterpartyText.height/2;
		add(afterpartyText);
		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		// scoreText.autoSize = false;
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);
		// scoreText.alignment = RIGHT;

		var scoreBG:FlxSprite = new FlxSprite(scoreText.x - 6, 0).makeGraphic(Std.int(FlxG.width * 0.35), 66, 0xFF000000);
		scoreBG.alpha = 0.6;
		add(scoreBG);

		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		diffText.font = scoreText.font;
		add(diffText);
		
		add(scoreText);

		// FlxG.sound.playMusic(Paths.music('title'), 0);
		// FlxG.sound.music.fadeIn(2, 0, 0.8);
		selector = new FlxText();

		selector.size = 40;
		selector.text = ">";
		// add(selector);

		var swag:Alphabet = new Alphabet(1, 0, "swag");

		// JUST DOIN THIS SHIT FOR TESTING!!!
		/*
			var md:String = Markdown.markdownToHtml(Assets.getText('CHANGELOG.md'));

			var texFel:TextField = new TextField();
			texFel.width = FlxG.width;
			texFel.height = FlxG.height;
			// texFel.
			texFel.htmlText = md;

			FlxG.stage.addChild(texFel);

			// scoreText.textField.htmlText = md;

			trace(md);
		 */

		 bg.y = -curSelected*720;

		 changeSelection();
		 changeDiff();

		var beaten = FlxG.save.data.weeksBeaten;
		if (beaten != null && beaten[0] && !FlxG.save.data.seenSUNotif)
		{
			new FlxTimer().start(0.5, function(tmr:FlxTimer)
			{
				persistentUpdate = false;
				#if html5
				openSubState(new HTMLSUSubstate());
				#else
				openSubState(new SUSubstate());
				#end
			});
		}

		
	}

	public function addSongData(songData:EngineData.SongData){
		songNames.push(songData.chartName.toLowerCase());
		songs.push(songData);
		var songDiffs:Array<Int> = [];
		#if sys
		if(FileSystem.isDirectory('assets/songs/${songData.chartName.toLowerCase()}') ){
			for (file in FileSystem.readDirectory('assets/songs/${songData.chartName.toLowerCase()}'))
			{
				if(file.endsWith(".json") && !FileSystem.isDirectory(file)){
					var difficultyName = file.replace(".json","").replace(songData.chartName.toLowerCase(),"");
					switch(difficultyName.toLowerCase()){
						case '-easy':
							songDiffs.push(0);
						case '':
							songDiffs.push(1);
						case '-hard':
							songDiffs.push(2);
						case '-erect':
							if(hasSU)
								songDiffs.push(3);
					}
				}
			}

			songDiffs.sort((a,b)->Std.int(a-b));

			difficulties.push(songDiffs);
		}else{
			if (!hasSU)
				difficulties.push([1, 0, 2]);
			else
				difficulties.push([1,0,2,3]);
		}
		#else
		var suffixes = ["","-easy","-hard"];
		if(hasSU)
			suffixes.push("-erect");
		
		var conversion = [1, 0, 2, 3];
		var daDiffs:Array<Int> = [];
		for(idx in 0...suffixes.length){
			var suff = suffixes[idx];
			var name = Paths.chart('${songData.chartName.toLowerCase()}$suff',
				songData.chartName.toLowerCase());//'songs:assets/songs/${songData.chartName.toLowerCase()}$suff.json';
			trace(name, OpenFlAssets.exists(name, TEXT));
			if(OpenFlAssets.exists(name, TEXT)){
				daDiffs.push(conversion[idx]);
			}
		}
		daDiffs.sort((a, b) -> Std.int(a - b));
		difficulties.push(daDiffs);
		#end
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String, ?chartName:String)
	{
		addSongData(new SongData(songName,songCharacter,weekNum,chartName));
	}

	public function addWeekData(weekData:WeekData){
		for(song in weekData.songs){
			addSongData(song);
		}
	}

	public function addWeek(songs:Array<String>, weekNum:Int, ?songCharacters:Array<String>)
	{
		if (songCharacters == null)
			songCharacters = ['bf'];

		var num:Int = 0;
		for (song in songs)
		{
			addSong(song, weekNum, songCharacters[num]);

			if (songCharacters.length != 1)
				num++;
		}
	}
	function selectSong(){
		PlayState.setFreeplaySong(songs[curSelected],curDifficulty);
		PlayState.seenCutscene = false;
		LoadingState.loadAndSwitchState(new PlayState());
	}
	override function update(elapsed:Float)
	{
		bg.y = FlxMath.lerp(bg.y, -curSelected*720, Main.adjustFPS(0.17));
		super.update(elapsed);
		/*if (FlxG.mouse.overlaps(infoBut) && FlxG.mouse.justPressed)
		{
			var info = infos.get(songs[curSelected].chartName).normal;
			if (curDifficulty == 3 && infos.get(songs[curSelected].chartName).asshole!=null){
				info = infos.get(songs[curSelected].chartName).asshole;
			}
			openSubState(new SongInfoSubstate(info));
		}
		infoBut.x = FlxMath.lerp(infoBut.x, grpSongs.members[curSelected].x - infoBut.width - 10, 0.1 * (elapsed/(1/60)) );*/
		if (afterpartyButton.visible){
			afterpartyButton.scale.x = FlxMath.lerp(afterpartyButton.scale.x, FlxG.mouse.overlaps(afterpartyButton) ? 1.1 : 1, 0.15 * (elapsed / (1 / 60)));
			afterpartyButton.scale.y = FlxMath.lerp(afterpartyButton.scale.y, FlxG.mouse.overlaps(afterpartyButton) ? 1.1 : 1, 0.15 * (elapsed / (1 / 60)));
			afterpartyText.visible = FlxG.mouse.overlaps(afterpartyButton);
			if (FlxG.mouse.overlaps(afterpartyButton) && FlxG.mouse.justPressed){
				FlxG.switchState(new ExtrasState());
			}
		}
		for(idx in infoButts.keys()){
			var butt = infoButts.get(idx);
			// Too lazy to use flxmousemanager whatever the fuck i just wanna go home
			butt.scale.x = FlxMath.lerp(butt.scale.x, FlxG.mouse.overlaps(butt) ? 1.1 : 1, 0.15 * (elapsed / (1 / 60)));
			butt.scale.y = FlxMath.lerp(butt.scale.y, FlxG.mouse.overlaps(butt) ? 1.1 : 1, 0.15 * (elapsed / (1 / 60)));
			if (FlxG.mouse.overlaps(butt) && FlxG.mouse.justPressed)
			{
				var info = infos.get(songs[idx].chartName).normal;
				if (curDifficulty == 3 && infos.get(songs[idx].chartName).asshole != null)
				{
					info = infos.get(songs[idx].chartName).asshole;
				}
				openSubState(new SongInfoSubstate(info));
			}
		}

		if (FlxG.sound.music.volume < 0.7)
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;


		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, Main.adjustFPS(0.4)));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;

		scoreText.text = "PERSONAL BEST:" + lerpScore;

		var upP = controls.UP_P;
		var downP = controls.DOWN_P;
		var accepted = controls.ACCEPT;

		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}

		if (controls.LEFT_P)
			changeDiff(-1);
		if (controls.RIGHT_P)
			changeDiff(1);

		if (controls.BACK)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			FlxG.switchState(new MainMenuState());
		}

		if (accepted)
		{
			selectSong();
		}
	}

	function changeDiff(change:Int = 0)
	{
		var oldDiff = curDifficulty;
		curDifficultyIdx += change;
		if(curDifficultyIdx>selectableDiffs.length-1){
			curDifficultyIdx=0;
		}else if(curDifficultyIdx<0){
			curDifficultyIdx=selectableDiffs.length-1;
		}
		var newDiff = selectableDiffs[curDifficultyIdx];
		
		if(newDiff > oldDiff)
			oldDiff = 0;
		
		curDifficulty = newDiff;

		if(oldDiff!=curDifficulty){
			if(curDifficulty==3 || oldDiff==3){
				if(OptionUtils.options.freeplayPreview){
					FlxG.sound.playMusic(CoolUtil.getSound('${Paths.inst(songs[curSelected].chartName,curDifficulty==3?"Erect":"" )}'), 0);
				}
			}
		}

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].chartName, curDifficulty);
		#end
		switch (curDifficulty)
		{
			case 0:
				diffText.text = "EASY";
			case 1:
				diffText.text = 'NORMAL';
			case 2:
				diffText.text = "HARD";
			case 3:
				diffText.text = "STEPPED UP";
		}
	}

	function changeSelection(change:Int = 0,additive:Bool=true)
	{
		#if !switch
		//NGio.logEvent('Fresh');
		#end

		// NGio.logEvent('Fresh');
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		if(additive){
			curSelected += change;

			if (curSelected < 0)
				curSelected = songs.length - 1;
			if (curSelected >= songs.length)
				curSelected = 0;
		}else{
			curSelected=change;
		}

		var oldDiff = curDifficulty;

		selectableDiffs=difficulties[curSelected];
		if(selectableDiffs.contains(curDifficulty)){
			curDifficultyIdx = selectableDiffs.indexOf(curDifficulty);
		}else{
			if(curDifficultyIdx>selectableDiffs.length){
				curDifficultyIdx=0;
			}else if(curDifficultyIdx<0){
				curDifficultyIdx=selectableDiffs.length;
			}
			curDifficulty=selectableDiffs[curDifficultyIdx];
			if(!selectableDiffs.contains(curDifficulty)){
				var nuDiff = selectableDiffs[Math.floor(selectableDiffs.length / 2)];
				curDifficultyIdx=selectableDiffs.contains(1)?selectableDiffs.indexOf(1):nuDiff;
				curDifficulty=selectableDiffs[curDifficultyIdx];
			}
		}
		if(curDifficulty>oldDiff){
			curDifficultyIdx = 0;
			curDifficulty = selectableDiffs[0];
		}
		diffText.visible = selectableDiffs.length>1;

		changeDiff();

		// selector.y = (70 * curSelected) + 30;

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].chartName, curDifficulty);
		// lerpScore = 0;
		#end

		var createThread=false;
		#if sys
			createThread=true;
		#end

		if(OptionUtils.options.freeplayPreview){
			FlxG.sound.playMusic(CoolUtil.getSound('${Paths.inst(songs[curSelected].chartName,curDifficulty==3?"Erect":"" )}'), 0);
		}

		var bullShit:Int = 0;

		for (i in 0...iconArray.length)
		{
			iconArray[i].alpha = 0.6;
		}

		iconArray[curSelected].alpha = 1;

		for (item in grpSongs.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
	}

	override function switchTo(next:FlxState){
		// Do all cleanup of stuff here! This makes it so you dont need to copy+paste shit to every switchState
		FlxG.stage.removeEventListener(MouseEvent.MOUSE_WHEEL,scroll);

		return super.switchTo(next);
	}
}
