package states;

import ui.Cutscene;
#if desktop
import Discord.DiscordClient;
#end

import modchart.*;
import Options;
import Section.SwagSection;
import Song.SwagSong;
import WiggleEffect.WiggleEffectType;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.util.FlxSpriteUtil;
import flixel.FlxSprite;
import flixel.util.FlxAxes;
import flixel.FlxState;
import flixel.group.FlxSpriteGroup;
import flixel.FlxSubState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import ui.*;
import flixel.input.keyboard.FlxKey;
import flixel.util.FlxTimer;
import haxe.Json;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.filters.ShaderFilter;
import LuaClass;
import flash.display.BitmapData;
import flash.display.Bitmap;
import Shaders;
import haxe.Exception;
import openfl.utils.Assets;
import ModChart;
import flash.events.KeyboardEvent;
import Controls;
import Controls.Control;
import openfl.media.Sound;
import openfl.display.GraphicsShader;
#if sys
import sys.io.File;
#end
import Section.Event;

#if cpp
import vm.lua.LuaVM;
import vm.lua.Exception;
import Sys;
import sys.FileSystem;
import llua.Convert;
import llua.Lua;
import llua.State;
import llua.LuaL;
#end

import EngineData.WeekData;
import EngineData.SongData;

using StringTools;
using flixel.util.FlxSpriteUtil;

class PlayState extends MusicBeatState
{
	var goldTween:FlxTween;
	var goldOverlay:FlxSprite;
	var noteCancer:FlxSprite;
	public static var calibrating:Bool = false;
	var originalOffset:Int = 0;
	var grayscale: GrayscaleEffect;
	var cum:FlxSprite;
	var godIhateThis:FlxSprite;
	var cumShader:GlitchEffect;
	var hpDrain:Float = 0;
	var oldHealth:Float = 1;
	var drainEnabled:Bool = true;
	public static var noteCounter:Map<String,Int> = [];
	public var inst:FlxSound;

	public static var seenCutscene:Bool = false;

	public static var fromExtras:Bool = false;
	public static var songData:SongData;
	public static var currentPState:PlayState;
	public static var weekData:WeekData;
	public static var inCharter:Bool=false;
	public var player:Character;
	public var nonPlayer:Character;
	public var memoryShader:MemoryEffect;
	public static var curStage:String = '';
	public static var SONG:SwagSong;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;
	public var scrollSpeed:Float = 1;
	public var songSpeed:Float = 1;
	public var dontSync:Bool=false;
	public var currentTrackPos:Float = 0;
	public var currentVisPos:Float = 0;
	var halloweenLevel:Bool = false;
	public var stage:Stage;
	public var closeupStage:Stage;
	public var corruptedStage:Stage; // malvado
	public var uncorruptedStage:Stage; // malvado

	public var dmpiikingOut:FlxSprite;

	public var realStage:Stage;
	var tweens:Array<FlxTween> = [];

	public var zoomBeatingInterval:Float = 4;
	public var zoomBeatingZoom:Float = 0.015;

	private var vocals:FlxSound;

	public var cameraLocked:Bool = false;
	public var cameraLockX:Float = 0;
	public var cameraLockY:Float = 0;

	public var camOffX:Float = 0;
	public var camOffY:Float = 0;

	public var dad:Character;
	public var opponent:Character;
	public var gf:Character;
	public var boyfriend:Character;
	public static var judgeMan:JudgementManager;
	public static var startPos:Float = 0;
	public static var charterPos:Float = 0;

	private var shownAccuracy:Float = 0;
	private var renderedNotes:FlxTypedGroup<Note>;
	private var noteSplashes:FlxTypedGroup<NoteSplash>;
	private var playerNotes:Array<Note> = [];
	private var unspawnNotes:Array<Note> = [];

	private var strumLine:FlxSprite;
	private var curSection:Int = 0;

	public var noteSpawnTime:Float = 1000;
	private var camFollow:FlxObject;
	public var currentOptions:Options;

	private static var prevCamFollow:FlxObject;
	private var lastHitDadNote:Note;
	public var eventSchedule:Array<Event> = [];
	public var strumLineNotes:FlxTypedGroup<Receptor>;
	public var playerStrums:FlxTypedGroup<Receptor>;
	public var dadStrums:FlxTypedGroup<Receptor>;
	public var playerStrumLines:FlxTypedGroup<FlxSprite>;
	public var refNotes:FlxTypedGroup<FlxSprite>;
	public var opponentRefNotes:FlxTypedGroup<FlxSprite>;
	public var refReceptors:FlxTypedGroup<FlxSprite>;
	public var opponentRefReceptors:FlxTypedGroup<FlxSprite>;
	public var opponentStrumLines:FlxTypedGroup<FlxSprite>;
	public var center:FlxPoint;

	public var dadX:Float = 0; // for 12-28
	public var dadY:Float = 0; // for 12-28
	public var bfX:Float = 0; // for 12-28
	public var bfY:Float = 0; // for 12-28
	// gonna do this some day
	private var opponentNotefield:Notefield;
	private var playerNotefield:Notefield;
	#if desktop
	public var luaSprites:Map<String, Dynamic>;
	public var luaObjects:Map<String, Dynamic>;
	public var unnamedLuaSprites:Int=0;
	public var unnamedLuaShaders:Int=0;
	public var unnamedLuaObjects:Int=0;
	public var defaultLuaClasses:Array<Dynamic>;
	public var dadLua:LuaCharacter;
	public var gfLua:LuaCharacter;
	public var bfLua:LuaCharacter;
	#end
	public var gameCam3D:RaymarchEffect;
	public var hudCam3D:RaymarchEffect;
	public var noteCam3D:RaymarchEffect;

	public static var noteModifier:String='base';
	public static var uiModifier:String='base';
	var pressedKeys:Array<Bool> = [false,false,false,false];

	private var camZooming:Bool = true;
	private var curSong:String = "";

	private var gfSpeed:Int = 4;
	private var health:Float = 1;
	private var previousHealth:Float = 1;
	private var combo:Int = 0;
	private var highestCombo:Int = 0;
	private var healthBar:Healthbar;

	private var generatedMusic:Bool = false;
	private var startingSong:Bool = false;

	public var camHUD:FlxCamera;
	public var camOther:FlxCamera;
	public var camNotes:FlxCamera;
	public var camOverlay:FlxCamera;
	public var camReceptor:FlxCamera;
	public var camSus:FlxCamera;
	public var pauseHUD:FlxCamera;
	public var camRating:FlxCamera;
	public var camGame:FlxCamera;
	public var modchart:ModChart;
	public var botplayPressTimes:Array<Float> = [0,0,0,0];
	public var botplayHoldTimes:Array<Float> = [0,0,0,0];
	public var botplayHoldMaxTimes:Array<Float> = [0,0,0,0];

	public var upscrollOffset:Float = 0;
	public var downscrollOffset:Float = 0;

	public var modManager:ModManager;

	public var opponents:Array<Character> = [];
	public var opponentIdx:Int = 0;

	var merchantDia:FlxSpriteGroup;
	var polaroids:FlxSpriteGroup;
	var merchantOverlay:FlxSprite;
	var malvadoPolaroid:Array<FlxSprite> = [];
	var merchantDiaMap:Map<String, FlxSprite>=[];
	public var dadAberration:ChromaticAberrationEffect;
	public var bfAberration:ChromaticAberrationEffect;
	public var hudAberration:ChromaticAberrationEffect;

	var flexyMic:FlxSprite;

	var judgeBin:FlxTypedGroup<JudgeSprite>;
	var comboBin:FlxTypedGroup<ComboSprite>;
	var accuracyName:String = 'Accuracy';

	var bindData:Array<FlxKey>;
	#if desktop
	var lua:LuaVM;
	#else
	var lua:Null<FlxBasic>=null; // random-ass null thing, doesnt matter what it is since this will always be null on html5
	#end
	var dialogue:Array<String> = ['blah blah blah', 'coolswag'];

	var halloweenBG:FlxSprite;
	var isHalloween:Bool = false;

	var phillyCityLights:FlxTypedGroup<FlxSprite>;
	var lightFadeShader:BuildingEffect;
	var vcrDistortionHUD:VCRDistortionEffect;
	var vcrDistortionGame:VCRDistortionEffect;
	var phillyTrain:FlxSprite;
	var trainSound:FlxSound;

	var limo:FlxSprite;
	var grpLimoDancers:FlxTypedGroup<BackgroundDancer>;
	var fastCar:FlxSprite;

	var upperBoppers:FlxSprite;
	var bottomBoppers:FlxSprite;
	var santa:FlxSprite;

	var bgGirls:BackgroundGirls;
	var wiggleShit:WiggleEffect = new WiggleEffect();
	var turn:String='';
	var focus:String='';

	var talking:Bool = true;
	var songScore:Int = 0;
	var botplayScore:Int = 0;
	var scoreTxt:FlxText;
	var highComboTxt:FlxText;
	var ratingCountersUI:FlxSpriteGroup;
	var botplayTxt:FlxText;
	var calibrationTxt:FlxText;

	var presetTxt:FlxText;

	var accuracy:Float = 1;
	var hitNotes:Float = 0;
	var totalNotes:Float = 0;
	private static var sliderVelocities:Array<Song.VelocityChange> = [];

	var counters:Map<String,FlxText> = [];

	var grade:String = "N/A";
	var luaModchartExists = false;
	var noteLanes:Array<Array<Note>> = [];
	var susNoteLanes:Array<Array<Note>> = [];
	var died:Bool = false;
	var canScore:Bool = true;
	var comboSprites:Array<FlxSprite>=[];

	var velocityMarkers:Array<Float>=[];

	public static var campaignScore:Int = 0;

	var defaultCamZoom:Float = 1.05;

	// how big to stretch the pixel art assets
	public static var daPixelZoom:Float = 6;

	var inCutscene:Bool = false;

	public var goldLoan:Float = 0;
	#if desktop
	// Discord RPC variables
	var storyDifficultyText:String = "";
	var iconRPC:String = "";
	var songLength:Float = 0;
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end
	
	function setupLuaSystem(){
		#if desktop
		if(luaModchartExists){
			lua = new LuaVM();
			lua.setGlobalVar("storyDifficulty",storyDifficulty);
			lua.setGlobalVar("chartName",songData.chartName);
			lua.setGlobalVar("songName",SONG.song);
			lua.setGlobalVar("displayName",songData.displayName);
			lua.setGlobalVar("curBeat",0);
			lua.setGlobalVar("curStep",0);
			lua.setGlobalVar("curDecBeat",0);
			lua.setGlobalVar("curDecStep",0);
			lua.setGlobalVar("songPosition",Conductor.songPosition);
			lua.setGlobalVar("bpm",Conductor.bpm);
			lua.setGlobalVar("crochet",Conductor.crochet);
			lua.setGlobalVar("stepCrochet",Conductor.stepCrochet);
			lua.setGlobalVar("XY","XY");
			lua.setGlobalVar("X","X");
			lua.setGlobalVar("Y","Y");
			lua.setGlobalVar("width",FlxG.width);
			lua.setGlobalVar("height",FlxG.height);

			lua.setGlobalVar("black",FlxColor.BLACK);
			lua.setGlobalVar("white",FlxColor.WHITE);

			var timerCount:Int = 0;
			Lua_helper.add_callback(lua.state,"startTimer", function(time: Float){
				// 1 = time
				// 2 = callback

				var name = 'timerCallbackNum${timerCount}';
				Lua.pushvalue(lua.state,2);
				Lua.setglobal(lua.state, name);

				new FlxTimer().start(time, function(t:FlxTimer){
					lua.call(name,[]);

				});

				timerCount++;

			});

			Lua_helper.add_callback(lua.state,"colorFromString", function(str:String){
				return Std.int(FlxColor.fromString(str));
			});

			Lua_helper.add_callback(lua.state,"doCountdown", function(?status:Int=3){
				doCountdown(status);
			});

			Lua_helper.add_callback(lua.state,"addQuick", function(name:String, val:Dynamic){
				FlxG.watch.addQuick(name, val);
			});

			Lua_helper.add_callback(lua.state,"log", function(string:String){
				FlxG.log.add(string);
			});

			Lua_helper.add_callback(lua.state,"playSound", function(sound:String,volume:Float=1,looped:Bool=false){
				var path = 'assets/songs/${PlayState.SONG.song.toLowerCase()}/$sound.${Paths.SOUND_EXT}';
				FlxG.sound.play(CoolUtil.getSound(path),volume,looped);
			});

			Lua_helper.add_callback(lua.state,"playInternalSound", function(sound:String,volume:Float=1,looped:Bool=false){
				FlxG.sound.play(Paths.sound(sound),volume,looped);
			});

			Lua_helper.add_callback(lua.state,"setVar", function(variable:String,val:Any){
				Reflect.setField(this,variable,val);
			});

			Lua_helper.add_callback(lua.state,"getVar", function(variable:String){
				return Reflect.field(this,variable);
			});

			Lua_helper.add_callback(lua.state,"setJudge", function(variable:String,val:Any){
				judgeMan.judgementCounter.set(variable,val);
			});

			Lua_helper.add_callback(lua.state,"getJudge", function(variable:String){
				return judgeMan.judgementCounter.get(variable);
			});

			Lua_helper.add_callback(lua.state,"setOption", function(variable:String,val:Any){
				Reflect.setField(currentOptions,variable,val);
			});

			Lua_helper.add_callback(lua.state,"getOption", function(variable:String){
				return Reflect.field(currentOptions,variable);
			});

			Lua_helper.add_callback(lua.state,"setBFAberration", function(val:Float){
				return bfAberration.setPercent(val);
			});

			Lua_helper.add_callback(lua.state,"setDadAberration", function(val:Float){
				return dadAberration.setPercent(val);
			});

			Lua_helper.add_callback(lua.state,"setHudAberration", function(val:Float){
				return hudAberration.setPercent(val);
			});

			Lua_helper.add_callback(lua.state,"compensateFPS", function(num:Float){ // prob need new name? idk
				return Main.adjustFPS(num);
			});

			Lua_helper.add_callback(lua.state,"newOpponent", function(x:Float, y:Float, ?character:String = "bf", ?spriteName:String){
				var char = new Character(x,y,character,false,!currentOptions.noChars);
				var name = "UnnamedOpponent"+unnamedLuaSprites;

				if(spriteName!=null)
					name=spriteName;
				else
					unnamedLuaSprites++;

				var lSprite = new LuaCharacter(char,name,spriteName!=null);
				var classIdx = Lua.gettop(lua.state)+1;
				lSprite.Register(lua.state);
				Lua.pushvalue(lua.state,classIdx);
				opponents.push(char);
				stage.layers.get("dad").add(char);
			});
			// TODO: Deprecate and make a new one with better control (layerName, etc)
			Lua_helper.add_callback(lua.state,"newSprite", function(?x:Int=0,?y:Int=0, ?drawBehind:Bool=false, ?autoAdd:Bool=false, ?spriteName:String){
				var sprite = new FlxSprite(x,y);
				var name = "UnnamedSprite"+unnamedLuaSprites;

				if(spriteName!=null)
					name=spriteName;
				else
					unnamedLuaSprites++;

				var lSprite = new LuaSprite(sprite,name,spriteName!=null);
				var classIdx = Lua.gettop(lua.state)+1;
				lSprite.Register(lua.state);
				Lua.pushvalue(lua.state,classIdx);
				if(drawBehind){
					stage.add(sprite);
				}else if(autoAdd){
					add(sprite);
				};
			});

			Lua_helper.add_callback(lua.state,"newCamera", function(?x:Int=0, ?y:Int=0,?cameraName:String){
				var cam = new FNFCamera(x,y);
				cam.bgColor = FlxColor.TRANSPARENT;
				var name = "UnnamedCamera"+unnamedLuaObjects;

				if(cameraName!=null) name=cameraName;
				else unnamedLuaObjects++;

				var lCam = new LuaCam(cam, name);
				var classIdx = Lua.gettop(lua.state)+1;
				lCam.Register(lua.state);
				Lua.pushvalue(lua.state,classIdx);
				FlxG.cameras.add(cam);

				trace('new camera named $name added!!');
			});


			var dirs = ["left","down","up","right"];
			for(dir in 0...playerStrums.length){
				var receptor = playerStrums.members[dir];
				new LuaReceptor(receptor, '${dirs[dir]}PlrNote').Register(lua.state);
			}
			for(dir in 0...dadStrums.length){
				var receptor = dadStrums.members[dir];
				new LuaReceptor(receptor, '${dirs[dir]}DadNote').Register(lua.state);
			}

			var luaModchart = new LuaModchart(modchart);

			bfLua = new LuaCharacter(boyfriend,"bf",true);
			gfLua = new LuaCharacter(gf,"gf",true);
			dadLua = new LuaCharacter(dad,"dad",true);

			var healthbar = new LuaHPBar(healthBar,"healthbar",true);
			var bfIcon = new LuaSprite(healthBar.iconP1,"iconP1",true);
			var dadIcon = new LuaSprite(healthBar.iconP2,"iconP2",true);

			var window = new LuaWindow();

			var luaRenderedNotes = new LuaGroup<Note>(renderedNotes,"renderedNotes",true);
			var luaGameCam = new LuaCam(FlxG.camera,"gameCam");
			var luaHUDCam = new LuaCam(camHUD,"HUDCam");
			var luaOtherCam = new LuaCam(camOther,"otherCam");
			var luaNotesCam = new LuaCam(camNotes,"notesCam");
			var luaSustainCam = new LuaCam(camSus,"holdCam");
			var luaReceptorCam = new LuaCam(camReceptor,"receptorCam");
			// TODO: a flat 'camera' object which'll affect the properties of every camera

			new LuaModMgr(modManager).Register(lua.state);

			defaultLuaClasses = [luaModchart,window,bfLua,gfLua,dadLua,bfIcon,dadIcon,luaGameCam,luaHUDCam,luaNotesCam,luaSustainCam,luaReceptorCam,luaRenderedNotes,healthbar,luaOtherCam];

			for(i in defaultLuaClasses)
				i.Register(lua.state);


			lua.errorHandler = function(error:String){
				FlxG.log.advanced(error, EngineData.LUAERROR, true);
			}

			// this catches compile errors
			try {
				lua.runFile(Paths.modchart(songData.chartName.toLowerCase()));
			}catch (e:Exception){
				FlxG.log.advanced(e, EngineData.LUAERROR, true);
			};

			if(luaModchartExists && lua!=null){
				Lua.getglobal(lua.state, "update");
				if(Lua.isfunction(lua.state,-1)==true){
					if(Main.getFPSCap()>180)
						Main.setFPSCap(180);

				}
			}
		}
		#end
	}

	var dialogueData: CustomDialogue.DialogueFile;
	var endDialogueData: CustomDialogue.DialogueFile;
	var cutsceneData:Cutscene.CutsceneFile;
	var endCutsceneData:Cutscene.CutsceneFile;

