#ifndef VOLUME_INCLUDED
#define VOLUME_INCLUDED

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

float BoxSDF(float3 p, float3 s)
{
    float3 vec = abs(p) - s;
    return length(max(vec, 0)) + max(min(vec.x, min(vec.y, vec.z)), 0);
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
    r.origin = _WorldSpaceCameraPos;
    r.direction = normalize(-WorldSpaceViewDir(float4(i.positionWS, 1)));

    float d = BoxSDF(i.positionWS - i.volumeCenterWS, 0.5);


    return d < 0.005f ? half4(1, 1, 0, 1) : 0;
}

#endif