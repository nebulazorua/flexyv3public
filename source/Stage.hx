package;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.text.FlxTypeText;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.input.FlxKeyManager;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxTimer;
import flixel.util.FlxDestroyUtil;
import flixel.math.FlxPoint;
import flixel.system.FlxSound;
import flixel.FlxObject;
import flixel.FlxBasic;
import Options;
import Shaders;
import states.*;
class Stage extends FlxTypedGroup<FlxBasic> {
  public static var songStageMap:Map<String,String> = [
    "tutorial"=>"stage",

    "noche"=>"fiesta",
    "desierto"=>"fiesta",
    "globetrotter"=>"rooftop",
    "gran-venta"=>"shop",
    "12-28"=>"date",
    "malvado"=>"malvado",
    "devoured"=>"devoured",
    "violets"=>"school"
  ];

  public static var stageNames:Array<String> = [
    "stage",
    "fiesta",
    "rooftop",
    "emptyRooftop",
    "rooftop-su",
    "shop",
    "date",
    'lqrooftop',
    'cringemas',
    "malvado",
    "devoured",
		"shopCloseup",
    'school',
    "blank"
  ];

  public var doDistractions:Bool = true;

  // rooftop bg
  var bluFW:FlxSprite;
  var grnFW:FlxSprite;
  var pnkFW:FlxSprite;
  var ylwFW:FlxSprite;

  public var everybodyscumming:FlxSprite;
  public var stageeveryonetellsyounottoworryabout:FlxSprite;
  public var wifeForever:FlxSprite;
  public var ritsack:FlxSprite;
  public var bullShit:FlxSprite; // get it becaquse bull skull onm erchant???

  public var tikyOne:FlxSprite;
  public var noTiky:FlxSprite;
  
  public var bg:FlxSprite;
  public var gfBop:FlxSprite;
  public var meeyaano:FlxSprite;
  public var babyManAndMerchant:FlxSprite;
  public var clowsoe:FlxSprite;
  public var ground:FlxSprite;
  public var demonclownwiththegamernotes:FlxSprite;
  public var bopper:FlxSprite;
  public var sideWallBack:FlxSprite;
  public var sideWall:FlxSprite;

  // merchant bg
  public var orangeBG:FlxSprite;
  public var purpleBG:FlxSprite;
  public var orangeFire1:FlxSprite;
  public var orangeFire2:FlxSprite;
  public var purpleFire1:FlxSprite;
  public var purpleFire2:FlxSprite;

  // malvado bg
  public var memoryShader:MemoryEffect;
  public var corruptSky:FlxSprite;
  public var corruptFloor:FlxSprite;

  // devoured and malvado
	public var corruptOverlay:FlxSprite;
  public var corruptWiggle:FlxSprite;

  // date bg
  var skyLine1:FlxSprite;
  var skyLine2:FlxSprite;
  var ground1:FlxSprite;
  var ground2:FlxSprite;
  var lamp1:FlxSprite;
  var lamp2:FlxSprite;

  // cringemas


  // misc, general bg stuff

  public var bfPosition:FlxPoint = FlxPoint.get(770,450);
  public var dadPosition:FlxPoint = FlxPoint.get(100,100);
  public var gfPosition:FlxPoint = FlxPoint.get(400,130);
  public var camPos:FlxPoint = FlxPoint.get(100,100);
  public var camOffset:FlxPoint = FlxPoint.get(100,100);

  public var layers:Map<String,FlxTypedGroup<FlxBasic>> = [
    "boyfriend"=>new FlxTypedGroup<FlxBasic>(), // stuff that should be layered infront of all characters, but below the foreground
    "dad"=>new FlxTypedGroup<FlxBasic>(), // stuff that should be layered infront of the dad and gf but below boyfriend and foreground
    "gf"=>new FlxTypedGroup<FlxBasic>(), // stuff that should be layered infront of the gf but below the other characters and foreground
  ];
  public var foreground:FlxTypedGroup<FlxBasic> = new FlxTypedGroup<FlxBasic>(); // stuff layered above every other layer
  public var overlay:FlxSpriteGroup = new FlxSpriteGroup(); // stuff that goes into the HUD camera. Layered before UI elements, still
	public var gameOverlay:FlxSpriteGroup = new FlxSpriteGroup(); // stuff that goes below all other HUD elements, but above the game

  public var boppers:Array<Array<Dynamic>> = []; // should contain [sprite, bopAnimName, whichBeats]
  public var dancers:Array<Dynamic> = []; // Calls the 'dance' function on everything in this array every beat

  public var defaultCamZoom:Float = 1.05;

  public var curStage:String = '';

  // other vars
  public var gfVersion:String = 'gf';
  public var gf:Character;
  public var boyfriend:Character;
  public var dad:Character;
  public var currentOptions:Options;
  public var centerX:Float = -1;
  public var centerY:Float = -1;

  override public function destroy(){
    bfPosition = FlxDestroyUtil.put(bfPosition);
    dadPosition = FlxDestroyUtil.put(dadPosition);
    gfPosition = FlxDestroyUtil.put(gfPosition);
    camOffset =  FlxDestroyUtil.put(camOffset);

    super.destroy();
  }


