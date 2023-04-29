Shader "Custom/Volume"
{
    Properties
    {
        _Density ("Density", Float) = 0.1
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
            ZTest Less
            Cull Off

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
