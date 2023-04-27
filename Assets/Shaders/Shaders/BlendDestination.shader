Shader "Custom/Blend"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}

    }

    SubShader
    {
        Tags { "Queue" = "Geometry" }

        Pass
        {
            SetTexture [_MainTex] {combine texture}
        }
        
    }

    FallBack "Diffuse"
}