  public function setPlayerPositions(?p1:Character,?p2:Character,?gf:Character){
    if(gf!=null)gf.visible = true;
    if(p1!=null)p1.setPosition(bfPosition.x,bfPosition.y);
    if(gf!=null)gf.setPosition(gfPosition.x,gfPosition.y);
    if(p2!=null){
      p2.setPosition(dadPosition.x,dadPosition.y);
      camPos.set(p2.getGraphicMidpoint().x, p2.getGraphicMidpoint().y);
    }

    if(p1!=null){
      switch(p1.curCharacter){

      }
    }

    if(p2!=null){

      switch(p2.curCharacter){
        case 'gf':
          if(gf!=null){
            p2.setPosition(gf.x, gf.y);
            gf.visible = false;
          }
        case 'dad':
          camPos.x += 400;
      }
    }

    if(gf!=null)
      if(curStage == 'malvadoSide' || curStage == 'malvado' || curStage=='date' || curStage=='rooftop' || curStage == 'emptyRooftop' || curStage=='rooftop-su' || curStage=='lqrooftop' || curStage=='devoured' || curStage == 'shopCloseup')gf.visible=false;
    

    if(p1!=null){
      p1.x += p1.posOffset.x;
      p1.y += p1.posOffset.y;
    }
    if(p2!=null){
      p2.x += p2.posOffset.x;
      p2.y += p2.posOffset.y;
    }
    if(gf!=null){
      gf.x += gf.posOffset.x;
      gf.y += gf.posOffset.y;
    }

  }

  public function new(stage:String, currentOptions:Options){
    super();
		this.currentOptions = currentOptions;
    create(stage);
  }