	override public function create()
	{
		camGame = new FNFCamera();
		camRating = new FNFCamera();
		camHUD = new FNFCamera();
		camNotes = new FNFCamera();
		camOverlay = new FNFCamera();
		camSus = new FNFCamera();
		camReceptor = new FNFCamera();
		camOther = new FNFCamera();

		FadeTransitionSubstate.nextCamera = camOther;
		super.create();

		modchart = new ModChart(this);
		#if desktop
		unnamedLuaSprites=0;
		#end
		currentPState=this;
		currentOptions = OptionUtils.options.clone();
		#if !debug
		if(isStoryMode){
			currentOptions.noFail=false;
		}
		#end
		#if NO_BOTPLAY
			currentOptions.botPlay=false;
		#end
		#if NO_FREEPLAY_MODS
			currentOptions.mMod=0;
			currentOptions.cMod=0;
			currentOptions.xMod=1;
			currentOptions.noFail=false;
		#end

		if (calibrating)
		{
			currentOptions.noteSkin = 'quants';
			originalOffset = currentOptions.noteOffset;
			currentOptions.noteOffset = 0;
			canPause=false;
			currentOptions.noStage = true;
			currentOptions.noChars = true;
			currentOptions.noFail = true;
			currentOptions.botPlay = false;
		}


		ScoreUtils.ghostTapping = currentOptions.ghosttapping;
		ScoreUtils.botPlay = currentOptions.botPlay;
		#if FORCED_JUDGE
		judgeMan = new JudgementManager(new JudgementManager.JudgementData(EngineData.defaultJudgementData));
		#else
		judgeMan = new JudgementManager(JudgementManager.getDataByName(currentOptions.judgementWindow));
		#end
		Conductor.safeZoneOffset = judgeMan.getHighestWindow();
		Conductor.calculate();
		ScoreUtils.wifeZeroPoint = judgeMan.getWifeZero();

		bindData = [
			OptionUtils.getKey(Control.LEFT),
			OptionUtils.getKey(Control.DOWN),
			OptionUtils.getKey(Control.UP),
			OptionUtils.getKey(Control.RIGHT),
		];

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		//lua = new LuaVM();
		#if cpp
			luaModchartExists = FileSystem.exists(Paths.modchart(songData.chartName.toLowerCase()));
		#end

		trace(luaModchartExists);
		judgeBin = new FlxTypedGroup<JudgeSprite>();
		comboBin = new FlxTypedGroup<ComboSprite>();
		judgeBin.add(new JudgeSprite());
		comboBin.add(new ComboSprite());
		grade = "N/A";
		hitNotes=0;
		totalNotes=0;
		accuracy=1;

		// var gameCam:FlxCamera = FlxG.camera;
		camHUD.bgColor.alpha = 0;
		camOverlay.bgColor.alpha = 0;
		camOther.bgColor.alpha = 0;
		camNotes.bgColor.alpha = 0;
		camRating.bgColor.alpha = 0;
		camSus.bgColor.alpha = 0;
		camReceptor.bgColor.alpha = 0;
		pauseHUD = new FNFCamera();
		pauseHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		if(!currentOptions.ratingOverNotes)
			FlxG.cameras.add(camRating);
		if(currentOptions.holdsBehindReceptors)
			FlxG.cameras.add(camSus);
		FlxG.cameras.add(camOverlay);
		FlxG.cameras.add(camReceptor);
		if(!currentOptions.holdsBehindReceptors)
			FlxG.cameras.add(camSus);
		FlxG.cameras.add(camNotes);
		if(currentOptions.ratingOverNotes)
			FlxG.cameras.add(camRating);

		FlxG.cameras.add(camHUD);
		FlxG.cameras.add(camOther);
		FlxG.cameras.add(pauseHUD);

		/*public var dadAberration:ChromaticAberrationEffect;
		public var bfAberration:ChromaticAberrationEffect;
		public var hudAberration:ChromaticAberrationEffect;*/
		hudAberration = new ChromaticAberrationEffect();
		bfAberration = new ChromaticAberrationEffect();
		dadAberration = new ChromaticAberrationEffect();
		modchart.addNoteEffect(hudAberration);

		FlxCamera.defaultCameras = [camGame];

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial');

		sliderVelocities = [];

		var speed = SONG.speed;
		if(!isStoryMode){
			var mMod = currentOptions.mMod<.1?speed:currentOptions.mMod;
			speed = currentOptions.cMod<.1?speed:currentOptions.cMod;
			speed *= currentOptions.xMod;
			if(speed<mMod){
				speed=mMod;
			}
		}

		SONG.initialSpeed = speed*.45;
		songSpeed = speed;
		for(vel in SONG.sliderVelocities)
			sliderVelocities.push(vel);

		for (section in SONG.notes)
		{
			var coolSection:Int = Std.int(section.lengthInSteps / 4);
			section.sectionNotes.sort((a,b)->Std.int(a[0]-b[0]));
			if(section.events!=null){
				section.events.sort((a,b)->Std.int(a.time-b.time));
				for(event in section.events){
					if(event.events!=null){
						for(ev in event.events){
							var daEvent = {
								time: event.time,
								args: ev.args,
								name: ev.name
							};
							eventPreInit(daEvent);
						}

					}else
						eventPreInit(event);
				}
			}
		}

		sliderVelocities.sort((a,b)->Std.int(a.startTime-b.startTime));
		mapVelocityChanges();

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);



		switch (songData.chartName.toLowerCase())
		{
			case 'tutorial':
				dialogue = ["Hey you're pretty cute.", 'U se the arrow keys to keep up \nwith me singing.'];
			case 'bopeebo':
				dialogue = [
					'HEY!',
					"You think you can just sing\nwith my daughter like that?",
					"If you want to date her...",
					"You're going to have to go \nthrough ME first!"
				];
			case 'fresh':
				dialogue = ["Not too shabby boy.", ""];
			case 'dadbattle':
				dialogue = [
					"gah you think you're hot stuff?",
					"If you can beat me here...",
					"Only then I will even CONSIDER letting you\ndate my daughter!"
				];
			default:
				/*try {
					dialogue = CoolUtil.coolTextFile2(File.getContent(Paths.dialogue(songData.chartName.toLowerCase() + "/dialogue")));
				} catch(e){
					trace("epic style " + e.message);
				}*/
				var suffix:String = '';
				if(storyDifficulty==3)suffix='Asshole';
				var dialogue = Paths.songJson(songData.chartName.toLowerCase() + "/dialogue" + suffix);
				#if sys
				if(FileSystem.exists(dialogue))
					dialogueData =cast Json.parse(File.getContent(dialogue));

				var eDialogue = Paths.songJson(songData.chartName.toLowerCase() + "/endDialogue" + suffix);
				if(FileSystem.exists(eDialogue))
					endDialogueData =cast Json.parse(File.getContent(eDialogue));

				var cutscene = Paths.songJson(songData.chartName.toLowerCase() + "/cutscene" + suffix);
				if (FileSystem.exists(cutscene))
					cutsceneData = cast Json.parse(File.getContent(cutscene));

				var eCutscene = Paths.songJson(songData.chartName.toLowerCase() + "/endCutscene" + suffix);
				if (FileSystem.exists(eCutscene))
					endCutsceneData = cast Json.parse(File.getContent(eCutscene));
				#else
				if (Assets.exists(dialogue))
					dialogueData = cast Json.parse(Assets.getText(dialogue));

				var eDialogue = Paths.songJson(songData.chartName.toLowerCase() + "/endDialogue" + suffix);
				if (Assets.exists(eDialogue))
					endDialogueData = cast Json.parse(Assets.getText(eDialogue));

				var cutscene = Paths.songJson(songData.chartName.toLowerCase() + "/cutscene" + suffix);
				if (Assets.exists(cutscene))
					cutsceneData = cast Json.parse(Assets.getText(cutscene));

				var eCutscene = Paths.songJson(songData.chartName.toLowerCase() + "/endCutscene" + suffix);
				if (Assets.exists(eCutscene))
					endCutsceneData = cast Json.parse(Assets.getText(eCutscene));
				#end

		}

		#if desktop
		// Making difficulty text for Discord Rich Presence.
		switch (storyDifficulty)
		{
			case 0:
				storyDifficultyText = "Easy";
			case 1:
				storyDifficultyText = "Normal";
			case 2:
				storyDifficultyText = "Hard";
			case 3:
				storyDifficultyText = "Stepped Up";
		}

		iconRPC = SONG.player2;

		// To avoid having duplicate images in Discord assets
		switch (iconRPC)
		{
			case 'senpai-angry':
				iconRPC = 'senpai';
			case 'monster-christmas':
				iconRPC = 'monster';
			case 'mom-car':
				iconRPC = 'mom';
		}

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		if (isStoryMode)
		{
			detailsText = "Story Mode ";
		}
		else
		{
			detailsText = "Freeplay ";
		}

		// String for when the game is paused
		detailsPausedText = "Paused - " + detailsText;

		// Updating Discord Rich Presence.
		DiscordClient.changePresence(detailsText + songData.displayName + " (" + storyDifficultyText + ")", iconRPC);
		#end
		try{
			vcrDistortionHUD = new VCRDistortionEffect();
			vcrDistortionGame = new VCRDistortionEffect();
		}catch(e:Any){
			trace(e);
		}

		noteModifier='base';
		uiModifier='base';
		curStage=SONG.stage==null?Stage.songStageMap.get(songData.chartName.toLowerCase()):SONG.stage;

		if(curStage==null){
			curStage='stage';
		}


		if(SONG.stage==null)
			SONG.stage = curStage;

		if (currentOptions.noStage || calibrating)
			curStage='blank';
		
		stage = new Stage(curStage,currentOptions);
		switch(curStage){
			case 'school' | 'schoolEvil':
			noteModifier='pixel';
			uiModifier='pixel';
			if(currentOptions.senpaiShaderStrength>0){ // they're on
				if(vcrDistortionHUD!=null){
					if(currentOptions.senpaiShaderStrength>=2){ // sempai shader strength
						switch(songData.chartName.toLowerCase()){
							case 'violets':
								vcrDistortionHUD.setVignetteMoving(false);
								vcrDistortionGame.setVignette(false);
								vcrDistortionGame.setGlitchModifier(.025);
								vcrDistortionHUD.setGlitchModifier(.025);
							case 'thorns':
								vcrDistortionGame.setGlitchModifier(.2);
								vcrDistortionHUD.setGlitchModifier(.2);
							case _: // default
								vcrDistortionHUD.setVignetteMoving(false);
								vcrDistortionGame.setVignette(false);
								vcrDistortionHUD.setDistortion(false);
								vcrDistortionGame.setDistortion(false);
						}
					}else{
						vcrDistortionHUD.setVignetteMoving(false);
						vcrDistortionGame.setVignette(false);
						vcrDistortionHUD.setDistortion(false);
						vcrDistortionGame.setDistortion(false);
					}
					vcrDistortionGame.setNoise(false);
					vcrDistortionHUD.setNoise(true);

					modchart.addCamEffect(vcrDistortionGame);
					modchart.addHudEffect(vcrDistortionHUD);
					modchart.addNoteEffect(vcrDistortionHUD);
				}
			}
		}

		/*ameCam3D = new RaymarchEffect();
		hudCam3D = new RaymarchEffect();
		noteCam3D = new RaymarchEffect();

		modchart.addCamEffect(gameCam3D);
		modchart.addHudEffect(hudCam3D);
		modchart.addNoteEffect(noteCam3D);*/


		if(SONG.noteModifier!=null)
			noteModifier=SONG.noteModifier;

		add(stage);

		FlxG.mouse.visible = false;


		var gfVersion:String = stage.gfVersion;

		if(!currentOptions.allowNoteModifiers){
			noteModifier='base';
		}
		if(SONG.player1=='bf-neb')
			gfVersion = 'lizzy';

		if(SONG.player1.contains('dickhead') && gfVersion=='gf')
			gfVersion = 'vera';



		if(currentOptions.potato==0){
			gfVersion='speakers';
			stage.defaultCamZoom = 1;
		}

		if(SONG.player1.contains('dickhead') && gfVersion=='speakers')
			gfVersion = 'suspeakers';
		gf = new Character(400, 130, gfVersion, false, !currentOptions.noChars);
		gf.scrollFactor.set(1,1);
		stage.gf=gf;

		dad = new Character(100, 100, SONG.player2, false, !currentOptions.noChars);
		if(SONG.song.toLowerCase()=='devoured')dad.hasMic = false;
		stage.dad=dad;
		boyfriend = new Character(770, 450, SONG.player1, true, !currentOptions.noChars);
		stage.boyfriend=boyfriend;
		

		switch (stage.curStage.toLowerCase())
		{
			case 'malvado':
			
				corruptedStage = new Stage("malvadoSide", currentOptions);
				uncorruptedStage = new Stage("devoured", currentOptions);
				uncorruptedStage.dadPosition.x -= 50;
				realStage = stage;
				memoryShader = new MemoryEffect();
				memoryShader.red = 1;
				memoryShader.green = 1;
				memoryShader.blue = 1;
				
				dad.shader = memoryShader.shader;
				boyfriend.shader = memoryShader.shader;
				
			case 'shop':
				if(storyDifficulty==3){
					closeupStage = new Stage("shopCloseup", currentOptions);
					realStage = stage;
				}
				
				dad.shader = dadAberration.shader;
				boyfriend.shader = bfAberration.shader;

			default:

		}

		if(currentOptions.opponentMode){
			boyfriend.isPlayer=false;
			dad.isPlayer=true;
			player=dad;
			nonPlayer=boyfriend;
		}else{
			player=boyfriend;
			nonPlayer=dad;
		}

		opponent=dad;
		stage.setPlayerPositions(boyfriend,dad,gf);

		dadX = dad.x;
		bfX = boyfriend.x;
		dadY = dad.y;
		bfY = boyfriend.y;

