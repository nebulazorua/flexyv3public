package states;

import Controls.Control;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import ui.*;
import flixel.math.FlxMath;
import Shaders.BlurEffect;
import flixel.addons.display.FlxTiledSprite;
import flixel.FlxCamera;
using StringTools;
import openfl.filters.ShaderFilter;

class PauseSubState extends MusicBeatSubstate
{
	var startTimer:FlxTimer;
	var grpMenuShit:FlxTypedGroup<PauseButton>;
	var top1:FlxTiledSprite;
	var top2:FlxTiledSprite;
	var bot1:FlxTiledSprite;
	var bot2:FlxTiledSprite;

	var top1Tween:FlxTween;
	var top2Tween:FlxTween;
	var bot1Tween:FlxTween;
	var bot2Tween:FlxTween;
	var blurTween:FlxTween;
	var diffTween:FlxTween;
	var nameTween:FlxTween;
	var menuItems:Array<String> = [
		'Resume',
		'Restart Song',
		'Restart with cutscene',
		#if ALLOW_SET_STARTPOS
		"Set Start Position",
		#end
		'Exit to menu'
		];
	var curSelected:Int = 0;

	var pauseMusic:FlxSound;
	var countingDown:Bool=false;
	var bg:FlxSprite;
	var levelInfo:FlxText;
	var blur:BlurEffect;
	var blurF: ShaderFilter;
	var levelDifficulty:FlxText;
	public function new(x:Float, y:Float)
	{
		super();
		var daCam:FlxCamera = FlxG.cameras.list[FlxG.cameras.list.length - 1];
		#if desktop
		blur = new BlurEffect();
		blurF = new ShaderFilter(blur.shader);
		for(cam in FlxG.cameras.list){
			var fnfCam:FNFCamera = cast cam;
			if(cam!=daCam){
				fnfCam.addFilter(blurF);
			}
		}
		#end
		pauseMusic = new FlxSound().loadEmbedded(Paths.music('breakfast'), true, true);
		pauseMusic.volume = 0;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));

		FlxG.sound.list.add(pauseMusic);

		bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		grpMenuShit = new FlxTypedGroup<PauseButton>();
		add(grpMenuShit);

		if(PlayState.startPos>0)
			menuItems.insert(2,"Restart from beginning");


		if(PlayState.inCharter)
			menuItems.insert(menuItems.length,"Exit to charter");

		top1 = new FlxTiledSprite(Paths.image('pause/overlay'), FlxG.width, 370, true, false);
		top1.screenCenter(XY);
		top1.antialiasing=true;
		top1.y -= 400;
		top1.scrollFactor.set(0,0);
		add(top1);

		top2 = new FlxTiledSprite(Paths.image('pause/overlay'), FlxG.width, 370, true, false);
		top2.screenCenter(XY);
		top2.antialiasing = true;
		top2.y -= 400;
		top2.scrollX = 295;
		top2.scrollFactor.set(0,0);
		add(top2);

		bot1 = new FlxTiledSprite(Paths.image('pause/overlay'), FlxG.width, 370, true, false);
		bot1.screenCenter(XY);
		bot1.antialiasing = true;
		bot1.y += 400;
		bot1.scrollFactor.set(0,0);
		add(bot1);

		bot2 = new FlxTiledSprite(Paths.image('pause/overlay'), FlxG.width, 370, true, false);
		bot2.screenCenter(XY);
		bot2.antialiasing = true;
		bot2.y += 400;
		bot2.scrollX = -295;
		bot2.scrollFactor.set(0,0);
		add(bot2);

		top1.y -= 300;
		top2.y -= 300;
		bot1.y += 300;
		bot2.y += 300;

		levelInfo = new FlxText(FlxG.width - 400, 0, 0, "", 32);
		levelInfo.text += PlayState.songData.displayName;
		levelInfo.scrollFactor.set();
		levelInfo.setFormat(Paths.font('Summer Square.otf'), 72, FlxColor.WHITE, FlxColor.BLACK);
		levelInfo.updateHitbox();
		levelInfo.x = FlxG.width - levelInfo.width * 2;
		levelInfo.screenCenter(Y);
		add(levelInfo);

		levelDifficulty = new FlxText(FlxG.width + 50, 0, 0, "", 32);
		levelDifficulty.text += CoolUtil.difficultyString();
		levelDifficulty.scrollFactor.set();
		levelDifficulty.setFormat(Paths.font('Summer Square.otf'), 64, FlxColor.WHITE, FlxColor.BLACK);
		levelDifficulty.updateHitbox();
		levelDifficulty.screenCenter(Y);
		levelDifficulty.y = levelInfo.y + levelInfo.height;
		add(levelDifficulty);

		levelDifficulty.alpha = 0;
		levelInfo.alpha = 0;

		//levelInfo.x = FlxG.width - (levelInfo.width + 20);
		//levelDifficulty.x = FlxG.width - (levelDifficulty.width + 20);

		FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});
		nameTween = FlxTween.tween(levelInfo, {alpha: 1, x: FlxG.width - levelInfo.width - 20}, 0.8, {ease: FlxEase.quartInOut, startDelay: 0.3});
		diffTween = FlxTween.tween(levelDifficulty, {alpha: 1, x: FlxG.width - levelDifficulty.width - 20}, 0.8, {ease: FlxEase.quartInOut, startDelay: 0.5});
		top1Tween = FlxTween.tween(top1, {y: top1.y + 300}, 0.7, {ease: FlxEase.quadOut, startDelay: 0.1});
		top2Tween = FlxTween.tween(top2, {y: top2.y + 300}, 0.7, {ease: FlxEase.quadOut, startDelay: 0.1});
		bot1Tween = FlxTween.tween(bot1, {y: bot1.y - 300}, 0.7, {ease: FlxEase.quadOut, startDelay: 0.325});
		bot2Tween = FlxTween.tween(bot2, {y: bot2.y - 300}, 0.7, {ease: FlxEase.quadOut, startDelay: 0.325});
		#if desktop
		blurTween = FlxTween.tween(blur, {size: 24}, 0.4, {ease: FlxEase.quartInOut});
		#end
		for (i in 0...menuItems.length)
		{
			//var songText:Alphabet = new Alphabet(0, (70 * i) + 30, menuItems[i], true, false);
			//songText.isMenuItem = true;
			//songText.targetY = i;
			var songText:PauseButton = new PauseButton(50, (i * 100) + (FlxG.height * 0.3), menuItems[i]);
			songText.targetY = i;

			songText.x = 50;
			songText.y = ((i * 100) + (FlxG.height * 0.3) - songText.bg.height/2) - 20;
			grpMenuShit.add(songText);
		}

		changeSelection();

		cameras = [daCam];
	}

	var canSelect:Bool = true;
	override function update(elapsed:Float)
	{
		if (pauseMusic.volume < 0.5)
			pauseMusic.volume += 0.01 * elapsed;

		super.update(elapsed);

		var upP = controls.UP_P && canSelect;
		var downP = controls.DOWN_P && canSelect;
		var accepted = controls.ACCEPT && canSelect;

		if (upP)
			changeSelection(-1);

		if (downP)
			changeSelection(1);

		var idx:Int = 0;

		for (item in grpMenuShit.members)
		{
			var yIndex = idx;
			if(curSelected>4){
				yIndex -= curSelected - 4;
			}

			idx++;

			var lerpVal:Float = 0.4 * (elapsed / (1/120) );
			if (item.targetY == 0)
			{
				item.x = FlxMath.lerp(item.x, 65, lerpVal);
				item.xScale = FlxMath.lerp(item.xScale, 1.2, lerpVal);
				item.yScale = FlxMath.lerp(item.yScale, 1.2, lerpVal);
			}else{
				item.x = FlxMath.lerp(item.x, 50, lerpVal);
				item.xScale = FlxMath.lerp(item.xScale, 1, lerpVal);
				item.yScale = FlxMath.lerp(item.yScale, 1, lerpVal);
			}

			item.y = FlxMath.lerp(item.y, ((yIndex * 100) + (FlxG.height * 0.3) - item.bg.height/2) - 20, lerpVal);

		}

		top1.scrollX -= 0.1 * (elapsed/(1/120));
		top2.scrollX += 0.5 * (elapsed/(1/120));
		bot1.scrollX -= 0.1 * (elapsed/(1/120));
		bot2.scrollX += 0.5 * (elapsed/(1/120));
		if (accepted)
		{
			var daSelected:String = menuItems[curSelected];

			switch (daSelected)
			{
				case "Resume":
					canSelect=false;
					top1Tween.cancel();
					top2Tween.cancel();
					bot1Tween.cancel();
					bot1Tween.active=false;
					bot2Tween.cancel();
					bot2Tween.active=false;
					#if desktop
					blurTween.cancel();
					blurTween.active=false;
					#end
					nameTween.cancel();
					nameTween.active=false;
					diffTween.cancel();
					diffTween.active=false;

					top1Tween = FlxTween.tween(top1, {y: top1.y - 300}, 0.7, {ease: FlxEase.quadOut});
					top2Tween = FlxTween.tween(top2, {y: top2.y - 300}, 0.7, {ease: FlxEase.quadOut});
					bot1Tween = FlxTween.tween(bot1, {y: bot1.y + 300}, 0.7, {ease: FlxEase.quadOut});
					bot2Tween = FlxTween.tween(bot2, {y: bot2.y + 300}, 0.7, {ease: FlxEase.quadOut});
					#if desktop
					blurTween = FlxTween.tween(blur, {size: 0}, 0.3, {ease: FlxEase.quadOut});
					#end
					FlxTween.tween(bg, {alpha: 0}, 0.4, {ease: FlxEase.quartInOut});
					nameTween = FlxTween.tween(levelInfo, {alpha: 0, x: FlxG.width - 50}, 0.4, {ease: FlxEase.quartInOut});
					diffTween = FlxTween.tween(levelDifficulty, {alpha: 0, x: FlxG.width + 15}, 0.4, {ease: FlxEase.quartInOut});
					for (item in grpMenuShit.members)
						FlxTween.tween(item, {alpha: 0}, 0.4, {ease: FlxEase.quartInOut});
					
					new FlxTimer().start(0.6, function(tmr:FlxTimer){
						#if desktop
						for(cam in FlxG.cameras.list){
							var fnfCam:FNFCamera = cast cam;
							if(cam!=cameras[0]){
								fnfCam.delFilter(blurF);
							}
						}
						#end
						close();
					});
				case "Restart Song":
					FlxG.resetState();
				case 'Restart with cutscene':
					PlayState.seenCutscene = false;
					FlxG.resetState();
				case "Restart from beginning":
					PlayState.startPos=0;
					FlxG.resetState();
				case "Set Start Position":
					PlayState.startPos = Conductor.rawSongPos;
				case "Exit to charter":
					FlxG.switchState(new ChartingState());
				case "Exit to menu":

					if(PlayState.isStoryMode)
						FlxG.switchState(new StoryMenuState());
					else{
						if (PlayState.fromExtras)
							FlxG.switchState(new ExtrasState());
						else
							FlxG.switchState(new FreeplayState());

						PlayState.fromExtras=false;
					}


					Cache.clear();
			}
		}


	}

	override function destroy()
	{
		pauseMusic.destroy();

		super.destroy();
	}

	function changeSelection(change:Int = 0):Void
	{
		curSelected += change;

		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		if (curSelected >= menuItems.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpMenuShit.members)
		{
			item.targetY = bullShit - curSelected;

			bullShit++;
			// item.setGraphicSize(Std.int(item.width * 0.8));

		}
	}
}
