Shader "Custom/CubeGrid"
{
    Properties
    {

    }

    SubShader
    {
        Pass
        {
            CGPROGRAM

            #include "UnityCG.cginc"

            #pragma target 4.5

            #pragma vertex vert 
            #pragma fragment frag

            struct Attributes
            {
                float4 positionOS : POSITION;

                uint instanceId : SV_INSTANCEID;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float3 positionWS : TEXCOORD0;
            };

            StructuredBuffer<float3> _Positions;

            float _Spacing;

            void ConfigureProcedural(uint instanceId)
            {
                float3 position = _Positions[instanceId];

                unity_ObjectToWorld = 0;
                unity_ObjectToWorld._m03_m13_m23_m33 = float4(position, 1.0);
                unity_ObjectToWorld._m00_m11_m22 = _Spacing;
            }

            Varyings vert(Attributes i)
            {
                Varyings o = (Varyings)0;

                ConfigureProcedural(i.instanceId);

                o.positionWS = mul(unity_ObjectToWorld, i.positionOS);
                o.positionCS = UnityWorldToClipPos(o.positionWS);


                return o;
            }

            half4 frag(Varyings i) : SV_TARGET
            {
                return half4(i.positionWS, 1);
            }

            ENDCG
        }
    }
}
