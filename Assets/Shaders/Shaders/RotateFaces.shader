Shader "Custom/RotateFaces"
{
    Properties
    {
        
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
                float3 normalOS : NORMAL;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
            };

            // From https://gist.github.com/keijiro
            // Rotation with angle (in radians) and axis
            float3x3 AngleAxis3x3(float angle, float3 axis)
            {
                float c, s;
                sincos(angle, s, c);

                float t = 1 - c;
                float x = axis.x;
                float y = axis.y;
                float z = axis.z;

                return float3x3(
                    t * x * x + c,      t * x * y - s * z,  t * x * z + s * y,
                    t * x * y + s * z,  t * y * y + c,      t * y * z - s * x,
                    t * x * z - s * y,  t * y * z + s * x,  t * z * z + c
                );
            }

            Varyings vert(Attributes i)
            {
                Varyings o;

                float4 pos = i.positionOS;

                pos.xyz = mul(AngleAxis3x3(_Time.y, i.normalOS), pos.xyz);

                o.positionCS = UnityObjectToClipPos(pos);

                return o;
            }

            half4 frag(Varyings i) : SV_TARGET
            {
                return 1;
            }

            ENDCG 
        }
    }
}
