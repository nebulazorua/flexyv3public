package states;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import ui.*;
using StringTools;
class CorruptGameOverSubstate extends MusicBeatSubstate
{
	var img:OffsetSprite;
	var camFollow:FlxObject;

	var stageSuffix:String = "-corr";

	public function new(x:Float, y:Float, ?who:String='bf')
	{
		super();

		Conductor.songPosition = 0;

		img = new OffsetSprite();
		img.frames = Paths.getSparrowAtlas("CORRUPT_BF_GAMEOVER");
		img.animation.addByPrefix("firstDeath", "BF dies", 24, false);
		img.animation.addByPrefix("deathLoop", "BF Dead Loop", 24, true);
		img.animation.addByPrefix("deathConfirm", "BF Dead confirm", 24, false);
		img.screenCenter(XY);
		img.scrollFactor.set();
		add(img);
		Conductor.changeBPM(100);
		Conductor.songPosition = 0;
		FlxG.sound.play(Paths.sound('fnf_loss_sfx' + stageSuffix));

		// FlxG.camera.followLerp = 1;
		// FlxG.camera.focusOn(FlxPoint.get(FlxG.width / 2, FlxG.height / 2));
		FlxG.camera.scroll.set();
		FlxG.camera.target = null;

		img.animation.play('firstDeath');
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
        
		if (controls.ACCEPT)
		{
			endBullshit();
		}

		if (controls.BACK)
		{
			FlxG.sound.music.stop();

			if (PlayState.isStoryMode)
				FlxG.switchState(new StoryMenuState());
			else
				FlxG.switchState(new FreeplayState());
		}

		if (img.animation.curAnim.name == 'firstDeath' && img.animation.curAnim.curFrame == 12)
		{
			FlxG.camera.follow(camFollow, LOCKON, Main.adjustFPS(0.01));
		}

		if (img.animation.curAnim.name == 'firstDeath' && img.animation.curAnim.finished)
		{
			FlxG.sound.playMusic(Paths.music('gameOver' + stageSuffix));
		}

		if (img.animation.curAnim.name == 'firstDeath' && img.animation.curAnim.finished)
			img.playAnim('deathLoop');
        
		if (FlxG.sound.music.playing)
		{
			Conductor.songPosition = FlxG.sound.music.time;
		}
	}

	override function beatHit()
	{
		super.beatHit();

		FlxG.log.add('beat');
	}

	var isEnding:Bool = false;

	function endBullshit():Void
	{
		if (!isEnding)
		{
			isEnding = true;
			img.playAnim('deathConfirm', true);
			FlxG.sound.music.stop();
			FlxG.sound.play(Paths.music('gameOverEnd' + stageSuffix));
			new FlxTimer().start(0.7, function(tmr:FlxTimer)
			{
				FlxG.camera.fade(FlxColor.BLACK, 2, false, function()
				{
					LoadingState.loadAndSwitchState(new PlayState());
				});
			});
		}
	}
}
