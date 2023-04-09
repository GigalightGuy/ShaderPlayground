Shader "MyAmazingShaders/Lambert"
{
	Properties
	{
		_Albedo("Main Texture", 2D) = "defaulttexture" {}
	}

	SubShader
	{
		CGPROGRAM

		#pragma surface surf Lambert

		struct Input
		{
			float2 uv_MainTex;
		};

		sampler2D _Albedo;

		void surf(Input IN, inout SurfaceOutput o)
		{
			
		}

		ENDCG
	}

	FallBack "Diffuse"
}
