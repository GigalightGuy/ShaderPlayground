Shader "Custom/Fire"
{
    Properties
    {
        [HDR] _BaseColor ("Base Color", Color) = (1, 0.5, 0.1)
        [HDR] _ExtraColor ("Extra Color", Color) = (1, 1, 0)
        _ColorMultiplier ("Color Multiplier", Range(1, 5)) = 2

        [NoScaleOffset] _NoiseTex ("Noise Texture", 2D) = "grey" {}
        [NoScaleOffset] _MaskTex ("Mask Texture", 2D) = "white" {}
        //[NoScaleOffset] _VoronoiTex ("Voronoi Texture", 2D) = "white" {}
        //[Power(4)] _VoronoiExponent ("Voronoi Exponent", Range(0.5, 4)) = 1

        [KeywordEnum(Off, Object, World)] _Triplanar ("Triplanar Mode", Float) = 0
        _UVScale ("UV Scale", Vector) = (1, 1, 1, 1)

        _DisplacementStrength ("Displacement Strength", Range(0, 1)) = 0.05
        _ScrollSpeed ("Scroll Speed", Range(0.2, 1.5)) = 1
        _FlameHeight ("Flame Height", Range(0.5, 2)) = 1

        _PosterizeSteps ("Posterize Steps", Range(2, 50)) = 5
        [Toggle(_POSTERIZE_ON)] _Posterize ("Enable Posterize", Float) = 0

        [Enum(UnityEngine.Rendering.CullMode)] _CullMode ("Cull Mode", Int) = 0
    }

    SubShader
    {
        Tags { "Queue" = "Transparent" }

        Pass 
        {
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off

            Cull [_CullMode]

            CGPROGRAM

            #pragma vertex vert 
            #pragma fragment frag

            #pragma shader_feature _POSTERIZE_ON
            #pragma shader_feature _TRIPLANAR_OFF _TRIPLANAR_OBJECT _TRIPLANAR_WORLD

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
                float3 position : TEXCOORD1;
                float3 normal : TEXCOORD2;
            };

            half4 _BaseColor, _ExtraColor;
            float _ColorMultiplier;

            sampler2D _NoiseTex, _MaskTex;
            float _DisplacementStrength;

            float2 _UVScale;
            float _ScrollSpeed, _FlameHeight;

            float _PosterizeSteps;

            Varyings vert(Attributes i)
            {
                Varyings o;
                o.uv = i.uv;

                float3 pos = mul(unity_ObjectToWorld, i.positionOS).xyz;

                float4 mask = tex2Dlod(_MaskTex, float4(i.uv, 0, 0));
                float3 displacement = tex2Dlod(_NoiseTex, 
                    float4(i.uv.x * _UVScale.x, i.uv.y * _UVScale.y - _Time.y * _ScrollSpeed, 0, 0)).rgb;
                displacement -= 0.5;
                displacement *= _DisplacementStrength * mask.a;
                pos += displacement;

                #if defined(_TRIPLANAR_OBJECT)
                    o.position = mul(unity_WorldToObject, float4(pos, 1)).xyz;
                    o.normal = i.normalOS;
                #elif defined(_TRIPLANAR_WORLD)
                    o.position = pos;
                    o.normal = UnityObjectToWorldNormal(i.normalOS);
                #endif


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

            struct TriplanarUV
            {
                float2 x;
                float2 y;
                float2 z;
            };

            TriplanarUV GetTriplanarUV(float3 pos, float3 nor)
            {
                TriplanarUV triUV;
                triUV.x = pos.zy;
                triUV.y = pos.xz + 0.25;
                triUV.z = pos.xy + 0.75;

                return triUV;
            }

            float3 GetTriplanarWeights(float3 nor)
            {
                float3 triW = abs(nor);
                return triW / (triW.x + triW.y + triW.z);
            }

            half4 frag(Varyings i) : SV_TARGET
            {
                #if !defined(_TRIPLANAR_OFF)
                    TriplanarUV triUV = GetTriplanarUV(i.position, i.normal);
                    triUV.x *= _UVScale;
                    triUV.y *= _UVScale;
                    triUV.z *= _UVScale;
                    float3 triW = GetTriplanarWeights(i.normal);

                    TriplanarUV scrollingTriUV = triUV;
                    scrollingTriUV.x += float2(-_Time.y * _ScrollSpeed * 0.23, -_Time.y * _ScrollSpeed);
                    // inverted to have scroll direction match unity's plane uv orientation
                    scrollingTriUV.y += float2(-_Time.y * _ScrollSpeed * 0.23,  _Time.y * _ScrollSpeed);
                    scrollingTriUV.z += float2(-_Time.y * _ScrollSpeed * 0.23, -_Time.y * _ScrollSpeed);
                    half3 noise1 = triW.x * tex2D(_NoiseTex, scrollingTriUV.x).rgb +
                                triW.y * tex2D(_NoiseTex, scrollingTriUV.y).rgb +
                                triW.z * tex2D(_NoiseTex, scrollingTriUV.z).rgb;

                    scrollingTriUV = triUV;
                    scrollingTriUV.x += float2( _Time.y * _ScrollSpeed * 0.47, -_Time.y * _ScrollSpeed * 1.37);
                    // inverted to have scroll direction match unity's plane uv orientation
                    scrollingTriUV.y += float2( _Time.y * _ScrollSpeed * 0.47,  _Time.y * _ScrollSpeed * 1.37);
                    scrollingTriUV.z += float2( _Time.y * _ScrollSpeed * 0.47, -_Time.y * _ScrollSpeed * 1.37);
                    half3 noise2 = triW.x * tex2D(_NoiseTex, scrollingTriUV.x).rgb +
                                triW.y * tex2D(_NoiseTex, scrollingTriUV.y).rgb +
                                triW.z * tex2D(_NoiseTex, scrollingTriUV.z).rgb;

                    scrollingTriUV = triUV;
                    scrollingTriUV.x += float2(0, -_Time.y * _ScrollSpeed * 0.86);
                    // inverted to have scroll direction match unity's plane uv orientation
                    scrollingTriUV.y += float2(0,  _Time.y * _ScrollSpeed * 0.86);
                    scrollingTriUV.z += float2(0, -_Time.y * _ScrollSpeed * 0.86);
                    half3 noise3 = triW.x * tex2D(_NoiseTex, scrollingTriUV.x).rgb +
                                triW.y * tex2D(_NoiseTex, scrollingTriUV.y).rgb +
                                triW.z * tex2D(_NoiseTex, scrollingTriUV.z).rgb;
                #else
                    float2 scrollingUV = i.uv * _UVScale;
                    scrollingUV += float2(-_Time.y * _ScrollSpeed * 0.23, -_Time.y * _ScrollSpeed);
                    half3 noise1 = tex2D(_NoiseTex, scrollingUV).rgb;

                    scrollingUV = i.uv * _UVScale;
                    scrollingUV += float2(_Time.y * _ScrollSpeed * 0.47, -_Time.y * _ScrollSpeed * 1.37);
                    half3 noise2 = tex2D(_NoiseTex, scrollingUV).rgb;

                    scrollingUV = i.uv * _UVScale;
                    scrollingUV += float2(0, -_Time.y * _ScrollSpeed * 0.86);
                    half3 noise3 = tex2D(_NoiseTex, scrollingUV).rgb;
                #endif
                

                half3 noise = half3(noise1.r, noise2.g, noise3.b);

                //half voronoi = pow(tex2D(_VoronoiTex, scrollUV).r, _VoronoiExponent);

                half4 distortedMask = tex2D(_MaskTex, float2(i.uv.x + (noise.g - 0.5) * 0.1, i.uv.y * noise.r * _FlameHeight));
                half4 mask = tex2D(_MaskTex, i.uv);

                noise.r = saturate(distortedMask.r * noise.r * _ColorMultiplier);

                half4 col = lerp(_ExtraColor, _BaseColor, noise.r);
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
