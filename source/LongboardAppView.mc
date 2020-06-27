using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Lang;
using Toybox.Graphics;
using Toybox.ActivityRecording;
using Toybox.Activity;

var session = null;
var stepsStart = 0;


// This is the menu input delegate for the main menu of the application
class MenuDelegate extends WatchUi.Menu2InputDelegate {

    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item) {
        if( item.getId().equals("resume") ) {
            if (session != null) {
            	if (!session.isRecording()) {
            		session.start();
        		}
            }	
	        // close menu
	        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);            
        } 
        else if ( item.getId().equals("save") ) {
	        // When the check menu item is selected, push a new menu that demonstrates
	        // left and right checkbox menu items
	        if (session != null) {
	        	if (session.isRecording()) {
	        		session.stop();
	    		}
	        	session.save();
	        	session = null;
	        }	
	        
	        // close menu
	        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
	        // close app
	        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        }
        else if( item.getId().equals("discard") ) {      
            var discardMenu = new WatchUi.Menu2({:title=>"Discard?"});
            discardMenu.addItem(new WatchUi.MenuItem("No", null, "cancel", null));
            discardMenu.addItem(new WatchUi.MenuItem("Yes", null, "discard", null));
			WatchUi.pushView(
			    discardMenu,
			    new DiscardConfirmationDelegate(),
			    WatchUi.SLIDE_IMMEDIATE
			);
        } else {
            WatchUi.requestUpdate();
        }
    }

    function onBack() {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }
}


// This is the menu input delegate for the main menu of the application
class DiscardConfirmationDelegate extends WatchUi.Menu2InputDelegate {

    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item) {
        if( item.getId().equals("discard") ) {
            if (session != null) {
            	if (session.isRecording()) {
            		session.stop();
        		}
            	session.discard();
            	session = null;
        	}
	        // close dialog
	        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
	        // close menu
	        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
	        // close app
	        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        } else {        
	        // close dialog
	        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        } 
    }

    function onBack() {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }
}


class LongboardAppDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    // Detect Menu button input
    function onKey(keyEvent) {    
    	var key = keyEvent.getKey();
    	
    	if(KEY_ENTER == key) {    		
	 		if( Toybox has :ActivityRecording ) {
	            if( ( session == null ) || ( session.isRecording() == false ) ) {
	                session = ActivityRecording.createSession({:name=>"Longboard", :sport=>ActivityRecording.SPORT_FITNESS_EQUIPMENT});
	                session.start();
	                WatchUi.requestUpdate();
	                stepsStart = ActivityMonitor.getInfo().steps;
	            }
	            else if( ( session != null ) && session.isRecording() ) {                       	
	    	        // Generate a new Menu with a drawable Title
					var menu = new WatchUi.Menu2({:title=>"Longboarding"});
					
					// Add menu items for demonstrating toggles, checkbox and icon menu items
					menu.addItem(new WatchUi.MenuItem("Resume", null, "resume", null));
					menu.addItem(new WatchUi.MenuItem("Save", null, "save", null));
					menu.addItem(new WatchUi.MenuItem("Discard", null, "discard", null));
					WatchUi.pushView(menu, new MenuDelegate(), WatchUi.SLIDE_UP );
	            }
            }
        }
        return true;
    }
}


class LongboardAppView extends WatchUi.View {

    var posnInfo = null;   
   	var iconTime = null;
   	var iconHR = null;
   	var iconSteps = null;
   	var iconDistance = null;
   	var iconSpeed = null;
	var iconCalories = null;
	
    var timer;

    function initialize() {
        View.initialize();
        iconTime = WatchUi.loadResource(Rez.Drawables.icon_clock);
        iconHR = WatchUi.loadResource(Rez.Drawables.icon_heartrate);
        iconSteps = WatchUi.loadResource(Rez.Drawables.icon_footprints);
        iconDistance = WatchUi.loadResource(Rez.Drawables.icon_distance);
        iconSpeed = WatchUi.loadResource(Rez.Drawables.icon_speed);
        iconCalories = WatchUi.loadResource(Rez.Drawables.icon_calories);
        
    	timer = new Timer.Timer();
    }

    // Load your resources here
    function onLayout(dc) {
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
        timer.start(method(:onTimer), 1000, true);
    }
    
    // Update the view
    function onUpdate(dc) {
        dc.clear();
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(0, 0, dc.getWidth(), dc.getHeight());
      
        var info = Activity.getActivityInfo();        
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        
        // Time
        if (info has :elapsedTime) {      
        	dc.drawBitmap(55, 20, iconTime);
        	
        	var hh = info.elapsedTime / 3600000;
        	var remainder = info.elapsedTime % 3600000;
        	var mm = remainder / 60000;
        	remainder = remainder % 60000;
        	var ss = remainder / 1000;        	
        	
        	var timeString = hh.format("%02d") + ":" + mm.format("%02d") + ":" + ss.format("%02d"); 
        	
            dc.drawText(75, 10, Graphics.FONT_MEDIUM, timeString, Graphics.TEXT_JUSTIFY_LEFT);
        }
        
        // Total Distance -> elapsedDistance
        if (info has :elapsedDistance) {
        	var dist = info.elapsedDistance;
        	
        	if(dist == null) {
        		dist = 0;
        	}
        	
        	if(dist < 1000) {
        		dist = dist.format("%0.0f"); // + "m";
    		} else {
    			dist = (dist / 1000).format("%0.0f"); //  + "km";
			}
        	
        	dc.drawBitmap(7, 70, iconDistance);
            dc.drawText(24, 60, Graphics.FONT_NUMBER_MEDIUM, dist, Graphics.TEXT_JUSTIFY_LEFT);
        }

		// Steps
        dc.drawBitmap(120, 70, iconSteps);
        var stepCount = ActivityMonitor.getInfo().steps;
        dc.drawText(143, 60, Graphics.FONT_NUMBER_MEDIUM, "" + (stepCount - stepsStart), Graphics.TEXT_JUSTIFY_LEFT);
        
        
        // Heart Rate -> currentHeartRate
        if (info has :currentHeartRate) {
        	var currentHeartRate = info.currentHeartRate;
        	
        	if(currentHeartRate == null) {
        		currentHeartRate = 0;
        	}
        	
        	dc.drawBitmap(7, 135, iconHR);
	        dc.drawText(24, 125, Graphics.FONT_NUMBER_MEDIUM, currentHeartRate.format("%d"), Graphics.TEXT_JUSTIFY_LEFT); 
        }
        
        // Speed -> currentSpeed
        if (info has :currentSpeed) {          
            dc.drawBitmap(120, 135, iconSpeed);
            var speedString = (info.currentSpeed * 3.6).format("%0.1f");
            dc.drawText(143, 125, Graphics.FONT_NUMBER_MEDIUM, speedString, Graphics.TEXT_JUSTIFY_LEFT); 
        }
        
        // Calories -> calories
        if ((info has :calories)) {
	    	var calories = info.calories;
        	
        	if(calories == null) {
        		calories = 0;
        	}
        	
        	dc.drawBitmap(100, 200, iconCalories);
            dc.drawText(125, 190, Graphics.FONT_MEDIUM, "" + calories, Graphics.TEXT_JUSTIFY_CENTER);
        }
     }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
        timer.stop();
    }
     
    
    function onTimer() {
        //Kick the display update
        WatchUi.requestUpdate();
    }
}
 
 