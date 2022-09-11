package ui;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.util.FlxTimer;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.math.FlxMath;
using StringTools;

class PauseBG extends FlxSpriteGroup {
  public var rect:FlxSprite;
  public var lTri:FlxSprite;
  public var rTri:FlxSprite;

  override public function set_color(val:FlxColor){
    rect.color = val;
    lTri.color = val;
    rTri.color = val;
    return super.set_color(val);
  }

  public function new(){
    super();
    rect = new FlxSprite().loadGraphic(Paths.image("pause/rectangle"));
		rect.antialiasing = true;
    rect.scrollFactor.set();

    lTri = new FlxSprite().loadGraphic(Paths.image("pause/triangle"));
		lTri.antialiasing = true;
    lTri.scrollFactor.set();

    rTri = new FlxSprite().loadGraphic(Paths.image("pause/triangle"));
    rTri.angle = 180;
		rTri.antialiasing = true;
    rTri.scrollFactor.set();

    color = rect.color;
    add(lTri);
    add(rTri);
    add(rect);
  }

  public function adjustShit(){
    var scale = rect.height/rect.frameHeight;

    lTri.scale.x = scale;
    rTri.scale.x = scale;
    lTri.scale.y = rect.scale.y;
    rTri.scale.y = rect.scale.y;

    lTri.updateHitbox();
    rTri.updateHitbox();

    lTri.x = rect.x - lTri.width;
    rTri.x = rect.x + rect.width;

    lTri.y = rect.y-((lTri.height-rect.height)/2);
    rTri.y = rect.y-((rTri.height-rect.height)/2);
  }

  override function update(elapsed:Float){
    super.update(elapsed);
    adjustShit();
  }
}

class PauseButton extends FlxSpriteGroup {
  var textObj:FlxText;
  public var bg:PauseBG;
  public var bg2:PauseBG;
  public var bg3:PauseBG;
  public var bg4:PauseBG;
  public var targetY:Int = 0;
  public var xScale(default, set):Float = 1;
  public var yScale(default, set):Float = 1;

  function set_xScale(val:Float){
    textObj.scale.x = val;

    textObj.updateHitbox();
    var h:Int = Std.int(textObj.height + 20);
    var w:Int = Std.int(textObj.width + 20);
    if(h < 52)h=52;
    if(w < 157)w=157;
    bg.rect.setGraphicSize(Std.int(w), Std.int(h));
    bg.rect.updateHitbox();
    bg.y = textObj.y-((bg.rect.height-textObj.height)/2);

    bg2.rect.scale.x = bg.rect.scale.x;
    bg2.rect.scale.y = bg.rect.scale.y;
    bg2.rect.updateHitbox();

    bg3.rect.scale.x = bg.rect.scale.x;
    bg3.rect.scale.y = bg.rect.scale.y;
    bg3.rect.updateHitbox();

    bg4.rect.scale.x = bg.rect.scale.x;
    bg4.rect.scale.y = bg.rect.scale.y;
    bg4.rect.updateHitbox();

    bg.adjustShit();
    bg2.adjustShit();
    bg3.adjustShit();
    bg4.adjustShit();
    return xScale = val;
  }

  function set_yScale(val:Float){
    textObj.scale.y = val;

    textObj.updateHitbox();
    var h:Int = Std.int(textObj.height + 20);
    var w:Int = Std.int(textObj.width + 20);
    if(h < 52)h=52;
    if(w < 157)w=157;
    bg.rect.setGraphicSize(Std.int(w), Std.int(h));
    bg.rect.updateHitbox();
    bg.y = textObj.y-((bg.rect.height-textObj.height)/2);

    bg2.rect.scale.x = bg.rect.scale.x;
    bg2.rect.scale.y = bg.rect.scale.y;
    bg2.rect.updateHitbox();

    bg3.rect.scale.x = bg.rect.scale.x;
    bg3.rect.scale.y = bg.rect.scale.y;
    bg3.rect.updateHitbox();

    bg4.rect.scale.x = bg.rect.scale.x;
    bg4.rect.scale.y = bg.rect.scale.y;
    bg4.rect.updateHitbox();

    bg.adjustShit();
    bg2.adjustShit();
    bg3.adjustShit();
    bg4.adjustShit();
    return yScale = val;
  }

