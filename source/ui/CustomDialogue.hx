// kinda based on psych's one a litte


package ui;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.text.FlxTypeText;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.input.FlxKeyManager;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import states.*;
import ui.*;
import openfl.utils.Assets;
import flixel.tweens.FlxTween;
import flixel.group.FlxGroup.FlxTypedGroup;
import haxe.Json;
import flash.display.BitmapData;
#if sys
import sys.io.File;
import sys.FileSystem;
#end
import Sys;
using StringTools;

typedef DialogueLine = {
  var character:String;
  var expression:String;
  var text:String;

  @:optional var actions:Array<DialogueAction>;
  @:optional var speed:Float;
  @:optional var box:String;
  @:optional var autoFinish:Float;
}

typedef DialogueFile = {
  var dialogue:Array<DialogueLine>;
  @:optional var music:String;
}

typedef DialogueExpression = {
  @:optional var animOffset:Array<Float>;
  var name:String;
  var prefix:String;
}

typedef DialogueCharacterFile = {
  var spritesheet:String;
  var pos:String;
  var expressions:Array<DialogueExpression>;
	@:optional var scale:Float;
  @:optional var offset:Array<Float>;

}

class DialogueCharacter extends FlxSprite {
  public var curCharacter:String;
  public var animOffsets:Map<String, Array<Dynamic>>;
  public var charOffset:Array<Float> = [];
  public var charData:DialogueCharacterFile;
  public var pos:String = 'left';
  public var actualX:Float = 0;
  public var actualY:Float = 0;
  public function new(x:Float, y:Float, ?character:String = "bf")
	{
		super(x, y);
		animOffsets = new Map<String, Array<Dynamic>>();
		curCharacter = character;

		antialiasing = true;

		setChar(curCharacter);

	}

  public function setCharData(){
    if(charData!=null){
      var chars = "assets/characters/dialogue/images/";
			var pathBase = "assets/characters/dialogue/data/";

			var spritesheet = charData.spritesheet;
			var path = chars + spritesheet;

      #if sys
			if(FileSystem.exists(path + ".png")){
				var image = FlxG.bitmap.get(path);
				if(image==null)
					image = FlxG.bitmap.add(BitmapData.fromFile(path + ".png"),false,path);

				if(FileSystem.exists(path + ".txt")){
					frames = FlxAtlasFrames.fromSpriteSheetPacker(image, File.getContent(path + ".txt") );
				}else if(FileSystem.exists(path + ".xml")){
					frames = FlxAtlasFrames.fromSparrow(image, File.getContent(path + ".xml") );
				}
			}
      #else
			trace(path, Assets.exists(path + ".png", IMAGE));
			if (Assets.exists(path + ".png", IMAGE))
			{
				var image = FlxG.bitmap.get(path);
				if (image == null)
					image = FlxG.bitmap.add(path + ".png", false, path);

				if (Assets.exists(path + ".txt", TEXT))
				{
					frames = FlxAtlasFrames.fromSpriteSheetPacker(image, Assets.getText(path + ".txt"));
				}
				else if (Assets.exists(path + ".xml", TEXT))
				{
					frames = FlxAtlasFrames.fromSparrow(image, Assets.getText(path + ".xml"));
				}
			}
      #end

      animOffsets.clear();
      animation.destroyAnimations();

      for(anim in charData.expressions){
        var prefix:String = anim.prefix;
        var name:String = anim.name;
        var offsets:Array<Float> = anim.animOffset;
        if(offsets.length<2)
            offsets=[0,0];

        animation.addByPrefix(name,prefix,24,false);

        addOffset(name,offsets[0],offsets[1]);

      }

      pos = charData.pos;
      if(charData.offset.length==2)
        charOffset = charData.offset;
      else
        charOffset = [0, 0];

			if (charData.scale!=null){
				setGraphicSize(Std.int(width * charData.scale));
        updateHitbox();
      }

    }
  }

