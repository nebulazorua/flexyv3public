package ui;

import flixel.FlxCamera;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.util.FlxTimer;
import flixel.FlxSprite;
import ui.Alphabet;
import flixel.group.FlxSpriteGroup;

typedef CutsceneLine =
{
	var character:String;
	var text:String;
    var image:String;

	@:optional var actions:Array<CutsceneAction>;
	@:optional var speed:Float;
	@:optional var box:String;
	@:optional var autoFinish:Float;
	@:optional var waitTime:Float;
}

typedef CutsceneAction = 
{
    var name:String;
	var args:Array<Dynamic>;
}

typedef CutsceneFile =
{
	var dialogue:Array<CutsceneLine>;
	@:optional var music:String;
}

class Cutscene extends FlxSpriteGroup
{
	var dialogueText:Alphabet;
	var bgFade:FlxSprite;
	var box:FlxSprite;
    var images:Map<String, FlxSprite> = [];
	var nametags:Map<String, FlxSprite> = [];

	var dialogue:CutsceneFile;
	var current:Int = 0;

	public var nextLineCallback:Bool->Void; // bool is if went to next line by autoFinish or player (true or autoFinish, false for player)
	public var skipCallback:Void->Void; // for when the player presses Enter midway through dialogue
	public var finishCallback:Void->Void; // for when the dialogue finishes
    
	public var fadeOut:Bool = true;
	var currentLine:CutsceneLine;
	var dialogueEnded:Bool = false;

	var autofinishTimer:FlxTimer;
    var canContinueTimer:FlxTimer;

	var boxType:String = 'normal';

    public function doAction(action:CutsceneAction){
        switch(action.name.toLowerCase()){
            case 'flash':
                for(cam in cameras)
                    cam.flash(FlxColor.fromString(action.args[0]), action.args[1]);
            case 'sound':
                FlxG.sound.play(Paths.sound(action.args[0]), action.args[1]);
            case 'changemusic':
				FlxG.sound.music.fadeOut(0.75, 0, function(tw:FlxTween){
					FlxG.sound.playMusic(Paths.music(action.args[0]), 0);
					FlxG.sound.music.fadeIn(0.75, 0, 0.8);
                });
                
        }
    }
	public function doCurrentLine()
	{
		while (dialogue.dialogue[current] == null && current < dialogue.dialogue.length)
			current++;

		if (current >= dialogue.dialogue.length)
			return;
		var line:CutsceneLine = dialogue.dialogue[current];
		if (line.speed == null || Math.isNaN(line.speed))
			line.speed = 0.05;
		if (line.box == null)
			line.box = 'normal';

		for (c in images.keys())
			images.get(c).visible = c == line.image;
	
		

		currentLine = line;
        
		if (line.box != boxType)
		{
			boxType = line.box;
			if (boxType == 'invisible')
				box.visible = false;
            //else
            //    playBoxAnim(boxType + "Open", true);
            
		}

        if(line.actions!=null){
            for(action in line.actions)
				doAction(action);
            
        }
		box.visible = boxType != 'invisible';

		for (c in nametags.keys())
			nametags.get(c).visible = box.visible==false?false:c == line.character;

		if (dialogueText != null)
		{
			remove(dialogueText);
			dialogueText.destroy();
		}
		if (autofinishTimer != null)
		{
			autofinishTimer.cancel();
			autofinishTimer.destroy();
			autofinishTimer = null;
		}
        if(canContinueTimer!=null){
			canContinueTimer.cancel();
			canContinueTimer.destroy();
			canContinueTimer = null;
        }
		dialogueText = new Alphabet(80, 430, line.text, false, true, 0.7, line.speed, true, FlxG.width * 0.8);
		add(dialogueText);
        if(line.waitTime!=null)
			canContinueTimer = new FlxTimer();
        
		dialogueText.finishCallback = function(){
			if (line.autoFinish!=null && line.autoFinish <= 0)
                skip(true);
            else{
				if (canContinueTimer!=null)
				    canContinueTimer.start(line.waitTime);
                
				if (line.autoFinish != null && line.autoFinish > 0){
                    autofinishTimer = new FlxTimer().start(line.autoFinish, function(tmr:FlxTimer)
                    {
                        skip(true);
                    });
                }
            }
            
        }

		if (line.text == '')
            if(dialogueText.finishCallback!=null)
				dialogueText.finishCallback();
        
	}

