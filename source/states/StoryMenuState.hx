package states;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.net.curl.CURLCode;
import flash.events.MouseEvent;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;
import flixel.FlxState;
import flixel.input.mouse.FlxMouseEventManager;
import EngineData.WeekData;
import EngineData.SongData;
import flixel.util.FlxGradient;
import ui.*;
using StringTools;

class StoryMenuState extends MusicBeatState
{
	var scoreText:FlxText;

	var hasSU:Bool = false;
	public static var curDifficulty:Int = 1;

	public static var weekUnlocked:Array<Bool> = [true, true, true, true, true, true, true];

	var txtWeekTitle:FlxText;

	public static var curWeek:Int = 0;
	public static var prevWeek:Int = 3;

	var txtTracklist:FlxText;

	var grpWeekText:FlxTypedGroup<StoryMenuItem>;
	var grpWeekCharacters:FlxTypedGroup<MenuCharacter>;
	var leftChar:MenuCharacter;
	var rightChar:MenuCharacter;

	var grpLocks:FlxTypedGroup<FlxSprite>;

	var difficultySelectors:FlxGroup;
	var sprDifficulty:FlxSprite;
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;
	var downArrow:FlxSprite;
	var upArrow:FlxSprite;
	var weekData:Array<WeekData>;
	var weekBG:FlxSprite;
	var hideWeekBG:FlxSprite;
	var erectEmitter:FlxEmitter;
	var gradientTween:FlxTween;
	var gradient:FlxSprite; // stepped up
	override function create()
	{
		super.create();
		FlxG.mouse.visible = true;
		weekData = EngineData.weekData;

		weekUnlocked = [true,false,false,false];
		if (FlxG.save.data.weeksBeaten == null)
			FlxG.save.data.weeksBeaten=[false,false,false,false];
		
		var beaten = FlxG.save.data.weeksBeaten;
		#if !html5 
		// if !html5 so that if you're on html5 you can only access the first week
		hasSU = beaten[0]==true;
		if(hasSU)
			weekUnlocked = [true, true, true, false];

		if (beaten[0] && beaten[1] && beaten[2])
			weekUnlocked[3]=true; // unlock 12-28 after you beat the other weeks
		#end

		if (FlxG.sound.music==null || !FlxG.sound.music.playing)
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
		

		persistentUpdate = persistentDraw = true;

		scoreText = new FlxText(10, 10, 0, "SCORE: 49324858", 36);
		scoreText.setFormat("VCR OSD Mono", 32);

		txtWeekTitle = new FlxText(FlxG.width * 0.7, 10, 0, "", 32);
		txtWeekTitle.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, RIGHT);
		txtWeekTitle.alpha = 0.7;

		var rankText:FlxText = new FlxText(0, 10);
		rankText.text = 'RANK: GREAT';
		rankText.setFormat(Paths.font("vcr.ttf"), 32);
		rankText.size = scoreText.size;
		rankText.screenCenter(X);

		var ui_tex = Paths.getSparrowAtlas('campaign_menu_UI_assets');
		var yellowBG:FlxSprite = new FlxSprite(0, 56).makeGraphic(FlxG.width, 400, 0xFFF9CF51);

		grpWeekText = new FlxTypedGroup<StoryMenuItem>();
		erectEmitter = new FlxEmitter();
		erectEmitter.clear();
		for(i in 0...150){
			var p:FlxParticle = new FlxParticle();
			p.loadGraphic(Paths.image("pafartickle"));
			p.exists=false;
			erectEmitter.add(p);
		}
		erectEmitter.keepScaleRatio = true;
		erectEmitter.launchMode = SQUARE;
		erectEmitter.acceleration.set(
			-5,
			-25,
			5,
			-30,
			-10,
			-50,
			10,
			-60
		);
		erectEmitter.velocity.set(
			-50,
			-100,
			50,
			-200,
			-100,
			-200,
			100,
			-400
		);
		erectEmitter.scale.set(
			0.7,
			0.7,
			1.7,
			1.7,
			0,
			0,
			0,
			0
		);
		erectEmitter.lifespan.min = 0.25;
		erectEmitter.lifespan.max = 2.25;

