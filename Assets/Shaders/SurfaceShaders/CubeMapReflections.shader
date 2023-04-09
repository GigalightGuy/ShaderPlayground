Shader "MyAmazingShaders/CubeMapReflections"
{
	Properties
	{
		_CubeTex ("Cube Map", Cube) = "defaulttexture" {}
	}

	SubShader
	{
		CGPROGRAM

		#pragma surface surf Lambert

		struct Input 
		{
			float3 worldRefl;
        };

		samplerCUBE _CubeTex;

		void surf(Input IN, inout SurfaceOutput o)
		{
			o.Emission = texCUBE(_CubeTex, IN.worldRefl).rgb;
		}

		ENDCG
	}

	FallBack "Diffuse"
}
