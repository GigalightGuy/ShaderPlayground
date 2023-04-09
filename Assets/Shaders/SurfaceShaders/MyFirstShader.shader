Shader "MyAmazingShaders/MyFirstShader"
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

	FallBack "Diffuse"
}
