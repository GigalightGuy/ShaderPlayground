Shader "Custom/Fire"
{
    Properties
    {
        [HDR] _BaseColor ("Base Color", Color) = (1, 0.5, 0.1)
        [HDR] _ExtraColor ("Extra Color", Color) = (1, 1, 0)
        _ColorMultiplier ("Color Multiplier", Range(1, 5)) = 2

        [NoScaleOffset] _NoiseTex ("Noise Texture", 2D) = "grey" {}
        [NoScaleOffset] _MaskTex ("Mask Texture", 2D) = "white" {}
        [NoScaleOffset] _VoronoiTex ("Voronoi Texture", 2D) = "white" {}
        [Power(4)] _VoronoiExponent ("Voronoi Exponent", Range(0.5, 4)) = 1

        _DisplacementStrength ("Displacement Strength", Range(0, 1)) = 0.05
        _ScrollSpeed ("Scroll Speed", Range(0.2, 1.5)) = 1

        _PosterizeSteps ("Posterize Steps", Range(2, 50)) = 5
        [Toggle(_POSTERIZE_ON)] _Posterize ("Enable Posterize", Float) = 0
    }

    SubShader
    {
        Tags { "Queue" = "Transparent" }

        Pass 
        {
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off

            CGPROGRAM

            #pragma vertex vert 
            #pragma fragment frag

            #pragma shader_feature _POSTERIZE_ON

            #include "UnityCG.cginc"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;

                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;

                float2 uv : TEXCOORD0;
            };

            half4 _BaseColor, _ExtraColor;
            float _ColorMultiplier;

            sampler2D _NoiseTex, _MaskTex, _VoronoiTex;
            float _VoronoiExponent, _DisplacementStrength;

            float _ScrollSpeed;

            float _PosterizeSteps;

            Varyings vert(Attributes i)
            {
                Varyings o;
                o.uv = i.uv;

                float3 pos = mul(unity_ObjectToWorld, i.positionOS).xyz;

                float4 mask = tex2Dlod(_MaskTex, float4(i.uv, 0, 0));
                float3 displacement = tex2Dlod(_NoiseTex, float4(i.uv.x, i.uv.y - _Time.y * _ScrollSpeed, 0, 0)).rgb;
                displacement -= 0.5;
                displacement *= _DisplacementStrength * mask.a;
                pos += displacement;

                o.positionCS = UnityWorldToClipPos(pos);

                return o;
            }

            half AverageRGB(half3 rgb)
            {
                return (rgb.r + rgb.g + rgb.b) * (1/3.0);
            }

            half4 Posterize(half4 color, float steps)
            {
                return round(color * steps) / steps;
            }

            half4 frag(Varyings i) : SV_TARGET
            {
                half4 col;

                float2 scrollUV = float2(i.uv.x, i.uv.y - _Time.y * _ScrollSpeed);
                half3 noise = tex2D(_NoiseTex, scrollUV).rgb;
                half voronoi = pow(tex2D(_VoronoiTex, scrollUV).r, _VoronoiExponent);

                half4 distortedMask = tex2D(_MaskTex, float2(i.uv.x + (noise.g - 0.5) * 0.1, i.uv.y * noise.r));
                half4 mask = tex2D(_MaskTex, i.uv);

                noise.r = saturate(distortedMask.r * voronoi * noise.r * _ColorMultiplier);

                col = lerp(_ExtraColor, _BaseColor, noise.r);
                col.a *= noise.r;

                #if defined(_POSTERIZE_ON)
                    col = Posterize(col, _PosterizeSteps);
                #endif

                return col;
            }

            ENDCG 
        }
    }
}
