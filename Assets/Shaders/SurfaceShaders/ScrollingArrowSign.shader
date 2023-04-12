Shader "MyAmazingShaders/ScrollingArrowSign"
{
	Properties
	{
		_MainTex ("Scrolling Texture", 2D) = "defaulttexture" {}

		[HideInInspector] _UVOffset ("UV Offset", Float) = 0
	}

	SubShader
	{
		CGPROGRAM

		#pragma surface surf Lambert alpha

		struct Input
		{
			float2 uv_MainTex;
		};

		sampler2D _MainTex;
		float _UVOffset;

		void surf(Input IN, inout SurfaceOutput o)
		{
			float2 modifiedUVs = IN.uv_MainTex;
			modifiedUVs.x = IN.uv_MainTex.x - (_UVOffset % 2) - 1;

			fixed4 sampledColor = tex2D(_MainTex, modifiedUVs);

			o.Albedo = sampledColor.rgb;
			o.Alpha = sampledColor.a;
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
