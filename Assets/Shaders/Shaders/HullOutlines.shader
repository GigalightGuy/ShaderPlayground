Shader "Unlit/HullOutlines"
{
    Properties
    {
        _OutlineColor ("Outline Color", Color) = (0, 0, 0, 1)
        _OutlineThickness ("Outline thickness", Float) = 0.1
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

                float3 pos = mul(unity_ObjectToWorld, i.positionOS).xyz + _OutlineThickness * smoothNormal;

                pos = mul(unity_WorldToObject, float4(pos, 1)).xyz;

                o.positionCS = UnityObjectToClipPos(pos);

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
