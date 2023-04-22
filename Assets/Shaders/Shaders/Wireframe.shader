Shader "Custom/Wireframe"
{
    Properties
    {
        _BaseColor ("Base Color", Color) = (1, 1, 1, 1)
        _WireframeColor ("Wireframe Color", Color) = (0, 0, 0, 1)
        _WireframeSmoothing ("Wireframe Smoothing", Range(0, 10)) = 1
        _WireframeThickness ("Wireframe Thickness", Range(0, 10)) = 1
    }

    SubShader
    {

        Pass 
        {
            CGPROGRAM

            #pragma target 4.0

            #pragma vertex vert
            #pragma fragment frag
            #pragma geometry geom

            #include "Wireframe.cginc"

            ENDCG 
        }
    }
}
