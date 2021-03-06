function [prof, price] = PVprofs(capacity)

% Time of day (January average)	Hourly Data: DC array power (W)
JanPV = [
0;
0;
0;
0;
0;
0;
0;
11.3742;
88.6818;
182.911;
271.616;
338.617;
345.314;
335.025;
283.749;
181.18;
50.2097;
0.604091;
0;
0;
0;
0;
0;
0;
]/capacity;

AprPV = [
%     Time of day (April average)	Hourly Data: DC array power (W)
0;
0;
0;
0;
0;
9.88665;
67.8089;
197.381;
307.427;
413.473;
496.432;
556.38;
570.617;
549.796;
442.147;
341.736;
212.452;
80.4812;
15.3717;
0;
0;
0;
0;
0;
]/capacity;

JulPV = [
% Time of day (July average)	Hourly Data: DC array power (W)
0;
0;
0;
0;
2.94552;
29.7936;
95.9164;
223.331;
346.074;
454.213;
552.564;
579.055;
560.1;
536.048;
501.345;
401.749;
272.935;
144.278;
40.4245;
10.7728;
0;
0;
0;
0;

]/capacity;

OctPV = [
%     Time of day (October average)	Hourly Data: DC array power (W)
0;
0;
0;
0;
0;
0;
19.7531;
107.102;
244.384;
323.55;
386.338;
408.893;
394.333;
373.422;
295.647;
200.97;
78.6309;
8.39492;
0;
0;
0;
0;
0;
0;

]/capacity;

SummerPrice = [
    39.11;
    36.92;
    31.9;
    27.19;
    23.35;
    26.54;
    23.9;
    18.84;
    11.59;
    22.52;
    25.57;
    40.34;
    40.33;
    41.52;
    41.4;
    44.8;
    57.04;
    61.88;
    47.19
    50.35;
    48.55;
    43.44;
    40.42;
    44.79;
]/1000;

WinterPrice = [
   37.2700;
   35.6400;
   35.7200;
   10.0300;
   29.8100;
   22.2100;
   34.7500;
   63.7700;
   35.6800;
   62.0000;
   51.4500;
   51.4500;
   37.3400;
   38.8600;
   41.8400;
   39.6700;
   34.6800;
   41.0100;
   40.3600;
   40.9000;
   39.1400;
   38.8000;
   35.5900;
   28.8400;
]/1000;

price = [WinterPrice SummerPrice];
prof = [JanPV AprPV JulPV OctPV];