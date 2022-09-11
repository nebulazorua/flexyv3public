package states;

import openfl.events.MouseEvent;
import flixel.FlxObject;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import flixel.FlxSprite;

class HTMLSUSubstate extends MusicBeatSubstate
{
	var bg:FlxSprite;
	var txt:FlxText;
	var txt2:FlxText;

	override function create()
	{
		super.create();
		bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();

		txt = new FlxText(0, 0, 0, "That's all, folks!", 24);
		txt.setFormat(Paths.font("vcr.ttf"), 30, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.PURPLE);
		txt.screenCenter(XY);
		txt.alpha = 0;
		txt.scrollFactor.set();
		txt.y += 190;

		txt2 = new FlxText(0, 0, 750, "If you'd like to keep playing\nClick on this text to download the full mod\nPress any key to leave this screen.", 24);
		txt2.setFormat(Paths.font("vcr.ttf"), 30, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.PURPLE);
		txt2.screenCenter(XY);
		txt2.alpha = 0;
		txt2.scrollFactor.set();
		txt2.y += 250;

		add(bg);
		add(txt);
		add(txt2);
		FlxTween.tween(txt, {alpha: 1}, 0.5, {ease: FlxEase.linear, startDelay: 0});
		FlxTween.tween(txt2, {alpha: 1}, 0.5, {ease: FlxEase.linear, startDelay: 0.85});
		FlxTween.tween(bg, {alpha: 0.6}, 0.2, {ease: FlxEase.linear});
	}

	var closing:Bool = false;

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (closing)
			return;

        if(FlxG.mouse.overlaps(txt2) && FlxG.mouse.justPressed){
			#if linux
			Sys.command('/usr/bin/xdg-open', ["https://gamebanana.com/mods/44567", "&"]);
			#else
			FlxG.openURL("https://gamebanana.com/mods/44567");
			#end
        }

		if (FlxG.keys.justPressed.ANY && txt2.alpha == 1)
		{
			FlxG.save.data.seenSUNotif = true;
			FlxG.save.flush();
			closing = true;
			FlxG.sound.play(Paths.sound('cancelMenu'));
			FlxTween.tween(bg, {alpha: 0}, 0.5, {
				ease: FlxEase.linear,
				onComplete: function(twn:FlxTween)
				{
					close();
				}
			});

			FlxTween.tween(txt, {alpha: 0}, 0.5, {ease: FlxEase.linear});
			FlxTween.tween(txt2, {alpha: 0}, 0.5, {ease: FlxEase.linear});
		}
	}
}