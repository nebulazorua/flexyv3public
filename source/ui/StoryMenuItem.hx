package ui;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import Options;
import flixel.tweens.FlxTween;
import Shaders;
class StoryMenuItem extends FlxSpriteGroup
{
	public var week:FlxSprite;
	public var lock:FlxSprite;
	public var flashingInt:Int = 0;
	public var daTween:FlxTween;
	public var locked:Bool=false;
	var daShader:MemoryEffect;
	public function new(x:Float, y:Float, path:String)
	{
		super(x, y);
		week = new FlxSprite().loadGraphic(Paths.image('storymenu/${path}'));
		lock = new FlxSprite().loadGraphic(Paths.image('lock'));
		week.antialiasing=true;
		lock.antialiasing=true;
		add(week);
		add(lock);

		daShader = new MemoryEffect();
		daShader.red = 0.25;
		daShader.green = 0.25;
		daShader.blue = 0.25;
		week.shader = daShader.shader;
	}

	private var isFlashing:Bool = false;

	public function startFlashing():Void
	{
		if(OptionUtils.options.menuFlash==true)
			isFlashing = true;
	}

	// if it runs at 60fps, fake framerate will be 6
	// if it runs at 144 fps, fake framerate will be like 14, and will update the graphic every 0.016666 * 3 seconds still???
	// so it runs basically every so many seconds, not dependant on framerate??
	// I'm still learning how math works thanks whoever is reading this lol
	var fakeFramerate:Int = Math.round((1 / FlxG.elapsed) / 10);

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		lock.visible = locked;
		daShader.percent = locked?1:0;
		var lWidth = lock.frameWidth * lock.scale.x;
		var lHeight = lock.frameHeight * lock.scale.y;

		lock.x = week.x + (week.width - lWidth)/2;
		lock.y = week.y + (week.height - lHeight)/2;
		if(daTween!=null && daTween.finished)daTween=null;
		if (isFlashing)
			flashingInt += 1;

		if (flashingInt % fakeFramerate >= Math.floor(fakeFramerate / 2))
			week.color = 0xFF33ffff;
		else
			week.color = FlxColor.WHITE;
	}
}
