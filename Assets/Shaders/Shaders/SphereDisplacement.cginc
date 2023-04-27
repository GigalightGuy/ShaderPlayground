#ifndef SPHERE_DISPLACEMENT_INCLUDED
#define SPHERE_DISPLACEMENT_INCLUDED

half4 _BaseColor;
half4 _WireframeColor;
float _WireframeSmoothing, _WireframeThickness;

float3 _DisplacementPos;
float _DisplacementRadius;

struct Attributes
{
    float4 positionOS : POSITION;
    float3 normalOS : NORMAL;
};

struct Varyings
{
    float4 positionCS : SV_POSITION;
    float4 positionWS : TEXCOORD0;
    float3 normalWS : TEXCOORD1;
};

struct VaryingsGeometry
{
    Varyings data;
    float2 barycentricCoords : TEXCOORD9;
};

Varyings vert(Attributes i)
{
    Varyings o = (Varyings)0;

    o.positionWS = mul(unity_ObjectToWorld, i.positionOS);

    float3 displaceVec = o.positionWS.xyz - _DisplacementPos;
    float displaceStrength = max(_DisplacementRadius - length(displaceVec), 0);
    float3 displaceDir = normalize(displaceVec);
    float3 displacement = displaceStrength * displaceDir;

    o.positionWS.xyz += displacement;

    o.positionCS = UnityObjectToClipPos(mul(unity_WorldToObject, o.positionWS).xyz);

    o.normalWS = UnityObjectToWorldNormal(i.normalOS);
    o.normalWS = displaceStrength > 0.0001 ? -displaceDir : o.normalWS;

    return o;
}

[maxvertexcount(3)]
void geom(triangle Varyings i[3], inout TriangleStream<VaryingsGeometry> stream)
{
    float3 p0 = i[0].positionWS.xyz;
    float3 p1 = i[1].positionWS.xyz;
    float3 p2 = i[2].positionWS.xyz;

    // float3 triangleNormal = normalize(cross(p1 - p0, p2 - p0));
    // i[0].normalWS = triangleNormal;
    // i[1].normalWS = triangleNormal;
    // i[2].normalWS = triangleNormal;

    VaryingsGeometry g0, g1, g2;
    g0.data = i[0];
    g1.data = i[1];
    g2.data = i[2];

    g0.barycentricCoords = float2(1, 0);
    g1.barycentricCoords = float2(0, 1);
    g2.barycentricCoords = float2(0, 0);

    stream.Append(g0);
    stream.Append(g1);
    stream.Append(g2);
}

half4 frag(VaryingsGeometry i) : SV_TARGET
{
    half4 col;

    #if defined(_SHADER_WIREFRAME)
        float3 barys;
        barys.xy = i.barycentricCoords;
        barys.z = 1 - barys.x - barys.y;

        float3 deltas = fwidth(barys);
        float3 smoothing = deltas * _WireframeSmoothing;
        float3 thickness = deltas * _WireframeThickness;
        barys = smoothstep(thickness, thickness + smoothing, barys);

        float minBary = min(barys.x, min(barys.y, barys.z));

        col = lerp(_WireframeColor, _BaseColor, minBary);
    #else
        col = dot(i.data.normalWS, _WorldSpaceLightPos0);
    #endif

    return col;
}

#endif