  public function create(stage:String){
		if (stage == 'halloween')
			stage = 'spooky'; // for kade engine shenanigans
		if ((stage == 'rooftop' || stage == 'rooftop-su') && OptionUtils.options.potato <= 0)
			stage = 'emptyRooftop';
		curStage = stage;
    overlay.scrollFactor.set(0,0); // so the "overlay" layer stays static
		gameOverlay.scrollFactor.set(0, 0); // so the "gameOverlay" layer stays static
    switch (stage){
			case 'malvado':
        dadPosition.x = 1075;
        dadPosition.y = -216;

        bfPosition.x += 300;
        defaultCamZoom = 0.9;

				corruptSky = new FlxSprite(-135, -410).loadGraphic(Paths.image("malvado/sky"));
				corruptSky.scrollFactor.set(0.6, 0.6);
        corruptSky.setGraphicSize(Std.int(corruptSky.width * 3));
				corruptSky.antialiasing = true;
				add(corruptSky);

				corruptFloor = new FlxSprite(0, 0).loadGraphic(Paths.image("malvado/ground"));
        corruptFloor.scrollFactor.set(1, 1);
        corruptFloor.antialiasing = true;
        add(corruptFloor);

				memoryShader = new MemoryEffect();
        corruptFloor.shader = memoryShader.shader;
				corruptSky.shader = memoryShader.shader;
        
				corruptOverlay = new FlxSprite(0, 0).loadGraphic(Paths.image('malvado/corruption border'));
				corruptOverlay.screenCenter(XY);
				corruptOverlay.setGraphicSize(1280, 720);
				corruptOverlay.antialiasing = true;
				corruptOverlay.scrollFactor.set(0, 0);
				gameOverlay.add(corruptOverlay);

				corruptWiggle = new FlxSprite(0, 0);
				corruptWiggle.frames = Paths.getSparrowAtlas("malvado/wiggly");
				corruptWiggle.animation.addByPrefix("wiggle", "wiggly", 24, true);
				corruptWiggle.antialiasing = true;
				corruptWiggle.scrollFactor.set(0, 0);
				corruptWiggle.animation.play("wiggle", true);
				corruptWiggle.updateHitbox();
				corruptWiggle.screenCenter(XY);
				gameOverlay.add(corruptWiggle);

      case 'cringemas':
        gfVersion='claygf';
        defaultCamZoom = 0.9;
        gfPosition.x -= 200;
        dadPosition.x = -185;
        dadPosition.y = 505-275;
        bfPosition.x = 925;
        bfPosition.y = 530;

        var scaleFactor = 1996.65 / 1544;

        var sky = new FlxSprite(-275, -210).loadGraphic(Paths.image("christ mas/sky"));
        sky.scrollFactor.set(0.2, 0.2);
        sky.antialiasing=true;
        sky.setGraphicSize(Std.int(sky.width * scaleFactor));
        add(sky);

        var sun = new FlxSprite(1005, -150).loadGraphic(Paths.image("christ mas/sun"));
        sun.scrollFactor.set(0.25, 0.25);
        sun.antialiasing=true;
        sun.setGraphicSize(Std.int(sun.width * scaleFactor));
        add(sun);

        var bglake = new FlxSprite(-275, -210).loadGraphic(Paths.image("christ mas/bglake"));
        bglake.scrollFactor.set(0.5, 0.5);
        bglake.antialiasing=true;
        bglake.setGraphicSize(Std.int(bglake.width * scaleFactor));
        add(bglake);

        var tree = new FlxSprite(-256, 75).loadGraphic(Paths.image("christ mas/christmastree"));
        tree.scrollFactor.set(0.5, 0.5);
        tree.antialiasing=true;
        tree.setGraphicSize(Std.int(tree.width * scaleFactor));
        add(tree);

        var littlemen = new FlxSprite(850, 395).loadGraphic(Paths.image("christ mas/gingerbread"));
        littlemen.scrollFactor.set(0.5, 0.5);
        littlemen.antialiasing=true;
        littlemen.setGraphicSize(Std.int(littlemen.width * scaleFactor));
        add(littlemen);

        var fg = new FlxSprite(-275, 225).loadGraphic(Paths.image("christ mas/foregrond"));
        fg.scrollFactor.set(1, 1);
        fg.antialiasing=true;
        fg.setGraphicSize(Std.int(fg.width * scaleFactor));
        add(fg);

      case 'lqrooftop':
        camOffset.x = 250;
        camOffset.y = 150;
        defaultCamZoom = 0.85;

        bfPosition.x = 895;
        bfPosition.y = 120;

        dadPosition.x = 80;
        dadPosition.y = 50-200;
        gfVersion = 'speakers';
        gfPosition.x = 380;
        gfPosition.y = 95;
        bg = new FlxSprite(-740, -485).loadGraphic(Paths.image('rooftop/lowquality'));
        bg.antialiasing = true;
        bg.setGraphicSize (Std.int(bg.width * (4/3)));
        bg.scrollFactor.set(1, 1);
        bg.y = -245;
        bg.x = -500;
        add(bg);
      case "emptyRooftop":
				camOffset.x = 250;
				camOffset.y = 150;

				gfVersion = 'speakers';
				defaultCamZoom = 0.75;

				bfPosition.x = 1050;
				bfPosition.y = 285 + 25;

				dadPosition.x = 330 - 25;
				dadPosition.y = 221 - 200;

				gfPosition.x = 380;
				gfPosition.y = 95;

				bg = new FlxSprite(-600, -400).loadGraphic(Paths.image('rooftop/sky'));
				bg.screenCenter(XY);
				bg.antialiasing = true;
				bg.setGraphicSize(Std.int(bg.width * 1.5));
				bg.scrollFactor.set(0.1, 0.1);
				bg.active = false;
				add(bg);

				wifeForever = new FlxSprite();
				wifeForever.frames = Paths.getSparrowAtlas('rooftop/dmp/cum');
				wifeForever.screenCenter(XY);
				wifeForever.animation.addByPrefix('sky', 'bg', 12);
				wifeForever.setGraphicSize(Std.int(wifeForever.width * 1.5));
				wifeForever.antialiasing = true;
				wifeForever.scrollFactor.set(0.1, 0.1);
				wifeForever.visible = false;
				add(wifeForever);
				wifeForever.animation.play("sky");

				sideWallBack = new FlxSprite().loadGraphic(Paths.image('rooftop/not-building-front'));
				sideWallBack.antialiasing = true;
				sideWallBack.scrollFactor.set(1, 1);
				sideWallBack.x = -482.8;
				sideWallBack.y = 5.6;
				sideWallBack.setGraphicSize(Std.int(sideWallBack.width * 1.25));
				sideWallBack.updateHitbox();
				add(sideWallBack);

        sideWall = new FlxSprite().loadGraphic(Paths.image('rooftop/building-front'));
        sideWall.antialiasing = true;
        sideWall.scrollFactor.set(1, 1);
        sideWall.x = -459;
        sideWall.y = 6.85;
        sideWall.setGraphicSize(Std.int(sideWall.width * 1.25));
        sideWall.updateHitbox();
        add(sideWall);
				
				var ground:FlxSprite = new FlxSprite().loadGraphic(Paths.image('rooftop/stage'));
				ground.antialiasing = true;
				ground.scrollFactor.set(1, 1);
				ground.x = -620;
				ground.y = -172;
				ground.setGraphicSize(Std.int(ground.width * 1.25 * 1.1));
				ground.updateHitbox();
				add(ground);
        
				var roofOverlay:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('rooftop/2overlay'));
				roofOverlay.setGraphicSize(1280, 720);
				roofOverlay.antialiasing = true;
				roofOverlay.alpha = 0.7;
				roofOverlay.screenCenter(XY);
				roofOverlay.active = false;
				overlay.add(roofOverlay);
      case 'rooftop' | 'rooftop-su':
        camOffset.x = 250;
        camOffset.y = 150;

        gfVersion = 'speakers';
        defaultCamZoom = 0.75;

        bfPosition.x = 1050;
        bfPosition.y = 285 + 25;

        dadPosition.x = 330-25;
        dadPosition.y = 231-200;

        gfPosition.x = 380;
        gfPosition.y = 95;

        bg = new FlxSprite(-600, -400).loadGraphic(Paths.image('rooftop/sky'));
        bg.screenCenter(XY);
        bg.antialiasing = true;
        bg.setGraphicSize (Std.int(bg.width * 1.5));
        bg.scrollFactor.set(0.1, 0.1);
        bg.active = false;
        add(bg);

        wifeForever = new FlxSprite();
        wifeForever.frames = Paths.getSparrowAtlas('rooftop/dmp/cum');
        wifeForever.screenCenter(XY);
        wifeForever.animation.addByPrefix('sky', 'bg', 12);
        wifeForever.setGraphicSize (Std.int(wifeForever.width * 1.5));
        wifeForever.antialiasing = true;
        wifeForever.scrollFactor.set(0.1, 0.1);
        wifeForever.visible=false;
        add(wifeForever);
        wifeForever.animation.play("sky");

        ylwFW = new FlxSprite();
        ylwFW.visible=false;
        ylwFW.frames = Paths.getSparrowAtlas('rooftop/fireworks/yellowFirework');
        ylwFW.setGraphicSize(Std.int(ylwFW.width*.4) ) ;
        ylwFW.updateHitbox();
        ylwFW.screenCenter(XY);
        ylwFW.y -= 700;
        ylwFW.x += 75;
        ylwFW.antialiasing=true;
        ylwFW.scrollFactor.set(.4,.4);
        ylwFW.animation.addByPrefix("explode","yellow",24,false);
        ylwFW.animation.finishCallback=function(n:String):Void{
          ylwFW.visible=false;
        }

        add(ylwFW);

        bluFW = new FlxSprite();
        bluFW.visible=false;
        bluFW.frames = Paths.getSparrowAtlas('rooftop/fireworks/blueFirework');
        bluFW.screenCenter(XY);
        bluFW.y -= 200;
        bluFW.x -= 50;
        bluFW.antialiasing=true;
        bluFW.scrollFactor.set(.8,.8);
        bluFW.setGraphicSize(Std.int(bluFW.width*1.1) ) ;
        bluFW.animation.addByPrefix("explode","blue",24,false);
        bluFW.animation.finishCallback=function(n:String):Void{
          bluFW.visible=false;
        }
        bluFW.updateHitbox();
        add(bluFW);


        grnFW = new FlxSprite();
        grnFW.visible=false;
        grnFW.frames = Paths.getSparrowAtlas('rooftop/fireworks/greenFirework');
        grnFW.screenCenter(XY);
        grnFW.y -= 275;
        grnFW.x += 300;
        grnFW.antialiasing=true;
        grnFW.scrollFactor.set(.8,.8);
        grnFW.setGraphicSize(Std.int(grnFW.width*1.1) ) ;
        grnFW.animation.addByPrefix("explode","green",24,false);
        grnFW.animation.finishCallback=function(n:String):Void{
          grnFW.visible=false;
        }
        grnFW.updateHitbox();
        add(grnFW);

        pnkFW = new FlxSprite();
        pnkFW.visible=false;
        pnkFW.frames = Paths.getSparrowAtlas('rooftop/fireworks/pinkFirework');
        pnkFW.screenCenter(XY);
        pnkFW.y -= 225;
        pnkFW.x += 600;
        pnkFW.antialiasing=true;
        pnkFW.scrollFactor.set(.85, .85);
        pnkFW.setGraphicSize(Std.int(pnkFW.width*1.3) ) ;
        pnkFW.animation.addByPrefix("explode","pink",24,false);
        pnkFW.animation.finishCallback=function(n:String):Void{
          pnkFW.visible=false;
        }
        pnkFW.updateHitbox();
        add(pnkFW);

        sideWallBack = new FlxSprite().loadGraphic(Paths.image('rooftop/not-building-front'));
        sideWallBack.antialiasing = true;
        sideWallBack.scrollFactor.set(1, 1);
        sideWallBack.x = -482.8;
        sideWallBack.y = 5.6;
				sideWallBack.setGraphicSize(Std.int(sideWallBack.width * 1.25));
				sideWallBack.updateHitbox();
        add(sideWallBack);

        if(curStage=='rooftop-su'){
          var bopper:FlxSprite = new FlxSprite(-112, -51);
          bopper.frames = Paths.getSparrowAtlas('rooftop-su/boobs_2');
					bopper.animation.addByPrefix('bop', 'crowd instance 1', 24, false);
          bopper.antialiasing = true;
					bopper.setGraphicSize(Std.int(bopper.width * 1.25));
					bopper.updateHitbox();
          add(bopper);
          boppers.push([bopper,"bop",1]);

          sideWall = new FlxSprite().loadGraphic(Paths.image('rooftop/building-front'));
          sideWall.antialiasing = true;
          sideWall.scrollFactor.set(1, 1);
          sideWall.x = -459;
          sideWall.y = 6.85;
					sideWall.setGraphicSize(Std.int(sideWall.width * 1.25));
					sideWall.updateHitbox();
          add(sideWall);

          var ground:FlxSprite = new FlxSprite().loadGraphic(Paths.image('rooftop/stage'));
          ground.antialiasing = true;
          ground.scrollFactor.set(1, 1);
					ground.x = -620;
					ground.y = -172;
					ground.setGraphicSize(Std.int(ground.width * 1.25 * 1.1));
					ground.updateHitbox();
          add(ground);

          var wildemybeloved:FlxSprite = new FlxSprite(533, -11);
          wildemybeloved.frames = Paths.getSparrowAtlas('rooftop-su/boobs_1');
					wildemybeloved.animation.addByPrefix('bop', 'cum instance 1', 24, false);
					wildemybeloved.setGraphicSize(Std.int(wildemybeloved.width * 1.25));
					wildemybeloved.updateHitbox();
          wildemybeloved.antialiasing = true;
          add(wildemybeloved);
          boppers.push([wildemybeloved,"bop",1]);

        }else{
					var bopper:FlxSprite = new FlxSprite(-177, -75);
					bopper.frames = Paths.getSparrowAtlas('rooftop/crowd');
					bopper.animation.addByPrefix('bop', 'crowd instance 1', 24, false);
					bopper.antialiasing = true;
					add(bopper);
					boppers.push([bopper, "bop", 1]);

					sideWall = new FlxSprite().loadGraphic(Paths.image('rooftop/building-front'));
					sideWall.antialiasing = true;
					sideWall.scrollFactor.set(1, 1);
					sideWall.x = -459;
					sideWall.y = 6.85;
					sideWall.setGraphicSize(Std.int(sideWall.width * 1.25));
					sideWall.updateHitbox();
					add(sideWall);

					demonclownwiththegamernotes = new FlxSprite(1386, 65);
					demonclownwiththegamernotes.frames = Paths.getSparrowAtlas('rooftop/tiky');
					demonclownwiththegamernotes.animation.addByPrefix('bop', 'tricky instance 1', 24, false);
					demonclownwiththegamernotes.antialiasing = true;
					add(demonclownwiththegamernotes);
					boppers.push([demonclownwiththegamernotes, "bop", 1]);


					noTiky = new FlxSprite().loadGraphic(Paths.image('rooftop/stage'));
					noTiky.antialiasing = true;
          noTiky.visible = false;
					noTiky.scrollFactor.set(1, 1);
					noTiky.x = -620;
					noTiky.y = -172;
					noTiky.setGraphicSize(Std.int(noTiky.width * 1.25 * 1.1));
					noTiky.updateHitbox();
					add(noTiky);

					tikyOne = new FlxSprite().loadGraphic(Paths.image('rooftop/tikystage'));
					tikyOne.antialiasing = true;
					tikyOne.scrollFactor.set(1, 1);
					tikyOne.x = -620;
					tikyOne.y = -172;
					tikyOne.setGraphicSize(Std.int(tikyOne.width * 1.25 * 1.1));
					tikyOne.updateHitbox();
					add(tikyOne);

					var daCrowd:FlxSprite = new FlxSprite(505, -62);
					daCrowd.frames = Paths.getSparrowAtlas('rooftop/backgroundOnes');
					daCrowd.animation.addByPrefix('bop', 'crowd instance 1', 24, false);
					daCrowd.antialiasing = true;
					add(daCrowd);
					boppers.push([daCrowd, "bop", 1]);


          gfBop = new FlxSprite(65.35, 350);
          gfBop.scale.set(1.65, 1.65);
          gfBop.frames = Paths.getSparrowAtlas('rooftop/bouncing ladies');
          gfBop.animation.addByPrefix('bop', 'bouncing ladies', 24, false);
          gfBop.antialiasing = true;
          gfBop.scrollFactor.set(1.15, 1.15);
          foreground.add(gfBop);
          boppers.push([gfBop,"bop",1]);

        }

        var roofOverlay:FlxSprite = new FlxSprite(0,0).loadGraphic(Paths.image('rooftop/2overlay'));
        roofOverlay.setGraphicSize(1280, 720);
        roofOverlay.antialiasing = true;
        roofOverlay.alpha = 0.7;
        roofOverlay.screenCenter(XY);
        roofOverlay.active = false;
        overlay.add(roofOverlay);
      case 'fiesta':
        camOffset.x = 175;
        camOffset.y += 50;
        gfPosition.y -= 100;
        dadPosition.x -= 50;
        defaultCamZoom=.75;
        var bg:FlxSprite = new FlxSprite(-900, -1252).loadGraphic(Paths.image('fiesta/sky'));
        bg.antialiasing = true;
        bg.scrollFactor.set(0.5, 0.5);
        add(bg);

        var mountains:FlxSprite = new FlxSprite(-701, -373).loadGraphic(Paths.image('fiesta/mountains'));
        mountains.antialiasing = true;
        mountains.scrollFactor.set(0.7, 0.7);
        add(mountains);

        var background:FlxSprite = new FlxSprite(-2061  , -348).loadGraphic(Paths.image('fiesta/background'));
        background.antialiasing = true;
        background.scrollFactor.set(1, 1);
        add(background);

        if(OptionUtils.options.potato>0){
          var frogy:FlxSprite = new FlxSprite(173, 70);
          frogy.frames = Paths.getSparrowAtlas('fiesta/froggy');
          frogy.animation.addByPrefix('bop', 'frogy', 24, false);
          frogy.antialiasing = true;
          frogy.scrollFactor.set(1, 1);
          add(frogy);
          boppers.push([frogy,"bop",1]);

          var cat:FlxSprite = new FlxSprite(29.75, -31.25);
          cat.frames = Paths.getSparrowAtlas('fiesta/oingo');
          cat.animation.addByPrefix('bop', 'oingo boingo cat', 24, false);
          cat.antialiasing = true;
          cat.scrollFactor.set(1, 1);
          add(cat);
          boppers.push([cat,"bop",1]);

          var gladys:FlxSprite = new FlxSprite(739, 42);
          gladys.frames = Paths.getSparrowAtlas('fiesta/gladys');
          gladys.animation.addByPrefix('bop', 'gladys', 24, false);
          gladys.antialiasing = true;
          gladys.scrollFactor.set(1, 1);
          add(gladys);
          boppers.push([gladys,"bop",1]);

          var lily:FlxSprite = new FlxSprite(1002, 58);
          lily.frames = Paths.getSparrowAtlas('fiesta/lily');
          lily.animation.addByPrefix('bop', 'lyl', 24, false);
          lily.antialiasing = true;
          lily.scrollFactor.set(1, 1);
          add(lily);
          boppers.push([lily,"bop",1]);

          gladys.y += 180;
          lily.y += 180;
          cat.y += 160;
          frogy.y += 180;

          frogy.x -= 50;
          gladys.x += 50;
          cat.x -= 75;
          lily.x += 50;
        }

        //gf.visible=false;
        dadPosition.x = 40;
        dadPosition.y = 106;

        bfPosition.x = 819;
        bfPosition.y = 441;

			case 'malvadoSide':
				defaultCamZoom = 0.8;
				bfPosition.y += 80;

				dadPosition.y += 100;
				camOffset.x = 200;
				camOffset.y = 150;

				var sky:FlxSprite = new FlxSprite(-550, -410).loadGraphic(Paths.image('merchant/sky'));
				sky.antialiasing = true;
				sky.active = false;
				sky.scrollFactor.set(.5, .5);
				add(sky);

				orangeBG = new FlxSprite(-400, -200).loadGraphic(Paths.image('merchant/backgroundorange'));
				orangeBG.antialiasing = true;
				add(orangeBG);

				memoryShader = new MemoryEffect();
				orangeBG.shader = memoryShader.shader;
      case 'devoured':
				defaultCamZoom = 0.8;
				bfPosition.y += 80;

				dadPosition.y += 100;
				camOffset.x = 200;
				camOffset.y = 150;

				var sky:FlxSprite = new FlxSprite(-550, -410).loadGraphic(Paths.image('devoured/sky'));
				sky.antialiasing = true;
				sky.active = false;
				sky.scrollFactor.set(.5, .5);
				add(sky);

				orangeBG = new FlxSprite(-400, -200).loadGraphic(Paths.image('devoured/bg'));
				orangeBG.antialiasing = true;
				add(orangeBG);

				corruptOverlay = new FlxSprite(0, 0).loadGraphic(Paths.image('devoured/corruption border'));
				corruptOverlay.screenCenter(XY);
				corruptOverlay.setGraphicSize(1280, 720);
				corruptOverlay.antialiasing = true;
				corruptOverlay.scrollFactor.set(0, 0);
				gameOverlay.add(corruptOverlay);

				corruptWiggle = new FlxSprite(0, 0);
				corruptWiggle.frames = Paths.getSparrowAtlas("devoured/devouredwiggly");
				corruptWiggle.animation.addByPrefix("wiggle", "wiggle lines", 24, true);
				corruptWiggle.antialiasing = true;
				corruptWiggle.scrollFactor.set(0, 0);
        corruptWiggle.animation.play("wiggle", true);
        corruptWiggle.updateHitbox();
				corruptWiggle.screenCenter(XY);
        corruptWiggle.x += 25;
				gameOverlay.add(corruptWiggle);

      case 'shopCloseup':
        centerX = 100;
        centerY = 100;
				dadPosition.y += 100;
				defaultCamZoom = 1.2;
				dadPosition.x -= 100;
        bfPosition.x += 100;
				bfPosition.y += 80;
				camOffset.x = 200;
				camOffset.y = 150;
        //-800, -200, 370, -470
        // 0, 200, 670, -70
        dadPosition.y -= 500;
        dadPosition.x -= 675;
        bfPosition.x -= 425;
        bfPosition.y -= 500;

				var bg:FlxSprite = new FlxSprite(-400, -200).loadGraphic(Paths.image('merchant/sugv_bg'));
				bg.antialiasing = true;
        bg.setGraphicSize(Std.int(bg.width * 2));
				bg.active = false;
				bg.scrollFactor.set(1, 1);
        add(bg);

        var lightning:FlxSprite = new FlxSprite(-400, -200);
        lightning.frames = Paths.getSparrowAtlas("merchant/lightning_sugv");
        lightning.antialiasing = true;
				lightning.animation.addByPrefix('idle', "lightning0", 24);
        lightning.animation.play("idle",true);
				lightning.setGraphicSize(Std.int(lightning.width * 2));
				lightning.updateHitbox();
				add(lightning);
      case 'shop':
        if(PlayState.storyDifficulty==3)
          gfVersion = 'orangesuspeakers';
        else
          gfVersion = 'orangegf';

        dadPosition.y += 100;
        defaultCamZoom = 0.8;
        bfPosition.y += 80;
        camOffset.x = 200;
        camOffset.y = 150;


        if(OptionUtils.options.potato>0){

          var sky:FlxSprite = new FlxSprite(-550, -410).loadGraphic(Paths.image('merchant/sky'));
          sky.antialiasing = true;
          sky.active = false;
          sky.scrollFactor.set(.5, .5);
          add(sky);

          orangeBG = new FlxSprite(-400, -200).loadGraphic(Paths.image('merchant/backgroundorange'));
          orangeBG.antialiasing = true;
          add(orangeBG);

          purpleBG = new FlxSprite(-400, -200).loadGraphic(Paths.image('merchant/backgroundpurple'));
          purpleBG.antialiasing = true;
          purpleBG.visible = false;
          add(purpleBG);

          orangeFire1 = new FlxSprite(0, 0);
          orangeFire1.frames = Paths.getSparrowAtlas('merchant/orangeflame');
          orangeFire1.animation.addByPrefix('idle', "fire0", 24);
          orangeFire1.antialiasing = true;
          orangeFire1.x = -55;
          orangeFire1.y = -32;
          add(orangeFire1);
          orangeFire1.animation.play('idle');

          orangeFire2 = new FlxSprite(0, 0);
          orangeFire2.frames = Paths.getSparrowAtlas('merchant/orangeflame');
          orangeFire2.animation.addByPrefix('idle', "fire0", 24);
          orangeFire2.antialiasing = true;
          orangeFire2.x = 1385;
          orangeFire2.y = -32;
          add(orangeFire2);
          orangeFire2.animation.play('idle');

          purpleFire1 = new FlxSprite(0, 0);
          purpleFire1.frames = Paths.getSparrowAtlas('merchant/purpleflame');
          purpleFire1.visible=false;
          purpleFire1.animation.addByPrefix('idle', "fire0", 24);
          purpleFire1.antialiasing = true;
          purpleFire1.x = orangeFire1.x;
          purpleFire1.y = orangeFire1.y;
          add(purpleFire1);
          purpleFire1.animation.play('idle');

          purpleFire2 = new FlxSprite(0, 0);
          purpleFire2.frames = Paths.getSparrowAtlas('merchant/purpleflame');
          purpleFire2.visible=false;
          purpleFire2.animation.addByPrefix('idle', "fire0", 24);
          purpleFire2.antialiasing = true;
          purpleFire2.x = orangeFire2.x;
          purpleFire2.y = orangeFire2.y;
          add(purpleFire2);
          purpleFire2.animation.play('idle');
        }else{
          orangeBG = new FlxSprite(0, 0).loadGraphic(Paths.image('merchant/background'));
          orangeBG.setGraphicSize(Std.int(orangeBG.width*(4/3)));
          add(orangeBG);
        }

      case 'date':
        defaultCamZoom = .9;
        var sky:FlxSprite = new FlxSprite(-283, -360).loadGraphic(Paths.image('date/sky'));
        sky.setGraphicSize(Std.int(sky.width*1.2));
        sky.antialiasing = true;
        sky.scrollFactor.set(1, 1);
        add(sky);

        var stars:FlxSprite = new FlxSprite(-283, -370).loadGraphic(Paths.image('date/stars'));
        stars.setGraphicSize(Std.int(stars.width*1.2));
        stars.antialiasing = true;
        stars.scrollFactor.set(1, 1);
        add(stars);

        var moon:FlxSprite = new FlxSprite(1242, -338).loadGraphic(Paths.image('date/moon'));
        moon.setGraphicSize(Std.int(moon.width*1.2));
        moon.antialiasing = true;
        moon.scrollFactor.set(1, 1);
        add(moon);

        skyLine1 = new FlxSprite(-283, -370).loadGraphic(Paths.image('date/skyline'));
        skyLine1.setGraphicSize(Std.int(skyLine1.width*1.2));
        skyLine1.antialiasing = true;
        skyLine1.scrollFactor.set(1, 1);
        add(skyLine1);

        skyLine2 = new FlxSprite(-283 + (1920*1.2), -370).loadGraphic(Paths.image('date/skyline'));
        skyLine2.setGraphicSize(Std.int(skyLine2.width*1.2));
        skyLine2.antialiasing = true;
        skyLine2.scrollFactor.set(1, 1);
        add(skyLine2);

        ground1 = new FlxSprite(-283, -360).loadGraphic(Paths.image('date/ground'));
        ground1.setGraphicSize(Std.int(ground1.width*1.2));
        ground1.antialiasing = true;
        ground1.scrollFactor.set(1, 1);
        add(ground1);

        ground2 = new FlxSprite(-283 + (1920*1.2), -360).loadGraphic(Paths.image('date/ground'));
        ground2.setGraphicSize(Std.int(ground2.width*1.2));
        ground2.antialiasing = true;
        ground2.scrollFactor.set(1, 1);
        add(ground2);

        lamp1 = new FlxSprite(317, -115).loadGraphic(Paths.image('date/lamp'));
        lamp1.setGraphicSize(Std.int(lamp1.width*1.2));
        lamp1.antialiasing = true;
        lamp1.scrollFactor.set(1, 1);
        add(lamp1);

        lamp2 = new FlxSprite(317 + (1920*1.2), -115).loadGraphic(Paths.image('date/lamp'));
        lamp2.setGraphicSize(Std.int(lamp2.width*1.2));
        lamp2.antialiasing = true;
        lamp2.scrollFactor.set(1, 1);
        add(lamp2);


        var lay:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('date/overlay'));
        lay.screenCenter(XY);
        lay.setGraphicSize(1280,720);
        lay.antialiasing = true;
        lay.scrollFactor.set(0,0);
        overlay.add(lay);