  override function set_x(val:Float){
    super.set_x(val);
    if(bg!=null){
      bg.adjustShit();
      bg2.adjustShit();
      bg3.adjustShit();
      bg4.adjustShit();
      set_xScale(xScale); // idk WHY i need to do this but I DO
    }
    return x;
  }

  override function set_y(val:Float){
    super.set_y(val);
    if(bg!=null){
      bg.adjustShit();
      bg2.adjustShit();
      bg3.adjustShit();
      bg4.adjustShit();
      set_yScale(yScale); // idk WHY i need to do this but I DO
    }

    return y;

  }

  public function new(x:Float, y:Float, text:String){
    super();
    bg = new PauseBG();

    textObj = new FlxText(0, 0, 0, text.toUpperCase(), 30);
		textObj.setFormat(Paths.font("Summer Square.otf"), 30, FlxColor.fromString("#eadaf2"), CENTER, FlxTextBorderStyle.OUTLINE,
			FlxColor.fromString("#8600c9"));
    textObj.scrollFactor.set();
    textObj.antialiasing=true;
    textObj.updateHitbox();
    var h:Int = Std.int(textObj.height + 20);
    var w:Int = Std.int(textObj.width + 20);
    if(h < 52)h=52;
    if(w < 350)w=350;
    bg.rect.setGraphicSize(Std.int(w), Std.int(h));
    bg.rect.updateHitbox();
    bg.y = textObj.y-((bg.rect.height-textObj.height)/2);

    bg2 = new PauseBG();
    bg2.rect.scale.x = bg.rect.scale.x;
    bg2.rect.scale.y = bg.rect.scale.y;
    bg2.rect.updateHitbox();
    bg2.y = bg.y;
    bg2.color = FlxColor.fromRGB(140, 0, 255);

    bg3 = new PauseBG();
    bg3.rect.scale.x = bg.rect.scale.x;
    bg3.rect.scale.y = bg.rect.scale.y;
    bg3.rect.updateHitbox();
    bg3.y = bg.y;
    bg3.color = FlxColor.fromRGB(54, 255, 0);

    bg4 = new PauseBG();
    bg4.rect.scale.x = bg.rect.scale.x;
    bg4.rect.scale.y = bg.rect.scale.y;
    bg4.rect.updateHitbox();
    bg4.y = bg.y;
    bg4.color = FlxColor.fromRGB(255, 237, 0);

    add(bg4);
    add(bg3);
    add(bg2);
    add(bg);
    add(textObj);
    y -= textObj.height/2;
    this.x = x;
    this.y = y;

    bg.adjustShit();
    bg2.adjustShit();
    bg3.adjustShit();
    bg4.adjustShit();

    xScale = xScale;
    yScale = yScale;
  }

  override function update(elapsed:Float){
    var lerpVal = 0.1 * elapsed/(1/120);
    if(targetY==0){
      bg2.x = FlxMath.lerp(bg2.x, bg.x + 3, lerpVal);
      bg2.y = FlxMath.lerp(bg2.y, bg.y + 3, lerpVal);
      bg3.x = FlxMath.lerp(bg3.x, bg2.x + 3, lerpVal);
      bg3.y = FlxMath.lerp(bg3.y, bg2.y + 3, lerpVal);
      bg4.x = FlxMath.lerp(bg4.x, bg3.x + 3, lerpVal);
      bg4.y = FlxMath.lerp(bg4.y, bg3.y + 3, lerpVal);
    }else{
      bg2.x = FlxMath.lerp(bg2.x, bg.x, lerpVal);
      bg2.y = FlxMath.lerp(bg2.y, bg.y, lerpVal);
      bg3.x = FlxMath.lerp(bg3.x, bg.x, lerpVal);
      bg3.y = FlxMath.lerp(bg3.y, bg.y, lerpVal);
      bg4.x = FlxMath.lerp(bg4.x, bg.x, lerpVal);
      bg4.y = FlxMath.lerp(bg4.y, bg.y, lerpVal);
    }
    super.update(elapsed);
  }
}
