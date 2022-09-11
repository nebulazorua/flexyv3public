package ui;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

typedef MenuCharData = {
	var name:String;
	var xOffset:Int;
	var yOffset:Int;
	var scale:Float;
	var fps:Int;
	var flipped:Bool;
	var looped:Bool;
}

class MenuCharacter extends FlxSprite
{
	public var character:String;
	public var baseX:Float = 0;
	public var baseY:Float = 0;
	public var tween:FlxTween;

	private static var settings:Map<String,MenuCharData> = [
		'bf'=>{name:"BF idle dance",xOffset:80, yOffset:-25, scale:1, fps: 24, flipped: false, looped: true},
		'flexy'=>{name:"idle- flexy idle",xOffset:-130, yOffset:0, scale:1, fps: 24, flipped: false, looped: true},
		'corruptedflexy'=>{name:"corrupt fleky",xOffset:-130, yOffset:-80, scale:1, fps: 24, flipped: false, looped: true},
		'corruptedbf'=>{name:"corrupt bf",xOffset:80, yOffset:-25, scale:1, fps: 24, flipped: false, looped: true},
		'ravvy'=>{name:"ravvy",xOffset:-60, yOffset:0, scale:1, fps: 24, flipped: false, looped: true},
		"sonar"=>{name:"sonar",xOffset:50, yOffset:0, scale:1, fps: 24, flipped: false, looped: true},
		"clayflexy"=>{name:"clay flexy",xOffset:-130, yOffset:-90, scale:1, fps: 24, flipped: false, looped: true},
		"dickhead"=>{name:"sb",xOffset:120, yOffset:-10, scale:1, fps: 24, flipped: false, looped: true}
	];

	public function setCharacter(char:String){
		if(char!=character){
			if(settings.exists(char)){
				frames = Paths.getSparrowAtlas('campaign_menu_UI_characters');
				var shit = settings.get(char);
				animation.addByPrefix(char, shit.name, shit.fps, shit.looped);
				animation.play(char,true);

				visible=true;

				updateHitbox();
				setGraphicSize(Std.int(width*shit.scale));
				//setPosition(baseX+shit.xOffset,baseY+shit.yOffset);
				offset.x -= shit.xOffset;
				offset.y -= shit.yOffset;

				flipX = shit.flipped;
				character=char;
			}else{
				character='none';
				visible=false;
			}
		}
	}

	public function new(sX:Float, sY:Float, character:String = 'bf')
	{
		super(sX, sY);
		baseX = x;
		baseY = y;

		setCharacter(character);
	}
}
