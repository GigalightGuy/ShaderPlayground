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

	// The Fallback block specifies a shader to be displayed 
	// In case none of the subshaders in this shader are compatible with the current platform
	// That means that if we have a SubShader that only works for Universal Render Pipeline
	// And don't have any other SubShader available, the object will use the default Diffuse shader 
	// If we specify FallBack "Diffuse"
	FallBack "Diffuse"
}
