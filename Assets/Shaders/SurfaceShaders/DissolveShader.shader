Shader "MyAmazingShaders/DissolveShader"
{
	Properties
	{
		_MainTex("Main Texture", 2D) = "defaulttexture" {}
		_DissolveTex("Mask Texture", 2D) = "defaulttexture" {}
		_DissolveAmount("Dissolve Amount", Range(0, 1)) = 0
	}

	SubShader
	{
		CGPROGRAM

		#pragma surface surf Lambert addshadow

		struct Input
		{
			float2 uv_MainTex;
		};

		sampler2D _MainTex;
		sampler2D _DissolveTex;
		float _DissolveAmount;

		void surf(Input IN, inout SurfaceOutput o)
		{
			o.Albedo = tex2D(_MainTex, IN.uv_MainTex).rgb;
			fixed3 dissolve = tex2D(_DissolveTex, IN.uv_MainTex).rgb * _DissolveAmount;

			if ((int)step(o.Albedo, dissolve))
			{
				discard;
			}
		}

		ENDCG
	}

	FallBack "Diffuse"
}
