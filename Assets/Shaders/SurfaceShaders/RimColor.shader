Shader "MyAmazingShaders/RimColor"
{
	Properties
	{
		_BaseColor ("Base Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_RimColor ("Rim Color", Color) = (0.0, 0.0, 0.0, 1.0)
		_RimColorPower ("Rim Color Power", Float) = 0.1
	}

	SubShader
	{
		CGPROGRAM

		#pragma surface surf Lambert alpha

		struct Input 
		{
			float3 viewDir;
        };

		fixed4 _BaseColor;
		fixed4 _RimColor;
		float _RimColorPower;

		fixed3 Mix(fixed3 colA, fixed3 colB, float amount)
		{
			return (1 - amount) * colA + amount * colB;
		}

		void surf(Input IN, inout SurfaceOutput o)
		{
			float dotP = dot(IN.viewDir, o.Normal);

			float rimIntensity = pow(1 - dotP, _RimColorPower);

			fixed3 finalColor = Mix(_BaseColor.rgb, _RimColor.rgb, rimIntensity);
			
			o.Alpha = smoothstep(0.0, 0.9, rimIntensity);

			o.Emission = finalColor;
		}

		ENDCG
	}

	FallBack "Diffuse"
}
