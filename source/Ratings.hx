package;

typedef RatingsList =
{
	name:String,
	accuracy:Float
}

class Ratings
{
	public static var ratings:Array<RatingsList> = [
		{name: 'SS', accuracy: 100},
		{name: 'S', accuracy: 95},
		{name: 'A', accuracy: 90},
		{name: 'B', accuracy: 80},
		{name: 'C', accuracy: 70},
		{name: 'D', accuracy: 0}
	];

	public static var juds:Array<Float> = [16.5, 40.5, 73.5, 103.5, 127.5];

	public static function getRating(accuracy:Float)
	{
		var alreadyFound:Bool = false;
		var id:Int = 0;

		for (i in 0...ratings.length)
		{
			if (accuracy >= ratings[i].accuracy && !alreadyFound)
			{
				id = i;
				alreadyFound = true;
			}
		}

		return (ratings[id].name);
	}

	public static function calculateAccuracy(ratings:Array<Int>, misses:Int, totalNoteHits:Int)
	{
		var accuracy:Float = 0;
		var accuracyTotal:Float = 0;
		var accuracyList:Array<Float> = [100, 100, 66.67, 33.33, 16.66];
		for (i in 0...accuracyList.length)
			accuracyTotal += ratings[i] * accuracyList[i];
		accuracy = accuracyTotal / (totalNoteHits + misses);

		return accuracy;
	}
}
