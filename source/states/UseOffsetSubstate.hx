package states;

import Options.OptionUtils;
import openfl.events.MouseEvent;
import flixel.FlxObject;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import flixel.FlxSprite;

class UseOffsetSubstate extends MusicBeatSubstate
{
	var bg:FlxSprite;
	var txt:FlxText;
    
    var oldOffset:Int = 0;
    var newOffset:Int = 0;

    public function new(oldO:Int, newO:Int){
        super();
        this.oldOffset=oldO;
        this.newOffset=newO;
    }

	override function create()
	{
		super.create();
        trace("wow");
		bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();

		txt = new FlxText(0, 0, 1000, "Would you like to use an offset of " + newOffset + "ms?\n(Was originally " + oldOffset + "ms)\nPress ESCAPE to leave it, press ENTER to set offset, or press SPACE to continue", 24);
		txt.setFormat(Paths.font("vcr.ttf"), 30, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.PURPLE);
		txt.screenCenter(XY);
		txt.alpha = 0;
		txt.scrollFactor.set();
		txt.y += 190;


		add(bg);
		add(txt);
		FlxTween.tween(txt, {alpha: 1}, 0.5, {ease: FlxEase.linear, startDelay: 0});
		FlxTween.tween(bg, {alpha: 0.6}, 0.2, {ease: FlxEase.linear});
	}

	var closing:Bool = false;

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (closing)
			return;
		if (FlxG.keys.justPressed.ENTER)
		{
			OptionUtils.options.noteOffset = newOffset;
			OptionUtils.saveOptions(OptionUtils.options);
        }

		if (FlxG.keys.justPressed.ENTER || FlxG.keys.justPressed.ESCAPE )
		{
            trace("oh");
			FlxG.save.flush();
			closing = true;
			FlxG.switchState(new OptionsState());
		}else if(FlxG.keys.justPressed.SPACE){
            trace("wat");
            close();
        }
	}
}