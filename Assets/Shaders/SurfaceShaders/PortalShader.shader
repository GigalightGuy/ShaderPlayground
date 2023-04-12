Shader "MyAmazingShaders/PortalShader"
{
	// Properties block where we define properties that we can access from the inspector
	// Does not directly affect the shader behaviour
	Properties
	{
		// Render Target texture to be displayed in the object
		_MainTex("Main Texture", 2D) = "defaulttexture" {}
		// Grey scale Mask texture to give portal custom format
		_MaskTex("Mask Texture", 2D) = "defaulttexture" {}
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
			// Ask Unity for the transformed UVs for _MainTex
			float2 uv_MainTex;
			// Ask Unity for the transformed UVs for _MaskTex
			float2 uv_MaskTex;
		};

		// Definition of shader variables
		// Properties need to be declared again here with the same name so the shader knows about them
		sampler2D _MainTex;
		sampler2D _MaskTex;

		// Function called before Unity calculates lighting in a Surface Shader
		// We receive input from a Input struct that Unity feels with the data we ask for
		// We can change the final look of our shader by modifing the data in the SurfaceOutput struct
		// That struct is gonna get passed to the function that calculates lighting in Surface Shaders
		void surf(Input IN, inout SurfaceOutput o)
		{
			// Sample _MainTex with UVs provided by Unity in the Input struct
			fixed3 albedo = tex2D(_MainTex, IN.uv_MainTex).rgb;
			// Sample _MaskTex with UVs provided by Unity in the Input struct
			fixed mask = tex2D(_MaskTex, IN.uv_MaskTex).a;

			// Assign sampled color from _MainTex to the Albedo
			o.Albedo = albedo;
			// Assign sampled alpha from _MaskTex to the Alpha so we can get some transparency for the portal format
			o.Alpha = mask;
		}

		// End shader code
		ENDCG
	}

	// The Fallback block specifies a shader to be displayed 
	// In case none of the subshaders in this shader are compatible with the current platform
	// That means that if we have a SubShader that only works for Universal Render Pipeline
	// And don't have any other SubShader available, the object will use the default Diffuse shader 
	// If we specify FallBack "Diffuse"
	FallBack "Diffuse"
}
