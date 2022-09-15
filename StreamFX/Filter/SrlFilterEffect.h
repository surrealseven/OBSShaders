// Get common shader defs
#include "..\SrlCommon.h"

////////////////////////////////////////////////////////////////////////////////
// Always provided by OBS

uniform float4x4 ViewProj<
	bool automatic = true;
	string name = "View Projection Matrix";
> ;

////////////////////////////////////////////////////////////////////////////////
// Provided by Stream Effects

uniform float4 Time<
	// x: Time in seconds since the source was created.
	// y: Time in the current second.
	// z: Total seconds passed since the source was created.
	// w: Reserved
	bool automatic = true;
	string name = "Time Array";
	string description = "A float4 value containing the total time, rendering time and the time since the last tick. The last value is a random number between 0 and 1.";
> ;

uniform float4 ViewSize<
	// x: Width
	// y: Height
	// z: 1. / Width
	// w: 1. / Height
	bool automatic = true;
> ;

uniform float4x4 Random<
	// float4 perInst = float4(Random[0][0], Random[1][0], Random[2][0], Random[3][0]);
	// float4 perActivation = float4(Random[0][1], Random[1][1], Random[2][1], Random[3][1]);
	// float4 perFrame1 = float4(Random[0][2], Random[1][2], Random[2][2], Random[3][2]);
	// float4 perFrame2 = float4(Random[0][3], Random[1][3], Random[2][3], Random[3][3]);
	bool automatic = true;
	string name = "Random Array";
	string description = "A float4x4 value containing random values between 0 and 1";
> ;

uniform texture2d InputA<
	// input texture
	bool automatic = true;
> ;

////////////////////////////////////////////////////////////////////////////////