	public function endDialogue()
	{
		dialogueEnded = true;
		//playBoxAnim(boxType + "Open", true);

		// cus reverse wont work on animation.play for some reason!!
		//box.animation.curAnim.reverse();
		if (dialogueText != null)
		{
			remove(dialogueText);
			dialogueText.destroy();
			dialogueText = null;
			FlxG.sound.music.fadeOut(1, 0);
		}
        for(cam in cameras){
			cam.fade(FlxColor.BLACK, 0.5, false, function()
			{
				if (fadeOut)
					cam.fade(FlxColor.BLACK, 0.5, true, null, true);
			}, true);
        }
        new FlxTimer().start(0.5, function(tmr:FlxTimer){
			if (fadeOut){
				new FlxTimer().start(0.5, function(tmr:FlxTimer)
				{
					if (finishCallback != null)
						finishCallback();
				});
				kill();
			}else{
				if (finishCallback != null)
					finishCallback();
			}
        });
	}

	function skip(auto:Bool = false)
	{
		current++;
		if (current >= dialogue.dialogue.length)
		{
			endDialogue();
		}
		else
		{
			doCurrentLine();
			if (nextLineCallback != null)
				nextLineCallback(auto);
		}
	}

	/*function playBoxAnim(name:String, force:Bool = false, rev:Bool = false)
	{
		box.animation.play(name, force, rev);
		box.centerOffsets();
		box.updateHitbox();
		switch (name)
		{
			case 'loud' | 'loudOpen': // thank u psych for these values
				box.offset.set(50, 65);
            case 'normal' | 'normalOpen':
				box.offset.set(0, -65);
		}
	}*/

	override function update(elapsed:Float)
	{
		if (!dialogueEnded)
		{
			//if (box.animation.name == '${boxType}Open' && box.animation.finished)
			//	playBoxAnim(boxType, true);

			bgFade.alpha += 0.35 * elapsed;
			if (bgFade.alpha > 0.5)
				bgFade.alpha = 0.5;
			if (dialogueText != null)
			{
				if (FlxG.keys.justPressed.ENTER)
				{
				
					if (dialogueText.finishedTyping)
					{
						if ((canContinueTimer == null || canContinueTimer.time > 0 && canContinueTimer.finished)){
							FlxG.sound.play(Paths.sound('clickText'), 0.8);
						    skip();
                        }
					}
					else
					{
						FlxG.sound.play(Paths.sound('clickText'), 0.8);
						dialogueText.stopTyping();
						var index = members.indexOf(dialogueText);
						if (dialogueText.finishCallback != null)
							dialogueText.finishCallback();

						remove(dialogueText);
						dialogueText = new Alphabet(80, 430, currentLine.text, false, false, 0.7, true, FlxG.width * 0.8);
						dialogueText.finishedTyping = true;
						insert(index, dialogueText);
						if (skipCallback != null)
							skipCallback();
					}
				}
				else if (FlxG.keys.justPressed.SPACE)
				{
					FlxG.sound.play(Paths.sound('clickText'), 0.8);
					endDialogue();
				}
			}
		}
		else
		{
			if (box != null)
			{
				box.destroy();
				box = null;
			}
		}
		super.update(elapsed);
	}

	public function new(dialogue:CutsceneFile)
	{
		super();
		this.dialogue = dialogue;
		if (dialogue.music != null)
		{
			FlxG.sound.playMusic(Paths.music(dialogue.music), 0);
			FlxG.sound.music.fadeIn(1, 0, 0.8);
		}
		bgFade = new FlxSprite().makeGraphic(FlxG.width * 4, FlxG.height * 4, FlxColor.WHITE);
		bgFade.alpha = 0;
		add(bgFade);

		var imagesToAdd:Array<String> = [];
		var tagsToAdd:Array<String> = [];
		for (data in dialogue.dialogue)
		{
			if (!imagesToAdd.contains(data.image))
				imagesToAdd.push(data.image);

			if (!tagsToAdd.contains(data.character))
				tagsToAdd.push(data.character);
		}

		for (image in imagesToAdd)
		{
			var spr = new FlxSprite();
            spr.loadGraphic(Paths.image('cutscenes/$image'));
            spr.antialiasing = true;
			spr.setGraphicSize(FlxG.width, FlxG.height);
			spr.updateHitbox();
			add(spr);
			spr.visible = false;
            images.set(image, spr);
		}

		for (char in tagsToAdd)
		{
			var spr = new FlxSprite();
			spr.loadGraphic(Paths.image('dialogue/nametags/$char'));
			spr.antialiasing = true;
			add(spr);
			spr.visible = false;
			nametags.set(char, spr);
		}
		

		box = new FlxSprite(0, 0);
		box.loadGraphic(Paths.image("dialogue/transDialogueBox"));
		box.updateHitbox();
		//playBoxAnim("normal", true);
		box.visible = false;
		add(box);

		doCurrentLine();
	}
}

