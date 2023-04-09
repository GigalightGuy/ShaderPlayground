Shader "Custom/RayMarching"
{
    Properties
    {
        [HideInInspector] _MainTex ("Main Texture", 2D) = "white" {}

        [Header(Ray Marching Settings)]
        _MaxDistance ("Max Ray March Distance", Range(10, 1000)) = 250
    }

    SubShader
    {
        Cull Off
        ZWrite Off
        ZTest Always

        Pass 
        {
            HLSLPROGRAM

            #include "UnityCG.cginc"
            #include "UnityLightingCommon.cginc"

            #pragma vertex vert 
            #pragma fragment frag 

            #define EPSILON 0.0001
            #define MAX_RAYMARCH_ITERATIONS 255

            float4x4 _CamToWorld, _CamInvProj;

            sampler2D _MainTex, _CameraDepthTexture;

            float4 _SpheresPos[5];
            float _SpheresRadius[5];
            int _ActiveSpheres;

            float _MaxDistance, _MaxIterations;

            struct appdata 
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f 
            {
                float4 position : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.position = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            struct Ray 
            {
                float3 origin;
                float3 direction;
            };

            Ray getCameraRay(float2 uv)
            {
                Ray ray;
                ray.origin = mul(_CamToWorld, float4(0, 0, 0, 1)).xyz;
                ray.direction = mul(_CamInvProj, float4(uv, 0, 1)).xyz;
                ray.direction = mul(_CamToWorld, float4(ray.direction, 0)).xyz;
                ray.direction = normalize(ray.direction);
                return ray;
            }

            float depthToDistance(float depth)
            {
                return Linear01Depth(depth) * (_ProjectionParams.z - _ProjectionParams.y);
            }
            
            float circleSDF(float2 p, float r)
            {
                return length(p) - r;
            }

            float sphereSDF(float3 p, float r)
            {
                return length(p) - r;
            }

            float sceneSDF(float3 p)
            {
                float dist = _MaxDistance;
                dist = sphereSDF(p - _SpheresPos[0], _SpheresRadius[0]);
                return dist;
            }

            float3 sampleNormal(float3 p)
            {
                static const float2 h = float2(EPSILON, 0);
                return normalize(float3(
                    sceneSDF(p + h.xyy) - sceneSDF(p - h.xyy),
                    sceneSDF(p + h.yxy) - sceneSDF(p - h.yxy),
                    sceneSDF(p + h.yyx) - sceneSDF(p - h.yyx)
                ));
            }

            fixed3 calculateLighting(float3 p, fixed3 col)
            {
                float3 nor = sampleNormal(p);
                return col * saturate(dot(nor, _WorldSpaceLightPos0.xyz)) * _LightColor0.rgb;
            }

            fixed3 rayMarch(Ray ray, float2 uv)
            {
                float3 pos = ray.origin;

                fixed3 originalSceneCol= tex2D(_MainTex, uv).rgb;
                float originalSceneDist = depthToDistance(tex2D(_CameraDepthTexture, uv).r);

                float dist = 0;
                float rayDist = 0;

                [loop] for (uint i = 0; i < MAX_RAYMARCH_ITERATIONS; i++)
                {
                    dist = sceneSDF(ray.origin + rayDist * ray.direction);

                    if (dist < EPSILON)
                    {
                        return rayDist < originalSceneDist ? 
                            calculateLighting(ray.origin + rayDist * ray.direction, fixed3(1, 0, 0)) 
                            : originalSceneCol;
                    }

                    rayDist += dist;

                    if (rayDist > _MaxDistance)
                    {
                        return originalSceneCol;
                    }
                }

                return originalSceneCol;
            }

            fixed4 frag(v2f i) : SV_TARGET
            {
                float2 centeredUV = i.uv * 2 - 1;
                Ray ray = getCameraRay(centeredUV);

                fixed3 col = rayMarch(ray, i.uv);

                return fixed4(col, 1);
            }

            ENDHLSL 
        }
    }
}
