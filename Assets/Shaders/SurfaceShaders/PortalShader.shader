Shader "MyAmazingShaders/PortalShader"
{
	Properties
	{
		_MainTex("Main Texture", 2D) = "defaulttexture" {}
		_MaskTex("Mask Texture", 2D) = "defaulttexture" {}
	}

	SubShader
	{
		CGPROGRAM

		#pragma surface surf Lambert alpha

		struct Input
		{
			float2 uv_MainTex;
			float2 uv_MaskTex;
		};

		sampler2D _MainTex;
		sampler2D _MaskTex;

		void surf(Input IN, inout SurfaceOutput o)
		{
			fixed3 albedo = tex2D(_MainTex, IN.uv_MainTex).rgb;
			fixed mask = tex2D(_MaskTex, IN.uv_MaskTex).a;

			o.Albedo = albedo;
			o.Alpha = mask;


		}

		ENDCG
	}

	FallBack "Diffuse"
}
