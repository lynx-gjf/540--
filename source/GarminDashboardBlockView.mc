import Toybox.System;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Activity;
import Toybox.Graphics;


/*!
    Bunny's extended dashboard Block for Garmin Edge

    @author Karoly Szabo (Bunny)
    @version 1.1.0
    @link https://github.com/bunnyhu/GarminDashboardBlock

    @note FONT_MEDIUM = garmin label, FONT_NUMBER_MEDIUM = garmin 2 lines num, FONT_NUMBER_HOT = garmin 1 line num
*/
class GarminDashboardBlockView extends WatchUi.DataField {
    //! speed multiplier km/mi
    private var _speedMod = 1;
    //! unit strings [dist, speed, icon dist, icon speed]
    private var _units as Array;
    //! Simu/Device padding
    private var _padding;
    //! All sensors data, always read from this
    private var _sensors;
    //! standard data color
    private var _colorDataText as Array = [
        "speed", "distance", "timer", "cadence", "avgSpeed", "hrNum",
    ];
    //! label color
    private var _colorLabelText as Array = [
        "cadLabel", "distanceIcon", "timerIcon", "cadenceIcon", "speedIcon",
    ];
    //! reAlign texts
    private var _alignText as Array = [
        "cadLabel", "hrNum",
    ];

    // colors for day/dark mode
    private var baseColors = {
        :sunNumColor => Graphics.COLOR_BLACK,
        :sunLabelColor => 0x777777,         // Graphics.COLOR_DK_GRAY,

        :darkNumColor => Graphics.COLOR_WHITE,
        :darkLabelColor => 0x999999,
    };


    //! Reset _sensors[] to 0 or null
    function resetSensors() {
        _sensors = {
            :speed       => 0,
            :avgSpeed    => 0,
            :timer       => 0,
            :distance    => 0.0f,
            :cadence     => 0,
            :avgCadence  => 0,
            :hr          => 0,
        };
    }


    function initialize() {
        DataField.initialize();
        resetSensors();
        _padding = new Align();
        if ( System.getDeviceSettings().distanceUnits == System.UNIT_METRIC) {
            _speedMod = 3.6;
            _units = ["km", "km/h", "C", "D"];
        } else {
            _speedMod = 2.23694;
            _units = ["mi", "mi/h", "F", "E"];
        }
    }


    //! Running when layout change or first load
    function onLayout(dc as Dc) as Void {
        var screenWidth = System.getDeviceSettings().screenWidth;
        var screenHeight = System.getDeviceSettings().screenHeight;
        var fieldWidth = dc.getWidth();
        var fieldHeight = dc.getHeight();

        if (fieldWidth >= (screenWidth/2) ) {
            if (fieldHeight>=(screenHeight/2)) {
                View.setLayout(Rez.Layouts.layout2x2(dc));
            } else if (fieldHeight>=(screenHeight/4)) {
                View.setLayout(Rez.Layouts.layout2x2(dc));
            } else {
                View.setLayout(Rez.Layouts.layout2x1(dc));
            }
        } else {
            View.setLayout(Rez.Layouts.layout1x1(dc));
        }

        setDrawableText("distanceLabel", (WatchUi.loadResource(Rez.Strings.distanceLabel) as String) + " "+ _units[0]);
        setDrawableText("timerLabel", WatchUi.loadResource(Rez.Strings.timerLabel) as String);
        setDrawableText("cadLabel", WatchUi.loadResource(Rez.Strings.cadenceLabel) as String);
        setDrawableText("distanceIcon", _units[2]);
        setDrawableText("speedIcon", _units[3]);

        // realign all text where need
        for (var f=0; f<_alignText.size(); f++) {
            var elem = findDrawableById(_alignText[f]);
            if (elem instanceof Text) {
                _padding.reAlign(elem);
            }
        }
    }


    //!  update class var with fresh data like every second
    function compute(info as Activity.Info) as Void {
        resetSensors();
        if (info.currentSpeed != null) {
            _sensors[:speed] = info.currentSpeed * _speedMod;
        }
        if (info.averageSpeed != null) {
            _sensors[:avgSpeed] = info.averageSpeed * _speedMod;
        }
        if (info.timerTime != null) {
            _sensors[:timer] = info.timerTime;
        }
        if (info.elapsedDistance != null) {
            _sensors[:distance] = info.elapsedDistance;
        }
        if (info.currentCadence != null) {
            _sensors[:cadence] = info.currentCadence;
        }
        if (info.averageCadence != null) {
            _sensors[:avgCadence] = info.averageCadence;
        }
        if (info.currentHeartRate != null) {
            _sensors[:hr] = info.currentHeartRate;
        }
    }


