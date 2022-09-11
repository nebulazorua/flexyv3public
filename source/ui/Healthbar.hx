package ui;

import flixel.FlxSprite;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.FlxBasic;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;

class Healthbar extends FlxSpriteGroup {
  public var bg:FlxSprite;
  public var bar:FlxBar;
  public var displayLeft:Float = 1;
  public var displayRight:Float = 1;
  public var leftBar:FlxBar;
  public var rightBar:FlxBar;
  public var debtBar:FlxBar;

  public var iconP1:HealthIcon;
  public var iconP2:HealthIcon;
  public var smooth:Bool = false;
  public var loving:Bool = false;
	public var cancer:Bool = false;
  public var reverse:Bool = false;
  public var value:Float = 1;
  public var color1:FlxColor;
  public var color2:FlxColor;

  var display:Float = 1;
  var instance:FlxBasic;
  var property:String;
  public function new(x:Float,y:Float,player1:String,player2:String,?instance:FlxBasic,?property:String,min:Float=0,max:Float=2,baseColor:FlxColor=0xFFFF0000,secondaryColor:FlxColor=0xFF66FF33){
    super(x,y);
    if(property==null || instance==null){
      property='value';
      instance=this;
    }


    this.instance=instance;
    this.property=property;
    display = Reflect.getProperty(instance,property);
    bg = new FlxSprite(0, 0).loadGraphic(Paths.image('healthBar','shared'));

    if(player1=='sonar' || player1=='ravvy')if(player2=='sonar' || player2=='ravvy')loving=true;
    bar = new FlxBar(bg.x + 4, bg.y + 4, RIGHT_TO_LEFT, Std.int(bg.width - 8), Std.int(bg.height - 8), this, 'display', min, max);
    bar.createFilledBar(baseColor,secondaryColor);
    debtBar = new FlxBar(bg.x + 4, bg.y + 4, LEFT_TO_RIGHT, Std.int(bg.width - 8), Std.int(bg.height - 8), instance, 'goldLoan', 0, 2);
    debtBar.createFilledBar(0x00000000,0xFFCC9900);

    iconP1 = new HealthIcon(player1, true);
    iconP1.y = bar.y - (iconP1.height / 2);

    iconP2 = new HealthIcon(player2, false);
    iconP2.y = bar.y - (iconP2.height / 2);

    leftBar = new FlxBar(bg.x + 4, bg.y + 4, LEFT_TO_RIGHT, Std.int((bg.width - 8)/2), Std.int(bg.height - 8), this, 'displayLeft', min, max/2);
    leftBar.createFilledBar(secondaryColor,secondaryColor);
    rightBar = new FlxBar(bg.x + (bg.width/2), bg.y + 4, RIGHT_TO_LEFT, Std.int((bg.width - 8)/2), Std.int(bg.height - 8), this, 'displayRight', min, max/2);
    rightBar.createFilledBar(baseColor,baseColor);
    bar.visible=!loving;
    leftBar.visible=loving;
    rightBar.visible=loving;

    add(bg);
    add(leftBar);
    add(rightBar);

    add(bar);

    add(debtBar);

    add(iconP1);
    add(iconP2);

  }
  public function setIcons(?player1,?player2){
    player1=player1==null?iconP1.animation.curAnim.name:player1;
    player2=player2==null?iconP2.animation.curAnim.name:player2;
    iconP1.changeCharacter(player1);
    iconP2.changeCharacter(player2);
  }

  public function setColors(baseColor:FlxColor,secondaryColor:FlxColor){
    var b = baseColor;
    var s = secondaryColor;
    bar.createFilledBar(baseColor,secondaryColor);
    color1 = b;
    color2 = s;

    rightBar.createFilledBar(0xFFFFFFFF,baseColor);
    leftBar.createFilledBar(0xFFFFFFFF,secondaryColor);

    rightBar.updateBar();
    leftBar.updateBar();

    bar.updateBar();
  }
  public function setIconSize(iconP1Size:Int,iconP2Size:Int){


    iconP1.setGraphicSize(Std.int(iconP1Size));
    iconP2.setGraphicSize(Std.int(iconP2Size));

    iconP1.updateHitbox();
    iconP2.updateHitbox();
    
  }

  var off:Float = 0;
  public function beatHit(curBeat:Float){
    if(cancer){
			var beat1 = (curBeat % 2) * 2;
			var beat2 = ((curBeat + 1)%2) * 2;
      
			if (beat1 == 0)
				beat1 = 0.5;
			if (beat2 == 0)
				beat2 = 0.5;

			iconP1.setGraphicSize(Std.int(150), Std.int(150 * beat1));
			iconP2.setGraphicSize(Std.int(150), Std.int(150 * beat2));
			iconP1.updateHitbox();
			iconP2.updateHitbox();
    }else if(loving && bar.percent>=90){
      iconP1.setGraphicSize(Std.int(150 - 30),Std.int(150 + 15));
      iconP2.setGraphicSize(Std.int(150 - 30),Std.int(150 + 15));
      off = 15;
      iconP1.updateHitbox();
      iconP2.updateHitbox();
    }else{
      setIconSize(180, 180);
    }
    if(cancer){
      var beat1 = curBeat % 2;
      var beat2 = (curBeat + 1) % 2;
			if (beat1 == 0)
				beat1=-1;
      if(beat2==0)
        beat2=-1;

      iconP1.angle = beat1 * 35;
      iconP2.angle = beat2 * 35;
    }
  }



