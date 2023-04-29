Shader "Custom/Pump"
{
    Properties
    {
        _Tint ("Tint", Color) = (1, 1, 1, 1)
        _MainTex ("Main Texture", 2D) = "white" {}

        _InflateStrength ("Inflate Amount", Range(0, 1)) = 0
        _PumpFrequency ("Pump Frequency", Float) = 3.5
        _PumpSpeed ("Pump Speed", Float) = 2

        _Pattern ("Interval Size", Float) = 2
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

            #define PI 3.14159265359

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float3 normalWS : TEXCOORD0;
                float2 uv : TEXCOORD1;
            };

            sampler2D _MainTex;
            half4 _Tint;

            float _InflateStrength, _PumpFrequency, _PumpSpeed;
            float _Pattern;

            float SquareWave(float x)
            {
                return round(sin(x) * 0.5 + 0.5);
            }

            Varyings vert(Attributes i)
            {
                Varyings o = (Varyings)0;

                float pumpInput = PI * i.uv.y * _PumpFrequency - 2 * PI * _Time.y * _PumpSpeed;
                float displacement = max(0, sin(pumpInput)) * SquareWave(pumpInput / floor(_Pattern)) * _InflateStrength;
                float3 pos = i.positionOS.xyz + displacement * i.normalOS;

                o.positionCS = UnityObjectToClipPos(float4(pos, 1));

                float3 binormal = cross(i.normalOS, i.tangentOS.xyz) * (i.tangentOS.w * unity_WorldTransformParams.w);

                pumpInput = PI * (i.uv.y - 0.001) * _PumpFrequency - 2 * PI * _Time.y * _PumpSpeed;
                displacement = max(0, sin(pumpInput)) * SquareWave(pumpInput / floor(_Pattern)) * _InflateStrength;
                float3 neighbourPos = i.positionOS.xyz - 0.001 * binormal + displacement * i.normalOS;

                binormal = normalize(neighbourPos - pos);

                o.normalWS = UnityObjectToWorldNormal(normalize(cross(i.tangentOS.xyz, binormal)));

                o.uv = i.uv;

                return o;
            }

            half4 frag(Varyings i) : SV_TARGET
            {
                half4 col = tex2D(_MainTex, i.uv) * _Tint;
                float atten = dot(i.normalWS, _WorldSpaceLightPos0) * 0.5 + 0.5;

                return atten * col;
            }

            ENDCG
        }
    }
}
