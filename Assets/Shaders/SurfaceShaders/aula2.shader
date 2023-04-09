Shader "Custom/aula2"
{
     Properties
    {
        _mainColor("A cor Bro!", Color)=(1,1,1,1)
    }

    SubShader
    {
     Cull off
        CGPROGRAM
            #pragma surface surf Lambert 


        struct Input {
        float2 uvMainTex;
        };

        fixed3 _mainColor; 

        void surf(Input IN, inout SurfaceOutput o) {
            //o.Albedo = _mainColor.rgb;
            o.Albedo= o.Normal;
           // o.Normal=abs(o.Normal);
            if(o.Normal.y>0.9f){
            discard;
            }
        }

        ENDCG
    }
        FallBack "Diffuse"
}
