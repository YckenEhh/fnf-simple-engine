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

    public static var juds:Array<Float> = [22.5, 54.5, 97.5, 127.5];

    public static function getRating(accuracy:Float){
        var curCheck:Int = 0;
        var alreadyFound:Bool = false;
        var id:Int = 0;

        for (i in 0...ratings.length){
            if (accuracy >= ratings[i].accuracy && !alreadyFound){
                id = i;
                alreadyFound = true;
            }
        }

        return(ratings[id].name);
    }
}
