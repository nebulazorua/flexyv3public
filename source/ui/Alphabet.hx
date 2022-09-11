package ui;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.util.FlxTimer;

using StringTools;

/**
 * Loosley based on FlxTypeText lolol
 */
class Alphabet extends FlxSpriteGroup
{
	public var delay:Float = 0.05;
	public var paused:Bool = false;
	public var movementType:String = "stairs";
	// for menu shit
	public var targetY:Float = 0;
	public var isMenuItem:Bool = false;
	public var wantedX:Float = 0;
	public var wantedY:Float = 0;
	public var offsetX:Float = 90;

	public var finishCallback:Void->Void; // for typing text only
	public var finishedTyping:Bool = false; // for typing text only

	public var text:String = "";

	var _finalText:String = "";
	var _curText:String = "";

	public var widthOfWords:Float = FlxG.width;

	var yMulti:Float = 0;

	// custom shit
	// amp, backslash, question mark, apostrophy, comma, angry faic, period
	var lastSprite:AlphaCharacter;
	var xPosResetted:Bool = false;
	var lastWasSpace:Bool = false;
	var fontScale:Float = 1;

	var splitWords:Array<String> = [];

	var isBold:Bool = false;
	var white:Bool = false;
	var daWidth:Float = FlxG.width * 0.75;
	public function new(x:Float, y:Float, text:String = "", ?bold:Bool = false, typed:Bool = false, fontScale:Float=1, speed:Float=0.05, cracker:Bool=false, ?w:Float)
	{
		super(x, y);

		if(w!=null)daWidth = w;
		this.fontScale = fontScale;
		white = cracker;
		_finalText = text;
		this.text = text;
		isBold = bold;

		if (text != "")
		{
			if (typed)
			{
				startTypedText(speed);
			}
			else
			{
				addText();
			}
		}else
			finishedTyping = true;
		
	}

	public function addText()
	{
		doSplitWords();

		for(char in splitWords){
			// TODO: better word wrapping, but this works for now
			if (char == "\n" || x + xPos >= daWidth && char == ' ')
			{
				xPos = 0;
				yMulti++;
				curRow++;
				lastSprite = null;
			}

			if (char == ' ')
				spaces++;

			#if (haxe >= "4.0.0")
			var isNumber:Bool = AlphaCharacter.numbers.contains(char);
			var isSymbol:Bool = AlphaCharacter.symbols.contains(char);
			var isLetter:Bool = AlphaCharacter.alphabet.contains(char.toLowerCase());
			#else
			var isNumber:Bool = AlphaCharacter.numbers.indexOf(char) != -1;
			var isSymbol:Bool = AlphaCharacter.symbols.indexOf(char) != -1;
			var isLetter:Bool = AlphaCharacter.alphabet.indexOf(char.toLowerCase()) != -1;
			#end

			if ((isLetter || isNumber || isSymbol) && char != '')
			{
				if (lastSprite != null)
				{
					lastSprite.updateHitbox();
					xPos += lastSprite.width + 3;
				}

				if (spaces > 0)
					xPos += 20 * spaces * fontScale;

				spaces = 0;

				var alpha = new AlphaCharacter(xPos, 55 * yMulti, fontScale, white);
				alpha.row = curRow;

				if (isBold)
				{
					if (isNumber)
						alpha.createBoldNumber(char);
					else if (isSymbol)
						alpha.createBoldSymbol(char);
					else
						alpha.createBoldLetter(char);
				}
				else
				{
					if (isNumber)
						alpha.createNumber(char);
					else if (isSymbol)
						alpha.createSymbol(char);
					else
						alpha.createLetter(char);
				}
				add(alpha);
				lastSprite = alpha;
			}
		}
		finishedTyping = true;
		
	}

	function doSplitWords():Void
	{
		var daSplit = _finalText.split("");
		splitWords=[];
		while(daSplit.length>0){
			var curr = daSplit[0];
			var next = '';
			if(daSplit.length>1)next = daSplit[1];
			if(curr=='\\' && next=='n'){
				splitWords.push("\n");
				daSplit.splice(0, 2);
			}else{
				splitWords.push(curr);
				daSplit.shift();
			}
		}
	}

