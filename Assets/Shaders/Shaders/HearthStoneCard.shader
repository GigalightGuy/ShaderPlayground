Shader "Custom/HearthStoneCard"
{
    Properties
    {
        _FrontTex ("Front Texture", 2D) = "white" {}
        _BackTex ("Back Texture", 2D) = "black" {}

        _BorderColor ("Border Color", Color) = (1, 1, 0)
        _BorderWidth ("Border Width", Range(0, 0.1)) = 0.05
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" "Queue" = "Transparent" }

        Blend SrcAlpha OneMinusSrcAlpha
        ZWrite Off

        Pass
        {

            CGPROGRAM

            #include "UnityCG.cginc"

            #pragma vertex vert
            #pragma fragment frag

            sampler2D _FrontTex;
            half4 _BorderColor;
            float _BorderWidth;

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

            Varyings vert(Attributes i)
            {
                Varyings o = (Varyings)0;

                i.positionOS.xyz *= (1 + _BorderWidth);

                o.positionCS = UnityObjectToClipPos(i.positionOS.xyz);
                o.uv = i.uv;

                return o;
            }

            half4 frag(Varyings i) : SV_TARGET
            {
                half4 col = tex2D(_FrontTex, i.uv * (1 + _BorderWidth) - ((1 + _BorderWidth) - 1) * 0.5);

                half mask = tex2D(_FrontTex, i.uv).a;

                col = lerp(_BorderColor, col, col.a);

                col.a *= mask;

                return col;
            }

            ENDCG
        }

        Pass
        {
            Cull Front

            CGPROGRAM

            #include "UnityCG.cginc"

            #pragma vertex vert
            #pragma fragment frag

            sampler2D _BackTex;

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

            Varyings vert(Attributes i)
            {
                Varyings o = (Varyings)0;

                o.positionCS = UnityObjectToClipPos(i.positionOS.xyz);
                o.uv = i.uv;

                return o;
            }

            half4 frag(Varyings i) : SV_TARGET
            {
                half4 col = tex2D(_BackTex, i.uv);

                return col;
            }

            ENDCG
        }
    }
}
