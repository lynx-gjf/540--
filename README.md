# Bunny's dashboard block
![GitHub Release](https://img.shields.io/github/v/release/bunnyhu/GarminDashboardBlock)
![GitHub Release Date](https://img.shields.io/github/release-date/bunnyhu/GarminDashboardBlock)

**Dashboard block for Garmin Edge**

This is a garmin Edge cycling computer data field. Its purpose is to display more data in one place, overcoming the limitations of the factory one-block-one-data split. I didn't want a full screen solution though, because I use other ConnectIQ data fields already from other developers (like smart bike lights), which unfortunately can't be inserted into a custom screen.

My data field displays 3 sizes of slightly different data, adapted to my own needs. The 2x2 big size is my main choice, the 2x1 line I use under the map, and the 1x1 is just why not make it.

## Supported and tested devices
Edge Explore 2 , Edge 1040, Edge 1050

## Supported, but not tested devices
Edge 540, Edge 840, Edge MTB

*On the Edge 540/840/MTB the 1x1 and 2x1 size is limited for two dataline.*

*Some screen layout slightly smaller than other similar and the datafield not fit in. I fit my datafield for the common size. If it is looks oversized, please try to use it in a different layout. Problematic layout maybe the 3 and 4 for my 2x2 size datafield.*

## Adapted data

| Data | Comment | 2x2 | 2x1 | 1x1 |
| --- | --- | --- | --- | --- |
| current speed | with color support (see below) | X | X* | X* |
| average speed | | X | | |
| current cadence | | X | X* | |
| climb % | negative if slope | X | X | X* |
| heart rate & zones | colorized bar | X | | |
| compass | (see below) | X | | |
| wind direction | included into compass | X | | |
| radar speed | with color support | X | X | |
| distance travelled | | | X | X* |
| moving time | | | X | X* |

*The * means that data is not avaiable on every device.*

### Enhanced data fields

**current speed** Its color marked: Green if the current speed is the same or faster than the average speed. Yellow if it is slower but not more than 1km/h or 1Mi/h, and orange if it is even slower than that. Also there is a triangled decimal dot, that show our speed is faster or slower than average (for color blinds or just simple a second sign).

**climb %** It is calculated from measured data, if slope the number is negative.

**current cadence** A small triangle show how the current cadence is for the average. UP if faster, DOWN if slower.

**average speed** After the speed numbers it indicates when the speed is approaching the shift point: 0.02 / below (downward triangle) or 0.08 / above (upward triangle).

**heart rate zones** The highest 3 color coded zone bar. The zone limits from your Garmin HR zones. On the top, there is the actual HR with number.

**compass , wind , radar speed** Those data using the same place and changing dinamic.
* Default is the compass. If there is weather informations the wind direction also appers on the circle around the compass with purple section. If there is fresh wind data - we using is, anyway if we are offline and  it is more than one hour old, it start use the hourly forecast. All information from official garmin weather data, the accurate of information is depend of that.
* If we have radar and wehicle(s) arriving, it show the fastest one's speed. If the speed moderate the number in a green circle, the ok speed means yellow and the fast one with red circle. After the wehicle pass, we turn back to compass.
* In the 2x1 datafield there is only radar information, if a vehicle arriving.

## Garmin IQ store
https://apps.garmin.com/en-US/apps/bf65ec33-0655-485c-83eb-bdecebcd23d4

## Project home
https://github.com/bunnyhu/GarminDashboardBlock

## History
* v1.2.0  - Edge 540, 840, MTB support. 2025. jul 12.
* v1.1.1  - Edge 1050 small improvements 2025. jul 10.
* v1.1.0  - Edge 1050 support, precise compass and HRZ bar, add radar speed to 2x1 size, average speed indicator 2025. jul 6.
* v1.0.5  - Color correction  2025. maj 1.
* v1.0.4  - Initial release   2025. april 3.
