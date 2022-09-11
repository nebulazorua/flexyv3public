package ui;

import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.FlxSprite;

class CockSprite extends FlxSprite {
	public var sprTracker:FlxSprite;

	override public function loadGraphic(Graphic:FlxGraphicAsset, Animated:Bool = false, Width:Int = 0, Height:Int = 0, Unique:Bool = false,
			?Key:String):CockSprite
	{
		return cast super.loadGraphic(Graphic, Animated, Width, Height, Unique, Key);
	}

    override function update(elapsed:Float){
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x - width - 10, sprTracker.y - 10);
    }
}