    //!  Update screen every second if datafield visible
    function onUpdate(dc as Dc) as Void {
        var numColor;
        var labelColor;

        if (getBackgroundColor() == Graphics.COLOR_BLACK) {
            numColor = baseColors[:darkNumColor];
            labelColor = baseColors[:darkLabelColor]; // Graphics.COLOR_DK_GRAY
        } else {
            numColor = baseColors[:sunNumColor];
            labelColor = baseColors[:sunLabelColor]; // Graphics.COLOR_LT_GRAY;
        }
        (View.findDrawableById("Background") as Text).setColor(getBackgroundColor());

        // colorize the labels and datas because night mode
        var colors = [[_colorLabelText, labelColor], [_colorDataText, numColor]];
        for (var c=0; c<colors.size(); c++) {
            for (var f=0; f<colors[c][0].size(); f++) {
                var elem = findDrawableById(colors[c][0][f]);
                if (elem instanceof Text) {
                    elem.setColor(colors[c][1]);
                }
            }
        }
        setDrawableText("speed", formatSpeed());
        setDrawableText("avgSpeed", formatAvgSpd());
        setDrawableText("cadence", formatCadence());
        setDrawableText("distance", formatDistance(_sensors[:distance]));
        setDrawableText("timer", formatTime(_sensors[:timer]));

        setDrawableText("hrNum", _sensors[:hr].format("%u"));

        View.onUpdate(dc);  // update the layouts, do it BEFORE extra drawing !!!!!!!
    }


    //! Format current speed without comparison coloring.
    function formatSpeed() as String {
        if (_sensors[:speed] < 100) {
            return _sensors[:speed].format("%0.1f");
        }
        return Math.round(_sensors[:speed]).format("%0.0f");
    }


    //! Average Speed with indicator arrow if the decimal is near to change
    function formatAvgSpd() as String {
        if (_sensors[:avgSpeed] == null) {
            return "";
        }
        if (_sensors[:avgSpeed] < 100) {
            var index = "";
            if (_sensors[:avgSpeed] > 0) {
                if ( (Math.round(_sensors[:avgSpeed] * 100).toNumber() % 10) >= 8 ) {
                    index = "[";    // UP 91
                } else if ( (Math.round(_sensors[:avgSpeed] * 100).toNumber() % 10) <= 2 ) {
                    index = "]";    // DOWN 93
                }
            }
            return _sensors[:avgSpeed].format("%0.1f") + index;
        } else {
            return Math.round(_sensors[:avgSpeed]).format("%0.0f");
        }
    }


    //!  Delta indexed cadence number
    function formatCadence() as String {
        if (_sensors[:cadence] == null) {
            return "";
        }

        var index = "";
        if ((_sensors[:avgCadence] != null) && (_sensors[:cadence] > 0)) {
            if (_sensors[:cadence] >= _sensors[:avgCadence]) {
                index = "[";    // UP
            } else {
                index = "]";    // DOWN
            }
        }

        return index + _sensors[:cadence].format("%0.0f");
    }


    //!  Dinamic time formatting
    function formatTime(seconds) as String {
        if ((seconds == null) || (seconds==0)) {
            return "-";
        }
        seconds = seconds / 1000;

        var h = seconds / 3600;
        var m = (seconds % 3600) / 60;
        var s = seconds % 60;
        if (h > 0) {
            return h.format("%d") +":" + m.format("%02d") + ":" + s.format("%02d");
        } else {
            return m.format("%d") + ":" + s.format("%02d");
        }
    }


    //!  Dinamic distance decimal formatting
    function formatDistance(pDistance) as String {
        if (pDistance == null) {
            return "-";
        }
        pDistance = pDistance / 1000;
        if (pDistance >= 100) {
            return pDistance.format("%.1f");
        } else {
            return pDistance.format("%.2f");
        }
    }


    //! Safe setText(), set only if the id is valid
    function setDrawableText(pId, pValue) {
        var elem = View.findDrawableById(pId);
        if (elem instanceof Text) {
            elem.setText(pValue);
        }
    }


}
