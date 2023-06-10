Shader "Custom/Distortion"
{
    Properties
    {
        [HideInInspector]
        _MainTex ("Main Texture", 2D) = "white" {}

        _DistortionTex ("Distortion Texture", 2D) = "black" {}
        _DistortionStrength ("Distortion Strength", Range(0.01, 1)) = 0.1
        _DistortionSpeed ("Distortion Speed", Float) = 0.2

    }

    SubShader
    {
        Pass
        {
            CGPROGRAM

            #include "UnityCG.cginc"

            #pragma shader_feature _TEST

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
                float2 scaledUV : TEXCOORD1;
            };

            sampler2D _MainTex, _DistortionTex;
            float4 _DistortionTex_ST;

            float _DistortionStrength, _DistortionSpeed;

            Varyings vert(Attributes i)
            {
                Varyings o = (Varyings)0;

                o.positionCS = UnityObjectToClipPos(i.positionOS);
                o.uv = i.uv;
                o.scaledUV = TRANSFORM_TEX(i.uv, _DistortionTex);

                return o;
            }

            half4 frag(Varyings i) : SV_TARGET
            {
                float2 distortion = tex2D(_DistortionTex, i.scaledUV + float2(0, _Time.y * _DistortionSpeed)).xy;

                half4 col = tex2D(_MainTex, i.uv + distortion * _DistortionStrength);


                return col;
            }

            ENDCG
        }
    }
}