		defaultCamZoom=stage.defaultCamZoom;
		if(boyfriend.curCharacter=='spirit' && !currentOptions.noChars){
			var evilTrail = new FlxTrail(boyfriend, null, 4, 24, 0.3, 0.069);
			add(evilTrail);
		}
		if(dad.curCharacter=='spirit' && !currentOptions.noChars){
			var evilTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069);
			add(evilTrail);
		}
		if(SONG.player1=='bf-neb')
			boyfriend.y -= 75;

		add(gf);
		add(stage.layers.get("gf"));

		if(stage.curStage=='date'){
			add(boyfriend);
			add(stage.layers.get("boyfriend"));
			add(dad);
			add(stage.layers.get("dad"));
			add(stage.foreground);
		}else{
			add(dad);
			add(stage.layers.get("dad"));
			add(boyfriend);
			add(stage.layers.get("boyfriend"));
			add(stage.foreground);
		}

		add(stage.gameOverlay);
		stage.gameOverlay.cameras = [camOverlay];
		add(stage.overlay);
		stage.overlay.cameras = [camHUD];

		opponents.push(dad);
		switch(currentOptions.staticCam){
			case 1:
				focus='bf';
			case 2:
				focus='dad';
			case 3:
				focus = 'center';
		}

		if(currentOptions.noChars){
			focus = 'center';
			flexyMic = new FlxSprite(0, 0).makeGraphic(1, 1, FlxColor.TRANSPARENT); // just so it doesnt NOR
			remove(gf);
			remove(dad);
			remove(boyfriend);
		}else{
			flexyMic = new FlxSprite(0,0).loadGraphic(Paths.image(storyDifficulty==3?"suflexymic":"flexymic"));
			flexyMic.antialiasing=true;

			flexyMic.setGraphicSize(Std.int(flexyMic.width));
			flexyMic.x = dad.x + 378;
			flexyMic.y = dad.y + 80;
			if(dad.curCharacter.contains("dmp"))flexyMic.y += 85;
			flexyMic.visible=false;
			stage.layers.get("dad").add(flexyMic);
		}

		if (SONG.song.toLowerCase() == 'devoured')
		{
			dmpiikingOut = new FlxSprite(dad.x, dad.y);
			dmpiikingOut.antialiasing = true;
			dmpiikingOut.frames = Paths.getSparrowAtlas("dmpiiking_out");
			dmpiikingOut.animation.addByPrefix("omghestransguys", "transform", 24, false);
			dmpiikingOut.setGraphicSize(Std.int(dmpiikingOut.width * 0.8));
			dmpiikingOut.updateHitbox();
			dmpiikingOut.visible = false;
			dmpiikingOut.x = dad.x + 90;
			dmpiikingOut.y = dad.y - 475;
			dmpiikingOut.scrollFactor.set(1, 1);
			add(dmpiikingOut);
		}

		var doof:DialogueBox = new DialogueBox(false, dialogue);
		// doof.x += 70;
		// doof.y = FlxG.height * 0.5;
		doof.scrollFactor.set();
		doof.finishThing = startCountdown;

		Conductor.rawSongPos = -5000 + startPos + currentOptions.noteOffset;
		Conductor.songPosition=Conductor.rawSongPos;

		strumLine = new FlxSprite(0, 50).makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();

		strumLineNotes = new FlxTypedGroup<Receptor>();
		add(strumLineNotes);

		playerStrumLines = new FlxTypedGroup<FlxSprite>();
		opponentStrumLines = new FlxTypedGroup<FlxSprite>();
		#if desktop
		luaSprites = new Map<String, FlxSprite>();
		luaObjects = new Map<String, FlxBasic>();
		#end
		refNotes = new FlxTypedGroup<FlxSprite>();
		opponentRefNotes = new FlxTypedGroup<FlxSprite>();
		refReceptors = new FlxTypedGroup<FlxSprite>();
		opponentRefReceptors = new FlxTypedGroup<FlxSprite>();
		playerStrums = new FlxTypedGroup<Receptor>();
		dadStrums = new FlxTypedGroup<Receptor>();

		noteSplashes = new FlxTypedGroup<NoteSplash>();
		//var recyclableSplash = new NoteSplash(100,100);
		//recyclableSplash.alpha=0;
		//noteSplashes.add(recyclableSplash);

		add(noteSplashes);
		//add(judgeBin);

		// startCountdown();


		modManager = new ModManager(this);

		generateSong();

		// add(strumLine);

		camFollow = new FlxObject(0, 0, 1, 1);
		if (!currentOptions.noStage && !calibrating){
			if (uncorruptedStage != null)
			{
				remove(stage);
				stage = uncorruptedStage;
				add(stage);
				stage.setPlayerPositions(boyfriend, dad, gf);
			}
		}


		camFollow.setPosition(stage.centerX==-1?stage.camPos.x:stage.centerX,stage.centerY==-1?stage.camPos.y:stage.centerY);

		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}

		add(camFollow);
		FlxG.camera.follow(camFollow, LOCKON, Main.adjustFPS(.03));
		camRating.follow(camFollow,LOCKON,Main.adjustFPS(.03));
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow.getPosition());

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		healthBar = new Healthbar(0,FlxG.height*.9,boyfriend.iconName,dad.iconName,this,'health',0,2);
		healthBar.reverse = currentOptions.opponentMode;
		healthBar.smooth = currentOptions.smoothHPBar;
		healthBar.cancer = SONG.song.toLowerCase()=='violets';
		healthBar.scrollFactor.set();
		healthBar.screenCenter(X);
		if(currentOptions.healthBarColors)
			healthBar.setColors(dad.iconColor,boyfriend.iconColor);

		if(currentOptions.downScroll)
			healthBar.y = FlxG.height*.1;



		scoreTxt = new FlxText(healthBar.bg.x + healthBar.bg.width / 2 - 150, healthBar.bg.y + 25, SONG.song.toLowerCase() == 'violets'?1270:0, "", 20);
		scoreTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.scrollFactor.set();

		if(SONG.song.toLowerCase()=='violets'){
			scoreTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			scoreTxt.text = "Score: 0\nAccuracy: 0%";
			scoreTxt.y -= 80;
		}

		botplayTxt = new FlxText(0, 80, 0, "[BOTPLAY]", 30);
		botplayTxt.visible = ScoreUtils.botPlay;
		botplayTxt.cameras = [camHUD];
		botplayTxt.screenCenter(X);
		botplayTxt.setFormat(Paths.font("vcr.ttf"), 30, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		botplayTxt.scrollFactor.set();

		add(botplayTxt);

		/*
				makeAnimatedLuaSprite("ntCombo", "EngineStuff/NoteCombo", 0, 0)
		addAnimationByPrefix("ntCombo", "anim", " NoteComboTextAppearAndDisappear", 24, false)
		scaleObject("ntCombo", .56, .56)
		
		setObjectCamera("ntCombo", "hud")
		*/

		noteCancer = new FlxSprite();
		noteCancer.frames = Paths.getSparrowAtlas("cancer/NoteCombo");
		noteCancer.scale.set(.56, .56);
		noteCancer.animation.addByPrefix("anim", " NoteComboTextAppearAndDisappear", 24, false);
		noteCancer.cameras = [camHUD];
		
		if (currentOptions.downScroll)
			botplayTxt.y = FlxG.height - 80;

		if(calibrating){
			calibrationTxt = new FlxText(0, 120, 1280, "Calibrating Offset\nNew Offset: 0\nOld Offset: " + currentOptions.noteOffset, 30);
			calibrationTxt.cameras = [camHUD];
			calibrationTxt.screenCenter(X);
			calibrationTxt.setFormat(Paths.font("vcr.ttf"), 30, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
			calibrationTxt.scrollFactor.set();
			if (currentOptions.downScroll)
				calibrationTxt.y = FlxG.height - 120;
			add(calibrationTxt);
		}



		ratingCountersUI = new FlxSpriteGroup();
		merchantDia = new FlxSpriteGroup();
		/*presetTxt = new FlxText(0, FlxG.height/2-80, 0, "", 20);
		presetTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		presetTxt.scrollFactor.set();
		presetTxt.visible=false;*/

		highComboTxt = new FlxText(0, FlxG.height/2-60, 0, "", 20);
		highComboTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		highComboTxt.scrollFactor.set();
		var counterIdx:Int = 0;
		ratingCountersUI.add(highComboTxt);
		for(judge in judgeMan.getJudgements()){
			var offset = -40+(counterIdx*20);

			var txt = new FlxText(0, (FlxG.height/2)+offset, 0, "", 20);
			txt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
			txt.scrollFactor.set();
			ratingCountersUI.add(txt);
			counters.set(judge,txt);
			counterIdx++;
		}
		ratingCountersUI.visible = currentOptions.showCounters;

		highComboTxt.text = "Highest Combo: " + highestCombo;

		add(healthBar);
		add(scoreTxt);
		add(ratingCountersUI);
		updateJudgementCounters();

		strumLineNotes.cameras = [camReceptor];
		renderedNotes.cameras = [camNotes];
		//judgeBin.cameras = [camRating];
		noteSplashes.cameras = [camReceptor];
		healthBar.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		ratingCountersUI.cameras = [camHUD];
		doof.cameras = [camHUD];


		var centerP = new FlxSprite(0,0);
		centerP.screenCenter(XY);

		center = FlxPoint.get(centerP.x,centerP.y);

		upscrollOffset = 50;
		downscrollOffset = FlxG.height-165;

		// if (SONG.song == 'South')
		// FlxG.camera.alpha = 0.7;
		// UI_camera.zoom = 1;
		// cameras = [FlxG.cameras.list[1]];
		startingSong = true;

		var removing:Array<Note>=[];
		for(note in unspawnNotes){
			if(note.strumTime<startPos && !note.isSustainNote){
				removing.push(note);
			}
		}
		for(note in removing){
			unspawnNotes.remove(note);

			for(tail in note.tail){
				unspawnNotes.remove(tail);
				destroyNote(tail);
			}
			destroyNote(note);

		}

		shownAccuracy = 100;
		if(currentOptions.accuracySystem==1){ // ITG
			totalNotes = ScoreUtils.GetMaxAccuracy(noteCounter);
			shownAccuracy = 0;
		}

		if(currentOptions.backTrans>0){
			var overlay = new FlxSprite(0,0).makeGraphic(Std.int(FlxG.width*2),Std.int(FlxG.width*2),FlxColor.BLACK);
			overlay.screenCenter(XY);
			overlay.alpha = currentOptions.backTrans/100;
			overlay.scrollFactor.set();
			add(overlay);
		}

		if(dad.hasMic && dad.curCharacter.contains("dmp"))
			flexyMic.visible=true;

		if(isStoryMode && SONG.song.toLowerCase()!='noche'){
			if(dad.hasMic && !flexyMic.visible)
				flexyMic.visible=true;

		}

		var blackBG = new FlxSprite().makeGraphic(Std.int(FlxG.width*2),Std.int(FlxG.width*2),FlxColor.BLACK);
		blackBG.screenCenter(XY);
		merchantDia.add(blackBG);
		var pieces:Array<String> = ["im","not","finished","yet","merchant"];
		for(piece in pieces){
			var image = new FlxSprite().loadGraphic(Paths.image("didntcum/" + piece));
			image.antialiasing=true;
			image.visible=false;
			image.setGraphicSize(1280, 720);
			image.screenCenter(XY);
			merchantDiaMap.set(piece, image);
			merchantDia.add(image);
		}

		merchantOverlay = new FlxSprite().loadGraphic(Paths.image("didntcum/merchant"));
		merchantOverlay.antialiasing=true;
		merchantOverlay.visible=true;
		merchantOverlay.setGraphicSize(1280, 720);
		merchantOverlay.screenCenter(XY);
		merchantOverlay.cameras = [camOther];

		goldOverlay = new FlxSprite().loadGraphic(Paths.image("Gold_note_overlay"));
		goldOverlay.antialiasing=true;
		goldOverlay.visible=true;
		goldOverlay.alpha = 0;
		goldOverlay.setGraphicSize(1280, 720);
		goldOverlay.screenCenter(XY);
		goldOverlay.cameras = [camOther];
		add(goldOverlay);
		merchantDia.scrollFactor.set();
		merchantDia.cameras = [camOther];


		cum = new FlxSprite().loadGraphic(Paths.image("ballz"));
		cum.antialiasing=true;
		cum.visible=true;
		cum.scrollFactor.set();
		cum.setGraphicSize(1280, 720);
		cum.screenCenter(XY);
		cum.cameras = [camOther];

		cumShader = new GlitchEffect();
		cum.shader = cumShader.shader;

		grayscale = new GrayscaleEffect();
		modchart.addCamEffect(grayscale);
		modchart.addNoteEffect(grayscale);
		modchart.addHudEffect(grayscale);
		if (isStoryMode && !seenCutscene)
		{
			seenCutscene = true;
			doCutscenes();
		}
		else
		{
			switch (curSong.toLowerCase())
			{
				default:
					startCountdown();

			}
		}

		openfl.system.System.gc();
	}

	

	function doCutscenes(?ignoreVideo:Bool){
		switch (curSong.toLowerCase())
		{
			case 'devoured':
				if (dialogueData != null)
				{
					var black = new FlxSprite().makeGraphic(FlxG.width*2, FlxG.height*2, FlxColor.BLACK);
					black.cameras = [camHUD];
					add(black);
					var dialog = startDialog(dialogueData);
					dialog.finishCallback = function()
					{
						remove(dialog);
						FlxTween.tween(black, {alpha: 0}, 1, {
							ease: FlxEase.linear,
							onComplete: function(twn:FlxTween)
							{
								black.destroy();
							}
						});
						startCountdown();
					};
				}
				else
					startCountdown();
			case 'globetrotter':
				if(ignoreVideo || storyDifficulty==3){
					if (dialogueData != null)
					{
						var dialog = startDialog(dialogueData);
						dialog.finishCallback = function()
						{
							remove(dialog);
							startCountdown();
						};
					}
					else
						startCountdown();
				}else
					startVideo("flexy_edited_cutscene", function(){
						camHUD.flash(FlxColor.BLACK, 1, function(){
							if (dialogueData != null)
							{
								var dialog = startDialog(dialogueData);
								dialog.finishCallback = function(){
									remove(dialog);
									startCountdown();
								};
							}else
								startCountdown();
						}, true);
					});
			default:
				if (dialogueData != null)
				{
					var dialog = startDialog(dialogueData);
					dialog.finishCallback = function()
					{
						remove(dialog);
						startCountdown();
					};
				} else if(cutsceneData != null){
					var scene = startCutscene(cutsceneData);
					scene.finishCallback = function()
					{
						remove(scene);
						startCountdown();
					};
				}
				else
					startCountdown();
		}
	}

	function startDialog(data: CustomDialogue.DialogueFile){
		var dialog = new CustomDialogue(data);
		dialog.scrollFactor.set();
		dialog.cameras = [camHUD];
		add(dialog);
		return dialog;
	}

	function startCutscene(data:Cutscene.CutsceneFile)
	{
		var dialog = new Cutscene(data);
		dialog.scrollFactor.set();
		dialog.cameras = [camHUD];
		add(dialog);
		return dialog;
	}


	function AnimWithoutModifiers(a:String){
		var reg1 = new EReg(".+Hold","i");
		var reg2 = new EReg(".+Repeat","i");
		return reg1.replace(reg2.replace(a,""),"");
	}

	public function swapCharacter(who:String, newCharacter:String){
		if(OptionUtils.options.potato<=0)return null;
		if(currentOptions.noChars)return null;
		var sprite:Character = null;
		switch(who){
			case 'dad':
				sprite=dad;
			case 'bf' | 'boyfriend':
				who='bf';
				sprite=boyfriend;
			case 'gf' | 'girlfriend':
				who='gf';
				sprite=gf;
		}
		if(sprite!=null){
			var newSprite:Character;
			var spriteX = sprite.x;
			var spriteY = sprite.y;
			var offX = sprite.posOffset.x;
			var offY = sprite.posOffset.y;

			var newX = spriteX - offX;
			var newY = spriteY - offY;

			var currAnim:String = "idle";
			if(sprite.animation.curAnim!=null)
				currAnim=sprite.animation.curAnim.name;
			remove(sprite);
			// TODO: Make this BETTER!!!
			var isPlayer = sprite.isPlayer;
			if(who=="bf"){
				boyfriend = new Character(newX,newY,newCharacter,true,boyfriend.hasSprite);
				newSprite = boyfriend;
				#if desktop
				if(bfLua!=null)bfLua.sprite = boyfriend;
				#end
				//iconP1.changeCharacter(newCharacter);
			}else if(who=="dad"){
				var index = opponents.indexOf(dad);
				if(index>=0)opponents.remove(dad);
				dad = new Character(newX,newY,newCharacter,false,dad.hasSprite);
				newSprite = dad;
				#if desktop
				if(dadLua!=null)dadLua.sprite = dad;
				#end
				if(index>=0)opponents.insert(index,dad);
				if(SONG.song.toLowerCase()=='devoured')dad.hasMic = false;

				flexyMic.visible = dad.hasMic;

				//iconP2.changeCharacter(newCharacter);
			}else if(who=="gf"){
				gf = new Character(newX,newY,newCharacter, false ,gf.hasSprite);
				newSprite = gf;
				#if desktop
				if(gfLua!=null)gfLua.sprite = gf;
				#end
			}else{
				newSprite = new Character(newX,newY,newCharacter);
			}

			if(player==sprite)player=newSprite;
			if(nonPlayer==sprite)nonPlayer=newSprite;

			newSprite.isPlayer = isPlayer;
			newSprite.x += newSprite.posOffset.x;
			newSprite.y += newSprite.posOffset.y;
			healthBar.setIcons(boyfriend.iconName,dad.iconName);
			if(currentOptions.healthBarColors)
				healthBar.setColors(dad.iconColor,boyfriend.iconColor);

			add(newSprite);
			if(currAnim!="idle" && !currAnim.startsWith("dance")){
				newSprite.playAnim(currAnim,true);
			}else if(currAnim=='idle' || currAnim.startsWith("dance")){
				newSprite.dance();
			}

			var daStage = stage;
			if(realStage!=null)daStage=realStage;

			switch (daStage.curStage.toLowerCase())
			{
				case 'malvado':
					dad.shader = memoryShader.shader;
					boyfriend.shader = memoryShader.shader;
				default:
					dad.shader = dadAberration.shader;
					boyfriend.shader = bfAberration.shader;
			}

			return newSprite;

		}
		return null;
	}
	// shit bandaid solution

	public function swapCharacterByLuaName(spriteName:String,newCharacter:String){
		#if desktop
		if(OptionUtils.options.potato<=0)return null;
		var sprite = luaSprites[spriteName];
		if(spriteName == 'bf' || spriteName == 'gf' || spriteName =='dad'){
			var newChar = swapCharacter(spriteName,newCharacter);
			luaSprites[spriteName] = newChar;
			return;
		}
		if(sprite!=null){
			var newSprite:Character;
			var spriteX = sprite.x;
			var spriteY = sprite.y;
			var offX = sprite.posOffset.x;
			var offY = sprite.posOffset.y;

			var newX = spriteX - offX;
			var newY = spriteY - offY;

			var currAnim:String = "idle";
			if(sprite.animation.curAnim!=null)
				currAnim=sprite.animation.curAnim.name;
			remove(sprite);
			// TODO: Make this BETTER!!!
			newSprite = new Character(newX,newY,newCharacter);


			newSprite.x += newSprite.posOffset.x;
			newSprite.y += newSprite.posOffset.y;
			healthBar.setIcons(boyfriend.iconName,dad.iconName);
			if(currentOptions.healthBarColors)
				healthBar.setColors(dad.iconColor,boyfriend.iconColor);

			luaSprites[spriteName]=newSprite;
			add(newSprite);
			if(currAnim!="idle" && !currAnim.startsWith("dance")){
				newSprite.playAnim(currAnim,true);
			}else if(currAnim=='idle' || currAnim.startsWith("dance")){
				newSprite.dance();
			}


		}
		#end
	}

	function schoolIntro(?dialogueBox:DialogueBox):Void
	{
		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);

		var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
		red.scrollFactor.set();

		var senpaiEvil:FlxSprite = new FlxSprite();
		senpaiEvil.frames = Paths.getSparrowAtlas('weeb/senpaiCrazy');
		senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
		senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * 6));
		senpaiEvil.scrollFactor.set();
		senpaiEvil.updateHitbox();
		senpaiEvil.screenCenter();

		if (songData.chartName.toLowerCase() == 'violets' || songData.chartName.toLowerCase() == 'thorns')
		{
			remove(black);

			if (songData.chartName.toLowerCase() == 'thorns')
			{
				add(red);
			}
		}

		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			black.alpha -= 0.15;

			if (black.alpha > 0)
			{
				tmr.reset(0.3);
			}
			else
			{
				if (dialogueBox != null)
				{
					inCutscene = true;

					if (songData.chartName.toLowerCase() == 'thorns')
					{
						add(senpaiEvil);
						senpaiEvil.alpha = 0;
						new FlxTimer().start(0.3, function(swagTimer:FlxTimer)
						{
							senpaiEvil.alpha += 0.15;
							if (senpaiEvil.alpha < 1)
							{
								swagTimer.reset();
							}
							else
							{
								senpaiEvil.animation.play('idle');
								FlxG.sound.play(Paths.sound('Senpai_Dies'), 1, false, null, true, function()
								{
									remove(senpaiEvil);
									remove(red);
									FlxG.camera.fade(FlxColor.WHITE, 0.01, true, function()
									{
										add(dialogueBox);
									}, true);
								});
								new FlxTimer().start(3.2, function(deadTime:FlxTimer)
								{
									FlxG.camera.fade(FlxColor.WHITE, 1.6, false);
								});
							}
						});
					}
					else
					{
						add(dialogueBox);
					}
				}
				else
					startCountdown();

				remove(black);
			}
		});
	}

	var startTimer:FlxTimer;
	var perfectMode:Bool = false;

	public function startVideo(name:String, ?finishCallback:Void->Void) // stolen from psych <3
	{
		inCutscene = true;

		var filepath:String = Paths.video(name);
		#if sys
		if (!FileSystem.exists(filepath))
		#else
		if (!Assets.exists(filepath))
		#end
		{
			FlxG.log.warn('Couldnt find video file: ' + name);
			if(finishCallback!=null)
				finishCallback();
			else
				doCutscenes(true);
			return;
		}

		var video:MP4Handler = new MP4Handler();
		video.playVideo(filepath);
		video.finishCallback = function()
		{
			#if web
			remove(video);
			#end
			if (finishCallback != null)
				finishCallback();
			else
				doCutscenes(true);
			return;
		}
		#if web
		add(video);
		#end
	}

	function startCountdown():Void
	{
		var countdownStatus:Int = 3; // 3 = show entire countdown. 2 = only sounds, 1 = non-visual countdown, 0 = skip countdown
		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN,keyPress);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP,keyRelease);

		inCutscene = false;

		generateStaticArrows(0, 1);
		generateStaticArrows(1, 0);

		modManager.setReceptors();
		modManager.registerModifiers();

		var toRemove:Array<Section.Event> = [];
		for(event in eventSchedule){
			var shouldKeep = eventPostInit(event);
			if(!shouldKeep)toRemove.push(event);
		}
		for(shit in toRemove)
			eventSchedule.remove(shit);

		if(stage.curStage=='date'){
			modManager.set('alpha', 100, 1);
			if(currentOptions.opponentMode)modManager.set('opponentSwap', 100, 0);
		}

		#if FORCE_LUA_MODCHARTS
		setupLuaSystem();
		#else
		if(currentOptions.loadModcharts)
			setupLuaSystem();
		#end

		if(!modManager.exists("reverse")){
			var y = upscrollOffset;
			if(scrollSpeed<0)
				y = downscrollOffset;

			trace(y);

			for(babyArrow in strumLineNotes.members){
				babyArrow.desiredY+=y;
			}
		}

		if(currentOptions.staticCam==0)
			focus = 'center';
		updateCamFollow();

		talking = false;
		startedCountdown = true;
		Conductor.rawSongPos = startPos;
		Conductor.rawSongPos -= Conductor.crochet * 5;
		Conductor.songPosition=Conductor.rawSongPos + currentOptions.noteOffset;
		updateCurStep();
		updateBeat();

		if(startPos>0)canScore=false;
		#if desktop
		if(luaModchartExists && lua!=null){
			var luaStatus:Dynamic = lua.call("startCountdown",[]);
			switch(luaStatus){
				case 'all' | 3:
					countdownStatus = 3;
				case 'sound' | 2:
					countdownStatus = 2;
				case 'hidden' | 1:
					countdownStatus = 1;
				case 'skip' | 0:
					countdownStatus = 0;
				case 'stop' | -1:
					countdownStatus = -1;
				default:
					countdownStatus = 3;
			}
		}
		#end

		startTimer = new FlxTimer();

		if(countdownStatus==-1)return;

		doCountdown(countdownStatus);
	}

	function doCountdown(countdownStatus:Int=3){
		if(startTimer==null)
			startTimer = new FlxTimer();


		if(countdownStatus==0){
			Conductor.rawSongPos = startPos;
			Conductor.songPosition=Conductor.rawSongPos + currentOptions.noteOffset;
			updateCurStep();
			updateBeat();
			return;
		}

		var songName:String = SONG.song.toLowerCase();
		if(storyDifficulty==3)
			songName += "-su";
		
		
		var popup:FlxSprite = new FlxSprite().loadGraphic(Paths.image('songCredits/${songName}'));
		popup.x -= popup.width;
		popup.y = (FlxG.height / 2 - popup.height / 2) + 200;
		popup.antialiasing = true;
		popup.scrollFactor.set();
		popup.cameras = [camHUD];
		tween(popup, {x: 25}, 1, {
			ease: FlxEase.quartInOut,
			startDelay: 1,
			onComplete: function(twn:FlxTween)
			{
				tween(popup, {x: -popup.width}, 1, {
					ease: FlxEase.quartInOut,
					startDelay: 2,
					onComplete: function(twn:FlxTween)
					{
						popup.destroy();
					}
				});
			}
		});
		add(popup);


		if (songName.contains("gran-venta"))
		{
			var popup:FlxSprite = new FlxSprite().loadGraphic(Paths.image('note popup'));
			popup.x = 450;
			popup.antialiasing = true;
			popup.scrollFactor.set();
			popup.cameras = [camHUD];
			tween(popup, {x: 0}, 1, {
				ease: FlxEase.quartInOut,
				startDelay: 1,
				onComplete: function(twn:FlxTween)
				{
					tween(popup, {x: 450}, 1, {
						ease: FlxEase.quartInOut,
						startDelay: 5,
						onComplete: function(twn:FlxTween)
						{
							popup.destroy();
						}
					});
				}
			});

			add(popup);
		}


		var swagCounter:Int = 0;
		startTimer.start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{	
			#if desktop
			if(luaModchartExists && lua!=null)
				lua.call("countdown",[swagCounter]);
			#end

			if(dad.animation.curAnim==null || dad.animation.curAnim.name!='intro' || dad.animation.curAnim.finished)
				dad.dance();
			
			gf.dance();
			boyfriend.dance();
			for(opp in opponents){
				if(opp!=dad)opp.dance();
			}

			var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
			introAssets.set('default', ['ready', "set", "go"]);
			introAssets.set('pixel', ['pixelUI/ready-pixel', 'pixelUI/set-pixel', 'pixelUI/date-pixel']);
			introAssets.set('corrupted', ['corrupted_ready', 'corrupted_set', 'corrupted_go']);
			var introAlts:Array<String> = introAssets.get('default');
			var altSuffix:String = "";

			for (value in introAssets.keys())
			{
				if (value == uiModifier)
				{
					introAlts = introAssets.get(value);
					if(value=='pixel')altSuffix = '-pixel';
				}
			}

			if(SONG.song.toLowerCase()=='devoured' || SONG.song.toLowerCase()=='malvado'){
				introAlts = introAssets.get("corrupted");
				altSuffix = '-corr';
			}

			if(countdownStatus>1){
				switch (swagCounter)

				{
					case 0:
						if(countdownStatus>=2)
							FlxG.sound.play(Paths.sound('intro3${altSuffix}'), 0.6);
					case 1:
						if(flexyMic.visible==false){
							if(dad.curCharacter.contains("flexy") && dad.animation.getByName("intro")!=null){
								dad.playAnim("intro",true);
							}
						}

						if(countdownStatus>=3){

							var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
							ready.cameras=[camHUD];
							ready.scrollFactor.set();
							ready.updateHitbox();

							if (altSuffix=='-pixel')
								ready.setGraphicSize(Std.int(ready.width * daPixelZoom));

							ready.screenCenter();
							add(ready);
							FlxTween.tween(ready, {alpha: 0}, Conductor.crochet / 1000, {
								ease: FlxEase.cubeInOut,
								onComplete: function(twn:FlxTween)
								{
									ready.destroy();
								}
							});
						}
						if(countdownStatus>=2)
							FlxG.sound.play(Paths.sound('intro2${altSuffix}'), 0.6);
					case 2:
						if(countdownStatus>=3){
							var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
							set.scrollFactor.set();

							if (altSuffix=='-pixel')
								set.setGraphicSize(Std.int(set.width * daPixelZoom));

							set.cameras=[camHUD];
							set.screenCenter();
							add(set);
							FlxTween.tween(set, {alpha: 0}, Conductor.crochet / 1000, {
								ease: FlxEase.cubeInOut,
								onComplete: function(twn:FlxTween)
								{
									set.destroy();
								}
							});
						}
						if(countdownStatus>=2)
							FlxG.sound.play(Paths.sound('intro1${altSuffix}'), 0.6);
					case 3:
						if(countdownStatus>=3){
							var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
							go.scrollFactor.set();

							if (altSuffix=='-pixel')
								go.setGraphicSize(Std.int(go.width * daPixelZoom));

							go.cameras=[camHUD];

							go.updateHitbox();

							go.screenCenter();
							add(go);
							FlxTween.tween(go, {alpha: 0}, Conductor.crochet / 1000, {
								ease: FlxEase.cubeInOut,
								onComplete: function(twn:FlxTween)
								{
									go.destroy();
								}
							});
						}
						if(countdownStatus>=2)
							FlxG.sound.play(Paths.sound('introGo${altSuffix}'), 0.6);
					case 4:
				}
			}

			swagCounter += 1;
		}, 5);
	}
	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	function startSong():Void
	{

		startingSong = false;

		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		inst.play();
		vocals.play();
		inst.time = startPos;
		vocals.time = startPos;
		Conductor.rawSongPos = startPos;
		Conductor.songPosition=Conductor.rawSongPos + currentOptions.noteOffset;
		updateCurStep();
		updateBeat();

		if(FlxG.sound.music!=null){
			FlxG.sound.music.stop();
		}

		#if desktop
		// Song duration in a float, useful for the time left feature
		songLength = inst.length;

		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText + songData.displayName + " (" + storyDifficultyText + ")", grade + " | Acc: " + CoolUtil.truncateFloat(accuracy*100,2) + "%", iconRPC, true, songLength);
		#end
	}

	var debugNum:Int = 0;

	function eventPostInit(event: Event):Bool
	{
		switch(event.name){
			case 'Set Modifier':
				var step = Conductor.getStep(event.time);
				var player:Int = 0;
				switch(event.args[2]){
					case 'player':
						player = 0;
					case 'opponent':
						player = 1;
					case 'both':
						player = -1;
				}
				modManager.queueSet(step, event.args[0], event.args[1], player);
				return false;
			case 'Ease Modifier':
				var step = Conductor.getStep(event.time);
				var player:Int = 0;
				switch(event.args[4]){
					case 'player':
						player = 0;
					case 'opponent':
						player = 1;
					case 'both':
						player = -1;
				}
				modManager.queueEase(step, step+event.args[2], event.args[0], event.args[1], event.args[3], player);
				return false;
			default:
			// nothing
		}
		return true;
	}


	function eventPreInit(event:Event){
		switch(event.name){
			case 'Scroll Velocity':
				switch(event.args[0]){
					case 'mult':
						var multiplier:Float = event.args[1];
						sliderVelocities.push({
							startTime: event.time + currentOptions.visualOffset,
							multiplier: multiplier
						});
					case 'constant':
						sliderVelocities.push({
							startTime: event.time + currentOptions.visualOffset,
							multiplier: event.args[1] / songSpeed
						});
				}
		}
	}

	function cacheCharacter(charName:String, isPlayer:Bool=false){
		if(OptionUtils.options.potato<=0)return;
		if (currentOptions.noChars)
			return;
		var cache = new Character(0, 0, charName, isPlayer);
		cache.alpha=1/9999;
		add(cache);
		//remove(cache);
	}

	function eventInit(event: Event):Bool
	{
		switch(event.name){	
			case 'Polaroid':
				if (malvadoPolaroid.length==0){
					polaroids = new FlxSpriteGroup();
					polaroids.scrollFactor.set();
					polaroids.cameras = [camOther];
					for (i in 1...6)
					{
						var image = new FlxSprite().loadGraphic(Paths.image('malvado/memories/Polaroid${i}', 'fiesta'));
						image.antialiasing = true;
						image.visible = false;
						image.setGraphicSize(Std.int(image.width * 0.9));
						image.screenCenter(XY);
						malvadoPolaroid.push(image);
						polaroids.add(image);
					}
				}
			case 'Gran Venta Purple':
				cacheCharacter("purplegf",false);
				if(storyDifficulty==3){
					cacheCharacter("purpledickhead",true);
					cacheCharacter("purple-erect-merchant",false);
				}else{
					cacheCharacter("purplebf",true);
					cacheCharacter("purplemerchant",false);
				}
			case 'Everybodys Comin':
				cacheCharacter("skelebf");
				cacheCharacter("dmpoutline");
			case 'The Skeleton Appears':
				cacheCharacter("dmp",true);
			case 'Change Character':
				cacheCharacter(event.args[1],event.args[0]=='bf');
			case 'Set Modifier':
				var step = Conductor.getStep(event.time);
				var player:Int = 0;
				switch(event.args[2]){
					case 'player':
						player = 0;
					case 'opponent':
						player = 1;
					case 'both':
						player = -1;
				}
				modManager.queueSet(step, event.args[0], event.args[1], player);
				return false;
			case 'Ease Modifier':
				var step = Conductor.getStep(event.time);
				var player:Int = 0;
				switch(event.args[4]){
					case 'player':
						player = 0;
					case 'opponent':
						player = 1;
					case 'both':
						player = -1;
				}
				modManager.queueEase(step, step+event.args[2], event.args[0], event.args[1], event.args[3], player);
				return false;
			default:
			// nothing
		}
		return true;
	}

	private function destroyNote(daNote:Note){
		daNote.active = false;
		daNote.visible = false;

		daNote.kill();

		renderedNotes.remove(daNote,true);
		if(daNote.mustPress)
			playerNotes.remove(daNote);


		if(daNote.parent!=null && daNote.parent.tail.contains(daNote))
			daNote.parent.tail.remove(daNote);


		if(daNote.parent!=null && daNote.parent.unhitTail.contains(daNote))
			daNote.parent.unhitTail.remove(daNote);

		//daNote.destroy();
	}

	private function generateSong():Void
	{

		hitNotes = 0;
		totalNotes = 0;
		dontSync = false;
		// FlxG.log.add(ChartParser.parse());

		//noteSkinJson(key:String, ?library:String='skins', ?skin:String='default', modifier:String='base', ?useOpenFLAssetSystem:Bool=true):FlxGraphicAsset{
		noteCounter.clear();
		noteCounter.set("holdTails",0);
		noteCounter.set("taps",0);

		// STUPID AMERICANS I WANNA NAME THE FILE BEHAVIOUR BUT I CANT
		// DUMB FUCKING AMERICANS CANT JUST ADD A 'U' >:(

		Note.noteBehaviour = Json.parse(Paths.noteSkinText("behaviorData.json",'skins',currentOptions.noteSkin,noteModifier));

		var dynamicColouring:Null<Bool> = Note.noteBehaviour.receptorAutoColor;
		if(dynamicColouring==null)dynamicColouring=false;
		Receptor.dynamicColouring=dynamicColouring;



		var songData = SONG;
		Conductor.changeBPM(SONG.bpm);

		curSong = SONG.song;

		switch(curSong.toLowerCase()){
			case 'devoured':
				if(stage.orangeBG != null)stage.orangeBG.visible = false;
				hpDrain = judgeMan.getJudgementHealth('sick') / 3;
			case 'malvado':
				hpDrain = judgeMan.getJudgementHealth('sick');
			case 'globetrotter':
				if(storyDifficulty == 3)
					hpDrain = judgeMan.getJudgementHealth('sick') / 3;
				
		}

		if(vocals==null){
			if (SONG.needsVoices){
				vocals = new FlxSound().loadEmbedded(CoolUtil.getSound('${Paths.voices(SONG.song, storyDifficulty==3?"Erect":"")}'));
				//vocals = new FlxSound().loadEmbedded(Paths.voices(SONG.song));
			}else
				vocals = new FlxSound();
		}

		if(inst==null){

			inst = new FlxSound().loadEmbedded(CoolUtil.getSound('${Paths.inst(SONG.song, storyDifficulty==3?"Erect":"")}'));
			//inst = new FlxSound().loadEmbedded(Paths.inst(SONG.song));
			inst.looped=false;
	

			if(currentOptions.noteOffset==0 && !calibrating)
				inst.onComplete = finishSong;
			else
				inst.onComplete = function(){
					dontSync=true;
				};
			
			FlxG.sound.list.add(vocals);
			FlxG.sound.list.add(inst);
		}

		inst.time = startPos;
		vocals.time = startPos;

		Conductor.songLength = inst.length;

		vocals.looped=false;
		if(renderedNotes==null){
			renderedNotes = new FlxTypedGroup<Note>();
			add(renderedNotes);
		}

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = SONG.notes;

		var playerCounter:Int = 0;

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped
		/*for(idx in 0...4){ // TODO: 6K OR 7K MODE!!
			if(idx==4)break;
			noteLanes[idx]=[];
			susNoteLanes[idx]=[];

		}*/
		scrollSpeed = 1;//(currentOptions.downScroll?-1:1);
		var setupSplashes:Array<String>=[];
		var loadingSplash = new NoteSplash(0,0);
		loadingSplash.visible=false;

		var lastBFNotes:Array<Note> = [null,null,null,null];
		var lastDadNotes:Array<Note> = [null,null,null,null];
		var startStep = Conductor.getStep(startPos);
		for (section in noteData)
		{
			section.sectionNotes.sort((a,b)->Std.int(a[0]-b[0]));
			if(section.events!=null){
				section.events.sort((a,b)->Std.int(a.time-b.time));
				for(event in section.events){
					if(event.events!=null){
						var pushingEvents = [];
						for(ev in event.events){
							var shouldKeep = eventInit(ev);
							if(shouldKeep){
								pushingEvents.push({
									time: event.time,
									args: ev.args,
									name: ev.name
								});
							}
							for(e in pushingEvents)eventSchedule.push(e);
							//if(shouldSchedule)eventSchedule.push(event);
						}
					}else{
						var shouldSchedule = eventInit(event);
						if(shouldSchedule)eventSchedule.push(event);
					}
				}
			}
			for (songNotes in section.sectionNotes)
			{
				if(songNotes[0]==null)continue;
				var daStrumTime:Float = songNotes[0];
				var daNoteData:Int = Std.int(songNotes[1] % 4);
				var gottaHitNote:Bool = section.mustHitSection;
				if (songNotes[1] > 3)
				{
					gottaHitNote = !section.mustHitSection;
				}


				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				if(currentOptions.opponentMode)
					gottaHitNote=!gottaHitNote;

				var swagNote:Note = new Note(daStrumTime, daNoteData, currentOptions.noteSkin, noteModifier, EngineData.noteTypes[songNotes[3]], oldNote, false, getPosFromTime(daStrumTime));
				swagNote.sustainLength = songNotes[2];
				swagNote.scrollFactor.set(0, 0);
				swagNote.shitId = unspawnNotes.length;
				if(!setupSplashes.contains(swagNote.graphicType) && gottaHitNote){
					loadingSplash.setup(swagNote);
					setupSplashes.push(swagNote.graphicType);
				}

				if(gottaHitNote){
					var lastBFNote = lastBFNotes[swagNote.noteData];
					if(lastBFNote!=null){
						if (Math.abs(swagNote.strumTime - lastBFNote.strumTime) <= 6 ){
							swagNote.kill();
							continue;
						}
					}
					lastBFNotes[swagNote.noteData]=swagNote;
				}else{
					swagNote.causesMiss=false;
					var lastDadNote = lastDadNotes[swagNote.noteData];
					if(lastDadNote!=null){
						if (Math.abs(swagNote.strumTime - lastDadNote.strumTime) <= 6 ){
							swagNote.kill();
							continue;
						}
					}
					lastDadNotes[swagNote.noteData]=swagNote;
				}
				if(!swagNote.canHold)swagNote.sustainLength=0;

				var noteStep = Conductor.getStep(swagNote.strumTime);
				if(storyDifficulty==3 && SONG.song.toLowerCase()=='gran-venta'){
					if(noteStep > 1408 && startStep<1408){
						swagNote.invisible=true;
					}
				}
				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;

				unspawnNotes.push(swagNote);

				if(Math.floor(susLength)>0){
					for (susNote in 0...Math.floor(susLength))
					{
						oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
						var sussy = daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet;
						var sustainNote:Note = new Note(sussy, daNoteData, currentOptions.noteSkin, noteModifier, EngineData.noteTypes[songNotes[3]], oldNote, true, getPosFromTime(sussy));
						sustainNote.parent = swagNote;
						sustainNote.invisible = swagNote.invisible;
						sustainNote.cameras = [camSus];
						sustainNote.scrollFactor.set();
						unspawnNotes.push(sustainNote);
						sustainNote.shitId = unspawnNotes.length;
						sustainNote.segment = swagNote.tail.length;
						swagNote.tail.push(sustainNote);
						swagNote.unhitTail.push(sustainNote);

						sustainNote.mustPress = gottaHitNote;
						if(!gottaHitNote)sustainNote.causesMiss=false;

						if (sustainNote.mustPress)
						{
							if(sustainNote.noteType=='default'){
								noteCounter.set("holdTails",noteCounter.get("holdTails")+1);
							}else{
								if(!noteCounter.exists(sustainNote.noteType + "holdTail") )
									noteCounter.set(sustainNote.noteType + "holdTail",0);

								noteCounter.set(sustainNote.noteType + "holdTail",noteCounter.get(sustainNote.noteType + "holdTail")+1);
							}
							sustainNote.x += FlxG.width / 2; // general offset
							sustainNote.defaultX = sustainNote.x;
						}
					}
				}

				swagNote.mustPress = gottaHitNote;

				if (swagNote.mustPress)
				{
					if(swagNote.noteType=='default'){
						noteCounter.set("taps",noteCounter.get("taps")+1);
					}else{
						if(!noteCounter.exists(swagNote.noteType) )
							noteCounter.set(swagNote.noteType,0);

						noteCounter.set(swagNote.noteType,noteCounter.get(swagNote.noteType)+1);
					}
					swagNote.x += FlxG.width / 2; // general offset
					swagNote.defaultX = swagNote.x;
				}
				else {}
			}
			daBeats += 1;
		}

		// trace(unspawnNotes.length);
		// playerCounter += 1;

		unspawnNotes.sort(sortByShit);

		if(eventSchedule.length>1)
			eventSchedule.sort(sortByEvents);


		generatedMusic = true;

		updateAccuracy();
	}

	function sortByEvents(Obj1:Event, Obj2:Event):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.time, Obj2.time);
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	function sortByStrum(wat:Int, Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.DESCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	function sortByOrder(wat:Int, Obj1:FNFSprite, Obj2:FNFSprite):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.zIndex, Obj2.zIndex);
	}

	function sortByZ(wat:Int, Obj1:FNFSprite, Obj2:FNFSprite):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.z, Obj2.z);
	}

	// ADAPTED FROM QUAVER!!!
	// https://github.com/Quaver/Quaver
	// https://github.com/Quaver/Quaver
	// https://github.com/Quaver/Quaver
	function mapVelocityChanges(){
		if(sliderVelocities.length==0)
			return;

		var pos:Float = sliderVelocities[0].startTime*(SONG.initialSpeed);
		velocityMarkers.push(pos);
		for(i in 1...sliderVelocities.length){
			pos+=(sliderVelocities[i].startTime-sliderVelocities[i-1].startTime)*(SONG.initialSpeed*sliderVelocities[i-1].multiplier);
			velocityMarkers.push(pos);
		}
	};
	// https://github.com/Quaver/Quaver
	// https://github.com/Quaver/Quaver
	// https://github.com/Quaver/Quaver
	// ADAPTED FROM QUAVER!!!

	private function generateStaticArrows(player:Int, pN:Int):Void
	{
		for (i in 0...4)
		{
			var dirs = ["left","down","up","right"];
			var clrs = ["purple","blue","green","red"];

			var babyArrow:Receptor = new Receptor(0, 100, i, currentOptions.noteSkin, noteModifier, Note.noteBehaviour);
			babyArrow.playerNum = pN;
			if(player==1)
				noteSplashes.add(babyArrow.noteSplash);


			if(currentOptions.middleScroll && player==0)
				babyArrow.visible=false;

			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();

			babyArrow.ID = i;
			var newStrumLine:FlxSprite = new FlxSprite(0, center.y).makeGraphic(10, 10);
			newStrumLine.scrollFactor.set();

			var newNoteRef:FlxSprite = new FlxSprite(0,-1000).makeGraphic(10, 10);
			newNoteRef.scrollFactor.set();

			var newRecepRef:FlxSprite = new FlxSprite(0,-1000).makeGraphic(10, 10);
			newRecepRef.scrollFactor.set();

			if (player == 1)
			{
				playerStrums.add(babyArrow);
				playerStrumLines.add(newStrumLine);
				refNotes.add(newNoteRef);
				refReceptors.add(newRecepRef);
			}else{
				dadStrums.add(babyArrow);
				opponentStrumLines.add(newStrumLine);
				opponentRefNotes.add(newNoteRef);
				opponentRefReceptors.add(newRecepRef);
			}

			babyArrow.playAnim('static');
			babyArrow.x = getXPosition(0, i, pN);

			newStrumLine.x = babyArrow.x;

			babyArrow.defaultX = babyArrow.x;
			babyArrow.defaultY = babyArrow.y;

			babyArrow.desiredX = babyArrow.x;
			babyArrow.desiredY = babyArrow.y;
			//babyArrow.point = FlxPoint.get(0,0);

			if (!isStoryMode)
			{
				babyArrow.yOffset -= 10;
				babyArrow.alpha = 0;
				FlxTween.tween(babyArrow,{yOffset: babyArrow.yOffset + 10, alpha:1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}

			strumLineNotes.add(babyArrow);
		}
	}

	function tweenCamIn():Void
	{
		FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
	}

	function updateAccuracy():Void
	{
		if(hitNotes==0 && totalNotes==0)
			accuracy = 1;
		else
			accuracy = hitNotes / totalNotes;
		#if desktop

		DiscordClient.changePresence(detailsText
			+ songData.displayName
			+ " ("
			+ storyDifficultyText
			+ ")",
			grade
			+ " | Acc: "
			+ CoolUtil.truncateFloat(accuracy * 100, 2)
			+ "%", iconRPC, true, songLength
			- Conductor.rawSongPos);
			#end

		var fcType = ' ';
		if(judgeMan.judgementCounter.get("miss")>0){
			fcType='';
		}else{
			if(judgeMan.judgementCounter.get("bad")+judgeMan.judgementCounter.get("shit")>=noteCounter.get("taps")/2 && noteCounter.get("taps")>0)
				fcType = ' (WTFC)';
			else if(judgeMan.judgementCounter.get("bad")>0 || judgeMan.judgementCounter.get("shit")>0)
				fcType += '(FC)';
			else if(judgeMan.judgementCounter.get("good")>0)
				fcType += '(GFC)';
			else if(judgeMan.judgementCounter.get("sick")>0)
				fcType += '(SFC)';
			else if(judgeMan.judgementCounter.get("epic")>0)
				fcType += '(EFC)';
		}


		grade = died?"F":ScoreUtils.AccuracyToGrade(accuracy) + fcType;
	}
	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (inst != null)
			{
				inst.pause();
				vocals.pause();
			}
			if (inst != null && !startingSong)
			{
				Conductor.rawSongPos = inst.time;
				Conductor.songPosition = (Conductor.rawSongPos+currentOptions.noteOffset);
			}

			if (startTimer!=null && !startTimer.finished)
				startTimer.active = false;
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{

			if(!startingSong)
				resyncVocals();


			for (tw in tweens)
			{
				if (!tw.finished)
				{
					tw.active = true;
				}
			}

			if (!startTimer.finished)
				startTimer.active = true;
			paused = false;

			#if desktop
			if (startTimer.finished)
			{
				DiscordClient.changePresence(detailsText + songData.displayName + " (" + storyDifficultyText + ")", grade + " | Acc: " + CoolUtil.truncateFloat(accuracy*100,2) + "%", iconRPC, true, songLength- Conductor.rawSongPos);
			}
			else
			{
				DiscordClient.changePresence(detailsText + songData.displayName + " (" + storyDifficultyText + ")", grade + " | Acc: " + CoolUtil.truncateFloat(accuracy*100,2) + "%", iconRPC);
			}
			#end
		}
		var s = subState;
		super.closeSubState();

		if ((s is UseOffsetSubstate)){
			inst.stop();
			vocals.stop();
			unspawnNotes=[];
			for(note in renderedNotes){
				for (tail in note.tail)
					destroyNote(tail);
				

				destroyNote(note);
			}

			generateSong();
			startingSong = true;

			var removing:Array<Note> = [];
			for (note in unspawnNotes)
			{
				if (note.strumTime < startPos && !note.isSustainNote)
				{
					removing.push(note);
				}
			}
			for (note in removing)
			{
				unspawnNotes.remove(note);

				for (tail in note.tail)
				{
					unspawnNotes.remove(tail);
					destroyNote(tail);
				}
				destroyNote(note);
			}

			shownAccuracy = 100;

			startedCountdown = true;
			Conductor.rawSongPos = startPos;
			Conductor.rawSongPos -= Conductor.crochet * 5;
			Conductor.songPosition = Conductor.rawSongPos + currentOptions.noteOffset;
			updateCurStep();
			updateBeat();
			inst.volume = 1;
			vocals.volume = 1;
			inst.time = Conductor.rawSongPos;
			vocals.time = Conductor.rawSongPos;
			resyncTimer = 0;
			startTimer = new FlxTimer();
			doCountdown();
		}
		
	}

	override public function onFocus():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			if (Conductor.rawSongPos > 0.0)
			{
				DiscordClient.changePresence(detailsText + songData.displayName + " (" + storyDifficultyText + ")", grade + " | Acc: " + CoolUtil.truncateFloat(accuracy*100,2) + "%", iconRPC, true, songLength-Conductor.rawSongPos);
			}
			else
			{
				DiscordClient.changePresence(detailsText + songData.displayName + " (" + storyDifficultyText + ")", grade + " | Acc: " + CoolUtil.truncateFloat(accuracy*100,2) + "%", iconRPC);
			}
		}
		#end

		super.onFocus();
	}

	function pause(){
		if(!canPause)return;
		if(paused || subState!=null || startTimer==null)return;
		persistentUpdate = false;
		persistentDraw = true;
		paused = true;

		for (tw in tweens)
		{
			if (!tw.finished)
			{
				tw.active = false;
			}
		}

		openSubState(new PauseSubState(player.x, player.y));
	}
	override public function onFocusLost():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			DiscordClient.changePresence(detailsPausedText + songData.displayName + " (" + storyDifficultyText + ")", grade + " | Acc: " + CoolUtil.truncateFloat(accuracy*100,2) + "%", iconRPC);
		}
		#end

		pause();

		super.onFocusLost();
	}

	function resyncVocals():Void
	{
		if (!dontSync){
			vocals.pause();

			inst.play();
			if(inst.time != Conductor.lastSongPos)
				resyncTimer = 0;
			
			Conductor.rawSongPos = inst.time + resyncTimer;
			Conductor.lastSongPos = inst.time;
			
			vocals.time = inst.time;
			Conductor.songPosition=Conductor.rawSongPos+currentOptions.noteOffset;
			vocals.play();
		}
	}

	private var paused:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;


	//public float GetSpritePosition(long offset, float initialPos) => HitPosition + ((initialPos - offset) * (ScrollDirection.Equals(ScrollDirection.Down) ? -HitObjectManagerKeys.speed : HitObjectManagerKeys.speed) / HitObjectManagerKeys.TrackRounding);
	// ADAPTED FROM QUAVER!!!
	// COOL GUYS FOR OPEN SOURCING
	// https://github.com/Quaver/Quaver
	// https://github.com/Quaver/Quaver
	// https://github.com/Quaver/Quaver
	function getPosFromTime(strumTime:Float):Float{
		var idx:Int = 0;
		while(idx<sliderVelocities.length){
			if(strumTime<sliderVelocities[idx].startTime)
				break;
			idx++;
		}
		return getPosFromTimeSV(strumTime,idx);
	}

	public static function getFNFSpeed(strumTime:Float):Float{
		return (getSVFromTime(strumTime)*(currentPState.scrollSpeed*(1/.45) ));
	}

	public static function getScale(strumTime:Float):Float{
		return Conductor.stepCrochet/100*1.5*PlayState.getFNFSpeed(strumTime);
	}

	public static function getSVFromTime(strumTime:Float):Float{
		var idx:Int = 0;
		while(idx<sliderVelocities.length){
			if(strumTime<sliderVelocities[idx].startTime)
				break;
			idx++;
		}
		idx--;
		if(idx<=0)
			return SONG.initialSpeed;
		return SONG.initialSpeed*sliderVelocities[idx].multiplier;
	}

	function getPosFromTimeSV(strumTime:Float,?svIdx:Int=0):Float{
		if(svIdx==0)
			return strumTime*SONG.initialSpeed;

		svIdx--;
		var curPos = velocityMarkers[svIdx];
		curPos += ((strumTime-sliderVelocities[svIdx].startTime)*(SONG.initialSpeed*sliderVelocities[svIdx].multiplier));
		return curPos;
	}

	function updatePositions(){
		Conductor.currentVisPos = Conductor.songPosition + currentOptions.visualOffset;
		Conductor.currentTrackPos = getPosFromTime(Conductor.currentVisPos);
	}

	/*public function getXPosition(diff:Float, direction:Int, player:Int):Float{
		var x = FlxG.width/2 - Note.swagWidth/2; // centers them

		if(!currentOptions.middleScroll){
			switch(player){
				// player 0 (aka BF) should have his notes shifted right
				// and player 1 (aka dad) should have his notes shifted left
				case 0:
					x += FlxG.width / 4;
				case 1:
					x -= FlxG.width / 4;
			}
		}
		x -= Note.swagWidth*2; // so that everything is aligned on the left side
		x += Note.swagWidth * direction; // moves everything to be in position
		x += 56; // because lol

		return x; // return it
	}*/
	// ^^ this is VERY slightly off
	// so im just gonna take the code from andromeda 2.0 lmao

	public function getXPosition(diff:Float, direction:Int, player:Int):Float{

		var x:Float = (FlxG.width/2) - Note.swagWidth - 54 + Note.swagWidth*direction;
		if(!currentOptions.middleScroll){
			switch(player){
				case 0:
					x += FlxG.width/2 - Note.swagWidth*2 - 100;
				case 1:
					x -= FlxG.width/2 - Note.swagWidth*2 - 100;
			}
		}
		x -= 56;

		return x;
	}

	// ADAPTED FROM QUAVER!!!
	// COOL GUYS FOR OPEN SOURCING
	// https://github.com/Quaver/Quaver
	// https://github.com/Quaver/Quaver
	// https://github.com/Quaver/Quaver

	function updateScoreText(){
		if(SONG.song.toLowerCase()=='violets')
			scoreTxt.text = 'Score: ${songScore}\n${accuracyName}: ${shownAccuracy}%\nGrade: ${grade}';
		else if(currentOptions.onlyScore){
			if(botplayScore!=0){
				if(songScore==0)
					scoreTxt.text = 'Bot Score: ${botplayScore}';
				else
					scoreTxt.text = 'Score: ${songScore} | Bot Score: ${botplayScore}';
			}else{
				scoreTxt.text = 'Score: ${songScore}';
			}
		}else{
			if(botplayScore!=0){
				if(songScore==0)
					scoreTxt.text = 'Bot Score: ${botplayScore} | ${accuracyName}: ${shownAccuracy}% | ${grade}';
				else
					scoreTxt.text = 'Score: ${songScore} | Bot Score: ${botplayScore} | ${accuracyName}: ${shownAccuracy}% | ${grade}';
			}else{
				scoreTxt.text = 'Score: ${songScore} | ${accuracyName}: ${shownAccuracy}% | ${grade}';
			}
		}
	}

	function tween(Object:Dynamic, Values:Dynamic, Duration:Float = 1, ?Options:TweenOptions)
	{
		if (Options != null)
		{
			var complete = Options.onComplete;
			var start = Options.onStart;

			Options.onComplete = function(tw:FlxTween)
			{
				tweens.remove(tw);
				if (complete != null)
					complete(tw);
			}
			Options.onStart = function(tw:FlxTween)
			{
				tweens.push(tw);
				if (start != null)
					start(tw);
			}
		}
		return FlxTween.tween(Object, Values, Duration, Options);
	}

	function ease(easeFunction:EaseFunction, t:Float, b:Float, c:Float, d:Float)
	{ // elapsed, begin, change (ending-beginning), duration
		var time = t / d;
		return c * easeFunction(time) + b;
	}

	function doEvent(event:Event) : Void {
		var args = event.args;
		switch (event.name){
			case 'DMPiiking Out RN!!':
				dmpiikingOut.visible=true;
				dad.visible=false;
				dmpiikingOut.animation.play("omghestransguys", true);
			case 'Closeup Trans BEGONE':
				dmpiikingOut.visible=false;
				dad.visible=true;
			case 'Closeup BG':
				if (!currentOptions.noStage && !calibrating){
					remove(stage);
					stage = closeupStage;
					add(stage);
					defaultCamZoom = stage.defaultCamZoom;
					stage.setPlayerPositions(boyfriend, dad, gf);
				}
			case 'Normal BG':
				if (!currentOptions.noStage && !calibrating){
					remove(stage);
					stage = realStage;
					add(stage);
					defaultCamZoom = stage.defaultCamZoom;
					stage.setPlayerPositions(boyfriend, dad, gf);
				}
			case 'Malvado Stage Change':
				if (!currentOptions.noStage && !calibrating){
					remove(stage);
					stage = realStage;
					add(stage);
					stage.setPlayerPositions(boyfriend, dad, gf);
				}
			case 'Bad Apple':
				drainEnabled = false;
				oldHealth = health;
				health = 1;
				realStage.corruptOverlay.visible = false;
				realStage.corruptWiggle.visible = false;
				if (!currentOptions.noStage && !calibrating){
					remove(stage);
					stage = corruptedStage;
					add(stage);
				}
				stage.setPlayerPositions(boyfriend, dad, gf);
				camHUD.flash(FlxColor.WHITE, 1, null, true);
				stage.memoryShader.percent = 1;
				flexyMic.flipX = true;
				flexyMic.x = boyfriend.x - 150;
				flexyMic.y = boyfriend.y + 80;
				flexyMic.shader = memoryShader.shader;
				flexyMic.visible = true;
			case 'Good Orange':
				health = oldHealth;
				drainEnabled = true;
				realStage.corruptOverlay.visible = true;
				realStage.corruptWiggle.visible = true;
				stage.memoryShader.percent = 0;
				flexyMic.visible = false;
				if (!currentOptions.noStage && !calibrating){
					remove(stage);
					stage = realStage;
					add(stage);
				}
				stage.setPlayerPositions(boyfriend, dad, gf);
				camHUD.flash(FlxColor.WHITE, 1, null, true);
			case 'Polaroid':
				add(polaroids);
				var piece = malvadoPolaroid[Std.int(args[0]-1)];
				piece.alpha = 0;
				piece.visible = true;
				var m:Int = 1;
				if(FlxG.random.bool(50))
					m = -1;
				
				piece.x -= 250 * m;

				tween(piece, {x: piece.x + (500 * m)}, 5, {
					ease: FlxEase.linear
				}); // maybe use velocity instead of a tween for the x? idk lmao this seems fine

				tween(piece, {alpha: 1}, 1, {
					ease: FlxEase.linear,
					onComplete: function(tw:FlxTween){
						tween(piece, {alpha: 0}, 1, {
							ease: FlxEase.linear
						});
					}
				});

			case 'Tiky Fall':
				if (stage.tikyOne!=null && stage.demonclownwiththegamernotes!=null && stage.tikyOne.visible){
					stage.tikyOne.visible = false;
					stage.noTiky.visible = true;
					stage.demonclownwiththegamernotes.velocity.set(200, 100);
					stage.demonclownwiththegamernotes.acceleration.set(750, 9000);
					stage.demonclownwiththegamernotes.angularAcceleration = 30;
					stage.demonclownwiththegamernotes.angularVelocity = 6;
					FlxG.sound.play(Paths.sound('trickydies'), 0.25);
					FlxTween.tween(stage.demonclownwiththegamernotes, {alpha: 1}, 1.5, {
						ease: FlxEase.quadInOut,
						startDelay: 0.5,
						onComplete: function(twn:FlxTween)
						{
							stage.demonclownwiththegamernotes.kill();
							stage.remove(stage.demonclownwiththegamernotes);
						}
					});
				}
			case 'HP Drain Mult':
				hpDrain *= args[0];
			case 'Devoured Appear':
				if (stage.orangeBG != null)stage.orangeBG.visible = true;
			case 'False Exit':
				canPause=false;
				paused=false;
				persistentDraw=true;
				persistentUpdate=true;
				FadeTransitionSubstate.nextCamera = camOther;
				var trans = new FadeTransitionSubstate();
				openSubState(trans);
				FlxG.autoPause=false;
	     		trans.finishCallback = function(){
					FPSMem.shouldUpdate=false;
					persistentDraw=true;
					persistentUpdate=true;
				};
				trans.start(IN);
			case 'Merchant Dialogue':
				if(startPos >= event.time*1000)return;

				if(subState!=null){
					persistentDraw=true;
					persistentUpdate=true;
					canPause=true;
					add(merchantDia);
					closeSubState();
				}
				var piece = merchantDiaMap.get(args[0]);
				piece.alpha=0;
				piece.visible=true;
				FlxTween.tween(piece, {alpha: 1}, 0.1, {
					ease: FlxEase.quadOut
				});
			case 'End Merchant Dialogue':
				if(startPos >= event.time*1000)return;
				var white = new FlxSprite().makeGraphic(Std.int(FlxG.width*2),Std.int(FlxG.width*2),FlxColor.WHITE);
				white.screenCenter(XY);
				white.cameras = [camOther];
				add(white);
				add(merchantOverlay);
				FPSMem.shouldUpdate=true;
				#if !html5
				FlxG.autoPause=true;
				#end
				FlxTween.tween(white, {alpha: 0}, 0.6, {
					onComplete: function(tween:FlxTween)
					{
						white.destroy();
					},
				});
				FlxTween.tween(merchantOverlay, {alpha: 0}, 1, {
					onComplete: function(tween:FlxTween)
					{
						merchantOverlay.destroy();
					},
					ease: FlxEase.quadOut
				});
				remove(merchantDia);
			case 'False Exit End':
				if(startPos >= event.time*1000)return;
				if(subState!=null){
					persistentDraw=true;
					persistentUpdate=true;
					canPause=true;
					closeSubState();
					camHUD.flash(FlxColor.WHITE, 0.75, null, true);
				}
			case 'Everybodys Comin':/*
				if(currentOptions.potato>0){
					camGame.flash(FlxColor.WHITE, 0.75, null, true);
					if(stage.curStage=='rooftop'){
						stage.everybodyscumming.visible=true;
						stage.stageeveryonetellsyounottoworryabout.visible=true;
						stage.wifeForever.visible=true;
						stage.ritsack.visible=true;
						stage.bullShit.visible=true;

						stage.sideWall.visible=false;
						stage.sideWallBack.visible=false;
						stage.bg.visible=false;
						stage.gfBop.visible=false;
						stage.meeyaano.visible=false;
						stage.babyManAndMerchant.visible=false;
						stage.clowsoe.visible=false;
						stage.ground.visible=false;
						stage.demonclownwiththegamernotes.visible=false;
						stage.bopper.visible=false;

					}

					swapCharacter('bf', 'skelebf');
					swapCharacter('dad', 'dmpoutline');
				}*/
			case 'Everybodys Leavin':
				/*if(currentOptions.potato>0){
					camGame.flash(FlxColor.WHITE, 0.75, null, true);
					if(stage.curStage=='rooftop'){
						stage.everybodyscumming.visible=false;
						stage.stageeveryonetellsyounottoworryabout.visible=false;
						stage.wifeForever.visible=false;
						stage.ritsack.visible=false;
						stage.bullShit.visible=false;

						stage.sideWall.visible=true;
						stage.sideWallBack.visible=true;
						stage.bg.visible=true;
						stage.gfBop.visible=true;
						stage.meeyaano.visible=true;
						stage.babyManAndMerchant.visible=true;
						stage.clowsoe.visible=true;
						stage.ground.visible=true;
						stage.demonclownwiththegamernotes.visible=true;
						stage.bopper.visible=true;
					}
					swapCharacter('bf', 'bf');
					swapCharacter('dad', 'dmp');
				}*/
			case 'Gran Venta Purple':
				if(OptionUtils.options.potato>0){
					if(storyDifficulty==3){
						swapCharacter('dad','purple-erect-merchant');
						swapCharacter('bf','purpledickhead');
						swapCharacter('gf','purplesuspeakers');
					}else{
						swapCharacter('gf','purplegf');
						swapCharacter('dad','purplemerchant');
						swapCharacter('bf','purplebf');
					}

					if(stage.curStage=='shop'){
						stage.purpleBG.visible=true;
						stage.purpleFire1.visible=true;
						stage.purpleFire2.visible=true;

						stage.orangeBG.visible=false;
						stage.orangeFire1.visible=false;
						stage.orangeFire2.visible=false;
					}
				}
			case 'The Skeleton Appears':
				if(currentOptions.potato>0){
					if(startPos < event.time*1000)camGame.flash(FlxColor.WHITE, 0.75, null, true);
					swapCharacter('dad','dmp');

					stage.setPlayerPositions(null, dad);
					
				}
				boyfriend.noIdleTimer = 1500;
				boyfriend.playAnim("scared", true);
			case 'Cam Flash':
				camGame.flash(FlxColor.fromString(args[0]), args[1], null, true);
			case 'Change Character':
				if(args[1]!=null && (args[1] == "corruptedflexy" || args[1] == "corruptingmerchant"))
					camGame.flash(FlxColor.fromRGB(216, 41, 118, 255), 0.75, null, true);
				swapCharacter(args[0],args[1]);
			case 'Play Anim':
				var char:Character = boyfriend;
				switch (args[0]){
					case 'gf':
						char = gf;
					case 'dad':
						char=dad;
				}
				char.noIdleTimer = args[2]*1000;
				char.playAnim(args[1],true);
			case 'Camera Zoom Interval':
				zoomBeatingInterval = args[0];
				zoomBeatingZoom = args[1];
			case 'GF Speed':
				gfSpeed = Math.floor(args[0]);
			case 'Screen Shake':
				if(startPos >= event.time*1000)return;
				var axes:FlxAxes = XY;
				switch(args[2]){
					case 'XY':
						axes = XY;
					case 'X':
						axes = X;
					case 'Y':
						axes = Y;
				}
				FlxG.camera.shake(args[0],args[1],null,true,axes);
				camHUD.shake(args[0],args[1],null,true,axes);
			case 'Set Cam Pos':
				focus = 'none';
				updateCamFollow();
				camFollow.setPosition(args[0],args[1]);
			case 'Set Cam Focus':
				focus = args[0];
				updateCamFollow();
			case 'Camera Zoom':
				if(currentOptions.potato==0){
					defaultCamZoom = CoolUtil.clamp(args[0], 1, 2);
				}else{
					defaultCamZoom = args[0];
				}
			case 'Camera Zoom Bump':
				if(startPos >= event.time*1000)return;
				var gameZoom = args[0];
				var hudZoom = args[1];
				if(currentOptions.potato==0){
					if(FlxG.camera.zoom+gameZoom<1){
						gameZoom=0;
					}
				}
				FlxG.camera.zoom += gameZoom;
				camHUD.zoom += hudZoom;
			case 'Camera Offset':
				camOffX = args[0];
				camOffY = args[1];
			case 'Custom':
				
		}
		#if desktop
		if(luaModchartExists && lua!=null)
			lua.call("doEvent",[event.name, event.args]); // TODO: Note lua class???
		#end

	}

	var differences:Array<Float>=[];

	function updateCamFollow(){
		var bfMid = boyfriend.getMidpoint();
		var dadMid = opponent.getMidpoint();
		var gfMid = gf.getMidpoint();

		if(cameraLocked){
			camFollow.setPosition(cameraLockX,cameraLockY);
		}else{
			var focusedChar:Null<Character>=null;
			var curFocus = focus;
			if(stage.curStage == 'shopCloseup')
				curFocus = 'center';

			switch (curFocus){
				case 'dad':
					focusedChar=opponent;
					camFollow.setPosition(dadMid.x + opponent.camOffset.x, dadMid.y + opponent.camOffset.y);
					if(stage.curStage == 'rooftop-su')
						camFollow.y -= 100;
				case 'bf':
					focusedChar=boyfriend;
					camFollow.setPosition(bfMid.x - stage.camOffset.x  + boyfriend.camOffset.x, bfMid.y - stage.camOffset.y + boyfriend.camOffset.y);
					if(stage.curStage == 'rooftop-su')
						camFollow.y -= 50;
				case 'gf':
					focusedChar=gf;
					camFollow.setPosition(gfMid.x + gf.camOffset.x, gfMid.y + gf.camOffset.y);
					if (stage.curStage == 'rooftop-su')
						camFollow.y -= 50;
				case 'center':
					focusedChar = null;
					var centerX = (stage.centerX==-1)?(((dadMid.x+ opponent.camOffset.x) + (bfMid.x- stage.camOffset.x + boyfriend.camOffset.x))/2):stage.centerX;
					var centerY = (stage.centerY==-1)?(((dadMid.y+ opponent.camOffset.y) + (bfMid.y- stage.camOffset.y + boyfriend.camOffset.y))/2):stage.centerY;
					camFollow.setPosition(centerX,centerY);
				case 'none':

			}

			if (dad.forceFocus)
				camFollow.setPosition(dadMid.x + opponent.camOffset.x, dadMid.y + opponent.camOffset.y);
			if(currentOptions.camFollowsAnims && focusedChar!=null){
				if(focusedChar.animation.curAnim!=null){
					switch (focusedChar.animation.curAnim.name.substring(4)){
						case 'UP' | 'UP-alt' | 'UPmiss' | 'UP-end' | 'UPEnd' | 'UPStart':
							if(focusedChar.curCharacter == 'corruptedmerchant')
								camFollow.y -= 25 * focusedChar.camMovementMult;
							else
								camFollow.y -= 15 * focusedChar.camMovementMult;
							
							
						case 'DOWN' | 'DOWN-alt' | 'DOWNmiss' | 'DOWN-end' | 'DOWNEnd' | 'DOWNStart':
							if (focusedChar.curCharacter == 'corruptedmerchant')
								camFollow.y += 25 * focusedChar.camMovementMult;
							else
								camFollow.y += 15 * focusedChar.camMovementMult;
						case 'LEFT' | 'LEFT-alt' | 'LEFTmiss' | 'LEFT-end' | 'LEFTEnd' | 'LEFTStart':
							camFollow.x -= 15 * focusedChar.camMovementMult;
						case 'RIGHT' | 'RIGHT-alt' | 'RIGHTmiss' | 'RIGHT-end' | 'RIGHTEnd' | 'RIGHTStart':
							camFollow.x += 15 * focusedChar.camMovementMult;
					}
				}
			}
		}
		if(focus!='none'){
			camFollow.x += camOffX;
			camFollow.y += camOffY;
		}
	}

	var flightTimer:Float = 0;
	var resyncTimer:Float = 0;
	override public function update(elapsed:Float)
	{
		#if !debug
		perfectMode = false;
		#end
		updatePositions();
		if(vcrDistortionHUD!=null){
			vcrDistortionHUD.update(elapsed);
			vcrDistortionGame.update(elapsed);
		}

		if(stage.memoryShader!=null && memoryShader!=null)
			memoryShader.percent = stage.memoryShader.percent;
		

		if(cumShader!=null){
			cumShader.update(elapsed);
		}
		modManager.update(elapsed);
		opponent = opponents.length>0?opponents[opponentIdx]:dad;
		if(currentOptions.opponentMode)
			player=opponent;

		modchart.update(elapsed);
		FlxG.camera.followLerp = 0.03 * (elapsed/(1 / 60));
		camRating.followLerp = 0.03 * (elapsed / (1 / 60));

		//healthBar.visible = ScoreUtils.botPlay?false:modchart.hudVisible;
		scoreTxt.visible = modchart.hudVisible;
		if(presetTxt!=null)
			presetTxt.visible = ScoreUtils.botPlay?false:modchart.hudVisible;


		shownAccuracy = CoolUtil.truncateFloat(FlxMath.lerp(shownAccuracy,accuracy*100, Main.adjustFPS(0.2)),2);

		if(Math.abs((accuracy*100)-shownAccuracy) <= 0.1)
			shownAccuracy=CoolUtil.truncateFloat(accuracy*100,2);
		//scoreTxt.text = "Score:" + (songScore + botplayScore) + ' / ${accuracyName}:' + shownAccuracy + "% / " + grade;
		updateScoreText();

		scoreTxt.screenCenter(X);
		if(SONG.song.toLowerCase()=='violets')
			scoreTxt.x += 10;
		botplayTxt.screenCenter(X);
		if(calibrationTxt!=null)
			calibrationTxt.screenCenter(X);
		botplayTxt.visible = ScoreUtils.botPlay;

		if(judgeMan.judgementCounter.get('miss')>0 && currentOptions.failForMissing){
			health=0;
		}
		previousHealth=health;
		if (controls.PAUSE && startedCountdown && canPause)
		{
			pause();

			#if desktop
			DiscordClient.changePresence(detailsPausedText + songData.displayName + " (" + storyDifficultyText + ")", grade + " | Acc: " + CoolUtil.truncateFloat(accuracy*100,2) + "%", iconRPC);
			#end
		}

		#if !DISABLE_CHART_EDITOR
		if (FlxG.keys.justPressed.SEVEN && !isStoryMode)
		{
			inst.pause();
			vocals.pause();
			persistentUpdate = false;
			persistentDraw = false;
			FlxG.switchState(new ChartingState());



			#if desktop
			DiscordClient.changePresence("Chart Editor", null, null, true);
			#end
		}
		#end

		// FlxG.watch.addQuick('VOL', vocals.amplitudeLeft);
		// FlxG.watch.addQuick('VOLRight', vocals.amplitudeRight);

		if (health > 2){
			health = 2;
			previousHealth = health;
			#if sys
			if(luaModchartExists && lua!=null)
				lua.setGlobalVar("health",health);
			#end
		}

		/* if (FlxG.keys.justPressed.NINE)
			FlxG.switchState(new Charting()); */

		#if !DISABLE_CHARACTER_EDITOR
		if (FlxG.keys.justPressed.EIGHT){
			FlxG.switchState(new CharacterEditorState(SONG.player2,new PlayState()));
		}
		#end


		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.rawSongPos += elapsed * 1000;
				if (Conductor.rawSongPos >= startPos)
					startSong();
			}
		}
		else
		{
			if(inst.playing){
				if(inst.time == Conductor.lastSongPos)
					resyncTimer += elapsed * 1000;
				else
					resyncTimer = 0;
				
				Conductor.rawSongPos = inst.time + resyncTimer;
				
				Conductor.lastSongPos = inst.time;
			}else
				Conductor.rawSongPos += elapsed*1000;
			
		}

		FlxG.watch.addQuick("conductor raw pos",Conductor.rawSongPos);
		FlxG.watch.addQuick("conductor pos",Conductor.songPosition);
		FlxG.watch.addQuick("conductor vis pos", Conductor.currentVisPos);
		FlxG.watch.addQuick("inst pos", inst.time);


		/*if(inst.playing && !startingSong){
			var delta = Conductor.rawSongPos/1000 - Conductor.lastSongPos;
			differences.push(delta);
			if(differences.length>20)
				differences.shift();
			Conductor.lastSongPos = inst.time/1000;
			if(Math.abs(delta)>=0.05){
				Conductor.rawSongPos = inst.time;
			}

			if(Conductor.rawSongPos>=vocals.length && vocals.length>0){
				dontSync=true;
				vocals.volume=0;
				vocals.stop();
			}
		}*/

		Conductor.songPosition = (Conductor.rawSongPos+currentOptions.noteOffset);
		#if sys
		try{
			if(luaModchartExists && lua!=null){
				lua.setGlobalVar("songPosition",Conductor.songPosition);
				lua.setGlobalVar("rawSongPos",Conductor.rawSongPos);
			}
		}catch(e:Any){
			trace(e);
		}
		#end

		if (camZooming)
		{
			FlxG.camera.zoom = FlxMath.lerp(FlxG.camera.zoom,defaultCamZoom, Main.adjustFPS(0.05));
			camHUD.zoom = FlxMath.lerp(camHUD.zoom,1, Main.adjustFPS(0.05));
		}

		if (curSong == 'Fresh')
		{
			switch (curBeat)
			{
				case 16:
					camZooming = true;
					gfSpeed = 8;
				case 48:
					gfSpeed = 4;
				case 80:
					gfSpeed = 8;
				case 112:
					gfSpeed = 4;
				case 163:
					// inst.stop();
					// FlxG.switchState(new TitleState());
			}
		}

		if(curSong == 'Spookeez'){
			switch (curStep){
				case 444,445:
					gf.playAnim("cheer",true);
					boyfriend.playAnim("hey",true);
			}
		}

		if (curSong == 'Bopeebo')
		{
			switch (curBeat)
			{
				case 128, 129, 130:
					vocals.volume = 0;
					// inst.stop();
					// FlxG.switchState(new PlayState());
			}
		}
		playerStrums.forEach( function(spr:Receptor)
		{
			var pos = modManager.getReceptorPos(spr,0);
			var scale = modManager.getReceptorScale(spr,0);
			modManager.updateReceptor(spr, 0, scale, pos);

			spr.desiredX = pos.x;
			spr.desiredY = pos.y;
			spr.desiredZ = pos.z;
			spr.scale.set(scale.x,scale.y);

			//scale.put();
		});

		dadStrums.forEach( function(spr:Receptor)
		{
			var pos = modManager.getReceptorPos(spr,1);
			var scale = modManager.getReceptorScale(spr,1);
			modManager.updateReceptor(spr, 1, scale, pos);

			spr.desiredX = pos.x;
			spr.desiredY = pos.y;
			spr.desiredZ = pos.z;
			spr.scale.set(scale.x,scale.y);

			//scale.put();

		});

		// RESET = Quick Game Over Screen
		if (controls.RESET && currentOptions.resetKey)
		{
			health = 0;
			trace("RESET = True");
		}

		// CHEAT = brandon's a pussy
		if (controls.CHEAT)
		{
			health += 1;
			previousHealth = health;
			#if sys
			if(luaModchartExists && lua!=null)
				lua.setGlobalVar("health",health);
			#end
			trace("User is cheating!");
		}
		if(died || health<0)
			health=0;

		if(!died){
			if (health <= 0 && stage.curStage!='date')
			{
				if(!currentOptions.noFail && !inCharter ){
					died=true;
					player.stunned = true;

					persistentUpdate = false;
					persistentDraw = false;
					paused = true;

					vocals.stop();
					inst.stop();
					if (player.curCharacter.contains("corrupt") || SONG.song.toLowerCase() == 'devoured' || SONG.song.toLowerCase() == 'malvado')
						openSubState(new CorruptGameOverSubstate(player.x, player.y, player.curCharacter));
					else
						openSubState(new GameOverSubstate(player.x, player.y, player.curCharacter));

					// FlxG.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

					#if desktop
					// Game Over doesn't get his own variable because it's only used here
					DiscordClient.changePresence("Game Over - " + detailsText + songData.displayName + " (" + storyDifficultyText + ")", grade + " | Acc: " + CoolUtil.truncateFloat(accuracy*100,2) + "%", iconRPC);
					#end
				}else{
					died=true;
					combo=0;
					showCombo();
					FlxG.sound.play(Paths.sound('fnf_loss_sfx'));
					var deathOverlay = new FlxSprite(0,0).makeGraphic(Std.int(FlxG.width*2),Std.int(FlxG.width*2),FlxColor.RED);
					deathOverlay.screenCenter(XY);
					deathOverlay.alpha = 0.6;
					add(deathOverlay);
					FlxTween.tween(deathOverlay, {alpha: 0}, 0.3, {
						onComplete: function(tween:FlxTween)
						{
							deathOverlay.destroy();
							FlxTween.tween(healthBar, {alpha: 0}, 0.7, {
								startDelay:1,
							});
						}
					});
					updateAccuracy();
				}
			}
		}

		if(!songEnded){
			var spawnTime = noteSpawnTime;
			switch(OptionUtils.options.potato){
				case 1:
					spawnTime*=0.75;
				case 0:
					spawnTime*=0.5;
			}
			while(unspawnNotes[0] != null)
			{

				if (Conductor.currentTrackPos-getPosFromTime(unspawnNotes[0].strumTime)>-spawnTime)
				{
					var dunceNote:Note = unspawnNotes[0];

					renderedNotes.add(dunceNote);

					if(dunceNote.mustPress){
						playerNotes.push(dunceNote);
						playerNotes.sort((a,b)->Std.int(a.strumTime-b.strumTime));
					}

					var index:Int = unspawnNotes.indexOf(dunceNote);
					unspawnNotes.splice(index, 1);

				}else
					break;
				
			}
		}

		var baseX = stage.dadPosition.x + dad.posOffset.x;
		var baseY = stage.dadPosition.y + dad.posOffset.y;

		var targetX:Float = baseX;
		var targetY:Float = baseY;
		if (dad.curCharacter == 'corruptedmerchant')
		{
			flightTimer += 0.015 * (elapsed / (1 / 120));
			targetY += Math.sin(flightTimer) * 25;
			var lerpVal:Float = 0.05 * (elapsed / (1 / 120));
			dad.x = FlxMath.lerp(dad.x, targetX, lerpVal);
			dad.y = FlxMath.lerp(dad.y, targetY, lerpVal);
			
		}

		var shouldResetDadReceptors:Bool = true; // lmao
		var notesToKill:Array<Note>=[];
		if (generatedMusic)
		{
			if(startedCountdown){
				if(currentOptions.allowOrderSorting)
					renderedNotes.sort(sortByOrder);

				preNoteLogic(elapsed);
				renderedNotes.forEachAlive(function(daNote:Note)
				{
					if(!daNote.active){
						daNote.visible=false;
						notesToKill.push(daNote);
						return;
					}

					var revPerc:Float = 0;
					var reverseMod:modchart.modifiers.ReverseModifier = modManager.get("reverse"); // why is html5 like this why must i specify its a fucking reversemodifier
					if (reverseMod!=null)
						revPerc = reverseMod.getScrollReversePerc(daNote.noteData,daNote.mustPress==true?0:1);
					var strumLine = playerStrums.members[daNote.noteData];
					var isDownscroll = revPerc>.5;

					if(!daNote.mustPress)
						strumLine = dadStrums.members[daNote.noteData];

					var diff =  Conductor.songPosition - daNote.strumTime;
			    var vDiff = (daNote.initialPos-Conductor.currentTrackPos);
					if(daNote.unhitTail.length>0 && daNote.wasGoodHit){
						diff=0;
						vDiff=0;
					}

			    	var notePos = modManager.getPath(diff, vDiff, daNote.noteData, daNote.mustPress==true?0:1);

					notePos.x += daNote.manualXOffset;
					notePos.y -= daNote.manualYOffset;

					var scale = modManager.getNoteScale(daNote);
					modManager.updateNote(daNote, daNote.mustPress?0:1, scale, notePos);

					daNote.x = notePos.x;
					daNote.y = notePos.y;

					daNote.z = notePos.z;
					daNote.scale.set(scale.x, scale.y);
					daNote.updateHitbox();

					if(daNote.isSustainNote){
							//var prevPos = modManager.getNotePos(daNote.prevNote);
							//getPath(diff:Float, vDiff:Float, column:Int, player:Int, sprite:FNFSprite)
							var futureSongPos = Conductor.songPosition + 75;
							var futureVisualPos = getPosFromTime(futureSongPos);

							var diff =  futureSongPos - daNote.strumTime;
					    var vDiff = (daNote.initialPos - futureVisualPos);
							//  var pos = getPath(diff, vDiff, note.noteData, note.mustPress==true?0:1, note);

							var nextPos = modManager.getPath(diff, vDiff, daNote.noteData, daNote.mustPress==true?0:1);
							nextPos.x += daNote.manualXOffset;
					    	nextPos.y -= daNote.manualYOffset;

							var diffX = (nextPos.x - notePos.x);
							var diffY = (nextPos.y - notePos.y);
							var rad = Math.atan2(diffY,diffX);
							var deg = rad * (180 / Math.PI);
							if(deg!=0)
								daNote.modAngle = deg + 90;
							else
								daNote.modAngle = 0;
					}

					//scale.put();
					var visibility:Bool=true;

					if (daNote.y > FlxG.height)
					{
						visibility = false;
					}
					else
					{
						if((daNote.mustPress || !daNote.mustPress && !currentOptions.middleScroll)){
							visibility = true;
						}
					}


					if(!daNote.mustPress && currentOptions.middleScroll){
						visibility=false;
					}

					if(daNote.tail.length>0 && daNote.wasGoodHit){
						visibility=false;
					}

					if(daNote.invisible ||daNote.parent!=null &&  daNote.parent.invisible){
						visibility=false;
					}

					daNote.visible = visibility;

					if(daNote.unhitTail.length > 0 && daNote.mustPress){ // NEW HOLD LOGIC
						if(!daNote.tooLate && daNote.wasGoodHit){
							var isHeld = pressedKeys[daNote.noteData];
							var receptor = playerStrums.members[daNote.noteData];
							if(isHeld && receptor.animation.curAnim.name!="confirm"){
								receptor.playAnim("confirm");
							}
							daNote.holdingTime += elapsed*1000;

							if(isHeld)
								daNote.tripTimer = 1;
							else
								daNote.tripTimer -= elapsed/0.1; // maybe make the regrab timer an option
								// idk lol

							if(daNote.tripTimer<=0){
								daNote.tripTimer=0;
								trace("tripped hold");
								daNote.tooLate=true;
								daNote.wasGoodHit=false;
								for(tail in daNote.tail){
									if(!tail.wasGoodHit)
										tail.tooLate=true;
								}
							}else{

								for(tail in daNote.unhitTail){
									if((tail.strumTime - 25) <= Conductor.songPosition && !tail.wasGoodHit && !tail.tooLate)
										noteHit(tail);

								}
								player.holding=daNote.unhitTail.length>0;
								if(daNote.unhitTail.length>0)
									player.holdTimer=0;

							}
						}
					}

					var shitGotHit = (daNote.parent!=null && daNote.parent.wasGoodHit && daNote.canBeHit) || (daNote.wasGoodHit || daNote.prevNote.wasGoodHit && !daNote.canBeHit);
					var shit = strumLine.y + Note.swagWidth/2;
					if(revPerc==0.5){
						daNote.clipRect=null;
						if(shitGotHit && daNote.wasGoodHit)
							daNote.visible=false;
					}else{
						if(daNote.isSustainNote){
							if(shitGotHit){
								var dY:Float = daNote.frameHeight;
								var dH:Float = strumLine.y+Note.swagWidth/2-daNote.y;
								dH /= daNote.scale.y;
								dY -= dH;

								var uH:Float = daNote.frameHeight*2;
								var uY:Float = strumLine.y+Note.swagWidth/2-daNote.y;

								uY /= daNote.scale.y;
								uH -= uY;

								var clipRect = new FlxRect(0,0,daNote.width*2,0);
								clipRect.y = CoolUtil.scale(revPerc,0,1,uY,dY);
								clipRect.height = CoolUtil.scale(revPerc,0,1,uH,dH);

								daNote.clipRect=clipRect;
							}

						}
					}


					if (!daNote.mustPress && daNote.canBeHit && !daNote.wasGoodHit)
					{
						dadStrums.forEach(function(spr:Receptor)
						{
							if (Math.abs(daNote.noteData) == spr.ID)
							{
								//spr.playAnim('confirm', true);
								spr.playNote(daNote);
							}
						});

						var altAnim:String = "";

						if (SONG.notes[Math.floor(curStep / 16)] != null)
						{
							if (SONG.notes[Math.floor(curStep / 16)].altAnim)
								altAnim = '-alt';
						}

						switch(daNote.noteType){
							case 'alt':
								altAnim='-alt';
							case 'mine':
								// this really SHOULDN'T happen, but..
								health += 0.25; // they hit a mine, not you
						}

							//if(!daNote.isSustainNote){

							var anim = "";
							switch (Math.abs(daNote.noteData))
							{
							case 0:
								//dad.playAnim('singLEFT' + altAnim, true);
								anim='singLEFT' + altAnim;
							case 1:
								//dad.playAnim('singDOWN' + altAnim, true);
								anim='singDOWN' + altAnim;
							case 2:
								//dad.playAnim('singUP' + altAnim, true);
								anim='singUP' + altAnim;
							case 3:
								//dad.playAnim('singRIGHT' + altAnim, true);
								anim='singRIGHT' + altAnim;
							}
							if(nonPlayer.animation.getByName(anim)==null){
								anim = anim.replace(altAnim,"");
							}

							if(hpDrain > 0 && !daNote.isSustainNote && drainEnabled){
								var drain = hpDrain;
								if(SONG.song.toLowerCase() == 'malvado' && health >= 1.6)drain *= 2;
								if (health > drain)
									health -= drain;
								
								else
									health = 0.01;
								
							}

							

							#if desktop
							if(luaModchartExists && lua!=null)
								lua.call("dadNoteHit",[Math.abs(daNote.noteData),daNote.strumTime,Conductor.songPosition, anim, daNote.isSustainNote]); // TODO: Note lua class???
							#end


						//}

						if(dad.hasMic)
							flexyMic.visible=true;

						playAnimationNote(nonPlayer, daNote, altAnim);

						if(daNote.holdParent && !daNote.isSustainEnd())
							nonPlayer.holding = true;
						else
							nonPlayer.holding = false;

						nonPlayer.holdTimer = 0;
						nonPlayer.bandaidSolution = (0.1 * Conductor.stepCrochet) / 1000;

						if (SONG.needsVoices)
							vocals.volume = 1;
						daNote.wasGoodHit=true;

						lastHitDadNote=daNote;

						if(daNote.parent!=null && daNote.parent.unhitTail.length>0)
							shouldResetDadReceptors=false;


						if(!daNote.isSustainNote && daNote.sustainLength==0){
							notesToKill.push(daNote);
						}else if(daNote.isSustainNote){
							if(daNote.parent.unhitTail.contains(daNote)){
								daNote.parent.unhitTail.remove(daNote);
							}
						}


					}


					if(daNote!=null && daNote.alive){
						if(daNote.tooLate && daNote.mustPress && !daNote.isSustainNote && !daNote.causedMiss){
							if(daNote.causesMiss){
								daNote.causedMiss = true;
								noteMiss(daNote.noteData);

								vocals.volume = 0;
								updateAccuracy();
							}
						}

						if((isDownscroll && daNote.y>FlxG.height+daNote.height || !isDownscroll && daNote.y<-daNote.height || daNote.unhitTail.length==0 && daNote.sustainLength>0 || daNote.isSustainNote && daNote.strumTime - Conductor.songPosition < -350) && (daNote.tooLate || daNote.wasGoodHit)){
							notesToKill.push(daNote);
						}
					}
				});

				postNoteLogic(elapsed);
			}
		}

		if(lastHitDadNote==null || !lastHitDadNote.alive || !lastHitDadNote.exists ){
			lastHitDadNote=null;
		}

		var cosBFX:Float = 2;
		var cosBFY:Float = 4;
		var cosDadX:Float = 2;
		var cosDadY:Float = 4;

		if(boyfriend.curCharacter=='ravvy'){cosBFX/=2; cosBFY/=2;}
		if(dad.curCharacter=='ravvy'){cosDadX/=2; cosDadY/=2;}



		switch(stage.curStage){
			case 'date':
				boyfriend.x = bfX - FlxMath.fastCos(Conductor.songPosition/128) * cosBFX;
				boyfriend.y = bfY - FlxMath.fastSin(Conductor.songPosition/128) * cosBFY;

				dad.x = dadX + FlxMath.fastSin(Conductor.songPosition/128) * cosDadX;
				dad.y = dadY - FlxMath.fastCos(Conductor.songPosition/128) * cosDadY;
			case 'devoured' | 'malvado':
				stage.corruptOverlay.alpha = 0.2 + (health / 2);
				stage.corruptWiggle.alpha = 0.2 + (health / 2);
		}


		super.update(elapsed);

		
		var bfVar:Float=player.dadVar;

		if (player.isSinging){
			if (player.holdTimer > Conductor.stepCrochet * bfVar && player.bandaidSolution<=0)
			{
				if(!pressedKeys.contains(true)){
					if (!player.animation.curAnim.name.endsWith('miss'))
						player.dance();
					
				}
			}
		}

		for(note in notesToKill){
			if(note.active){
				destroyNote(note);
			}
		}


		while(eventSchedule[0]!=null){
			var event = eventSchedule[0];
			if(Conductor.songPosition >= event.time){
				if(event.events!=null && event.events.length>0){
					for(e in event.events)doEvent(e);
				}else if(event.events==null)
					doEvent(event);
				eventSchedule.shift();
			}else{
				break;
			}
		}

		updateCamFollow();

		dadStrums.forEach(function(spr:Receptor)
		{

			if(shouldResetDadReceptors){ // so when holding it wont awkwardly reset the anim
				if (spr.animation.finished && spr.animation.curAnim.name=='confirm')
				{
					spr.playAnim('static',true);
				}
			}

		});
		FlxG.watch.addQuick("note count", renderedNotes.members.length);

		strumLineNotes.sort(sortByOrder);


		if (!inCutscene){


			/*if(pressedKeys.contains(true)){
				for(idx in 0...pressedKeys.length){
					var isHeld = pressedKeys[idx];
					if(isHeld)
						for(daNote in getHittableHolds(idx))
							noteHit(daNote);
				}
			}*/
		}

		if(currentOptions.ratingInHUD){
			camRating.zoom = camHUD.zoom;
		}else{
			camRating.zoom = camGame.zoom;
		}
		camReceptor.zoom = camHUD.zoom;
		camNotes.zoom = camReceptor.zoom;
		camSus.zoom = camNotes.zoom;

		#if sys
		if(luaModchartExists && lua!=null){
			lua.setGlobalVar("curDecBeat",curDecBeat);
			lua.setGlobalVar("curDecStep",curDecStep);

			lua.call("update",[elapsed]);
		}
		#end

		if(Conductor.rawSongPos>=inst.length + currentOptions.noteOffset){
			if(inst.volume>0 || vocals.volume>0)
				finishSong();

			inst.volume=0;
			vocals.volume=0;
		}
		#if debug
		if (FlxG.keys.justPressed.ONE)
			finishSong();
		#end
		if (calibrating && FlxG.keys.justPressed.ESCAPE)
			finishSong();
	}

	var songEnded:Bool=false;

	function finishSong(){
		if(songEnded)return;
		for(note in unspawnNotes)
			destroyNote(note);

		if(calibrating){
			for(note in renderedNotes){
				for(tail in note.tail)
					destroyNote(tail);
				
				destroyNote(note);
			}
			inst.pause();
			vocals.pause();
			eventSchedule=[];
			unspawnNotes=[];
			openSubState(new UseOffsetSubstate(originalOffset, newOffset));
		}else{
			unspawnNotes = [];
			songEnded = true;
			canPause = false;
			dontSync = true;
			inst.volume = 0;
			vocals.volume = 0;
			inst.stop();
			vocals.stop();
			eventSchedule = [];
			if(isStoryMode){
				if(endDialogueData!=null){
					var dialog = startDialog(endDialogueData);
					dialog.finishCallback = endSong;
				}else if(endCutsceneData!=null){
					var cutscene = startCutscene(endCutsceneData);
					cutscene.fadeOut = false;
					cutscene.finishCallback = endSong;
				}else
					endSong();
			}else
				endSong();
		}


	}

	function endSong():Void
	{
		seenCutscene = false;
		canPause = false;
		inst.volume = 0;
		vocals.volume = 0;
		inst.stop();

		#if cpp
		if(lua!=null){
			lua.destroy();
			lua=null;
		}
		#end
		if (SONG.validScore && !died && canScore)
		{
			#if !switch
			Highscore.saveScore(songData.chartName, songScore, storyDifficulty);
			#end
		}

		if(inCharter){
			inst.pause();
			vocals.pause();
			FlxG.switchState(new ChartingState());
		}else{
			if (isStoryMode)
			{
				if(!died && canScore)
					campaignScore += songScore;

				gotoNextStory();

				if (storyPlaylist.length <= 0)
				{

					FlxG.sound.playMusic(Paths.music('freakyMenu'));

					FlxG.switchState(new StoryMenuState());
					


					// if ()
					//StoryMenuState.weekUnlocked[Std.int(Math.min(storyWeek + 1, StoryMenuState.weekUnlocked.length - 1))] = true;

					if (SONG.validScore && !died && canScore)
					{
						//NGio.unlockMedal(60961);
						Highscore.saveWeekScore(storyWeek, campaignScore, storyDifficulty);
					}

					if(FlxG.save.data.weeksBeaten==null)
						FlxG.save.data.weeksBeaten=[];
					
					FlxG.save.data.weeksBeaten[storyWeek]=true;
					FlxG.save.flush();

					//FlxG.save.data.weekUnlocked = StoryMenuState.weekUnlocked;
					//FlxG.save.flush();
				}
				else
				{

					if (songData.chartName.toLowerCase() == 'eggnog')
					{
						var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
							-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
						blackShit.scrollFactor.set();
						add(blackShit);
						camHUD.visible = false;

						FlxG.sound.play(Paths.sound('Lights_Shut_off'));
					}

					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;
					prevCamFollow = camFollow;

					inst.stop();

					LoadingState.loadAndSwitchState(new PlayState());
				}
			}
			else
			{
				trace('WENT BACK TO FREEPLAY??');
				if(fromExtras)
					FlxG.switchState(new ExtrasState());
				else
					FlxG.switchState(new FreeplayState());
				fromExtras=false;
			}
		}
	}


	var endingSong:Bool = false;
	var prevComboNums:Array<String> = [];

	private function showCombo(){
		var seperatedScore:Array<String> = Std.string(combo).split("");

		// WHY DOES HAXE NOT HAVE A DECREMENTING FOR LOOP
		// WHAT THE FUCK
		while(comboSprites.length>0){
			comboSprites[0].kill();
			comboSprites.remove(comboSprites[0]);
		}
		var placement:String = Std.string(combo);
		var ratingCameras = [camRating];
		var baseX = FlxG.width * 0.55;
		if(currentOptions.ratingInHUD)
			baseX = FlxG.width * 0.5;
		

		var pixelShitPart1:String = "";
		var pixelShitPart2:String = '';

		if (noteModifier=='pixel')
		{
			pixelShitPart1 = 'pixelUI/';
			pixelShitPart2 = '-pixel';
		}

		if(combo!=0){
			if(currentOptions.showComboCounter){
				var daLoop:Float = 0;
				var idx:Int = -1;
				for (i in seperatedScore)
				{
					idx++;
					if(i=='-'){
						i='negative';
					}
					//var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'num' + i + pixelShitPart2));
					var numScore:Null<ComboSprite> = null;
					if(currentOptions.recycleComboJudges){
						numScore = comboBin.recycle(ComboSprite);
						numScore.setStyle(noteModifier);
					}else
						numScore = new ComboSprite(0,0,noteModifier);
					numScore.setup();
					numScore.number = i;
					numScore.screenCenter(XY);
					numScore.x = baseX + (43 * daLoop) - 90;
					numScore.y += 25;

					if(currentOptions.fcBasedComboColor){
						if(judgeMan.judgementCounter.get("miss")==0 && judgeMan.judgementCounter.get("bad")==0 && judgeMan.judgementCounter.get("shit")==0){
							if(judgeMan.judgementCounter.get("good")>0)
								numScore.color = 0x77E07E;
							else if(judgeMan.judgementCounter.get("sick")>0){
								numScore.color = 0x99F7F4;
							}
							else if(judgeMan.judgementCounter.get("epic")>0){
								numScore.color = 0xA97FDB;
							}
						}else{
							numScore.color = 0xFFFFFF;
						}
					}

					if (noteModifier!='pixel')
					{
						numScore.antialiasing = true;
						numScore.setGraphicSize(Std.int(numScore.width * 0.5));
					}
					else
					{
						numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom * .8));
					}
					numScore.updateHitbox();

					if(currentOptions.ratingInHUD){
						numScore.scrollFactor.set(0,0);
						numScore.y += 50;
						numScore.x -= 50;
					}
					numScore.cameras=ratingCameras;
					numScore.x += currentOptions.judgeX;
					numScore.y += currentOptions.judgeY;

					var scaleX = numScore.scale.x;
					var scaleY = numScore.scale.y;

					insert(members.length + 1, numScore);
					if(currentOptions.smJudges){
						comboSprites.push(numScore);
						//
						numScore.scale.x *= 1.25;
						numScore.scale.y *= 0.75;
						numScore.alpha = 0.6;
						numScore.currentTween = FlxTween.tween(numScore, {"scale.x": scaleX, "scale.y": scaleY, alpha: 1}, 0.2, {
							ease: FlxEase.circOut
						});

					}else{
						numScore.currentTween = FlxTween.tween(numScore, {alpha: 0}, 0.2, {
							onComplete: function(tween:FlxTween)
							{
								numScore.kill();
								remove(numScore);
							//	numScore.destroy();
							},
							startDelay: Conductor.crochet * 0.002
						});
						numScore.acceleration.y = FlxG.random.int(200, 300);
						numScore.velocity.y -= FlxG.random.int(140, 160);
						numScore.velocity.x = FlxG.random.float(-5, 5);
					}

					daLoop++;
				}
			}
			prevComboNums = seperatedScore;
		}
	}

	var judge:FlxSprite;

	var simpleJudge:JudgeSprite;
	
	private function popUpScore(daRating:String,?noteDiff:Float):Void
	{

		var ratingX = FlxG.width * 0.55;

		var pixelShitPart1:String = "";
		var pixelShitPart2:String = '';

		if (noteModifier=='pixel')
		{
			pixelShitPart1 = 'pixelUI/';
			pixelShitPart2 = '-pixel';
		}

		var ratingCameras = [camRating];
		if(currentOptions.showRatings){
			var rating:Null<JudgeSprite> = null;
			if (currentOptions.smJudges && simpleJudge != null)
				rating = simpleJudge;
			else if(currentOptions.recycleComboJudges){
				rating = judgeBin.recycle(JudgeSprite);
				rating.setStyle(noteModifier);
			}else{
				rating = new JudgeSprite(0, 0, noteModifier);
				
			}
			if (currentOptions.smJudges && simpleJudge == null)simpleJudge = rating;


			rating.setup();
			rating.judgement = daRating;
			rating.screenCenter();
			rating.x = ratingX - 40;
			rating.y -= 60;


			if (noteModifier!='pixel')
			{
				rating.setGraphicSize(Std.int(rating.width * 0.7));
				rating.antialiasing = true;
			}
			else
			{
				rating.setGraphicSize(Std.int(rating.width * daPixelZoom * .8));
			}

			rating.updateHitbox();

			if(currentOptions.ratingInHUD){
				rating.scrollFactor.set(0,0);

				rating.screenCenter();
				ratingX = FlxG.width / 2;
				rating.y -= 25;
			}

			rating.x += currentOptions.judgeX;
			rating.y += currentOptions.judgeY;

			if(currentOptions.smJudges){
				if(judge!=null && judge.alive && judge!=simpleJudge)
					judge.kill();

				if(!simpleJudge.alive)simpleJudge.revive();

				insert(members.length+1, rating);
				
				var scaleX = rating.scale.x;
				var scaleY = rating.scale.y;
				rating.scale.scale(1.1);
				if(rating.currentTween!=null && rating.currentTween.active){
					rating.currentTween.cancel();
					rating.currentTween=null;
				}
				rating.currentTween = FlxTween.tween(rating, {"scale.x": scaleX, "scale.y": scaleY}, 0.1, {
					onComplete: function(tween:FlxTween)
					{
						if(rating.alive && rating.currentTween==tween){
							rating.currentTween = FlxTween.tween(rating, {"scale.x": 0, "scale.y": 0}, 0.2, {
								onComplete: function(tween:FlxTween)
								{
									rating.kill();
									//rating.destroy();
									remove(rating);
									if(judge==rating)judge=null;
								},
								ease: FlxEase.quadIn,
								startDelay: 0.6
							});
						}
					},
					ease: FlxEase.quadOut
				});

			}else{
				rating.currentTween = FlxTween.tween(rating, {alpha: 0}, 0.2, {
					onComplete: function(tween:FlxTween)
					{
						rating.kill();
						remove(rating);
					//	rating.destroy();
					},
					startDelay: Conductor.crochet * 0.001
				});
				rating.acceleration.y = 550;
				rating.velocity.y -= FlxG.random.int(140, 175);
				rating.velocity.x -= FlxG.random.int(0, 10);
				insert(members.length+1, rating);
			}

			judge=rating;

			rating.cameras=ratingCameras;

		}

		showCombo();
		var daLoop:Float=0;
		if(currentOptions.showMS && noteDiff!=null){
			var displayedMS = CoolUtil.truncateFloat(noteDiff,2);
			var seperatedMS:Array<String> = Std.string(displayedMS).split("");
			for (i in seperatedMS)
			{
				if(i=="."){
					i = "point";
					daLoop-=.5;
				}
				if(i=='-'){
					i='negative';
					daLoop--;
				}

			//	var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'num' + i + pixelShitPart2));
				var numScore:Null<ComboSprite> = null;
				if(currentOptions.recycleComboJudges){
					numScore = comboBin.recycle(ComboSprite);
					numScore.setStyle(noteModifier);
				}else
					numScore = new ComboSprite(0,0,noteModifier);

				numScore.setup();
				numScore.number = i;
				numScore.screenCenter();
				numScore.x = ratingX + (32 * daLoop) + 15;
				numScore.y += 50;

				if(i=='point'){
					if(noteModifier!="pixel")
						numScore.x += 25;
					else{
						//numScore.y += 35;
						numScore.x += 24;
					}
				}


				switch(daRating){
					case 'epic':
						numScore.color = 0xC182FF;
					case 'sick':
						numScore.color = 0x00ffff;
					case 'good':
						numScore.color = 0x14cc00;
					case 'bad':
						numScore.color = 0xa30a11;
					case 'shit':
						numScore.color = 0x5c2924;
					default:
						numScore.color = 0xFFFFFF;
				}

				if (noteModifier!='pixel')
				{
					numScore.antialiasing = true;
					numScore.setGraphicSize(Std.int((numScore.width * 0.5)*.75));
				}
				else
				{
					numScore.setGraphicSize(Std.int((numScore.width * daPixelZoom * .8)*.75));
				}
				numScore.updateHitbox();

				numScore.acceleration.y = FlxG.random.int(100, 150);
				numScore.velocity.y -= FlxG.random.int(50, 75);
				numScore.velocity.x = FlxG.random.float(-2.5, 2.5);

				if(currentOptions.ratingInHUD){
					numScore.y += 10;
					numScore.x += 75;
					numScore.scrollFactor.set(0,0);
				}

				numScore.x += currentOptions.judgeX;
				numScore.y += currentOptions.judgeY;

				numScore.cameras=ratingCameras;

				insert(members.length + 1, numScore);

				numScore.currentTween = FlxTween.tween(numScore, {alpha: 0}, 0.2, {
					onComplete: function(tween:FlxTween)
					{
						numScore.kill();
						remove(numScore);
						//numScore.destroy();
					},
					startDelay: Conductor.crochet * 0.0005
				});

				daLoop++;
			}
		}

		// add(coolText);



		updateAccuracy();
		curSection += 1;
	}

	function updateReceptors(){
		playerStrums.forEach(function(spr:Receptor)
		{
			if(pressedKeys[spr.ID] && spr.animation.curAnim.name!="confirm" && spr.animation.curAnim.name!="pressed" )
				spr.playAnim("pressed");

			if(!pressedKeys[spr.ID]){
				spr.playAnim("static");
			}
		});

		strumLineNotes.sort(sortByOrder);
	}

	private function keyPress(event:KeyboardEvent){
		if(paused)return;
		#if !NO_BOTPLAY
		if(event.keyCode == FlxKey.F6 && !calibrating)
			ScoreUtils.botPlay = !ScoreUtils.botPlay;
		
		#end
		if(ScoreUtils.botPlay)return;
		var direction = bindData.indexOf(event.keyCode);
		if(direction!=-1 && !pressedKeys[direction]){
			pressedKeys[direction]=true;
			handleInput(direction);
			updateReceptors();
		}

	}

	private function keyRelease(event:KeyboardEvent){
		if(paused)return;
		if(ScoreUtils.botPlay)return;
		var direction = bindData.indexOf(event.keyCode);
		if(direction!=-1 && pressedKeys[direction]){
			pressedKeys[direction]=false;
			updateReceptors();
		}
	}

	private function handleInput(direction:Int){
		if(direction!=-1){
			var hitting:Array<Note> = getHittableNotes(direction,true);
			hitting.sort((a,b)->Std.int(a.strumTime-b.strumTime)); // SHOULD be in order?
			// But just incase, we do this sort

			// TODO: chord cohesion, maybe
			if(hitting.length>0){
				player.holdTimer=0;
				for(hit in hitting){
					noteHit(hit);
					break;
				}
			}else{
				if(currentOptions.ghosttapSounds)
					FlxG.sound.play(Paths.sound('Ghost_Hit'),currentOptions.hitsoundVol/100);

				if(currentOptions.ghosttapping==false)
					badNoteCheck();
			}

		}
	}

	/*private function botplay(){
		var holdArray:Array<Bool> = [false,false,false,false];
		var controlArray:Array<Bool> = [false,false,false,false];
		for(note in playerNotes){
			if(note.mustPress && note.canBeHit && note.strumTime<=Conductor.songPosition+5 && !note.isSustainNote){
				if(note.sustainLength>0 && botplayHoldMaxTimes[note.noteData]<note.sustainLength){
					controlArray[note.noteData]=true;
					botplayHoldTimes[note.noteData] = (note.sustainLength/1000)+.1;
				}
				if(!note.isSustainNote){
					controlArray[note.noteData]=true;
					if(botplayHoldTimes[note.noteData]<=.2){
						botplayHoldTimes[note.noteData] = .2;
					}
				}
			}
		}

		for(idx in 0...botplayHoldTimes.length){
			if(botplayHoldTimes[idx]>0){
				pressedKeys[idx]=true;
				botplayHoldTimes[idx]-=FlxG.elapsed;
			}else{
				pressedKeys[idx]=false;
			}
		}

		for(idx in 0...controlArray.length){
			var pressed = controlArray[idx];
			if(pressed)
				handleInput(idx);
		}

		updateReceptors();
	}*/
	private function preNoteLogic(elapsed: Float){
		// put whatever code here idk

		// botplay
		if(ScoreUtils.botPlay){
			for(dir in 0...botplayHoldTimes.length){
				if(botplayHoldTimes[dir]>0)botplayHoldTimes[dir]-=elapsed*1000;
				if(botplayHoldTimes[dir]<0)botplayHoldTimes[dir]=0;
				var time = botplayHoldTimes[dir];
				if(time>0){
					if(!pressedKeys[dir]){
						pressedKeys[dir]=true;
						handleInput(dir);
						updateReceptors();
					}
				}else{
					if(pressedKeys[dir]){
						pressedKeys[dir]=false;
						updateReceptors();
					}
				}
			}
		}
	}

	private function postNoteLogic(elapsed: Float){
		// put whatever code here idk

		// botplay
		if(ScoreUtils.botPlay){
			for(dir in 0...botplayHoldTimes.length){
				var notes = getHittableNotes(dir,true);
				for(note in notes){
					var diff = note.strumTime - Conductor.songPosition;
					if(diff<=10 && note.causesMiss){
						if(note.sustainLength==0)
							botplayHoldTimes[dir] = 100;
						else
							botplayHoldTimes[dir] = note.sustainLength+100;


						pressedKeys[dir]=true;
						handleInput(dir);
						updateReceptors();
					}
				}
			}
		}
	}

	function getHittableNotes(direction:Int=-1,excludeHolds:Bool=false){
		var notes:Array<Note>=[];
		for(note in playerNotes){
			if(note.canBeHit && note.alive && !note.wasGoodHit && !note.tooLate && (direction==-1 || note.noteData==direction) && (!excludeHolds || !note.isSustainNote)){
				notes.push(note);
			}
		}
		return notes;
	}

	function getHittableHolds(?direction:Int=-1){
		var sustains:Array<Note>=[];
		for(note in getHittableNotes()){
			if(note.isSustainNote && !note.parent.tooLate){
				sustains.push(note);
			}
		}
		return sustains;
	}

	function showMiss(direction:Int){
		player.holding=false;
		switch (direction)
		{
			case 0:
				player.playAnim('singLEFTmiss', true);
			case 1:
				player.playAnim('singDOWNmiss', true);
			case 2:
				player.playAnim('singUPmiss', true);
			case 3:
				player.playAnim('singRIGHTmiss', true);
		}
	}

	function noteMiss(direction:Int = 1):Void
	{
		health += judgeMan.getJudgementHealth('miss');
		judgeMan.judgementCounter.set("miss",judgeMan.judgementCounter.get("miss")+1);
		updateJudgementCounters();
		previousHealth=health;
		#if desktop
		if(luaModchartExists && lua!=null){
			lua.call("noteMiss",[direction]);
		}
		#end
		if (combo > 5 && gf.animOffsets.exists('sad'))
		{
			gf.playAnim('sad');
		}
		combo = 0;
		showCombo();

		songScore += judgeMan.getJudgementScore('miss');

		FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.3, 0.6));

		updateAccuracy();
		showMiss(direction);
	}

	function badNoteCheck()
	{
		// just double pasting this shit cuz fuk u
		// REDO THIS SYSTEM!
		var upP = controls.UP_P;
		var rightP = controls.RIGHT_P;
		var downP = controls.DOWN_P;
		var leftP = controls.LEFT_P;
		if(currentOptions.accuracySystem==2){
			hitNotes-=2;
		}else{
			hitNotes--;
		}
		if (leftP)
			noteMiss(0);
		if (downP)
			noteMiss(1);
		if (upP)
			noteMiss(2);
		if (rightP)
			noteMiss(3);
	}


	function noteHit(note:Note):Void
	{
		if (!note.wasGoodHit){
			var diff = note.strumTime - Conductor.songPosition;
			switch(note.noteType){
				case 'mine':
					hurtNoteHit(note);
				case 'loan':
					goldNoteHit(note);
				case 'alt':
					goodNoteHit(note,diff,true);
				default:
					goodNoteHit(note,diff,false);
			}
			var judge = judgeMan.determine(diff);

			note.wasGoodHit=true;
			playerStrums.forEach(function(spr:Receptor)
			{
				if (Math.abs(note.noteData) == spr.ID)
				{
					spr.playNote(note,(currentOptions.useNotesplashes && !note.isSustainNote)?(judge=='sick' || judge=='epic'):false);
				}
			});
			updateReceptors();

			if (!note.isSustainNote && note.tail.length==0)
			{
				note.kill();
				if(note.mustPress){
					//noteLanes[note.noteData].remove(note);
					playerNotes.remove(note);
				}
				renderedNotes.remove(note, true);
				note.destroy();
			}else if(note.mustPress && note.isSustainNote){
				if(note.parent!=null){
					if(note.parent.unhitTail.contains(note)){
						note.parent.unhitTail.remove(note);
					}
				}
			//	susNoteLanes[note.noteData].remove(note);
			}
		}

	}

	function updateJudgementCounters(){
		for(judge in counters.keys()){
			var txt = counters.get(judge);
			var name:String = JudgementManager.judgementDisplayNames.get(judge);
			if(name==null){
				name = '${judge.substring(0,1).toUpperCase()}${judge.substring(1,judge.length)}';
			}
			txt.text = '${name}: ${judgeMan.judgementCounter.get(judge)}';
			txt.x=0;
		}
	}

	function hurtNoteHit(note:Note):Void{
		health -= 0.25;
		judgeMan.judgementCounter.set("miss",judgeMan.judgementCounter.get("miss")+1);
		updateJudgementCounters();
		previousHealth=health;
		#if desktop
		if(luaModchartExists && lua!=null){
			lua.call("hitMine",[note.noteData,note.strumTime,Conductor.songPosition,note.isSustainNote]);
		}
		#end
		if (combo > 5 && gf.animOffsets.exists('sad'))
		{
			gf.playAnim('sad');
		}
		combo = 0;
		showCombo();

		songScore -= 600;

		FlxG.sound.play(Paths.sound('mineExplode'), FlxG.random.float(0.5, 0.7));

		if(currentOptions.accuracySystem==2)
			hitNotes+=ScoreUtils.malewifeMineWeight;
		else
			hitNotes-=1.2;

		updateAccuracy();
		player.holding=false;
		if(player.animation.getByName("hurt")!=null){
			player.playAnim('hurt', true);
			player.noIdleTimer = Conductor.stepCrochet*4;
		}else
			showMiss(note.noteData);
	}

	function playAnimationNote(who:Character, daNote:Note, suffix:String=''){
		var dirs = ["LEFT","DOWN","UP","RIGHT"];
		var dir = "";
		var anim = "";
		dir = dirs[daNote.noteData];
		anim = 'sing${dir}';

		if(daNote.tail.length>0 && !daNote.isSustainNote){
			if(who.animation.getByName('hold${dir}Start')!=null)
				anim = 'hold${dir}Start';
			else if(who.animation.getByName('hold${dir}')!=null)
				anim = 'hold${dir}';
		}else if(daNote.isSustainNote){
			if(who.animation.getByName('hold${dir}')!=null)
				anim = 'hold${dir}';
		}

		if(daNote.isSustainEnd()){
			if(who.animation.getByName('hold${dir}End')!=null)
				anim = 'hold${dir}End';
		}

		if(who.animation.getByName(anim+suffix)!=null)
			anim += suffix;
		
		who.holdTimer = 0;
		who.bandaidSolution = (0.1 * Conductor.stepCrochet) / 1000;
		if(who.animation.curAnim!=null){
			if(who.animation.curAnim!=null && (!anim.startsWith("hold") || who.animation.curAnim.name!=anim)){
				who.playAnim(anim, true);
			}
		}
		

	}

	function goldNoteHit(note:Note):Void
	{
		vocals.volume = 1;

		goldOverlay.alpha = 1;
		if(goldTween!=null)goldTween.cancel();
		goldTween = tween(goldOverlay, {alpha: 0}, 0.2, {
			ease: FlxEase.linear,
			onComplete: function(twn:FlxTween)
			{
				goldTween=null;
			}
		});
		FlxG.sound.play(Paths.sound('Gold_Note_Hit'), 0.85);
		if(currentOptions.hitSound && !note.isSustainNote)
			FlxG.sound.play(Paths.sound('Normal_Hit'),currentOptions.hitsoundVol/100);

		#if desktop
		if(luaModchartExists && lua!=null)
			lua.call("goldNoteHit",[note.noteData,note.strumTime,Conductor.songPosition,note.isSustainNote]); // TODO: Note lua class???
		#end

		var owed = 2-health;
		if(owed<=0)owed=0.3;
		goldLoan += owed;
		goldLoan += (goldLoan * (24/100));
		health=2;

		previousHealth=health;

		player.noIdleTimer = Conductor.stepCrochet*4;
		player.playAnim("hey", true);

		vocals.volume = 1;
		updateAccuracy();
	}

	var syncOffsets:Array<Float> = [];
	var newOffset:Int = 0;
	var deviation:Int = 0;
	function goodNoteHit(note:Note,noteDiff:Float,altAnim:Bool=false):Void
	{
		var judgement = note.isSustainNote?judgeMan.determine(0):judgeMan.determine(noteDiff);

		var breaksCombo = judgeMan.shouldComboBreak(judgement);

		if(judgement=='miss')
			return noteMiss(note.noteData);

		if(calibrating){
			if(judgement != 'shit' && judgement != 'bad'){
				syncOffsets.push(noteDiff);
				
				if(syncOffsets.length >= 24){
					var mean:Float = 0;
					var dev:Float = 0;
					for(idx in 0...syncOffsets.length)mean += syncOffsets[idx];
					mean /= syncOffsets.length;
					
					for(i in 0...syncOffsets.length)
						dev += (i - mean) * (i - mean);
					dev /= syncOffsets.length;
					dev = Math.sqrt(dev);
	
					if(dev < 30){
						newOffset += Math.round(mean);
						currentOptions.noteOffset = newOffset;
						Conductor.songPosition = Conductor.rawSongPos + currentOptions.noteOffset;
						var wow:Alphabet = new Alphabet(0, 0, "Set Offset!", true, false);
						wow.cameras = [camHUD];
						wow.screenCenter(XY);
						FlxTween.tween(wow, {alpha: 0}, 0.2, {
							onComplete: function(tween:FlxTween)
							{
								wow.kill();
								remove(wow);
							},
							startDelay: Conductor.crochet * 0.002
						});
						wow.acceleration.y = FlxG.random.int(200, 300);
						wow.velocity.y -= FlxG.random.int(140, 160);
						wow.velocity.x = FlxG.random.float(-5, 5);
						
						add(wow);
					}else{
						var wow:Alphabet = new Alphabet(0, 0, "Offset could not be set", true, false);
						wow.cameras = [camHUD];
						wow.screenCenter(XY);
						FlxTween.tween(wow, {alpha: 0}, 0.2, {
							onComplete: function(tween:FlxTween)
							{
								wow.kill();
								remove(wow);
							},
							startDelay: Conductor.crochet * 0.002
						});
						wow.acceleration.y = FlxG.random.int(200, 300);
						wow.velocity.y -= FlxG.random.int(140, 160);
						wow.velocity.x = FlxG.random.float(-5, 5);

						add(wow);
					}
					deviation = Math.floor(dev);
					syncOffsets.resize(0);
				}
				calibrationTxt.text = "Calibrating Offset\nNew Offset: " + newOffset + "\nOld Offset: " + originalOffset + "\nDeviation: " + deviation + "\nSamples: " + syncOffsets.length + " / 24";
			}

		}

		vocals.volume = 1;

		if (!note.isSustainNote)
		{
			if(breaksCombo){
				combo=0;
				showCombo();
				judgeMan.judgementCounter.set('miss',judgeMan.judgementCounter.get('miss')+1);
			}else{
				combo++;
			}

			var score:Int = judgeMan.getJudgementScore(judgement);
			if(currentOptions.accuracySystem==2){
				var wifeScore = ScoreUtils.malewife(noteDiff,Conductor.safeZoneOffset/180);
				totalNotes+=2;
				hitNotes+=wifeScore;
			}else{
				if(currentOptions.accuracySystem!=1)
					totalNotes++;
				hitNotes+=judgeMan.getJudgementAccuracy(judgement);
			}
			if(ScoreUtils.botPlay){
				botplayScore+=score;
			}else{
				songScore += score;
			}
			judgeMan.judgementCounter.set(judgement,judgeMan.judgementCounter.get(judgement)+1);
			updateJudgementCounters();
			popUpScore(judgement,-noteDiff);
			if(combo>highestCombo)
				highestCombo=combo;

			highComboTxt.text = "Highest Combo: " + highestCombo;
		}

		if(currentOptions.hitSound && !note.isSustainNote)
			FlxG.sound.play(Paths.sound('Normal_Hit'),currentOptions.hitsoundVol/100);

		var strumLine = playerStrums.members[note.noteData%4];

	#if desktop
		if(luaModchartExists && lua!=null)
			lua.call("goodNoteHit",[note.noteData,note.strumTime,Conductor.songPosition,note.isSustainNote]); // TODO: Note lua class???
		#end


		if(!note.isSustainNote){
			var hpBack = judgeMan.getJudgementHealth(judgement);
			if(goldLoan<=0)
				health += hpBack;
			else{
				goldLoan -= hpBack;
				if(goldLoan<0)goldLoan=0;
			}
		}

		if(health>2)
			health=2;

		previousHealth=health;

		var dirs = ["LEFT","DOWN","UP","RIGHT"];
		var dir = "";
		var anim = "";
		dir = dirs[note.noteData];
		anim = 'sing${dir}';

		var suffix = '';
		if(breaksCombo && !note.isSustainNote){
			anim='sing${dir}miss';
			player.playAnim(anim, true);
		}else if(!note.isSustainNote)
			playAnimationNote(player, note, suffix);



		//}
		vocals.volume = 1;
		updateAccuracy();

	}

	var fastCarCanDrive:Bool = true;
	var lStep:Int = 0;
	var prevCombo:Int = 0;
	var dontPlayCombo:Bool = false;
	override function stepHit()
	{
		super.stepHit();
		if(songEnded)return;
		#if sys
		if(luaModchartExists && lua!=null){
			lua.setGlobalVar("curStep",curStep);
			lua.call("stepHit",[curStep]);
		}
		#end
		if(!paused && !dontSync){
			if (inst != null && !startingSong && vocals!=null && SONG.needsVoices){
				if (Math.abs(vocals.time - inst.time) > 40)
				{
					trace("vocals went off sync from inst for some reason!! difference of " + Math.abs(vocals.time - inst.time));
					resyncVocals();
				}
			}
		}

		if (curStep % gfSpeed == 0)
			gf.dance();

		var lastChange = Conductor.getBPMFromStep(curStep);
		if(lastChange.bpm != Conductor.bpm){
			Conductor.changeBPM(lastChange.bpm);
			#if sys
			if(luaModchartExists && lua!=null){
				lua.setGlobalVar("bpm",Conductor.bpm);
				lua.setGlobalVar("crochet",Conductor.crochet);
				lua.setGlobalVar("stepCrochet",Conductor.stepCrochet);
			}
			#end
		}

		if (SONG.song.toLowerCase() == 'violets' && !dontPlayCombo){
			//local thing = curBpm <= 140 and math.snap(((-curBpm + 140) / 2.5), 8) + 8 or 8
			var shit = Conductor.bpm <= 140 ? CoolUtil.snapNum(((-Conductor.bpm + 140) / 2.5), 8) + 8 : 8;
			if(curStep % shit==0){
				var newCombo = combo - prevCombo;
				if(newCombo >= 5){
					var canPlay:Bool = true;
					var n:Float = 0;
					var songPos = Conductor.songPosition;
					var et = songPos + (Conductor.stepCrochet * shit);
					for(i in 0...renderedNotes.length){
						var note = renderedNotes.members[i];
						var time = note.strumTime;
						if(note.mustPress && !note.isSustainNote && time >= songPos && time < et){
							canPlay=false;
							break;
						}
					}
					if(canPlay){
						noteCancer.animation.play("anim", true, false, 13);
						noteCancer.animation.curAnim.reverse();
						new FlxTimer().start(14/24, function(tmr: FlxTimer){
							dontPlayCombo=false;
							remove(noteCancer);
						});
						noteCancer.x = 311 - 42;
						noteCancer.y = 223 + 21;
						tween(noteCancer, {x: 311, y: 223}, .12, {ease: FlxEase.quadOut});
						dontPlayCombo=true;

						add(noteCancer);
					}

					prevCombo = combo;
				}
			}
		}
		
		for(step in lStep...curStep){
			if(SONG.song.toLowerCase()=='gran-venta' && storyDifficulty==3){
				switch(step){
					case 1400:
						if(startPos < Conductor.stepToSeconds(1400)){
							FlxTween.tween(grayscale, {influence: 1}, 0.4, {
								ease: FlxEase.quadOut
							});
						}
					case 1408:
						if(startPos < Conductor.stepToSeconds(1408)){
							grayscale.influence = 1;
							camHUD.flash(FlxColor.WHITE, 0.75, null, true);
							for(note in unspawnNotes)
								note.invisible=false;

							renderedNotes.forEachAlive(function(daNote:Note)
							{
								daNote.invisible=false;
							});
						}
					case 1430:
						if(startPos < Conductor.stepToSeconds(1408)){
							FlxTween.tween(grayscale, {influence: 0}, 0.6, {
								ease: FlxEase.quadIn
							});
						}
					case 2800:
						if(startPos < Conductor.stepToSeconds(2800)){
							canPause=false;
							paused=false;
							persistentDraw=true;
							persistentUpdate=true;
							FadeTransitionSubstate.nextCamera = camOther;
							var trans = new FadeTransitionSubstate();
							openSubState(trans);
							FlxG.autoPause=false;
							trans.finishCallback = function(){
								FPSMem.shouldUpdate=false;
								persistentDraw=true;
								persistentUpdate=true;
							};
							trans.start(IN);
						}
					case 2848:
						if(startPos < Conductor.stepToSeconds(2800)){
							add(cum);
							persistentDraw=true;
							persistentUpdate=true;
							canPause=false;
							closeSubState();
							FPSMem.visable=false;


							FlxTween.tween(cumShader, {amount: 1}, 4, {
								ease: FlxEase.linear,
								startDelay: 1
							});

						}
					case 2928:
						FPSMem.visable=true;
						FPSMem.shouldUpdate=true;
						remove(cum);
						canPause=true;
						camHUD.flash(FlxColor.WHITE, 0.75, null, true);

				}
			}
		}
		lStep = curStep;
	}

	override function beatHit()
	{
		super.beatHit();

		if(songEnded)return;

		stage.beatHit(curBeat);

		if (SONG.notes[Math.floor(curStep / 16)] != null)
		{

			if (generatedMusic)
			{
				var prevTurn = turn;
				if(SONG.notes[Std.int(curStep / 16)].mustHitSection){
					if(turn!='bf'){
						turn='bf';
						if(currentOptions.staticCam==0)
							focus='bf';
					}
				}else{
					if(turn!='dad'){
						turn='dad';
						if(goldLoan>0){
							health -= goldLoan;
							player.noIdleTimer = Conductor.stepCrochet*4;
							player.playAnim("hurt",true);
							goldLoan = 0;
						}
						if(currentOptions.staticCam==0)
							focus='dad';
					}
				}

			}
			// else
			// Conductor.changeBPM(SONG.bpm);

			// Dad doesnt interupt his own notes
			if(nonPlayer.animation.curAnim!=null)
				if (!nonPlayer.isSinging && (nonPlayer.animation.curAnim.name!='intro' || nonPlayer.animation.curAnim.finished)){
					if(nonPlayer.hasMic && !startingSong)
						flexyMic.visible=true;
					if(!nonPlayer.curCharacter.contains('flexy') && !nonPlayer.curCharacter.contains('dmp'))
						nonPlayer.dance();
					else if(curBeat%2==0){
						nonPlayer.dance(true);
					}
				}

			for(opp in opponents){
				if(opp!=nonPlayer && opp!=player){
					if(opp.animation.curAnim!=null)
						if (!opp.isSinging)
							opp.dance();
				}
			}


		}
		// FlxG.log.add('change bpm' + SONG.notes[Std.int(curStep / 16)].changeBPM);
		wiggleShit.update(Conductor.crochet);

		// HARDCODING FOR MILF ZOOMS!
		/*if (curSong.toLowerCase() == 'milf' && curBeat >= 168 && curBeat < 200 && camZooming && FlxG.camera.zoom < 1.35)
		{
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
		}*/

		if (camZooming && FlxG.camera.zoom < defaultCamZoom + 0.35 && curBeat % zoomBeatingInterval == 0)
		{
			FlxG.camera.zoom += zoomBeatingZoom;
			camHUD.zoom += zoomBeatingZoom*2;
		}

		healthBar.beatHit(curBeat);


		/*if(boyfriend.animation.curAnim!=null)
			if (!boyfriend.animation.curAnim.name.startsWith("sing"))
				boyfriend.dance();*/
		if(player.animation.curAnim!=null)
			if (!player.isSinging && (player.animation.curAnim.name!='intro' || player.animation.curAnim.finished)){
				if((player.hasMic) && !startingSong)
					flexyMic.visible=true;
				if(!player.curCharacter.contains('flexy') && !player.curCharacter.contains('dmp'))
					player.dance();
				else if(curBeat%2==0)
					player.dance(true);

		}


		if (curBeat % 8 == 7 && curSong == 'Bopeebo')
		{
			boyfriend.playAnim('hey', true);
		}

		/*if (curBeat % 16 == 15 && SONG.song == 'Tutorial' && dad.curCharacter == 'gf' && curBeat > 16 && curBeat < 48)
		{
			boyfriend.playAnim('hey', true);
			dad.playAnim('cheer', true);
		}*/

		#if sys
		if(luaModchartExists && lua!=null){
			lua.setGlobalVar("curBeat",curBeat);
			lua.call("beatHit",[curBeat]);
		}
		#end
	}

	override function destroy(){
		center.put();

		super.destroy();
	}

	override function switchTo(next:FlxState){
		// Do all cleanup of stuff here! This makes it so you dont need to copy+paste shit to every switchState
		#if cpp
		if(lua!=null){
			lua.destroy();
			lua=null;
		}
		#end
		FPSMem.visable=true;
		PlayState.calibrating = false;
		Main.setFPSCap(OptionUtils.options.fps);
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN,keyPress);
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP,keyRelease);

		return super.switchTo(next);
	}

	public static function setStoryWeek(data:WeekData,difficulty:Int){
		PlayState.calibrating = false;
		PlayState.inCharter=false;
		PlayState.startPos = 0;
		PlayState.charterPos = 0;
		storyPlaylist = data.getCharts();
		weekData = data;

		isStoryMode = true;
		storyDifficulty = difficulty;

		SONG = Song.loadFromJson(data.songs[0].formatDifficulty(difficulty), storyPlaylist[0].toLowerCase());
		storyWeek = weekData.weekNum;
		campaignScore = 0;

		PlayState.songData=data.songs[0];
	}

	public function gotoNextStory(){
		PlayState.inCharter=false;
		PlayState.startPos = 0;
		PlayState.charterPos = 0;
		PlayState.calibrating = false;
		storyPlaylist.remove(storyPlaylist[0]);
		if(storyPlaylist.length>0){
			var songData = weekData.getByChartName(storyPlaylist[0]);
			SONG = Song.loadFromJson(songData.formatDifficulty(storyDifficulty), songData.chartName.toLowerCase());

			PlayState.songData=songData;
		}
	}

	public static function setSong(song:SwagSong){
		SONG = song;
		PlayState.calibrating = false;
		var songData = new SongData(SONG.song,SONG.player2,storyWeek,SONG.song,'week${storyWeek}');

		weekData = new WeekData("Chart",songData.weekNum,'dad',[songData],'bf','gf',songData.loadingPath);
		PlayState.songData=songData;
	}

	public static function setFreeplaySong(songData:SongData,difficulty:Int){
		PlayState.inCharter=false;
		PlayState.startPos = 0;
		PlayState.charterPos = 0;
		PlayState.songData=songData;
		PlayState.calibrating = false;
		SONG = Song.loadFromJson(songData.formatDifficulty(difficulty), songData.chartName.toLowerCase());
		weekData = new WeekData("Freeplay",songData.weekNum,'dad',[songData],'bf','gf',songData.loadingPath);
		// TODO: maybe have a "setPlaylist" function which takes WeekData and have FreeplayState create a temporary one n shit
		// could also be used to have custom 'freeplay playlists' where you play multiple songs in a row without being in story mode
		// for now, this'll do

		isStoryMode = false;
		storyDifficulty = difficulty;
		storyWeek = songData.weekNum;
	}
}
