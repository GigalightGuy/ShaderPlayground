Shader "Custom/Tessellation"
{
    Properties
    {
        _BaseColor ("Base Color", Color) = (1, 1, 1, 1)
        _WireframeColor ("Wireframe Color", Color) = (0, 0, 0, 1)
        _WireframeSmoothing ("Wireframe Smoothing", Range(0, 10)) = 1
        _WireframeThickness ("Wireframe Thickness", Range(0, 10)) = 1

        _TessellationUniform ("Tessellation Uniform", Range(1, 64)) = 1

        [KeywordEnum(Uniform, Edge)] _Tessellation ("Tessellation Mode", Float) = 0
        _TessellationEdgeLength ("Tessellation Edge Length", Range(5, 100)) = 50
    }

    SubShader
    {

        Pass 
        {
            CGPROGRAM

            #pragma target 4.6

            #pragma shader_feature _TESSELLATION_EDGE

            #pragma vertex tessellationVert
            #pragma fragment frag
            #pragma hull hull
            #pragma domain domain
            #pragma geometry geom

            #include "Wireframe.cginc"
            #include "Tessellation.cginc"

            ENDCG 
        }
    }
}
