Shader "Custom/Volume"
{
    Properties
    {
        
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
