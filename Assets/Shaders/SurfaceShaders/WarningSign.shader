Shader "MyAmazingShaders/WarningSign"
{
	Properties
	{
		_MainTex ("Flashing Texture", 2D) = "defaulttexture" {}
		_MaxDistance ("Distance Weight", Float) = 10

		[HideInInspector] _TargetDistance ("Distance to target", Float) = 0
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
		float _MaxDistance;
		float _TargetDistance;

		void surf(Input IN, inout SurfaceOutput o)
		{
			fixed4 sampledColor = tex2D(_MainTex, IN.uv_MainTex);
			float intensityModifier = max(_MaxDistance - _TargetDistance, 0);

			o.Albedo = sampledColor.rgb;
			o.Alpha = sampledColor.a;

			o.Emission = sampledColor.rgb * intensityModifier;
		}

		ENDCG
	}

	FallBack "Diffuse"
}
