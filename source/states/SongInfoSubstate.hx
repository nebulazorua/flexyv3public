package states;

import flixel.group.FlxSpriteGroup;
import openfl.events.MouseEvent;
import flixel.FlxObject;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import flixel.FlxSprite;

typedef SongInfo = Array<SongLine>;
typedef SongLine = {
    var text:String;
    var ?link:String;
}

typedef HyperlinkData = {
    var beginIndex:Int;
    var endIndex:Int;
    var url:String;
    var underline:FlxSpriteGroup;
}

typedef CharPosInfo = {
    var x:Float;
    var y:Float;
}
class SongInfoSubstate extends MusicBeatSubstate {
    var info:SongInfo;
    var bg:FlxSprite;
    var box:FlxSprite;
    var text:FlxText;

    var links:Array<HyperlinkData> = [];

    public function new(daInfo:SongInfo) {
        info = daInfo;
        super();
    }

    function getXYAtIndex(text:FlxText, idx:Int): CharPosInfo {
        var textField = text.textField;
        @:privateAccess
        var textEngine = textField.__textEngine;

        for(group in textEngine.layoutGroups)
        {
            var advanceX = 0.0;
            for (i in 0...group.positions.length)
			{
				advanceX += group.getAdvance(i);
                var index = group.startIndex + i;
                if(index==idx){
                    var bounds = textField.getCharBoundaries(idx);
                    var width = bounds.width;
                    var height = bounds.height;
                    return {x: group.offsetX + advanceX - width, y: group.offsetY}
                }
            }
        }

        return {x: -1, y:-1}
    }

    function clickText(x:Float, y:Float){
		var idx:Int = text.textField.getCharIndexAtPoint(x, y);
        for(i in 0...links.length){
            var data = links[i];
            if(idx >= data.beginIndex && idx <= data.endIndex){
				#if linux
				Sys.command('/usr/bin/xdg-open', [data.url, "&"]);
				#else
				FlxG.openURL(data.url);
				#end
            }
        }
    }
    override function create(){
        super.create();
		bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();

		box = new FlxSprite().loadGraphic(Paths.image("songInfoBox"));
        box.screenCenter(XY);
        box.antialiasing = true;

        text = new FlxText(box.x + 45, box.y + 45, 720, '', 24);
        text.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);

		add(bg);
		add(box);
		add(text);

        var daText = '';
        var unformatted='';
        for(line in info){
			
            if(line.link!=null){
                links.push({
					beginIndex: unformatted.length,
					endIndex: unformatted.length + line.text.length-1,
                    url: line.link,
                    underline: new FlxSpriteGroup()
                });
                daText += '<hl>${line.text}<hl>';
            }else
                daText += line.text;

			unformatted += line.text;
        }

        text.applyMarkup(daText, [
            new FlxTextFormatMarkerPair(new FlxTextFormat(FlxColor.fromString('#6dc0fc'), true), "<hl>")
        ]);
        @:privateAccess
		text._regen =true;
		@:privateAccess
		text.regenGraphic();

        for(data in links){
			var startLine = text.textField.getLineIndexOfChar(data.beginIndex);
			var endLine = text.textField.getLineIndexOfChar(data.endIndex);
            for(lineIdx in startLine...endLine+1){
				var metrics = text.textField.getLineMetrics(lineIdx);
				var startPos = getXYAtIndex(text, data.beginIndex);
				var endPos = getXYAtIndex(text, data.endIndex);
                var y = startPos.y;
                if(lineIdx!=startLine){
                    @:privateAccess
					for (group in text.textField.__textEngine.layoutGroups)
					{
                        if(group.lineIndex == lineIdx)y=group.offsetY;
                    }
					startPos = {x: metrics.x, y: y};
                }
                if(lineIdx!=endLine){
                    
                    @:privateAccess
					for (group in text.textField.__textEngine.layoutGroups)
					{
						if (group.lineIndex == lineIdx)
							y = group.offsetY;
					}
					endPos = {x: metrics.width, y: y};
                }
                var bounds = text.textField.getCharBoundaries(data.beginIndex);
                var endBounds = text.textField.getCharBoundaries(data.endIndex);
                var width = Math.abs((endPos.x + endBounds.width) - startPos.x);
                var line = new FlxSprite(text.x + startPos.x + 2, text.y + startPos.y + bounds.height + 2).makeGraphic(Math.floor(width), 2, FlxColor.fromString('#6dc0fc'));
                data.underline.add(line);
            }
            data.underline.visible = false;
            add(data.underline);
        }
		FlxTween.tween(bg, {alpha: 0.6}, 0.2, {ease: FlxEase.linear});
    }

    var closing:Bool=false;
    override function update(elapsed:Float){
        super.update(elapsed);
		if (closing)return;
        if(FlxG.mouse.overlaps(text)){
            var localX = FlxG.mouse.x - text.x;
            var localY = FlxG.mouse.y - text.y;
			var idx:Int = text.textField.getCharIndexAtPoint(localX, localY);
			for (i in 0...links.length)
			{
				var data = links[i];
				data.underline.visible = idx >= data.beginIndex && idx <= data.endIndex;
			}

			if (FlxG.mouse.justPressed)
			    clickText(localX, localY);
            

        }else{
			for (i in 0...links.length)
			{
				var data = links[i];
				data.underline.visible = false;
			} 
        }
        if(controls.BACK || FlxG.mouse.justPressed && !FlxG.mouse.overlaps(text) && !FlxG.mouse.overlaps(box)){
            closing=true;
			FlxTween.tween(bg, {alpha: 0}, 0.2, {ease: FlxEase.linear, onComplete:function(twn:FlxTween){
                close();
            }});
            for(data in links)
				FlxTween.tween(data.underline, {alpha: 0}, 0.2, {ease: FlxEase.linear});
            
			FlxTween.tween(box, {alpha: 0}, 0.2, {ease: FlxEase.linear});
			FlxTween.tween(text, {alpha: 0}, 0.2, {ease: FlxEase.linear});
        }
    }
}