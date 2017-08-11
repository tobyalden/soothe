package entities;

class Timer
{

    static var allTimers:Array<Timer> = new Array<Timer>();

    public var count:Int;
    public var duration:Int;

    public function new(duration:Int)
    {
        this.duration = duration;
        count = 0;
        allTimers.push(this);
    }

    public function restart()
    {
        count = duration;
    }

    public function percentComplete() {
        return count / duration;
    }

    public function isActive()
    {
        return count > 0;
    }

    public static function updateAll()
    {
        for(timer in allTimers)
        {
            /*trace(timer.count);*/
            if(timer.count > 0)
            {
                timer.count -= 1;
            }
        }
    }

}
