Shader "MyAmazingShaders/Spiral"
{
	Properties
	{
		_DummyTex ("Ignore this", 2D) = "defaulttexture" {}
	}

	SubShader
	{
		CGPROGRAM

		#pragma surface surf Lambert

		struct Input
		{
			float2 uv_DummyTex;
			float3 viewDir;
		};

		float squareWave(float a, float f)
		{
			return sin(a * f) > 0 ? 1 : 0;
		}

		sampler2D _DummyTex;

		#define PI 3.141592654

		void surf(Input IN, inout SurfaceOutput o)
		{
			float2 centeredUVs = IN.uv_DummyTex - float2(0.5, 0.5);

			float r = length(centeredUVs);

			float theta = atan2(centeredUVs.y, centeredUVs.x);

			o.Emission = (frac(2.5 * theta / PI + 7.0 * pow(r, 0.4) - 50.0 * _Time.x)) < 0.5 ? float3(1.0, 1.0, 1.0) : float3(0.0, 0.0, 0.0);
		}

		ENDCG
	}

	FallBack "Diffuse"
}