  override function update(elapsed:Float){
    var num = Reflect.getProperty(instance,property);
    if(smooth){
      display = FlxMath.lerp(display,num,Main.adjustFPS(.2));
      if(Math.abs(display-num)<.1){
        display=num;
      }
    }else{
      display=num;
    }

    iconP1.flipX=!loving;
    iconP2.flipX=loving;

    bar.visible=!loving;
    leftBar.visible=loving;
    rightBar.visible=loving;

    displayRight = display/2;
    displayLeft = display/2;

    var percent = bar.percent;
    var opponentPercent = 100-bar.percent;

		if (cancer)
		{
			iconP1.angle = FlxMath.lerp(iconP1.angle, 0, Main.adjustFPS(0.15));
			iconP2.angle = FlxMath.lerp(iconP2.angle, 0, Main.adjustFPS(0.15));
    }
    if(!loving){
      if(reverse){
        percent = 100-bar.percent;
        opponentPercent = bar.percent;
        if(bar.fillDirection==RIGHT_TO_LEFT){
          bar.fillDirection = LEFT_TO_RIGHT;
          setColors(color2,color1);
        }

      }else{
        if(bar.fillDirection==LEFT_TO_RIGHT){
          bar.fillDirection = RIGHT_TO_LEFT;
          setColors(color2,color1);
        }
      }
    }

    var iconOffset:Int = 26;
    if(loving){

      if(percent>=90){
        iconP1.setGraphicSize(Std.int(FlxMath.lerp(iconP1.width, 150, Main.adjustFPS(0.3))),Std.int(FlxMath.lerp(iconP1.height, 150, Main.adjustFPS(0.3))));
        iconP2.setGraphicSize(Std.int(FlxMath.lerp(iconP2.width, 150, Main.adjustFPS(0.3))),Std.int(FlxMath.lerp(iconP2.height, 150, Main.adjustFPS(0.3))));

        iconP1.updateHitbox();
        iconP2.updateHitbox();
        iconP1.animation.curAnim.curFrame = iconP1.lossIndex;
        iconP2.animation.curAnim.curFrame = iconP2.lossIndex;
      }else{
        setIconSize(Std.int(FlxMath.lerp(iconP1.width, 150, Main.adjustFPS(0.3))),Std.int(FlxMath.lerp(iconP2.width, 150, Main.adjustFPS(0.3))));
        iconP1.animation.curAnim.curFrame = iconP1.neutralIndex;
        iconP2.animation.curAnim.curFrame = iconP2.neutralIndex;
      }

      // THIS IS FOR 12 28 LMAO GOTO THE ELSE
      // - neb, because im a dipshit and put shit here before
      var width = bg.width - 4;

      iconP1.x = (bg.x - iconP1.width/2) + (((width/2)-45) * percent/100) + off;
      iconP2.x = (bg.x + width - iconP2.width/2) - (((width/2)-45) * percent/100) - off;


      off = FlxMath.lerp(off, 0, Main.adjustFPS(0.1));

      iconP1.y = bg.y - iconP1.height/2;
      iconP2.y = bg.y - iconP2.height/2;

    }else{
      if(cancer){
				iconP1.setGraphicSize(Std.int(FlxMath.lerp(iconP1.width, 150, Main.adjustFPS(0.3))),
					Std.int(FlxMath.lerp(iconP1.height, 150, Main.adjustFPS(0.15))));
				iconP2.setGraphicSize(Std.int(FlxMath.lerp(iconP2.width, 150, Main.adjustFPS(0.3))),
					Std.int(FlxMath.lerp(iconP2.height, 150, Main.adjustFPS(0.15))));

				iconP1.updateHitbox();
				iconP2.updateHitbox();

      }else
        setIconSize(Std.int(FlxMath.lerp(iconP1.width, 150, Main.adjustFPS(0.1))),Std.int(FlxMath.lerp(iconP2.width, 150, Main.adjustFPS(0.1))));
      debtBar.x = bar.x + (bar.width * (FlxMath.remapToRange(percent, 0, 100, 100, 0) * 0.01));

      iconP1.x = bar.x + (bar.width * (FlxMath.remapToRange(percent, 0, 100, 100, 0) * 0.01) - iconOffset);
      iconP2.x = bar.x + (bar.width * (FlxMath.remapToRange(percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);

      if (percent < 20 && iconP1.lossIndex!=-1)
        iconP1.animation.curAnim.curFrame = iconP1.lossIndex;
      else if(percent > 80 && iconP1.winningIndex!=-1)
        iconP1.animation.curAnim.curFrame = iconP1.winningIndex;
      else
        iconP1.animation.curAnim.curFrame = iconP1.neutralIndex;


      if (opponentPercent < 20 && iconP2.lossIndex!=-1)
        iconP2.animation.curAnim.curFrame = iconP2.lossIndex;
      else if(opponentPercent > 80 && iconP2.winningIndex!=-1)
        iconP2.animation.curAnim.curFrame = iconP2.winningIndex;
      else
        iconP2.animation.curAnim.curFrame = iconP2.neutralIndex;
    }

    super.update(elapsed);


  }
}
