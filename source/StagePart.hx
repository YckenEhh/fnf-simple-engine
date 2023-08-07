package;

import openfl.display.BitmapData;
import flixel.FlxSprite;
#if sys
import sys.io.File;
import sys.FileSystem;
#end

typedef StagePartData = {
    positionX:Int,
    positionY:Int,
    scaleX:Float,
    scaleY:Float,
    scrollFactor:Array<Float>
}

class StagePart extends FlxSprite
{
    public function new(curStage:String, partNum:Int)
    {
        super();

        #if sys
        loadGraphic(BitmapData.fromFile('mods/stages/$curStage/$partNum.png'));

        trace ('loading image at mods/stages/$curStage/$partNum.png');

        if (FileSystem.exists('mods/stages/$curStage/' + partNum + '.json'))
        {
            var toParse:String = File.getContent('mods/stages/$curStage/' + partNum + '.json');
            var _json:StagePartData = cast haxe.Json.parse(toParse);
            trace(_json);
    
            x = _json.positionX;
            y = _json.positionY;
            scale.x = _json.scaleX;
            scale.y = _json.scaleY;
            // scrollFactor.x = scrollFactor[0];
            // scrollFactor.y = scrollFactor[1];
            updateHitbox();
        }
        else
        {
            screenCenter();
            scale.x = 1;
            scale.y = 1;
            // scrollFactor.x = 0;
            // scrollFactor.y = 0;
            updateHitbox();
        }
        
        #end
    }
}