  public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		if(animation.getByName(AnimName)!=null){
			animation.play(AnimName, Force, Reversed, Frame);

			var daOffset = animOffsets.get(AnimName);
			if (animOffsets.exists(AnimName))
				offset.set(daOffset[0], daOffset[1]);
			else
				offset.set(0, 0);

		}
	}

  public function addOffset(name:String, x:Float, y:Float)
    animOffsets[name] = [x, y];


  public function setChar(newChar:String){
    switch (newChar)
    {
      //case 'whatever':
      // whatever hard-coded shit here

      default:
      {
        curCharacter=newChar;

        charData=getJSON(curCharacter);

        setCharData();
      }
    }
  }

  public function getJSON(character:String): DialogueCharacterFile{
    var pathBase = 'assets/characters/dialogue/data/';
    var daCharPath = pathBase + character + ".json";
    var shit:Null<Dynamic>=null;
    #if sys
    if(FileSystem.exists(daCharPath))
			shit = cast Json.parse(File.getContent(daCharPath));
		else if(FileSystem.exists(pathBase + "dad.json"))
			shit = cast Json.parse(File.getContent(pathBase + "dad.json") );
    #else
		if (Assets.exists(daCharPath, TEXT))
			shit = cast Json.parse(Assets.getText(daCharPath));
		else if (Assets.exists(pathBase + "dad.json", TEXT))
			shit = cast Json.parse(Assets.getText(pathBase + "dad.json"));
    #end

    return shit;
  }
}

typedef DialogueAction =
{
	var name:String;
	var args:Array<Dynamic>;
}
class CustomDialogue extends FlxSpriteGroup {
  var dialogueText:Alphabet;
  var bgFade:FlxSprite;
  var box:FlxSprite;

  var dialogue: DialogueFile;
  var current:Int = 0;

  var characters:Map<String, DialogueCharacter>=[];

  public var nextLineCallback:Bool->Void; // bool is if went to next line by autoFinish or player (true or autoFinish, false for player)
  public var skipCallback:Void->Void; // for when the player presses Enter midway through dialogue
  public var finishCallback:Void->Void; // for when the dialogue finishes
	var currentLine:DialogueLine;
  var dialogueEnded:Bool = false;

  var autofinishTimer:FlxTimer;
  var boxType:String = 'normal';
  var boxFlip:Bool = false;

	public function doAction(action:DialogueAction)
	{
		switch (action.name.toLowerCase())
		{
			case 'flash':
				for (cam in cameras)
					cam.flash(FlxColor.fromString(action.args[0]), action.args[1]);
			case 'sound':
				FlxG.sound.play(Paths.sound(action.args[0]), action.args[1]);
			case 'changemusic':
				FlxG.sound.music.fadeOut(0.75, 0, function(tw:FlxTween)
				{
					FlxG.sound.playMusic(Paths.music(action.args[0]), 0);
					FlxG.sound.music.fadeIn(0.75, 0, 0.8);
				});
      case 'cutmusic':
        FlxG.sound.music.stop();
		}
	}

  public function doCurrentLine(){
    while(dialogue.dialogue[current]==null && current < dialogue.dialogue.length)current++;
    trace(current);
    if(current >= dialogue.dialogue.length)return;
    var line:DialogueLine = dialogue.dialogue[current];
    if(line.speed==null || Math.isNaN(line.speed))line.speed=0.05;
    if(line.box==null)line.box='normal';
    for(c in characters.keys()){
      if(c!=line.character)characters.get(c).visible=false;
    }
    
    currentLine = line;
    var thisChar = characters.get(line.character);
    var flip = (thisChar.pos=='left');
    if(line.box!=boxType || boxFlip!=flip){
      boxType = line.box;
      boxFlip = flip;
      playBoxAnim(boxType + "Open",true);
      box.flipX=flip;
    }
    box.visible=true;
    if(!thisChar.visible){
      thisChar.alpha=0;
      if(thisChar.actualX < FlxG.width/2)
        thisChar.x = thisChar.actualX - 50;
      else
        thisChar.x = thisChar.actualX + 50;

      thisChar.visible=true;
      FlxTween.tween(thisChar, {alpha: 1, x: thisChar.actualX}, 0.1);
    }
    thisChar.playAnim(line.expression, true);

		if (line.actions != null)
		{
			for (action in line.actions)
				doAction(action);
		}

    if(dialogueText!=null){
      remove(dialogueText);
      dialogueText.destroy();
    }
    if(autofinishTimer!=null){
      autofinishTimer.cancel();
      autofinishTimer.destroy();
      autofinishTimer=null;
    }
    dialogueText = new Alphabet(80, 420, line.text, false, true, 0.7, line.speed);
    add(dialogueText);
    if(line.autoFinish!=null){
      if(line.autoFinish<=0){
        dialogueText.finishCallback = function()
          skip(true);

      }else{
        dialogueText.finishCallback = function(){
          autofinishTimer = new FlxTimer().start(line.autoFinish, function(tmr:FlxTimer)
      		{
            skip(true);
          });
        }
      }
    }
  }


