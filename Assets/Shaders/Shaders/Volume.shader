Shader "Custom/Volume"
{
    Properties
    {
        _Color ("Color", Color) = (0.5, 0.5, 0.5, 1)
        _Density ("Density", Float) = 0.1
        _LargeStep ("Large Step", Range(0.1, 10)) = 0.2
        _SmallStep ("Small Step", Range(0.01, 1)) = 0.01
        _MaxDist ("Max Distance", Float) = 20
    }

    SubShader
    {
        Tags
        {
            "RenderType" = "Transparent" "Queue" = "Transparent"
        }


        Pass 
        {
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            ZTest Always
            Cull Front

            CGPROGRAM

            #pragma target 3.0

            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            #include "Volume.cginc"

            ENDCG 
        }
    }
}
