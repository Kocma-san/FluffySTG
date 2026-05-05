
#define MOVE_TOWARDS(c, t, maxDelta) ( (c) + sign((t)-(c))*min((maxDelta), abs((t)-(c))) )

#define SATURATION_CHANGE_SPEED 3
#define HEART_RATE_CHANGE_SPEED 40
#define MAX_HEART_RATE 215
#define STROKE_VOLUME_CHANGE_SPEED 1
