Shader "Custom/Stencil"
{
    Properties
    {
        [Header(Stencil)]
		_Stencil ("Stencil ID [0;255]", Float) = 0
		_ReadMask ("ReadMask [0;255]", Int) = 255
		_WriteMask ("WriteMask [0;255]", Int) = 255
		[Enum(UnityEngine.Rendering.CompareFunction)] _StencilComp ("Stencil Comparison", Int) = 3
		[Enum(UnityEngine.Rendering.StencilOp)] _StencilOp ("Stencil Operation", Int) = 0
		[Enum(UnityEngine.Rendering.StencilOp)] _StencilFail ("Stencil Fail", Int) = 0
		[Enum(UnityEngine.Rendering.StencilOp)] _StencilZFail ("Stencil ZFail", Int) = 0

        [Header(ZBuffer)]
        [Enum(Off,0,On,1)] _ZWrite ("ZWrite", Int) = 1
		[Enum(UnityEngine.Rendering.CompareFunction)] _ZTest ("ZTest", Int) = 4

        [Header(Blend)]
        [Enum(UnityEngine.Rendering.BlendMode)] _BlendSrc ("Blend mode Source", Int) = 5
        [Enum(UnityEngine.Rendering.BlendMode)] _BlendDst ("Blend mode Destination", Int) = 10
    }

    SubShader
    {
        Stencil
        {
            Ref [_Stencil]
			ReadMask [_ReadMask]
			WriteMask [_WriteMask]
			Comp [_StencilComp]
			Pass [_StencilOp]
			Fail [_StencilFail]
			ZFail [_StencilZFail]
        }

        ZWrite [_ZWrite]
        ZTest [_ZTest]

        Blend [_BlendSrc] [_BlendDst]

        CGPROGRAM

            #pragma surface surf Lambert

		    struct Input
		    {
		    	float2 uv_Albedo;
		    };

		    void surf(Input IN, inout SurfaceOutput o)
		    {
                o.Albedo = 1;
		    }

        ENDCG
    }
}
