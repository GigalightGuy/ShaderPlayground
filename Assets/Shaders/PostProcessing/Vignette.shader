Shader "Custom/Vignette"
{
    Properties
    {
        [HideInInspector]
        _MainTex ("Main Texture", 2D) = "white" {}

        _VignetteWidth ("Vignette Width", Range(0, 1)) = 0.1
        _VignetteColor ("Vignette Color", Color) = (0, 0, 0)

    }

    SubShader
    {
        Pass
        {
            CGPROGRAM

            #include "UnityCG.cginc"

            #pragma shader_feature _TEST

            #pragma vertex vert 
            #pragma fragment frag

            struct Attributes
            {
                float4 positionOS : POSITION;

                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;

                float2 uv : TEXCOORD0;
            };

            sampler2D _MainTex;

            float _VignetteWidth;
            half3 _VignetteColor;

            float DFRoundBox(float2 p, float2 s, float r)
            {
                float2 h = abs(p) - s;
                return max(length(max(h, 0)) - r, 0);
            }

            Varyings vert(Attributes i)
            {
                Varyings o = (Varyings)0;

                o.positionCS = UnityObjectToClipPos(i.positionOS);
                o.uv = i.uv;

                return o;
            }

            half4 frag(Varyings i) : SV_TARGET
            {
                half4 col = tex2D(_MainTex, i.uv);

                float mask = DFRoundBox(i.uv - 0.5, 0.5 - _VignetteWidth * 0.5, 0.3);

                col.rgb = lerp(col.rgb, _VignetteColor, mask);

                return col;
            }

            ENDCG
        }
    }
}
