#ifndef TESSELLATION_INCLUDED
#define TESSELLATION_INCLUDED

struct TessellationFactors
{
    float edge[3] : SV_TessFactor;
    float inside : SV_InsideTessFactor;
};

struct TessellationControlPoint
{
    float4 positionOS : INTERNALTESSPOS;
    float3 normalOS : NORMAL;
};

float _TessellationUniform;
float _TessellationEdgeLength;

TessellationControlPoint tessellationVert(Attributes i)
{
    TessellationControlPoint o;
    o.positionOS = i.positionOS;
    o.normalOS = i.normalOS;
    return o;
}

float TessellationEdgeFactor(float3 p0, float3 p1)
{
    #if defined(_TESSELLATION_EDGE)
        float edgeLength = distance(p0, p1);

        float3 edgeCenter = (p0 + p1) * 0.5;
        float viewDistance = distance(edgeCenter, _WorldSpaceCameraPos);

        return edgeLength * _ScreenParams.y / (_TessellationEdgeLength * viewDistance);
    #else
        return _TessellationUniform;
    #endif
}

TessellationFactors PatchConstantFunction(InputPatch<TessellationControlPoint, 3> patch)
{
    float3 p0 = mul(unity_ObjectToWorld, patch[0].positionOS).xyz;
    float3 p1 = mul(unity_ObjectToWorld, patch[1].positionOS).xyz;
    float3 p2 = mul(unity_ObjectToWorld, patch[2].positionOS).xyz;

    TessellationFactors f;
    f.edge[0] = TessellationEdgeFactor(p1, p2);
    f.edge[1] = TessellationEdgeFactor(p2, p0);
    f.edge[2] = TessellationEdgeFactor(p0, p1);
    f.inside = (
        TessellationEdgeFactor(p1, p2) + 
        TessellationEdgeFactor(p2, p0) + 
        TessellationEdgeFactor(p0, p1)) * (1 / 3.0);

    return f;
}

[UNITY_domain("tri")]
[UNITY_outputcontrolpoints(3)]
[UNITY_outputtopology("triangle_cw")]
[UNITY_partitioning("fractional_odd")]
[UNITY_patchconstantfunc("PatchConstantFunction")]
TessellationControlPoint hull(InputPatch<TessellationControlPoint, 3> patch, uint id : SV_OutputControlPointID)
{
    return patch[id];
}

[UNITY_domain("tri")]
Varyings domain(TessellationFactors factors, OutputPatch<TessellationControlPoint, 3> patch, float3 barycentricCoords : SV_DomainLocation)
{
    Attributes data;

    #define DOMAIN_INTERPOLATE(fieldName) data.fieldName = \
        patch[0].fieldName * barycentricCoords.x + \
        patch[1].fieldName * barycentricCoords.y + \
        patch[2].fieldName * barycentricCoords.z;

    DOMAIN_INTERPOLATE(positionOS);
    DOMAIN_INTERPOLATE(normalOS);

    return vert(data);
}

#endif