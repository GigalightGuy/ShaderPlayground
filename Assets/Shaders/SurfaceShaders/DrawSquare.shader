Shader "MyAmazingShaders/DrawSquare"
{
	Properties
	{
		_BaseColor ("Base Color", Vector) = (1, 1, 1)
		_SquareTex ("Square Texture", 2D) = "defaulttexture" {}
		_SquareLength ("Square Length", Float) = 5
		_RotationSpeed ("Texture Rotation Speed", Float) = 5

		[HideInInspector] _GotHit ("Got Hit", Integer) = 0
		[HideInInspector] _SquareCenter ("Square Center", Vector) = (0, 0, 0)
	}

	SubShader
	{
		CGPROGRAM

		#pragma surface surf Lambert

		struct Input
		{
			float2 uv_SquareTex;
			float3 worldPos;
		};

		fixed3 _BaseColor;
		sampler2D _SquareTex;
		float _SquareLength;
		float _RotationSpeed;
		float3 _SquareCenter;
		int _GotHit;

		float map(float fromMin, float fromMax, float toMin, float toMax, float value)
		{			
			return (value - fromMin) / (fromMax - fromMin) * (toMax - toMin) + toMin;
		}

		float2 rotate(float2 pos, float angle)
		{

			pos -= float2(0.5, 0.5);
		
			float2x2 rotMat = {	cos(angle), -sin(angle),
								sin(angle),  cos(angle)};

			pos = mul(rotMat, pos);

			pos += float2(0.5, 0.5);

			return pos;
		}

		void surf(Input IN, inout SurfaceOutput o)
		{
			float halfLength = _SquareLength * 0.5;

			float minX = _SquareCenter.x - halfLength;
			float maxX = _SquareCenter.x + halfLength;
			float minY = _SquareCenter.y - halfLength;
			float maxY = _SquareCenter.y + halfLength;

			if (_GotHit && 
				IN.worldPos.x <= maxX && 
				IN.worldPos.x >= minX &&
				IN.worldPos.y <= maxY && 
				IN.worldPos.y >= minY)
			{
				float2 squareUVs;
				squareUVs.x = map(minX, maxX, 0, 1, IN.worldPos.x);
				squareUVs.y = map(minY, maxY, 0, 1, IN.worldPos.y);

				//squareUVs = rotate(squareUVs, _RotationSpeed * _Time.x);

				fixed4 sampledColor = tex2D(_SquareTex, squareUVs);

				o.Albedo = lerp(_BaseColor, sampledColor.rgb, sampledColor.a);
			}
			else
			{
				o.Albedo = _BaseColor;
			}
		}

		ENDCG
	}

	FallBack "Diffuse"
}