		erectEmitter.start(false, 0.035);
		erectEmitter.emitting=false;
		var blackBarThingie:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, 56, FlxColor.BLACK);
		add(blackBarThingie);


		grpWeekCharacters = new FlxTypedGroup<MenuCharacter>();

		grpLocks = new FlxTypedGroup<FlxSprite>();

		trace("Line 70");

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		for (i in 0...weekData.length)
		{
			var weekThing:StoryMenuItem = new StoryMenuItem(0, yellowBG.y + yellowBG.height + 10, weekData[i].loadingPath);
			weekThing.y = 480 + (120 * i);
			//weekThing.targetY = i;
			weekThing.antialiasing = true;
			
			weekThing.screenCenter(X);
			weekThing.scale.set(0.85, 0.85);
			weekThing.lock.scale.set(0.85 * 1.2, 0.85 * 1.2);
			weekThing.offset.y += 25;
			weekThing.alpha = (i==0?1:0);
			grpWeekText.add(weekThing);
			// weekThing.updateHitbox();

			// Needs an offset thingie
			weekThing.locked = !weekUnlocked[i];
		}

		trace("Line 96");

		leftChar = new MenuCharacter(-400, 50, 'flexy');
		leftChar.antialiasing = true;

		rightChar = new MenuCharacter(FlxG.width, 50, 'bf');
		rightChar.antialiasing = true;

		difficultySelectors = new FlxGroup();

		leftArrow = new FlxSprite(grpWeekText.members[0].x + grpWeekText.members[0].width + 10, grpWeekText.members[0].y + 10);
		leftArrow.frames = ui_tex;
		leftArrow.animation.addByPrefix('idle', "arrow left");
		leftArrow.animation.addByPrefix('press', "arrow push left");
		leftArrow.animation.play('idle');
		leftArrow.updateHitbox();
		difficultySelectors.add(leftArrow);

		sprDifficulty = new FlxSprite(leftArrow.x + 100, leftArrow.y);
		sprDifficulty.frames = ui_tex;
		sprDifficulty.animation.addByPrefix('easy', 'EASY');
		sprDifficulty.animation.addByPrefix('normal', 'NORMAL');
		sprDifficulty.animation.addByPrefix('hard', 'HARD');
		sprDifficulty.animation.addByPrefix('stepped up', 'STEPPED UP');
		sprDifficulty.animation.play('easy');
		sprDifficulty.setGraphicSize(Std.int(sprDifficulty.width*.8));
		sprDifficulty.antialiasing=true;

		difficultySelectors.add(sprDifficulty);

		rightArrow = new FlxSprite(sprDifficulty.x + sprDifficulty.width + 30, leftArrow.y);
		rightArrow.frames = ui_tex;
		rightArrow.animation.addByPrefix('idle', 'arrow right');
		rightArrow.animation.addByPrefix('press', "arrow push right", 24, false);
		rightArrow.animation.play('idle');
		rightArrow.updateHitbox();
		difficultySelectors.add(rightArrow);

		weekBG = new FlxSprite(267, 60);
		weekBG.frames = Paths.getSparrowAtlas("storybgshit");
		weekBG.animation.addByPrefix("fiesta","mainstory",24,true);
		weekBG.animation.addByPrefix("flexmas","xmas",24,true);
		weekBG.animation.addByPrefix("corruption","corrupted",24,true);
		weekBG.animation.addByPrefix("1228","anniversary1",24,true);
		weekBG.animation.play('fiesta',true);
		weekBG.antialiasing=true;
		weekBG.updateHitbox();

		hideWeekBG = new FlxSprite(267, 60).makeGraphic(720, 480, FlxColor.BLACK);
		
		trace("Line 150");
		var daFrames = new FlxSprite().loadGraphic(Paths.image("the_frame"));
		add(yellowBG);
		add(weekBG);
		add(hideWeekBG);
		add(daFrames);

		var blackBarThingie:FlxSprite = new FlxSprite(0, 440).makeGraphic(FlxG.width, 280, FlxColor.BLACK);
		add(blackBarThingie);
		erectEmitter.y = 440 + 280;
		erectEmitter.width = FlxG.width;

		gradient = FlxGradient.createGradientFlxSprite(FlxG.width, 280, [0xFF9300FF, FlxColor.TRANSPARENT], 1, -90);
		gradient.scrollFactor.set();
		gradient.y = 440;
		gradient.alpha = 0;

		add(leftChar);
		add(rightChar);

		add(erectEmitter);
		add(gradient);

		add(difficultySelectors);
		add(grpLocks);
		add(grpWeekText);
		rightChar.tween = FlxTween.tween(rightChar, {x: FlxG.width - rightChar.width}, 0.15, {
			ease: FlxEase.quadOut
		});

		leftChar.tween = FlxTween.tween(leftChar, {x: 0}, 0.15, {
			ease: FlxEase.quadOut
		});

		txtTracklist = new FlxText(FlxG.width * 0.05, yellowBG.x + yellowBG.height + 100, 0, "Tracks", 32);
		txtTracklist.alignment = CENTER;
		txtTracklist.font = rankText.font;
		txtTracklist.color = 0xFFe55777;
		add(txtTracklist);
		// add(rankText);
		add(scoreText);
		add(txtWeekTitle);

		updateText();
		changeWeek();
		changeDifficulty();

		trace("Line 165");

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

		FlxG.stage.addEventListener(MouseEvent.MOUSE_WHEEL,scroll);


	}

	override function update(elapsed:Float)
	{
		// scoreText.setFormat('VCR OSD Mono', 32);
		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, Main.adjustFPS(0.5)));

		scoreText.text = "WEEK SCORE:" + lerpScore;

		txtWeekTitle.text = !weekUnlocked[curWeek]?"???":weekData[curWeek].name.toUpperCase();
		txtWeekTitle.x = FlxG.width - (txtWeekTitle.width + 10);

		// FlxG.watch.addQuick('font', scoreText.font);

		difficultySelectors.visible = (weekUnlocked[curWeek]);

		grpLocks.forEach(function(lock:FlxSprite)
		{
			lock.y = grpWeekText.members[lock.ID].y;
		});
		if(gradientTween!=null && gradientTween.finished)gradientTween.cancel();
		if (!movedBack)
		{
			if (!selectedWeek)
			{
				if (controls.UP_P)
				{
					changeWeek(-1);
				}

				if (controls.DOWN_P)
				{
					changeWeek(1);
				}

				if (controls.RIGHT || FlxG.mouse.overlaps(rightArrow) && FlxG.mouse.pressed )
					rightArrow.animation.play('press')
				else
					rightArrow.animation.play('idle');

				if (controls.LEFT || FlxG.mouse.overlaps(leftArrow) && FlxG.mouse.pressed)
					leftArrow.animation.play('press');
				else
					leftArrow.animation.play('idle');

				if (controls.RIGHT_P || FlxG.mouse.overlaps(rightArrow) && FlxG.mouse.justPressed )
					changeDifficulty(1);
				if (controls.LEFT_P || FlxG.mouse.overlaps(leftArrow) && FlxG.mouse.justPressed)
					changeDifficulty(-1);
			}

			if (controls.ACCEPT)
			{
				selectWeek();
			}
		}

		if (controls.BACK && !movedBack && !selectedWeek)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			movedBack = true;
			FlxG.switchState(new MainMenuState());
		}

		super.update(elapsed);
	}

	var movedBack:Bool = false;
	var selectedWeek:Bool = false;
	var stopspamming:Bool = false;

	function selectWeek()
	{
		if (weekUnlocked[curWeek])
		{
			if (stopspamming == false)
			{
				FlxG.sound.play(Paths.sound('confirmMenu'));

				grpWeekText.members[curWeek].startFlashing();
				//grpWeekCharacters.members[1].setCharacter('bfConfirm');
				stopspamming = true;
			}

			selectedWeek = true;
			PlayState.seenCutscene = false;
			var dat = weekData[curWeek];
			if(curDifficulty < 2 && curWeek == 0){
				dat = new WeekData("Fiesta de Fuego", 7, 'flexy', [
					"Noche",
					"Desierto",
					new SongData("Globetrotter", "dmp", 7, "globetrotter", 'fiesta')
				], 'bf', 'gf', 'fiesta');
			}
			PlayState.setStoryWeek(dat,curDifficulty);
			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				LoadingState.loadAndSwitchState(new PlayState(), true);
			});
		}
	}

	function changeDifficulty(change:Int = 0):Void
	{
		var prev = curDifficulty;
		curDifficulty += change;
		var max = 3;
		var min = 0;
		if (curWeek != 0 || !hasSU)max=2;
		if(curWeek!=0)min=max;

		if (curDifficulty < min)
			curDifficulty = max;
		if (curDifficulty > max)
			curDifficulty = min;


		sprDifficulty.offset.x = 0;

		switch (curDifficulty)
		{
			case 0:
				sprDifficulty.animation.play('easy');
				sprDifficulty.centerOffsets();
				sprDifficulty.offset.x += 5;
				sprDifficulty.offset.y += 15;
				//sprDifficulty.offset.x = 20*.8;
			case 1:
				sprDifficulty.animation.play('normal');
				sprDifficulty.centerOffsets();
				sprDifficulty.offset.x -= 5;
				sprDifficulty.offset.y += 15;
				//sprDifficulty.offset.x = 80*.8;
				//sprDifficulty.offset.y = 20*.8;
			case 2:
				sprDifficulty.animation.play('hard');
				sprDifficulty.centerOffsets();
				sprDifficulty.offset.x += 5;
				sprDifficulty.offset.y += 15;
				//sprDifficulty.offset.x = 20*.8;
			case 3:
				sprDifficulty.animation.play('stepped up');
				sprDifficulty.centerOffsets();
				sprDifficulty.offset.y += 15;
				//sprDifficulty.offset.x = 50*.8;
		}
		leftArrow.visible = min != max;
		rightArrow.visible = min != max;
		sprDifficulty.visible = min != max;
		

		if(gradient!=null){
			if(curDifficulty==3){
				if(gradientTween!=null)gradientTween.cancel();
				gradientTween = FlxTween.tween(gradient, {alpha: 1}, 0.75, {
					ease: FlxEase.quadInOut
				});
			}else if(prev==3){
				if(gradientTween!=null)gradientTween.cancel();
				gradientTween = FlxTween.tween(gradient, {alpha: 0}, 0.75, {
					ease: FlxEase.quadInOut
				});
			}
		}

		erectEmitter.emitting = curDifficulty==3;
		sprDifficulty.alpha = 0;

		// USING THESE WEIRD VALUES SO THAT IT DOESNT FLOAT UP
		sprDifficulty.y = leftArrow.y - 15;
		intendedScore = Highscore.getWeekScore(curWeek, curDifficulty);

		#if !switch
		intendedScore = Highscore.getWeekScore(curWeek, curDifficulty);
		#end

		FlxTween.tween(sprDifficulty, {y: leftArrow.y + 15, alpha: 1}, 0.07);
		updateChars();
		updateText();
	}

	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	function scroll(event:MouseEvent){
		if(subState!=null && !persistentUpdate)return;
		changeWeek(-event.delta);
	}

	function changeWeek(change:Int = 0):Void
	{
		prevWeek = curWeek;
		curWeek += change;

		if (curWeek >= weekData.length)
			curWeek = 0;
		if (curWeek < 0)
			curWeek = weekData.length - 1;

		var bullShit:Int = 0;

		for (item in grpWeekText.members)
		{
			var diff = bullShit-curWeek;
			if(item.daTween!=null)
				item.daTween.cancel();

			if(diff==0){
				item.y = 480 + (120*change);
				item.daTween = FlxTween.tween(item, {y: 480, alpha: 1}, 0.07);
			}else{
				item.daTween = FlxTween.tween(item, {y: 480 - (120*change), alpha: 0}, 0.07);
			}

			bullShit++;
		}
		var lol = weekData[curWeek].loadingPath;
		weekBG.animation.play(lol,true);
		weekBG.centerOffsets();
		weekBG.visible = weekUnlocked[curWeek];
		hideWeekBG.visible = !weekUnlocked[curWeek];
		switch(lol){
			case 'corruption':
				weekBG.offset.y += 50;
		}

		FlxG.sound.play(Paths.sound('scrollMenu'));

		updateText();
		if(curDifficulty==3 && curWeek!=0)changeDifficulty(-1);
		changeDifficulty();
		updateChars();

	}

	function updateChars(){
		if(leftChar.tween!=null){
			leftChar.tween.cancel();
			leftChar.tween.active=false;
		}
		if(rightChar.tween!=null){
			rightChar.tween.cancel();
			rightChar.tween.active=false;
		}

		if (leftChar.character != weekData[curWeek].character || !weekUnlocked[curWeek]){
			leftChar.tween = FlxTween.tween(leftChar, {x: -400}, 0.2, {
				ease: FlxEase.quadIn,
				onComplete: function(twn:FlxTween)
				{
					if (weekUnlocked[curWeek]){
						leftChar.setCharacter(weekData[curWeek].character);
						leftChar.tween = FlxTween.tween(leftChar, {x: 0}, 0.2, {
							ease: FlxEase.quadOut
						});
					}
				}
			});
		}else{
			leftChar.tween = FlxTween.tween(leftChar, {x: 0}, 0.2, {
				ease: FlxEase.quadOut
			});
		}
		var protag:String = weekData[curWeek].protag;
		if(protag == 'bf' && curDifficulty==3)protag='dickhead';

		if (rightChar.character != protag || !weekUnlocked[curWeek]){
			rightChar.tween = FlxTween.tween(rightChar, {x: FlxG.width}, 0.2, {
				ease: FlxEase.quadIn,
				onComplete: function(twn:FlxTween)
				{
					if (weekUnlocked[curWeek])
					{
						rightChar.setCharacter(protag);
						rightChar.tween = FlxTween.tween(rightChar, {x: FlxG.width - rightChar.width}, 0.2, {
							ease: FlxEase.quadOut
						});
					}
				}
			});
		}else{
			rightChar.tween = FlxTween.tween(rightChar, {x: FlxG.width - rightChar.width}, 0.2, {
				ease: FlxEase.quadOut
			});
		}
	}

	function updateText()
	{
		txtTracklist.text = "Tracks\n";

		var stringThing:Array<SongData> = weekData[curWeek].songs;
		if(weekUnlocked[curWeek]){
			for (i in stringThing)
			{
				if(i.displayName=='Gran Venta'){
					if(curDifficulty >= 2)
						txtTracklist.text += "\n???";
				}else
					txtTracklist.text += "\n" + i.displayName;
				


			}
		}else
			txtTracklist.text += "\n???";

		txtTracklist.text = txtTracklist.text.toUpperCase();

		txtTracklist.screenCenter(X);
		txtTracklist.x -= FlxG.width * 0.35;

		txtTracklist.text += "\n";

		#if !switch
		intendedScore = Highscore.getWeekScore(curWeek, curDifficulty);
		#end
	}

	override function switchTo(next:FlxState){
		// Do all cleanup of stuff here! This makes it so you dont need to copy+paste shit to every switchState
		FlxG.stage.removeEventListener(MouseEvent.MOUSE_WHEEL,scroll);

		return super.switchTo(next);
	}

}