        bfPosition.x -= 775;
        dadPosition.x += 250;
        bfPosition.y -= 350;
        dadPosition.y -= 100;
			case 'school':
				gfVersion = 'gf-pixel';
				camOffset.x = 200;
				camOffset.y = 200;

				bfPosition.x += 200;
				bfPosition.y += 220;
				gfPosition.x += 180;
				gfPosition.y += 300;

				var bgSky = new FlxSprite().loadGraphic(Paths.image('weeb/weebSky', 'week6'));
				bgSky.scrollFactor.set(0.1, 0.1);
				add(bgSky);

				var repositionShit = -200;

				var bgSchool:FlxSprite = new FlxSprite(repositionShit, 0).loadGraphic(Paths.image('weeb/weebSchool', 'week6'));
				bgSchool.scrollFactor.set(0.6, 0.90);
				add(bgSchool);

				var bgStreet:FlxSprite = new FlxSprite(repositionShit).loadGraphic(Paths.image('weeb/weebStreet', 'week6'));
				bgStreet.scrollFactor.set(0.95, 0.95);
				add(bgStreet);

				var fgTrees:FlxSprite = new FlxSprite(repositionShit + 170, 130).loadGraphic(Paths.image('weeb/weebTreesBack', 'week6'));
				fgTrees.scrollFactor.set(0.9, 0.9);
				add(fgTrees);

