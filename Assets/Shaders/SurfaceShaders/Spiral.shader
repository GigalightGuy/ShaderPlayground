Shader "MyAmazingShaders/Spiral"
{
	// Properties block where we define properties that we can access from the inspector
	// Does not directly affect the shader behaviour
	Properties
	{
		// This texture is not used, we just use it to get the UV coordinates for the shader
		_DummyTex ("Ignore this", 2D) = "defaulttexture" {}
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
			float2 uv_DummyTex;
			float3 viewDir;
		};

		float squareWave(float a, float f)
		{
			return sin(a * f) > 0 ? 1 : 0;
		}

		// Definition of shader variables
		// Properties need to be declared again here with the same name so the shader knows about them
		sampler2D _DummyTex;

		// Constant value for PI
		#define PI 3.141592654

		// Function called before Unity calculates lighting in a Surface Shader
		// We receive input from a Input struct that Unity feels with the data we ask for
		// We can change the final look of our shader by modifing the data in the SurfaceOutput struct
		// That struct is gonna get passed to the function that calculates lighting in Surface Shaders
		void surf(Input IN, inout SurfaceOutput o)
		{
			// Center UV coordinates by subtracting 0.5 in both x and y
			float2 centeredUVs = IN.uv_DummyTex - float2(0.5, 0.5);

			// Getting length of UV coordinate vector
			// We are doing this after centering the UVs to be (0, 0) at the center
			// So we get the distance of the current pixel to the center of the UV space
			float r = length(centeredUVs);

			// We get angle from vector direction
			float theta = atan2(centeredUVs.y, centeredUVs.x);

			// Using the frac function, we can get repeating slices with the angle theta and a time offset to give it movement
			// We passing the color to Emission so the result is not affected by lighting
			// We could avoid this by overriding the Surface Shader lighting function or by using a simple Shader
			o.Emission = (frac(2.5 * theta / PI + 7.0 * pow(r, 0.4) - 50.0 * _Time.x)) < 0.5 ? float3(1.0, 1.0, 1.0) : float3(0.0, 0.0, 0.0);
		}

		// End shader code
		ENDCG
	}

	FallBack "Diffuse"
}
