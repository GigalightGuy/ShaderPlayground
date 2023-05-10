Shader "Custom/Metaballs"
{
    Properties
    {
        _DiffuseColor ("Diffuse Color", Color) = (1, 1, 1)
        
        _SpecularColor ("Specular Color", Color) = (1, 1, 1)
        _SpecularPow ("Specular Power", Float) = 1

        _FresnelColor ("Fresnel Color", Color) = (1, 1, 1)
        _FresnelPow ("Fresnel Power", Float) = 1

        _BlendAmount ("Blend Amount", Range(0.01, 1)) = 0.05
    }

    SubShader
    {
        Tags 
        {
            "Queue" = "Transparent"
        }

        Pass
        {
            Cull Front
            ZTest Always

            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM

            #include "UnityCG.cginc"

            #pragma vertex vert 
            #pragma fragment frag

            #define EPSILON 0.001

            struct Attributes
            {
                float4 positionOS : POSITION;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;

                float3 positionWS : TEXCOORD0;
            };

            struct Ray
            {
                float3 orig;
                float3 dir;
            };

            half3 _DiffuseColor;
        
            half3 _SpecularColor;
            float _SpecularPow;

            half3 _FresnelColor;
            float _FresnelPow;

            float _BlendAmount;

            float4 _Spheres[10];
            int _SphereCount;

            float SphereSDF(float3 p, float r)
            {
                return length(p) - r;
            }

            float SmoothMin(float a, float b, float k)
            {
                float h = max(k - abs(a - b), 0) / k;
                return min(a, b) - h * h * h * k * (1 / 6.0);
            }

            float SceneSDF(float3 p)
            {
                float d = SphereSDF(p - _Spheres[0].xyz, _Spheres[0].w);

                for (int i = 1; i < _SphereCount; i++)
                {
                    d = SmoothMin(d, SphereSDF(p - _Spheres[i].xyz, _Spheres[i].w), _BlendAmount);
                }

                return d;
            }

            float3 EstimateNormal(float3 p)
            {
                float2 h = float2(EPSILON, 0);

                return normalize(float3(
                    SceneSDF(p + h.xyy) - SceneSDF(p - h.xyy),
                    SceneSDF(p + h.yxy) - SceneSDF(p - h.yxy),
                    SceneSDF(p + h.yyx) - SceneSDF(p - h.yyx)
                ));
            }

            half3 CalculateLighting(float3 p, float3 viewDir)
            {
                float3 lightDir = _WorldSpaceLightPos0;
                float3 normal = EstimateNormal(p);

                float3 halfDir = normalize(lightDir + viewDir);

                float diffuseAtten = saturate(dot(normal, lightDir));
                float specularAtten = pow(saturate(dot(normal, halfDir)), _SpecularPow);
                float fresnelStrength = pow(1 - saturate(dot(normal, viewDir)), _FresnelPow);

                half3 diffuse = diffuseAtten * _DiffuseColor;
                half3 specular = specularAtten * _SpecularColor;
                half3 fresnel = fresnelStrength * _FresnelColor;

                return saturate(diffuse + specular + fresnel);
            }

            half4 Raymarch(Ray r)
            {
                float length = 0;

                for (int i = 0; i < 150; i++)
                {
                    float d = SceneSDF(r.orig + length * r.dir);

                    if (d < EPSILON)
                    {
                        return half4(CalculateLighting(r.orig + length * r.dir, -r.dir), 1);
                    }

                    length += d;
                }

                return 0;
            }

            Varyings vert(Attributes i)
            {
                Varyings o = (Varyings)0;
                
                o.positionCS = UnityObjectToClipPos(i.positionOS.xyz);
                o.positionWS = mul(unity_ObjectToWorld, i.positionOS).xyz;

                return o;
            }

            half4 frag(Varyings i) : SV_TARGET
            {
                Ray r;
                r.orig = _WorldSpaceCameraPos;
                r.dir = normalize(i.positionWS - _WorldSpaceCameraPos);

                half4 col = Raymarch(r);


                return col;
            }

            ENDCG
        }
    }
}
