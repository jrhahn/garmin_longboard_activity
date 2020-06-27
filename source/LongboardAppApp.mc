using Toybox.Application;
using Toybox.Position;

class LongboardAppApp extends Application.AppBase {
	
	var view;

    function initialize() {
        AppBase.initialize();
    }

    //! onStart() is called on application start up
    function onStart(state) {
        Position.enableLocationEvents(Position.LOCATION_CONTINUOUS, method(:onPosition));
    }

    //! onStop() is called when your application is exiting
    function onStop(state) {
        Position.enableLocationEvents(Position.LOCATION_DISABLE, method(:onPosition));
    }

    function onPosition(info) {
        view.setPosition(info);
    }
    
    // Return the initial view of your application here
    function getInitialView() {
    	view = new LongboardAppView();
        return [ view, new LongboardAppDelegate() ];
    }
}
