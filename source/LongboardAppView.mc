using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Lang;
using Toybox.Graphics;
using Toybox.ActivityRecording;
using Toybox.Activity;

var session = null;
var stepsStart = 0;


class LongboardAppDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onMenu() {
//        WatchUi.pushView(new Rez.Menus.MainMenu(), new LongboardAppMenuDelegate(), WatchUi.SLIDE_UP);
        if( Toybox has :ActivityRecording ) {
            if( ( session == null ) || ( session.isRecording() == false ) ) {
                session = ActivityRecording.createSession({:name=>"Longboard", :sport=>ActivityRecording.SPORT_FITNESS_EQUIPMENT});
                session.start();
                WatchUi.requestUpdate();
                stepsStart = ActivityMonitor.getInfo().steps;
            }
            else if( ( session != null ) && session.isRecording() ) {
                session.stop();
                session.save();
                session = null;
                WatchUi.requestUpdate();
            }
        }
        return true;
    }
     
    // Detect Menu button input
    function onKey(keyEvent) {
        System.println(keyEvent.getKey()); // e.g. KEY_MENU = 7
        return true;
    }

}


class LongboardAppView extends WatchUi.View {


    var posnInfo = null;
    

    function initialize() {
        View.initialize();
    }

    // Load your resources here
    function onLayout(dc) {
//        setLayout(Rez.Layouts.MainLayout(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
    }
    
    function drawBar(dc, string, y, percent, color) {
        var width = dc.getWidth() / 5 * 4;
        var x = dc.getWidth() / 10;

        if (percent > 1) {
            percent = 1.0;
        }

        dc.setColor(color, color);
        dc.fillRectangle(x, y, width * percent, 10);
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.drawRectangle(x, y, width, 10);
        dc.setPenWidth(1);

        var font = Graphics.FONT_SMALL;

        dc.drawText(x, y - Graphics.getFontHeight(font) - 3, font, string, Graphics.TEXT_JUSTIFY_LEFT);
    }

    // Update the view
    function onUpdate(dc) {
        // Call the parent onUpdate function to redraw the layout
//        View.onUpdate(dc);
  // Set background color
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(0, 0, dc.getWidth(), dc.getHeight());
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_WHITE);
        dc.drawText(dc.getWidth()/2, 0, Graphics.FONT_XTINY, "M:"+System.getSystemStats().usedMemory, Graphics.TEXT_JUSTIFY_CENTER);
        
        var info = Activity.getActivityInfo();
        

        if( Toybox has :ActivityRecording ) {
            // Draw the instructions
            if( ( session == null ) || ( session.isRecording() == false ) ) {
                dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_WHITE);
                dc.drawText(dc.getWidth() / 2, dc.getHeight() / 2, Graphics.FONT_MEDIUM, "Press Menu to\nStart Recording", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
            }
            else if( ( session != null ) && session.isRecording() ) {
                var x = dc.getWidth() / 2;
                var y = dc.getFontHeight(Graphics.FONT_XTINY);
                dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_WHITE);
                dc.drawText(x, y, Graphics.FONT_MEDIUM, "Recording...", Graphics.TEXT_JUSTIFY_CENTER);
                y += dc.getFontHeight(Graphics.FONT_MEDIUM);
                dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_WHITE);
                dc.drawText(x, y, Graphics.FONT_MEDIUM, "Press Menu again\nto Stop and Save\nthe Recording", Graphics.TEXT_JUSTIFY_CENTER);
            }
        }
        // tell the user this sample doesn't work
        else {
            dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_WHITE);
            dc.drawText(dc.getWidth() / 2, dc.getWidth() / 2, Graphics.FONT_MEDIUM, "This product doesn't\nhave FIT Support", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        }
        
        dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_BLACK);
        
        // Time
        if (info has :elapsedTime) {
            // var stepsPercent = info.steps.toFloat() / info.stepGoal;
            dc.drawText(110, 10, Graphics.FONT_MEDIUM, "Time: " + info.elapsedTime, Graphics.TEXT_JUSTIFY_CENTER);
            //drawBar(dc, "Steps", dc.getHeight() / 4, stepsPercent, Graphics.COLOR_GREEN);
        }
        
        // Total Distance -> elapsedDistance
        if (info has :elapsedDistance) {
        	var dist = info.elapsedDistance;
        	
        	if(dist == null) {
        		dist = 0;
        	}
            // var stepsPercent = info.steps.toFloat() / info.stepGoal;
            dc.drawText(10, 55, Graphics.FONT_MEDIUM, "Dist: " + dist, Graphics.TEXT_JUSTIFY_LEFT);
            //drawBar(dc, "Steps", dc.getHeight() / 4, stepsPercent, Graphics.COLOR_GREEN);
        }
        
        // Total Steps
        // var stepsPercent = info.steps.toFloat() / info.stepGoal;
        var stepCount = ActivityMonitor.getInfo().steps;
        dc.drawText(110, 55, Graphics.FONT_MEDIUM, "Steps: " + (stepCount - stepsStart), Graphics.TEXT_JUSTIFY_LEFT);
        //drawBar(dc, "Steps", dc.getHeight() / 4, stepsPercent, Graphics.COLOR_GREEN);
        
        
        // Heart Rate -> currentHeartRate
        if (info has :currentHeartRate) {
        	var currentHeartRate = info.currentHeartRate;
        	
        	if(currentHeartRate == null) {
        		currentHeartRate = 0;
        	}
        	
            // var stepsPercent = info.steps.toFloat() / info.stepGoal;
            dc.drawText(10, 115, Graphics.FONT_LARGE, "HR: " + currentHeartRate, Graphics.TEXT_JUSTIFY_LEFT);
            //drawBar(dc, "Steps", dc.getHeight() / 4, stepsPercent, Graphics.COLOR_GREEN);
        }
        
        // speed -> currentSpeed
        if (info has :currentSpeed) {
            // var stepsPercent = info.steps.toFloat() / info.stepGoal;
            dc.drawText(110, 115, Graphics.FONT_LARGE, "Speed: " + info.currentSpeed, Graphics.TEXT_JUSTIFY_LEFT);
            //drawBar(dc, "Steps", dc.getHeight() / 4, stepsPercent, Graphics.COLOR_GREEN);
        }
                
        
        // calories -> calories
        if ((info has :calories)) {
	    	var calories = info.calories;
        	
        	if(calories == null) {
        		calories = 0;
        	}
        	
        
            // var stepsPercent = info.steps.toFloat() / info.stepGoal;
            dc.drawText(110, 180, Graphics.FONT_MEDIUM, "Cal: " + calories, Graphics.TEXT_JUSTIFY_CENTER);
            //drawBar(dc, "Steps", dc.getHeight() / 4, stepsPercent, Graphics.COLOR_GREEN);
        }
     }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    }
    
    //! Stop the recording if necessary
    function stopRecording() {
        if( Toybox has :ActivityRecording ) {
            if( session != null && session.isRecording() ) {
                session.stop();
                session.save();
                session = null;
                WatchUi.requestUpdate();
            }
        }
    }    
     
    function setPosition(info) {
        posnInfo = info;
        WatchUi.requestUpdate();
    }

}
