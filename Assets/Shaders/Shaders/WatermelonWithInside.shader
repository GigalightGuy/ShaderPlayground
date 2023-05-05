Shader "Custom/WatermelonWithInside"
{
    Properties
    {
        _WatermelonTex ("Watermelon Texture", 2D) = "white" {}
        _WatermelonInsideTex ("Watermelon Inside Texture", 2D) = "black" {}

        _CutSlider ("Cut Slider", Range(-0.5, 0.5)) = -0.5
    }

    SubShader
    {
        Pass 
        {
            CGPROGRAM

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
                float positionOS : TEXCOORD0;
                float2 uv : TEXCOORD1;
            };

            sampler2D _WatermelonTex, _WatermelonInsideTex;
            float _CutSlider;

            Varyings vert(Attributes i)
            {
                Varyings o;

                float3 transformedPosOS = i.positionOS.xyz;

                if (i.positionOS.x > _CutSlider)
                {
                    transformedPosOS.x = _CutSlider;

                    if (transformedPosOS.x < 0)
                    {
                        float cosThetaSqr = pow(transformedPosOS.x * 2, 2);
                        float sin = sqrt(1 - cosThetaSqr);

                        if (i.positionOS.x > 0)
                        {
                            transformedPosOS.yz = sin * transformedPosOS.yz;
                        }
                        else
                        {
                            transformedPosOS.yz = sin * normalize(transformedPosOS.yz) * 0.5;
                        }
                        
                    }
                }

                o.positionCS = UnityObjectToClipPos(transformedPosOS);
                o.positionOS = i.positionOS.xyz;
                o.uv = i.uv;

                return o;
            }

            half4 frag(Varyings i) : SV_TARGET
            {
                half3 col;

                if (i.positionOS.x > _CutSlider + 0.02)
                {
                    col = tex2D(_WatermelonInsideTex, i.uv).rgb;
                }
                else if (i.positionOS.x > _CutSlider)
                {
                    col = 1;
                }
                else
                {
                    col = tex2D(_WatermelonTex, i.uv).rgb;
                }

                return half4(col, 1);
            }

            ENDCG

        }
        
    }
}
