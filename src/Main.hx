import com.haxepunk.Engine;
import com.haxepunk.HXP;
import scenes.*;

class Main extends Engine
{

	override public function init()
	{
#if debug
		HXP.console.enable();
#end
		HXP.fullscreen = true;
		HXP.screen.smoothing = false;
		HXP.scene = new GameScene();
	}

	public static function main() { new Main(); }

}
