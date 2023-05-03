Shader "Unlit/HullOutlines"
{
    Properties
    {
        _OutlineColor ("Outline Color", Color) = (0, 0, 0, 1)
        _OutlineThickness ("Outline thickness", Float) = 0.1

        [Toggle(_AnimateOutline)] _Animate ("Animate Outline", Float) = 0
    }

    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
            "Queue" = "Geometry"
        }

        Pass
        {
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct Attributes
            {
                float4 positionOS : POSITION;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
            };

            Varyings vert(Attributes i)
            {
                Varyings o = (Varyings)0;

                o.positionCS = UnityObjectToClipPos(i.positionOS);

                return o;
            }

            half4 frag(Varyings i) : SV_TARGET
            {
                return 1;
            }

            ENDCG
        }

        Pass 
        {
            Cull Front

            CGPROGRAM

            #pragma shader_feature _AnimateOutline

            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 smoothNormalOS : TEXCOORD1;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
            };

            half4 _OutlineColor;
            float _OutlineThickness;

            Varyings vert(Attributes i)
            {
                Varyings o = (Varyings)0;

                float3 smoothNormal = UnityObjectToWorldNormal(i.smoothNormalOS);

                float finalOutlineThickness;
                #if defined(_AnimateOutline)
                    finalOutlineThickness = _OutlineThickness * (1 + sin(_Time.y));
                #else
                    finalOutlineThickness = _OutlineThickness;
                #endif

                float3 pos = mul(unity_ObjectToWorld, i.positionOS).xyz + finalOutlineThickness * smoothNormal;

                o.positionCS = UnityWorldToClipPos(pos);

                return o;
            }

            half4 frag(Varyings i) : SV_TARGET
            {
                return _OutlineColor;
            }

            ENDCG
        }
    }
}
