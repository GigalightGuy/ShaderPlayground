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
    float3 volumeCenterWS : TEXCOORD1;
};

struct Ray 
{
    float3 origin;
    float3 direction;
};

float _Density;

float BoxSDF(float3 p, float3 s)
{
    float3 vec = abs(p) - s;
    return length(max(vec, 0)) + max(min(vec.x, min(vec.y, vec.z)), 0);
}

float Raymarch(Ray ray, int maxIter, float maxDist, float3 volumeCenter)
{
    float progress = 0;
    int i = 0;

    while (i < maxIter)
    {
        float d = BoxSDF(ray.origin + ray.direction * progress - volumeCenter, 0.5);

        if (d < EPSILON)
        {
            break;
        }

        progress += d;

        i++;
    }

    float volDist = 0;

    while (i < maxIter)
    {
        float d = BoxSDF(ray.origin + ray.direction * progress - volumeCenter, 0.5);

        if (d > EPSILON) break;
        
        volDist += 0.01;

        progress += 0.01;

        i++;
    }

    float luminance = exp(-volDist * _Density);

    return luminance;
}

Varyings vert(Attributes i)
{
    Varyings o = (Varyings)0;
    o.positionCS = UnityObjectToClipPos(i.positionOS.xyz);
    o.positionWS = mul(unity_ObjectToWorld, i.positionOS);
    o.volumeCenterWS = mul(unity_ObjectToWorld, float4(0, 0, 0, 1));

    return o;
}

half4 frag(Varyings i) : SV_TARGET
{
    Ray r;
    r.origin = i.positionWS;
    r.direction = normalize(-WorldSpaceViewDir(float4(i.positionWS, 1)));

    float luminance = Raymarch(r, 250, 100, i.volumeCenterWS);

    return half4(0, 1, 0, 1 - luminance);
}

#endif