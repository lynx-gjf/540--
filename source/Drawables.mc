import Toybox.Lang;
import Toybox.Application;
import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.UserProfile;

/*  *************************************************************
    Datafield background color drawable
    *************************************************************
*/
class Background extends WatchUi.Drawable {
    hidden var mColor as ColorValue;

    function initialize() {
        var dictionary = {
            :identifier => "Background"
        };
        Drawable.initialize(dictionary);
        mColor = Graphics.COLOR_WHITE;
    }


    function setColor(color as ColorValue) as Void {
        mColor = color;
    }


    function draw(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_TRANSPARENT, mColor);
        dc.clear();
    }
}

//! Heart rate zone bar v2
//! show the hightest 3 zone
class HRZoneBar extends WatchUi.Drawable {
    /*
        USAGE:
        <drawable class="HRZoneBar" id="pulseBar">
            <param name="locX">1</param>
            <param name="locY">1</param>
            <param name="width">15</param>
            <param name="height">75</param>
            <param name="arrowSize">10</param>
        </drawable>
    */
    //! actual heart rate
    var hr = null;
    //! background color
    var bgColor = Graphics.COLOR_WHITE;
    //! heartRate Zones
    private var _hrZones as Array = [];
    //! HRZ graphic data [[height, color]]
    private var _hrZonesGraph as Array = [
        [0, 0xb1c9ea],
        [1, 0xb1c9ea],
        [2, 0xb1c9ea],
        [3, 0xb1c9ea],
        [4, 0x13ac13],
        [5, 0xff0000],
    ];
    //! 1 HR pulse pixel
    private var _hrPixel as Float = 3.00f;
    //! indicator arrow size
    private var _arrowSize = 10;
    //! indicator offset, 1/5 width
    private var _arrowOffset = 3;
    //! bottom left
    private var bottomY;


    function initialize(options) {
        Drawable.initialize(options);
        setOptions(options);
        _hrZones = UserProfile.getHeartRateZones(UserProfile.getCurrentSport());
        if (_hrZones.size() != 6 ) {
            _hrZones = [1,2,3,4,5,6];
        }
        _hrPixel =  height / (_hrZones[5]-_hrZones[2]).toFloat();
        _hrZonesGraph[3][0] = (_hrZones[3]-_hrZones[2])* _hrPixel;
        _hrZonesGraph[4][0] = (_hrZones[4]-_hrZones[3])* _hrPixel;
        _hrZonesGraph[5][0] = (_hrZones[5]-_hrZones[4])* _hrPixel;
        _arrowOffset = Math.floor( width / 5 );
        bottomY = locY+height;
    }


    //! Set options
    function setOptions( options ) {
        if (options[:hr] != null) { hr = options[:hr]; }
        if (options[:background] != null) { bgColor = options[:background]; }
        if (options[:arrowSize] != null) { _arrowSize = options[:arrowSize]; }

    }


    //! Get zone from heart rate
    function getZone(_hr) as Number {
        for (var f=0; f<=4; f++) {
            if ((_hr>=_hrZones[f]) && (_hr<=_hrZones[f+1])) {
                return f;
            }
        }
        return 5;
    }

    function draw(dc as Dc) as Void {
        /*  *************************************************************
            Garmin min: 65 max: 181
            91-108, 109-126, 127-144, 145-162, 163-180,
            91,108,126,144,162,180
        */
        if ((hr == null) || (hr<25)) {
            return;
        }
        var _hr = hr;
        // show only between the top 3 zone, no more no less HR
        if (_hr > _hrZones[5]) {
            _hr = _hrZones[5];
        } else if (_hr < _hrZones[2]) {
            _hr = _hrZones[2];
        }
        var _cursor = locY;
        for (var f=5; f>=3; f--) {
            if (_hr > _hrZones[f-1]) {
                dc.setColor( _hrZonesGraph[f][1] , Graphics.COLOR_TRANSPARENT);
                dc.fillRectangle(locX, _cursor, width, _hrZonesGraph[f][0]);
            }
            _cursor += _hrZonesGraph[f][0];
        }
        _cursor = locY;
        dc.setPenWidth(2);
        dc.setColor( Graphics.COLOR_BLACK , Graphics.COLOR_TRANSPARENT);
        for (var f=5; f>=3; f--) {
            _cursor += _hrZonesGraph[f][0];
            if (_hr > _hrZones[f-1]) {
                dc.drawLine(locX, _cursor, locX+width, _cursor);
            }

        }

        var hrY = Math.floor( _hrPixel * (_hr - _hrZones[2]) );
        if ( hrY>height ) {    hrY = width;  }
        if ( hrY<0 ) {    hrY = 0;  }
        // Actual HR indicator triangle
        if (bgColor == Graphics.COLOR_BLACK) {
            dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
        } else {
            dc.setColor(Graphics.COLOR_DK_RED, Graphics.COLOR_TRANSPARENT);
        }
        var indicatorBaseX = locX+width-_arrowOffset;
        var indicatorBaseY = bottomY - hrY;
        dc.fillPolygon([
            [indicatorBaseX, indicatorBaseY],
            [indicatorBaseX+_arrowSize, indicatorBaseY-(_arrowSize/2)],
            [indicatorBaseX+_arrowSize, indicatorBaseY+(_arrowSize/2)]
        ]);
    }
}