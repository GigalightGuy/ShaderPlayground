Shader "MyAmazingShaders/Zebruh"
{
	Properties
	{
		_Frequency ("Frequency", Range(0, 10)) = 1
	}

	SubShader
	{
		CGPROGRAM

		#pragma surface surf Lambert

		struct Input
		{
			float3 viewDir;
		};

		// Function that uses a sin function to get a wave
		// And a conditional to output 0 or 1 when the wave is negative or positive
		// Which is one of various ways to get a repeating squared wave function
		float squareWave(float a, float f)
		{
			return sin(a * f) > 0 ? 1 : 0;
		}

		float _Frequency;

		void surf(Input IN, inout SurfaceOutput o)
		{
			float dotP = dot(IN.viewDir, o.Normal);

			o.Albedo = squareWave(10 * dotP, _Frequency);
		}

		ENDCG
	}

	FallBack "Diffuse"
}
