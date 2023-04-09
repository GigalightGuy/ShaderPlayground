Shader "MyAmazingShaders/RimColor"
{
	// Properties block where we define properties that we can access from the inspector
	// Does not directly affect the shader behaviour
	Properties
	{
		// Base color used where Rim effect is not strong
		_BaseColor ("Base Color", Color) = (1.0, 1.0, 1.0, 1.0)
		// Color used where Rim effect is stronger
		_RimColor ("Rim Color", Color) = (0.0, 0.0, 0.0, 1.0)
		// Expoent used to make Rim effect sharper and thinner
		_RimColorPower ("Rim Color Power", Float) = 0.1
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
		// alpha tells Unity that our shader can have transparency
		#pragma surface surf Lambert alpha

		// Input struct for the surf function that we can provide with Unity defined members
		// And Unity will fill the struct for us and pass it to our surf function
		struct Input 
		{
			// Ask Unity for the view direction vector
			float3 viewDir;
        };

		// Definition of shader variables
		// Properties need to be declared again here with the same name so the shader knows about them
		fixed4 _BaseColor;
		fixed4 _RimColor;
		float _RimColorPower;

		// Function called before Unity calculates lighting in a Surface Shader
		// We receive input from a Input struct that Unity feels with the data we ask for
		// We can change the final look of our shader by modifing the data in the SurfaceOutput struct
		// That struct is gonna get passed to the function that calculates lighting in Surface Shaders
		void surf(Input IN, inout SurfaceOutput o)
		{
			// Get dot product between the world space normal and the view direction
			// Dot product result goes from -1 to 1 if both vectors are of unit length
			// Both these vectors are provided by Unity and are already normalized as they represent directions
			// Value is 1 when both vectors have the same direction
			// And -1 when they point in opposite directions
			float dotP = dot(IN.viewDir, o.Normal);

			// We want the Rim effect to be stronger when the angle between the view and normal is closer to 90 degrees
			// So we do 1 - dotP and then we use the expoent to make a sharper transition from base color to rim color
			// Go to the editor and change the _RimColorPower value to see how it affects the effect
			float rimIntensity = pow(1 - dotP, _RimColorPower);

			// For the final color we lerp between the base color and the rim color based on the rim effect intensity
			fixed3 finalColor = lerp(_BaseColor.rgb, _RimColor.rgb, rimIntensity);
			
			// Here we are giving more transparency to pixels that have less rim intensity
			// So that the parts of the object that are facing us directly are more transparent
			o.Alpha = smoothstep(0.0, 0.9, rimIntensity);

			// We assign the final color to the Emission so our effect does not get affected by Surface Shader Lighting
			o.Emission = finalColor;
		}

		// End shader code
		ENDCG
	}

	FallBack "Diffuse"
}