				var bgTrees:FlxSprite = new FlxSprite(repositionShit - 380, -800);
				var treetex = Paths.getPackerAtlas('weeb/weebTrees', 'week6');
				bgTrees.frames = treetex;
				bgTrees.animation.add('treeLoop', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], 12);
				bgTrees.animation.play('treeLoop');
				bgTrees.scrollFactor.set(0.85, 0.85);
				add(bgTrees);

				var treeLeaves:FlxSprite = new FlxSprite(repositionShit, -40);
				treeLeaves.frames = Paths.getSparrowAtlas('weeb/petals', 'week6');
				treeLeaves.animation.addByPrefix('leaves', 'PETALS ALL', 24, true);
				treeLeaves.animation.play('leaves');
				treeLeaves.scrollFactor.set(0.85, 0.85);
				add(treeLeaves);

				var widShit = Std.int(bgSky.width * 6);

				bgSky.setGraphicSize(widShit);
				bgSchool.setGraphicSize(widShit);
				bgStreet.setGraphicSize(widShit);
				bgTrees.setGraphicSize(Std.int(widShit * 1.4));
				fgTrees.setGraphicSize(Std.int(widShit * 0.8));
				treeLeaves.setGraphicSize(widShit);

				fgTrees.updateHitbox();
				bgSky.updateHitbox();
				bgSchool.updateHitbox();
				bgStreet.updateHitbox();
				bgTrees.updateHitbox();
				treeLeaves.updateHitbox();

				centerX = bgSchool.getMidpoint().x;
				centerY = bgSchool.getMidpoint().y;

				// centerX = 580;
				// centerY = 380;

				var bgGirls = new BackgroundGirls(-100, 190);
				bgGirls.scrollFactor.set(0.9, 0.9);

				if (PlayState.SONG.song.toLowerCase() == 'violets')
				{
					bgGirls.getScared();
				}

				bgGirls.setGraphicSize(Std.int(bgGirls.width * PlayState.daPixelZoom));
				bgGirls.updateHitbox();
				add(bgGirls);
				dancers.push(bgGirls);


      case 'blank':
        centerX = 0;
        centerY = 0;
      default:
        defaultCamZoom = 1;
        curStage = 'stage';
        var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('stageback'));
        bg.antialiasing = true;
        bg.scrollFactor.set(0.9, 0.9);
        bg.active = false;
        add(bg);

        var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('stagefront'));
        stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
        stageFront.updateHitbox();
        stageFront.antialiasing = true;
        stageFront.scrollFactor.set(0.9, 0.9);
        stageFront.active = false;
        add(stageFront);

        var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image('stagecurtains'));
        stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
        stageCurtains.updateHitbox();
        stageCurtains.antialiasing = true;
        stageCurtains.scrollFactor.set(1.3, 1.3);
        stageCurtains.active = false;

        centerX = bg.getMidpoint().x;
        centerY = bg.getMidpoint().y;

        foreground.add(stageCurtains);
      }
  }

  var nextFirework:Int = 4;
	var fireworking:Bool = false;
	var fireworkTimer:Int = 0;

  function theFireWorks(){
    fireworking=true;
    var fireworks:Array<FlxSprite> = [
      ylwFW,
      bluFW,
      grnFW,
      pnkFW
    ];
    var fireworkCount:Int = FlxG.random.int(0,2);
    var sounds:Array<String>=[
      Paths.sound('firework_explosion_001'),
      Paths.sound('firework_explosion_002'),
      Paths.sound('firework_explosion_003')
    ];

    for (i in 0...fireworkCount){
      var fw = fireworks[FlxG.random.int(0,fireworks.length-1) ];
      var snd = sounds[FlxG.random.int(0,sounds.length-1) ];
      fireworks.remove(fw);
      sounds.remove(snd);
      new FlxTimer().start(FlxG.random.float(0.2,0.6),function( tmrw:FlxTimer ) {
        fw.visible=true;
        fw.flipX = FlxG.random.bool(50);
        fw.angle = FlxG.random.float(-25,25);
        fw.animation.getByName("explode").frameRate = FlxG.random.float(20,32);
        fw.animation.play("explode",true);
        fw.animation.getByName("explode").curFrame = FlxG.random.int(0,3);
        fw.offset.x = FlxG.random.float(-35,35);
        fw.offset.y = FlxG.random.float(-35,35);
        if(fw==ylwFW){
          FlxG.sound.play(snd,0.3); // far away!!
        }else{
          FlxG.sound.play(snd,0.5);
        }
        if(i==fireworkCount){
          fireworking=false;
        }

      });
    }

    new FlxTimer().start(3, function(tmr:FlxTimer){
      if(fireworking)
        fireworking=false;
    });
  }

  public function beatHit(beat){
    for(b in boppers){
      if(beat%b[2]==0){
        b[0].animation.play(b[1],true);
      }
    }
    for(d in dancers)
      d.dance();


    if(doDistractions){
      switch(curStage){
        case "rooftop" | "rooftop-su":
          if(!fireworking)
            fireworkTimer++;

          if(FlxG.random.bool(20) && !fireworking && fireworkTimer>=nextFirework){
            theFireWorks();
            nextFirework = FlxG.random.int(8,16);
          }
      }
    }
  }


  override function update(elapsed:Float){
    if(doDistractions){
      switch(curStage){
        case "date":
          ground1.x -= .5 * elapsed/(1/120);
          ground2.x -= .5 * elapsed/(1/120);

          lamp1.x -= .5 * elapsed/(1/120);
          lamp2.x -= .5 * elapsed/(1/120);

          skyLine1.x -= .1 * elapsed/(1/120);
          skyLine2.x -= .1 * elapsed/(1/120);

          if(ground1.x<-283 - (1920*1.2))
            ground1.x = ground2.x + (1920*1.2);

          if(ground2.x<-283 - (1920*1.2))
            ground2.x = ground1.x + (1920*1.2);

          if(skyLine1.x<-283 - (1920*1.2))
            skyLine1.x = skyLine2.x + (1920*1.2);

          if(skyLine2.x<-283 - (1920*1.2))
            skyLine2.x = skyLine1.x + (1920*1.2);

          if(lamp1.x<317 - (1920*1.2))
            lamp1.x = 317 + (1920*1.2);

          if(lamp2.x<317 - (1920*1.2))
            lamp2.x = 317 + (1920*1.2);

      }
    }
    super.update(elapsed);
  }

}
