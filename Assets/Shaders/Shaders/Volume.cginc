#ifndef VOLUME_INCLUDED
#define VOLUME_INCLUDED

#define EPSILON 0.0005

struct Attributes
{
    float4 positionOS : POSITION;
};

struct Varyings
{
    float4 positionCS : SV_POSITION;
    float3 positionWS : TEXCOORD0;
    float4 positionNDC : TEXCOORD1;
    float3 volumeCenterWS : TEXCOORD2;
};

struct Ray 
{
    float3 origin;
    float3 direction;
};

half3 _Color;
float _Density, _LargeStep, _SmallStep, _MaxDist;

sampler2D _CameraDepthTexture;

// From https://iquilezles.org/articles/smin/
float SMinCubic(float a, float b, float k)
{
    float h = max(k-abs(a-b), 0.0)/k;
    return min(a, b) - h*h*h*k*(1.0/6.0);
}

float SphereSDF(float3 p, float r)
{
    return length(p) - r;
}

float BoxSDF(float3 p, float3 s)
{
    float3 vec = abs(p) - s;
    return length(max(vec, 0)) + max(min(vec.x, min(vec.y, vec.z)), 0);
}

float RoundBoxSDF(float3 p, float3 s, float r)
{
    float3 vec = abs(p) - s;
    return length(max(vec, 0)) + max(min(vec.x, min(vec.y, vec.z)), 0) - r;
} 

float SceneSDF(float3 p)
{
    return SMinCubic(RoundBoxSDF(p, float3(2, 0.5, 2), 0.3), SphereSDF(p - float3(0, 1, 0), 1.5), 0.75);
}

float Raymarch(Ray ray, float3 volumeCenter, float sceneDist)
{
    float transmittance = 1;
    float totalDist = 0;

    while (transmittance > 0.01 && totalDist < _MaxDist)
    {
        float3 p = ray.origin + ray.direction * totalDist;

        float smallStepsToTake = 0;
        float d = SceneSDF(p);

        if (d < 0)
        {
            totalDist = max(0, totalDist - _LargeStep);
            p = ray.origin + ray.direction * totalDist;
            d = SceneSDF(p);

            smallStepsToTake = ceil(_LargeStep / _SmallStep);
        }
        else
        {
            totalDist += _LargeStep;
        }

        while (smallStepsToTake > 0.5 || d < 0)
        {
            if (d < 0) transmittance *= exp(-_Density * _SmallStep);
            
            totalDist += _SmallStep;
            
            if (totalDist > sceneDist) return transmittance;

            p = ray.origin + ray.direction * totalDist;
            d = SceneSDF(p);

            smallStepsToTake--;
        }
        
    }

    return transmittance;
}

Varyings vert(Attributes i)
{
    Varyings o = (Varyings)0;
    o.positionCS = UnityObjectToClipPos(i.positionOS.xyz);
    o.positionWS = mul(unity_ObjectToWorld, i.positionOS);
    o.positionNDC = ComputeScreenPos(o.positionCS);
    o.volumeCenterWS = mul(unity_ObjectToWorld, float4(0, 0, 0, 1));

    return o;
}

half4 frag(Varyings i) : SV_TARGET
{
    Ray r;
    r.origin = _WorldSpaceCameraPos;
    r.direction = normalize(i.positionWS.xyz - _WorldSpaceCameraPos);

    float sceneDist = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.positionNDC.xy / i.positionNDC.w));

    float transmittance = Raymarch(r, i.volumeCenterWS, sceneDist);

    return half4(_Color, 1 - transmittance);
}

#endif