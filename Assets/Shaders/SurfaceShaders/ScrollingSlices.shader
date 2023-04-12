Shader "MyAmazingShaders/ScrollingSlices"
{
	Properties
	{
		_FirstTex ("First Texture", 2D) = "defaulttexture" {}
		_SecondTex ("Second Texture", 2D) = "defaulttexture" {}

		_ScrollSpeed ("Scroll Speed", Range(1, 1000)) = 10
		_SliceFrequency ("Slice Frequency", Range(0, 100)) = 10
	}

	SubShader
	{
		// Start shader code
		CGPROGRAM

		#pragma surface surf Lambert 

		struct Input
		{
			float3 worldPos;

			float2 uv_FirstTex;
		};

		sampler2D _FirstTex;
		sampler2D _SecondTex;

		float _ScrollSpeed;
		float _SliceFrequency;

		void surf(Input IN, inout SurfaceOutput o)
		{
			if (sin((IN.worldPos.y + _Time.x * _ScrollSpeed) * _SliceFrequency) > 0)
			{
				o.Albedo = tex2D(_FirstTex, IN.uv_FirstTex).rgb;
			}
			else
			{
				o.Albedo = tex2D(_SecondTex, IN.uv_FirstTex).rgb;
			}
		}

		ENDCG
	}

	// The Fallback block specifies a shader to be displayed 
	// In case none of the subshaders in this shader are compatible with the current platform
	// That means that if we have a SubShader that only works for Universal Render Pipeline
	// And don't have any other SubShader available, the object will use the default Diffuse shader 
	// If we specify FallBack "Diffuse"
	FallBack "Diffuse"
}
