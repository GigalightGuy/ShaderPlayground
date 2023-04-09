Shader "MyAmazingShaders/myFristShader"
{
   Properties
   {
		_mainColor("A cor Bro!", Color) = (1,1,1,1)
		_transparency("Dev..ups... Transparencia",Range (0, 1)) = 1
   }

   SubShader{
	 CGPROGRAM
		#pragma surface surf Lambert alpha

		struct Input {
		float2 uvMainTex;
		};
		
		fixed3 _mainColor;
		fixed _transparency;

		void surf(Input IN, inout SurfaceOutput o) {
			o.Albedo = _mainColor.rgb;
			o.Alpha = 1-_transparency;
		}

		ENDCG
		}
		FallBack "Diffuse"
}