	var typingTimer:FlxTimer;
	override function destroy(){
		if(typingTimer!=null){
			typingTimer.cancel();
			typingTimer.destroy();
			typingTimer=null;
		}
		super.destroy();
	}

	var loopNum:Int = 0;

	var xPos:Float = 0;
	var curRow:Int = 0;
	var spaces:Int = 0;
	var speed:Float = 0.05;
	public function startTypedText(speed:Float=0.05):Void
	{
		_finalText = text;
		doSplitWords();
		loopNum = 0;

		xPos = 0;
		curRow = 0;
		spaces = 0;
		this.speed=speed;
		if(speed<=0){
			stopTyping();
			addText();
		}else{
			typingTimer = new FlxTimer().start(speed, timerFunc, 1);
		}
	}


	public function stopTyping(){
		if(typingTimer!=null){
			typingTimer.cancel();
			typingTimer.destroy();
			typingTimer=null;
		}
	
	}

	function timerFunc(?tmr:FlxTimer)
	{
		var char = splitWords[loopNum];
		// TODO: better word wrapping, but this works for now
		if(char=="\n" || x + xPos >= daWidth && char==' ' ){
			xPos = 0;
			yMulti++;
			curRow++;
			lastSprite = null;
		}

		if(char == ' ')
			spaces++;


		#if (haxe >= "4.0.0")
		var isNumber:Bool = AlphaCharacter.numbers.contains(char);
		var isSymbol:Bool = AlphaCharacter.symbols.contains(char);
		var isLetter:Bool = AlphaCharacter.alphabet.contains(char.toLowerCase());
		#else
		var isNumber:Bool = AlphaCharacter.numbers.indexOf(char) != -1;
		var isSymbol:Bool = AlphaCharacter.symbols.indexOf(char) != -1;
		var isLetter:Bool = AlphaCharacter.alphabet.indexOf(char.toLowerCase()) != -1;
		#end

		if ((isLetter || isNumber || isSymbol) && char!='')
		{
			if (lastSprite != null){
				lastSprite.updateHitbox();
				xPos += lastSprite.width + 3;
			}

			if (spaces>0)
				xPos += 20 * spaces * fontScale;

			spaces=0;

			var alpha = new AlphaCharacter(xPos, 55 * yMulti, fontScale, white);
			alpha.row = curRow;

			if (isBold)
			{
				if (isNumber)
					alpha.createBoldNumber(char);
				else if (isSymbol)
					alpha.createBoldSymbol(char);
				else
					alpha.createBoldLetter(char);
			}
			else
			{
				if (isNumber)
					alpha.createNumber(char);
				else if (isSymbol)
					alpha.createSymbol(char);
				else
					alpha.createLetter(char);
			}

			add(alpha);
			lastSprite = alpha;

		}

		loopNum++;
		if(loopNum < splitWords.length){
			if(tmr!=null)tmr.reset(speed);
		}else{
			finishedTyping=true;
			if(finishCallback!=null)finishCallback();
			if(tmr!=null)tmr.cancel();
		}
	}

	public function calculateWantedXY(){
		var scaledY = FlxMath.remapToRange(targetY, 0, 1, 0, 1.3);
		switch (movementType){
			case 'stairs':
				wantedY = (scaledY * 120) + (FlxG.height * 0.48);
				wantedX = (targetY * 20) + offsetX;
			case 'freeplayList':
				wantedY =  (scaledY * 720) + 320;
			case 'list':
				wantedY =  (scaledY * 120) + (FlxG.height * 0.48);
				wantedX = offsetX;
			case 'listManualX':
				wantedY =  (scaledY * 120) + (FlxG.height * 0.48);
			default:
				wantedY = (scaledY * 120) + (FlxG.height * 0.48);
				wantedX = offsetX;
		}
	}

	public function gotoTargetPosition(){
		calculateWantedXY();
		x = wantedX;
		y = wantedY;
	}

	override function update(elapsed:Float)
	{
		if (isMenuItem)
		{
			calculateWantedXY();
			x = FlxMath.lerp(x, wantedX, Main.adjustFPS(0.16));
			y = FlxMath.lerp(y, wantedY, Main.adjustFPS(0.16));

		}

		super.update(elapsed);
	}
}

