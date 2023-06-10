Shader "Custom/AnimatedDottedLines"
{
    Properties
    {
        _LineColor ("Line Color", Color) = (1, 1, 1, 1)
        _BackgroundColor ("Background Color", Color) = (0, 0, 0, 0.5)

        _ScrollSpeed ("Scroll Speed", Float) = 3
        
        _LineLength ("Line Length", Range(0.01, 0.1)) = 0.025
        _LineWidth ("Line Width", Range(0.001, 0.05)) = 0.005

        _LineSpacing ("Line Spacing", Range(0.01, 0.2)) = 0.1

        [Header(Box Trim)]
        _BoxHalfSize ("Box Half Size", Range(0.1, 0.5)) = 0.445
        _BoxRound ("Box Roundness", Range(0.001, 0.05)) = 0.01
    }

    SubShader
    {
        Tags
        {
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
        }

        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha

            ZWrite Off

            CGPROGRAM

            #include "UnityCG.cginc"

            #pragma vertex vert 
            #pragma fragment frag

            struct Attributes
            {
                float4 positionOS : POSITION;

                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;

                float2 uv : TEXCOORD0;
            };

            half4 _LineColor, _BackgroundColor;
            float _ScrollSpeed, _LineLength, _LineWidth, _LineSpacing;

            float _BoxHalfSize, _BoxRound;

            float2 RepeatPos2DX(float2 p, float c)
            {
                float2 h = float2(round(p.x / c), 0);
                return p - c * h;
            }

            float2 RepeatPos2DY(float2 p, float c)
            {
                float2 h = float2(0, round(p.y / c));
                return p - c * h;
            }

            float SDFHorizontalCapsule2D(float2 p, float l, float r)
            {
                p.x -= clamp(p.x, -l, l);
                return length(p) - r;
            }

            float SDFVerticalCapsule2D(float2 p, float l, float r)
            {
                p.y -= clamp(p.y, -l, l);
                return length(p) - r;
            }

            float SDFRoundBox2D(float2 p, float2 s, float r)
            {
                float2 q = abs(p) - s;
                return length(max(q, 0)) + min(max(q.x, q.y), 0) - r;
            }

            float SceneSDF(float2 pos)
            {
                float d;

                float offset = _ScrollSpeed * _Time.x;

                float2 upperLine = RepeatPos2DX(pos - float2(offset, 0) - float2(0.5, 0.95), _LineSpacing);
                d = SDFHorizontalCapsule2D(upperLine, _LineLength, _LineWidth);

                float2 lowerLine = RepeatPos2DX(pos + float2(offset, 0) - float2(0.5, 0.05), _LineSpacing);
                d = min(d, SDFHorizontalCapsule2D(lowerLine, _LineLength, _LineWidth));

                float2 leftLine = RepeatPos2DY(pos - float2(0, offset) - float2(0.05, 0.5), _LineSpacing);
                d = min(d, SDFVerticalCapsule2D(leftLine, _LineLength, _LineWidth));

                float2 rightLine = RepeatPos2DY(pos + float2(0, offset) - float2(0.95, 0.5), _LineSpacing);
                d = min(d, SDFVerticalCapsule2D(rightLine, _LineLength, _LineWidth));

                d = max(d, SDFRoundBox2D(pos - 0.5, _BoxHalfSize, _BoxRound));

                return d;
            }

            Varyings vert(Attributes i)
            {
                Varyings o = (Varyings)0;

                o.positionCS = UnityObjectToClipPos(i.positionOS);
                o.uv = i.uv;

                return o;
            }

            half4 frag(Varyings i) : SV_TARGET
            {
                half4 col = lerp(_BackgroundColor, _LineColor, saturate(1 - ceil(SceneSDF(i.uv))));

                return col;
            }

            ENDCG
        }
    }
}
