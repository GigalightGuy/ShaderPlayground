Shader "MyAmazingShaders/DrawTextureInPos"
{
	// Properties block where we define properties that we can access from the inspector
	// Does not directly affect the shader behaviour
	Properties
	{
		// Properties that we can set in the inspector per Material

		// Base color used where the texture is not being drawn
		_BaseColor ("Base Color", Vector) = (1, 1, 1)
		// Texture to draw in the hit point
		_SquareTex ("Square Texture", 2D) = "defaulttexture" {}
		// Size of the texture we drawing
		_SquareLength ("Square Length", Float) = 5
		// Property that controls rotation speed of the texture
		_RotationSpeed ("Texture Rotation Speed", Float) = 5

		// Properties to be set through code, so we use the HideInInspector attribute 
		// HideInInspector tells Unity to not display the property in the inspector

		// Integer that works as a bool so we can tell the shader when we should draw the texture
		[HideInInspector] _GotHit ("Got Hit", Integer) = 0
		// Center of the position where we should draw our texture (set with raycast through code)
		[HideInInspector] _SquareCenter ("Square Center", Vector) = (0, 0, 0)
	}

	// SubShader blocks can be used to have our shader run different code in different platforms ou render pipelines
	// For example we can have a shader with 2 SubShader blocks 
	// Where one runs for the Built In Render Pipeline
	// And the other runs in the Universal Pipeline
	// The same way we can have 1 SubShader for PCs and another for mobile devices
	SubShader
	{
		// Start shader code
		CGPROGRAM

		// surface tells Unity that this is a surface shader
		// surf tells Unity which function to call as the Surface Shader function
		// Lambert tells Unity to use Lambert shading for this Surface Shader
		#pragma surface surf Lambert

		// Input struct for the surf function that we can provide with Unity defined members
		// And Unity will fill the struct for us and pass it to our surf function
		struct Input
		{
			// Ask Unity for the transformed UVs for _SquareTex
			float2 uv_SquareTex;
			// Ask Unity for pixel worldPos
			float3 worldPos;
		};

		// Definition of shader variables
		// Properties need to be declared again here with the same name so the shader knows about them
		fixed3 _BaseColor;
		sampler2D _SquareTex;
		float _SquareLength;
		float _RotationSpeed;
		float3 _SquareCenter;
		int _GotHit;

		// Function that remaps the parameter value from (fromMin, fromMax) interval to (toMin, toMax) interval
		float map(float fromMin, float fromMax, float toMin, float toMax, float value)
		{			
			return (value - fromMin) / (fromMax - fromMin) * (toMax - toMin) + toMin;
		}

		// Function that applies a 2D rotation to a 2D position
		float2 rotate(float2 pos, float angle)
		{
			// Because UVs are 0, 0 in the lower left corner
			// We move our position by half a unit before rotating
			// So we can rotate it around the center of the UV space 
			// Instead of around the lower left corner
			pos -= float2(0.5, 0.5);
		
			// 1 axis rotation matrix
			float2x2 rotMat = {	cos(angle), -sin(angle),
								sin(angle),  cos(angle)};

			// Rotate position by angle by multiplying it with the matrix
			pos = mul(rotMat, pos);

			// Move the position back after rotation
			pos += float2(0.5, 0.5);

			return pos;
		}

		// Function called before Unity calculates lighting in a Surface Shader
		// We receive input from a Input struct that Unity feels with the data we ask for
		// We can change the final look of our shader by modifing the data in the SurfaceOutput struct
		// That struct is gonna get passed to the function that calculates lighting in Surface Shaders
		void surf(Input IN, inout SurfaceOutput o)
		{
			float halfLength = _SquareLength * 0.5;

			// Calculate limits for the quad
			float minX = _SquareCenter.x - halfLength;
			float maxX = _SquareCenter.x + halfLength;
			float minY = _SquareCenter.y - halfLength;
			float maxY = _SquareCenter.y + halfLength;

			// Check if _GitHit is true(1) 
			// And check if the current pixel's position is inside square
			if (_GotHit && 
				IN.worldPos.x <= maxX && 
				IN.worldPos.x >= minX &&
				IN.worldPos.y <= maxY && 
				IN.worldPos.y >= minY)
			{
				// Map pixel position from world space to (0, 1) interval inside square space
				float2 squareUVs;
				squareUVs.x = map(minX, maxX, 0, 1, IN.worldPos.x);
				squareUVs.y = map(minY, maxY, 0, 1, IN.worldPos.y);

				// Rotate custom uv coordinates over time
				squareUVs = rotate(squareUVs, _RotationSpeed * _Time.x);

				// Use custom rotated UVs to sample from the texture
				fixed4 sampledColor = tex2D(_SquareTex, squareUVs);

				// Mix between the base color and the texture based on the texture alpha
				// So we don't get black background where the texture has some transparency
				o.Albedo = lerp(_BaseColor, sampledColor.rgb, sampledColor.a);
			}
			else
			{
				// Just assign the base color if the pixel is outside of the square or object is not being hit
				o.Albedo = _BaseColor;
			}
		}

		// End shader code
		ENDCG
	}

	FallBack "Diffuse"
}