  public function endDialogue(){
		dialogueEnded = true;
		playBoxAnim(boxType + "Open", true);

		// cus reverse wont work on animation.play for some reason!!
		box.animation.curAnim.reverse();
		if (dialogueText != null)
		{
			remove(dialogueText);
			dialogueText.destroy();
			dialogueText = null;
			FlxG.sound.music.fadeOut(1, 0);
		}
  }
  
  function skip(auto:Bool=false){
    current++;
    if(current>=dialogue.dialogue.length){
      endDialogue();
    }else{
      doCurrentLine();
      if(nextLineCallback!=null)nextLineCallback(auto);
    }
  }

  function playBoxAnim(name: String, force:Bool=false, rev:Bool=false){
    box.animation.play(name, force, rev);
    box.centerOffsets();
    box.updateHitbox();
    switch(name){
      case 'loud' | 'loudOpen': //thank u psych for these values
        box.offset.set(50, 65);
    }
  }

  override function update(elapsed:Float){

    if(!dialogueEnded){
      if(box.animation.name == '${boxType}Open' && box.animation.finished)
        playBoxAnim(boxType,true);


      bgFade.alpha += 0.35 * elapsed;
      if(bgFade.alpha>0.5)bgFade.alpha=0.5;
      if(dialogueText!=null){
        if (FlxG.keys.justPressed.ENTER){
          FlxG.sound.play(Paths.sound('clickText'), 0.8);

          if(dialogueText.finishedTyping){
            skip();

          }else{
						dialogueText.stopTyping();
            var index = members.indexOf(dialogueText);
						if (dialogueText.finishCallback!=null)
						  dialogueText.finishCallback();

            remove(dialogueText);
						dialogueText = new Alphabet(80, 420, currentLine.text, false, false, 0.7);
            dialogueText.finishedTyping=true;
						insert(index, dialogueText);
            if(skipCallback!=null)skipCallback();
          }

        }else if(FlxG.keys.justPressed.SPACE){
           FlxG.sound.play(Paths.sound('clickText'), 0.8);
           endDialogue();
        }
      }
    }else{
      if(box!=null && box.animation.curAnim.curFrame<=0){
        box.destroy();
        box=null;
      }

      if(bgFade!=null){
        bgFade.alpha -= 0.5 * elapsed;
        if(bgFade.alpha<=0){
          bgFade.destroy();
          bgFade=null;
        }
      }

      for(shit in characters.keys()){
        var char = characters.get(shit);
        char.alpha -= 1 * elapsed;
      }

      if(bgFade==null && box==null){
        for(shit in characters.keys()){
          var char = characters.get(shit);
          char.destroy();
        }
        characters.clear();
        if(finishCallback!=null)finishCallback();
        kill();
      }
    }
    super.update(elapsed);
  }

  public function new(dialogue: DialogueFile){
    super();
    this.dialogue = dialogue;
    if(dialogue.music!=null){
      FlxG.sound.playMusic(Paths.music(dialogue.music), 0);
      FlxG.sound.music.fadeIn(1, 0, 0.8);
    }
    bgFade = new FlxSprite().makeGraphic(FlxG.width*4, FlxG.height*4, FlxColor.WHITE);
    bgFade.alpha=0;
    add(bgFade);

    var charsToAdd:Array<String> = [];
    for(data in dialogue.dialogue){
      if(!charsToAdd.contains(data.character))charsToAdd.push(data.character);
    }

    for(charName in charsToAdd){
      var char = new DialogueCharacter(0, 0, charName);
      switch(char.pos){
        case 'left':
          char.x = 200;
        case 'right':
          char.x = FlxG.width - char.width - 200;
      }
      char.y = 200;
      char.x += char.charOffset[0];
      char.y += char.charOffset[1];

      char.actualX = char.x;
      char.actualY = char.y;

      add(char);
      char.visible=false;
      characters.set(charName, char);
    }

    box = new FlxSprite(20, 370);
    box.frames = Paths.getSparrowAtlas("dialogue/dialogueBox");
    box.animation.addByPrefix("normal", "speech bubble normal", 24);
    box.animation.addByPrefix("normalOpen", "Speech Bubble Normal Open", 24, false);
    box.animation.addByPrefix("loud", "AHH speech bubble", 24);
    box.animation.addByPrefix("loudOpen", "speech bubble loud open", 24, false);
    playBoxAnim("normal",true);
    box.visible = false;
    add(box);

    doCurrentLine();

  }
}
