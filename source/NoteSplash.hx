package;

import flixel.FlxG;
import flixel.FlxSprite;
import haxe.io.Path;

class NoteSplash extends FlxSprite
{
	var colors:Array<String> = ['purple', 'blue', 'green', 'red'];

	public function new(x:Float, y:Float, noteData:Int = 0, type:String):Void
	{
		super(x, y);

		colors = Note.getColorLineByMania(PlayState.mania);

		frames = Paths.getSparrowAtlas('noteSplashes', 'shared');

		for (i in 0...colors.length){
			animation.addByPrefix('note${i}-0', 'note impact 1 ${colors[i]}', 24, false);
			animation.addByPrefix('note${i}-1', 'note impact 2 ${colors[i]}', 24, false);
		}

		setupNoteSplash(x, y, noteData, type);
	}

	public function setupNoteSplash(x:Float, y:Float, noteData:Int = 0, nWidth:Float = 110, type:String)
	{	
		setPosition(x - (51 * (nWidth / 66.5)), y - (55 * (nWidth / 66.5))); // ik fuck this system lmao
		alpha = 0.6;
		animation.play('note' + noteData + '-' + FlxG.random.int(0, 1), true);
		scale.set(Note.noteScale / 0.7, Note.noteScale / 0.7);
		updateHitbox();
	}

	override function update(elapsed:Float)
	{
		if (animation.curAnim.finished)
			kill();

		super.update(elapsed);
	}
}
