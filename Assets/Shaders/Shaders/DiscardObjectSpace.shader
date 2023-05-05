Shader "Custom/DiscardObjectSpace"
{
    Properties
    {
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
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float3 positionOS : TEXCOORD0;
            };

            float _CutSlider;

            Varyings vert(Attributes i)
            {
                Varyings o;

                o.positionCS = UnityObjectToClipPos(i.positionOS.xyz);
                o.positionOS = i.positionOS.xyz;

                return o;
            }

            half4 frag(Varyings i) : SV_TARGET
            {
                if (i.positionOS.x < _CutSlider)
                {
                    discard;
                }

                return 1;
            }

            ENDCG

        }
        
    }
}
