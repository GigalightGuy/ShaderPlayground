Shader "MyAmazingShaders/CellShading"
{
	Properties
	{
		_Albedo ("Albedo ", Vector) = (1.0, 1.0, 1.0)
		_ShadowThreshold1 ("Threshold 1", Range(-1.0, 1.0)) = -0.3
		_ShadowColor1 ("Shadow Color 1", Vector) = (0.1, 0.1, 0.1)
		_ShadowThreshold2 ("Threshold 2", Range(-1.0, 1.0)) = 0.0
		_ShadowColor2 ("Shadow Color 2", Vector) = (0.3, 0.3, 0.3)
		_ShadowThreshold3 ("Threshold 3", Range(-1.0, 1.0)) = 0.3
		_ShadowColor3 ("Shadow Color 3", Vector) = (0.5, 0.5, 0.5)
	}

	SubShader
	{
		CGPROGRAM

		#pragma surface surf Lambert

		struct Input
		{
			float2 uv_Albedo;
		};

		fixed3 _Albedo;
		float _ShadowThreshold1;
		fixed3 _ShadowColor1;
		float _ShadowThreshold2;
		fixed3 _ShadowColor2;
		float _ShadowThreshold3;
		fixed3 _ShadowColor3;

		void surf(Input IN, inout SurfaceOutput o)
		{
			float dotRes = dot(_WorldSpaceLightPos0, o.Normal);

			if (dotRes < _ShadowThreshold1)
			{
				o.Emission = _ShadowColor1;
			}
			else if (dotRes < _ShadowThreshold2)
			{
				o.Emission = _ShadowColor2;
			}
			else if (dotRes < _ShadowThreshold3)
			{
				o.Emission = _ShadowColor3;
			}
			else
			{
				o.Emission = _Albedo;
			}

		}

		ENDCG
	}

	FallBack "Diffuse"
}
