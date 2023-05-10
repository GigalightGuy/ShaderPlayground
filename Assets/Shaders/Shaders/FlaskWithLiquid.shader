Shader "Unlit/FlaskWithLiquid"
{
    Properties
    {
        _GlassColor ("Glass Color", Color) = (1, 1, 1, 0.5)
        _GlassThickness ("Glass Thickness", Range(0.01, 0.35)) = 0.1

        _LiquidColor ("Liquid Color", Color) = (1, 1, 0, 1)
        _FillAmount ("Fill Amount", Range(0, 1)) = 1
    }

    SubShader
    {
        Pass
        {
            Tags
            {
                "RenderType" = "Opaque"
                "Queue" = "Geometry"
            }

            Cull Off

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;

                float3 positionNoTranslationWS : TEXCOORD0;
            };

            float _GlassThickness;

            half4 _LiquidColor;
            float _FillAmount;

            Varyings vert(Attributes i)
            {
                Varyings o = (Varyings)0;

                float3 pos = i.positionOS.xyz - _GlassThickness * i.normalOS;
                o.positionCS = UnityObjectToClipPos(pos);
                o.positionNoTranslationWS = mul((float3x3)unity_ObjectToWorld, pos);

                return o;
            }

            half4 frag(Varyings i) : SV_TARGET
            {
                float h = i.positionNoTranslationWS.y * 0.5 + 0.5;
                if (h > _FillAmount) discard;

                return _LiquidColor;
            }

            ENDCG
        }

        Pass
        {
            Tags
            {
                "RenderType" = "Transparent"
                "Queue" = "Transparent"
            }

            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;

                float3 normalWS : TEXCOORD0;
                float3 viewDirWS : TEXCOORD1;
            };

            half4 _GlassColor;

            Varyings vert(Attributes i)
            {
                Varyings o = (Varyings)0;

                o.positionCS = UnityObjectToClipPos(i.positionOS.xyz);
                o.normalWS = UnityObjectToWorldNormal(i.normalOS);

                o.viewDirWS = normalize(WorldSpaceViewDir(i.positionOS));

                return o;
            }

            half4 frag(Varyings i) : SV_TARGET
            {
                float fresnel = pow(1 - saturate(dot(i.normalWS, i.viewDirWS)), 3);
                float dotP = (dot(i.normalWS, _WorldSpaceLightPos0.xyz) + 1) * 0.5;

                half4 col = _GlassColor;
                col.rgb *= dotP;
                col *= 0.2 + fresnel * 0.8;

                return col;
            }

            ENDCG
        }
    }
}