class AlphaCharacter extends FlxSprite
{
	public static var alphabet:String = "abcdefghijklmnopqrstuvwxyz";

	public static var numbers:String = "1234567890";

	public static var symbols:String = "|~#$%()*+-:;<=>@[]^_.,'!?";

	public var row:Int = 0;
	public var fontScale:Float = 1;
	public function new(x:Float, y:Float, fontScale:Float=1, white:Bool=false)
	{
		super(x, y);
		this.fontScale=fontScale;
		var tex = Paths.getSparrowAtlas(white?'cumAlphabet':'alphabet');
		tex.parent.destroyOnNoUse = false;
		tex.parent.persist = true;
		
		
		frames = tex;

		scale.set(fontScale, fontScale);
		updateHitbox();

		antialiasing = true;
	}

	public function createBoldLetter(letter:String)
	{
		animation.addByPrefix(letter, letter.toUpperCase() + " bold", 24);
		animation.play(letter);
		updateHitbox();
	}

	public function createBoldNumber(letter:String):Void
	{
		animation.addByPrefix(letter, "bold" + letter, 24);
		animation.play(letter);
		updateHitbox();
	}

	public function createBoldSymbol(letter:String) // from PSYCHE
	{
		switch (letter)
		{
			case '.':
				animation.addByPrefix(letter, 'PERIOD bold', 24);
			case "'":
				animation.addByPrefix(letter, 'APOSTRAPHIE bold', 24);
			case "?":
				animation.addByPrefix(letter, 'QUESTION MARK bold', 24);
			case "!":
				animation.addByPrefix(letter, 'EXCLAMATION POINT bold', 24);
			case "(":
				animation.addByPrefix(letter, 'bold (', 24);
			case ")":
				animation.addByPrefix(letter, 'bold )', 24);
			default:
				animation.addByPrefix(letter, 'bold ' + letter, 24);
		}
		animation.play(letter);
		updateHitbox();

		switch (letter) // from psych thank u psych
		{
			case "'":
				y -= 20 * fontScale;
			case '-':
				//x -= 35 - (90 * (1.0 - textSize));
				y += 20 * fontScale;
			case '(':
				x -= 65 * fontScale;
				y -= 5 * fontScale;
				offset.x = -58 * fontScale;
			case ')':
				x -= 20 / fontScale;
				y -= 5 * fontScale;
				offset.x = 12 * fontScale;
			case '.':
				y += 45 * fontScale;
				x += 5 * fontScale;
				offset.x += 3 * fontScale;
		}

	}

	public function createLetter(letter:String):Void
	{
		var letterCase:String = "lowercase";
		if (letter.toLowerCase() != letter)
		{
			letterCase = 'capital';
		}

		animation.addByPrefix(letter, letter + " " + letterCase, 24);
		animation.play(letter);
		updateHitbox();

		y = (110 - height);
		y += row * 60;
	}

	public function createNumber(letter:String):Void
	{
		animation.addByPrefix(letter, letter, 24);
		animation.play(letter);

		updateHitbox();
		y = (110 - height);
		y += row * 60;
	}

	public function createSymbol(letter:String)
	{
		switch (letter)
		{
			case '#':
				animation.addByPrefix(letter, 'hashtag', 24);
			case '.':
				animation.addByPrefix(letter, 'period', 24);
			case "'":
				animation.addByPrefix(letter, 'apostraphie', 24);
				y -= 50;
			case "?":
				animation.addByPrefix(letter, 'question mark', 24);
			case "!":
				animation.addByPrefix(letter, 'exclamation point', 24);
			case ",":
				animation.addByPrefix(letter, 'comma', 24);
			default:
				animation.addByPrefix(letter, letter, 24);
		}
		animation.play(letter);

		updateHitbox();
		y = (110 - height);
		y += row * 60;
		switch (letter)
		{
			case "'":
				y -= 20;
			case '-':
				//x -= 35 - (90 * (1.0 - textSize));
				y -= 16;
		}
	}
}
